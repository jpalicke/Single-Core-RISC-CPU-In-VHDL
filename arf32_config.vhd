-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 8
-- Task:  Task 3
-- File: arf32_config.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity arf32_config is
  generic( SIZE  : positive := 16;
           R0_HW : boolean  := true;
           FWD   : boolean  := true); 
	port(clk, rst, wren            : in std_logic;
	     rdaddr1, rdaddr2, wraddr  : in std_logic_vector(4 downto 0);
	     wrdata                    : in std_logic_vector(SIZE-1 downto 0);
	     rddata1, rddata2          : out std_logic_vector(SIZE-1 downto 0));
end entity arf32_config;

architecture mixed of arf32_config is 

  constant R0 : std_logic_vector(4 downto 0) := (others => '0');
  
  signal data1, data2  : std_logic_vector(SIZE-1 downto 0);
  
begin
  
--arf32

  arf32: entity work.arf32(structure) 
    generic map (SIZE => SIZE, R0_HW => R0_HW)
    port map(clk => clk,
             rst => rst,
             wren => wren,
             rdaddr1 => rdaddr1,
             rdaddr2 => rdaddr2,
             wraddr => wraddr,
             wrdata => wrdata,
             rddata1 => data1,
             rddata2 => data2);
             
  -- if generates
  
  case1: if not FWD generate
    rddata1 <= data1;
    rddata2 <= data2;
  end generate;
  
  case2: if FWD and not R0_HW generate
    rddata1 <= wrdata when ((rdaddr1 = wraddr) and wren = '1') else
               data1;
    rddata2 <= wrdata when ((rdaddr2 = wraddr) and wren = '1') else
               data2;
  end generate;
  
  case3: if FWD and R0_HW generate
    rddata1 <= wrdata when ((rdaddr1 = wraddr) and wren = '1' and wraddr /= R0) else
               data1;
    rddata2 <= wrdata when ((rdaddr2 = wraddr) and wren = '1' and wraddr /= R0) else
               data2;
  end generate;


end architecture mixed;


