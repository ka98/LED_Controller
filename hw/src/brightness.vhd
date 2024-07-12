library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity brightness is
  port
  (
    i_clk        : in std_logic;
    i_brightness : in std_logic_vector(7 downto 0);

    o_pwm : out std_logic

  );
end entity;

architecture RTL of brightness is
  signal r_counter : UNSIGNED(7 downto 0) := (others => '0');
begin

  process (i_clk)
  begin
    if rising_edge(i_clk) then
      r_counter <= r_counter + 1;
    end if;
  end process;

  process (r_counter)
  begin
    if i_brightness < std_logic_vector(r_counter) then
      o_pwm <= '0';
    else
      o_pwm <= '1';
    end if;
  end process;

end RTL;