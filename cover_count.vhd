library IEEE;
use IEEE.std_logic_1164.ALL;

entity cover_count is
   port(clk        : in  std_logic;
        reset      : in  std_logic;
        mem_in     : in  std_logic;
        cofl       : in  std_logic;
        write      : in  std_logic;
        mine_count : in  std_logic_vector(5 downto 0);
	count_ready: in std_logic;
	mine	: in std_logic;
	mine_ready : in std_logic;
        win_over : out std_logic);
end cover_count;

