library IEEE;
use IEEE.std_logic_1164.ALL;

architecture structural of buildingmodule is
	signal seed :std_logic_vector(9 downto 0);

component seedgen
port(start : in  std_logic;
	reset : in	 std_logic;
        clk   : in  std_logic;
        seed  : out std_logic_vector(9 downto 0));
end component;

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

component minecounter
   port(start      : in  std_logic;
        reset      : in  std_logic;
        clk        : in  std_logic;
        ready      : in  std_logic;
        mine       : in  std_logic;
	last_cell  : in  std_logic;
        mine_count : out std_logic_vector(5 downto 0);
        count_ready: out std_logic);
end component;

begin
sdgn: seedgen port map(start,reset,clk,seed);
plc: mineplacerv2 port map(seed,pos,clk,reset,start,mine,ready,last_cell);
cnt:minecounter port map(start,reset,clk,ready,mine,last_cell,mine_count,count_ready);
end structural;

