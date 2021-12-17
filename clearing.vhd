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
-- CREATED		"Fri Dec 17 10:18:31 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY clearing IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		pin1 :  IN  STD_LOGIC;
		pin2 :  IN  STD_LOGIC;
		pin3 :  IN  STD_LOGIC;
		pin4 :  IN  STD_LOGIC;
		pin6 :  IN  STD_LOGIC;
		pin7 :  IN  STD_LOGIC;
		pin9 :  IN  STD_LOGIC;
		cover_in :  IN  STD_LOGIC;
		flag_in :  IN  STD_LOGIC;
		mine_in :  IN  STD_LOGIC;
		number_in :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		cover_out :  OUT  STD_LOGIC;
		flag_out :  OUT  STD_LOGIC;
		game_over :  OUT  STD_LOGIC;
		start :  OUT  STD_LOGIC;
		cursor_out :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END clearing;

ARCHITECTURE bdf_type OF clearing IS 

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
		 pin7 : IN STD_LOGIC;
		 pin9 : IN STD_LOGIC;
		 line_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

COMPONENT clearing_alg
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 cover_in : IN STD_LOGIC;
		 flag_in : IN STD_LOGIC;
		 mine_in : IN STD_LOGIC;
		 controller_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 cursor_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 number_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 cover_out : OUT STD_LOGIC;
		 flag_out : OUT STD_LOGIC;
		 game_over : OUT STD_LOGIC;
		 cursor_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT startconverter
	PORT(controller_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 start : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN 



b2v_inst : movement
PORT MAP(clk => clk,
		 reset => reset,
		 controller_in => SYNTHESIZED_WIRE_4,
		 address_out => SYNTHESIZED_WIRE_2);


b2v_inst1 : controller_fsm
PORT MAP(clk => clk,
		 reset => reset,
		 pin1 => pin1,
		 pin2 => pin2,
		 pin3 => pin3,
		 pin4 => pin4,
		 pin6 => pin6,
		 pin7 => pin7,
		 pin9 => pin9,
		 line_out => SYNTHESIZED_WIRE_4);


b2v_inst3 : clearing_alg
PORT MAP(clk => clk,
		 reset => reset,
		 cover_in => cover_in,
		 flag_in => flag_in,
		 mine_in => mine_in,
		 controller_in => SYNTHESIZED_WIRE_4,
		 cursor_in => SYNTHESIZED_WIRE_2,
		 number_in => number_in,
		 cover_out => cover_out,
		 flag_out => flag_out,
		 game_over => game_over,
		 cursor_out => cursor_out);


b2v_inst4 : startconverter
PORT MAP(controller_in => SYNTHESIZED_WIRE_4,
		 start => start);


END bdf_type;