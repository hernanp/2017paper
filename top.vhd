----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2015 07:57:21 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
USE ieee.numeric_std.ALL;

use std.textio.all;
use IEEE.std_logic_textio.all; 

entity top is
    
end top;

architecture Behavioral of top is

    -- Procedure for clock generation
  

  -- Clock frequency and signal
   signal Clock : std_logic;
   signal full_c1_u, full_c2_u, full_b_c1, full_b_c2, full_c1_b, full_c2_b, full_b_m, full_m:std_logic;
   signal bus_res1, bus_res2,cpu_res1, cpu_res2, cpu_req1, cpu_req2,snoop_req1,snoop_req2, wb_req1, wb_req2: std_logic_vector (50 downto 0);
   signal snoop_hit1, snoop_hit2: std_logic;
   signal snoop_res1, snoop_res2, bus_req1, bus_req2: std_logic_vector(50 downto 0);
   signal memres, tomem : std_logic_vector(51 downto 0);
   signal full_crq1, full_srq1, full_brs1,full_wb1,full_srs1,full_crq2, full_srq2, full_brs2,full_wb2,full_srs2:std_logic;
   signal reset: std_logic:='1';
   signal full_mrs: std_logic;
   signal done1, done2: std_logic;
   signal mem_wb: std_logic_vector(50 downto 0);
   signal wb_ack: std_logic;
   signal pwrreq,pwrres: std_logic_vector(4 downto 0);
   signal pwrreq_full : std_logic;
   signal gfxreq, gfxres: std_logic_vector(2 downto 0);
   file trace_file: TEXT open write_mode is "trace1.txt";
begin
reset_proc : process
    begin
       --reset <= '0';
       --wait for 10 ps;
       reset <= '1';
       wait for 50 ps;
       reset <= '0';
       wait;
    end process;

clk_gen : process
  
       variable line_output:line;
       --variable ll:line;
       variable logsr: string(8 downto 1);
       variable x : integer:=0;
       variable empp: string(51 downto 1) := (others => 'N');
       variable coma: string(2 downto 1) := ", ";
   begin
   -- Generate a clock cycle
   loop
     	Clock <= '0';
     	wait for 2 ps;
     	Clock <= '1';
     	wait for 2 ps;
     	if cpu_req1(50 downto 50) = "1" then
     	  	write(line_output, cpu_req1);
		else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		if cpu_req2(50 downto 50) = "1" then
			write(line_output, cpu_req2);
		else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
     	if cpu_res1(50 downto 50) = "1" then
            write(line_output, cpu_res1);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if cpu_res2(50 downto 50) = "1" then

            write(line_output, cpu_res2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if bus_req1(50 downto 50) = "1" then
            write(line_output, bus_req1);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if bus_req2(50 downto 50) = "1" then
            write(line_output, bus_req2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);     
     	if bus_res1(50 downto 50) = "1" then
     		
           	write(line_output, bus_res1);
        else
            write(line_output, empp); 	 
        end if;
        write(line_output, coma);
        if bus_res2(50 downto 50) = "1" then
           	write(line_output, bus_res2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if wb_req1(50 downto 50) = "1" then
            write(line_output, wb_req1);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if wb_req2(50 downto 50) = "1" then
        	
            write(line_output, wb_req2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);    
        
        if snoop_req1(50 downto 50) = "1" then
            write(line_output, snoop_req1);
       	else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if snoop_req2(50 downto 50) = "1" then

            write(line_output, snoop_req2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);      
         if snoop_res1(50 downto 50) = "1" then

            write(line_output, snoop_res1);
         else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if snoop_res2(50 downto 50) = "1" then
        	
            write(line_output, snoop_res2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if tomem(50 downto 50) = "1" then
        	
            write(line_output, tomem);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
        if memres(50 downto 50) = "1" then
        	
            write(line_output, memres);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma); 
		      
        if mem_wb(50 downto 50) = "1" then
            write(line_output, mem_wb);
        else
		    write(line_output, empp);  
		end if;
		
		write(line_output, coma);
		
		write(line_output,wb_ack);
		writeline(trace_file, line_output);
		if done1='1' and done2='1' then
		  wait;
		 end if;
   end loop;
   wait;
 end process;
  
  
    cpu1: entity work.CPU(Behavioral) port map(
       reset => reset,
       Clock=>Clock,
       seed=>1,
       cpu_res=>cpu_res1,
       cpu_req=>cpu_req1,
       full_c=>full_c1_u,
       done=>done1
   );
   
   cpu2: entity work.CPU(Behavioral) port map(
          reset => reset,
          Clock=>Clock,
          seed=>2,
          cpu_res=>cpu_res2,
          cpu_req=>cpu_req2,
          full_c=>full_c2_u,
          done=>done2
      );
    cache1: entity work.L1Cache(Behavioral) port map(
         Clock=>Clock,
         reset=>reset,
         cpu_req=>cpu_req1,
         snoop_req=>snoop_req1,
         bus_res=>bus_res1,
         cpu_res=>cpu_res1,
         full_cprq=>full_c1_u,
         snoop_hit=>snoop_hit1,
         snoop_res=>snoop_res1,
         cache_req=>bus_req1,
         full_srq=>open,
         full_brs=>full_brs1,
         full_crq=>full_crq1,
         full_wb=>full_wb1,
         full_srs=>full_srs1,
         wb_req => wb_req1
          
    );
     cache2: entity work.L1Cache(Behavioral) port map(
            Clock=>Clock,
            reset=>reset,
            cpu_req=>cpu_req2,
            snoop_req=>snoop_req2,
            bus_res=>bus_res2,
            cpu_res=>cpu_res2,
            full_cprq=>full_c2_u,
            snoop_hit=>snoop_hit2,
            snoop_res=>snoop_res2,
            cache_req=>bus_req2,
            full_srq=>open,
         	full_brs=>full_brs2,
         	full_crq=>full_crq2,
         	full_wb=>full_wb2,
         	full_srs=>full_srs2,
         	wb_req => wb_req2
       );
       
    interconnect: entity work.AXI(Behavioral) port map(
        Clock=>Clock,
        reset=>reset,
        cache_req1=>bus_req1,
        cache_req2=>bus_req2,
        wb_req1 => wb_req1,
        wb_req2 => wb_req2,
        memres=>memres,
        bus_res1=>bus_res1,
        bus_res2=>bus_res2,
        tomem=>tomem,
        
        snoop_req1=>snoop_req1,
        snoop_req2=>snoop_req2,
        snoop_res1=>snoop_res1,
        snoop_res2=>snoop_res2,
        snp_hit1=>snoop_hit1,
        snp_hit2=>snoop_hit2,
        
        full_srq1 => full_srq1,
        full_srq2 => full_srq2,
        full_brs1 => full_brs1,
	    full_brs2 => full_brs1,
        full_crq1=>full_crq1,
        full_crq2=>full_crq2,
        full_wb1=>full_wb1,
        full_srs1=>full_srs1,
        full_wb2=>full_wb2,
        full_srs2=>full_srs2,
        full_mrs=>full_mrs,
        
        full_b_m=>full_b_m,
        full_m=>full_m,
        
        pwrreq =>pwrreq,
        pwrres =>pwrres,
        pwrreq_full =>pwrreq_full,
        
        mem_wb => mem_wb,
        wb_ack => wb_ack
        
    );
    power: entity work.PWR(Behavioral) port map(
    	Clock=>Clock,
    	reset=>reset,
    	req=>pwrreq,
    	res=>pwrres,
    	full_preq=>pwrreq_full,
    	gfxreq=>gfxreq,
    	gfxres=>gfxres
    );
    gfx: entity work.gfx(Behavioral) port map(
    	Clock=>Clock,
    	reset=>reset,
    	pwrreq=>gfxreq,
    	pwrres=>gfxres
    );
    mem: entity work.Memory(Behavioral) port map(   
        Clock=>Clock,
        reset=>reset,
        req=>tomem,
        wb_req => mem_wb,
        wb_ack => wb_ack,
        res=>memres,
        full_b_m=>full_b_m,
        full_m=>full_m
    );
end Behavioral;
