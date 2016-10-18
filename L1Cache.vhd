
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
USE ieee.numeric_std.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity L1Cache is
    Port ( 
           Clock: in std_logic;
           reset: in std_logic;
           cpu_req : in STD_LOGIC_VECTOR(50 downto 0);
           snoop_req : in STD_LOGIC_VECTOR(50 downto 0);
           bus_res  : in  STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           --01: read response
           --10: write response
           --11: fifo full response
           cpu_res : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           --01: read response 
           --10: write response
           --11: fifo full response
           snoop_hit : out std_logic;
           snoop_res : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           wb_req: out std_logic_vector(50 downto 0);
            --01: read request
            --10: write request
            --10,11: write back function
           full_cprq: out std_logic:='0';
           full_srq: out std_logic:='0';
           full_brs: out std_logic:='0';
           full_crq,full_wb,full_srs: in std_logic;
           cache_req : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0')
           );
           
           
end L1Cache;

architecture Behavioral of L1Cache is
--IMB cache 1
--3 lsb: dirty bit, valid bit, exclusive bit
--cache hold valid bit ,dirty bit, exclusive bit, 6 bits tag, 32 bits data, 41 bits in total
	type rom_type is array (2**10-1 downto 0) of std_logic_vector (40 downto 0);     
	signal ROM_array : rom_type:= (others => (others =>'0'));
	signal we1,we2,we3,re1,re2,re3: std_logic:='0';
	signal out1,out2,out3:std_logic_vector(50 downto 0);
	signal emp1,emp2,emp3,ful1,ful2,ful3: std_logic:='0';	
	signal mem_req1,mem_req2,upd_req,write_req: std_logic_vector(50 downto 0);
	signal mem_res1,mem_res2,wt_res,upd_res: std_logic_vector(49 downto 0);
	signal hit1,hit2,upd_ack,write_ack,mem_ack1,mem_ack2: std_logic;
	signal in1,in2,in3: std_logic_vector(50 downto 0);
	signal cpu_res1, cpu_res2: std_logic_vector(50 downto 0);
	signal ack1, ack2: std_logic;
	signal wb_req_c, wb_res_c:integer:=1;
	
	signal prc:std_logic_vector(1 downto 0);
	signal tmp_snp_res, tmp_cpu_res1: std_logic_vector(50 downto 0):=(others => '0');
	signal tmp_hit : std_logic;
	signal tmp_mem: std_logic_vector(40 downto 0);
begin
	cpu_req_fif: entity work.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in1,
		WriteEn=>we1,
		ReadEn=>re1,
		DataOut=> mem_req1,
		Full=>full_cprq,
		Empty=>emp1
		);
	snp_req_fif: entity work.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in2,
		WriteEn=>we2,
		ReadEn=>re2,
		DataOut=>mem_req2,
		Full=>full_srq,
		Empty=>emp2
		);
	bus_res_fif: entity work.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in3,
		WriteEn=>we3,
		ReadEn=>re3,
		DataOut=>upd_req,
		Full=>full_brs,
		Empty=>emp3
		);
	 cpu_res_arbitor: entity work.arbiter2(Behavioral) port map(
    	clock => Clock,
        reset => reset,
        din1 => cpu_res1,
        ack1 => ack1,
        din2 => cpu_res2,
        ack2 => ack2,
        dout => cpu_res 
    );
	
	-- Store CPU requests into fifo	
	cpu_req_fifo: process (Clock)      
	begin
		if reset='1' then
			we1<='0';
		elsif rising_edge(Clock) then
			if cpu_req(50 downto 50)="1" then
				in1 <= cpu_req;
				we1 <= '1';
			else
				we1 <= '0';
			end if;
		end if;
	end process;
        

	tmp_lala: process(Clock)
	begin
		tmp_mem <= ROM_array(96);
	end process;
	snp_req_fifo: process (Clock)
	begin	  
		if reset='1' then
			we2<='0';
		
		elsif rising_edge (Clock) then
			if (snoop_req(50 downto 50)="1") then
				in2<=snoop_req;
				we2<='1';
			else
				we2<='0';
			end if;	
		end if;
	end process;
	

	bus_res_fifo: process (Clock)
	begin
		if reset='1' then
			we3<='0';
		
		elsif rising_edge(Clock) then			
			if(bus_res(50 downto 50)="1") then
				in3<=bus_res;
				we3<='1';
			else
				we3<='0';
			end if;
		end if;
	end process;

	
	
-------prblem:
--------it seems when it send cache request, the request is never reset back to empty
   --deal with cpu request
   cpu_req_p:process (reset, Clock)
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        variable state: integer :=0;
	begin
		if (reset = '1') then
			-- reset signals
			cpu_res1 <= nilreq;
			write_req <= nilreq;
			cache_req <= nilreq;
			--tmp_write_req <= nilreq;
		elsif rising_edge(Clock) then
		
			if state =0 then
				cache_req <= nilreq;
				if re1 = '0' and emp1 ='0' then
					re1 <= '1';
					state := 1;
				end if;
				
			elsif state = 1 then
				re1 <= '0';
				if mem_ack1 = '1' then
					if hit1 = '1' then
						if mem_res1(49 downto 48) = "10" then
							write_req <= '1'&mem_res1;
							tmp_cpu_res1 <= '1'&mem_res1;
							state := 3;
						else
							cpu_res1 <= '1'&mem_res1;
							state := 4;
						end if;
					else
						cache_req <= '1'&mem_res1;
						state :=0;
					end if;
				end if;
				
			elsif state = 3 then
				if write_ack ='1' then
					write_req <= nilreq;
					cpu_res1 <= tmp_cpu_res1;
					state := 4;
				end if;
			elsif state = 4 then
				if ack1 = '1' then
					cpu_res1 <= nilreq;
					state := 0;
				end if;
			end if;
		
		
		    
		end if;
	end process;
        


	--deal with snoop request
   snp_req_p:process (reset, Clock)
        	
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
		variable state: integer:=0;
	begin
		if (reset = '1') then
			-- reset signals
			snoop_res <= nilreq;
			snoop_hit <='0';
		elsif rising_edge(Clock) then
			if state =0 then
			     snoop_res <= nilreq;
			     if re2='0' and emp2 ='0' then
			         re2 <= '1';
			         state := 1;
			     end if;
			elsif state =1 then
				re2 <= '0';
			    if mem_ack2 = '1' then
			         tmp_snp_res <= '1'&mem_res2;
			         tmp_hit <= hit2;
			         state := 2;
			    end if;
			elsif state =2 then
			     if full_srs = '0' then
			         snoop_hit <= tmp_hit;
			         snoop_res <= tmp_snp_res;
			         state := 0;
			     end if;
			end if;
		end if;
	end process;


	
   ---deal with bus response
   	bus_res_p:process (reset, Clock)
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        variable state: integer :=0;
	begin
		if reset = '1' then
			-- reset signals
			cpu_res2 <= nilreq;
			--upd_req <= nilreq;
		elsif rising_edge(Clock) then
		    if state =0 then
		          if re3='0' and emp3 ='0' then
		              re3 <= '1';
		              state := 1;
		          end if;
		    elsif state =1 then
		    	   re3 <= '0';
		          if upd_ack ='1' then
		             
		              cpu_res2 <= '1'&upd_res;
		              state :=2;
		          end if;
		    elsif state =2 then
		          if ack2 = '1' then
		              cpu_res2 <= nilreq;
		              state :=0;
		          end if;
		    end if;
			
		end if;
	end process;


        --deal with cache memory
	mem_control_unit:process(reset, Clock)
        variable res:std_logic_vector(49 downto 0);
        variable indx:integer;
        variable memcont: std_logic_vector(40 downto 0);
        variable nilmem: std_logic_vector(40 downto 0):=(others =>'0');
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        variable nilreq1:std_logic_vector(51 downto 0):=(others => '0');
        variable shifter:boolean:=false;
	begin
		if (reset = '1') then
		-- reset signals;
			mem_res1 <= nilreq(49 downto 0);
			mem_res2 <= nilreq(49 downto 0);
			write_ack <= '0';
			upd_ack <= '0';
		elsif rising_edge(Clock) then
		    mem_res1 <= nilreq(49 downto 0);
            mem_res2 <= nilreq(49 downto 0);
            write_ack <= '0';
            upd_ack <= '0';
            wb_req<=nilreq;
			if mem_req1(50 downto 50)="1" then
				indx := to_integer(unsigned(mem_req1(41 downto 32)));
         		memcont:=ROM_array(indx);
         		--if we can't find it in memory
         		if memcont(40 downto 40)="0" or mem_req1(49 downto 48)="10" or mem_req1(49 downto 48)="11"
                        or memcont(37 downto 32)/=mem_req1(47 downto 42) then
					mem_ack1<='1';
					hit1 <= '0';
					mem_res1 <= mem_req1(49 downto 0);
				else
					mem_ack1<='1';
					hit1<='1';
					if mem_req1(49 downto 48)="10" then
						mem_res1 <= mem_req1(49 downto 0);
					else
						mem_res1 <= mem_req1(49 downto 32)& memcont(31 downto 0);
					end if;
				end if;
			else
			    mem_ack1<='0';
			end if;
                

			if mem_req2(50 downto 50)="1" then
				indx:=to_integer(unsigned(mem_req2(41 downto 32)));
				memcont:=ROM_array(indx);
				-- if we can't find it in memory
				if  memcont(40 downto 40)="0" 
                        or memcont(37 downto 32)/=mem_req2(47 downto 42) then
					mem_ack2<='1';
					hit2<='0';
					mem_res2 <= mem_req2(49 downto 0);
				else
					mem_ack2<='1';
					hit2<='1';
					--if it's write, invalidate the cache line
					if mem_req2(49 downto 48) ="10" then
						ROM_array(indx)(40) <= '0';
						mem_res2<=mem_req2(49 downto 0);
					else
					--if it's read, mark the exclusive as 0
						ROM_array(indx)(38) <= '0';
						mem_res2<=mem_req2(49 downto 32)&memcont(31 downto 0);
					end if;
					
				end if;
			else
			     mem_ack2<='0';
			end if;
                
                --first deal with write request from cpu_request
                --the write is only sent here if the data exist in cahce memory
                
			-- Handling CPU write request (no update req from bus)
			if write_req(50 downto 50)="1" and upd_req(50 downto 50)="0" then
				indx := to_integer(unsigned(write_req(41 downto 32)));
				ROM_array(indx)<="110"&write_req(47 downto 42)&write_req(31 downto 0);
				write_ack<='1';    
                upd_ack <='0';
                wt_res <= write_req(49 downto 0);
                
			-- Handling update request (no write_req from CPU)
			elsif upd_req(50 downto 50)="1" and write_req(50 downto 50)="0" then
				indx := to_integer(unsigned(upd_req(41 downto 32)));
				memcont := ROM_array(indx);
				--if tags do not match, dirty bit is 1, and write_back fifo in BUS is not full, 
				if memcont(39 downto 39) = "1" and memcont(37 downto 32)/=upd_req(47 downto 42) and full_wb /= '1' then
					wb_req <= "110"& memcont(37 downto 32)&upd_req(41 downto 32)&memcont(31 downto 0);
				end if;
				ROM_array(indx) <= "100"&upd_req(47 downto 42)&upd_req(31 downto 0);
				upd_ack<='1';
				upd_res<=upd_req(49 downto 0);
                write_ack<='0';
			elsif upd_req(50 downto 50)="1" and write_req(50 downto 50)="1" then
                        if shifter=true then
                            shifter:=false;
                            indx:=to_integer(unsigned(write_req(41 downto 32)));
                            ROM_array(indx)<="110"&write_req(47 downto 42)&write_req(31 downto 0);
                            write_ack<='1';  
                            upd_ack <='0';  
                            wt_res <= write_req(49 downto 0);
                        else
                            shifter:=true;
                            --if tags do not match, dirty bit is 1, and write_back fifo in BUS is not full, 
							if memcont(39 downto 39) = "1" and memcont(37 downto 32)/=upd_req(47 downto 42) and full_wb /= '1' then
								wb_req <= "110"& memcont(37 downto 32)&upd_req(41 downto 32)&memcont(31 downto 0);
							end if;
							ROM_array(indx) <= "100" & upd_req(47 downto 42)&upd_req(31 downto 0);
							upd_ack<='1';
                			write_ack<='0';
                			upd_res <= upd_req(49 downto 0);
                        end if;
            
              	          
              end if;
      end if;
   end process;

end Behavioral;
