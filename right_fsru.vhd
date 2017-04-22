-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 3
-- Task:  Task 3a
-- File: right_fsru.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity right_fsru is 
  generic( SIZE   : positive := 4;
           FXDCNT : positive := 1);
	port( A              : in   std_logic_vector(SIZE-1 downto 0);
	      en, rot, srin  : in   std_logic;
	      F              : out  std_logic_vector(SIZE-1 downto 0));
end entity right_fsru;

architecture mixed of right_fsru is 
  
  signal layer1 : std_logic_vector(SIZE-1 downto 0);
  signal pad    : std_logic_vector(FXDCNT-1 downto 0);
  constant HIGH : std_logic := '1';
    
begin
  
  --layer 1 mux defined by the ccsa.  when rot is 1
  --pad gets set to the part of A that would be
  --"pushed off the cliff" with the shift operation
  --otherwise it gets set to srin
  
  with rot select
    pad <= A(FXDCNT-1 downto 0) when HIGH,
           (others => srin) when others;
           
  -- this statement is the "wire rearrangement logic",
  -- using the concatenation operator.  I could not for
  -- the life of me to get the vector aggregates version
  -- to work correctly.
    
  layer1 <= pad & A(SIZE-1 downto FXDCNT);
  
  -- this is the layer2 mux, just senses the enable signal
  -- and passes the shifted/rotated vector, otherwise it 
  -- passes the unchanged input signal.
           
  layer2: entity work.mux_2to1(dataflow) generic map (SIZE => SIZE)
    port map(w0 => A, w1 => layer1, s => en, f=> F); 
  
  
end architecture mixed;
