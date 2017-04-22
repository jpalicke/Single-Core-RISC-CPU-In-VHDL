-----------------------------------------------------------
-- Name:  Joseph Palicke
-- Project:  Lab 1
-- Task:  Task 1
-- File:  csg_4bit.vhd
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity csg_4bit is
  port ( c0 : in  std_logic;
         g  : in  std_logic_vector(2 downto 0);
         a  : in  std_logic_vector(2 downto 0);
         p  : in  std_logic_vector(3 downto 0);
         s  : out std_logic_vector(3 downto 0));
end entity csg_4bit;

architecture dataflow of csg_4bit is
signal level_1 : std_logic_vector(3 downto 0);
signal level_2 : std_logic_vector(5 downto 0);
signal level_3 : std_logic_vector(5 downto 0);
begin
  
  s(0) <= (p(0) xor c0);
  
  -- level_1 is the output of the and/or gate combinations on
  -- the far left of the schematic
  level_1(0) <= (g(0) and a(1)) or g(1);
  level_1(1) <= (a(0) and a(1)) or g(1);
  level_1(2) <= (level_1(0) and a(2)) or g(2);
  level_1(3) <= (level_1(1) and a(2)) or g(2);
  
  -- level_2 is the output of the set of the xor gates roughly
  -- in the middle of the schematic
  level_2(0) <= (g(0) xor p(1));
  level_2(1) <= (a(0) xor p(1));
  level_2(2) <= (level_1(0) xor p(2)) ;
  level_2(3) <= (level_1(1) xor p(2)) ;
  level_2(4) <= (level_1(2) xor p(3)) ;
  level_2(5) <= (level_1(3) xor p(3)) ;
  
  -- level_3 is the output of the nand/nor gates before the
  -- very last set of gates that lead to the outputs
  level_3(0) <= (not c0) nand level_2(0);
  level_3(1) <= c0 nand level_2(1);
  level_3(2) <= (not c0) nand level_2(2) ;
  level_3(3) <= c0 nand level_2(3) ;
  level_3(4) <= c0 nor level_2(4);
  level_3(5) <= (not c0) nor level_2(5);
  
  -- outputs
  s(1) <= level_3(0) nand level_3(1);
  s(2) <= level_3(2) nand level_3(3);
  s(3) <= level_3(4) nor level_3(5);
  
end architecture dataflow;