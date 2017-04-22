--------------------------------
-- Name:  Joseph Palicke
-- Class:  ECE37100
-- Project: P3 processor
-- Task: Memory Write Stage
-- File:  p3_mem.vhd
--------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_mem is
	port( ALUResultInMEM  : in std_logic_vector(31 downto 0);
        RofRtInMEM      : in std_logic_vector(31 downto 0);
        ALUAddrInMEM    : in std_logic_vector(7 downto 0);
        WriteAddrInMEM  : in std_logic_vector(4 downto 0);
        MemWriteInMEM   : in std_logic;
        clk             : in std_logic;
        clken           : in std_logic;
        rst             : in std_logic;
        ALUResultOutID  : out std_logic_vector(31 downto 0);
        MemDataOutID    : out std_logic_vector(31 downto 0));
end entity p3_mem;

architecture mixed of p3_mem  is
  
  constant ZERO  : std_logic := '0';
  constant ZEROS : std_logic_vector(31 downto 0) := (others => '0');
  
  constant ONE   : integer := 1;
  constant EIGHT    : integer := 8;
  constant SIXTEEN : integer := 16;
  constant THIRTYTWO : integer := 32;
  
  signal MemDataMEM  : std_logic_vector(31 downto 0);
  
begin
  
   -- instantiate dataRAM
  
  dataRAM: entity work.dataRAM(SYN)     
    port map(clock => clk ,
             wren => MemWriteInMEM,
             clken => clken,
             address => ALUAddrInMEM,
             data => RofRtInMEM,
             q => MemDataMEM);

  
  -- pipeline flops
  
  MEMPipeline : process(rst, clk) is
	begin
		if rst = '1' then 
			ALUResultOutID <= (others => '0');
      MemDataOutID <= (others => '0');
		elsif rising_edge(clk) then
			if clken = '1' then
			  ALUResultOutID <= ALUResultInMEM;
        MemDataOutID <= MemDataMEM;
			end if;
		end if;
	end process MEMPipeline;        

end architecture mixed;


