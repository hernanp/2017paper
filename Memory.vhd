
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.nondeterminism.all;

entity Memory is
    Port (  Clock: in std_logic;
            reset: in std_logic;
            full_b_m: in std_logic;
            req : in STD_LOGIC_VECTOR(51 downto 0);
            wb_req: in std_logic_vector(50 downto 0);
            res: out STD_LOGIC_VECTOR(51 downto 0);
            wb_ack: out std_logic;
            full_m: out std_logic:='0');
end Memory;

architecture Behavioral of Memory is
     type rom_type is array (2**16-1 downto 0) of std_logic_vector (31 downto 0);     
     signal ROM_array : rom_type:= (others=> (others=>'0'));
     signal in3,out3: std_logic_vector(51 downto 0);
     signal in2,out2: std_logic_vector(50 downto 0);
     signal we3,re3,we2,re2,emp3,emp2: std_logic:='0';
     signal tmp_full: std_logic;
    
     signal test: integer;
begin
    wb_fif: entity  work.STD_FIFO(Behavioral) 
	generic map(
		DATA_WIDTH => 51,
		FIFO_DEPTH => 256
	)
	port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in2,
		WriteEn=>we2,
		ReadEn=>re2,
		DataOut=>out2,
		Full=>tmp_full,
		Empty=>emp2
		); 
   mem_req_fif: entity  work.STD_FIFO(Behavioral) 
	generic map(
		DATA_WIDTH => 52,
		FIFO_DEPTH => 256
	)
	port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in3,
		WriteEn=>we3,
		ReadEn=>re3,
		DataOut=>out3,
		Full=>full_m,
		Empty=>emp3
		); 
		
  mem_res_fifo: process(reset,Clock)
    begin
       if reset='1' then
           we3<='0';
       elsif rising_edge(Clock) then
           if req(50 downto 50)="1" then
               in3<=req;
               we3<='1';
           else
               we3<='0';
           end if;
                           
        end if;
  end process; 
    wb_fifo: process(reset,Clock)
    begin
       if reset='1' then
           we2<='0';
       elsif rising_edge(Clock) then
           if wb_req(50 downto 50)="1" then
               in2<=wb_req;
               we2<='1';
           else
               we2<='0';
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
    variable tmp_req: std_logic_vector(51 downto 0);
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
            res <= tmp_req(51 downto 32) & ROM_array(address);
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

end Behavioral;
