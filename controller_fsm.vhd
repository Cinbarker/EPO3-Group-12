library IEEE;
use IEEE.std_logic_1164.ALL;

entity controller_fsm is
   port(clk      : in  std_logic;
        reset    : in  std_logic;
        pin1     : in  std_logic;
        pin2     : in  std_logic;
        pin3     : in  std_logic;
        pin4     : in  std_logic;
        pin6     : in  std_logic;
        pin9     : in  std_logic;

	count_in	: in std_logic_vector(9 downto 0);

        line_out : out std_logic_vector(2 downto 0));
end controller_fsm;
