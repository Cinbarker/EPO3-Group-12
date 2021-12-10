library IEEE;
use IEEE.std_logic_1164.ALL;  
use IEEE.numeric_std.ALL;

entity rom_con is
   port(x_address 	: in  std_logic_vector	(3 downto 0);
	y_address 	: in  std_logic_vector	(3 downto 0);
	map_sel	  	: in  std_logic_vector	(3 downto 0);		-- we need a sel to choose the bitmap
        data_out      	: out std_logic_vector	(5 downto 0);
	clk		: in  std_logic;
	cursor		: in  std_logic);	
   end rom_con;

architecture behaviour of rom_con is
   	component rom_covered is
      	port(	address  : in std_logic_vector	(7 downto 0);
           	data_out : out std_logic_vector	(5 downto 0));
   	end component;

	component rom_one is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_two is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;
	
	component rom_three is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_four is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_five is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
  	end component;

	component rom_six is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_seven is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_eight is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_empty is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_bomb is
     	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	component rom_flag is
      	port(	address : in std_logic_vector(7 downto 0);
           	data_out : out std_logic_vector(5 downto 0));
   	end component;

	signal address 	: std_logic_vector	(7 downto 0);
   	signal data0   	: std_logic_vector  	(5 downto 0);
	signal data1   	: std_logic_vector  	(5 downto 0);
	signal data2   	: std_logic_vector  	(5 downto 0);
	signal data3   	: std_logic_vector  	(5 downto 0);
	signal data4   	: std_logic_vector  	(5 downto 0);
	signal data5   	: std_logic_vector  	(5 downto 0);
	signal data6   	: std_logic_vector  	(5 downto 0);
	signal data7   	: std_logic_vector  	(5 downto 0);
	signal data8   	: std_logic_vector  	(5 downto 0);
	signal data9   	: std_logic_vector  	(5 downto 0);
	signal data10   : std_logic_vector  	(5 downto 0);
	signal data11   : std_logic_vector  	(5 downto 0);
   	signal pixel	: std_logic;
   	begin
		address <= x_address&y_address;			-- xxxxyyyy
      		rc: rom_covered port map (address, data0);
		r1: rom_one 	port map (address, data1);
		r2: rom_two 	port map (address, data2);
		r3: rom_three 	port map (address, data3);
		r4: rom_four 	port map (address, data4);
		r5: rom_five	port map (address, data5);
		r6: rom_six	port map (address, data6);
		r7: rom_seven	port map (address, data7);
		r8: rom_eight	port map (address, data8);
		re: rom_empty 	port map (address, data9);
		rb: rom_bomb 	port map (address, data10);
		rf: rom_flag 	port map (address, data11);

      		data_out <= 	data0  when map_sel = "0000" else
			    	data1  when map_sel = "0001" else
			    	data2  when map_sel = "0010" else
			    	data3  when map_sel = "0011" else
			    	data4  when map_sel = "0100" else
			    	data5  when map_sel = "0101" else
			    	data6  when map_sel = "0110" else
			    	data7  when map_sel = "0111" else
			    	data8  when map_sel = "1000" else
			    	data9  when map_sel = "1001" else
			    	data10 when map_sel = "1010" else
			    	data11 when map_sel = "1011" else
				"000000";
end behaviour; 

library IEEE;
use IEEE.std_logic_1164.ALL;

entity rom_con_tb is
end entity;

architecture behaviour of rom_con_tb is
   component rom_con
      port(x_address : in  std_logic_vector(3 downto 0);
           y_address : in  std_logic_vector(3 downto 0);
           map_sel   : in  std_logic_vector(3 downto 0);
           data_out  : out std_logic_vector(5 downto 0);
           clk       : in  std_logic;
           cursor    : in  std_logic);
   end component;

   signal x_address : std_logic_vector(3 downto 0);
   signal y_address : std_logic_vector(3 downto 0);
   signal map_sel   : std_logic_vector(3 downto 0);
   signal data_out  : std_logic_vector(5 downto 0);
   signal clk       : std_logic;
   signal cursor    : std_logic;
begin
   test: rom_con port map (x_address, y_address, map_sel, data_out, clk, cursor);
   x_address(0) <= '0' after 0 ns,
		   '1' after 20 ns;
   x_address(1) <= '0' after 0 ns,
		   '1' after 10 ns;
   x_address(2) <= '0' after 0 ns;
   x_address(3) <= '0' after 0 ns,
		   '1' after 10 ns; 
   y_address(0) <= '0' after 0 ns;
   y_address(1) <= '0' after 0 ns;
   y_address(2) <= '0' after 0 ns;
   y_address(3) <= '0' after 0 ns,
		   '1' after 20 ns;
   map_sel(0) <= '0' after 0 ns,
		 '1' after 50 ns;
   map_sel(1) <= '0' after 0 ns,
		 '1' after 80 ns;
   map_sel(2) <= '0' after 0 ns;
   map_sel(3) <= '0' after 0 ns,
		 '1' after 110 ns;
   clk <= '0' after 0 ns,
          '1' after 20 ns when clk /= '1' else '0' after 20 ns;
   cursor <= '0' after 0 ns;
end behaviour;
