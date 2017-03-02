library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity arbiter3 is
    Port (
            clock: in std_logic;
            reset: in std_logic;
            
            din1: 	in STD_LOGIC_VECTOR(72 downto 0);
            ack1: 	out STD_LOGIC;
            
            din2:	in std_logic_vector(72 downto 0);
            ack2:	out std_logic;
            
            dout:	out std_logic_vector(73 downto 0);
            
            ack: in std_logic
            
     );
end arbiter3;

-- version 1
architecture Behavioral of arbiter3 is

    signal s_ack1, s_ack2 : std_logic;
		
begin  

	process (reset, clock)
        variable nilreq : std_logic_vector(72 downto 0):=(others => '0');
        variable cmd: std_logic_vector( 1 downto 0);
        variable state : integer :=0;
    begin
        if reset = '1' then
        	s_ack1 <= '0';
        	s_ack2 <= '0';
        	dout <= '0'& nilreq;
        elsif rising_edge(clock) then
			if state = 0 then
				cmd:= din1(72 downto 72) & din2(72 downto 72);
				case cmd is      
					when "00" =>
						dout <= '0'& nilreq;
						s_ack1 <= '0';
						s_ack2 <= '0';          
					when "01" =>
						if s_ack2 = '0' then
							dout <= '0'& din2;
							state := 2;
						else
							dout <= '0'& nilreq;
						end if;
					when "10" =>
						if s_ack1 = '0' then
							dout <= '1'& din1;
							state := 1;
						else
							dout <= '0'& nilreq;
						end if;
					when "11" =>
						if s_ack2 ='0' then
							dout <= '0'& din2;
							state := 2;
						elsif s_ack1 ='0' then
							dout <= '1'& din1;
							state := 1;
						else
							dout <= '0'& nilreq;
						end if;
					when others =>
				end case;
			elsif state =1 then
				if ack = '1' then
					state := 0;
					s_ack1 <= '1';
				end if;
			elsif state =2 then
				if ack = '1' then
					state := 0;
					s_ack2 <= '1';
				end if;
			end if;
        end if;
        ack1 <= s_ack1;
        ack2 <= s_ack2;
    end process;
end architecture Behavioral;   



