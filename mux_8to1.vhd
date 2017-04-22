-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Task:  Task 2b
-- File: mux_8to1.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mux_8to1 is 
  generic( SIZE : positive := 5 );
	port( w0, w1, w2, w3  : in   std_logic_vector(SIZE-1 downto 0);
	      w4, w5, w6, w7  : in   std_logic_vector(SIZE-1 downto 0); 
	      s  : in   std_logic_vector(2 downto 0);
	      f  : out  std_logic_vector(SIZE-1 downto 0));
end entity mux_8to1;

architecture structure of mux_8to1 is 
  signal w3downto0 : std_logic_vector(SIZE-1 downto 0);
  signal w7downto4 : std_logic_vector(SIZE-1 downto 0);
  
-- declare an "all zeros" vector for the unused treetop inputs
 
  constant ALL_ZEROS : std_logic_vector(SIZE-1 downto 0) := (others => '0');
  constant ZERO : std_logic := '0';
begin
  
  -- two 4 to 1 muxes are called, one with w0-w3, the other with
  -- w4-w7 as inputs.  The bottom two bits of s are used
  -- to select a signal from each mux...
  
  treebase_low: entity work.mux_4to1(mixed) generic map(SIZE => SIZE)
    port map(w0 => w0, w1 => w1, w2 => w2, w3 => w3,
             s => s(1 downto 0), f => w3downto0);
  treebase_high: entity work.mux_4to1(mixed) generic map(SIZE => SIZE) 
    port map(w0 => w4 , w1 => w5 , w2 => w6 , w3 => w7,
             s => s(1 downto 0), f => w7downto4);
             
  --...and those two signals are run into another 4 to 1 mux
  --along with two zero vectors for the upper inputs, making
  --it act as a 2 to 1 mux.  s(2) is sent to s(0) of the 4 to 1
  --mux, meaning either w0 or w1 will always be selected for
  --output to f.
  
  treetop: entity work.mux_4to1(mixed) generic map(SIZE => SIZE) 
    port map(w0 => w3downto0 , w1 => w7downto4 , w2 => ALL_ZEROS, w3 => ALL_ZEROS,
             s(0) => s(2) , s(1) => ZERO, f => f);
  

end architecture structure;


