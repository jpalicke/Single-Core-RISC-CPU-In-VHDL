-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 4
-- Task:  Task 2b
-- File: btc_32bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity btc_32bit is 
  generic( SIGNED_OPS   : boolean := TRUE );
	port( x, y        : in   std_logic_vector(31 downto 0);
	      zG, zS, zE  : out   std_logic);
end entity btc_32bit;

architecture structure of btc_32bit is 
  signal G_0, S_0 : std_logic_vector(15 downto 0);
  signal G_1, S_1 : std_logic_vector(7 downto 0);
  constant FIFTEEN : positive := 15;
  constant SEVEN   : positive := 7;
  constant UNSIGNED : boolean := FALSE;
begin
  
  tree_base: for i in FIFTEEN downto 0 generate
    signed: if i = FIFTEEN generate
      compare: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => SIGNED_OPS)
        port map(x => x(2*i+1 downto 2*i), y => y(2*i+1 downto 2*i), 
                 zG => G_0(i), zS => S_0(i), zE => OPEN);
    end generate signed;
    other_bits: if i /= FIFTEEN generate
      compare: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => UNSIGNED)
        port map(x => x(2*i+1 downto 2*i), y => y(2*i+1 downto 2*i), 
                 zG => G_0(i), zS => S_0(i), zE => OPEN);
    end generate other_bits;
  end generate tree_base;
             
  tree_middle: for i in SEVEN downto 0 generate
    compare_2: entity work.cpc_2bit(dataflow) generic map(SIGNED_OPS => UNSIGNED)
      port map(x => G_0(2*i+1 downto 2*i), y => S_0(2*i+1 downto 2*i), 
               zG => G_1(i), zS => S_1(i), zE => OPEN);
  end generate tree_middle;           
             
  compare_treetop: entity work.btc_8bit(structure) generic map(SIGNED_OPS => UNSIGNED)
    port map(x => G_1, y => S_1, zG => zG, zS => zS, zE => zE); 
  
    

end architecture structure;

