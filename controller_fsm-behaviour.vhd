library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of controller_fsm is
	type controller_fsm_state is (UP, DOWN, LEFT, RIGHT, SEL, FLAG, STOP, reset_state);

	signal state, new_state : controller_fsm_state;

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

	process(state, new_state, pin1, pin2, pin3, pin4, pin6, pin7, pin9)
	begin
		case state is
			when up =>
				line_out <= "000";	
				if (not(pin1 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= up;
				end if;
			when down =>
				line_out <= "001";
				if (not(pin2 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= down;
				end if;
			when left =>
				line_out <= "010";
				if (not(pin3 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= left;
				end if;
			when right =>
				line_out <= "011";
				if (not(pin4 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= right;
				end if;
			when sel =>
				line_out <= "100";
				if (not(pin6 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= sel;
				end if;
			when flag =>
				line_out <= "101";
				if (not(pin9 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= flag;
				end if;
			when stop =>
				line_out <= "110";
				if (not(pin6 = '0' and pin9 = '0')) then 
					new_state <= reset_state;
				else
					new_state <= stop;
				end if;
			when reset_state =>
				line_out <= "111";  
				if (pin1 = '0') then
					new_state <= up;
				elsif (pin2 = '0') then
					new_state <= down;
				elsif (pin3 = '0') then
					new_state <= left;
				elsif (pin4 = '0') then
					new_state <= right;
				elsif (pin6 = '0' and pin9 = '0') then
					new_state <= stop;
				elsif (pin6 = '0') then
					new_state <= sel;
				elsif (pin9 = '0') then
					new_state <= flag;
				else
					new_state <= reset_state;
				end if;	
		end case;
	end process;
end behaviour;

