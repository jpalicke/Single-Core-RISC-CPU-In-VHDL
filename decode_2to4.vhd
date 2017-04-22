-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Task:  Task 1a
-- File: decode_2to4.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity decode_2to4 is 
	port( w  : in   std_logic_vector(1 downto 0);
	      en : in   std_logic;
	      y  : out  std_logic_vector(3 downto 0));
end entity decode_2to4;

architecture mixed of decode_2to4 is 
  signal x_axis_out: std_logic_vector(1 downto 0);
  signal y_axis_out: std_logic_vector(1 downto 0);
  
  constant TWO : positive := 2;
  
begin
  
  x_axis: entity work.decode_1to2(dataflow)
    port map(w => w(0), en => en, y => x_axis_out);
  y_axis: entity work.decode_1to2(dataflow)
    port map(w => w(1), en => en, y => y_axis_out);
      
  and_array_y: for i in 0 to TWO-1 generate
    and_array_x: for j in 0 to TWO-1 generate
      y(TWO*j+i) <= x_axis_out(i) and y_axis_out(j);  
    end generate and_array_x;
  end generate and_array_y;
  
end architecture mixed;
