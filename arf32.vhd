-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 8
-- Task:  Task 2
-- File: arf32.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity arf32 is
  generic( SIZE  : positive := 8;
           R0_HW : boolean  := false); 
	port(clk, rst, wren            : in std_logic;
	     rdaddr1, rdaddr2, wraddr  : in std_logic_vector(4 downto 0);
	     wrdata                    : in std_logic_vector(SIZE-1 downto 0);
	     rddata1, rddata2          : out std_logic_vector(SIZE-1 downto 0));
end entity arf32;

architecture structure of arf32 is 

  type arf is array (0 to 3) of std_logic_vector(SIZE-1 downto 0);
  signal rddata1_out    : arf;
  signal rddata2_out    : arf;
  
  signal write_en    : std_logic_vector(3 downto 0);
  signal data_in     : std_logic_vector(SIZE-1 downto 0);
  
  alias rdaddr1_lw    :  std_logic_vector(2 downto 0) is rdaddr1(2 downto 0);
  alias rdaddr1_hgh   :  std_logic_vector(1 downto 0) is rdaddr1(4 downto 3);
  alias rdaddr2_lw    :  std_logic_vector(2 downto 0) is rdaddr2(2 downto 0);
  alias rdaddr2_hgh   :  std_logic_vector(1 downto 0) is rdaddr2(4 downto 3);
  alias wraddr_lw     :  std_logic_vector(2 downto 0) is wraddr(2 downto 0);
  alias wraddr_hgh    :  std_logic_vector(1 downto 0) is wraddr(4 downto 3);
  
begin
  
  -- instantiate 4 ARF-8's
  
  arf_8: for i in 0 to 3 generate
    
    hdwire: if i = 0 generate
    
      arf8_0: entity work.arf8(structure) 
        generic map (SIZE => SIZE, R0_HW => R0_HW)
        port map(clk => clk,
                 rst => rst,
                 wren => write_en(i),
                 rdaddr1 => rdaddr1_lw,
                 rdaddr2 => rdaddr2_lw,
                 wraddr => wraddr_lw,
                 wrdata => wrdata,
                 rddata1 => rddata1_out(i),
                 rddata2 => rddata2_out(i));
          
    end generate;
    nonhdwire: if i /= 0 generate
    
      arf8_1to3: entity work.arf8(structure) 
        generic map (SIZE => SIZE, R0_HW => false)
        port map(clk => clk,
                 rst => rst,
                 wren => write_en(i),
                 rdaddr1 => rdaddr1_lw,
                 rdaddr2 => rdaddr2_lw,
                 wraddr => wraddr_lw,
                 wrdata => wrdata,
                 rddata1 => rddata1_out(i),
                 rddata2 => rddata2_out(i));
    
    end generate;
    
  end generate;
  
  --decoder to select which arf8 is getting written to
  
  wraddr_decode: entity work.decode_2to4(mixed)
    port map(w => wraddr_hgh, en => wren, y => write_en);
  
  --muxes to select which arf8's are connected to the output 
  
  rdaddr1_select: entity work.mux_4to1(mixed)
    generic map(SIZE => SIZE)
    port map(w0 => rddata1_out(0),
             w1 => rddata1_out(1),
             w2 => rddata1_out(2),
             w3 => rddata1_out(3),
             s => rdaddr1_hgh,
             f => rddata1);
             
  rdaddr2_select: entity work.mux_4to1(mixed)
    generic map(SIZE => SIZE)
    port map(w0 => rddata2_out(0),
             w1 => rddata2_out(1),
             w2 => rddata2_out(2),
             w3 => rddata2_out(3),
             s => rdaddr2_hgh,
             f => rddata2);

end architecture structure;

