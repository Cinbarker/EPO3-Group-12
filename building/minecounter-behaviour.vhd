library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of minecounter is
type counter_state is (off,add_count,update_count,count_done);
signal new_count:std_logic_vector(5 downto 0);
signal state, new_state:counter_state;

begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then
			if reset='1' then
				state<=off;
			else
				state<=new_state;
			end if;
		end if;
	end process;

	cnt:process(state,new_state,ready,start)
	begin
		case state is
			when off=>
			if start='1' then
				new_state<=add_count;
			else
				new_state<=off;
			end if;
			mine_count<=std_logic_vector(to_unsigned(0,6));
			new_count<=std_logic_vector(to_unsigned(0,6));
			count_ready<='0';
			when update_count=>
			if ready='0' then
				mine_count<=new_count;
				if last_cell='1' then
					new_state<=count_done;
				else
					new_state<=add_count;
				end if;
			else
				new_state<=update_count;
			end if;
			when add_count=>
			if ready='1' then
				if mine='1' then
						new_count<=std_logic_vector(unsigned(mine_count)+to_unsigned(1,6));new_state<=update_count;
					else
						new_state<=add_count;
					end if;
			else
				new_state<=add_count;
			end if;
			when count_done=>
			mine_count<=new_count;
			count_ready<='1';
		end case;
	end process;
end behaviour;

