library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behavioural of cell_assignment is
type cell_assignment_state is (reset_state, cell_wait, req_cover, read_cover, req_flag, read_flag, req_mine_num, read_mine_num);
signal state, new_state: cell_assignment_state;
type bitmap is (covered, one, two, three, four, five, six, seven, eight, empty, mine, flag);
signal cell_type, new_cell_type: bitmap;

signal cell_count, begin_count: unsigned(7 downto 0):="11111111";
signal hor_p, ver_p: unsigned(9 downto 0);

begin
hor_p <= unsigned(hor_pos);
ver_p <= unsigned(ver_pos);
cell_type_out <= 	"0000" when cell_type = covered else
						"0001" when cell_type = one else
						"0010" when cell_type = two else
						"0011" when cell_type = three else
						"0100" when cell_type = four else
						"0101" when cell_type = five else
						"0110" when cell_type = six else
						"0111" when cell_type = seven else
						"1000" when cell_type = eight else
						"1001" when cell_type = empty else
						"1010" when cell_type = mine else
						"1011" when cell_type = flag else
						"0000";
process(clk)
begin
  if(clk'event and clk='1') then
    if reset = '1' then
      state <= reset_state;
      cell_type <= covered;
    else
      state <= new_state;
    end if;
    
    if state = req_cover then
      cell_type <= new_cell_type;
    else
      null;
    end if;
  end if;
end process;

process(state, new_state, hor_p, mem_in, mine_ready, num_ready, cell_count, is_mine, mine_num)
begin
  case state is
    when reset_state =>
      win_over <= '0';
      lose_over <= '0';
      new_state <= cell_wait;
    
    when cell_wait =>
      if hor_p = 103 or hor_p = 127 or hor_p = 151 or hor_p = 175 or hor_p = 199 or hor_p = 223 or hor_p = 247 or hor_p = 271 or hor_p = 295 or hor_p = 319 or hor_p = 343 or hor_p = 367 or hor_p = 391 or hor_p = 415 or hor_p = 439 or hor_p = 463 or hor_p = 487 then 
        new_state <= req_cover;
      else
        new_state <= cell_wait;
      end if;   
      
    when req_cover =>
      mem_write <= '0';
      mem_cofl <= '0';
      pos <= std_logic_vector(cell_count);
      new_state <= read_cover;
      
    when read_cover =>
      if mem_in = '0' then
        new_state <= req_mine_num;
      elsif mem_in = '1' then
        new_state <= req_flag;
      else 
        new_state <= read_cover;
      end if;
      
    when req_flag =>
      mem_write <= '0';
      mem_cofl <= '1';
      pos <= std_logic_vector(cell_count);
      new_state <= read_flag;
      
    when read_flag =>
      if mem_in = '0' then
        new_cell_type <= covered;
        new_state <= cell_wait;
      elsif mem_in = '1' then
        new_cell_type <= flag;
        new_state <= cell_wait;
      else 
        new_state <= read_flag;
      end if;
        
    when req_mine_num =>
      pos <= std_logic_vector(cell_count mod 16);
      new_state <= req_mine_num;				--1 clock cycle between request and read. Is this enough???
      
    when read_mine_num =>
      if is_mine = '1' and mine_num = "0000" then 
	     new_cell_type <= mine;
	     lose_over <= '1';
      elsif  mine_num = "0000" and is_mine = '0' then new_cell_type <= empty;
      elsif  mine_num = "0001" and is_mine = '0' then new_cell_type <= one;
      elsif  mine_num = "0010" and is_mine = '0' then new_cell_type <= two;
      elsif  mine_num = "0011" and is_mine = '0' then new_cell_type <= three;
      elsif  mine_num = "0100" and is_mine = '0' then new_cell_type <= four;
      elsif  mine_num = "0101" and is_mine = '0' then new_cell_type <= five;
      elsif  mine_num = "0110" and is_mine = '0' then new_cell_type <= six;
      elsif  mine_num = "0111" and is_mine = '0' then new_cell_type <= seven;
      elsif  mine_num = "1000" and is_mine = '0' then new_cell_type <= eight;
      else   new_cell_type <= empty;
      end if;
      new_state <= cell_wait;
      
  end case;
end process;  

process(clk, ver_p, hor_p, begin_count, state, cell_count)
begin
  if(clk'event and clk='1') then 
    if hor_p = 103 or hor_p = 127 or hor_p = 151 or hor_p = 175 or hor_p = 199 or hor_p = 223 or hor_p = 247 or hor_p = 295 or hor_p = 319 or hor_p = 343 or hor_p = 367 or hor_p = 391 or hor_p = 415 or hor_p = 439 or hor_p = 463 or hor_p = 487 then 
      cell_count <= cell_count + 1;
    else null;
    end if;   
    
    if    ver_p < 49  then begin_count <= "00000000";
    elsif ver_p = 73  then begin_count <= "00010000";
    elsif ver_p = 97  then begin_count <= "00100000";
    elsif ver_p = 121 then begin_count <= "00110000";
    elsif ver_p = 145 then begin_count <= "01000000";
    elsif ver_p = 169 then begin_count <= "01010000";
    elsif ver_p = 193 then begin_count <= "01100000";
    elsif ver_p = 217 then begin_count <= "01110000";
    elsif ver_p = 241 then begin_count <= "10000000";
    elsif ver_p = 265 then begin_count <= "10010000";
    elsif ver_p = 289 then begin_count <= "10100000";
    elsif ver_p = 313 then begin_count <= "10110000";
    elsif ver_p = 337 then begin_count <= "11000000";
    elsif ver_p = 361 then begin_count <= "11010000";
    elsif ver_p = 385 then begin_count <= "11100000";
    elsif ver_p = 409 then begin_count <= "11110000";
    else null;
    end if;
    if reset /= '1' then
      if hor_p < 104 then 
        cell_count <= begin_count;
      else 
        null;
      end if;
    else 
      cell_count <= "11111111";
      begin_count <= "00000000";
  end if;
  else 
    null;
  end if;
  end process;
end architecture; 

