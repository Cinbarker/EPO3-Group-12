library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity dmux is
port (input  : in  std_logic;
      sel    : in std_logic_vector (7 downto 0);		-- sel is the selector signal for the address
      output : out std_logic_vector (255 downto 0)); 		
end dmux;

--standard D-mux behaviour used to implement a '1' or a '0' into a certain adress.
architecture behv of dmux is
begin
process (sel,input)
begin
output <= (others => '0');
output(to_integer (unsigned (sel))) <= input;
end process;
end behv;

library IEEE;
use IEEE.std_logic_1164.ALL;

entity SR_latch is
port (  S   	: in std_logic;
	R   	: in std_logic ;
	Q   	: inout std_logic);
end SR_latch;

--standard SR-latch behaviour
architecture behav of SR_latch is
signal nQ : std_logic ;           --:= '1';		--nQ is 'not Q'

--signal nQ : std_logic ;           --:= '1';		--nQ is 'not Q'

begin 
Q  <= R nor nQ;
nQ <= S nor Q;
end behav;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity mux is
port   (input 	: in std_logic_vector (255 downto 0);
	sel	: in std_logic_vector (7 downto 0);
	output	: out std_logic);
end entity;

architecture behave of mux is
begin
output <= input(to_integer (unsigned (sel)));
end architecture;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

-- overall system which implements latches and a dmux to generate the memory element
entity covered_mem is
port ( 	advec		: in std_logic_vector (7 downto 0);
	data_in 	: in std_logic;
	data_out   	: out std_logic; 			--should not be inout
	g_reset		: in std_logic;				-- this is a general reset to set all cells to their covered state
	write		: in std_logic);			
end entity;

architecture struct of covered_mem is

component mux is
port   (input 	: in std_logic_vector (255 downto 0);
	sel	: in std_logic_vector (7 downto 0);
	output	: out std_logic);
end component;

component dmux is
port (input  : in  std_logic;
      sel    : in std_logic_vector (7 downto 0);
      output : out std_logic_vector (255 downto 0)); -- plz kill me
end component;

component SR_latch is
port (S, R : in std_logic;
	Q   : inout std_logic);
end component;
signal sel 		: std_logic_vector (7 downto 0);
signal latch_in 	: std_logic_vector (255 downto 0);--:=std_logic_vector( to_unsigned( 0, 256));
signal latch_out 	: std_logic_vector (255 downto 0);--:=std_logic_vector( to_unsigned( 0, 256));
signal data_write 	: std_logic;
begin


data_write <= 	data_in when write = '1' else  '0';
D: dmux port map (input  => data_write,				-- deciedes where the new value will get stored
		  sel	 => advec,
		  output => latch_in);

M: mux port map (input => latch_out,
		 sel => advec,
		 output => data_out);

Genz: for I in 0 to 255 generate			-- generates the latches in which the value of the covered state is stored
begin
L:  SR_latch port map ( R  => g_reset,				-- I is the address variable
			S  => latch_in(I),
			Q  => latch_out(I));



end generate;
end architecture;