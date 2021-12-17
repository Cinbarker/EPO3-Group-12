library IEEE;
use IEEE.std_logic_1164.ALL;

entity clearing_2 is
	port (	clk 	: in std_logic;
		reset 	: in std_logic;

		mine_ready : in std_logic;
		calc_ready : in std_logic;

		controller_in : in std_logic_vector(2 downto 0);
	
		cover_in	: in std_logic;  					--from memory
		flag_in		: in std_logic;				--from memory
		mine_in		: in std_logic;				--from seed gen
		number_in	: in std_logic_vector(2 downto 0);				--from building alg

		cursor_in	: in std_logic_vector(7 downto 0);
		
		cursor_out	: out std_logic_vector(7 downto 0);		-- to memory

		cover_out	: out std_logic;					--to memory
		flag_out	: out std_logic;					--to memory

		game_over	: out std_logic					--to display
	);
end entity;
