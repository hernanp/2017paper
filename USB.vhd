
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.nondeterminism.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity USB is
    Port (  Clock: in std_logic;
            reset: in std_logic;
             ---write address chanel
            waddr: in std_logic_vector(31 downto 0);
            wlen: in std_logic_vector(9 downto 0);
            wsize: in std_logic_vector(9 downto 0);
            wvalid: in std_logic;
            wready: out std_logic;
            ---write data channel
            wdata: in std_logic_vector(31 downto 0);
            wtrb: in std_logic_vector(3 downto 0);
            wlast: in std_logic;
            wdvalid: in std_logic;
            wdataready: out std_logic;
            ---write response channel
            wrready: in std_logic;
            wrvalid: out std_logic;
            wrsp: out std_logic_vector(1 downto 0);
            
            ---read address channel
            raddr: in std_logic_vector(31 downto 0);
            rlen: in std_logic_vector(9 downto 0);
            rsize: in std_logic_vector(9 downto 0);
            rvalid: in std_logic;
            rready: out std_logic;
            ---read data channel
            rdata: out std_logic_vector(31 downto 0);
            rstrb: out std_logic_vector(3 downto 0);
            rlast: out std_logic;
            rdvalid: out std_logic;
            rdready: in std_logic;
            rres: out std_logic_vector(1 downto 0);
            
            
            
            pwrreq: in std_logic_vector(2 downto 0);
            pwrres: out std_logic_vector(2 downto 0);
            
            upreq: out std_logic_vector(50 downto 0);
            upres: in std_logic_vector(50 downto 0);
            upreq_full: in std_logic
            );
end USB;

architecture Behavioral of USB  is
   signal poweron: std_logic :='1';
    type rom_type is array (2**16-1 downto 0) of std_logic_vector (31 downto 0);     
       signal ROM_array : rom_type:= (others=> (others=>'0'));
       signal in3,out3: std_logic_vector(53 downto 0);
       signal in2,out2: std_logic_vector(50 downto 0);
       signal we3,re3,we2,re2,emp3,emp2: std_logic:='0';
       signal tmp_full: std_logic;
       signal tmp_req: std_logic_vector(50 downto 0);
       signal test: integer;

begin

write: process (Clock, reset)
    variable address: integer;
    variable len: integer;
    variable size: std_logic_vector(9 downto 0);
    variable state : integer :=0;
    variable lp: integer:=0;
    begin
    if reset ='1' then
       wready <= '1';
       wdataready <= '0';
    elsif (rising_edge(Clock)) then
    	if state = 0 then
    	    wrvalid <= '0';
    	    wrsp <= "10";
    		if wvalid ='1' then
    			wready <='0';
    			address:=to_integer(unsigned(waddr));
    			len := to_integer(unsigned(wlen));
    			size := wsize;
    			state := 2;
    			wdataready <= '1';
    		end if;
    		
    	elsif state =2 then
    		if wdvalid ='1' then
    		---not sure if lengh or length -1
    			if lp < len-1 then
    			    wdataready <= '0';
    				---strob here is not considered
        			ROM_array(address+lp) <= wdata(31 downto 0);
        			lp := lp +1;
        			wdataready <= '1';
        			if wlast ='1' then
        				state := 3;
        			end if;
        		else
        			state := 3;
        		end if;
        		
    		end if;
    	elsif state = 3 then
    		if wrready = '1' then
    		    wrvalid <= '1';
    		    wrsp <= "00";
    		    state :=0;
    		end if;
    	end if;
    end if;
    end process;
    
    
    
    read: process (Clock, reset)
    variable address: integer;
    variable len: integer;
    variable size: std_logic_vector(9 downto 0);
    variable state : integer :=0;
    variable lp: integer:=0;
    variable dt: std_logic_vector(31 downto 0);
    begin
    if reset ='1' then
       rready <= '1';
       rdvalid <= '0';
       rstrb <= "1111";
       rlast <= '0';
       address := 0;
    elsif (rising_edge(Clock)) then
    	if state = 0 then
    		lp:=0;
    		if rvalid ='1' then
    			rready <='0';
    			address:=to_integer(unsigned(raddr(31 downto 4)));
    			tmp_int <= address;
    			len := to_integer(unsigned(rlen));
    			size := rsize;
    			state := 2;
    		end if;
    		
    	elsif state =2 then
    		if rdready = '1' then
    			if lp < 16 then
    			    rdvalid <= '1';
    				---strob here is not considered
    				---left alone , dono how to fix
    				---if ROM_array(address+lp) ="00000000000000000000000000000000" then
    					---ROM_array(address+lp) := selection(2**15-1,32);
    				---end if;
    				dt := selection(2**15-1,32);
        			---rdata <= dt;
        			rdata <= ROM_array(address);
        			lp := lp +1;
        			rres <= "00";
        			if lp = len then
        				state := 3;
        				rlast <= '1';
        			end if;
        		else
        			state := 3;
        		end if;
        		
    		end if;
    	elsif state = 3 then
    		rdvalid <= '0';
    		rready <='1';
    		rlast <= '0';
    		state := 0;
    	end if;
    end if;
    end process;
  
  l1: process (reset,Clock)
    
    variable tmplog: std_logic_vector(51 downto 0);
    variable enr: boolean:=false;
    variable enw: boolean:=true; 
    variable address: integer;
    variable flag: boolean:=false;
    variable nada: std_logic_vector(51 downto 0) :=(others=>'0');
    variable bo :boolean;
    variable nilmem: std_logic_vector(31 downto 0) := (others=>'0');
    variable tpmem: std_logic_vector(31 downto 0):= selection(2**31-1,32);
    variable state : integer :=0;
    variable tmp_req: std_logic_vector(53 downto 0);
    variable tmp_wb: std_logic_vector(50 downto 0);
    variable wt: integer:=0;
    begin
    if reset ='1' then
        res<=(others => '0');
        wb_ack <='0';
    elsif (rising_edge(Clock)) then
        test<=state;
        if state = 0 then
            if re3 = '0' and emp3 ='0' then
                re3 <='1';
                state :=6;
            elsif re2 ='0' and emp2 = '0' then
                re2 <= '1';
                state :=7;
            end if;
             res <= (others => '0');
                wb_ack <= '0';
            
       elsif state =6 then
            re3<='0';
            
            if out3(50 downto 50) = "1" then
               tmp_req := out3;
        	   address:=to_integer(unsigned(out3(47 downto 32)));
        	   if (out3(49 downto 48)="01") then
        	      state :=1;
        	      wt:=0;
        	   elsif (out3(49 downto 48)="10") then
        	      state :=2;
        	      wt :=0;
        	   end if;
            end if;
        elsif state =7 then
            re2 <='0';
            
            if out2(50 downto 50) = "1" then
                tmp_wb := out2;
        	   address:=to_integer(unsigned(out2(47 downto 32)));
        	   state :=3;     
        	   wt:=0;   	  
            end if;
        elsif state =1 then
            if wt < 20 then
                wt:= wt +1 ;
            else 
                state :=9;
                wt :=0;
            end if;
        elsif state =9 then
            res <= tmp_req(53 downto 32) & ROM_array(address);
            state :=0;
        elsif state =2 then
             if wt < 20 then
                wt:= wt +1 ;
             else
                state :=10;
                wt:=0;
             end if;
        elsif state =10 then   
             ROM_array(address) <= tmp_req(31 downto 0);
             res <= tmp_req;
             state := 0;
        elsif state =3 then
             if wt < 20 then
                 wt:= wt +1 ;
             else
                wt:=0;
                state := 11;
             end if;
       elsif state =11 then
             ROM_array(address) <= tmp_wb(31 downto 0);
             wb_ack <= '1';
             state :=0;
        end if;
    end if;
   end process;  
     
  pwr: process (Clock)
   begin
    if reset ='1' then
        pwrres<=(others => '0');
        
    elsif (rising_edge(Clock)) then
    	if pwrreq(2 downto 2)="1" then
    		if pwrreq( 1 downto 0) = "00" then
    			poweron <= '0';
    		elsif pwrreq(1 downto 0) ="10" then
    			poweron <= '1';
    		end if;
    		pwrres <= pwrreq;
    	else
    		pwrres <= "000";
    	end if;
        
    end if;
    end process;

end Behavioral;
