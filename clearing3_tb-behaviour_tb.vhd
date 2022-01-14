library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour_tb of clearing3_tb is
   component clearing3
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
		stop : in std_logic;
   		
   		write: out std_logic;
   		cofl: out std_logic;			
   		
   		cursor_out	: out std_logic_vector(7 downto 0);		
   
   		cover_out	: out std_logic;					
   		flag_out	: out std_logic;					
   		number_out: out std_logic_vector(3 downto 0);		
   
   		pass	: out std_logic;
   
   		game_over	: out std_logic	
   	);
   end component;
   signal clk 	: std_logic;
   signal reset 	: std_logic;
   signal mine_ready : std_logic;
   signal calc_ready : std_logic;
   signal controller_in : std_logic_vector(2 downto 0);
   signal cover_in	: std_logic;
   signal flag_in		: std_logic;
   signal mine_in		: std_logic;
   signal number_in	: std_logic_vector(3 downto 0);
   signal start: std_logic;
   signal cursor_in	: std_logic_vector(7 downto 0);
signal stop : std_logic;
   signal write: std_logic;
   signal cofl: std_logic;
   signal cursor_out	: std_logic_vector(7 downto 0);
   signal cover_out	: std_logic;
   signal flag_out	: std_logic;
   signal number_out: std_logic_vector(3 downto 0);
   signal pass	: std_logic;
   signal game_over	: std_logic;
begin
   test: clearing3 port map (clk, reset, mine_ready, calc_ready, controller_in, cover_in, flag_in, mine_in, number_in, start, cursor_in,stop, write, cofl, cursor_out, cover_out, flag_out, number_out, pass, game_over);
   clk <= '1' after 0 ns,
          '0' after 20 ns when clk /= '0' else '1' after 20 ns;
   reset <= '1' after 0 ns,
            '0' after 80 ns;

   start <= '1' after 0 ns,
	'0' after 200 ns;
   mine_ready <= '1' after 0 ns;
   calc_ready <= '1' after 40 ns,
	'0' after 80 ns;
	stop<='0' after 0 ns,
	'1' after 1000 ns;

   controller_in <= "000" after 0 ns,
	"100" after 400 ns;

   cover_in <= '1' after 0 ns,
	'0' after 480 ns;
   flag_in <= '0' after 0 ns;
   mine_in <= '0' after 0 ns;

   number_in <= "0000" after 0 ns;

   cursor_in <= "00110010" after 0 ns,
	"00110011" after 1320 ns;
end behaviour_tb;


