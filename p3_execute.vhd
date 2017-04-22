--------------------------------
-- Name:  Joseph Palicke
-- Class:  ECE37100
-- Project: P3 processor
-- Task: Execution Stage
-- File:  p3_execute.vhd
--------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_execute is
	port(RofRsInEXE      : in std_logic_vector(31 downto 0);
       RofRtInEXE      : in std_logic_vector(31 downto 0);
       ShamtInEXE      : in std_logic_vector(31 downto 0);
       WriteAddrInEXE  : in std_logic_vector(4 downto 0);
       ImmInEXE        : in std_logic_vector(31 downto 0);
       PCPlusOneInEXE  : in std_logic_vector(31 downto 0);
       ALUControlInEXE : in std_logic_vector(3 downto 0);
       ALUSrcXInEXE    : in std_logic_vector(1 downto 0);
       ALUSrcYInEXE    : in std_logic_vector(1 downto 0);
       rst             : in std_logic;
       clk             : in std_logic;
       clken           : in std_logic;
       ALUResultOutMEM : out std_logic_vector(31 downto 0);
       ALUAddrOutMEM   : out std_logic_vector(7 downto 0);
       RofRtOutMEM     : out std_logic_vector(31 downto 0);
       CVZOut          : out std_logic_vector(2 downto 0));
end entity p3_execute;

architecture mixed of p3_execute is
  
  constant ZERO  : std_logic := '0';
  constant ZEROS : std_logic_vector(31 downto 0) := (others => '0');
  
  constant ONE   : integer := 1;
  constant FIVE    : integer := 5;
  constant SIXTEEN : integer := 16;
  constant THIRTYTWO : integer := 32;
  
  signal ALUXInputEXE : std_logic_vector(31 downto 0);
  signal ALUYInputEXE : std_logic_vector(31 downto 0);
  signal ALUOutputEXE : std_logic_vector(31 downto 0);
  
begin
  
  -- muxes to select alu inputs
  
  with ALUSrcXInEXE select
    ALUXInputEXE <= PCPlusOneInEXE when "01",
                    ShamtInEXE when "10",
                    std_logic_vector(to_unsigned(SIXTEEN,THIRTYTWO)) when "11",
                    RofRsInEXE when others;
                    
  with ALUSrcYInEXE select
    ALUYInputEXE <= ImmInEXE when "01",
                    std_logic_vector(to_unsigned(ONE,THIRTYTWO)) when "10",
                    RofRtInEXE when others;  
  
  -- insantiate ALU
  
    ALU: entity work.pmips_alu_behav(behavior) generic map(LG_SIZE => FIVE)
      port map(x => ALUXInputEXE,
               y => ALUYInputEXE,
               funct => ALUControlInEXE,
               result => ALUOutputEXE,
               CVZ => CVZOut);
  
  -- non piped outputs

  RofRtOutMem <= RofRtInEXE;
  ALUAddrOutMEM <= ALUOutputEXE(7 downto 0);

  -- pipeline flops
  
  EXEPipeline : process(rst, clk) is
	begin
		if rst = '1' then 
			ALUResultOutMEM <= ZEROS;
		elsif rising_edge(clk) then
			if clken = '1' then
				ALUResultOutMEM <= ALUOutputEXE;
			end if;
		end if;
	end process EXEPipeline;        

end architecture mixed;

