library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of mineplacerv2_tb is
   component mineplacerv2
   port(seed : in  std_logic_vector(9 downto 0);
           pos  : in  std_logic_vector(7 downto 0);
   	clk  : in std_logic;
   	reset: in	 std_logic;
   	start: in std_logic;
           mine : out std_logic;
   	ready: out std_logic;
   	last_cell: out std_logic);
   end component;
   signal seed : std_logic_vector(9 downto 0);
   signal pos  : std_logic_vector(7 downto 0);
   signal clk  : std_logic;
   signal reset: std_logic;
   signal start: std_logic;
   signal mine : std_logic;
   signal ready: std_logic;
   signal last_cell: std_logic;
begin
   test: mineplacerv2 port map (seed, pos, clk, reset, start, mine, ready, last_cell);
seed<="1000000001" after 0 ns;
 reset<='1' after 0 ns,
	'0' after 40 ns;
start<='1' after 0 ns,
'0' after 100 ns;
--pos<="00000010" after 80 ns;
--"00000010" after 80 ns,
--"00000011" after 120 ns,
--"00000100" after 160 ns,
--"00000101" after 200 ns,
--"00000110" after 240 ns,
--"00000111" after 280 ns,
--"00001000" after 320 ns,
--"00001001" after 360 ns,
--"00001000" after 400 ns,
--"00001000" after 440 ns,
--"00001000" after 480 ns,
--"00001000" after 520 ns;

lbl1:process
begin
wait for 180 ns;
for i in 0 to 256 loop
	pos<=std_logic_vector(to_unsigned(i,8));
wait for 120 ns;
end loop;
end process;
clk <= '0' after 0 ns,
          '1' after 20 ns when clk /= '1' else '0' after 20 ns;



end behaviour;

