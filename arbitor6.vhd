library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity arbiter6 is
	Generic (
		constant DATA_WIDTH  : positive := 51
	);
    Port (
            clock: in std_logic;
            reset: in std_logic;
            
            din1: 	in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
            ack1: 	out STD_LOGIC;
            
            din2:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack2:	out std_logic;
            
            din3:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack3:	out std_logic;
            
            din4:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack4:	out std_logic;
            
            din5:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack5:	out std_logic;
            
            din6:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack6:	out std_logic;
            
            dout:	out std_logic_vector(DATA_WIDTH - 1 downto 0)
     );
end arbiter6;

-- version 2
architecture Behavioral of arbiter6 is

    signal s_ack1, s_ack2,s_ack3,s_ack4, s_ack5,s_ack6 : std_logic;
    signal s_token : integer :=0;
		
begin  
 	process (reset, clock)
        variable nilreq : std_logic_vector(DATA_WIDTH - 1 downto 0):=(others => '0');
        variable cmd: std_logic_vector( 5 downto 0);
    begin
        if reset = '1' then
        	s_token <= 0;
        	s_ack1 <= '0';
        	s_ack2 <= '0';
        	s_ack3 <= '0';
        	s_ack4 <= '0';
        	s_ack5 <= '0';
        	s_ack6 <= '0';
        	dout <=  nilreq;
        elsif rising_edge(clock) then
        	cmd:= din1(DATA_WIDTH-1 downto DATA_WIDTH-1) & din2(DATA_WIDTH-1 downto DATA_WIDTH-1)& din3(DATA_WIDTH-1 downto DATA_WIDTH-1)&din4(DATA_WIDTH-1 downto DATA_WIDTH-1) & din5(DATA_WIDTH-1 downto DATA_WIDTH-1)& din6(DATA_WIDTH-1 downto DATA_WIDTH-1);
        	dout <= nilreq;
            s_ack1 <= '0';
            s_ack2 <= '0';   
            s_ack3 <= '0'; 
            s_ack4 <= '0';
            s_ack5 <= '0';   
            s_ack6 <= '0'; 
            case cmd is                  		      
                when "010000" =>
                	if s_ack2 = '0' then
                    	dout <=  din2;
                    	s_ack2 <= '1';
                    end if;
                when "100000" =>
                	if s_ack1 = '0' then
                    	dout <= din1;
                    	s_ack1 <= '1';
                    end if;
                when "001000" =>
                	if s_ack3 = '0' then
                    	dout <= din3;
                    	s_ack3 <= '1';
                    end if;
                when "000000" =>
                when "111000" =>
                    if s_token = 0 and s_ack2 ='0' then
                        dout <= din2;
                    	s_ack2 <= '1';
                    	s_token <= 1;
                    elsif s_token = 1 and s_ack1 ='0' then
                        dout <= din1;
                    	s_ack1 <= '1';
                    	s_token <= 2;
                    elsif s_token = 2 and s_ack3 ='0' then
                    	dout <= din3;
                    	s_ack3 <= '1';
                    	s_token <= 0;	
                    end if;
               when "011000" =>
               		if s_token < 1 and s_ack2 ='0' then
                        dout <= din2;
                    	s_ack2 <= '1';
                    	s_token <= 2;
                    elsif  s_ack3 ='0' then
                    	dout <= din3;
                    	s_ack3 <= '1';
                    	s_token <= 0;	
                    end if;
              when "110000" =>
               		if s_token < 1 and s_ack1 ='0' then
                        dout <= din1;
                    	s_ack1 <= '1';
                    	s_token <= 1;
                    elsif  s_ack2 ='0' then
                    	dout <= din2;
                    	s_ack2 <= '1';
                    	s_token <= 0;	
                    end if;
              when "101000" =>
               		if s_token < 1 and s_ack1 ='0' then
                        dout <= din1;
                    	s_ack1 <= '1';
                    	s_token <= 1;
                    elsif  s_ack3 ='0' then
                    	dout <= din3;
                    	s_ack3 <= '1';
                    	s_token <= 0;	
                    end if;
             when others =>
            end case;
        end if;
        ack1 <= s_ack1;
        ack2 <= s_ack2;
        ack3 <= s_ack3;
        ack4 <= s_ack4;
        ack5 <= s_ack5;
        ack6 <= s_ack6;
    end process;
end architecture Behavioral;   