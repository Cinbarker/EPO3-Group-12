library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of clearing_2 is
	type clearing_alg_state is (read_cov, read_flag, read_mine, uncovered, flag, unflag);
	
	signal state, new_state : clearing_alg_state;
	signal pos : std_logic_vector(7 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= covered;
			else
				pos <= cursor_in;
				state <= new_state;
			end if;
		end if;
	end process;

	process(state, new_state)
	begin
		case state is
			when request_cov =>
				--read cover from memory, write = 0. If 0, uncovered. If cover 1, read_flag, cofl 0
				write <= '0';
				cofl <= '0';
				if (controller_in = "100" or controller_in = "101") then
				new_state <= read_cov;
			when read_cov =>
				write <= '0';
				if (cover_in = '0') then
					new_state <= uncovered;
				elsif (cover_in = '1') then
					cofl <= '1';
					new_state <= read_flag;
				else
					new_state <= read_cov;
				end if;
			when read_flag
				--read flag from memory, wirte = 0, cofl = 1
				write <= '0';
				if (flag_in = '0') then 
			
		end case;
	end process;
end architecture;





end behaviour;

