-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 5
-- Task:  Task 2b
-- File: hau_32bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity hau_32bit is 
	port(x, y    : in std_logic_vector(31 downto 0);
	     cin     : in std_logic;
	     sum     : out std_logic_vector(31 downto 0);
	     cout    : out std_logic);
end entity hau_32bit;

architecture structure of hau_32bit is 

  signal g, a, p : std_logic_vector(31 downto 0);
  signal carry   : std_logic_vector(8 downto 0);
  
begin

-- bitwise g,a,p and taking care of cout
 	g <= x and y;
	a <= x or y;
	p <= x xor y;
  cout <= carry(8);

-- prefix carry tree generating every 4th carry
  pct: entity work.pct_32bit(structure)
    port map(g => g, a => a, cin => cin, carries => carry(8 downto 1));
      
-- conditional sum generators and handling cin

  carry(0) <= cin;
  
  csg_generate: for i in 7 downto 0 generate
    csg_1: entity work.csg_4bit(dataflow)
      port map(c0 => carry(i), g => g(4*i+2 downto 4*i), a => a(4*i+2 downto 4*i), 
               p => p(4*(i+1)-1 downto 4*i) , s => sum(4*(i+1)-1 downto 4*i));
  end generate;
  
end architecture structure;

