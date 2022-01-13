-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 32-bit"
-- VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Full Version"
-- CREATED		"Thu Jan 13 15:57:18 2022"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY clearing_top IS 
	PORT
	( clk :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		pin1 :  IN  STD_LOGIC;
		pin2 :  IN  STD_LOGIC;
		pin3 :  IN  STD_LOGIC;
		pin4 :  IN  STD_LOGIC;
		pin6 :  IN  STD_LOGIC;
		pin9 :  IN  STD_LOGIC;
		mine_ready :  IN  STD_LOGIC;
		calc_ready :  IN  STD_LOGIC;
		mem_in :  IN  STD_LOGIC;
		mine_in :  IN  STD_LOGIC;
		start8 :  IN  STD_LOGIC;
		stop :  IN  STD_LOGIC;
		count_ready :  IN  STD_LOGIC;
		count_in :  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		mine_count :  IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		number_in :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		write :  OUT  STD_LOGIC;
		cofl :  OUT  STD_LOGIC;
		cover_out :  OUT  STD_LOGIC;
		flag_out :  OUT  STD_LOGIC;
		game_over :  OUT  STD_LOGIC;
		win_over :  OUT  STD_LOGIC;
		start1 :  OUT  STD_LOGIC;
		cursor_out :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		flags_left :  OUT  STD_LOGIC_VECTOR(5 DOWNTO 0);
		number_out :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END clearing_top;

ARCHITECTURE bdf_type OF clearing_top IS 

COMPONENT clearing3
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 mine_ready : IN STD_LOGIC;
		 calc_ready : IN STD_LOGIC;
		 mem_in : IN STD_LOGIC;
		 mine_in : IN STD_LOGIC;
		 start : IN STD_LOGIC;
		 stop : IN STD_LOGIC;
		 controller_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 cursor_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 number_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 write : OUT STD_LOGIC;
		 cofl : OUT STD_LOGIC;
		 cover_out : OUT STD_LOGIC;
		 flag_out : OUT STD_LOGIC;
		 pass : OUT STD_LOGIC;
		 game_over : OUT STD_LOGIC;
		 cursor_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 number_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT movement
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 controller_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 address_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT controller_fsm
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 pin1 : IN STD_LOGIC;
		 pin2 : IN STD_LOGIC;
		 pin3 : IN STD_LOGIC;
		 pin4 : IN STD_LOGIC;
		 pin6 : IN STD_LOGIC;
		 pin9 : IN STD_LOGIC;
		 count_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 line_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

COMPONENT cover_count
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 mem_in : IN STD_LOGIC;
		 cofl : IN STD_LOGIC;
		 write : IN STD_LOGIC;
		 count_ready : IN STD_LOGIC;
		 mine : IN STD_LOGIC;
		 mine_ready : IN STD_LOGIC;
		 mine_count : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 win_over : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT flagcount
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 mem_in : IN STD_LOGIC;
		 cofl : IN STD_LOGIC;
		 write : IN STD_LOGIC;
		 count_ready : IN STD_LOGIC;
		 mine_count : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 flags_left : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT;

COMPONENT startconverter
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 controller_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 start : OUT STD_LOGIC;
		 reset_out : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT c_buffer
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 pass : IN STD_LOGIC;
		 controller_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 controller_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;


BEGIN 
write <= SYNTHESIZED_WIRE_18;
cofl <= SYNTHESIZED_WIRE_17;



b2v_inst : clearing3
PORT MAP(clk => clk,
		 reset => SYNTHESIZED_WIRE_15,
		 mine_ready => mine_ready,
		 calc_ready => calc_ready,
		 mem_in => mem_in,
		 mine_in => mine_in,
		 start => start8,
		 stop => stop,
		 controller_in => SYNTHESIZED_WIRE_1,
		 cursor_in => SYNTHESIZED_WIRE_2,
		 number_in => number_in,
		 write => SYNTHESIZED_WIRE_18,
		 cofl => SYNTHESIZED_WIRE_17,
		 cover_out => cover_out,
		 flag_out => flag_out,
		 pass => SYNTHESIZED_WIRE_13,
		 game_over => game_over,
		 cursor_out => cursor_out,
		 number_out => number_out);


b2v_inst1 : movement
PORT MAP(clk => clk,
		 reset => SYNTHESIZED_WIRE_15,
		 controller_in => SYNTHESIZED_WIRE_16,
		 address_out => SYNTHESIZED_WIRE_2);


b2v_inst2 : controller_fsm
PORT MAP(clk => clk,
		 reset => reset,
		 pin1 => pin1,
		 pin2 => pin2,
		 pin3 => pin3,
		 pin4 => pin4,
		 pin6 => pin6,
		 pin9 => pin9,
		 count_in => count_in,
		 line_out => SYNTHESIZED_WIRE_16);


b2v_inst3 : cover_count
PORT MAP(clk => clk,
		 reset => SYNTHESIZED_WIRE_15,
		 mem_in => mem_in,
		 cofl => SYNTHESIZED_WIRE_17,
		 write => SYNTHESIZED_WIRE_18,
		 count_ready => count_ready,
		 mine => mine_in,
		 mine_ready => mine_ready,
		 mine_count => mine_count,
		 win_over => win_over);


b2v_inst4 : flagcount
PORT MAP(clk => clk,
		 reset => SYNTHESIZED_WIRE_15,
		 mem_in => mem_in,
		 cofl => SYNTHESIZED_WIRE_17,
		 write => SYNTHESIZED_WIRE_18,
		 count_ready => count_ready,
		 mine_count => mine_count,
		 flags_left => flags_left);


b2v_inst5 : startconverter
PORT MAP(clk => clk,
		 reset => reset,
		 controller_in => SYNTHESIZED_WIRE_16,
		 start => start1,
		 reset_out => SYNTHESIZED_WIRE_15);


b2v_inst9 : c_buffer
PORT MAP(clk => clk,
		 reset => SYNTHESIZED_WIRE_15,
		 pass => SYNTHESIZED_WIRE_13,
		 controller_in => SYNTHESIZED_WIRE_16,
		 controller_out => SYNTHESIZED_WIRE_1);


END bdf_type;
