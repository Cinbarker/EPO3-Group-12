library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of flagcount is
	type cnt_state is (start,count1,count2);
	signal state,new_state:cnt_state;
	signal mines:unsigned(8 downto 0);
	signal flag_count,fc2:unsigned(8 downto 0);
	signal fc3:std_logic_vector(8 downto 0);
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
				flag_count<="000000000";
				fc2<="000000000";
				if count_ready='1' then
					flags_left<=mine_count;
					mines<=resize(unsigned(mine_count),9);
					new_state<=count1;
				else
					new_state<=start;
				end if;
			when count1=>
				if write='1' and cofl='1' and mem_in='1' then		--add flag
					flag_count<=fc2+to_unsigned(1,8);
					fc3<=std_logic_vector(mines - fc2 - to_unsigned(1,8));
					new_state<=count2;
				elsif write='1' and cofl='1' and mem_in='0' then	--unflag
					flag_count<=fc2-to_unsigned(1,8);
					fc3<=std_logic_vector(mines-fc2+to_unsigned(1,8));
					new_state<=count2;
				else
					new_state<=count1;
				end if;
			when count2=>
				fc2<=flag_count;
				if to_integer(unsigned(fc3)) <= to_integer(mines) then
					flags_left<=fc3(5 downto 0);
				else
					flags_left<="000000";
				end if;
				new_state<=count1;
		end case;
	end process;
end behaviour;
