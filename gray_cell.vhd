library ieee;
use ieee.std_logic_1164.all;

entity gray_cell is
	port( g_hi, a_hi : in  std_logic;   --hi group generate/alive
	      g_lo       : in  std_logic;   --lo group generate/alive
		  g_grp      : out std_logic ); --new group alive
end entity gray_cell;

architecture dataflow of gray_cell is
begin
	g_grp <= g_hi or (a_hi and g_lo); 
end architecture dataflow;
