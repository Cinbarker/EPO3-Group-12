library IEEE;
use IEEE.std_logic_1164.ALL;

entity flag_counter is
   port(clk		    : in std_logic;
	reset	    : in std_logic;
	flag        : in  std_logic;
        write       : in  std_logic;
	cofl	    : in std_logic;
        mine_count  : in  std_logic_vector(5 downto 0);
        count_ready : in  std_logic;
        count_out   : out std_logic_vector(5 downto 0));
end flag_counter;

