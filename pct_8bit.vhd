-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 5
-- Task:  Task 1
-- File: pct_8bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pct_8bit is 
	port(g, a          : in std_logic_vector(7 downto 0);
	     g_grp, a_grp  : out std_logic_vector(1 downto 0));
end entity pct_8bit;

architecture structure of pct_8bit is 
  

  signal g_grp_base  :  std_logic_vector(3 downto 0); 
  signal a_grp_base  :  std_logic_vector(3 downto 0);
  signal g_grp7      :  std_logic_vector(1 downto 0);
  signal a_grp7      :  std_logic_vector(1 downto 0);

begin
  
  --generates (g, a) 7:6, 5:4, 3:2, 1:0
  
  base_bcells: for i in 3 downto 0 generate
    black_cell: entity work.black_cell(dataflow)
      port map(g_hi => g(2*i+1), a_hi => a(2*i+1) , g_lo => g(2*i) , a_lo => a(2*i) , 
               g_grp => g_grp_base(i) , a_grp => a_grp_base(i));
  end generate;
  
  --this could probably be shortened into a loop, but was getting needlessly
  --complicated with a nested if generate and didn't really save any effort
  --for structure, please refer to the diagram in the report materials.
  --basically, takes the highest level black_cell, and puts it into another
  --black cell along with the (bitwise)next lowest black_cell, i.e 7:4 gets put
  --into a black cell along with 3:2, and that output goes into a black_cell with
  --1:0
  
  seventofour: entity work.black_cell(dataflow)
    port map(g_hi => g_grp_base(3), a_hi => a_grp_base(3) , g_lo => g_grp_base(2) , 
             a_lo => a_grp_base(2) , g_grp => g_grp7(1) , a_grp => a_grp7(1));
               
  seventotwo: entity work.black_cell(dataflow)
    port map(g_hi => g_grp7(1), a_hi => a_grp7(1) , g_lo => g_grp_base(1) , 
             a_lo => a_grp_base(1) , g_grp => g_grp7(0) , a_grp => a_grp7(0));
  
  seventozero: entity work.black_cell(dataflow)
    port map(g_hi => g_grp7(0), a_hi => a_grp7(0) , g_lo => g_grp_base(0) , 
             a_lo => a_grp_base(0) , g_grp => g_grp(1) , a_grp => a_grp(1));
    
  --works the same way as the seven series, just starting with the 3:2 black cell
  
  threetozero: entity work.black_cell(dataflow)
    port map(g_hi => g_grp_base(1), a_hi => a_grp_base(1) , g_lo => g_grp_base(0) , 
             a_lo => a_grp_base(0) , g_grp => g_grp(0) , a_grp => a_grp(0));
               
               
end architecture structure;


