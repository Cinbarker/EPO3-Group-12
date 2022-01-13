library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of controller_fsm is
	type controller_fsm_state is (UP, DOWN, LEFT, RIGHT, SEL, FLAG, START, reset_state, wait_1, wait_2);

	signal state, new_state : controller_fsm_state;
	signal old_count,new_count : std_logic_vector(9 downto 0);
	signal which_pin,new_pin : std_logic_vector(2 downto 0);
	signal frame_count, old_frame_count : std_logic_vector(2 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= reset_state;
				old_frame_count<="000";
				which_pin<="000";
				old_count<="0000000000";
			else
				state <= new_state;
				old_frame_count<=frame_count;
				which_pin<=new_pin;
				old_count<=new_count;
			end if;
		end if;
	end process;

	process(state, new_state, pin1, pin2, pin3, pin4, pin6, pin9, count_in, old_count,which_pin,old_frame_count)
	begin
		case state is
			when reset_state =>
				line_out <= "111";
				frame_count <= "000";
				if pin1 = '0' then
					new_count <= count_in;
					new_pin <= "000";
					new_state <= wait_1;
				elsif pin2 = '0' then
					new_count <= count_in;
					new_pin <= "001";
					new_state <= wait_1;
				elsif pin3 = '0' then
					new_count <= count_in;
					new_pin <= "010";
					new_state <= wait_1;
				elsif pin4 = '0' then
					new_count <= count_in;
					new_pin <= "011";
					new_state <= wait_1;
				elsif (pin6 = '0' and pin9 = '0') then
					new_count <= count_in;
					new_pin <= "111";			
					new_state <= wait_1;
				elsif pin6 = '0' then
					new_count <= count_in;
					new_pin <= "100";
					new_state <= wait_1;
				elsif pin9 = '0' then
					new_count <= count_in;
					new_pin <= "101";
					new_state <= wait_1;
				else 
					new_count<="0000000000";
					new_pin <= "111";
					new_state <= reset_state;
				end if;

			when wait_1 =>
				new_pin<=which_pin;
				line_out <= "111";
				new_count<=old_count;
				frame_count<=old_frame_count;
				if old_count /= count_in then
					new_state <= wait_2;
				else
					new_state <= wait_1;
				end if;

			when wait_2 => 
				new_pin<=which_pin;
				new_count<=old_count;
				line_out <= "111";
				if old_count = count_in then
					frame_count <= std_logic_vector(unsigned(old_frame_count) + to_unsigned(1,3));
					if (unsigned(old_frame_count) >= "100") then
						if (pin6 = '0' and pin9 = '0') then
							new_pin <= "110";
						end if;
						--when the button is pressed
						if (pin1 = '0' and which_pin = "000") then
							new_state <= up;
						elsif (pin2 = '0' and which_pin = "001") then
							new_state <= down;
						elsif (pin3 = '0' and which_pin = "010") then
							new_state <= left;
						elsif (pin4 = '0' and which_pin = "011") then
							new_state <= right;
						elsif (pin6 = '0' and pin9 = '0' and which_pin = "110") then
							new_state <= start;
						elsif (pin6 = '0' and which_pin = "100") then
							new_state <= sel;
						elsif (pin9 = '0' and which_pin = "101") then
							new_state <= flag;						
				
						--when the button is released, all pin inputs are 1
						else
							new_state <= reset_state;
						end if;
					else 
						new_state <= wait_2;
					end if;
				else
					frame_count<=old_frame_count;
					new_state <= wait_2;
				end if;
			
			
			when up =>
				line_out <= "000";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin1 = '1' then
					new_state <= wait_1;
				else
					new_state <= up;
				end if;
			when down =>
				line_out <= "001";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin2 = '1' then
					new_state <= wait_1;
				else
					new_state <= down;
				end if;
			when left =>
				line_out <= "010";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin3 = '1' then
					new_state <= wait_1;
				else
					new_state <= left;
				end if;

			when right =>
				line_out <= "011";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin4 = '1' then
					new_state <= wait_1;
				else
					new_state <= right;
				end if;
			when sel =>
				line_out <= "100";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin6 = '1' then
					new_state <= wait_1;
				else
					new_state <= sel;
				end if;
			when flag =>
				line_out <= "101";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin9 = '1' then
					new_state <= wait_1;
				else
					new_state <= flag;
				end if;
			when start =>
				line_out <= "110";
				frame_count<=old_frame_count;
				new_count<=old_count;
				new_pin<=which_pin;
				if pin6 = '1' or pin9 = '1' then
					new_state <= wait_1;
				else
					new_state <= start;
				end if;
		end case;
	end process;
end behaviour;
