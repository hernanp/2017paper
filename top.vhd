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

  -- Clock frequency and signal
   signal Clock : std_logic;
   signal full_c1_u, full_c2_u,  full_b_m, full_m:std_logic;
   signal bus_res1, bus_res2,cpu_res1, cpu_res2, cpu_req1, cpu_req2, wb_req1, wb_req2: std_logic_vector (50 downto 0);
   signal snoop_hit1, snoop_hit2: std_logic;
   signal snoop_res1, snoop_res2,snoop_req1,snoop_req2: std_logic_vector(53 downto 0);
   signal  bus_req1, bus_req2: std_logic_vector(50 downto 0);
   signal memres, tomem : std_logic_vector(53 downto 0);
   signal full_crq1, full_srq1, full_brs1,full_wb1,full_srs1,full_crq2, full_srq2, full_brs2,full_wb2,full_srs2:std_logic;
   signal reset: std_logic:='1';
   ---signal full_mrs: std_logic;
   signal done1, done2: std_logic;
   signal mem_wb: std_logic_vector(50 downto 0);
   signal wb_ack: std_logic;
   signal pwrreq,pwrres: std_logic_vector(4 downto 0);
   signal pwrreq_full : std_logic;
   
   file trace_file: TEXT open write_mode is "trace1.txt";
   signal gfx_b,togfx: std_logic_vector(53 downto 0);
   signal gfx_upreq,gfx_upres,gfx_wb : std_logic_vector (50 downto 0);
   signal gfx_upreq_full,gfx_wb_ack:std_logic;
   signal pwr_gfxreq, pwr_gfxres: std_logic_vector(2 downto 0);
    signal pwr_audioreq, pwr_audiores: std_logic_vector(2 downto 0);
     signal pwr_usbreq, pwr_usbres: std_logic_vector(2 downto 0);
      signal pwr_uartreq, pwr_uartres: std_logic_vector(2 downto 0);
   
   signal audio_b,toaudio: std_logic_vector(53 downto 0);
   signal audio_upreq,audio_upres,audio_wb : std_logic_vector (50 downto 0);
   signal audio_upreq_full,audio_wb_ack:std_logic;
   
   signal usb_b,tousb: std_logic_vector(53 downto 0);
   signal usb_upreq,usb_upres,usb_wb : std_logic_vector (50 downto 0);
   signal usb_upreq_full,usb_wb_ack:std_logic;
   
   signal uart_b,touart: std_logic_vector(53 downto 0);
   signal uart_upreq,uart_upres,uart_wb : std_logic_vector (50 downto 0);
   signal uart_upreq_full,uart_wb_ack:std_logic;
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
       ---variable logsr: string(8 downto 1);
      --- variable x : integer:=0;
       variable empp: string(51 downto 1) := (others => 'N');
       variable coma: string(2 downto 1) := "  ";
   begin
   -- Generate a clock cycle
   loop
     	Clock <= '0';
     	wait for 2 ps;
     	Clock <= '1';
     	wait for 2 ps;
     	--- 1
     	if cpu_req1(50 downto 50) = "1" then
     	  	write(line_output, cpu_req1);
		else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 2
		if cpu_req2(50 downto 50) = "1" then
			write(line_output, cpu_req2);
		else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 3
     	if cpu_res1(50 downto 50) = "1" then
            write(line_output, cpu_res1);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 4
        if cpu_res2(50 downto 50) = "1" then

            write(line_output, cpu_res2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		---5
        if bus_req1(50 downto 50) = "1" then
            write(line_output, bus_req1);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 6
        if bus_req2(50 downto 50) = "1" then
            write(line_output, bus_req2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);     
		--- 7
     	if bus_res1(50 downto 50) = "1" then
     		
           	write(line_output, bus_res1);
        else
            write(line_output, empp); 	 
        end if;
        write(line_output, coma);
        --- 8
        if bus_res2(50 downto 50) = "1" then
           	write(line_output, bus_res2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 9
        if wb_req1(50 downto 50) = "1" then
            write(line_output, wb_req1);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 10
        if wb_req2(50 downto 50) = "1" then
            write(line_output, wb_req2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);    
        --- 11
        if snoop_req1(50 downto 50) = "1" then
            write(line_output, snoop_req1);
       	else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 12
        if snoop_req2(50 downto 50) = "1" then
            write(line_output, snoop_req2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);    
		--- 13
         if snoop_res1(50 downto 50) = "1" then

            write(line_output, snoop_res1);
         else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 14
        if snoop_res2(50 downto 50) = "1" then
        	
            write(line_output, snoop_res2);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 15
        if tomem(50 downto 50) = "1" then
        	
            write(line_output, tomem);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma);
		--- 16
        if memres(50 downto 50) = "1" then
        	
            write(line_output, memres);
        else
		    write(line_output, empp);  
		end if;
		write(line_output, coma); 
		--- 17     
        if mem_wb(50 downto 50) = "1" then
            write(line_output, mem_wb);
        else
		    write(line_output, empp);  
		end if;
		
		write(line_output, coma);
		---18
		write(line_output,wb_ack);
		write(line_output,coma);
		
		
		
		--19
		if gfx_upreq(50 downto 50)= "1" then
			write(line_output,gfx_upreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--20
		if gfx_upres(50 downto 50)= "1" then
			write(line_output,gfx_upres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--- 21    
        if gfx_wb(50 downto 50) = "1" then
            write(line_output, gfx_wb);
        else
		    write(line_output, empp);  
		end if;
		
		write(line_output, coma);
		---22
		write(line_output,gfx_wb_ack);
		write(line_output,coma);
		
		--23
		if togfx(50 downto 50)= "1" then
			write(line_output,togfx);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--24
		if gfx_b(50 downto 50)= "1" then
			write(line_output,gfx_b);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--25
		if pwr_gfxreq(2 downto 2)= "1" then
			write(line_output,pwr_gfxreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--26
		if pwr_gfxres(2 downto 2)= "1" then
			write(line_output,pwr_gfxres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		
		--19
		if audio_upreq(50 downto 50)= "1" then
			write(line_output,audio_upreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--20
		if audio_upres(50 downto 50)= "1" then
			write(line_output,audio_upres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--- 21    
        if audio_wb(50 downto 50) = "1" then
            write(line_output, audio_wb);
        else
		    write(line_output, empp);  
		end if;
		
		write(line_output, coma);
		---22
		write(line_output,audio_wb_ack);
		write(line_output,coma);
		
		--23
		if toaudio(50 downto 50)= "1" then
			write(line_output,toaudio);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--24
		if audio_b(50 downto 50)= "1" then
			write(line_output,audio_b);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--25
		if pwr_audioreq(2 downto 2)= "1" then
			write(line_output,pwr_audioreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--26
		if pwr_audiores(2 downto 2)= "1" then
			write(line_output,pwr_audiores);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		
		--19
		if usb_upreq(50 downto 50)= "1" then
			write(line_output,usb_upreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--20
		if usb_upres(50 downto 50)= "1" then
			write(line_output,usb_upres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--- 21    
        if usb_wb(50 downto 50) = "1" then
            write(line_output, usb_wb);
        else
		    write(line_output, empp);  
		end if;
		
		write(line_output, coma);
		---22
		write(line_output,usb_wb_ack);
		write(line_output,coma);
		
		--23
		if tousb(50 downto 50)= "1" then
			write(line_output,tousb);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--24
		if usb_b(50 downto 50)= "1" then
			write(line_output,usb_b);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--25
		if pwr_usbreq(2 downto 2)= "1" then
			write(line_output,pwr_usbreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--26
		if pwr_usbres(2 downto 2)= "1" then
			write(line_output,pwr_usbres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		
		
		
		
		--19
		if uart_upreq(50 downto 50)= "1" then
			write(line_output,uart_upreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--20
		if uart_upres(50 downto 50)= "1" then
			write(line_output,uart_upres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--- 21    
        if uart_wb(50 downto 50) = "1" then
            write(line_output, uart_wb);
        else
		    write(line_output, empp);  
		end if;
		
		write(line_output, coma);
		---22
		write(line_output,uart_wb_ack);
		write(line_output,coma);
		
		--23
		if touart(50 downto 50)= "1" then
			write(line_output,touart);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--24
		if uart_b(50 downto 50)= "1" then
			write(line_output,uart_b);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		--25
		if pwr_uartreq(2 downto 2)= "1" then
			write(line_output,pwr_uartreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		--26
		if pwr_uartres(2 downto 2)= "1" then
			write(line_output,pwr_uartres);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		---51 
		if pwrreq(4 downto 4) ="1" then
			write(line_output,pwrreq);
		else
			write(line_output,empp);
		end if;
		write(line_output,coma);
		
		---52 
		if pwrres(4 downto 4) ="1" then
			write(line_output,pwrres);
		else
			write(line_output,empp);
		end if;
		
		
		
		
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
         snoop_c_req => snoop_req2,
         snoop_c_res=> snoop_res2,
         snoop_c_hit=> snoop_hit2,
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
            snoop_c_req => snoop_req1,
         	snoop_c_res=> snoop_res1,
         	snoop_c_hit=> snoop_hit1,
            snoop_req=>snoop_req1,
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
   power: entity work.PWR(Behavioral) port map(
   		audioreq => pwr_audioreq,
    	usbreq => pwr_usbreq,
    	uartreq => pwr_uartreq,
    	audiores => pwr_audiores,
    	usbres => pwr_usbres,
    	uartres => pwr_uartres,
    	Clock=>Clock,
    	reset=>reset,
    	req=>pwrreq,
    	res=>pwrres,
    	full_preq=>pwrreq_full,
    	gfxreq=>pwr_gfxreq,
    	gfxres=>pwr_gfxres
    );
   
    interconnect: entity work.AXI(Behavioral) port map(
    	gfx_upreq => gfx_upreq,
    	gfx_upres => gfx_upres,
        gfx_upreq_full => gfx_upreq_full,
    	gfx_wb => gfx_wb,
    	gfx_wb_ack => gfx_wb_ack,
    	gfxres => gfx_b,
    	togfx => togfx,
    	audio_upreq => audio_upreq,
    	audio_upres => audio_upres,
        audio_upreq_full => audio_upreq_full,
    	audio_wb => audio_wb,
    	audio_wb_ack => audio_wb_ack,
    	audiores => audio_b,
    	toaudio => toaudio,
    	usb_upreq => usb_upreq,
    	usb_upres => usb_upres,
        usb_upreq_full => usb_upreq_full,
    	usb_wb => usb_wb,
    	usb_wb_ack => usb_wb_ack,
    	usbres => usb_b,
    	tousb => tousb,
    	uart_upreq => uart_upreq,
    	uart_upres => uart_upres,
        uart_upreq_full => uart_upreq_full,
    	uart_wb => uart_wb,
    	uart_wb_ack => uart_wb_ack,
    	uartres => uart_b,
    	touart => touart,
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
        
        full_b_m=>full_b_m,
        full_m=>full_m,
        
        pwrreq =>pwrreq,
        pwrres =>pwrres,
        pwrreq_full =>pwrreq_full,
        
        mem_wb => mem_wb,
        wb_ack => wb_ack
        
    );
     gfx: entity work.gfx(Behavioral) port map(
    	upres => gfx_upres,
    	upreq => gfx_upreq,
    	upreq_full => gfx_upreq_full,
    	---this is wrong!!!!!!!!!
    	full_b_m => full_b_m,
    	req => togfx,
    	res => gfx_b,
    	wb_req => gfx_wb,
    	wb_ack => gfx_wb_ack,
    	Clock=>Clock,
    	reset=>reset,
    	pwrreq=>pwr_gfxreq,
    	pwrres=>pwr_gfxres
    );
    Audio: entity work.Audio(Behavioral) port map(
    	upres => audio_upres,
    	upreq => audio_upreq,
    	upreq_full => audio_upreq_full,
    	full_b_m => full_b_m,
    	req => toaudio,
    	res => audio_b,
    	wb_req => audio_wb,
    	wb_ack => audio_wb_ack,
    	Clock=>Clock,
    	reset=>reset,
    	pwrreq=>pwr_audioreq,
    	pwrres=>pwr_audiores
    );
    USB: entity work.USB(Behavioral) port map(
    	upres => usb_upres,
    	upreq => usb_upreq,
    	upreq_full => usb_upreq_full,
    	full_b_m => full_b_m,
    	req => tousb,
    	res => usb_b,
    	wb_req => usb_wb,
    	wb_ack => usb_wb_ack,
    	Clock=>Clock,
    	reset=>reset,
    	pwrreq=>pwr_usbreq,
    	pwrres=>pwr_usbres
    );
    UART: entity work.UART(Behavioral) port map(
    	upres => uart_upres,
    	upreq => uart_upreq,
    	upreq_full => uart_upreq_full,
    	full_b_m => full_b_m,
    	req => touart,
    	res => uart_b,
    	wb_req => uart_wb,
    	wb_ack => uart_wb_ack,
    	Clock=>Clock,
    	reset=>reset,
    	pwrreq=>pwr_uartreq,
    	pwrres=>pwr_uartres
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
