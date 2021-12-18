library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of flag_counter is
	type fc_state is (start,counting,update_count);
	signal state,new_state:fc_state;
	signal count,new_count:unsigned(5 downto 0);
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

	cnt:process(state,new_state)
	begin
		case state is
			when start=>
				if count_ready='1' then
					count_out<=mine_count;
					new_count<=unsigned(mine_count);
					new_state<=counting;
				else
					new_state<=start;
				end if;
			when counting=>
				if write='1' and flag='1' and cofl='1' then
					new_count<=unsigned(count_out) - to_unsigned(1,6);
					new_state<=update_count;
				elsif write='1' and flag='0' and cofl='1' then
					new_count<=unsigned(count_out) + to_unsigned(1,6);
					new_state<=update_count;
				else
					new_state<=counting;
				end if;
			when update_count=>
				count_out<=std_logic_vector(new_count);
				new_state<=counting;
		end case;
	end process;
end behaviour;

