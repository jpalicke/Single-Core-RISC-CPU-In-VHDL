--------------------------------
-- Name:  Joseph Palicke
-- Class:  ECE37100
-- Project: P3 processor
-- Task: Top Level
-- File:  p3_top.vhd
--------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_top is
	port(clk, rst, clken       : in std_logic;
	     InstructionOutTop     : out std_logic_vector(31 downto 0);
	     GSEOutTop             : out std_logic_vector(2 downto 0);
	     PCSrcOutTop           : out std_logic_vector(1 downto 0);
	     WithZeroOutTop        : out std_logic;
	     MemWriteOutTop        : out std_logic;
       MemReadOutTop         : out std_logic;
       ALUControlOutTop      : out std_logic_vector(3 downto 0);
       ALUSrcXOutTop         : out std_logic_vector(1 downto 0);
       ALUSrcYOutTop         : out std_logic_vector(1 downto 0);
       SignExtOutTop         : out std_logic;
       RegWriteOutTop        : out std_logic;
       WriteDestOutTop       : out std_logic_vector(1 downto 0);
       BranchTargetOutTop    : out std_logic_vector(7 downto 0);
       JumpTargetOutTop      : out std_logic_vector(7 downto 0);
       RegTargetOutTop       : out std_logic_vector(7 downto 0);
       PCPlusOneOutTop       : out std_logic_vector(7 downto 0);
       RofRsOutTop           : out std_logic_vector(31 downto 0);
       RofRtOutTop           : out std_logic_vector(31 downto 0);
       ImmOutTop             : out std_logic_vector(31 downto 0);
       WriteAddrMEMOutTop    : out std_logic_vector(4 downto 0));
	     
end entity p3_top;

architecture mixed of p3_top  is
  
  signal InstructionTop  : std_logic_vector(31 downto 0);
  signal GSETop          : std_logic_vector(2 downto 0);
  signal PCSrcTop        : std_logic_vector(1 downto 0);
  signal WithZeroTop     : std_logic;
  signal MemWriteTop     : std_logic;
  signal MemReadTop      : std_logic;
  signal ALUControlTop   : std_logic_vector(3 downto 0);
  signal ALUSrcXTop      : std_logic_vector(1 downto 0);
  signal ALUSrcYTop      : std_logic_vector(1 downto 0);
  signal SignExtTop      : std_logic;
  signal RegWriteTop     : std_logic;
  signal WriteDestTop    : std_logic_vector(1 downto 0);
  signal BranchTargetTop : std_logic_vector(7 downto 0);
  signal JumpTargetTop   : std_logic_vector(7 downto 0);
  signal RegTargetTop    : std_logic_vector(7 downto 0);
  signal PCPlusOneTop    : std_logic_vector(7 downto 0);
  signal OpcodeTop       : std_logic_vector(5 downto 0);
  signal RtTop           : std_logic_vector(4 downto 0);
  signal RsTop           : std_logic_vector(4 downto 0);
  signal FuncTop         : std_logic_vector(5 downto 0);
  signal PCPlusOneIFTop  : std_logic_vector(7 downto 0);
  signal ALUDataIDTop    : std_logic_vector(31 downto 0);
  signal MemDataIDTop    : std_logic_vector(31 downto 0);
  signal RofRsTop        : std_logic_vector(31 downto 0);
  signal RofRtIDTop      : std_logic_vector(31 downto 0);
  signal ShamtTop        : std_logic_vector(31 downto 0);
  signal WriteAddrIDTop  : std_logic_vector(4 downto 0);
  signal WriteAddrPMCUTop : std_logic_vector(4 downto 0);
  signal ImmTop          : std_logic_vector(31 downto 0);
  signal PCPlusOneIDTop  : std_logic_vector(31 downto 0);
  signal ALUResultOutEXETop : std_logic_vector(31 downto 0);
  signal ALUAddrTop      : std_logic_vector(7 downto 0);
  signal RofRtMemTop     : std_logic_vector(31 downto 0);
  signal WriteAddrEXETop : std_logic_vector(4 downto 0);
  signal CVZTop          : std_logic_vector(2 downto 0);
  signal WriteAddrMEMTop : std_logic_vector(4 downto 0);
  signal StallTop        : std_logic;
  signal BypassRsTop     : std_logic_vector(1 downto 0);
  signal BypassRtTop     : std_logic_vector(1 downto 0);
  signal ALUResultEXETop : std_logic_vector(31 downto 0);
  signal ALUResultMEMTop : std_logic_vector(31 downto 0);
  signal MemDataMEMTop   : std_logic_vector(31 downto 0);
    
begin
  
  -- signals to outs
  
    InstructionOutTop <= InstructionTop;
    GSEOutTop <= GSETop;
    PCSrcOutTop <= PCSrcTop;
    WithZeroOutTop <= WithZeroTop;
    MemWriteOutTop <= MemWriteTop;
    MemReadOutTop <= MemReadTop;
    ALUControlOutTop <= ALUControlTop;
    ALUSrcXOutTop <= ALUSrcXTop;
    ALUSrcYOutTop <= ALUSrcYTop;
    SignExtOutTop <= SignExtTop;
    RegWriteOutTop <= RegWriteTop;
    WriteDestOutTop <= WriteDestTop;
    BranchTargetOutTop <= BranchTargetTop;
    JumpTargetOutTop <= JumpTargetTop;
    RegTargetOutTop <= RegTargetTop;
    PCPlusOneOutTop <= PCPlusOneIFTop;
    RofRsOutTop <= RofRsTop;
    RofRtOutTop <= RofRtIDTop;
    ImmOutTop <= ImmTop;
    WriteAddrMEMOutTop <= WriteAddrMEMTop;
    
    
  
  -- stages
  
  memory:  entity work.p3_mem(mixed)
  port map(ALUResultInMEM => ALUResultOutEXETop,
           RofRtInMEM => RofRTMemTop,
           ALUAddrInMEM => ALUAddrTop,
           WriteAddrInMEM => WriteAddrEXETop,
           MemWriteInMEM => MemWriteTop,
           clk => clk,
           clken => clken,
           rst => rst,
           ALUResultOutID => ALUDataIDTop,
           MemDataOutID => MemDataIDTop);
  
  pmcu:  entity work.p3_pmcu(mixed)
  port map(clk => clk,
           rst => rst, 
           clken => clken,
	         OpcodeInPMCU => OpcodeTop,
           RtInPMCU => RtTop,
           WriteAddrInPMCU => WriteAddrIDTop,
           FuncInPMCU => FuncTop,
           GSEInPMCU => GSETop,
           PCSrcOutIF => PCSrcTop,
           WithZeroOutID => WithZeroTop,
           MemWriteOutMEM => MemWriteTop,
           MemReadOutIDWB => MemReadTop,
           ALUControlOutEXE => ALUControlTop,
           ALUSrcXOutEXE => ALUSrcXTop,
           ALUSrcYOutEXE => ALUSrcYTop,
           SignExtOutID => SignExtTop,
           RegWriteOutIDWB => RegWriteTop,
           WriteDestOutIDWB => WriteDestTop,
           WriteAddrOutIDWB => WriteAddrPMCUTop);
  
  fetch:  entity work.p3_fetch(mixed)
  port map(PCSrcInIF => PCSrcTop,
           BranchTargetInIF => BranchTargetTop,
           JumpTargetInIF => JumpTargetTop,
           RegTargetInIF => RegTargetTop,
           clken => clken,
           clk => clk,
           rst => rst,
	         InstructionOutID => InstructionTop,
           PCPlusOneOutID => PCPlusOneIFTop);
    
  decode:  entity work.p3_decode_wb(mixed)
  port map(InstructionInID => InstructionTop,
	         WriteAddrInID => WriteAddrPMCUTop,
           PCPlusOneInID => PCPlusOneIFTop,
           ALUDataInID => ALUDataIDTop,
           MemDataInID => MemDataIDTop,
           WriteDestInID => WriteDestTop,
           WithZeroInID => WithZeroTop,
           SignExtInID => SignExtTop,
           RegWriteInID => RegWriteTop,
           MemReadInID => MemReadTop,
           clk => clk,
           clken => clken,
           rst => rst,
           OpcodeOutPMCU => OpcodeTop,
           RtOutPMCU => RtTop,
           FuncOutPMCU => FuncTop,
           GSEOutPMCU => GSETop,
           RofRsOutEXE => RofRsTop,
           RofRtOutEXE => RofRtIDTop,
           ShamtOutEXE => ShamtTop,
           WriteAddrOutPMCU => WriteAddrIDTop, 
           ImmOutEXE => ImmTop,
           PCPlusOneOutEXE => PCPlusOneIDTop,
           BranchTargetOutIF => BranchTargetTop,
           JumpTargetOutIF => JumpTargetTop, 
           RegTargetOutIF => RegTargetTop,
           PCSrcOutIF => PCSrcOutTop);
    
  execute:  entity work.p3_execute(mixed)
  port map(RofRsInEXE => RofRsTop,
           RofRtInEXE => RofRtIDTop,
           ShamtInEXE => ShamtTop,
           WriteAddrInEXE => WriteAddrIDTop,
           ImmInEXE => ImmTop,
           PCPlusOneInEXE => PCPlusOneIDTop,
           ALUControlInEXE => ALUControlTop,
           ALUSrcXInEXE => ALUSrcXTop,
           ALUSrcYInEXE => ALUSrcYTop,
           rst => rst,
           clk => clk,
           clken => clken,
           ALUResultOutMEM => ALUResultOutEXETop,
           ALUAddrOutMEM => ALUAddrTop,
           RofRtOutMEM => RofRTMemTop,
           CVZOut => CVZTop);

end architecture mixed;



