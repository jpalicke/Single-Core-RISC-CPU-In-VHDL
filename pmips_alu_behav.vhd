-----------------------------
-- Name:  Joseph Palicke
-- ECE 37100
-- Lab:  Lab 5
-- Task:  Task 2
-- File: pmips_alu_behav.vhd
-----------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pmips_alu_behav is 
  generic (LG_SIZE : positive := 3);
	port(x, y        : in std_logic_vector(2**LG_SIZE-1 downto 0);
	     funct       : in std_logic_vector(3 downto 0);
	     result      : out std_logic_vector(2**LG_SIZE-1 downto 0);
	     CVZ         : out std_logic_vector(2 downto 0));
end entity pmips_alu_behav;

architecture behavior of pmips_alu_behav is 

--constants

  constant ONE        : std_logic := '1';
  constant ZERO       : std_logic := '0'; 
  constant ZEROS      : std_logic_vector(2**LG_SIZE-1 downto 0) := (others => '0');

  constant RIGHT_LOG   : std_logic_vector(1 downto 0) := "00";
  constant RIGHT_ATH   : std_logic_vector(1 downto 0) := "01";
  constant LEFT_LOG    : std_logic_vector(1 downto 0) := "10";
  
  constant OPS_LOG     : std_logic_vector(1 downto 0) := "00";
  constant OPS_ARITH   : std_logic_vector(1 downto 0) := "01";
  constant OPS_COMP    : std_logic_vector(1 downto 0) := "10";
  constant OPS_SHIFT   : std_logic_vector(1 downto 0) := "11";
  
  constant FUNCT_AND   : std_logic_vector(3 downto 0) := "0000" ;
  constant FUNCT_OR    : std_logic_vector(3 downto 0) := "0001" ;
  constant FUNCT_XOR   : std_logic_vector(3 downto 0) := "0010" ;
  constant FUNCT_NOR   : std_logic_vector(3 downto 0) := "0011" ;
  constant FUNCT_ADDU  : std_logic_vector(3 downto 0) := "0100" ;
  constant FUNCT_ADD   : std_logic_vector(3 downto 0) := "0101" ;
  constant FUNCT_SUBU  : std_logic_vector(3 downto 0) := "0110" ;
  constant FUNCT_SUB   : std_logic_vector(3 downto 0) := "0111" ;
  constant FUNCT_SLTU  : std_logic_vector(3 downto 0) := "1010" ;
  constant FUNCT_SLT   : std_logic_vector(3 downto 0) := "1011" ;
  constant FUNCT_SRL   : std_logic_vector(3 downto 0) := "1100" ;
  constant FUNCT_SRA   : std_logic_vector(3 downto 0) := "1101" ;
  constant FUNCT_SLL   : std_logic_vector(3 downto 0) := "1110" ;
  

--signals
  
  signal C                   : std_logic; 
  signal V_sub, V_add        : std_logic;
  signal Z                   : std_logic;
  
  signal x_op, y_op, slt_f   : unsigned(2**LG_SIZE-1 downto 0);
  signal arith_f             : unsigned(2**LG_SIZE+1 downto 0);
  signal log_right_shft      : unsigned(2**LG_SIZE-1 downto 0);
  signal log_left_shft       : unsigned(2**LG_SIZE-1 downto 0);
  signal arith_right_shft    : signed(2**LG_SIZE-1 downto 0);
  signal shift_f             : unsigned(2**LG_SIZE-1 downto 0);
  signal count               : natural;
  
  signal bit_and, bit_or     : std_logic_vector(2**LG_SIZE-1 downto 0);
  signal bit_xor, bit_nor    : std_logic_vector(2**LG_SIZE-1 downto 0);
  signal logic_f             : std_logic_vector(2**LG_SIZE-1 downto 0);
  signal shift_operand       : std_logic_vector(2**LG_SIZE-1 downto 0);
  signal reversed            : std_logic_vector(2**LG_SIZE-1 downto 0);
  signal y_invert, answer	   : std_logic_vector(2**LG_SIZE-1 downto 0);
  
--aliases

  alias sign_sel      :  std_logic is funct(0);
  alias sub_sel       :  std_logic is funct(1);
  alias left_sel      :  std_logic is funct(1);
  alias arith_sel     :  std_logic is funct(0);
  alias funct_sel     :  std_logic_vector(1 downto 0) is funct(1 downto 0);
  alias block_sel     :  std_logic_vector(1 downto 0) is funct(3 downto 2);
  alias x_sign        :  std_logic is x(2**LG_SIZE-1);
  alias y_sign        :  std_logic is y(2**LG_SIZE-1);
  alias result_sign   :  std_logic is arith_f(2**LG_SIZE);
  alias cout          :  std_logic is arith_f(2**LG_SIZE+1);
  alias shift_amt     :  std_logic_vector is x(LG_SIZE-1 downto 0);   
 
begin

--addition/subtraction

--invert y for subtraction
  
  invert: for i in 2**LG_SIZE-1 downto 0 generate
	  y_invert(i) <= y(i) xor sub_sel;
  end generate;

--adder

  arith_f  <= unsigned(ZERO & x & ONE) 
              + unsigned(ZERO & y_invert & sub_sel);

--flags  
  
  C <= ((cout and (not sub_sel)) or ((not cout) and sub_sel)); 

  V_add <= (x_sign and y_sign and (not result_sign)) or 
           ((not x_sign) and (not y_sign) and result_sign);
  V_sub <= (x_sign and (not y_sign) and (not result_sign)) or
           ((not x_sign) and y_sign and result_sign);
      
--slt
  
--conditionally inverts sign bits for signed ops
  
  x_op <= unsigned((x_sign xor sign_sel) & x(2**LG_SIZE-2 downto 0));
  y_op <= unsigned((y_sign xor sign_sel) & y(2**LG_SIZE-2 downto 0));
  
  slt_f <= to_unsigned(1,2**LG_SIZE) when x_op < y_op else to_unsigned(0,2**LG_SIZE); 
             
--shift

  count <= to_integer(unsigned(shift_amt));
  
--pre-reversal and post reversal for handling left shift  
  
  bit_reverse: for i in 2**LG_SIZE-1 downto 0 generate
    reversed(i) <= y((2**LG_SIZE-1)-i);
  end generate;
  bit_correct: for i in 2**LG_SIZE-1 downto 0 generate
    log_left_shft(i) <= log_right_shft((2**LG_SIZE-1)-i);
  end generate;
  
--selecting signal fed to the shifter, either reversed or
--original based on funct(1)
  
  with left_sel select
    shift_operand  <= reversed when ONE,
                     y when others;
  
--selecting output of shift block based on funct(1 downto 0)  
                 
  with funct_sel select
    shift_f <= unsigned(arith_right_shft) when RIGHT_ATH,
               log_left_shft when LEFT_LOG,
               log_right_shft when others;
   
                 
  arith_right_shft <= shift_right(signed(shift_operand), count); 
  
  log_right_shft <= shift_right(unsigned(shift_operand), count);
      
--logic functions

  bit_and <= x and y;
  bit_or  <= x or y;
  bit_xor <= x xor y;
  bit_nor <= x nor y;
  
--selecting logic function to send to output mux  
  
  with funct select
    logic_f <= bit_and when FUNCT_AND,
               bit_or  when FUNCT_OR,
               bit_xor when FUNCT_XOR,
               bit_nor when others;
       
--select output based on top two bits of function opcode

  Z <= ONE when answer = ZEROS else ZERO;
  result <= answer;

  with block_sel select
    answer <= logic_f when OPS_LOG,
              std_logic_vector(arith_f(2**LG_SIZE downto 1)) when OPS_ARITH,
              std_logic_vector(slt_f) when OPS_COMP,
              std_logic_vector(shift_f) when others;
              
              
  with funct select
    CVZ <= C & ZERO & Z when FUNCT_ADDU,
           C & ZERO & Z when FUNCT_SUBU,
           ZERO & V_add & Z when FUNCT_ADD,
           ZERO & V_sub & Z when FUNCT_SUB,
           ZERO & ZERO  & Z when others;
              
  
end architecture behavior;





