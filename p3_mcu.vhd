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

entity p3_mcu is
	port(OpcodeInMCU     : in std_logic_vector(5 downto 0);
       RtInMCU         : in std_logic;
       FuncInMCU       : in std_logic_vector(5 downto 0);
       GSEInMCU        : in std_logic_vector(2 downto 0);
       PCSrcOutID      : out std_logic_vector(1 downto 0);
       WithZeroOutID   : out std_logic;
       MemWriteOutID   : out std_logic;
       MemReadOutID    : out std_logic;
       ALUControlOutID : out std_logic_vector(3 downto 0);
       ALUSrcXOutID    : out std_logic_vector(1 downto 0);
       ALUSrcYOutID    : out std_logic_vector(1 downto 0);
       SignExtOutID    : out std_logic;
       RegWriteOutID   : out std_logic;
       WriteDestOutID  : out std_logic_vector(1 downto 0));
end entity p3_mcu;

architecture behavior of p3_mcu is
  
  constant ZERO  : std_logic := '0';
  constant ONE   : std_logic := '1';
  
  constant FIVE : integer := 5;
  constant EIGHT : integer := 8;
  constant SIXTEEN : integer := 16;
  constant THIRTYTWO : integer := 32;
  
  --instruction words
  
  constant ADDI      : std_logic_vector(15 downto 0) := "001000----------";
  constant ADDIU     : std_logic_vector(15 downto 0) := "001001----------";
  constant ANDI      : std_logic_vector(15 downto 0) := "001100----------";
  constant BEQ       : std_logic_vector(15 downto 0) := "000100---------1";
  constant BEQ_not   : std_logic_vector(15 downto 0) := "000100---------0";
  constant BGEZ_gr   : std_logic_vector(15 downto 0) := "0000011------1--";
  constant BGEZ_eq   : std_logic_vector(15 downto 0) := "0000011--------1";
  constant BGEZ_not  : std_logic_vector(15 downto 0) := "0000011------0-0";
  constant BLTZ      : std_logic_vector(15 downto 0) := "0000010-------1-";
  constant BLTZ_not  : std_logic_vector(15 downto 0) := "0000010-------0-";
  constant BGTZ      : std_logic_vector(15 downto 0) := "000111-------1--";
  constant BGTZ_not  : std_logic_vector(15 downto 0) := "000111-------0--";
  constant BLEZ_lt   : std_logic_vector(15 downto 0) := "000110--------1-";
  constant BLEZ_eq   : std_logic_vector(15 downto 0) := "000110---------1";
  constant BLEZ_not  : std_logic_vector(15 downto 0) := "000110--------00";
  constant BNE       : std_logic_vector(15 downto 0) := "000101---------0";
  constant BNE_not   : std_logic_vector(15 downto 0) := "000101---------1";
  constant J         : std_logic_vector(15 downto 0) := "000010----------";
  constant JAL       : std_logic_vector(15 downto 0) := "000011----------";
  constant LUI       : std_logic_vector(15 downto 0) := "001111----------";
  constant LW        : std_logic_vector(15 downto 0) := "100011----------";
  constant ORI       : std_logic_vector(15 downto 0) := "001101----------";
  constant SLTI      : std_logic_vector(15 downto 0) := "001010----------";
  constant SLTIU     : std_logic_vector(15 downto 0) := "001011----------";
  constant SW        : std_logic_vector(15 downto 0) := "101011----------";
  constant XORI      : std_logic_vector(15 downto 0) := "001110----------";
  constant ADD       : std_logic_vector(15 downto 0) := "000000-100000---";
  constant ADDU      : std_logic_vector(15 downto 0) := "000000-100001---";
  constant AND_OP    : std_logic_vector(15 downto 0) := "000000-100100---";
  constant JALR      : std_logic_vector(15 downto 0) := "000000-001001---";
  constant JR        : std_logic_vector(15 downto 0) := "000000-001000---";
  constant NOR_OP    : std_logic_vector(15 downto 0) := "000000-100111---";
  constant OR_OP     : std_logic_vector(15 downto 0) := "000000-100101---";
  constant SLL_OP    : std_logic_vector(15 downto 0) := "000000-000000---";
  constant SLLV      : std_logic_vector(15 downto 0) := "000000-000100---";
  constant SLT       : std_logic_vector(15 downto 0) := "000000-101010---";
  constant SLTU      : std_logic_vector(15 downto 0) := "000000-101011---";
  constant SRA_OP    : std_logic_vector(15 downto 0) := "000000-000011---";
  constant SRAV      : std_logic_vector(15 downto 0) := "000000-000111---";
  constant SRL_OP    : std_logic_vector(15 downto 0) := "000000-000010---";
  constant SRLV      : std_logic_vector(15 downto 0) := "000000-000110---";
  constant SUB       : std_logic_vector(15 downto 0) := "000000-100010---";
  constant SUBU      : std_logic_vector(15 downto 0) := "000000-100011---";
  constant XOR_OP    : std_logic_vector(15 downto 0) := "000000-100110---";
  
  
  constant ZEROS  : std_logic_vector(31 downto 0) := (others => '0');
  
  signal inst_wordMCU      : std_logic_vector(15 downto 0);
  signal ctrl_wordMCU      : std_logic_vector(16 downto 0);
  
  alias PCSrcMCU           : std_logic_vector(1 downto 0) is ctrl_wordMCU(16 downto 15);
  alias WriteDestMCU       : std_logic_vector(1 downto 0) is ctrl_wordMCU(14 downto 13);
  alias WithZeroMCU        : std_logic is ctrl_wordMCU(12);
  alias MemWriteMCU        : std_logic is ctrl_wordMCU(11);
  alias MemReadMCU         : std_logic is ctrl_wordMCU(10);
  alias ALUControlMCU      : std_logic_vector(3 downto 0) is ctrl_wordMCU(9 downto 6);
  alias ALUSrcXMCU         : std_logic_vector(1 downto 0) is ctrl_wordMCU(5 downto 4);
  alias ALUSrcYMCU         : std_logic_vector(1 downto 0) is ctrl_wordMCU(3 downto 2);
  alias SignExtMCU         : std_logic is ctrl_wordMCU(1);
  alias RegWriteMCU        : std_logic is ctrl_wordMCU(0);
  
  
begin
  

  PCSrcOutID <= PCSrcMCU; 
  WriteDestOutID <= WriteDestMCU;
  MemWriteOutID <= MemWriteMCU;
  RegWriteOutID <= RegWriteMCU;
  
  WithZeroOutID <= ONE when std_match(ONE, WithZeroMCU) else ZERO;
  MemReadOutID <= ONE when std_match(ONE, MemReadMCU) else ZERO;
  SignExtOutID <= ONE when std_match(ONE, SignExtMCU) else ZERO;
  
  ALUControlOutID <= "0000" when std_match(ALUControlMCU,"0000") else
                     "0001" when ALUControlMCU = "0001" else
                     "0010" when ALUControlMCU = "0010" else
                     "0011" when ALUControlMCU = "0011" else
                     "0100" when ALUControlMCU = "0100" else
                     "0101" when ALUControlMCU = "0101" else
                     "0110" when ALUControlMCU = "0110" else
                     "0111" when ALUControlMCU = "0111" else
                     "1010" when ALUControlMCU = "1010" else
                     "1011" when ALUControlMCU = "1011" else
                     "1100" when ALUControlMCU = "1100" else
                     "1101" when ALUControlMCU = "1101" else
                     "1110";
                     
  ALUSrcXOutID <= "01" when ALUSrcXMCU = "01" else
                  "10" when ALUSrcXMCU = "10" else
                  "11" when ALUSrcXMCU = "11" else
                  "00";                   
                     
  ALUSrcYOutID <= "01" when ALUSrcYMCU = "01" else
                  "10" when ALUSrcYMCU = "10" else
                  "00";
  
  inst_wordMCU <= OpcodeInMCU & RtInMCU & FuncInMCU & GSEInMCU;
  
    ctrl_wordMCU <= "0000-000101000111" when std_match(ADDI,inst_wordMCU) else
                    "0000-000101000111" when std_match(ADDIU,inst_wordMCU) else
                    "0000-000000000101" when std_match(ANDI,inst_wordMCU) else
                    "0100000---------0" when std_match(BEQ,inst_wordMCU) else
                    "0000000---------0" when std_match(BEQ_not,inst_wordMCU) else
                    "0100100---------0" when std_match(BGEZ_gr,inst_wordMCU) else
                    "0100100---------0" when std_match(BGEZ_eq,inst_wordMCU) else
                    "0000100---------0" when std_match(BGEZ_not,inst_wordMCU) else
                    "0100100---------0" when std_match(BLTZ,inst_wordMCU) else
                    "0000100---------0" when std_match(BLTZ_not,inst_wordMCU) else
                    "0100100---------0" when std_match(BGTZ,inst_wordMCU) else
                    "0000100---------0" when std_match(BGTZ_not,inst_wordMCU) else
                    "0100100---------0" when std_match(BLEZ_lt,inst_wordMCU) else
                    "0100100---------0" when std_match(BLEZ_eq,inst_wordMCU) else
                    "0000100---------0" when std_match(BLEZ_not,inst_wordMCU) else
                    "0100000---------0" when std_match(BNE,inst_wordMCU) else
                    "0000000---------0" when std_match(BNE_not,inst_wordMCU) else
                    "1000-00---------0" when std_match(J,inst_wordMCU) else
                    "1010-0001010110-1" when std_match(JAL,inst_wordMCU) else
                    "0000-001110110111" when std_match(LUI,inst_wordMCU) else
                    "0000-010101000111" when std_match(LW,inst_wordMCU) else
                    "0000-000001000101" when std_match(ORI,inst_wordMCU) else
                    "0000-001011000111" when std_match(SLTI,inst_wordMCU) else
                    "0000-0010100001-1" when std_match(SLTIU,inst_wordMCU) else
                    "0000-100101000110" when std_match(SW,inst_wordMCU) else
                    "0000-000010000101" when std_match(XORI,inst_wordMCU) else
                    "0001-0001010000-1" when std_match(ADD,inst_wordMCU) else
                    "0001-0001010000-1" when std_match(ADDU,inst_wordMCU) else
                    "0001-0000000000-1" when std_match(AND_OP,inst_wordMCU) else
                    "1110-0001010110-1" when std_match(JALR,inst_wordMCU) else
                    "1101-00---------0" when std_match(JR,inst_wordMCU) else
                    "0001-0000110000-1" when std_match(NOR_OP,inst_wordMCU) else
                    "0001-0000010000-1" when std_match(OR_OP,inst_wordMCU) else
                    "0001-0011101000-1" when std_match(SLL_OP,inst_wordMCU) else
                    "0001-0011100000-1" when std_match(SLLV,inst_wordMCU) else
                    "0001-0010110000-1" when std_match(SLT,inst_wordMCU) else
                    "0001-001010000001" when std_match(SLTU,inst_wordMCU) else
                    "0001-0011011000-1" when std_match(SRA_OP,inst_wordMCU) else
                    "0001-0011010000-1" when std_match(SRAV,inst_wordMCU) else
                    "0001-0011001000-1" when std_match(SRL_OP,inst_wordMCU) else
                    "0001-0011000000-1" when std_match(SRLV,inst_wordMCU) else
                    "0001-0001110000-1" when std_match(SUB,inst_wordMCU) else
                    "0001-0001110000-1" when std_match(SUBU,inst_wordMCU) else
                    "0001-0000100000-1" when std_match(XOR_OP,inst_wordMCU) else
                    "00000000000000000";

end architecture behavior;

