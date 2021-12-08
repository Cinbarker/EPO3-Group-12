library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of seedgen_tb is
   component seedgen
      port(start : in  std_logic;
   	reset : in	 std_logic;
           clk   : in  std_logic;
           seed  : out std_logic_vector(9 downto 0));
   end component;
   signal start : std_logic;
   signal reset : std_logic;
   signal clk   : std_logic;
   signal seed  : std_logic_vector(9 downto 0);
begin
   test: seedgen port map (start, reset, clk, seed);
   start <= '0' after 0 ns,
	'1' after 40 ms,
	'0' after 60 ms;
   reset <= '1' after 0 ns,
            '0' after 200 ns;
   clk <= '0' after 0 ns,
          '1' after 20 ns when clk /= '1' else '0' after 20 ns;
end behaviour;

