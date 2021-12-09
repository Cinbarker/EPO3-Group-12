library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of buildingmodule_tb is
   component buildingmodule
      port(start      : in  std_logic;
   	clk	   : in	 std_logic;
   	reset      : in	 std_logic;
           pos        : in  std_logic_vector(7 downto 0);
           mine       : out std_logic;
           mine_count : out std_logic_vector(5 downto 0);
   	count_ready: out std_logic;
   	ready	   : out std_logic;
   	last_cell: out std_logic);
   end component;
   signal start      : std_logic;
   signal clk	   : std_logic;
   signal reset      : std_logic;
   signal pos        : std_logic_vector(7 downto 0);
   signal mine       : std_logic;
   signal mine_count : std_logic_vector(5 downto 0);
   signal count_ready: std_logic;
   signal ready	   : std_logic;
   signal last_cell: std_logic;
begin
   test: buildingmodule port map (start, clk, reset, pos, mine, mine_count, count_ready, ready, last_cell);
   start <= '0' after 0 ns,
	'1' after 990 ns,
	'0' after 1040 ns;
   clk <= '0' after 0 ns,
          '1' after 20 ns when clk /= '1' else '0' after 20 ns;
   reset <= '1' after 0 ns,
            '0' after 80 ns;

lbl1:process
begin
wait for 1100 ns;
for i in 0 to 256 loop
	pos<=std_logic_vector(to_unsigned(i,8));
wait for 80 ns;
end loop;
end process;
end behaviour;

