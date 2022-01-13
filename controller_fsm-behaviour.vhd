library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of controller_fsm is
	type controller_fsm_state is (UP, DOWN, LEFT, RIGHT, SEL, FLAG, START, reset_state, wait_1, wait_2);

	signal state, new_state : controller_fsm_state;
	signal old_count : std_logic_vector(9 downto 0);
	signal which_pin : std_logic_vector(2 downto 0);
	signal frame_count, old_frame_count : std_logic_vector(2 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= reset_state;
			else
				state <= new_state;
			end if;
		end if;
	end process;

	process(state, new_state, pin1, pin2, pin3, pin4, pin6, pin9, count_in, old_count)
	begin
		case state is
			when reset_state =>
				line_out <= "111";
				frame_count <= (others => '0');
				old_frame_count <= (others => '0');
				if pin1 = '0' then
					old_count <= count_in;
					which_pin <= "000";
					new_state <= wait_1;
				elsif pin2 = '0' then
					old_count <= count_in;
					which_pin <= "001";
					new_state <= wait_1;
				elsif pin3 = '0' then
					old_count <= count_in;
					which_pin <= "010";
					new_state <= wait_1;
				elsif pin4 = '0' then
					old_count <= count_in;
					which_pin <= "011";
					new_state <= wait_1;
				elsif (pin6 = '0' and pin9 = '0') then
					old_count <= count_in;
					which_pin <= "XXX";			
					new_state <= wait_1;
				elsif pin6 = '0' then
					old_count <= count_in;
					which_pin <= "100";
					new_state <= wait_1;
				elsif pin9 = '0' then
					old_count <= count_in;
					which_pin <= "101";
					new_state <= wait_1;
				else 
					new_state <= reset_state;
				end if;

			when wait_1 =>
				line_out <= "111";
				old_frame_count <= frame_count;
				if old_count /= count_in then
					new_state <= wait_2;
				else
					new_state <= wait_1;
				end if;

			when wait_2 => 
				line_out <= "111";
				frame_count <= std_logic_vector(unsigned(old_frame_count) + 1);
				if old_count = count_in then
					if (frame_count >= "101") then
						if (pin6 = '0' and pin9 = '0') then
							which_pin <= "110";
						else
							null;
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
						new_state <= wait_1;
					end if;
				else
					new_state <= wait_2;
				end if;
			
			
			when up =>
				line_out <= "000";
				if pin1 = '1' then
					new_state <= wait_1;
				else
					new_state <= up;
				end if;
			when down =>
				line_out <= "001";
				if pin2 = '1' then
					new_state <= wait_1;
				else
					new_state <= down;
				end if;
			when left =>
				line_out <= "010";
				if pin3 = '1' then
					new_state <= wait_1;
				else
					new_state <= left;
				end if;

			when right =>
				line_out <= "011";
				if pin4 = '1' then
					new_state <= wait_1;
				else
					new_state <= right;
				end if;
			when sel =>
				line_out <= "100";
				if pin6 = '1' then
					new_state <= wait_1;
				else
					new_state <= sel;
				end if;
			when flag =>
				line_out <= "101";
				if pin9 = '1' then
					new_state <= wait_1;
				else
					new_state <= flag;
				end if;
			when start =>
				line_out <= "110";
				if pin6 = '1' or pin9 = '1' then
					new_state <= wait_1;
				else
					new_state <= start;
				end if;
		end case;
	end process;
end behaviour;

