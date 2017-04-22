-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Task:  Task 2a
-- File: mux_4to1.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mux_4to1 is 
  generic( SIZE : positive := 3 );
	port( w0, w1, w2, w3  : in   std_logic_vector(SIZE-1 downto 0);
	      s  : in   std_logic_vector(1 downto 0);
	      f  : out  std_logic_vector(SIZE-1 downto 0));
end entity mux_4to1;

architecture mixed of mux_4to1 is 
  constant ONE : std_logic := '1';
  signal minterms : std_logic_vector(3 downto 0);
begin
  
  --setting up one decoder to take in select signals and
  --output minterms for anding with w0-w3 vectors
  
  decode_2to4: entity work.decode_2to4(mixed)
    port map( w => s, en => ONE , y => minterms);
   
  --implements the 2 level SOP circuit mux from 
  --page 23 combo_logic_review.pdf, figure a.    
  --takes the output of the decoder, and ands that with each w(i)
  --each of these terms are then ored together, and set to f(i)
  --the loop then increments and does the same operation again
  --until i hits size-1.  the operation is completed, and the 
  --generate loop is done unrolling.
      
  sop_circuit: for i in 0 to SIZE-1 generate
    f(i) <= (w0(i) and minterms(0)) or (w1(i) and minterms(1))
          or (w2(i) and minterms(2)) or (w3(i) and minterms(3));
  end generate sop_circuit;

end architecture mixed;

