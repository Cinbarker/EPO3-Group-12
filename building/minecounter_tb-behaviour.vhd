library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of minecounter_tb is
   component minecounter
      port(start      : in  std_logic;
           reset      : in  std_logic;
           clk        : in  std_logic;
           ready      : in  std_logic;
           mine       : in  std_logic;
   	last_cell  : in  std_logic;
           mine_count : out std_logic_vector(5 downto 0);
           count_ready: out std_logic);
   end component;
   signal start      : std_logic;
   signal reset      : std_logic;
   signal clk        : std_logic;
   signal ready      : std_logic;
   signal mine       : std_logic;
   signal last_cell  : std_logic;
   signal mine_count : std_logic_vector(5 downto 0);
   signal count_ready: std_logic;
begin
   test: minecounter port map (start, reset, clk, ready, mine, last_cell, mine_count, count_ready);
   start <= '0' after 0 ns,
'1' after 100 ns,
'0' after 200 ns;
   reset <= '1' after 0 ns,
            '0' after 80 ns;
   clk <= '0' after 0 ns,
          '1' after 20 ns when clk /= '1' else '0' after 20 ns;
   ready <= '0' after 0 ns,
'1' after 80 ns when ready /= '1' else '0' after 40 ns;
   mine <= '0' after 0 ns,
'1' after 400 ns,
'0' after 520 ns,
'1' after 600 ns,
'0' after 720 ns,
'1' after 1000 ns,
'0' after 1120 ns;
   last_cell <= '0' after 0 ns,
'1' after 800 ns;
end behaviour;

