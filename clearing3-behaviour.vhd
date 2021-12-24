library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of clearing3 is
	type clr_state is (game_start,req_cov,read_cov,req_fl,read_fl,waiting,update_cursor,uncover,flag,unflag,check_mine,ac1,ac2,ac3,ac4,ac5,ac6,ac7,ac8,ac9,ac10,ac11,ac12,ac13,ac14,ac15,ac16,game_end);
	type ready_state is (r1,r2);
	signal r_state,r_new_state:ready_state;
	signal state,new_state:clr_state;
	signal cover_in,flag_in:std_logic;
	signal cursor_buff:std_logic_vector(7 downto 0);
	signal already_uncov:std_logic;
	signal ready:std_logic;
	signal border:std_logic;
	signal borderdir:std_logic_vector(2 downto 0);
begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then					
			if reset='1' then
				state<=game_start;
				r_state<=r1;
			elsif ready='1' then
				state<=new_state;
			else
				state<=state;
				r_state<=r_new_state;
			end if;
		end if;
	end process;

	rdy:process(calc_ready,r_state,r_new_state)
	begin
		case r_state is
			when r1=>
				if calc_ready='1' then
					ready<='1';
					r_new_state<=r2;
				else
					ready<='0';
					r_new_state<=r1;
				end if;
			when r2=>
				if stop='1' then
					r_new_state<=r1;
					ready<='0';
				else
					r_new_state<=r2;
				end if;
		end case;
	end process;
	
	clr:process(state,new_state,controller_in,cursor_in,start)
	begin
		case state is
			when game_start=>
				already_uncov<='0';
				border<='0';
				borderdir<="000";
				cover_out<='1';
				flag_out<='0';
				game_over<='0';
				pass<='1';
				number_out<="0000";
				cursor_out<=cursor_in;
				cursor_buff<=cursor_in;
				write<='0';
				cofl<='0';
				if start='1' then		--first frame done
					new_state<=read_cov;
				else
					new_state<=game_start;
				end if;
			when req_cov=>
				cursor_out<=cursor_buff;
				write<='0';
				cofl<='0';
				pass<='0';
				new_state<=read_cov;
			when read_cov=>
				cursor_out<=cursor_buff;
				write<='0';
				cofl<='0';
				pass<='0';
				cover_out<=mem_in;
				cover_in<=mem_in;
				if mem_in='0' then
					new_state<=waiting;
				else
					new_state<=req_fl;
				end if;
			when req_fl=>
				cursor_out<=cursor_buff;
				write<='0';
				cofl<='1';
				pass<='0';
				new_state<=read_fl;
			when read_fl=>
				cursor_out<=cursor_buff;
				write<='0';
				cofl<='1';
				pass<='0';
				flag_out<=mem_in;
				flag_in<=mem_in;
				new_state<=waiting;
			when waiting=>
				game_over<='0';
				write<='0';
				pass<='1';
				cover_out<=cover_in;
				cursor_out<=cursor_buff;
				if cursor_buff/=cursor_in then	--pos change => read mem
					new_state<=update_cursor;
				elsif controller_in="100" and flag_in='0' and already_uncov='0' then		--uncover only when no flag and covered
					new_state<=uncover;
				elsif controller_in="101" and cover_in='1' then				--flag when no flag, unflag when flag
					if flag_in='0' then
						new_state<=flag;
					else 
						new_state<=unflag;
					end if;
				else
					new_state<=waiting;
				end if;
			when update_cursor=>
				already_uncov<='0';
				cursor_buff<=cursor_in;
				new_state<=req_cov;
			when flag=>
				cursor_out<=cursor_buff;
				write<='1';
				cofl<='1';
				flag_out<='1';
				pass<='0';
				new_state<=waiting;
			when unflag=>
				cursor_out<=cursor_in;
				write<='1';
				cofl<='1';
				flag_out<='0';
				pass<='0';
				new_state<=waiting;
			when uncover=>
				if to_integer(unsigned(cursor_buff))=0 then					--top left corner
					border<='1';
					borderdir<="001";
				elsif to_integer(unsigned(cursor_buff))=15 then					--top right corner
					border<='1';
					borderdir<="011";
				elsif to_integer(unsigned(cursor_buff))=255 then					--bottom right corner
					border<='1';
					borderdir<="101";
				elsif to_integer(unsigned(cursor_buff))=240 then					--bottom left corner
					border<='1';
					borderdir<="111";
				elsif to_integer(unsigned(cursor_buff))<15 then				--top row
					border<='1';
					borderdir<="010";
				elsif to_integer(unsigned(cursor_buff))>240 then 		--bottom row
					border<='1';
					borderdir<="110";
				elsif (to_integer(unsigned(cursor_buff)) mod 16)=0 then		--left column
					border<='1';
					borderdir<="000";
				elsif (to_integer(unsigned(cursor_buff)) mod 16)=15 then		--right column
					border<='1';
					borderdir<="100";
				else					--no adjacent border
					border<='0';
				end if;
				already_uncov<='1';
				write<='1';
				cofl<='0';
				cover_out<='0';
				pass<='0';
				new_state<=check_mine;
			when check_mine=>
				write<='0';
				cursor_out<=cursor_buff;
				if mine_in='1' and mine_ready='1' then
					new_state<=game_end;
				elsif mine_in='0' and mine_ready='1' then						--uncover if no mine
					if number_in="0000" then					--if cell empty > auto clear
						number_out<=number_in;
						if border='0' then				--full cycle, start left
							new_state<=ac1;			
						elsif borderdir="000" then				--half cycle start top
							new_state<=ac5;
						elsif borderdir="001" then				--quarter cycle, start right
							new_state<=ac9;
						elsif borderdir="010" then				--half cycle, start right
							new_state<=ac9;
						elsif borderdir="011" then				--quarter cycle, start bottom
							new_state<=ac13;
						elsif borderdir="100" then				--half cycle, start bottom
							new_state<=ac13;
						elsif borderdir="101" then				--quarter cycle, start left
							new_state<=ac1;
						elsif borderdir="110" then				--half cycle, start left
							new_state<=ac1;
						elsif borderdir="111" then				--quarter cycle, start right
							new_state<=ac9;
						else
							new_state<=waiting;
						end if;
					else
						new_state<=waiting;			--only uncover selected cell
					end if;
				else
					new_state<=check_mine;
				end if;
			when ac1=>			--read flag cell left
				cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(1,8)); 
				write<='0';
				cofl<='1';
				new_state<=ac2;
			when ac2=>			--uncover if not flagged
				if flag_in='0' then				
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(1,8));
				end if;
				if border='1' and (borderdir="010" or borderdir="011") then
					new_state<=waiting;
				else
					new_state<=ac3;
				end if;
			when ac3=>			--read flag cell above left
				cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(17,8));
				write<='0';
				cofl<='1';
				new_state<=ac4;
			when ac4=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(17,8));
				end if;
				new_state<=ac5;
			when ac5=>			--read flag cell above
				cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(16,8));
				write<='0';
				cofl<='1';
				new_state<=ac6;
			when ac6=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(16,8));
				end if;
				if border='1' and (borderdir="100" or borderdir="101") then
					new_state<=waiting;
				else
					new_state<=ac7;
				end if;
			when ac7=>			--read flag cell above right
				cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(15,8));
				write<='0';
				cofl<='1';
				new_state<=ac8;
			when ac8=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) - to_unsigned(15,8));
				end if;
				new_state<=ac9;
			when ac9=>			--read flag cell right
				cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(1,8));
				write<='0';
				cofl<='1';
				new_state<=ac10;
			when ac10=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(1,8));
				end if;
				if border='1' and (borderdir="110" or borderdir="111") then
					new_state<=waiting;
				else
					new_state<=ac11;
				end if;
			when ac11=>			--read flag cell below right
				cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(17,8));
				write<='0';
				cofl<='1';
				new_state<=ac12;
			when ac12=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(17,8));
				end if;
				new_state<=ac13;
			when ac13=>			--read flag cell below
				cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(16,8));
				write<='0';
				cofl<='1';
				new_state<=ac14;
			when ac14=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(16,8));
				end if;
				if border='1' and (borderdir="000" or borderdir="001") then
					new_state<=waiting;
				else
					new_state<=ac15;
				end if;
			when ac15=>			--read flag cell below left
				cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(15,8));
				write<='0';
				cofl<='1';
				new_state<=ac16;
			when ac16=>			--uncover if not flagged
				if flag_in='0' then	
					write<='1';
					cofl<='0';
					cover_out<='0';
					cursor_out<=std_logic_vector(unsigned(cursor_buff) + to_unsigned(15,8));
				end if;
				if border='0' then
					new_state<=waiting;
				else
					new_state<=ac1;
				end if;
			when game_end=>
				pass<='1';
				cover_out <= '0';
				flag_out <= '0';
				game_over <= '1';
				cursor_out <= "XXXXXXXX";
		end case;
	end process;
end behaviour;

