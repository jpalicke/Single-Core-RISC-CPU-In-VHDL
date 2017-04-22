--------------------------------
-- Name:  Joseph Palicke
-- Class:  ECE37100
-- Project: P3 processor
-- Task: Instruction Fetch Stage
-- File:  p3_fetch.vhd
--------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_fetch is
	port(  PCSrcInIF        : in std_logic_vector(1 downto 0);
         BranchTargetInIF : in std_logic_vector(7 downto 0);
         JumpTargetInIF   : in std_logic_vector(7 downto 0);
         RegTargetInIF    : in std_logic_vector(7 downto 0);
         clken            : in std_logic;
         clk              : in std_logic;
         rst              : in std_logic;        
	       InstructionOutID : out std_logic_vector(31 downto 0);
         PCPlusOneOutID   : out std_logic_vector(7 downto 0));
end entity p3_fetch;

architecture mixed of p3_fetch is
  
  signal AddressIF        : std_logic_vector(7 downto 0);
  signal InstructionIF    : std_logic_vector(31 downto 0);
  signal PsuedoAddressIF  : std_logic_vector(7 downto 0);
  signal PCPlusOneIF      : std_logic_vector(7 downto 0);
  
begin
  
  --instructionROM
  instROM: entity work.instructionROM(SYN)
    port map(address => AddressIF,
             clken => clken,
             clock => clk,
             q => InstructionIF );
             
  -- increment PC
  
  PCPlusOneIF <= std_logic_vector(unsigned(PsuedoAddressIF) + to_unsigned(1,8));
             
  -- PC Source Mux
  
  with PCSrcInIF select
    AddressIF <=  BranchTargetInIF when "01",
                  JumpTargetInIF when "10",
                  RegTargetInIF when "11",
                  PCPlusOneIF when others;  
              
  -- pipeline flops and pseudo PC
  
 	pipeline_flops_and_PC : process(rst, clk) is
	begin
		if rst = '1' then 
			PCPlusOneOutID <= (others => '0');
			InstructionOutID <= (others => '0');
			--psuedoPC
			PsuedoAddressIF <= (others => '1');
		elsif rising_edge(clk) then
			if (clken = '1') then
				InstructionOutID <= InstructionIF;
				PCPlusOneOutID <= PCplusOneIF;
				--psuedoPC
				PsuedoAddressIF <= AddressIF;
			end if;
		end if;
	end process pipeline_flops_and_PC;         
    
end architecture mixed;

