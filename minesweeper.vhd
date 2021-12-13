-- TODO: see if data can be spared by fusing the 3 1 bit RAM components
-- TODO: see if data can be spared by optimising the mine generation part
-- TODO: create a way for other modules to ask if there are mines in certain cells






--------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity minecounter is
   port(start      : in  std_logic;				-- 1 if the start button is being pressed, 0 if it isn't
        reset      : in  std_logic;				-- on as it starts (not every screen)
        clk        : in  std_logic;
        ready      : in  std_logic;				-- pulses with value 1 when a new mine has been calculated (to distinguish mines with the same value in series)
        mine       : in  std_logic;				-- 1 when there is a mine in the cell, 0 when there isn't
	last_cell  : in  std_logic;				-- 1 when the last cell of the field has been reached
        mine_count : out std_logic_vector(5 downto 0);		-- the total amount of mines
        count_ready: out std_logic);				-- is 1 when mine_count is done (all mines have been determined once)
end minecounter;

architecture behaviour of minecounter is
type counter_state is (off,add_count,update_count);
signal new_count, mine_count_buffer:std_logic_vector(5 downto 0);
signal count_ready_buffer: std_logic;
signal state, new_state:counter_state;

begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then
			if (reset='1') then
				state<=off;
			else
				state<=new_state;
			end if;
		end if;
	end process;

	cnt:process(state,ready,start)
	begin
		case state is
			when off=>
				if (start='1') then			-- if the button is pressed, goes back to 0 when the button is released
					new_state	<= add_count;
				else
					new_state	<= off;
				end if;
				mine_count		<= std_logic_vector(to_unsigned(0,6));
				mine_count_buffer	<= std_logic_vector(to_unsigned(0,6));
				new_count		<= std_logic_vector(to_unsigned(0,6));
				count_ready		<= '0';
				count_ready_buffer	<= '0';
			when update_count=>
				if (ready='0') then
					mine_count	<= mine_count_buffer;
					if (last_cell='1') then
						count_ready_buffer	<= '1';
						count_ready		<= '1';
					else
						new_state	<= add_count;
					end if;
				end if;
			when add_count=>
				if (ready='1') then
					if (mine='1' AND count_ready_buffer = '0') then
						mine_count_buffer	<= mine_count_buffer + 1;
						new_state	<= update_count;
					else
						new_state	<= update_count;	-- this way it also stops counting if the last cell is not a mine
					end if;
				end if;
		end case;
	end process;
end behaviour;

---------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity mineplacerv2 is
port(	seed: 		in std_logic_vector(9 downto 0);	-- the seed used to determine the mine values
        pos: 		in std_logic_vector(7 downto 0);	-- the position of the requested mine
	clk: 		in std_logic;
	reset: 		in std_logic;
	start: 		in std_logic;				-- 1 if the start button is being pressed, 0 if it isn't
        mine: 		out std_logic;				-- 1 if there is a mine at the requested position, 0 if there isn't
	ready: 		out std_logic;				-- pulses with value 1 when a new mine has been calculated (to distinguish mines with the same value in series)
	last_cell: 	out std_logic);				-- if the requested position is that of the last cell
end mineplacerv2;

architecture behaviour of mineplacerv2 is
	type mine_state is (off,on0,on1,update);
	type starter_state is (off,waiting);
	signal s_state,s_new_state:starter_state;
	signal state, new_state:mine_state;
	signal old_pos:std_logic_vector(7 downto 0);
	signal start_plc, no_zero:std_logic;

begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then					
			if reset='1' then
				state<=off;
				s_state<=off;
				
			else
				state<=new_state;
				s_state<=s_new_state;
			end if;
		end if;
	end process;
	
	placer_starter:process(start,s_state)				--waits for start input, initiates plc process
	begin
		case s_state is
			when off=>
				start_plc<='0';
				if start='1' then
					s_new_state<=waiting;
				else
					s_new_state<=off;
				end if;
			when waiting=>
				if start<='0' then
					s_new_state<=off;
					start_plc<='1';
				else
					s_new_state<=waiting;
				end if;
		end case;
	end process;

	postracker:process(pos)
	begin
		if pos=std_logic_vector(to_unsigned(255,8)) then
			last_cell<='1';
		else
			last_cell<='0';
		end if;
	end process;
	
	mineplacer:process(pos,state,seed,clk,start_plc)
	begin
		case state is
			when off=>
				mine<='0';
				ready<='0';
				old_pos<="00000000";
				if start_plc='1' then
					new_state<=on0;
				else
					new_state<=off;
				end if;
			when on0=>
				if to_integer(unsigned(pos))<256 then
					new_state<=on1;			--wait for first input
					if (pos=0) then
						no_zero	<= '1';
					else
						no_zero	<= '0';
					end if;
				else
					new_state<=on0;
				end if;
			when on1=>
				old_pos<=pos;
				if (((to_integer((unsigned(seed) * 100) / (unsigned(pos+no_zero)))) mod 6) = 0) then	--place mine, the +1 was added to prevent division by 0
					mine<='1';
					ready<='1';
				else
					mine<='0';
					ready<='1';
				end if;
				
				new_state<=update;
			when update=>
				ready<='0';
				if old_pos/=pos then
					new_state<=on1;
					if (pos=0) then
						no_zero	<= '1';
					else
						no_zero	<= '0';
					end if;
				else
					new_state<=update;
				end if;
		end case;
	end process;
end behaviour;

---------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity seedgen is
   port(start : in std_logic;
	reset : in std_logic;
        clk   : in std_logic;
        seed  : out std_logic_vector(9 downto 0));
end seedgen;

architecture behaviour of seedgen is
	type seed_state is (off,counting1);
	signal state, new_state:seed_state;
	signal count:std_logic_vector(9 downto 0);
	signal working: std_logic;
begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then						--global reset
			if reset='1' then
				state<=off;
			else
				state<=new_state;
			end if;
		end if;
	end process;

	sdgn:process(state,start, reset)
	begin
		case state is
			when off=>
				if (working='1') then
					new_state<=counting1;
				else
					count<=(others => '0');
					if (reset='1') then
						seed	<=(others => '0');
					end if;
					if start='1' then
						new_state	<=counting1;
					else
						new_state	<=off;
					end if;
				end if;
			when counting1=>
				if (start='1') then
					count<=count + 1;
					new_state<=off;
					working<='1';
				elsif (start='0') then
					if (count<511) then
						seed<=count + 512;
					else
						seed<=count;
					end if;
					new_state<=off;
					working<='0';
				end if;
		end case;
	end process;			
end behaviour;

---------------------------------------------------------------------------------------------------------------------------

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
type mem_type is array(0 to (2**address'length)-1) of std_logic_vector(data_in'range);
signal mem : mem_type;
begin
	ram_lat : process(address, write, reset, data_in) is
	begin
		if (reset = '1') then
			mem(0 to 15) <= (others => (others => '0'));
		elsif (write = '1') then
			mem(to_integer(unsigned(address))) <= data_in;
		end if;
	end process;
	data_out <= mem(to_integer(unsigned(address)));
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
type mem_type is array(0 to address'length**2-1) of std_logic;
signal mem : mem_type;
begin
	ram_lat : process(address, write, reset, data_in) is
	begin
	
		if (reset = '1') then
			mem <= ((others => '0'));
		elsif (rising_edge(write)) then			-- rising_edge instead of write = '1' prevents all 3 registers from becoming the input of register 1
			mem(to_integer(unsigned(address))) <= data_in;
		end if;
	end process;
	data_out <= std_logic(mem(to_integer(unsigned(address))));
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
		allmines_done:		in std_logic;				-- if this is 1, all mines have been read, new mines should be 0
		mine_value:		in std_logic;				-- the value of the mine
		mineval_out:		out std_logic;				-- output, should be mine_value if allmines_done=0, else should be 0
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
	process (allmines_done, mine_value)
	begin
		if (allmines_done = '1') then
			mineval_out	<= '0';
		else
			mineval_out	<= mine_value;
		end if;
	end process;
	process (address_ctrl, address_pixel, ctrl_done, pixel_done, state)
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
	allmines_done:			out std_logic;				-- if this is 1, all mines have been read, new mines should be 0
	clk:				in std_logic;
	reset:				in std_logic);
end entity controller;

architecture behaviour of controller is
	signal address_surr_buffer, data_in_surr_buffer, bit_3, row:	std_logic_vector(3 downto 0);
	signal start_done, allmines_done_buffer:			std_logic;
	type	control_state is (	reset_state,
					load_mines,
					load_mines_2,
					read_left,
					read_middle,
					read_right,
					buffer_state);
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

	process (state, mine_done, write_surrread)
	begin
		case state is
			when reset_state =>
				write_surr			<= '0';			-- so it doesn't overwrite the current address with 0 after data_in_surr <= '0000'
				write_surrcalc			<= '0';
				row				<= (others => '0');	-- the current row it is working on
				address_mine			<= (others => '0');	-- output signal, determined based on state and address_surr_buffer
				address_surr			<= (others => '0');	-- output signal, address of cell who's surroundings are calculated
				address_surr_buffer		<= (others => '1');	-- if <15, not at end of row (came from line 237), used in load_mines_2 to specify this
											-- used because output signal can't be read in vhdl
				data_in_surr			<= (others => '0');	-- output signal, the amount of surrounding mines (is calculated in its buffer)
				data_in_surr_buffer		<= (others => '0');	-- this is also used in load_mines/load_mines_2 to specify what cell in the row
											-- used because output signal can't be read in vhdl
				bit_3				<= (others => '0');	-- always 000, used in line 220 so vhdl understands desired output
				start_done			<= '0';			-- if this is 0, 2 rows instead of 1 will be loaded the first time				allmines_done			<= '0';		-- if all mines in the field have been read, all new mines (below the field) are 0
				allmines_done_buffer		<= '0';			-- can't read output signals, a buffer is needed	
				allmines_done			<= '0';
				new_state			<= load_mines;
				write				<= '0';			-- so rising_edge(write) works properly at ram_1 for the first cell after reset

			when load_mines =>	-- this state asks for the mines and then starts writing them
				write_surrcalc	<= '0';
				address_mine	<= data_in_surr_buffer;
				mine_addr_ask(3 downto 0)	<= data_in_surr_buffer;	-- this signal is used here since every row it starts at 0, so it doesn't store
												-- anything right now, allowing it to be used
				if (start_done = '0') then
					mine_addr_ask(7 downto 4)	<= row;		-- assuming upper left corner is 0, from left to right, up to down
				else
					mine_addr_ask(7 downto 4)	<= row + 1;
				end if;
				if (mine_done = '1') then
					write	<= '1';
					new_state	<= load_mines_2;
					if (row = 14 AND data_in_surr_buffer = 15) then
						allmines_done	<= '1';		-- if all mines in the field have been read, all new mines (below the field) are 0
						allmines_done_buffer	<= '1';	-- can't read output signals, a buffer is needed	
					end if;
				end if;
			when load_mines_2 =>	-- this state registers when the mines are written and stops the process when a row of mines has been written
				write	<= '0';
				if (mine_done = '0') then
					if (data_in_surr_buffer < 15) then
						data_in_surr_buffer	<= data_in_surr_buffer + 1;
						new_state	<= load_mines;
					else
						if (start_done = '0') then	-- used when starting the program once only, loads 2 rows of mines for the first row
							start_done	<= '1';
							data_in_surr_buffer	<= (others => '0');
							new_state <= load_mines;
						elsif (write_surrread = '1') then	-- will start calculating the next row after pixel writer is done with this row
							new_state <= read_left;
							address_surr		<= (others => '0');	-- at the beginning of a row, you start with the first cell
							address_surr_buffer	<= (others => '0');
						end if;
					end if;
				end if;
				if (address_surr_buffer < 15) then -- this happens if it doesn't go to the next row, it is initialised to 15 in reset to prevent triggering this
					write_surr	<= '0';
					write_surrcalc	<= '0';
					address_surr			<= address_surr_buffer + '1';
					address_surr_buffer		<= address_surr_buffer + '1';	-- you can't read outputs in vhdl, so it is defined twice
					new_state	<= read_left;
				end if;
			when read_left =>
				if (address_surr_buffer > 0) then	-- if it is 0, then there are no cells and thus no mines to the left
					data_in_surr_buffer	<= bit_3 + data_out_mine1 + data_out_mine2 + data_out_mine3;	-- bit_3 is 000, used to prevent error
				else
					data_in_surr_buffer	<= (others => '0');
				end if;
				address_mine		<= address_surr_buffer;
				new_state	<= read_middle;
			when read_middle =>
				data_in_surr_buffer	<= data_in_surr_buffer + data_out_mine1 + data_out_mine3;
				if (address_surr_buffer < 15) then
					address_mine		<= address_surr_buffer + '1';
				end if;	
				new_state	<= read_right;
			when read_right =>
				write_surr	<= '1';				-- the value of data_in_surr calculated in this clock cycle needs to be written	
				data_in_surr_buffer	<= (others => '0'); 	-- this allows the signal to be used in load_mine/load_mine_2
										-- data_in_surr isn't influenced by this
				if (address_surr_buffer < 15) then		-- if it is 15, then there are no cells and thus no mines to the right
					data_in_surr		<= data_in_surr_buffer + data_out_mine1 + data_out_mine2 + data_out_mine3;
					address_mine		<= address_surr_buffer;
					new_state		<= load_mines_2;
				else
					data_in_surr	<= data_in_surr_buffer;
					new_state	<= buffer_state;
				end if;
			when buffer_state =>				-- if address_surr_buffer and row are 15, everything has been calculated, it will reset for the next iteration
				write_surr	<= '0';
				write_surrcalc	<= '1';			-- the signal that the row is calculated, control of surrounding address goes to pixel writer
				if (row = 15) then
					new_state	<= reset_state;	-- all rows have been read, it will start all over again
				else
					new_state	<= load_mines;
					row	<= row + 1;		-- this is the end of the row, it will now go to the next row	
				end if;
				
				
		end case;
	end process;
end architecture behaviour;

-----------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity building_main is	-- no way for other modules to ask for a mine at location...
	port(	clk:					in std_logic;
		reset:					in std_logic;				-- happens at the beginning of every game
		start:					in std_logic;				-- 1 if the start button is being pressed, 0 if it isn't
		ready: 					out  std_logic;				-- pulses with value 1 when a new mine has been calculated (to distinguish mines with the same value in series)
        	mine: 					out  std_logic;				-- 1 when there is a mine in the cell, 0 when there isn't
		mine_count: 				out std_logic_vector(5 downto 0);	-- the total amount of mines
       		count_ready: 				out std_logic;				-- is 1 when mine_count is done (all mines have been determined once)
		surr_read:				in std_logic;				-- when the pixel writer has written this row
		adr_surr_pixel:				in std_logic_vector(3 downto 0);	-- what is being read by the pixel writer
		surr_calc:				out std_logic;				-- when surrounding has been updated to the next row
		surr_out:				out std_logic_vector(3 downto 0));	-- the output that is read by pixel writer
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
			allmines_done:		in std_logic;				-- if this is 1, all mines have been read, new mines should be 0
			mine_value:		in std_logic;				-- the value of the mine
			mineval_out:		out std_logic;				-- output, should be mine_value if allmines_done=0, else should be 0
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
			write_surrcalc:			out std_logic;				-- gives a pulse of value 1 when the values of the next row of surrounding have been calculated
			write_surrread:			in std_logic;				-- gives a pulse when pixel writing has read the row and asks for the next row
			mine_done:			in std_logic;				-- pulses 1 when next mine is being outputted (after requesting next mine)
			mine_addr_ask:			out std_logic_vector(7 downto 0);	-- mine location asked for, assuming upper left corner is 0, from left to right, up to down
			allmines_done:			out std_logic;				-- if this is 1, all mines have been read, new mines should be 0
			clk:				in std_logic;
			reset:				in std_logic);
	end component controller;

	component seedgen
		port(	start : in  std_logic;
			reset : in  std_logic;
 			clk   : in  std_logic;
 	  		seed  : out std_logic_vector(9 downto 0));
	end component;

	component mineplacerv2
   		port(	seed : in std_logic_vector(9 downto 0);
      			pos  : in std_logic_vector(7 downto 0);
			clk  : in std_logic;
			reset: in std_logic;
			start: in std_logic;
        		mine : out std_logic;
			ready: out std_logic;
			last_cell: out std_logic);
	end component;

	component minecounter
  		port(	start      : in  std_logic;
    			reset      : in  std_logic;
      			clk        : in  std_logic;
			ready      : in  std_logic;
        		mine       : in  std_logic;
			last_cell  : in  std_logic;
        		mine_count : out std_logic_vector(5 downto 0);
        		count_ready: out std_logic);
	end component;

	signal write, write_surr, mine_1_out, mine_2_out, mine_3_out, surr_calc_sig, allmines_done, ram_1_data_in, ready_sig, last_cell_sig, mine_sig: std_logic;
	signal pos: std_logic_vector(7 downto 0);
	signal mine_address, surr_address, surr_in, adr_surr_ctrl: std_logic_vector(3 downto 0);
	signal seed_sig: std_logic_vector(9 downto 0);
	
begin
	surr_calc	<= surr_calc_sig;
	ready		<= ready_sig;
	mine		<= mine_sig;

	sdgn: 	seedgen port map(	start		=> start,
					reset		=> reset,
					clk		=> clk,
					seed		=> seed_sig);

	plc: 	mineplacerv2 port map(	seed		=> seed_sig,
					pos		=> pos,
					clk		=> clk,
					reset		=> reset,
					start		=> start,
					mine		=> mine_sig,
					ready		=> ready_sig,
					last_cell	=> last_cell_sig);

	cnt:	minecounter port map(	start		=> start,
					reset		=> reset,
					clk		=> clk,
					ready		=> ready_sig,
					mine		=> mine_sig,
					last_cell	=> last_cell_sig,
					mine_count	=> mine_count,
					count_ready	=> count_ready);

	mux_1:	mux_2to1 port map	(address_ctrl	=> adr_surr_ctrl,
					address_pixel	=> adr_surr_pixel,
					ctrl_done	=> surr_calc_sig,
					pixel_done	=> surr_read,
					output		=> surr_address,
					allmines_done	=> allmines_done,
					mine_value	=> mine_sig,
					mineval_out	=> ram_1_data_in,
					reset		=> reset,
					clk		=> clk);

	mine_1: ram_1 port map		(address	=> mine_address,
					data_in 	=> ram_1_data_in,	-- mine_1 has the most recent determined mines (the lowest of the 3 rows)
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
					address_surr	=> adr_surr_ctrl,
					write_surr	=> write_surr,
					write_surrcalc	=> surr_calc_sig,		
					write_surrread	=> surr_read,
					mine_done	=> ready_sig,
					mine_addr_ask	=> pos,
					allmines_done	=> allmines_done,
					clk		=> clk,
					reset		=> reset);
end architecture structural;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity building_main_tb is
end entity building_main_tb;

architecture structural_tb of building_main_tb is
	component building_main is	-- no way for other modules to ask for a mine at location...
		port(	clk:					in std_logic;
			reset:					in std_logic;				-- happens at the beginning of every game
			start:					in std_logic;				-- 1 if the start button is being pressed, 0 if it isn't
			ready: 					out  std_logic;				-- pulses with value 1 when a new mine has been calculated (to distinguish mines with the same value in series)
        		mine: 					out  std_logic;				-- 1 when there is a mine in the cell, 0 when there isn't
			mine_count: 				out std_logic_vector(5 downto 0);	-- the total amount of mines
       			count_ready: 				out std_logic;				-- is 1 when mine_count is done (all mines have been determined once)
			surr_read:				in std_logic;				-- when the pixel writer has written this row
			adr_surr_pixel:				in std_logic_vector(3 downto 0);	-- what is being read by the pixel writer
			surr_calc:				out std_logic;				-- when surrounding has been updated to the next row
			surr_out:				out std_logic_vector(3 downto 0)	-- the output that is read by pixel writer
			);
	end component building_main;
	signal clk, reset, start, ready, mine, count_ready, surr_read, surr_calc:	std_logic;
	signal adr_surr_pixel, surr_out:						std_logic_vector(3 downto 0);
	signal mine_count:								std_logic_vector(5 downto 0);
begin
	main_0: building_main port map	(clk				=> clk,
					reset				=> reset,
					start				=> start,
					ready				=> ready,
					mine				=> mine,
					mine_count			=> mine_count,
					count_ready			=> count_ready,
					surr_read			=> surr_read,
					adr_surr_pixel			=> adr_surr_pixel,
					surr_calc			=> surr_calc,
					surr_out			=> surr_out);

	clk				<=	'0' after 0 ns, '1' after 20 ns when clk /= '1' else '0' after 20 ns;

	reset 				<= 	'1' after 0 ns,
            					'0' after 80 ns;

	start 				<= 	'0' after 0 ns,
						'1' after 990 ns,
						'0' after 1020 ns;

	adr_surr_pixel			<= 	"0000" after 0 ns;

	surr_read			<= 	'1' after 0 ns;

end structural_tb;

