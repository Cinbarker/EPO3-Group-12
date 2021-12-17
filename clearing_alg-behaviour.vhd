library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of clearing_alg is

	type clearing_alg_state is (covered, flag_state, mine_state, number_state, game_over_state, unflag_state, wait_until, reset, default);

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

	process(state, new_state, controller_in, pos)
	begin

	cursor_out <= pos;

		case state is
			when reset => 
				cover_out <= '1';     
				flag_out <= '0';
				game_over <= '0';

				new_state <= default;		
			
			when default =>
				if (cover_in = '1' and controller_in = "100") then
					if (calc_ready = '0') then
						new_state <= wait_until;
					else
						new_state <= covered;	
					end if;

				elsif (controller_in = "101" and flag_in = '0') then				--flag covered cell
					new_state <= flag_state;
				elsif (controller_in = "101" and flag_in = '1') then				--unflag flagged cell
					new_state <= unflag_state;
				else
					new_state <= covered;
				end if;		


			when wait_until =>
				if (calc_ready = '1') then
					if (mine_ready = '1') then
						if (mine_in = '1') then
							new_state <= mine_state;
						elsif (mine_in = '0') then
							new_state <= number_state;
						else
							new_state <= covered;							
						end if;
					else
						new_state <= wait_until;
					end if;
				else 
					new_state <= wait_until;
				end if;

			when covered =>
				cover_out <= '1';     
				flag_out <= '0';
				game_over <= '0';
				
				if (cover_in = '1' and controller_in = "100") then
					if (calc_ready = '0') then
						new_state <= wait_until;
					else
						new_state <= covered;	
					end if;

				elsif (controller_in = "101" and flag_in = '0') then				--flag covered cell
					new_state <= flag_state;
				elsif (controller_in = "101" and flag_in = '1') then				--unflag flagged cell
					new_state <= unflag_state;
				else
					new_state <= covered;
				end if;

			when flag_state =>
				cover_out <= '1';
				flag_out <= '1';
				game_over <= '0';
				cursor_out <= cursor_in;
			when unflag_state =>
				cover_out <= '1';
				flag_out <= '0';
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

