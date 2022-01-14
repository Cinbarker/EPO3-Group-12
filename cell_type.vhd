 library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

-- this entity decides what type each cell will be
entity cell_assignment is
  port (	
    clk	: in	std_logic;
		reset	: in 	std_logic;
		
		is_mine: in std_logic;    -- whether the cell is a mine
		mine_ready: in std_logic; -- whether the mine state is ready to be read
		
		num_ready: in std_logic; -- whether the number is ready to be read
		mine_num: in	std_logic_vector(3 downto 0);     -- how many adjacent mines there are to a cell
		
		mem_in: in std_logic;     -- whether the cell is or isn't flagged / covered
		mem_write: out std_logic; -- control whether to write to memory or not
		mem_cofl: out std_logic;  -- choose either covered (0) or flag (1) memory
		
		hor_pos	: in	std_logic_vector(9 downto 0);        -- h index what pixel is currently being written by vga
		ver_pos	: in	std_logic_vector(9 downto 0);        -- v index what pixel is currently being written by vga
		
		win_over : out std_logic;  -- 1 if the game is over and the player won, else 0
		lose_over: out std_logic; -- 1 if the game is over and the player lost, else 0
		
		pos: out	std_logic_vector(7 downto 0);  -- Output to ??????????????
		cell_type_out: out std_logic_vector(3 downto 0)	-- Calculated cell type
		);
end entity;
