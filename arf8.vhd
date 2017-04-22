-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 8
-- Task:  Task 1
-- File: arf8.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;

entity arf8 is
  generic( SIZE  : positive := 5;
           R0_HW : boolean  := false); 
	port(clk, rst, wren            : in std_logic;
	     rdaddr1, rdaddr2, wraddr  : in std_logic_vector(2 downto 0);
	     wrdata                    : in std_logic_vector(SIZE-1 downto 0);
	     rddata1, rddata2          : out std_logic_vector(SIZE-1 downto 0));
end entity arf8;

architecture structure of arf8 is 

  constant ZEROS     : std_logic_vector(SIZE-1 downto 0) := (others => '0');

  type arf is array (0 to 7) of std_logic_vector(SIZE-1 downto 0);
  signal data_out    : arf;
  
  signal write_en    : std_logic_vector(7 downto 0);
  signal data_in     : std_logic_vector(SIZE-1 downto 0);
  
  
begin
 
 -- generate array of flip flops
 -- checks if the row is the 0th row and checks R0_HW
 -- if both are true, arf(0) is set to zeros, if not
 -- parses through the loop normally and generates
 -- the flop for that row.
 
  ff_y: for i in 0 to 7 generate
    r0true: if (R0_HW = true and i = 0) generate
      data_out(0) <= ZEROS;
    end generate;
    r0false: if (R0_HW = false and i = 0) generate
      ff: entity work.dflop(behavior) generic map (SIZE => SIZE)
        port map(clk => clk, 
                 rst => rst, 
                 clken => write_en(0), 
                 din => wrdata, 
                 q => data_out(0));
    end generate;
    rest: if i /= 0 generate
      ff: entity work.dflop(behavior) generic map (SIZE => SIZE)
        port map(clk => clk, 
                 rst => rst, 
                 clken => write_en(i), 
                 din => wrdata, 
                 q => data_out(i));
      end generate;
  end generate;
  
  --decoder for write addresses
  
  wraddr_decode: entity work.decode_3to8(structure)
    port map(w => wraddr, 
             en => wren, 
             y => write_en);
  
  --muxes for read addresses
  
  rdaddr1_mux: entity work.mux_8to1(structure) generic map (SIZE => SIZE)
    port map(w0 => data_out(0), 
             w1 => data_out(1), 
             w2 => data_out(2), 
             w3 => data_out(3), 
             w4 => data_out(4), 
             w5 => data_out(5), 
             w6 => data_out(6), 
             w7 => data_out(7), 
             s => rdaddr1, 
             f => rddata1);
  
   rdaddr2_mux: entity work.mux_8to1(structure) generic map (SIZE => SIZE)
    port map(w0 => data_out(0), 
             w1 => data_out(1), 
             w2 => data_out(2), 
             w3 => data_out(3), 
             w4 => data_out(4), 
             w5 => data_out(5), 
             w6 => data_out(6), 
             w7 => data_out(7), 
             s => rdaddr2, 
             f => rddata2);
             
end architecture structure;

