library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour of mem_control is
	type memctrl_state is (off,passbld,passca,passclr);
	signal state,new_state:memctrl_state;
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

	ctrl:process(state,new_state,hor_in,ver_in,calc_ready)
	begin
		case state is
			when off=>
				write_out<='0';
				cofl_out<='0';
				data_out<='0';
				adr_out<="00000000";
				clr_stop<='0';
				new_state<=passbld;
			when passbld=>
				write_out<=write_in_bld;
				cofl_out<=cofl_in_bld;
				adr_out<=adr_in_bld;
				clr_stop<='0';
				data_out<=data_in_bld;
				if unsigned(hor_in)>to_unsigned(100,10) and unsigned(ver_in)=to_unsigned(49,10) then		--after front porch
					new_state<=passca;
				elsif unsigned(hor_in)>to_unsigned(512,10) then
					new_state<=passclr;
				else
					new_state<=passbld;
				end if;
			when passca=>
				write_out<=write_in_ca;
				cofl_out<=cofl_in_ca;
				adr_out<=adr_in_ca;
				clr_stop<='0';
				data_out<=data_in_ca;
				if unsigned(hor_in)>to_unsigned(100,10) and unsigned(hor_in)<to_unsigned(513,10) then
					new_state<=passca;
				elsif unsigned(ver_in)=to_unsigned(48,10) or unsigned(ver_in)=to_unsigned(72,10) or unsigned(ver_in)=to_unsigned(96,10) or unsigned(ver_in)=to_unsigned(120,10) or unsigned(ver_in)=to_unsigned(144,10) or unsigned(ver_in)=to_unsigned(168,10) or unsigned(ver_in)=to_unsigned(192,10) or unsigned(ver_in)=to_unsigned(216,10) or unsigned(ver_in)=to_unsigned(240,10) or unsigned(ver_in)=to_unsigned(264,10) or unsigned(ver_in)=to_unsigned(288,10) or unsigned(ver_in)=to_unsigned(312,10) or unsigned(ver_in)=to_unsigned(334,10) or unsigned(ver_in)=to_unsigned(360,10) or unsigned(ver_in)=to_unsigned(384,10) or unsigned(ver_in)=to_unsigned(408,10) or unsigned(ver_in)=to_unsigned(432,10) then
					new_state<=passbld;
				else
					new_state<=passclr;
				end if;
			when passclr=>
				write_out<=write_in_clr;
				cofl_out<=cofl_in_clr;
				adr_out<=adr_in_clr;
				data_out<=data_in_clr;
				if unsigned(hor_in)=to_unsigned(101,10) then
					new_state<=passca;
					clr_stop<='1';
				else
					new_state<=passclr;
					clr_stop<='0';
				end if;
		end case;
	end process;
end behaviour;

