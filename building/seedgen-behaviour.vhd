library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

architecture behaviour of seedgen is
	type seed_state is (off,counting1,counting2,counting_done);
	signal state, new_state:seed_state;
	signal count,new_count:std_logic_vector(9 downto 0);
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

	sdgn:process(state,start,new_state)
	begin
		case state is
			when off=>
				count<=std_logic_vector(to_unsigned(0,10));
				new_count<=std_logic_vector(to_unsigned(0,10));
				if reset='1' then
					seed<=std_logic_vector(to_unsigned(0,10));
				end if;
				if start='1' then
					new_state<=counting1;
				else
					new_state<=off;
				end if;
			when counting1=>
				if start='1' then
					new_count<=std_logic_vector(unsigned(count)+to_unsigned(1,10));
					new_state<=counting2;
				else
					new_state<=counting_done;	
				end if;									when counting2=>
				count<=new_count;
				new_state<=counting1;
			when counting_done=>
				if to_integer(unsigned(count))<511 then
				seed<=std_logic_vector(unsigned(count) - to_unsigned(512,10));
				else
				seed<=count;
				end if;
				new_state<=off;
		end case;
	end process;			
end behaviour;
