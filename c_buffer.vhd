library IEEE;
use IEEE.std_logic_1164.ALL;

entity c_buffer is
   port(clk		: in std_logic;
	reset	: in std_logic;
	controller_in  : in  std_logic_vector(2 downto 0);
        pass           : in  std_logic;
        controller_out : out std_logic_vector(2 downto 0));
end c_buffer;

