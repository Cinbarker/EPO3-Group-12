LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY system_tb IS
END ENTITY system_tb;

ARCHITECTURE structural OF system_tb IS
   COMPONENT system IS
     	port ( 	advec		: in std_logic_vector (7 downto 0);
		data_in 	: in std_logic;
		data_out   	: out std_logic; 			
		g_reset		: in std_logic);			
	end component;

   SIGNAL 	advec		 : std_logic_vector (7 downto 0);
   signal	data_in, g_reset, data_out : STD_LOGIC;


BEGIN
   advec  <=  "00000000" AFTER 0 NS,
	      "00100010" after 20 ns,
	      "00100100" after 35 ns,
	      "00100010" after 40 ns,
	      "00000000" after 50 ns;
   data_in  <= 	'0' AFTER 0 NS,
            	'1' AFTER 25 NS,
		'0' after 30 ns;
   g_reset <= 	'1' AFTER 0 NS,
             	'0' AFTER 10 NS;
		--'1' after 30 ns;
TBL: system port map(advec 	=> advec,
		     data_in 	=> data_in,
		     data_out 	=> data_out,
		     g_reset 	=> g_reset);
END structural;  