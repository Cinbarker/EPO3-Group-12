library IEEE;
use IEEE.std_logic_1164.ALL;

entity startconverter is
   port(clk			: in std_logic;
	reset		: in std_logic;
	controller_in : in  std_logic_vector(2 downto 0);
        start         : out std_logic;
	reset_out		: out std_logic);
end startconverter;

