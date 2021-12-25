library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of cover_count is
	type cc_state is (start,uncover1,count1,count2,game_end,game_end2);
	signal state,new_state:cc_state;
	signal c1:unsigned(7 downto 0);
	signal mc:unsigned(7 downto 0);
	signal cover_count:unsigned(7 downto 0);
begin
	rst:process(clk,reset)
	begin
		if(clk'event and clk='1') then
			if reset='1' then
				state<=start;
			else
				state<=new_state;
			end if;
		end if;
	end process;

	cc:process(state,new_state,mem_in,cofl,write,count_ready,mine,mine_ready)
	begin
		case state is
			when start=>				--wait until count_ready
				win_over<='0';
				cover_count<="11111111";
				if count_ready='1' then				--cannot uncover before count_ready, see clearing3
					mc<=resize(unsigned(mine_count),8);
					new_state<=uncover1;
				else
					new_state<=start;
				end if;
			when uncover1=>					--uncover first cell, counter only goes to 255 256 cells in field
				if mem_in='0' and cofl='0' and write='1' then
					new_state<=count1;
				else
					new_state<=uncover1;
				end if;
			when count1=>						--count cells
				if mem_in='0' and cofl='0' and write='1' then
					c1<=(cover_count - to_unsigned(1,8));
					new_state<=count2;
				else
					new_state<=count1;
				end if;
			when count2=>				--update count
				if c1=mc and mine_ready='1' and mine='0' then					--if no mine, win
					new_state<=game_end;
				elsif c1=mc and mine_ready='1' and mine='1' then		--if mine, no win
					new_state<=game_end2;
				elsif c1=mc then					--if covers=mines then wait till mine
					new_state<=count2;
				else
					cover_count<=c1;
					new_state<=count1;
				end if;
			when game_end=>
				win_over<='1';
			when game_end2=>
				win_over<='0';
		end case;
	end process;
end behaviour;
--add mine check for last cell
