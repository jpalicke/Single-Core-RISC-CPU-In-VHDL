-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 5
-- Task:  Task 1
-- File: pmips_alu_struct.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pmips_alu_struct is 
	port(x, y      : in std_logic_vector(31 downto 0);
	     funct     : in std_logic_vector(3 downto 0);
	     result    : out std_logic_vector(31 downto 0);
	     CVZ       : out std_logic_vector(2 downto 0));
end entity pmips_alu_struct;

architecture structure of pmips_alu_struct is 

--constants

  constant THIRTYTWO  : positive := 32;
  constant FIVE       : positive := 5;
  constant THREE      : positive := 3;
  constant ONE        : std_logic := '1';
  constant ZERO       : std_logic := '0';
  constant ZEROS      : std_logic_vector(31 downto 0) := (others => '0');
  

--signals
  
  signal asu_f, bsru_f         : std_logic_vector(31 downto 0);
  signal blu_f, slt_f, answer  : std_logic_vector(31 downto 0);
  signal asu_flg, bsru_flg     : std_logic_vector(2 downto 0);
  signal blu_flg, slt_flg      : std_logic_vector(2 downto 0);
  signal nzv, gse              : std_logic_vector(2 downto 0);
  signal Z_flag                : std_logic;

--aliases

  alias sub        :  std_logic is funct(1);
  alias left       :  std_logic is funct(1);
  alias signed     :  std_logic is funct(0);
  alias arith      :  std_logic is funct(0);
  alias blu_sel    :  std_logic_vector(1 downto 0) is funct(1 downto 0);
  alias sel        :  std_logic_vector(1 downto 0) is funct(3 downto 2);
  alias cnt        :  std_logic_vector(4 downto 0) is x(4 downto 0);
  alias lessthan   :  std_logic is gse(1);
  alias V          :  std_logic is nzv(0);
  alias Z          :  std_logic is nzv(1);
  
 
begin

--asu

  asu: entity work.asu_32bit(mixed)
    port map(x => x, y => y, sub => sub, twos_cmp => signed, 
             result => asu_f , NZV => nzv);
  
  asu_flg <= (2 => V and (not signed), 1 => V and signed, 0 => Z);
      
--scu
  
  scu: entity work.scu(mixed)
    port map(NZV => nzv , twos_cmp => signed, z_GSE => gse);   
      
  with lessthan select
    slt_f <= (31 downto 1 => ZERO, 0 => ONE) when ONE,
             (31 downto 1 => ZERO, 0 => ZERO) when others;
             
--logBSRU

  shift:  entity work.log_bsru(structure) generic map (SHMT => FIVE)
    port map(A => y, cnt => cnt, rot => ZERO, left => left, 
             arith => arith, F => bsru_f);
               
--blu

  blu:  entity work.blu_nbit(behavior) generic map(SIZE => THIRTYTWO)
    port map(x => x, y=> y , blu_sel => blu_sel, f => blu_f);
      
--mux to select output based on the upper two bits of funct

  result <= answer;

  with answer select
    Z_flag  <= ONE when ZEROS,
               ZERO when others;
  
  blu_flg <= ZERO & ZERO & Z_flag;
  bsru_flg <= ZERO & ZERO & Z_flag;
  slt_flg <= ZERO & ZERO & Z_flag;
  

  output_mux: entity work.mux_4to1(mixed) generic map(SIZE => THIRTYTWO)
    port map(w0 => blu_f, w1 => asu_f, w2 => slt_f , w3 => bsru_f , 
             s => sel, f => answer);

  flag_mux: entity work.mux_4to1(mixed) generic map(SIZE => THREE)
    port map(w0 => blu_flg, w1 => asu_flg, w2 => slt_flg , w3 => bsru_flg , 
             s => sel, f => CVZ);
    
  
end architecture structure;




