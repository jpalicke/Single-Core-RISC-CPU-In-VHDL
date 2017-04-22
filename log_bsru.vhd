-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 3
-- Task:  Task 3b
-- File: log_bsru.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity log_bsru is 
  generic( SHMT   : positive := 4 );
	port( A                 : in   std_logic_vector(2**SHMT-1 downto 0);
	      cnt               : in   std_logic_vector(SHMT-1 downto 0);
	      rot, left, arith  : in   std_logic;
	      F                 : out  std_logic_vector(2**SHMT-1 downto 0));
end entity log_bsru;

architecture structure of log_bsru is 
  
  -- declare a type of SRUOutType, which is an array of 
  -- std_logic_vectors (typically called a "vector of vectors")
  type SRUOutType is array(0 to SHMT) of
      std_logic_vector(2**SHMT-1 downto 0);
  signal sru_outs      :  SRUOutType;
  signal srin          :  std_logic; 

    
begin
  
  --this pre/post reversal logic is only used during left shifts
  --the initial vector is passed in, if left=1, it is reversed to
  --sru_outs(0) so it can be used in the shift array.  if left=0
  --it passes A unchanged to sru_outs  The post reverse works the
  --same way.  These units are only turned on in a left shift.
  
  pre_reverse: entity work.bru(behavior) generic map (SIZE => 2**SHMT)
    port map(A => A, rev => left, Y => sru_outs(0));
  
  post_reverse: entity work.bru(behavior) generic map (SIZE => 2**SHMT)
    port map(A => sru_outs(SHMT), rev => left, Y => F);
      
  --srin is passed to each fsru, and used to pad the shift operation
  --if not doing an arithmetic shift, arith will be 0, 0 and anything is
  --0, and srin is 0, making a logical shift.  if arith is 1, then the
  --sign bit of A is basically used as srin.
  
  srin <= arith AND A(2**SHMT-1);
  
  --shift array.  this is a for loop counting from 0 to shmt-1.
  --for example, let's say shmt is 4.  the loop will set up a shift
  --unit that shifts 2^3 places, 2^2 places, 2^1 places, and 2^0 places
  --cnt is the variable toggling the number of shift places, so say cnt
  --is 6 for example.  since the number of places shifted is the same
  --as the weight of a position in the binary number, ie shifting 5 places
  --could be easily done by turning on the 2^2 shifter and the 2^0 shifter
  --the individual digits of cnt control the enable of each shift stage
  --(ie, cnt(i) will turn on or off the shifter that does 2**i places 
  --of shift).
  
  
  shift_array: for i in 0 to SHMT-1 generate
    shift_unit: entity work.right_fsru(mixed) generic map(SIZE => 2**SHMT, FXDCNT => 2**i)
        port map(A => sru_outs(i), en => cnt(i), rot => rot, srin => srin, F => sru_outs(i+1));
    end generate;
      
    
end architecture structure;

