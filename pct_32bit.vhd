-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 5
-- Task:  Task 1b
-- File: pct_32bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pct_32bit is 
	port(g, a          : in std_logic_vector(31 downto 0);
	     cin           : in std_logic;
	     carries       : out std_logic_vector(7 downto 0));
end entity pct_32bit;

architecture structure of pct_32bit is 
  
  type pct8bit is array(0 to 3) of
      std_logic_vector(1 downto 0);
  signal g_pct      :  pct8bit;
  signal a_pct      :  pct8bit;
  type tree is array(0 to 5) of
      std_logic_vector(1 downto 0);
  signal g_tree     :  tree;
  signal a_tree     :  tree;

begin
  
  --generates 31:24, 27:24, 23:16, 19:16, 15:8, 11:8, 7:0, 3:0.
  --the ones with the same end index for the spans are grouped into 2 bit vectors
  --and a vector of vectors is made of those.
  
  g_a_generate: for i in 3 downto 0 generate
    pct_8bit: entity work.pct_8bit(structure)
      port map(g => g((8*(i+1))-1 downto 8*i), a => a((8*(i+1))-1 downto 8*i) , 
               g_grp => g_pct(i), a_grp => a_pct(i) );
  end generate;
  
  --generates 31:0 and 27:0
     
  black_cell31: for i in 2 downto 0 generate
    black_cell27: for j in 1 downto 0 generate
      black_cell_cond1:  if i = 2 generate
        base: entity work.black_cell(dataflow)
          port map(g_hi => g_pct(3)(j) , a_hi => a_pct(3)(j) , g_lo => g_pct(2)(1) , 
                   a_lo => a_pct(2)(1), g_grp => g_tree(5)(j), a_grp => a_tree(5)(j));
      end generate;
      black_cell_cond2:  if i /=2 generate
        rest: entity work.black_cell(dataflow)
          port map(g_hi => g_tree(4+i)(j) , a_hi => a_tree(4+i)(j) , g_lo => g_pct(i)(1) , 
                   a_lo => a_pct(i)(1), g_grp => g_tree(3+i)(j), a_grp => a_tree(3+i)(j));
      end generate;
    end generate;
  end generate;
  
  -- generates 23:0 and 19:0
  
  black_cell23: for i in 1 downto 0 generate
    black_cell19: for j in 1 downto 0 generate
      black_cell_cond1:  if i = 1 generate
          base: entity work.black_cell(dataflow)
            port map(g_hi => g_pct(2)(j) , a_hi => a_pct(2)(j) , g_lo => g_pct(1)(1) , 
                     a_lo => a_pct(1)(1), g_grp => g_tree(2)(j), a_grp => a_tree(2)(j));
      end generate;
      black_cell_cond2:  if i /=1 generate
        black_cell_1_hi: entity work.black_cell(dataflow)
          port map(g_hi => g_tree(2)(j) , a_hi => a_tree(2)(j) , g_lo => g_pct(0)(1) , 
                   a_lo => a_pct(0)(1), g_grp => g_tree(1)(j), a_grp => a_tree(1)(j));
      end generate;
    end generate;
  end generate;
  
  -- generates 15:0 and 11:0
  
  black_cell15_11:  for i in 1 downto 0 generate
    black_cell_0_hi: entity work.black_cell(dataflow)
      port map(g_hi => g_pct(1)(i) , a_hi => a_pct(1)(i) , g_lo => g_pct(0)(1) , 
               a_lo => a_pct(0)(1), g_grp => g_tree(0)(i), a_grp => a_tree(0)(i));
  end generate;
  
  --generate the grey cells.  the lowest grey cells are different because there are no
  --black cells inbetween, they are coming directly from the pct_8 handling the lowest
  --bits of the input.  yes, the index of g_tree is ugly, but i'm storing carries in
  --tree(3,1,0), so that evaluates to those numbers.
  
  grey_cell_gen_hi: for i in 3 downto 0 generate  
    grey_cell_gen_lo: for j in 1 downto 0 generate
      grey_cell_lsb: if i = 0 generate
        grey_cell_0: entity work.gray_cell(dataflow)
        port map(g_hi => g_pct(0)(j), a_hi => a_pct(0)(j) , g_lo => cin, g_grp => carries(j));
      end generate;
      grey_cell_other:  if i /= 0 generate
        grey_cell: entity work.gray_cell(dataflow)
          port map(g_hi => g_tree((2**(i-1))-1)(j), a_hi => a_tree((2**(i-1))-1)(j) , 
                   g_lo => cin, g_grp => carries((2*i)+j));
      end generate;
    end generate;
  end generate;

end architecture structure;



