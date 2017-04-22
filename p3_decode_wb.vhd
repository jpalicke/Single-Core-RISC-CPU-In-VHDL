--------------------------------
-- Name:  Joseph Palicke
-- Class:  ECE37100
-- Project: P3 processor
-- Task: Instruction Decode Stage
-- File:  p3_decode_wb.vhd
--------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_decode_wb is
	port(InstructionInID   : in std_logic_vector(31 downto 0);
	     WriteAddrInID     : in std_logic_vector(4 downto 0);
       PCPlusOneInID     : in std_logic_vector(7 downto 0);
       ALUDataInID       : in std_logic_vector(31 downto 0);
       MemDataInID       : in std_logic_vector(31 downto 0);
       WriteDestInID     : in std_logic_vector(1 downto 0);
       WithZeroInID      : in std_logic;
       SignExtInID       : in std_logic;
       RegWriteInID      : in std_logic;
       MemReadInID       : in std_logic;
       clk               : in std_logic;
       clken             : in std_logic;
       rst               : in std_logic;
       OpcodeOutPMCU     : out std_logic_vector(5 downto 0);
       RtOutPMCU         : out std_logic_vector(4 downto 0);   
       FuncOutPMCU       : out std_logic_vector(5 downto 0);
       GSEOutPMCU        : out std_logic_vector(2 downto 0);
       RofRsOutEXE       : out std_logic_vector(31 downto 0);
       RofRtOutEXE       : out std_logic_vector(31 downto 0);
       ShamtOutEXE       : out std_logic_vector(31 downto 0);
       WriteAddrOutPMCU  : out std_logic_vector(4 downto 0);
       ImmOutEXE         : out std_logic_vector(31 downto 0);
       PCPlusOneOutEXE   : out std_logic_vector(31 downto 0);
       BranchTargetOutIF : out std_logic_vector(7 downto 0);
       JumpTargetOutIF   : out std_logic_vector(7 downto 0); 
       RegTargetOutIF    : out std_logic_vector(7 downto 0);
       PCSrcOutIF        : out std_logic_vector(1 downto 0));
end entity p3_decode_wb;

architecture mixed of p3_decode_wb is
  
  constant ZERO  : std_logic := '0';
  constant ONE   : std_logic := '1';
  
  constant FIVE : integer := 5;
  constant EIGHT : integer := 8;
  constant SIXTEEN : integer := 16;
  constant THIRTYTWO : integer := 32;
  
  constant ZEROS  : std_logic_vector(31 downto 0) := (others => '0');
  
  signal PCSrcID          : std_logic_vector(1 downto 0);
  signal PCPlusOneID      : std_logic_vector(31 downto 0);
  signal RofRsID          : std_logic_vector(31 downto 0);
  signal RofRtID          : std_logic_vector(31 downto 0);
  signal RegWriteID       : std_logic;
  signal ShamtID          : std_logic_vector(31 downto 0);
  signal ImmID            : std_logic_vector(31 downto 0);
  signal BTC32YInputID    : std_logic_vector(31 downto 0);
  signal WriteDataID      : std_logic_vector(31 downto 0);
  signal GSEID            : std_logic_vector(2 downto 0);
  signal WriteAddrID      : std_logic_vector(4 downto 0);
  signal BranchTargetID   : unsigned(7 downto 0);
  
  alias IWOpcodeID  : std_logic_vector(5 downto 0) is InstructionInID(31 downto 26);
  alias IWRsID      : std_logic_vector(4 downto 0) is InstructionInID(25 downto 21);
  alias IWRtID      : std_logic_vector(4 downto 0) is InstructionInID(20 downto 16);
  alias IWRdID      : std_logic_vector(4 downto 0) is InstructionInID(15 downto 11);
  alias IWShamtID   : std_logic_vector(4 downto 0) is InstructionInID(10 downto 6);
  alias IWFuncID    : std_logic_vector(5 downto 0) is InstructionInID(5 downto 0);
  alias IWImmID     : std_logic_vector(15 downto 0) is InstructionInID(15 downto 0);
  alias IWAddrID    : std_logic_vector(7 downto 0) is InstructionInID(7 downto 0);
  
begin
  
  -- feed opcode, funct, rt, and GSE to PMCU
  
  OpcodeOutPMCU <= IWOpcodeID;
  FuncOutPMCU <= IWFuncID;
  RtOutPMCU <= IWRtID;
  GSEOutPMCU  <= GSEID;
  
  -- select Write Address
  
  with WriteDestInID select
    WriteAddrID <= IWRdID when "01",
                   "11111" when "10",
                   IWRtID when others;
  
  
  -- select WriteDataID source
  
  with MemReadInID select
    WriteDataID <= MemDataInID when ONE,
                   ALUDataInID when others;
  
  
  -- instantiate the ARF
  
  RegisterFile: entity work.arf32_config(mixed)
    generic map(SIZE => THIRTYTWO, R0_HW => true, FWD => true)
    port map(clk => clk,
             rst => rst,
             wren => RegWriteInID,
             rdaddr1 => IWRsID,
             rdaddr2 => IWRtID,
             wraddr => WriteAddrInID,
             wrdata => WriteDataID,
             rddata1 => RofRsID,
             rddata2 => RofRtID);
             
  -- instantiate the comparator and select the y operand source
  
  BTC32YInputID <= ZEROS when std_match(WithZeroInID,ONE) else RofRtID;
                     
  comparator: entity work.btc_32bit(structure)
    generic map(SIGNED_OPS => TRUE)
    port map(x => RofRsID,
             y => BTC32YInputID,
             zG => GSEID(2),
             zS => GSEID(1),
             zE => GSEID(0));
  
  -- extend pc + 1
  
  pcplusone: entity work.elu(dataflow)
    generic map (ISIZE => EIGHT, OSIZE => THIRTYTWO)
    port map (A => PCPlusOneInID, 
              twos_cmp => ZERO, 
              Y => PCPlusOneID);
              
  -- extend immediate
  
  immediate: entity work.elu(dataflow)
    generic map (ISIZE => SIXTEEN, OSIZE => THIRTYTWO)
    port map (A => IWImmID, 
              twos_cmp => SignExtInID, 
              Y => ImmID);
              
  -- extend shamt
  
  shamt: entity work.elu(dataflow)
    generic map (ISIZE => FIVE, OSIZE => THIRTYTWO)
    port map (A => IWShamtID, 
              twos_cmp => ZERO, 
              Y => ShamtID);
  
  -- non piped outputs
  
  BranchTargetID <= (unsigned(IWAddrID)) + (unsigned(PCPlusOneInID));
  BranchTargetOutIF <= std_logic_vector(BranchTargetID);
  JumpTargetOutIF <= InstructionInID(7 downto 0);
  RegTargetOutIF <= RofRsID(7 downto 0);
  PCSrcOutIF <= PCSrcID;
  RtOutPMCU <= IWRtID;
  WriteAddrOutPMCU <= WriteAddrID;
              
  -- pipeline flops
  
  IDPipeline : process(rst, clk) is
	begin
		if rst = ONE then 
			RofRsOutEXE <= ZEROS;
			RofRtOutEXE <= ZEROS;
			ShamtOutEXE <= ZEROS;
			ImmOutEXE <= ZEROS;
			PCPlusOneOutEXE <= ZEROS;
		elsif rising_edge(clk) then
			if (clken = ONE) then
				RofRsOutEXE <= RofRsID;
				RofRtOutEXE <= RofRtID;
				ShamtOutEXE <= ShamtID;
				ImmOutEXE <= ImmID;
				PCPlusOneOutEXE <= PCPlusOneID;
			end if;
		end if;
	end process IDPipeline;        

end architecture mixed;
