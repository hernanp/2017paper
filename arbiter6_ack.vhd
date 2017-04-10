library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity arbiter6_ack is
	Generic (
		constant DATA_WIDTH  : positive := 73
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
            
            dout:	out std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack: 	in std_logic
     );
end arbiter6_ack;

-- version 2
architecture Behavioral of arbiter6_ack is

    signal s_ack1, s_ack2,s_ack3,s_ack4, s_ack5,s_ack6 : std_logic;
    signal s_token : integer :=0;
		
begin  
 	process (reset, clock)
 		variable nilreq : std_logic_vector(DATA_WIDTH - 1 downto 0):=(others => '0');
 		variable state : integer:=0;
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
        	if state = 0 then
					dout <= nilreq;
	            s_ack1 <= '0';
	            s_ack2 <= '0';   
	            s_ack3 <= '0'; 
	            s_ack4 <= '0';
	            s_ack5 <= '0';   
	            s_ack6 <= '0'; 
	            if din1(72 downto 72 ) ="1" then
	            	if s_ack1 = '0' then
	            		dout <= din1;
	            		state := 1;
	                end if; 
	            elsif din2(72 downto 72 ) ="1" then
	            	if s_ack2 = '0' then
	            		dout <= din2;
	            		state :=2;
	                end if; 
	         	elsif din3(72 downto 72 ) ="1" then
	            	if s_ack3 = '0' then
	            		dout <= din3;
	            		state :=3;
	                end if; 
	            elsif din4(72 downto 72 ) ="1" then
	            	if s_ack4 = '0' then
	            		dout <= din4;
	            		state :=4;
	                end if; 
	            elsif din5(72 downto 72 ) ="1" then
	            	if s_ack5 = '0' then
	            		dout <= din5;
	            		state :=5;
	                end if; 
	            elsif din6(72 downto 72 ) ="1" then
	            	if s_ack6 = '0' then
	            		dout <= din6;
	            		state :=6;
	                end if; 
	            end if;
	    elsif state =1 then
			dout <= nilreq;
			if ack ='1' then
	    		s_ack1 <= '1';
				state :=0;
			end if;
	    elsif state =2 then
		 dout <= nilreq;
	    		if ack ='1' then
	    		s_ack2 <= '1';
				state :=0;
			end if;								
	    elsif state =3 then
		 dout <= nilreq;
	    		if ack ='1' then
	    		s_ack3 <= '1';
				state :=0;
			end if;
	    elsif state =4 then
		 dout <= nilreq;
	    	if ack ='1' then
	    		s_ack4 <= '1';
				state :=0;
			end if;
	    elsif state =5 then
		 dout <= nilreq;
	    	if ack ='1' then
	    		s_ack5 <= '1';
				state :=0;
			end if;
	    elsif state =6 then
		 dout <= nilreq;
	    	if ack ='1' then
	    		s_ack6 <= '1';
				state :=0;
			end if;
	    end if;
        end if;
        ack1 <= s_ack1;
        ack2 <= s_ack2;
        ack3 <= s_ack3;
        ack4 <= s_ack4;
        ack5 <= s_ack5;
        ack6 <= s_ack6;
    end process;
end architecture Behavioral;   