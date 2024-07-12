library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity bcm is
  port
  (
    i_clk : in std_logic;
    i_res : in std_logic;

    i_data0 : in std_logic_vector(23 downto 0); --upper half data 
    i_data1 : in std_logic_vector(23 downto 0); --lower half data

    o_data0 : out std_logic_vector(2 downto 0); --upper half data 
    o_data1 : out std_logic_vector(2 downto 0); --lower half data
    o_clk   : out std_logic;

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
              if r_bcm_phase = 7 then
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
      o_lat <= '1';
      o_oe  <= '0';
      w_enable_o_clk <= '0';
    else
      case r_state is
        when s_write =>
          o_lat <= '0';
          o_oe  <= '1';
          w_enable_o_clk <= '1';
        when s_output_disable =>
          o_lat <= '0';
          o_oe  <= '0';
          w_enable_o_clk <= '0';
        when s_latch =>
          o_lat <= '1';
          o_oe  <= '0';
          w_enable_o_clk <= '0';
        when others =>
          o_lat <= '0';
          o_oe  <= '1';
          w_enable_o_clk <= '0';
      end case;
    end if;
  end process;

  with w_enable_o_clk select
    o_clk <= i_clk when '1',
    '0' when others;

  o_data0   <= i_data0(r_bcm_phase + 16) & i_data0(r_bcm_phase + 8) & i_data0(r_bcm_phase);
  o_data1   <= i_data1(r_bcm_phase + 16) & i_data1(r_bcm_phase + 8) & i_data1(r_bcm_phase);
  o_address <= std_logic_vector(r_row) & std_logic_vector(r_column);
end RTL;