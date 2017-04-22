-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 4
-- Task:  Task 3
-- File: scu.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity scu is 
	port( NZV        : in   std_logic_vector(2 downto 0);
	      twos_cmp   : in   std_logic;
	      z_GSE      : out  std_logic_vector(2 downto 0));
end entity scu;

architecture mixed of scu is 
  
  signal signed, unsigned : std_logic_vector(2 downto 0);
  signal N : std_logic;
  signal Z : std_logic;
  signal V : std_logic;
  signal C : std_logic;
  constant THREE  : positive := 3;
  
begin
  
  multiplexer: entity work.mux_2to1(dataflow) generic map (SIZE => THREE)
    port map(w0 => unsigned, w1 => signed, s => twos_cmp, f => z_GSE);
  
  N <= NZV(2);
  Z <= NZV(1);
  V <= NZV(0);
  C <= (not twos_cmp) and NZV(0);
  --g
  unsigned(2) <= (not Z) and (not C);    
  --s
  unsigned(1) <= (not Z) and C;
  --e
  unsigned(0) <= Z;
  --g
  signed(2) <= ((not Z and not V) and not N) xor ((not Z) and (V and N));
  --s
  signed(1) <= (not Z) and (N xor V);
  --e
  signed(0) <= Z;
       
    
end architecture mixed;
