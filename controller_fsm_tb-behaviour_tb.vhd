library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

architecture behaviour_tb of controller_fsm_tb is
   component controller_fsm
      port(clk      : in  std_logic;
           reset    : in  std_logic;
           pin1     : in  std_logic;
           pin2     : in  std_logic;
           pin3     : in  std_logic;
           pin4     : in  std_logic;
           pin6     : in  std_logic;
           pin9     : in  std_logic;
	   count_in	: in std_logic_vector(9 downto 0);
           line_out : out std_logic_vector(2 downto 0));
   end component;
   signal clk      : std_logic;
   signal reset    : std_logic;
   signal pin1     : std_logic;
   signal pin2     : std_logic;
   signal pin3     : std_logic;
   signal pin4     : std_logic;
   signal pin6     : std_logic;
   signal pin9     : std_logic;
   signal count_in	: std_logic_vector(9 downto 0);
   signal line_out : std_logic_vector(2 downto 0);
begin
   test: controller_fsm port map (clk, reset, pin1, pin2, pin3, pin4, pin6, pin9, count_in, line_out);
   clk <= '0' after 0 ns,
          '1' after 10 ns when clk /= '1' else '0' after 20 ns;
   reset <= '1' after 0 ns,
            '0' after 5 us;

--pin1 <= '1' after 0 ns, '0' after 10 ms,  '1' after 10.1 ms, '0' after 10.2 ms, '1' after 10.3 ms, '0' after 10.4 ms, '1' after 10.5 ms, '0' after 10.6 ms;--, '1' after 11 ms;
pin6 <= '1' after 0 ns, '0' after 10 ms,  '1' after 10.1 ms, '0' after 10.2 ms, '1' after 10.3 ms, '0' after 10.4 ms, '1' after 10.5 ms, '0' after 10.6 ms, '1' after 120 ms, '0' after 121 ms, '1' after 122 ms, '0' after 123 ms, '1' after 124 ms, '0' after 125 ms, '1' after 126 ms, '0' after 127 ms, '1' after 128 ms;--, '1' after 11 ms;
pin9 <= '1' after 0 ns, '0' after 50 ms,  '1' after 50.1 ms, '0' after 50.2 ms, '1' after 50.3 ms, '0' after 50.4 ms, '1' after 50.5 ms, '0' after 50.6 ms, '1' after 100 ms, '0' after 101 ms, '1' after 102 ms, '0' after 103 ms, '1' after 104 ms, '0' after 105 ms, '1' after 106 ms, '0' after 107 ms, '1' after 108 ms;--, '1' after 11 ms;

pin1 <= '1' after 0 ns;--, '0' after 160 ns, '1' after 200 ns;
pin2 <= '1' after 0 ns;--, '0' after 160 ns, '1' after 200 ns;

pin3 <= '1' after 0 ns;--, '0' after 160 ns, '1' after 200 ns;
pin4 <= '1' after 0 ns;--, '0' after 220 ns, '1' after 260 ns;
process
begin
wait for 10 ns;
	if reset = '1' then
		count_in <= (others => '0');
	elsif unsigned(count_in) < to_unsigned(525,10) then
		count_in <= std_logic_vector(unsigned(count_in)+1);
		wait for 32 us;
	else
		count_in <= (others => '0');
	end if;
end process;


end behaviour_tb;

