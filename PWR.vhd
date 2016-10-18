----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2015 11:10:38 PM
-- Design Name: 
-- Module Name: Memory - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PWR is
    Port (  Clock: in std_logic;
            reset: in std_logic;
            
            req : in STD_LOGIC_VECTOR(4 downto 0);
            res: out STD_LOGIC_VECTOR(4 downto 0);
            full_preq: out std_logic:='0';
            
            gfxres : in STD_LOGIC_VECTOR(2 downto 0);
            gfxreq : out STD_LOGIC_VECTOR(2 downto 0)
            );
            
end PWR;

architecture Behavioral of PWR is
	signal tmp_req: std_logic_vector(4 downto 0);
	signal in1,out1 : std_logic_vector(4 downto 0);
	signal in2,out2 : std_logic_vector(2 downto 0);
	signal we1,re1,emp1,we2,re2,emp2 : std_logic:='0';
begin

	pwr_req_fif: entity work.STD_FIFO(Behavioral) 
	generic map(
        DATA_WIDTH => 5,
        FIFO_DEPTH => 16
    )
	port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in1,
		WriteEn=>we1,
		ReadEn=>re1,
		DataOut=>out1,
		Full=>full_preq,
		Empty=>emp1
		);
		
	
	pwr_req_fifo: process (Clock)      
	begin
		if reset='1' then
			we1<='0';
		elsif rising_edge(Clock) then
			if req(4 downto 4)="1" then
				in1 <= req;
				we1 <= '1';
			else
				we1 <= '0';
			end if;
		end if;
	end process;
	
	
	
	req_p:process (reset, Clock)
        variable nilreq:std_logic_vector(4 downto 0):=(others => '0');
        variable state: integer :=0;
	begin
		if (reset = '1') then
			gfxreq<= nilreq(2 downto 0);
			--tmp_write_req <= nilreq;
		elsif rising_edge(Clock) then
			if state =0 then
				gfxreq <= nilreq(2 downto 0);
				if re1 = '0' and emp1 ='0' then
					re1 <= '1';
					state := 1;
				end if;
				
			elsif state = 1 then
				re1 <= '0';
				if out1(4 downto 4)="1" then
					if out1(1 downto 0)="00" then
						tmp_req <= out1;
						state := 2;
					end if;
				end if;
			elsif state = 2 then
				gfxreq<=tmp_req(4 downto 2);
				state := 3;
			elsif state = 3 then
				if gfxres(2 downto 2) = "1" then
					res <= tmp_req;
					state :=0;
				end if;
			end if;
		
		end if;
	end process;
        
	

end Behavioral;
