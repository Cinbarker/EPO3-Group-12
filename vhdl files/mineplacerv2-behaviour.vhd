library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of mineplacerv2 is
	type mine_state is (off,on0,on1,update);
	type starter_state is (off,waiting,start1);
	signal s_state,s_new_state:starter_state;
	signal state, new_state:mine_state;
	signal old_pos:std_logic_vector(7 downto 0);
	signal start_plc:std_logic;

begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then					
			if reset='1' then
				state<=off;
				s_state<=off;
				
			else
				state<=new_state;
				s_state<=s_new_state;
			end if;
		end if;
	end process;
	
	placer_starter:process(start,s_state,s_new_state)				--waits for start input, initiates plc process
	begin
		case s_state is
			when off=>
				start_plc<='0';
				if start='1' then
					s_new_state<=waiting;
				else
					s_new_state<=off;
				end if;
			when waiting=>
				if start<='0' then
					s_new_state<=start1;
				else
					s_new_state<=waiting;
				end if;
			when start1=>
				start_plc<='1';
				s_new_state<=off;
		end case;
	end process;

	postracker:process(pos)
	begin
		if pos=std_logic_vector(to_unsigned(255,8)) then
			last_cell<='1';
		else
			last_cell<='0';
		end if;
	end process;
	
	mineplacer:process(pos,state,new_state,seed,clk,start_plc)
	begin
		case state is
			when off=>
				mine<='0';
				ready<='0';
				old_pos<="00000000";
				if start_plc='1' then
					new_state<=on0;
				else
					new_state<=off;
				end if;
			when on0=>
				if to_integer(unsigned(pos))<256 then
					new_state<=on1;			--wait for first input
				else
					new_state<=on0;
				end if;
			when on1=>
				old_pos<=pos;
				if (((to_integer((unsigned(seed) * 100) / unsigned(pos))) mod 6) = 0) then			--place mine
					mine<='1';
					ready<='1';
				else
					mine<='0';
					ready<='1';
				end if;
				new_state<=update;
			when update=>
				ready<='0';
				if old_pos/=pos then
					new_state<=on1;
				else
					new_state<=update;
				end if;
		end case;
	end process;
end behaviour;

