-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 3
-- Task:  Task 2
-- File: elu.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity elu is 
  generic( ISIZE : positive := 5;
           OSIZE : positive := 10);
	port( A         : in   std_logic_vector(ISIZE-1 downto 0);
	      twos_cmp  : in   std_logic;
	      Y         : out  std_logic_vector(OSIZE-1 downto 0));
end entity elu;

architecture dataflow of elu is 

  signal pad_bit  : std_logic;
  signal ext : std_logic_vector(OSIZE-ISIZE-1 downto 0);
    
begin
  
  -- checks for two's comp bit.  if doesn't exist
  -- pad bit is zero.  if it does, and the sign bit
  -- of a is 1, pad bit is 1.  otherwise it is zero.
  -- ext then becomes a vector the size of the difference
  -- between isize and osize, set to all pad bit.
  
  pad_bit <= A(ISIZE-1) and twos_cmp;
  ext <= (others => pad_bit);
  
  --takes the ext vector and puts it to the left of a
  --therefore extending the A to Y
  
  Y <= ext & A;
  

end architecture dataflow;




