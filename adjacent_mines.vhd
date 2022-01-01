library IEEE;
use IEEE.std_logic_1164.ALL;

entity adjacent_mines is
   port(clk			: in  std_logic;
	reset		: in  std_logic;
	start		: in std_logic;
	mine_in		: in std_logic;
	mine_ready		: in std_logic;
	pos_in		: in std_logic_vector(7 downto 0);
	next_row		: in std_logic;
	
	pos_out		: out std_logic_vector(7 downto 0);
	nr_out		: out std_logic_vector(3 downto 0);
	nr_out_ready		: out std_logic;
	row_ready		: out std_logic
);
end adjacent_mines;

