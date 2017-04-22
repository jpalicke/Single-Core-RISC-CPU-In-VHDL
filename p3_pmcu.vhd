
--------------------------------
-- Name:  Joseph Palicke
-- Class:  ECE37100
-- Project: P3 processor
-- Task: Microprocessor Control Unit
-- File:  MicroprocessorControlUnit.vhd
--------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_pmcu is
	port(clk, rst, clken   : in std_logic;
	     OpcodeInPMCU      : in std_logic_vector(5 downto 0);
       RtInPMCU          : in std_logic_vector(4 downto 0);
       FuncInPMCU        : in std_logic_vector(5 downto 0);
       GSEInPMCU         : in std_logic_vector(2 downto 0);
       WriteAddrInPMCU   : in std_logic_vector(4 downto 0);
       PCSrcOutIF       : out std_logic_vector(1 downto 0);
       WithZeroOutID    : out std_logic;
       MemWriteOutMEM   : out std_logic;
       MemReadOutIDWB   : out std_logic;
       ALUControlOutEXE : out std_logic_vector(3 downto 0);
       ALUSrcXOutEXE    : out std_logic_vector(1 downto 0);
       ALUSrcYOutEXE    : out std_logic_vector(1 downto 0);
       SignExtOutID     : out std_logic;
       RegWriteOutIDWB  : out std_logic;
       WriteDestOutIDWB : out std_logic_vector(1 downto 0);
       WriteAddrOutIDWB : out std_logic_vector(4 downto 0));
end entity p3_pmcu;

architecture mixed of p3_pmcu is
    
  -- into the pmcu stage
  
  signal  MemWritePMCU   : std_logic;
  signal  MemReadPMCU    : std_logic;
  signal  ALUControlPMCU : std_logic_vector(3 downto 0);
  signal  ALUSrcXPMCU    : std_logic_vector(1 downto 0);
  signal  ALUSrcYPMCU    : std_logic_vector(1 downto 0);
  signal  RegWritePMCU   : std_logic;
  
  -- into the exe stage
  
  signal MemWriteEXE  : std_logic;
  signal MemReadEXE   : std_logic;
  signal RegWriteEXE  : std_logic;
  signal WriteAddrEXE : std_logic_vector(4 downto 0);
  
  -- into the mem stage
  
  signal MemWriteMEM  : std_logic;
  signal MemReadMEM   : std_logic;
  signal RegWriteMEM  : std_logic;
  signal WriteAddrMEM : std_logic_vector(4 downto 0);
        
begin
  
  --instantiate MCU
  
  mcu: entity work.p3_mcu(behavior)
  port map(OpcodeInMCU => OpcodeInPMCU,
           RtInMCU => RtInPMCU(0),
           FuncInMCU => FuncInPMCU,
           GSEInMCU => GSEInPMCU,
           PCSrcOutID => PCSrcOutIF,
           WithZeroOutID => WithZeroOutID,
           MemWriteOutID => MemWritePMCU,
           MemReadOutID => MemReadPMCU,
           ALUControlOutID => ALUControlPMCU,
           ALUSrcXOutID => ALUSrcXPMCU,
           ALUSrcYOutID => ALUSrcYPMCU,
           SignExtOutID => SignExtOutID,
           RegWriteOutID => RegWritePMCU,
           WriteDestOutID => WriteDestOutIDWB);
  
         
  -- pipeline flops
  
  flop : process(rst, clk) is
	begin
		if rst = '1' then 
		  --id/exe stage pipe
		  MemWriteEXE <= '0';
		  MemReadEXE <= '0';
		  ALUControlOutEXE <= "0000";
		  ALUSrcXOutEXE <= "00";
		  ALUSrcYOutEXE <= "00";
		  RegWriteEXE <= '0';
		  WriteAddrEXE <= (others => '0');
		  --exe/mem stage pipe
		  MemReadMEM <= '0';
		  RegWriteMEM <= '0';
		  WriteAddrMEM <= (others => '0');
		  --mem/wb-id stage pipe
		  MemReadOutIDWB <= '0';
		  RegWriteOutIDWB <= '0';
		  WriteAddrOutIDWB <= (others => '0');
		elsif rising_edge(clk) then
			if clken = '1' then
			  --id/exe stage pipe
		    MemWriteOutMEM <= MemWritePMCU;
		    MemReadEXE <= MemReadPMCU;
		    ALUControlOutEXE <= ALUControlPMCU;
		    ALUSrcXOutEXE <= ALUSrcXPMCU;
		    ALUSrcYOutEXE <= ALUSrcYPMCU;
		    RegWriteEXE <= RegWritePMCU;
		    WriteAddrEXE <= WriteAddrInPMCU;
		    --exe/mem stage pipe
		    MemReadMEM <= MemReadEXE;
		    RegWriteMEM <= RegWriteEXE;
		    WriteAddrMEM <= WriteAddrEXE;
		    --mem/wb-id stage pipe
		    MemReadOutIDWB <= MemReadMEM;
		    RegWriteOutIDWB <= RegWriteMEM;
		    WriteAddrOutIDWB <= WriteAddrMEM;
			end if;
		end if;
	end process flop;
  
  
end architecture mixed;

