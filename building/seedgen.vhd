library IEEE;
use IEEE.std_logic_1164.ALL;

entity seedgen is
   port(start : in  std_logic;
	reset : in	 std_logic;
        clk   : in  std_logic;
        seed  : out std_logic_vector(9 downto 0));
end seedgen;

