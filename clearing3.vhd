library IEEE;
use IEEE.std_logic_1164.ALL;

entity clearing3 is
port (	clk 	: in std_logic;
		reset 	: in std_logic;

		mine_ready : in std_logic;
		calc_ready : in std_logic;

		controller_in : in std_logic_vector(2 downto 0);
	
		cover_in	: in std_logic;  					
		flag_in		: in std_logic;				
		mine_in		: in std_logic;				
		number_in	: in std_logic_vector(3 downto 0);				
		start: in std_logic; 

		cursor_in	: in std_logic_vector(7 downto 0);
		
		write: out std_logic;
		cofl: out std_logic;			
		
		cursor_out	: out std_logic_vector(7 downto 0);		

		cover_out	: out std_logic;					
		flag_out	: out std_logic;					
		number_out: out std_logic_vector(3 downto 0);		

		pass	: out std_logic;

		game_over	: out std_logic	
	);
end clearing3;

