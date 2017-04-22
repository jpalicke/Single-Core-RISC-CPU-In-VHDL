library ieee;
use ieee.std_logic_1164.all;

entity black_cell is
	port( g_hi, a_hi   : in  std_logic;   --hi group generate/alive
	      g_lo, a_lo   : in  std_logic;   --lo group generate/alive
		  g_grp        : out std_logic;   --new group generate
          a_grp        : out std_logic ); --new group alive
end entity black_cell;

architecture dataflow of black_cell is
begin
	g_grp <= g_hi or (a_hi and g_lo); 
	a_grp <= a_hi and a_lo;
end architecture dataflow;
