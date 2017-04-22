-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 4
-- Task:  Task 2a
-- File: btc_8bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity btc_8bit is 
  generic( SIGNED_OPS   : boolean := TRUE );
	port( x, y        : in   std_logic_vector(7 downto 0);
	      zG, zS, zE  : out   std_logic);
end entity btc_8bit;

architecture structure of btc_8bit is 
  signal G_0, S_0 : std_logic_vector(3 downto 0);
  signal G_1, S_1 : std_logic_vector(1 downto 0);
  constant THREE  : positive := 3;
  constant ONE    : positive := 1;
  constant UNSIGNED : boolean := FALSE;
begin
  
  tree_base: for i in THREE downto 0 generate
    signed: if i = THREE generate
      compare: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => SIGNED_OPS)
        port map(x => x(2*i+1 downto 2*i), y => y(2*i+1 downto 2*i), 
                 zG => G_0(i), zS => S_0(i), zE => OPEN);
    end generate signed;
    other_bits: if i /= THREE generate
      compare: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => UNSIGNED)
        port map(x => x(2*i+1 downto 2*i), y => y(2*i+1 downto 2*i), 
                 zG => G_0(i), zS => S_0(i), zE => OPEN);
    end generate other_bits;
  end generate tree_base;
             
  tree_middle: for i in ONE downto 0 generate
    compare_2: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => UNSIGNED)
      port map(x => G_0(2*i+1 downto 2*i), y => S_0(2*i+1 downto 2*i), 
               zG => G_1(i), zS => S_1(i), zE => OPEN);
  end generate tree_middle;           
             
  compare_treetop: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => UNSIGNED)
    port map(x => G_1(1 downto 0), y => S_1(1 downto 0), zG => zG, zS => zS, 
             zE => zE); 
  
    

end architecture structure;
