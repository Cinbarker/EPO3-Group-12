library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of c_buffer is
	type buffer_state is (start,passthrough,hold);
	signal state,new_state:buffer_state;
	signal controller_buff:std_logic_vector(2 downto 0);
begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then					
			if reset='1' then
				state<=start;
			else
				state<=new_state;
			end if;
		end if;
	end process;

	lbl1:process(state,new_state,pass,controller_in)
	begin
	case state is
		when start=>
			controller_buff<=controller_in;
			if controller_in="100" or controller_in="101" then
				if pass='1' then 
					new_state<=passthrough;
				else
					new_state<=hold;
				end if;
			else
				new_state<=passthrough;
			end if;
		when passthrough=>
			controller_out<=controller_buff;
			new_state<=start;
		when hold=>
			controller_out<="111";
			if pass='1' then
				new_state<=passthrough;
			else
				new_state<=hold;
			end if;
	end case;
	end process;
end behaviour;

