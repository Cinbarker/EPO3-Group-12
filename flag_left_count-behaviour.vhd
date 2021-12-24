library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of flag_left_count is
	type cnt_state is (start,count1,count2);
	signal state,new_state:cnt_state;
	signal c1:unsigned(5 downto 0);
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
	
	cnt:process(state,new_state,mine_count,write,cofl,mem_in)
	begin
		case state is
			when start=>
				if count_ready='1' then
					flags_left<=mine_count;
					c1<=unsigned(mine_count);
					new_state<=count1;
				else
					new_state<=start;
				end if;
			when count1=>
				if write='1' and cofl='1' and mem_in='1' then		--flag left -1
					if (to_integer(unsigned(flags_left)) > 0) then
						c1<=unsigned(flags_left)- to_unsigned(1,6);
					else
						c1<="000000";
					end if;
					new_state<=count2;
				elsif write='1' and cofl='1' and mem_in='0' then		--flag left +1
					if (to_integer(unsigned(flags_left)) < to_integer(unsigned(mine_count)))then		--mine_count=max flags_left
						c1<=unsigned(flags_left) + to_unsigned(1,6);
					else
						c1<=unsigned(mine_count);
					end if;
					new_state<=count2;
				else
					new_state<=count1;
				end if;
			when count2=>
				flags_left<=std_logic_vector(c1);
				new_state<=count1;
		end case;
	end process;
end behaviour;

