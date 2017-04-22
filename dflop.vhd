library ieee;
use ieee.std_logic_1164.all;

entity dflop is
	generic( SIZE : positive := 4 );
	port( clk   : in  std_logic;
	      rst   : in  std_logic;	--asynchronous
	      clken : in  std_logic;
		  din   : in  std_logic_vector(SIZE-1 downto 0);
	      q     : out std_logic_vector(SIZE-1 downto 0) );
end entity dflop;

architecture behavior of dflop is
begin
	flop : process(rst, clk) is
	begin
		if rst = '1' then 
			q <= (others => '0');
		elsif rising_edge(clk) then
			if clken = '1' then
				q <= din;
			end if;
		end if;
	end process flop;
end architecture behavior;
