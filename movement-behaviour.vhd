library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

architecture behavioural of movement is
	signal pos_xy, new_pos_xy : std_logic_vector(7 downto 0);
	signal controller_in_old : std_logic_vector(2 downto 0);
	signal controller_in_older : std_logic_vector(2 downto 0);

begin
	
	address_out <= pos_xy;
	process(clk,reset)
	begin
		
			if (reset = '1') then
				pos_xy <= std_logic_vector(to_unsigned(0,8));
				controller_in_old <= (others => '1');				
				controller_in_older <= (others => '1');
			elsif (rising_edge(clk)) then
				pos_xy <= new_pos_xy;
				controller_in_older <= controller_in_old;
				controller_in_old <= controller_in;
				
			end if;
	end process;

	process(pos_xy, controller_in_older, controller_in_old)
	begin
		new_pos_xy <= pos_xy;
		if (controller_in_older /= controller_in_old) then
			if (controller_in_old = "000") then
				new_pos_xy <= std_logic_vector(unsigned(pos_xy) - to_unsigned(16,8));
			elsif (controller_in_old = "001") then
				new_pos_xy <= std_logic_vector(unsigned(pos_xy) + to_unsigned(16,8));
			elsif (controller_in_old = "011") then
				if ((to_integer(unsigned(pos_xy)) mod 16) = 15) then
					new_pos_xy <= std_logic_vector(unsigned(pos_xy) - to_unsigned(15,8));
				else
					new_pos_xy <= std_logic_vector(unsigned(pos_xy) + to_unsigned(1,8));
				end if;
			elsif (controller_in_old = "010") then
				if ((to_integer(unsigned(pos_xy)) mod 16) = 0) then
					new_pos_xy <= std_logic_vector(unsigned(pos_xy) + to_unsigned(15,8));
				else
					new_pos_xy <= std_logic_vector(unsigned(pos_xy) - to_unsigned(1,8));
				end if;
			elsif (controller_in_old = "110") then
				new_pos_xy <= std_logic_vector(to_unsigned(0,8));
			end if;
		end if;
	end process;
end architecture;
