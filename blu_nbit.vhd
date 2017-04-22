library ieee;
use ieee.std_logic_1164.all;

entity blu_nbit is 
	generic( SIZE : positive := 4 );
	port( x, y : in  std_logic_vector(SIZE-1 downto 0);
	      blu_sel : in std_logic_vector(1 downto 0);
	      f : out  std_logic_vector(SIZE-1 downto 0) );
end entity blu_nbit;

architecture behavior of blu_nbit is  
begin
	with blu_sel select
		f <= x and y when "00",
			 x or y  when "01",
			 x xor y when "10",
			 x nor y when others;
end architecture behavior;
