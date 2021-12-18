library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of clearing_2 is
	type clr_state is (game_start,req_cov,read_cov,req_fl,read_fl,waiting,uncover,flag,unflag,check_mine,game_end);
	signal state,new_state:clr_state;
	signal old_pos:std_logic_vector(7 downto 0);
begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then					
			if reset='1' then
				state<=game_start;
			elsif calc_ready='1' then
				state<=new_state;
			else
				state<=state;
			end if;
		end if;
	end process;

	clr:process(state,new_state,controller_in,cursor_in,start)
	begin
		case state is
			when game_start=>
				cover_out<='1';
				flag_out<='0';
				game_over<='0';
				number_out<="0000";
				cursor_out<=std_logic_vector(to_unsigned(0,8));
				write<='0';
				cofl<='0';
				if start='1' then		--first frame done
					new_state<=read_cov;
				end if;
			when req_cov=>
				cursor_out<=cursor_in;
				write<='0';
				cofl<='0';
				new_state<=read_cov;
			when read_cov=>
				old_pos<=cursor_in;
				write<='0';
				cofl<='0';
				cover_out<=cover_in;
				new_state<=req_fl;
			when req_fl=>
				write<='0';
				cofl<='1';
				new_state<=read_fl;
			when read_fl=>
				write<='0';
				cofl<='1';
				flag_out<=flag_in;
				new_state<=waiting;
			when waiting=>
				write<='0';
				if old_pos/=cursor_in then	--pos change => read mem
					new_state<=req_cov;
				elsif controller_in="100" and flag_in='0' then		--uncover only when no flag
					new_state<=uncover;
				elsif controller_in="101" then				--flag when no flag, unflag when flag
					if flag_in='0' then
						new_state<=flag;
					else 
						new_state<=unflag;
					end if;
				else
					new_state<=waiting;
				end if;
			when flag=>
				cursor_out<=cursor_in;
				write<='1';
				cofl<='1';
				flag_out<='1';
				new_state<=waiting;
			when unflag=>
				cursor_out<=cursor_in;
				write<='1';
				cofl<='1';
				flag_out<='0';
				new_state<=waiting;
			when uncover=>
				cursor_out<=cursor_in;
				write<='1';
				cofl<='1';
				cover_out<='0';
				new_state<=check_mine;
			when check_mine=>
				if mine_in='1' and mine_ready='1' then
					new_state<=game_end;
				elsif mine_in='0' and mine_ready='1' then
					number_out<=number_in; --??? 
					new_state<=waiting;
				else
					new_state<=check_mine;
				end if;
			when game_end=>
				cover_out <= '0';
				flag_out <= '0';
				game_over <= '1';
				cursor_out <= "XXXXXXXX";
		end case;
	end process;
end behaviour;

