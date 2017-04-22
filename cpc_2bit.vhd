-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 4
-- Task:  Task 1
-- File: cpc_2bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cpc_2bit is 
  generic( SIGNED_OPS   : boolean := FALSE );
	port( x, y        : in   std_logic_vector(1 downto 0);
	      zG, zS, zE  : out   std_logic);
end entity cpc_2bit;

architecture dataflow of cpc_2bit is 
  signal E1, E0, S1, S0, G1, G0   : std_logic;

begin
  
  E1 <= x(1) xnor y(1);
  E0 <= x(0) xnor y(0);
  S0 <= (not x(0)) and y(0);
  G0 <= x(0) and (not y(0));
  zG <= G1 or (E1 and G0);
  zS <= S1 or (E1 and S0);
  zE <= E1 and E0;
  
  signed: if SIGNED_OPS = TRUE generate
      S1 <= x(1) and (not y(1));
      G1 <= (not x(1)) and y(1);
  end generate signed;
  unsigned: if SIGNED_OPS = FALSE generate
      S1 <= (not x(1)) and y(1);
      G1 <= (x(1) and (not y(1)));
  end generate unsigned; 
  
end architecture dataflow;



