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
	signal Clock                                                                                                      : std_logic;
	signal full_c1_u, full_c2_u, full_b_m                                                                   : std_logic;
	signal  cpu_res1, cpu_res2, cpu_req1, cpu_req2                              : std_logic_vector(72 downto 0);
	signal bus_res1, bus_res2 :std_logic_vector(552 downto 0);
	signal snoop_hit1, snoop_hit2                                                                                     : std_logic;
	signal  snoop_req1, snoop_req2                                                             : std_logic_vector(72 downto 0);
	signal snoop_res1, snoop_res2 :std_logic_vector(72 downto 0);
	signal snoop_req:std_logic_vector(75 downto 0);
	---this should be 72
	signal snoop_res:std_logic_vector(75 downto 0);
	signal snoop_hit:std_logic;
	signal bus_req1, bus_req2                                                                                         : std_logic_vector(72 downto 0);
	signal memres, tomem                                                                                              : std_logic_vector(75 downto 0);
	signal full_crq1, full_srq1, full_brs1, full_wb1, full_srs1, full_crq2, full_brs2, full_wb2, full_srs2 : std_logic;
	signal reset                                                                                                      : std_logic := '1';
	---signal full_mrs: std_logic;
	signal done1, done2                                                                                          : std_logic;
	signal mem_wb  , wb_req1, wb_req2                                                                                                    : std_logic_vector(552 downto 0);
	signal wb_ack                                                                                                     : std_logic;
	signal pwrreq, pwrres                                                                                             : std_logic_vector(4 downto 0);
	signal pwrreq_full                                                                                                : std_logic;

	file trace_file : TEXT open write_mode is "trace1.txt";
	signal gfx_b, togfx                 : std_logic_vector(75 downto 0);
	signal gfx_upreq, gfx_upres, gfx_wb : std_logic_vector(72 downto 0);
	signal gfx_upreq_full, gfx_wb_ack   : std_logic;
	signal pwr_gfxreq, pwr_gfxres       : std_logic_vector(2 downto 0);
	signal pwr_audioreq, pwr_audiores   : std_logic_vector(2 downto 0);
	signal pwr_usbreq, pwr_usbres       : std_logic_vector(2 downto 0);
	signal pwr_uartreq, pwr_uartres     : std_logic_vector(2 downto 0);

	signal audio_b, toaudio                   : std_logic_vector(53 downto 0);
	signal audio_upreq, audio_upres, audio_wb : std_logic_vector(72 downto 0);
	signal audio_upreq_full, audio_wb_ack     : std_logic;

	signal usb_b, tousb                 : std_logic_vector(75 downto 0);
	signal usb_upreq, usb_upres, usb_wb : std_logic_vector(72 downto 0);
	signal usb_upreq_full, usb_wb_ack   : std_logic;
 
 
   signal zero : std_logic :='0';
	signal zero72 : std_logic_vector(72 downto 0) := (others => '0');
	signal zero75 : std_logic_vector(75 downto 0) := (others => '0');
	signal uart_b, touart                  : std_logic_vector(75 downto 0);
	signal uart_upreq, uart_upres, uart_wb : std_logic_vector(72 downto 0);
	signal uart_upreq_full, uart_wb_ack    : std_logic;
	
	signal up_snoop, up_snoop_res :std_logic_vector(75 downto 0);
	signal up_snoop_hit:std_logic;
	
		signal waddr                                         : std_logic_vector(31 downto 0);
		signal wlen                                          : std_logic_vector(9 downto 0);
		signal wsize                                         : std_logic_vector(9 downto 0);
		signal wvalid                                         : std_logic;
		signal wready                                         : std_logic;
		-- -write data channel
		signal wdata                                          : std_logic_vector(31 downto 0);
		signal wtrb                                           : std_logic_vector(3 downto 0);
		signal wlast                                          :std_logic;
		signal wdvalid                                         : std_logic;
		signal wdataready                                      : std_logic;
		-- -write response channel
		signal wrready                                         : std_logic;
		signal wrvalid                                         : std_logic;
		signal wrsp                                            : std_logic_vector(1 downto 0);

		-- -read address channel
		signal raddr                                           : std_logic_vector(31 downto 0);
		signal rlen                                            : std_logic_vector(9 downto 0);
		signal rsize                                           : std_logic_vector(9 downto 0);
		signal rvalid                                          : std_logic;
		signal rready                                          : std_logic;
		-- -read data channel
		signal rdata                                           : std_logic_vector(31 downto 0);
		signal rstrb                                           : std_logic_vector(3 downto 0);
		signal rlast                                           : std_logic;
		signal rdvalid                                         : std_logic;
		signal rdready                                         : std_logic;
		signal rres                                            : std_logic_vector(1 downto 0);
	
	---gfx write address channel
		signal waddr_gfx                                          : std_logic_vector(31 downto 0);
		signal wlen_gfx                                           : std_logic_vector(9 downto 0);
		signal wsize_gfx                                          : std_logic_vector(9 downto 0);
		signal wvalid_gfx                                         : std_logic;
		signal wready_gfx                                         : std_logic;
		--_gfx-write data channel
		signal wdata_gfx                                          : std_logic_vector(31 downto 0);
		signal wtrb_gfx                                           : std_logic_vector(3 downto 0);
		signal wlast_gfx                                          :std_logic;
		signal wdvalid_gfx                                        : std_logic;
		signal wdataready_gfx                                     : std_logic;
		--_gfx-write response channel
		signal wrready_gfx                                        : std_logic;
		signal wrvalid_gfx                                        : std_logic;
		signal wrsp_gfx                                           : std_logic_vector(1 downto 0);

		--_gfx-read address channel
		signal raddr_gfx                                          : std_logic_vector(31 downto 0);
		signal rlen_gfx                                           : std_logic_vector(9 downto 0);
		signal rsize_gfx                                          : std_logic_vector(9 downto 0);
		signal rvalid_gfx                                         : std_logic;
		signal rready_gfx                                         : std_logic;
		--_gfx-read data channel
		signal rdata_gfx                                          : std_logic_vector(31 downto 0);
		signal rstrb_gfx                                          : std_logic_vector(3 downto 0);
		signal rlast_gfx                                          : std_logic;
		signal rdvalid_gfx                                        : std_logic;
		signal rdready_gfx                                        : std_logic;
		signal rres_gfx                                           : std_logic_vector(1 downto 0);
		
		
		signal waddr_uart                                          : std_logic_vector(31 downto 0);
		signal wlen_uart                                           : std_logic_vector(9 downto 0);
		signal wsize_uart                                          : std_logic_vector(9 downto 0);
		signal wvalid_uart                                         : std_logic;
		signal wready_uart                                         : std_logic;
		--_uart-write data channel
		signal wdata_uart                                          : std_logic_vector(31 downto 0);
		signal wtrb_uart                                           : std_logic_vector(3 downto 0);
		signal wlast_uart                                          :std_logic;
		signal wdvalid_uart                                        : std_logic;
		signal wdataready_uart                                     : std_logic;
		--_uart-write response channel
		signal wrready_uart                                        : std_logic;
		signal wrvalid_uart                                        : std_logic;
		signal wrsp_uart                                           : std_logic_vector(1 downto 0);

		--_uart-read address channel
		signal raddr_uart                                          : std_logic_vector(31 downto 0);
		signal rlen_uart                                           : std_logic_vector(9 downto 0);
		signal rsize_uart                                          : std_logic_vector(9 downto 0);
		signal rvalid_uart                                         : std_logic;
		signal rready_uart                                         : std_logic;
		--_uart-read data channel
		signal rdata_uart                                          : std_logic_vector(31 downto 0);
		signal rstrb_uart                                          : std_logic_vector(3 downto 0);
		signal rlast_uart                                          : std_logic;
		signal rdvalid_uart                                        : std_logic;
		signal rdready_uart                                        : std_logic;
		signal rres_uart                                           : std_logic_vector(1 downto 0);
		
		signal waddr_usb                                          : std_logic_vector(31 downto 0);
		signal wlen_usb                                           : std_logic_vector(9 downto 0);
		signal wsize_usb                                          : std_logic_vector(9 downto 0);
		signal wvalid_usb                                         : std_logic;
		signal wready_usb                                         : std_logic;
		--_usb-write data channel
		signal wdata_usb                                          : std_logic_vector(31 downto 0);
		signal wtrb_usb                                           : std_logic_vector(3 downto 0);
		signal wlast_usb                                          :std_logic;
		signal wdvalid_usb                                        : std_logic;
		signal wdataready_usb                                     : std_logic;
		--_usb-write response channel
		signal wrready_usb                                        : std_logic;
		signal wrvalid_usb                                        : std_logic;
		signal wrsp_usb                                           : std_logic_vector(1 downto 0);

		--_usb-read address channel
		signal raddr_usb                                          : std_logic_vector(31 downto 0);
		signal rlen_usb                                           : std_logic_vector(9 downto 0);
		signal rsize_usb                                          : std_logic_vector(9 downto 0);
		signal rvalid_usb                                         : std_logic;
		signal rready_usb                                         : std_logic;
		--_usb-read data channel
		signal rdata_usb                                          : std_logic_vector(31 downto 0);
		signal rstrb_usb                                          : std_logic_vector(3 downto 0);
		signal rlast_usb                                          : std_logic;
		signal rdvalid_usb                                        : std_logic;
		signal rdready_usb                                        : std_logic;
		signal rres_usb                                           : std_logic_vector(1 downto 0);
		
		signal waddr_audio                                          : std_logic_vector(31 downto 0);
		signal wlen_audio                                           : std_logic_vector(9 downto 0);
		signal wsize_audio                                          : std_logic_vector(9 downto 0);
		signal wvalid_audio                                         : std_logic;
		signal wready_audio                                         : std_logic;
		--_audio-write data channel
		signal wdata_audio                                          : std_logic_vector(31 downto 0);
		signal wtrb_audio                                           : std_logic_vector(3 downto 0);
		signal wlast_audio                                          :std_logic;
		signal wdvalid_audio                                        : std_logic;
		signal wdataready_audio                                     : std_logic;
		--_audio-write response channel
		signal wrready_audio                                        : std_logic;
		signal wrvalid_audio                                        : std_logic;
		signal wrsp_audio                                           : std_logic_vector(1 downto 0);

		--_audio-read address channel
		signal raddr_audio                                          : std_logic_vector(31 downto 0);
		signal rlen_audio                                           : std_logic_vector(9 downto 0);
		signal rsize_audio                                          : std_logic_vector(9 downto 0);
		signal rvalid_audio                                         : std_logic;
		signal rready_audio                                         : std_logic;
		--_audio-read data channel
		signal rdata_audio                                          : std_logic_vector(31 downto 0);
		signal rstrb_audio                                          : std_logic_vector(3 downto 0);
		signal rlast_audio                                          : std_logic;
		signal rdvalid_audio                                        : std_logic;
		signal rdready_audio                                        : std_logic;
		signal rres_audio                                           : std_logic_vector(1 downto 0);
begin
	reset_proc : process
	begin
		--reset <= '0';
		--wait for 10 ps;
		reset <= '1';
--		wait for 50 ps;
		reset <= '0';
--		wait;
	end process;

	clk_gen : process
		variable line_output : line;
		--variable ll:line;
		---variable logsr: string(8 downto 1);
		--- variable x : integer:=0;
		variable empp        : string(51 downto 1) := (others => 'N');
		variable coma        : string(2 downto 1)  := "  ";
	begin
		-- Generate a clock cycle
		if rising_edge(Clock) then
			Clock <= '0';
--			wait for 2 ps;
			Clock <= '1';
--			wait for 2 ps;
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
			write(line_output, wb_ack);
			write(line_output, coma);

			--19
			if gfx_upreq(50 downto 50) = "1" then
				write(line_output, gfx_upreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--20
			if gfx_upres(50 downto 50) = "1" then
				write(line_output, gfx_upres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--- 21    
			if gfx_wb(50 downto 50) = "1" then
				write(line_output, gfx_wb);
			else
				write(line_output, empp);
			end if;

			write(line_output, coma);
			---22
			write(line_output, gfx_wb_ack);
			write(line_output, coma);

			--23
			if togfx(50 downto 50) = "1" then
				write(line_output, togfx);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--24
			if gfx_b(50 downto 50) = "1" then
				write(line_output, gfx_b);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--25
			if pwr_gfxreq(2 downto 2) = "1" then
				write(line_output, pwr_gfxreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--26
			if pwr_gfxres(2 downto 2) = "1" then
				write(line_output, pwr_gfxres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--19
			if audio_upreq(50 downto 50) = "1" then
				write(line_output, audio_upreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--20
			if audio_upres(50 downto 50) = "1" then
				write(line_output, audio_upres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--- 21    
			if audio_wb(50 downto 50) = "1" then
				write(line_output, audio_wb);
			else
				write(line_output, empp);
			end if;

			write(line_output, coma);
			---22
			write(line_output, audio_wb_ack);
			write(line_output, coma);

			--23
			if toaudio(50 downto 50) = "1" then
				write(line_output, toaudio);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--24
			if audio_b(50 downto 50) = "1" then
				write(line_output, audio_b);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--25
			if pwr_audioreq(2 downto 2) = "1" then
				write(line_output, pwr_audioreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--26
			if pwr_audiores(2 downto 2) = "1" then
				write(line_output, pwr_audiores);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--19
			if usb_upreq(50 downto 50) = "1" then
				write(line_output, usb_upreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--20
			if usb_upres(50 downto 50) = "1" then
				write(line_output, usb_upres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--- 21    
			if usb_wb(50 downto 50) = "1" then
				write(line_output, usb_wb);
			else
				write(line_output, empp);
			end if;

			write(line_output, coma);
			---22
			write(line_output, usb_wb_ack);
			write(line_output, coma);

			--23
			if tousb(50 downto 50) = "1" then
				write(line_output, tousb);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--24
			if usb_b(50 downto 50) = "1" then
				write(line_output, usb_b);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--25
			if pwr_usbreq(2 downto 2) = "1" then
				write(line_output, pwr_usbreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--26
			if pwr_usbres(2 downto 2) = "1" then
				write(line_output, pwr_usbres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--19
			if uart_upreq(50 downto 50) = "1" then
				write(line_output, uart_upreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--20
			if uart_upres(50 downto 50) = "1" then
				write(line_output, uart_upres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--- 21    
			if uart_wb(50 downto 50) = "1" then
				write(line_output, uart_wb);
			else
				write(line_output, empp);
			end if;

			write(line_output, coma);
			---22
			write(line_output, uart_wb_ack);
			write(line_output, coma);

			--23
			if touart(50 downto 50) = "1" then
				write(line_output, touart);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--24
			if uart_b(50 downto 50) = "1" then
				write(line_output, uart_b);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			--25
			if pwr_uartreq(2 downto 2) = "1" then
				write(line_output, pwr_uartreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);
			--26
			if pwr_uartres(2 downto 2) = "1" then
				write(line_output, pwr_uartres);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			---51 
			if pwrreq(4 downto 4) = "1" then
				write(line_output, pwrreq);
			else
				write(line_output, empp);
			end if;
			write(line_output, coma);

			---52 
			if pwrres(4 downto 4) = "1" then
				write(line_output, pwrres);
			else
				write(line_output, empp);
			end if;

			writeline(trace_file, line_output);
			if done1 = '1' and done2 = '1' then
--				wait;
			end if;
		end if;
--		wait;
	end process;

	cpu1 : entity work.CPU(Behavioral) port map(
			reset   => reset,
			Clock   => Clock,
			seed    => 1,
			cpu_res => cpu_res1,
			cpu_req => cpu_req1,
			full_c  => full_c1_u
			--done    => done1
		);
	cpu2 : entity work.CPU(Behavioral) port map(
			reset   => reset,
			Clock   => Clock,
			seed    => 2,
			cpu_res => cpu_res2,
			cpu_req => cpu_req2,
			full_c  => full_c2_u
			--done    => done2
		);
	cache1 : entity work.L1Cache(Behavioral) port map(
			Clock       => Clock,
			reset       => reset,
			cpu_req     => cpu_req1,
			snoop_c_req => snoop_req2,
			snoop_c_res => snoop_res2,
			snoop_c_hit => snoop_hit2,
			snoop_req   => snoop_req1,
			snoop_hit   => snoop_hit1,
			snoop_res   => snoop_res1,
			
			cache_req   => bus_req1,
			bus_res     => bus_res1,
			cpu_res     => cpu_res1,
			full_cprq   => full_c1_u,
			
			
			up_snoop => up_snoop,
			up_snoop_res => up_snoop_res,
			up_snoop_hit => up_snoop_hit,
			
			--full_srq    => zero,
			full_brs    => full_brs1,
			full_crq    => full_crq1,
			full_wb     => full_wb1,
			full_srs    => full_srs1,
			wb_req      => wb_req1
		);
	cache2 : entity work.L1Cache(Behavioral) port map(
			Clock       => Clock,
			reset       => reset,
			cpu_req     => cpu_req2,
			snoop_c_req => snoop_req1,
			snoop_c_res => snoop_res1,
			snoop_c_hit => snoop_hit1,
			snoop_req   => snoop_req2,
			snoop_hit   => snoop_hit2,
			snoop_res   => snoop_res2,
			
			cache_req   => bus_req2,
			bus_res     => bus_res2,
			cpu_res     => cpu_res2,
			full_cprq   => full_c2_u,
			
			
			up_snoop => zero75,
			up_snoop_res => zero75,
			--up_snoop_hit => zero,
			
			--full_srq    => zero,
			full_brs    => full_brs2,
			full_crq    => full_crq2,
			full_wb     => full_wb2,
			full_srs    => full_srs2,
			wb_req      => wb_req2
		);
	power : entity work.PWR(Behavioral) port map(
			audioreq  => pwr_audioreq,
			usbreq    => pwr_usbreq,
			uartreq   => pwr_uartreq,
			audiores  => pwr_audiores,
			usbres    => pwr_usbres,
			uartres   => pwr_uartres,
			Clock     => Clock,
			reset     => reset,
			req       => pwrreq,
			res       => pwrres,
			full_preq => pwrreq_full,
			gfxreq    => pwr_gfxreq,
			gfxres    => pwr_gfxres
		);

	interconnect : entity work.AXI(Behavioral) port map(
			gfx_upreq        => gfx_upreq,
			gfx_upres        => gfx_upres,
			gfx_upreq_full   => gfx_upreq_full,
			
			audio_upreq      => audio_upreq,
			audio_upres      => audio_upres,
			audio_upreq_full => audio_upreq_full,
			
			usb_upreq        => usb_upreq,
			usb_upres        => usb_upres,
			usb_upreq_full   => usb_upreq_full,
			
			uart_upreq       => uart_upreq,
			uart_upres       => uart_upres,
			uart_upreq_full  => uart_upreq_full,
			
			waddr => waddr,
			wlen =>wlen,
			wsize =>wsize,
			wvalid=>wvalid,
			wready=>wready,
			wdata=>wdata,
			wtrb=>wtrb,
			wlast=>wlast,
			wdvalid=>wdvalid,
			wdataready=>wdataready,
			wrready=>wrready,
			wrvalid=>wrvalid,
			wrsp=>wrsp,
			raddr=>raddr,
			rlen=>rlen,
			rsize=>rsize,
			rvalid=>rvalid,
			rready=>rready,
			rdata=>rdata,
			rstrb=>rstrb,
			rlast=>rlast,
			rdvalid=>rdvalid,
			rdready=>rdready,
			rres=>rres,
			
			waddr_gfx => waddr_gfx,
			wlen_gfx =>wlen_gfx,
			wsize_gfx =>wsize_gfx,
			wvalid_gfx=>wvalid_gfx,
			wready_gfx=>wready,
			wdata_gfx=>wdata_gfx,
			wtrb_gfx=>wtrb_gfx,
			wlast_gfx=>wlast_gfx,
			wdvalid_gfx=>wdvalid_gfx,
			wdataready_gfx=>wdataready_gfx,
			wrready_gfx=>wrready_gfx,
			wrvalid_gfx=>wrvalid_gfx,
			wrsp_gfx=>wrsp_gfx,
			raddr_gfx=>raddr_gfx,
			rlen_gfx=>rlen_gfx,
			rsize_gfx=>rsize_gfx,
			rvalid_gfx=>rvalid_gfx,
			rready_gfx=>rready_gfx,
			rdata_gfx=>rdata_gfx,
			rstrb_gfx=>rstrb_gfx,
			rlast_gfx=>rlast_gfx,
			rdvalid_gfx=>rdvalid_gfx,
			rdready_gfx=>rdready_gfx,
			rres_gfx=>rres_gfx,
			
			waddr_uart => waddr_uart,
			wlen_uart =>wlen_uart,
			wsize_uart =>wsize_uart,
			wvalid_uart=>wvalid_uart,
			wready_uart=>wready_uart,
			wdata_uart=>wdata_uart,
			wtrb_uart=>wtrb_uart,
			wlast_uart=>wlast_uart,
			wdvalid_uart=>wdvalid_uart,
			wdataready_uart=>wdataready_uart,
			wrready_uart=>wrready_uart,
			wrvalid_uart=>wrvalid_uart,
			wrsp_uart=>wrsp_uart,
			raddr_uart=>raddr_uart,
			rlen_uart=>rlen_uart,
			rsize_uart=>rsize_uart,
			rvalid_uart=>rvalid_uart,
			rready_uart=>rready_uart,
			rdata_uart=>rdata_uart,
			rstrb_uart=>rstrb_uart,
			rlast_uart=>rlast_uart,
			rdvalid_uart=>rdvalid_uart,
			rdready_uart=>rdready_uart,
			rres_uart=>rres_uart,
			
			
			
			waddr_usb => waddr_usb,
			wlen_usb =>wlen_usb,
			wsize_usb =>wsize_usb,
			wvalid_usb=>wvalid_usb,
			wready_usb=>wready_usb,
			wdata_usb=>wdata_usb,
			wtrb_usb=>wtrb_usb,
			wlast_usb=>wlast_usb,
			wdvalid_usb=>wdvalid_usb,
			wdataready_usb=>wdataready_usb,
			wrready_usb=>wrready_usb,
			wrvalid_usb=>wrvalid_usb,
			wrsp_usb=>wrsp_usb,
			raddr_usb=>raddr_usb,
			rlen_usb=>rlen_usb,
			rsize_usb=>rsize_usb,
			rvalid_usb=>rvalid_usb,
			rready_usb=>rready_usb,
			rdata_usb=>rdata_usb,
			rstrb_usb=>rstrb_usb,
			rlast_usb=>rlast_usb,
			rdvalid_usb=>rdvalid_usb,
			rdready_usb=>rdready_usb,
			rres_usb=>rres_usb,
			
			
			waddr_audio => waddr_audio,
			wlen_audio =>wlen_audio,
			wsize_audio =>wsize_audio,
			wvalid_audio=>wvalid_audio,
			wready_audio=>wready_audio,
			wdata_audio=>wdata_audio,
			wtrb_audio=>wtrb_audio,
			wlast_audio=>wlast_audio,
			wdvalid_audio=>wdvalid_audio,
			wdataready_audio=>wdataready_audio,
			wrready_audio=>wrready_audio,
			wrvalid_audio=>wrvalid_audio,
			wrsp_audio=>wrsp_audio,
			raddr_audio=>raddr_audio,
			rlen_audio=>rlen_audio,
			rsize_audio=>rsize_audio,
			rvalid_audio=>rvalid_audio,
			rready_audio=>rready_audio,
			rdata_audio=>rdata_audio,
			rstrb_audio=>rstrb_audio,
			rlast_audio=>rlast_audio,
			rdvalid_audio=>rdvalid_audio,
			rdready_audio=>rdready_audio,
			rres_audio=>rres_audio,
			Clock            => Clock,
			reset            => reset,
			cache_req1       => bus_req1,
			cache_req2       => bus_req2,
			wb_req1          => wb_req1,
			wb_req2          => wb_req2,
			bus_res1         => bus_res1,
			bus_res2         => bus_res2,
			snoop_req1       => snoop_req,
			snoop_res1       => snoop_res,
			snp_hit1         => snoop_hit,
			full_srq1        => full_srq1,
			full_wb1         => full_wb1,
			full_srs1        => full_srs1,
			full_wb2         => full_wb2,
			pwrreq           => pwrreq,
			pwrres           => pwrres,
			pwrreq_full      => pwrreq_full
		);
	gfx : entity work.gfx(Behavioral) port map(
		wrvalid => wrvalid_gfx,
		wrsp => wrsp_gfx,
		raddr=>raddr_gfx,
		rlen=> rlen_gfx ,
		rsize=> rsize_gfx,
		rvalid=>rvalid_gfx ,                                       
		rready=>rready_gfx   ,                                    
		--_gfx-read data channel
		rdata=> rdata_gfx ,                                       
		rstrb=> rstrb_gfx  ,                                        
		rlast=> rlast_gfx  ,                                       
		rdvalid=> rdvalid_gfx ,                                       
		rdready=> rdready_gfx  ,        
		rres=> rres_gfx ,
			waddr => waddr_gfx,
			wlen => wlen_gfx,
			wsize => wsize_gfx,
			wvalid => wvalid_gfx,
			wdata => wdata_gfx,
			wready => wready_gfx,
			wtrb => wtrb_gfx,
			wlast => wlast_gfx,
			wdataready=> wdataready_gfx,
			wdvalid => wdvalid_gfx,
			wrready => wrready_gfx,
			
			upres      => gfx_upres,
			upreq      => gfx_upreq,
			upreq_full => gfx_upreq_full,
			---this is wrong!!!!!!!!!

			Clock      => Clock,
			reset      => reset,
			pwrreq     => pwr_gfxreq,
			pwrres     => pwr_gfxres
		);
	Audio : entity work.Audio(Behavioral) port map(
			wrvalid => wrvalid_audio,
		wrsp => wrsp_audio,
		raddr=>raddr_audio,
		rlen=> rlen_audio ,
		rsize=> rsize_audio,
		rvalid=>rvalid_audio ,                                       
		rready=>rready_audio   ,                                    
		--_audio-read data channel
		rdata=> rdata_audio ,                                       
		rstrb=> rstrb_audio  ,                                        
		rlast=> rlast_audio  ,                                       
		rdvalid=> rdvalid_audio ,                                       
		rdready=> rdready_audio  ,        
		rres=> rres_audio ,
			waddr => waddr_audio,
			wlen => wlen_audio,
			wsize => wsize_audio,
			wvalid => wvalid_audio,
			wdata => wdata_audio,
			wready => wready_audio,
			wtrb => wtrb_audio,
			wlast => wlast_audio,
			wdataready=> wdataready_audio,
			wdvalid => wdvalid_audio,
			wrready => wrready_audio,
			
			upres      => audio_upres,
			upreq      => audio_upreq,
			upreq_full => audio_upreq_full,
			---this is wrong!!!!!!!!!

			Clock      => Clock,
			reset      => reset,
			pwrreq     => pwr_audioreq,
			pwrres     => pwr_audiores
		);
	USB : entity work.USB(Behavioral) port map(
			wrvalid => wrvalid_usb,
		wrsp => wrsp_usb,
		raddr=>raddr_usb,
		rlen=> rlen_usb ,
		rsize=> rsize_usb,
		rvalid=>rvalid_usb ,                                       
		rready=>rready_usb   ,                                    
		--_usb-read data channel
		rdata=> rdata_usb ,                                       
		rstrb=> rstrb_usb  ,                                        
		rlast=> rlast_usb  ,                                       
		rdvalid=> rdvalid_usb ,                                       
		rdready=> rdready_usb  ,        
		rres=> rres_usb ,
			waddr => waddr_usb,
			wlen => wlen_usb,
			wsize => wsize_usb,
			wvalid => wvalid_usb,
			wdata => wdata_usb,
			wready => wready_usb,
			wtrb => wtrb_usb,
			wlast => wlast_usb,
			wdataready=> wdataready_usb,
			wdvalid => wdvalid_usb,
			wrready => wrready_usb,
			
			upres      => usb_upres,
			upreq      => usb_upreq,
			upreq_full => usb_upreq_full,
			---this is wrong!!!!!!!!!

			Clock      => Clock,
			reset      => reset,
			pwrreq     => pwr_usbreq,
			pwrres     => pwr_usbres
		);
	UART : entity work.UART(Behavioral) port map(
			wrvalid => wrvalid_uart,
		wrsp => wrsp_uart,
		raddr=>raddr_uart,
		rlen=> rlen_uart ,
		rsize=> rsize_uart,
		rvalid=>rvalid_uart ,                                       
		rready=>rready_uart   ,                                    
		--_uart-read data channel
		rdata=> rdata_uart ,                                       
		rstrb=> rstrb_uart  ,                                        
		rlast=> rlast_uart  ,                                       
		rdvalid=> rdvalid_uart ,                                       
		rdready=> rdready_uart  ,        
		rres=> rres_uart ,
			waddr => waddr_uart,
			wlen => wlen_uart,
			wsize => wsize_uart,
			wvalid => wvalid_uart,
			wdata => wdata_uart,
			wready => wready_uart,
			wtrb => wtrb_uart,
			wlast => wlast_uart,
			wdataready=> wdataready_uart,
			wdvalid => wdvalid_uart,
			wrready => wrready_uart,
			
			upres      => uart_upres,
			upreq      => uart_upreq,
			upreq_full => uart_upreq_full,
			---this is wrong!!!!!!!!!

			Clock      => Clock,
			reset      => reset,
			pwrreq     => pwr_uartreq,
			pwrres     => pwr_uartres
		);
	mem : entity work.Memory(Behavioral) port map(
			Clock => Clock,
			reset => reset,
			waddr => waddr,
			wlen =>wlen,
			wsize =>wsize,
			wvalid=>wvalid,
			wready=>wready,
			wdata=>wdata,
			wtrb=>wtrb,
			wlast=>wlast,
			wdvalid=>wdvalid,
			wdataready=>wdataready,
			wrready=>wrready,
			wrvalid=>wrvalid,
			wrsp=>wrsp,
			raddr=>raddr,
			rlen=>rlen,
			rsize=>rsize,
			rvalid=>rvalid,
			rready=>rready,
			rdata=>rdata,
			rstrb=>rstrb,
			rlast=>rlast,
			rdvalid=>rdvalid,
			rdready=>rdready,
			rres=>rres
		);
end Behavioral;
