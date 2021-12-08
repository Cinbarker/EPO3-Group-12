library IEEE;
use IEEE.std_logic_1164.ALL;

entity mineplacerv2 is
port(seed : in  std_logic_vector(9 downto 0);
        pos  : in  std_logic_vector(7 downto 0);
	clk  : in std_logic;
	reset: in	 std_logic;
	start: in std_logic;
        mine : out std_logic;
	ready: out std_logic;
	last_cell: out std_logic);
end mineplacerv2;
