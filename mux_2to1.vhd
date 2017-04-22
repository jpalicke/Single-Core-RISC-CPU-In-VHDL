library ieee;
use ieee.std_logic_1164.all;

entity mux_2to1 is 
	generic( SIZE : positive := 4 );
	port( w0 : in  std_logic_vector(SIZE-1 downto 0);
	      w1 : in  std_logic_vector(SIZE-1 downto 0);
	      s  : in  std_logic;
	      f  : out std_logic_vector(SIZE-1 downto 0) );
end entity mux_2to1;

architecture dataflow of mux_2to1 is 
begin
   the_muxes : 
   for i in SIZE-1 downto 0 generate
		f(i) <= (not(s) and w0(i)) or (s and w1(i));
   end generate the_muxes;
end architecture dataflow;
