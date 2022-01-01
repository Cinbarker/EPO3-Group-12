library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

architecture behaviour of adjacent_mines is
	type c_state is (start_state,req_mine1,req_mine2,read_mine1,read_mine2,calcnr,read_nr,output_nr,shift_row1,shift_row2,clear_row);
	signal state,new_state:c_state;
	signal mines_row1,new_mines_row1,mines_row2,new_mines_row2,mines_row3,new_mines_row3:std_logic_vector(15 downto 0);
	signal cellpos,new_cellpos:unsigned(7 downto 0);
	signal a:unsigned(3 downto 0);
	signal nr0,nr1,nr2,nr3,nr4,nr5,nr6,nr7,nr8,nr9,nr10,nr11,nr12,nr13,nr14,nr15:std_logic_vector(3 downto 0);
	signal new_nr0,new_nr1,new_nr2,new_nr3,new_nr4,new_nr5,new_nr6,new_nr7,new_nr8,new_nr9,new_nr10,new_nr11,new_nr12,new_nr13,new_nr14,new_nr15:std_logic_vector(3 downto 0);
	signal rowcnt1,new_rowcnt1:unsigned(7 downto 0);
begin
	rst:process(clk)
	begin
		if(clk'event and clk='1') then					
			if reset='1' then
				state<=start_state;
				cellpos<="00000000";
				rowcnt1<="00000000";
				mines_row1<=std_logic_vector(to_unsigned(0,16));
				mines_row2<=std_logic_vector(to_unsigned(0,16));
				mines_row3<=std_logic_vector(to_unsigned(0,16));
				nr0<="0000";
				nr1<="0000";
				nr2<="0000";
				nr3<="0000";
				nr4<="0000";
				nr5<="0000";
				nr6<="0000";
				nr7<="0000";
				nr8<="0000";
				nr9<="0000";
				nr10<="0000";
				nr11<="0000";
				nr12<="0000";
				nr13<="0000";
				nr14<="0000";
				nr15<="0000";
			else
				state<=new_state;
				cellpos<=new_cellpos;
				rowcnt1<=new_rowcnt1;
				mines_row1<=new_mines_row1;
				mines_row2<=new_mines_row2;
				mines_row3<=new_mines_row3;
				nr0<=new_nr0;
				nr1<=new_nr2;
				nr2<=new_nr2;
				nr3<=new_nr3;
				nr4<=new_nr4;
				nr5<=new_nr5;
				nr6<=new_nr6;
				nr7<=new_nr7;
				nr8<=new_nr8;
				nr9<=new_nr9;
				nr10<=new_nr10;
				nr11<=new_nr11;
				nr12<=new_nr12;
				nr13<=new_nr13;
				nr14<=new_nr14;
				nr15<=new_nr15;
			end if;
		end if;
	end process;
	
	sc:process(state,new_state,start,pos_in,mine_ready,next_row)
	begin
		case state is
			when start_state=>
				new_cellpos<=to_unsigned(0,8);
				nr_out<="0000";
				nr_out_ready<='0';
				row_ready<='0';
				a<="0000";
				new_rowcnt1<="00000000";
				new_mines_row1<=std_logic_vector(to_unsigned(0,16));
				new_mines_row2<=std_logic_vector(to_unsigned(0,16));
				new_mines_row3<=std_logic_vector(to_unsigned(0,16));
				new_nr0<="0000";
				new_nr1<="0000";
				new_nr2<="0000";
				new_nr3<="0000";
				new_nr4<="0000";
				new_nr5<="0000";
				new_nr6<="0000";
				new_nr7<="0000";
				new_nr8<="0000";
				new_nr9<="0000";
				new_nr10<="0000";
				new_nr11<="0000";
				new_nr12<="0000";
				new_nr13<="0000";
				new_nr14<="0000";
				new_nr15<="0000";
				if start='1' then
					new_state<=req_mine1;
				else
					new_state<=start_state;
				end if;
			when req_mine1=>				--request mines for row 2
				new_rowcnt1<=rowcnt1;
				new_cellpos<=cellpos;
				row_ready<='0';
				nr_out_ready<='0';
				pos_out<=std_logic_vector(cellpos);
				new_state<=read_mine1;
				a<=to_unsigned(to_integer(unsigned(cellpos)) mod 16 ,4);
			when read_mine1=>						--read mines for row 2
				row_ready<='0';
				nr_out_ready<='0';
				if mine_ready='1' and to_integer(a)=15 then
					new_mines_row3(to_integer(a))<= mine_in;
					new_cellpos<=cellpos + to_unsigned(1,8);
					new_state<=shift_row1;
				elsif mine_ready='1' and to_integer(a)/=15 then
					new_mines_row3(to_integer(a))<= mine_in;
					new_cellpos<=cellpos + to_unsigned(1,8);
					new_state<=req_mine1;
				else
					new_cellpos<=cellpos;
					new_state<=read_mine1;
				end if;
			when req_mine2=>				--request mines for row 3
				new_rowcnt1<=rowcnt1;
				new_cellpos<=cellpos;
				row_ready<='0';
				nr_out_ready<='0';
				pos_out<=std_logic_vector(cellpos);
				new_state<=read_mine2;
				a<=to_unsigned(to_integer(unsigned(cellpos)) mod 16 ,4);
			when read_mine2=>							--read mines for row 3
				row_ready<='0';
				nr_out_ready<='0';
				if mine_ready='1' and to_integer(a)=15 then
					new_mines_row3(to_integer(a))<= mine_in;
					new_cellpos<=cellpos + to_unsigned(1,8);
					new_state<=calcnr;
				elsif mine_ready='1' and to_integer(a)/=15 then
					new_mines_row3(to_integer(a))<= mine_in;
					new_cellpos<=cellpos + to_unsigned(1,8);
					new_state<=req_mine2;
				else
					new_cellpos<=cellpos;
					new_state<=read_mine2;
				end if;
			when calcnr=>
				new_rowcnt1<=rowcnt1;
				new_cellpos<=cellpos;
				row_ready<='1';
				nr_out_ready<='0';
				new_nr0<= ( 				     ("000"&mines_row1(0))  + ("000"&mines_row1(1))  +										("000"&mines_row2(1))  + 						  ("000"&mines_row3(0))  + ("000"&mines_row3(1))  );
				new_nr1<= ( ("000"&mines_row1(0))  + ("000"&mines_row1(1))  + ("000"&mines_row1(2))  + ("000"&mines_row2(0))  + ("000"&mines_row2(2))  + ("000"&mines_row3(0))  + ("000"&mines_row3(1))  + ("000"&mines_row3(2))  );
				new_nr2<= ( ("000"&mines_row1(1))  + ("000"&mines_row1(2))  + ("000"&mines_row1(3))  + ("000"&mines_row2(1))  + ("000"&mines_row2(3))  + ("000"&mines_row3(1))  + ("000"&mines_row3(2))  + ("000"&mines_row3(3))  );
				new_nr3<= ( ("000"&mines_row1(2))  + ("000"&mines_row1(3))  + ("000"&mines_row1(4))  + ("000"&mines_row2(2))  + ("000"&mines_row2(4))  + ("000"&mines_row3(2))  + ("000"&mines_row3(3))  + ("000"&mines_row3(4))  );
				new_nr4<= ( ("000"&mines_row1(3))  + ("000"&mines_row1(4))  + ("000"&mines_row1(5))  + ("000"&mines_row2(3))  + ("000"&mines_row2(5))  + ("000"&mines_row3(3))  + ("000"&mines_row3(4))  + ("000"&mines_row3(5))  );
				new_nr5<= ( ("000"&mines_row1(4))  + ("000"&mines_row1(5))  + ("000"&mines_row1(6))  + ("000"&mines_row2(4))  + ("000"&mines_row2(6))  + ("000"&mines_row3(4))  + ("000"&mines_row3(5))  + ("000"&mines_row3(6))  );
				new_nr6<= ( ("000"&mines_row1(5))  + ("000"&mines_row1(6))  + ("000"&mines_row1(7))  + ("000"&mines_row2(5))  + ("000"&mines_row2(7))  + ("000"&mines_row3(5))  + ("000"&mines_row3(6))  + ("000"&mines_row3(7))  );
				new_nr7<= ( ("000"&mines_row1(6))  + ("000"&mines_row1(7))  + ("000"&mines_row1(8))  + ("000"&mines_row2(6))  + ("000"&mines_row2(8))  + ("000"&mines_row3(6))  + ("000"&mines_row3(7))  + ("000"&mines_row3(8))  );
				new_nr8<= ( ("000"&mines_row1(7))  + ("000"&mines_row1(8))  + ("000"&mines_row1(9))  + ("000"&mines_row2(7))  + ("000"&mines_row2(9))  + ("000"&mines_row3(7))  + ("000"&mines_row3(8))  + ("000"&mines_row3(9))  );
				new_nr9<= ( ("000"&mines_row1(8))  + ("000"&mines_row1(9))  + ("000"&mines_row1(10)) + ("000"&mines_row2(8))  + ("000"&mines_row2(10)) + ("000"&mines_row3(8))  + ("000"&mines_row3(9))  + ("000"&mines_row3(10)) );
				new_nr10<=( ("000"&mines_row1(9))  + ("000"&mines_row1(10)) + ("000"&mines_row1(11)) + ("000"&mines_row2(9))  + ("000"&mines_row2(11)) + ("000"&mines_row3(9))  + ("000"&mines_row3(10)) + ("000"&mines_row3(11)) );
				new_nr11<=( ("000"&mines_row1(10)) + ("000"&mines_row1(11)) + ("000"&mines_row1(12)) + ("000"&mines_row2(10)) + ("000"&mines_row2(12)) + ("000"&mines_row3(10)) + ("000"&mines_row3(11)) + ("000"&mines_row3(12)) );
				new_nr12<=( ("000"&mines_row1(11)) + ("000"&mines_row1(12)) + ("000"&mines_row1(13)) + ("000"&mines_row2(11)) + ("000"&mines_row2(13)) + ("000"&mines_row3(11)) + ("000"&mines_row3(12)) + ("000"&mines_row3(13)) );
				new_nr13<=( ("000"&mines_row1(12)) + ("000"&mines_row1(13)) + ("000"&mines_row1(14)) + ("000"&mines_row2(12)) + ("000"&mines_row2(14)) + ("000"&mines_row3(12)) + ("000"&mines_row3(13)) + ("000"&mines_row3(14)) );
				new_nr14<=( ("000"&mines_row1(13)) + ("000"&mines_row1(14)) + ("000"&mines_row1(15)) + ("000"&mines_row2(13)) + ("000"&mines_row2(15)) + ("000"&mines_row3(13)) + ("000"&mines_row3(14)) + ("000"&mines_row3(15)) );
				new_nr15<=( ("000"&mines_row1(14)) + ("000"&mines_row1(15)) + 										       ("000"&mines_row2(14)) + 							 ("000"&mines_row3(14)) + ("000"&mines_row3(15)) 									  );
				new_state<=read_nr;
			when read_nr=>					--output requested number
				new_rowcnt1<=rowcnt1;
				new_cellpos<=cellpos;
				row_ready<='1';
				nr_out_ready<='0';
				if next_row='1' then
					new_state<=shift_row1;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 0 then
					nr_out<=nr0;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 1 then
					nr_out<=nr1;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 2 then
					nr_out<=nr2;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 3 then
					nr_out<=nr3;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 4 then
					nr_out<=nr4;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 5 then
					nr_out<=nr5;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 6 then
					nr_out<=nr6;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 7 then
					nr_out<=nr7;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 8 then
					nr_out<=nr8;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 9 then
					nr_out<=nr9;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 10 then
					nr_out<=nr10;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 11 then
					nr_out<=nr11;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 12 then
					nr_out<=nr12;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 13 then
					nr_out<=nr13;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 14 then
					nr_out<=nr14;
					new_state<=output_nr;
				elsif (to_integer(unsigned(pos_in)) mod 16) = 15 then
					nr_out<=nr15;
					new_state<=output_nr;
				else
					new_state<=read_nr;
				end if;
				new_nr0<=nr0;
				new_nr1<=nr1;
				new_nr2<=nr2;
				new_nr3<=nr3;
				new_nr4<=nr4;
				new_nr5<=nr5;
				new_nr6<=nr6;
				new_nr7<=nr7;
				new_nr8<=nr8;
				new_nr9<=nr9;
				new_nr10<=nr10;
				new_nr11<=nr11;
				new_nr12<=nr12;
				new_nr13<=nr13;
				new_nr14<=nr14;
				new_nr15<=nr15;
			when output_nr=>
				new_rowcnt1<=rowcnt1;
				new_cellpos<=cellpos;
				row_ready<='1';
				nr_out_ready<='1';
				new_nr0<=nr0;
				new_nr1<=nr1;
				new_nr2<=nr2;
				new_nr3<=nr3;
				new_nr4<=nr4;
				new_nr5<=nr5;
				new_nr6<=nr6;
				new_nr7<=nr7;
				new_nr8<=nr8;
				new_nr9<=nr9;
				new_nr10<=nr10;
				new_nr11<=nr11;
				new_nr12<=nr12;
				new_nr13<=nr13;
				new_nr14<=nr14;
				new_nr15<=nr15;
				if next_row='1' then
					new_state<=shift_row1;
				else
					new_state<=read_nr;
				end if;
			when shift_row1=>				--shift row 2 to row 1
				new_cellpos<=cellpos;
				row_ready<='0';
				nr_out_ready<='0';
				new_mines_row1<=mines_row2;
				new_state<=shift_row2;
			when shift_row2=>				--shift row 3 to row 2
				new_cellpos<=cellpos;
				row_ready<='0';
				nr_out_ready<='0';
				new_mines_row2<=mines_row3;
				new_state<=clear_row;
			when clear_row=>				--clear row 3
				new_rowcnt1<=rowcnt1+to_unsigned(1,8);
				new_cellpos<=cellpos;
				row_ready<='0';
				nr_out_ready<='0';
				new_mines_row3<=std_logic_vector(to_unsigned(0,16));
				new_state<=req_mine2;
		end case;
	end process;
end behaviour;

