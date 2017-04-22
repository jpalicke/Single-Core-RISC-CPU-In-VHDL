-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 5
-- Task:  Task 3
-- File: asu_32bit.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity asu_32bit is 
	port(x, y      : in std_logic_vector(31 downto 0);
	     sub       : in std_logic;
	     twos_cmp  : in std_logic;
	     result    : out std_logic_vector(31 downto 0);
	     NZV       : out std_logic_vector(2 downto 0));
end entity asu_32bit;

architecture mixed of asu_32bit is 
 
  signal cout         : std_logic;
  signal answer       : std_logic_vector(31 downto 0);
  signal v_add, v_sub : std_logic;
  signal v_unsigned   : std_logic;
  signal v_signed     : std_logic;
  signal flip         : std_logic_vector(31 downto 0);
  signal invert		 : std_logic_vector(31 downto 0);
  
  constant ZEROS  : std_logic_vector(31 downto 0) := (others => '0');
  
  alias Z         : std_logic is NZV(1);
  alias N         : std_logic is NZV(2);
  alias V         : std_logic is NZV(0);
  alias x_sign    : std_logic is x(31);
  alias y_sign    : std_logic is y(31);
  alias sign_result : std_logic is answer(31);
 
begin

  -- hybrid adder unit
  
  hau: entity work.hau_32bit(structure)
    port map(x => x , y => invert , cin => sub , 
             sum => answer, cout => cout);
  result <= answer;
      
  -- conditional inversion logic
  -- quartus seems to really not like vector aggregates
  -- or and/or/etc of a vector with a scalar.
  -- hence, this was changed to the following.
  
  flip <= (others => sub);
  invert(31 downto 0) <= ((not y(31 downto 0) and 
			flip(31 downto 0)) or (y(31 downto 0) and not flip(31 downto 0)));
  
  -- z flag
  
  with answer select
    Z <= '1' when ZEROS,
         '0' when others;
         
  -- n flag
    
    N <= twos_cmp and answer(31);
    
  -- v flag
  
    v_add <= (x_sign and y_sign and (not sign_result)) or 
             ((not x_sign) and (not y_sign) and sign_result);
    v_sub <= (x_sign and (not y_sign) and (not sign_result)) or 
             ((not x_sign) and y_sign and sign_result);
    v_unsigned <= ((not cout) and sub) or (cout and (not sub));         
    v_signed <= (v_add and (not sub)) or (v_sub and sub);
    V <=  (v_signed and twos_cmp) or (v_unsigned and (not twos_cmp));
    
  
end architecture mixed;


