-- maybe use a mux in main to determine the control over surrounding, that way surrounding can be read when it isn't being updated.


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity ram_4 is
port(	address: 	in std_logic_vector(3 downto 0);	-- 2^address'length amount of cells, used to specify the cell to read/write the data
	data_in: 	in std_logic_vector(3 downto 0);	-- size of a single cell, data input
	data_out: 	out std_logic_vector(3 downto 0);	-- data output
	write: 		in std_logic;				-- if 1: current input will be written to addressed cell
	reset:		in std_logic);
end entity ram_4;
architecture behaviour of ram_4 is
type mem_type is array(0 to (2**address'length)-1)
		of std_logic_vector(data_in'range);
signal mem : mem_type;
begin
	ram_lat : process(address, write, data_in) is
	begin
		if write = '1' then
			mem(to_integer(unsigned(address))) <= data_in;
		end if;
	end process;
	process(reset, address)
	begin
		if (reset = '1') then
			mem(0 to 15) <= (others => (others => '0'));
		else
			data_out <= mem(to_integer(unsigned(address)));
		end if;
	end process;
end architecture behaviour;

---------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity ram_1 is
port(	address: 	in std_logic_vector(3 downto 0);	-- 2^address'length amount of cells, used to specify the cell to read/write the data
	data_in: 	in std_logic;				-- size of a single cell, data input
	data_out: 	out std_logic;				-- data output
	write: 		in std_logic;				-- if 1: current input will be written to addressed cell
	reset:		in std_logic);
end entity ram_1;

architecture behaviour of ram_1 is
type mem_type is array(0 to (2**address'length)-1)
		of std_logic;
signal mem : mem_type;
begin
	ram_lat : process(address, write, data_in) is
	begin
		if write = '1' then
			mem(to_integer(unsigned(address))) <= data_in;
		end if;
	end process;
	process(reset, address)
	begin
		if (reset = '1') then
			mem(0 to 15) <= (others => '0');
		else
			data_out <= mem(to_integer(unsigned(address)));
		end if;
	end process;
end architecture behaviour;

---------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity mux_2to1 is
	port(	address_ctrl:		in std_logic_vector(3 downto 0);
		address_pixel:		in std_logic_vector(3 downto 0);
		ctrl_done:		in std_logic;				--if it is 1, control will go to address_pixelwriter
		pixel_done:		in std_logic;				--if it is 1, control will go to address_ctrl
		output:			out std_logic_vector(3 downto 0);
		reset:			in std_logic;
		clk:			in std_logic);
end entity mux_2to1;

architecture behaviour of mux_2to1 is
	type in_control is (	s_controller,	-- either one has control over the address of surrounding
				s_pixelwriter);
	signal state, new_state: in_control;
begin
	process (clk)
	begin
		if (falling_edge (clk)) then
			if (reset = '1') then
				state <= s_controller; --reset arrow
			else
				state <= new_state;
			end if;
		end if;
	end process;
	process (address_ctrl, address_pixel, ctrl_done, pixel_done)
	begin
		case state is
			when s_controller =>
				if (ctrl_done = '1') then
					new_state	<= s_pixelwriter;
				end if;
				output	<= address_ctrl;
			when s_pixelwriter =>
				if (pixel_done = '1') then
					new_state	<= s_controller;
				output	<= address_pixel;
				end if;
		end case;
	end process;
end architecture behaviour;

---------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity controller is
port(	data_out_mine1:			in std_logic;
	data_out_mine2:			in std_logic;
	data_out_mine3:			in std_logic;
	address_mine:			out std_logic_vector(3 downto 0);
	write:				out std_logic;
	data_in_surr:			out std_logic_vector(3 downto 0);	-- what will be written in the cell address_surr points to if write_surr=1
	address_surr:			out std_logic_vector(3 downto 0);	-- only does anything when controller is calculating, not when pixel writing is reading
	write_surr:			out std_logic;
	write_surrcalc:			out std_logic;				-- gives a pulse of 1 when the values of the next row of surrounding have been calculated
	write_surrread:			in std_logic;				-- gives a pulse when pixel writing has read the row and asks for the next row
	mine_done:			in std_logic;				-- pulses 1 when next mine is being outputted (after requesting next mine)
	mine_addr_ask:			out std_logic_vector(7 downto 0);	-- mine location asked for, assuming upper left corner is 0, from left to right, up to down
	clk:				in std_logic;
	reset:				in std_logic);
end entity controller;

architecture behaviour of controller is
	signal address_surr_buffer, address_mine_buffer, data_in_surr_buffer, bit_3, row:	std_logic_vector(3 downto 0);
	type	control_state is (	reset_state,
					new_cell,
					read_left,
					move_left,
					read_middle,
					read_right);
	signal state, new_state:	control_state;
begin
	process (clk)
	begin
		if (rising_edge (clk)) then
			if (reset = '1') then
				state <= reset_state; --reset arrow
			else 
				state <=new_state;
			end if;
		end if;
	end process;

	process (state, new_state, mine_done, write_surrread)
	begin
		case state is
			when reset_state =>
				row				<= (others => '0');
				address_mine			<= (others => '0');
				address_mine_buffer		<= (others => '0');
				address_surr			<= (others => '0');
				address_surr_buffer		<= (others => '0');
				data_in_surr			<= (others => '0');
				data_in_surr_buffer		<= (others => '0');
				bit_3				<= (others => '0');
				new_state			<= read_left;
			when new_cell =>					-- when the row is not done
				write_surr	<= '0';
				if (address_surr_buffer < 15) then
					address_surr			<= address_surr_buffer + '1';
					address_surr_buffer		<= address_surr_buffer + '1';	-- you can't read output's in vhdl, so it is defined twice
					new_state	<= read_left;
				else
					if (write_surrread = '1') then
						new_state	<= read_left;	
						address_surr		<= (others => '0');
						address_surr_buffer	<= (others => '0');
					end if;
				end if;
			when read_left =>
				if (address_surr_buffer > 0) then	-- if it is 0, then there are no cells and thus no mines to the left
					data_in_surr_buffer	<= bit_3 + data_out_mine1 + data_out_mine2 + data_out_mine3;	-- bit_3 is 000, used to prevent error
				else
					data_in_surr_buffer	<= (others => '0');

				end if;
				mine_addr_ask(7 downto 4)	<= row + 2;	-- assuming upper left corner is 0, from left to right, up to down
				mine_addr_ask(3 downto 0)	<= address_surr_buffer - 1;
				if (mine_done = '1') then
					write		<= '1';
					new_state	<= move_left;
				end if;
			when move_left =>
				write		<= '0';
				address_mine		<= address_mine_buffer + 1;
				address_mine_buffer	<= address_mine_buffer + 1;	-- you can't read output's in vhdl, so it is defined twice
				new_state	<= read_middle;
			when read_middle =>
				data_in_surr_buffer	<= data_in_surr_buffer + data_out_mine1 + data_out_mine3;
				address_mine		<= address_mine_buffer + '1';
				address_mine_buffer	<= address_mine_buffer + '1';	-- you can't read output's in vhdl, so it is defined twice
				new_state	<= read_right;
			when read_right =>
				write_surr	<= '1';		-- the value of data_in_surr calculated in this clock cycle needs to be written
				new_state	<= new_cell;
				if (address_surr_buffer < 15) then	-- if it is 15, then there are no cells and thus no mines to the right
					data_in_surr		<= data_in_surr_buffer + data_out_mine1 + data_out_mine2 + data_out_mine3;
					address_mine		<= address_mine_buffer - 1;
					address_mine_buffer	<= address_mine_buffer - 1;

				else
					data_in_surr	<= data_in_surr_buffer;
					row		<= row + 1;	-- this is the end of the now, it will now go to the next row
					address_mine	<= (others => '0');
				end if;
		end case;
	end process;
end architecture behaviour;

-----------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity building_main is
	port(	clk:					in std_logic;
		reset:					in std_logic;
		surr_read:				in std_logic;				-- when the pixel writer has written this row
		adr_surr_pixel:				in std_logic_vector(3 downto 0);	-- what is being read by the pixel writer
		surr_calc:				out std_logic;				-- when surrounding has been updated to the next row
		surr_out:				out std_logic_vector(3 downto 0);	-- the output that is read by pixel writer
		mine_addr_ask:				out std_logic_vector(7 downto 0);	-- the cell who's mine value 1/0 is currently being asked
		mine_done:				in std_logic;				-- pulses 1 when next mine is being outputted (after requesting next mine)
		mine_value:				in std_logic);				-- the value of the current mine
end entity building_main;

architecture structural of building_main is

	component ram_4 is
		port(	address: 	in std_logic_vector(3 downto 0);	-- 2^address'length amount of cells, used to specify the cell to read/write the data
			data_in: 	in std_logic_vector(3 downto 0);	-- size of a single cell, data input
			data_out: 	out std_logic_vector(3 downto 0);	-- data output
			write: 		in std_logic;				-- if 1: current input will be written to addressed cell
			reset:		in std_logic);
	end component ram_4;

	component ram_1 is
		port(	address: 	in std_logic_vector(3 downto 0);	-- 2^address'length amount of cells, used to specify the cell to read/write the data
			data_in: 	in std_logic;				-- size of a single cell, data input
			data_out: 	out std_logic;				-- data output
			write: 		in std_logic;				-- if 1: current input will be written to addressed cell
			reset:		in std_logic);
	end component ram_1;

	component mux_2to1 is
		port(	address_ctrl:		in std_logic_vector(3 downto 0);
			address_pixel:		in std_logic_vector(3 downto 0);
			ctrl_done:		in std_logic;				--if it is 1, control will go to address_pixel
			pixel_done:		in std_logic;				--if it is 1, control will go to address_ctrl
			output:			out std_logic_vector(3 downto 0);
			reset:			in std_logic;
			clk:			in std_logic);
	end component mux_2to1;

	component controller is
		port(	data_out_mine1:			in std_logic;
			data_out_mine2:			in std_logic;
			data_out_mine3:			in std_logic;
			address_mine:			out std_logic_vector(3 downto 0);
			write:				out std_logic;
			data_in_surr:			out std_logic_vector(3 downto 0);	-- what will be written in the cell address_surr points to if write_surr=1
			address_surr:			out std_logic_vector(3 downto 0);	-- only does anything when controller is calculating, not when pixel writing is reading
			write_surr:			out std_logic;
			write_surrcalc:			out std_logic;				-- gives a pulse of 1 when the values of the next row of surrounding have been calculated
			write_surrread:			in std_logic;				-- gives a pulse when pixel writing has read the row and asks for the next row
			mine_done:			in std_logic;				-- pulses 1 when next mine is being outputted (after requesting next mine)
			mine_addr_ask:			out std_logic_vector(7 downto 0);	-- mine location asked for, assuming upper left corner is 0, from left to right, up to down
			clk:				in std_logic;
			reset:				in std_logic);
	end component controller;
	signal write, write_surr, mine_1_out, mine_2_out, mine_3_out, surr_calc_buffer: std_logic;
	signal mine_address, surr_address, surr_in, address_surr_controller: std_logic_vector(3 downto 0);
	
begin
	surr_calc	<= surr_calc_buffer;

	mux_1:	mux_2to1 port map	(address_ctrl		=> address_surr_controller,
					address_pixel		=> adr_surr_pixel,
					ctrl_done		=> surr_calc_buffer,
					pixel_done		=> surr_read,
					output			=> surr_address,
					reset			=> reset,
					clk			=> clk);

	mine_1: ram_1 port map		(address	=> mine_address,
					data_in 	=> mine_value,		-- mine_1 has the most recent determined mines (the lowest of the 3 rows)
					data_out	=> mine_1_out,
					write		=> write,		-- Due to vhdl parallel logic (if you change the value of multiple variables that are based on
	-- each other at the same time, each update depends on the old value of the one they are based on, not the new one). So mine_1 becomes the input mine value.									
					reset		=> reset);

	mine_2: ram_1 port map		(address	=> mine_address,
					data_in 	=> mine_1_out,		-- mine_2 has the middle row of the 3 rows
					data_out	=> mine_2_out,
					write		=> write,		-- see mine_1, mine_2 becomes the old value of mine_1
					reset		=> reset);

	mine_3: ram_1 port map		(address	=> mine_address,
					data_in 	=> mine_2_out,		-- mine_3 has the oldest row of the 3 rows
					data_out	=> mine_3_out,
					write		=> write,		-- see mine_1, mine_3 becomes the old value of mine_2
					reset		=> reset);

	surrounding: ram_4 port map	(address	=> surr_address,
					data_in 	=> surr_in,
					data_out	=> surr_out,
					write		=> write_surr,
					reset		=> reset);

	p2: controller port map		(data_out_mine1 => mine_1_out,
					data_out_mine2	=> mine_2_out,
					data_out_mine3	=> mine_3_out,
					address_mine	=> mine_address,
					write		=> write,
					data_in_surr	=> surr_in,
					address_surr	=> address_surr_controller,
					write_surr	=> write_surr,
					write_surrcalc	=> surr_calc_buffer,		
					write_surrread	=> surr_read,
					mine_done	=> mine_done,
					mine_addr_ask	=> mine_addr_ask,
					clk		=>	clk,
					reset		=>	reset);
end architecture structural;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity building_main_tb is
end entity building_main_tb;

architecture structural_tb of building_main_tb is
	component main is
		port(	clk:					in std_logic;
			reset:					in std_logic;
			surr_read:				in std_logic;				-- when the pixel writer has read this row
			adr_surr_pixel:				in std_logic_vector(3 downto 0);	-- what is being read by the pixel writer
			surr_calc:				out std_logic;				-- when surrounding has been updated to the next row
			surr_out:				out std_logic_vector(3 downto 0);	-- the output that is read by pixel writer
			mine_addr_ask:				out std_logic_vector(7 downto 0);	-- the cell who's mine value 1/0 is currently being asked
			mine_done:				in std_logic;				-- pulses 1 when next mine is being outputted (after requesting next mine)
			mine_value:				in std_logic);				-- the value of the current mine
	end component main;
	signal clk, reset, surr_read, surr_calc, mine_done, mine_value:	std_logic;
	signal adr_surr_pixel, surr_out:				std_logic_vector(3 downto 0);
	signal mine_addr_ask:						std_logic_vector(7 downto 0);
begin
	main_0: main port map	(clk				=> clk,
				reset				=> reset,
				surr_read			=> surr_read,
				adr_surr_pixel			=> adr_surr_pixel,
				surr_calc			=> surr_calc,
				surr_out			=> surr_out,
				mine_addr_ask			=> mine_addr_ask,
				mine_done			=> mine_done,
				mine_value			=> mine_value);

	clk				<=	'0' after 0 ns, '1' after 20 ns when clk /= '1' else '0' after 20 ns;

	reset				<=	'1' after 0 ns,
						'0' after 30 ns;

	surr_read			<=	'1' after 0 ns;

	adr_surr_pixel			<= 	"0000" after 0 ns;

	mine_done			<= 	'0' after 0 ns;

	mine_value			<= 	'0' after 0 ns;

end structural_tb;

