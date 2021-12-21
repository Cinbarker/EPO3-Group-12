library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of pulse_gen is
begin
	lbl:process(count_in)
	begin
		if (to_integer(unsigned(count_in)) mod 24)=23 then
			load_next<='1';
		else 
			load_next<='0';
		end if;
		if to_integer(unsigned(count_in))= 500 then
			stop_clearing<='1';
		else
			stop_clearing<='0';
		end if;
	end process;
end behaviour;

