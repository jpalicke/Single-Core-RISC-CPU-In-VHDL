-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Task:  Task 1b
-- File: decode_2to4.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity decode_3to8 is 
	port( w  : in   std_logic_vector(2 downto 0);
	      en : in   std_logic;
	      y  : out  std_logic_vector(7 downto 0));
end entity decode_3to8;

architecture structure of decode_3to8 is 

signal out_2to4  : std_logic_vector(3 downto 0);
signal treetop_in : std_logic_vector(1 downto 0);

begin
 
 -- for the tip of the tree, a 1 to 2 decoder would be ideal.
 -- however this 2 to 4 will work fine.  treetop_in is used
 -- for the input, which is w(2) concatenated with a 0. 
 -- The portion of the output that will be
 -- used in the tree is only the portion activated by w(2), ie
 -- out_2to4(1 downto 0)
 
  treetop_in <= '0' & w(2);
 
  treetop: entity work.decode_2to4(mixed)
    port map(w => treetop_in, en => en, y => out_2to4);

 -- for the base of the tree, out_2to4(1) turns on en in the 
 -- decoder called by treebase_high, while out_2to4(0) 
 -- turns on treebase_low.

  treebase_high: entity work.decode_2to4(mixed)
    port map(w => w(1 downto 0) , en => out_2to4(1) , y => y(7 downto 4));
  treebase_low: entity work.decode_2to4(mixed)
    port map(w => w(1 downto 0), en => out_2to4(0), y => y(3 downto 0));
  
end architecture structure;
