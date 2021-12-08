library IEEE;
use IEEE.std_logic_1164.ALL;

entity minecounter is
   port(start      : in  std_logic;
        reset      : in  std_logic;
        clk        : in  std_logic;
        ready      : in  std_logic;
        mine       : in  std_logic;
	last_cell  : in  std_logic;
        mine_count : out std_logic_vector(5 downto 0);
        count_ready: out std_logic);
end minecounter;

