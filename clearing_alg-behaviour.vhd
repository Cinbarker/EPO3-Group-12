library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of clearing_alg is

	type clearing_alg_state is (covered, flag_state, mine_state, number_state, game_over_state);

	signal state, new_state : clearing_alg_state;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= covered;
			else
				state <= new_state;
			end if;
		end if;
	end process;

	process(state, new_state, controller_in)
	begin
		case state is
			when covered =>
				cover_out <= '1';     
				flag_out <= '0';
				game_over <= '0';
				cursor_out <= cursor_in;
				if (cover_in = '1' and controller_in = "100" and mine_in = '0') then 		--select number
					new_state <= number_state;
				elsif (cover_in = '1' and controller_in = "100" and mine_in = '1') then 	--select mine
					new_state <= mine_state;
				elsif (cover_in = '1' and controller_in = "101") then				--flag
					new_state <= flag_state;
				else
					new_state <= covered;
				end if;
			when flag_state =>
				cover_out <= '1';
				flag_out <= '1';
				game_over <= '0';
				cursor_out <= cursor_in;
			when mine_state =>
				cover_out <= '0';
				flag_out <= '0';
				game_over <= '0';
				cursor_out <= cursor_in;
				new_state <= game_over_state;
			when game_over_state =>
				cover_out <= '0';
				flag_out <= '0';
				game_over <= '1';
				cursor_out <= "XXXXXXXX";
			when number_state =>
				cover_out <= '0';
				flag_out <= '0';
				game_over <= '0';
				cursor_out <= cursor_in;
		end case;
	end process;
end architecture;

