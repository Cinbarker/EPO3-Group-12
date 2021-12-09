library IEEE;
use IEEE.std_logic_1164.ALL;

entity buildingmodule is
   port(start      : in  std_logic;
	clk	   : in	 std_logic;
	reset      : in	 std_logic;
        pos        : in  std_logic_vector(7 downto 0);
        mine       : out std_logic;
        mine_count : out std_logic_vector(5 downto 0);
	count_ready: out std_logic;
	ready	   : out std_logic;
	last_cell: out std_logic);
end buildingmodule;

