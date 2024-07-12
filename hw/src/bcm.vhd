library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity bcm is
  generic
  (
    BIT_DEPTH : integer := 7
  );
  port
  (
    i_clk : in std_logic;
    i_res : in std_logic;

    i_brightness_pwm : in std_logic;

    i_data0 : in std_logic_vector(23 downto 0); --upper half data 
    i_data1 : in std_logic_vector(23 downto 0); --lower half data

    o_data0 : out std_logic_vector(2 downto 0); --upper half data 
    o_data1 : out std_logic_vector(2 downto 0); --lower half data
    o_clk   : out std_logic;

    o_A : out std_logic;
    o_B : out std_logic;
    o_C : out std_logic;
    o_D : out std_logic;
    o_E : out std_logic;

    o_R0 : out std_logic;
    o_R1 : out std_logic;
    o_G0 : out std_logic;
    o_G1 : out std_logic;
    o_B0 : out std_logic;
    o_B1 : out std_logic;

    o_lat : out std_logic;
    o_oe  : out std_logic;

    o_address : out std_logic_vector(10 downto 0)

  );
end entity;

architecture RTL of bcm is

  type t_state is (
    s_write,
    s_output_disable,
    s_latch,
    s_wait
  );

  signal r_state : t_state;

  signal r_column    : unsigned(5 downto 0) := (others => '0');
  signal r_row       : unsigned(4 downto 0) := (others => '0');
  signal r_bcm_phase : integer              := 0;

  signal w_enable_o_clk : std_logic;
  signal w_data0        : std_logic_vector(2 downto 0);
  signal w_data1        : std_logic_vector(2 downto 0);
  signal w_oe : std_logic;

  signal r_wait_counter : unsigned(13 downto 0);

begin

  process (i_clk)
  begin
    if (rising_edge(i_clk)) then

      if (i_res = '1') then
        r_state <= s_write;

        r_column       <= (others => '0');
        r_row          <= (others => '0');
        r_bcm_phase    <= 0;
        r_wait_counter <= (others => '0');
      else
        case r_state is
          when s_write =>
            r_column <= r_column + 1;
            if r_column = "111111" then
              r_state <= s_output_disable;
            end if;

          when s_output_disable =>
            r_state <= s_latch;

          when s_latch              =>
            r_wait_counter <= (others => '0');
            if r_bcm_phase = 0 then
              r_state     <= s_write;
              r_bcm_phase <= r_bcm_phase + 1;
            else
              r_state <= s_wait;
            end if;

          when s_wait =>
            r_wait_counter <= r_wait_counter + 1;

            if r_wait_counter = shift_left(X"0043", r_bcm_phase) - X"0043" then
              r_state <= s_write;
              if r_bcm_phase = BIT_DEPTH - 1 then
                r_bcm_phase <= 0;
                r_row       <= r_row + 1;
              else
                r_bcm_phase <= r_bcm_phase + 1;
              end if;
            end if;
        end case;
      end if;
    end if;

  end process;

  process (r_state, i_res)
  begin

    if i_res = '1' then
      o_lat          <= '1';
      w_oe           <= '0';
      w_enable_o_clk <= '0';
    else
      case r_state is
        when s_write =>
          o_lat          <= '0';
          w_oe           <= '1';
          w_enable_o_clk <= '1';
        when s_output_disable =>
          o_lat          <= '0';
          w_oe           <= '0';
          w_enable_o_clk <= '0';
        when s_latch =>
          o_lat          <= '1';
          w_oe           <= '0';
          w_enable_o_clk <= '0';
        when others =>
          o_lat          <= '0';
          w_oe           <= '1';
          w_enable_o_clk <= '0';
      end case;
    end if;
  end process;

  with w_enable_o_clk select
    o_clk <= i_clk when '1',
    '0' when others;

  o_R0 <= w_data0(2);
  o_R1 <= w_data1(2);
  o_G0 <= w_data0(1);
  o_G1 <= w_data1(1);
  o_B0 <= w_data0(0);
  o_B1 <= w_data1(0);

  o_data0 <= w_data0;
  o_data1 <= w_data1;

  o_A <= std_logic(r_row(0));
  o_B <= std_logic(r_row(1));
  o_C <= std_logic(r_row(2));
  o_D <= std_logic(r_row(3));
  o_E <= std_logic(r_row(4));

  w_data0   <= i_data0(r_bcm_phase + 16 + (8 - BIT_DEPTH)) & i_data0(r_bcm_phase + 8 + (8 - BIT_DEPTH)) & i_data0(r_bcm_phase + (8 - BIT_DEPTH));
  w_data1   <= i_data1(r_bcm_phase + 16 + (8 - BIT_DEPTH)) & i_data1(r_bcm_phase + 8 + (8 - BIT_DEPTH)) & i_data1(r_bcm_phase + (8 - BIT_DEPTH));
  o_address <= std_logic_vector(r_row) & std_logic_vector(r_column);

  o_oe <= w_oe and i_brightness_pwm;
end RTL;