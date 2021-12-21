library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of pulse_gen_tb is
   component pulse_gen
      port(clk	: in std_logic;
   	reset : in std_logic;
   	count_in  : in  std_logic_vector(9 downto 0);
           load_next : out std_logic;
   	stop_clearing : out std_logic);
   end component;
   signal clk	: std_logic;
   signal reset : std_logic;
   signal count_in  : std_logic_vector(9 downto 0);
   signal load_next : std_logic;
   signal stop_clearing : std_logic;
begin
   test: pulse_gen port map (clk, reset, count_in, load_next, stop_clearing);
   clk <= '0' after 0 ns,
          '1' after 20 ns when clk /= '1' else '0' after 20 ns;
   reset <= '1' after 0 ns,
            '0' after 80 ns;
lbl:process
begin
for i in 0 to 1023 loop
	count_in<=std_logic_vector(to_unsigned(i,10));
wait for 40 ns;
end loop;
end process;
end behaviour;

