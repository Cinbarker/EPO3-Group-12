library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity memory is
port (	write		: in	std_logic;
	cofl		: in	std_logic;				-- for cofl: coverd = 0, flaged = 1
	address		: in	std_logic_vector (7 downto 0);
	input		: in	std_logic;
	g_reset		: in	std_logic;
	output		: out	std_logic;
	clk		: in	std_logic);
end entity;

architecture behavioural of memory is

signal output_c, output_f, write_c, write_f	: std_logic;

component covered_mem is
port ( 	address		: in std_logic_vector (7 downto 0);
	data_in 	: in std_logic;
	data_out   	: out std_logic; 			
	g_reset		: in std_logic;
	write		: in std_logic);			
end component;

component flagged_mem is
port(	address : in std_logic_vector(7 downto 0);
	data_in : in std_logic;
	data_out : out std_logic;
	write : in std_logic);
end component;

begin
mem_c: covered_mem port map (	address  => address,
		  		data_in	 => input,
		  		data_out => output_c,
				g_reset	 => g_reset,
				write	 => write_c);

mem_f: flagged_mem port map (	address  => address,				-- deciedes where the new value will get stored
		  		data_in	 => input,
		  		data_out => output_f,
				write	 => write_f);

-- TODO: maybe add a clk process for a buffer
output <= output_c when cofl = '0' else output_f when cofl = '1';		-- for cofl: coverd = 0, flaged = 1
write_c <= write when cofl ='0' else '0';
write_f <= '0' when cofl = '0' else write when cofl = '1';




end architecture;
