library IEEE;
use IEEE.std_logic_1164.ALL;

entity mem_control is
   port(clk          : in  std_logic;
        reset        : in  std_logic;
        write_in_clr : in  std_logic;
        write_in_bld : in  std_logic;
        write_in_ca  : in  std_logic;
        cofl_in_clr  : in  std_logic;
        cofl_in_bld  : in  std_logic;
        cofl_in_ca   : in  std_logic;
        adr_in_clr   : in  std_logic_vector(7 downto 0);
        adr_in_bld   : in  std_logic_vector(7 downto 0);
        adr_in_ca    : in  std_logic_vector(7 downto 0);
        write_out    : out std_logic;
        cofl_out     : out std_logic;
        adr_out      : out std_logic_vector(7 downto 0);
	clr_stop	: out std_logic;
	calc_Ready	: in std_logic;
        hor_in : in  std_logic_vector(9 downto 0);
        ver_in : in  std_logic_vector(9 downto 0));
end mem_control;

