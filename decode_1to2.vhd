library ieee;
use ieee.std_logic_1164.all;

entity decode_1to2 is 
	port( w  : in  std_logic;
	      en : in  std_logic;
	      y  : out  std_logic_vector(1 downto 0) );
end entity decode_1to2;

architecture dataflow of decode_1to2 is 
begin
   y(0) <= en and not(w);
   y(1) <= en and w;
end architecture dataflow;
