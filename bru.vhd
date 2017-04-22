-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 3
-- Task:  Task 1
-- File: bru.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity bru is 
  generic( SIZE : positive := 4 );
	port( A    : in   std_logic_vector(SIZE-1 downto 0);
	      rev  : in   std_logic;
	      Y    : out  std_logic_vector(SIZE-1 downto 0));
end entity bru;

architecture behavior of bru is 

  signal reversed :  std_logic_vector(SIZE-1 downto 0);
  constant HIGH        :  std_logic := '1';
  
begin
  
  --this loop counts down from SIZE-1 down to 0, and
  --sets the value at reversed(current index value) to
  --A(SIZE-1-current index value).  EG, when SIZE=4 and
  --i=1, reversed(1) will be set to A(2)
  
  bit_reverse: for i in SIZE-1 downto 0 generate
    reversed(i) <= A((SIZE-1)-i);
  end generate;
  
  --this cssa sets the output to reversed when rev is high.
  
  with rev select
    Y <= reversed when HIGH,
         A when others;

end architecture behavior;


