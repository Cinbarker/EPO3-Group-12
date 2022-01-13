library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of startconverter is
	type s_state is (off,reset1,start1);
	signal state,new_state:s_state;
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

	lbl1:process(state,new_state,controller_in)
	begin
		case state is
			when off=>
				if controller_in="110" then
					start<='1';
					reset_out<='1';
					new_state<=reset1;
				else
					start<='0';
					reset_out<='0';
					new_state<=off;
				end if;
			when reset1=>
					start<='1';
					reset_out<='1';
					new_state<=start1;
			when start1=>
				reset_out<='0';
				if controller_in/="110" then
					start<='0';
					new_state<=off;
				else
					start<='1';
					new_state<=start1;
				end if;
		end case;
	end process;
end behaviour;

