library IEEE;
use IEEE.std_logic_1164.ALL;

entity pulse_gen is
   port(clk	: in std_logic;
	reset : in std_logic;
	count_in  : in  std_logic_vector(9 downto 0);
        load_next : out std_logic;
	stop_clearing : out std_logic);
end pulse_gen;

