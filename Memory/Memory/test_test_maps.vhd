library IEEE;
use IEEE.std_logic_1164.ALL;  
use IEEE.numeric_std.ALL;

entity rom is

   port(x_address 	: in  std_logic_vector(3 downto 0);
	y_address 	: in  std_logic_vector(3 downto 0);
	map_sel	  	: in  std_logic_vector(3 downto 0);		-- we need a sel to choose the bitmap
        data_out      	: out std_logic_vector(5 downto 0);
	clk		: in  std_logic;
	cursor		: in  std_logic);	

end rom;
-- Colours: rrggbb
-- bright red, 		110000
-- bright green, 	001100
-- purple: 		010001
-- turquoise: 		001010
-- dark red: 		100000
-- dark blue		000001
-- middle blue		000010
-- dark grey		010101
-- light grey		101010
-- white		111111
-- black		000000
 
architecture behaviour of rom is
signal address	 : std_logic_vector (7 downto 0);
signal data	 : std_logic;
signal data_flag : std_logic_vector (1 downto 0);
signal covered_colour_1 : std_logic_vector (5 downto 0) := "111111"	;
begin
	address <= x_address&y_address;			-- xxxxyyyy
process(x_address, y_address, cursor,map_sel)
begin
	if to_integer(unsigned(x_address)) = 0 or to_integer(unsigned(y_address)) = 0 then
		data_out <= "010101";			-- dark grey, for all the top borders
	elsif (cursor = '1' and (to_integer(unsigned(x_address)) = 1 or to_integer(unsigned(x_address)) = 11 or to_integer(unsigned(y_address)) = 1 or to_integer(unsigned(y_address)) = 11)) then -- when the cell has the cursor in it, we specify that within the second ring from the outside is red.
		data_out <= "110000";
	else
		case map_sel is
			when "0000" =>					-- Covered
				with address select data <=
				'0' when "00010001",
				'0' when "00100001",
				'0' when "00110001",
				'0' when "01000001",
				'0' when "01010001",
				'0' when "01100001",
				'0' when "01110001",
				'0' when "10000001",
				'0' when "10010001",
				'0' when "10100001",
				'0' when "10110001",
				'0' when "00010010",
				'0' when "00010011",
				'0' when "00010100",
				'0' when "00010101",
				'0' when "00010110",
				'0' when "00010111",
				'0' when "00011000",
				'0' when "00011001",
				'0' when "00011010",
				'0' when "00011011",
				'1' when others;
				data_out <= "111111" when data = '0' else "101010";

			when "0001" =>					-- bitmap for one
				with address select data <=
				'0' when "01010011",
				'0' when "01100011",
				'0' when "01100100",
				'0' when "01100101",
				'0' when "01100110",
				'0' when "01100111",
				'0' when "01101000",
				'0' when "01001001",
				'0' when "01011001",
				'0' when "01101001",
				'0' when "01111001",
				'0' when "10001001",
				'1' when others;
				data_out <= "000010" when data = '0' else "101010";
			when others =>
				data_out <= "000000";
end case; end if; end process; end architecture;
