----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2015 10:27:30 AM
-- Design Name: 
-- Module Name: AXI - Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity AXI is
	Port(
		Clock                                              : in  std_logic;
		reset                                              : in  std_logic;
		cache_req1                                         : in  STD_LOGIC_VECTOR(72 downto 0);
		cache_req2                                         : in  STD_LOGIC_VECTOR(72 downto 0);
		wb_req1, wb_req2                                   : in  std_logic_vector(552 downto 0);
		bus_res1                                           : out STD_LOGIC_VECTOR(552 downto 0);
		bus_res2                                           : out STD_LOGIC_VECTOR(552 downto 0);
		snoop_req1                                         : out STD_LOGIC_VECTOR(72 downto 0);
		snoop_req2                                         : out STD_LOGIC_VECTOR(72 downto 0);
		snoop_res1, snoop_res2                             : in  STD_LOGIC_VECTOR(552 downto 0);
		snp_hit1                                           : in  std_logic;
		snp_hit2                                           : in  std_logic;
		full_srq1, full_srq2                               : in  std_logic;
		full_wb1, full_srs1, full_wb2, full_srs2, full_mrs : out std_logic;
		pwrreq                                             : out std_logic_vector(4 downto 0);
		pwrreq_full                                        : in  std_logic;
		pwrres                                             : in  std_logic_vector(4 downto 0);

		--add 3 bits in snoop request to indicate the source
		--000 cpu0
		--001 gfx
		--010 uart
		--011 usb
		--100 audio
		--101 cpu1

		full_gfxrs, full_audiors, full_usbrs, full_uartrs  : out std_logic;
		wb_ack                                             : in  std_logic;
		gfx_wb                                             : out std_logic_vector(50 downto 0);
		gfx_wb_ack                                         : in  std_logic;
		usb_wb                                             : out std_logic_vector(50 downto 0);
		usb_wb_ack                                         : in  std_logic;
		audio_wb                                           : out std_logic_vector(50 downto 0);
		audio_wb_ack                                       : in  std_logic;
		uart_wb                                            : out std_logic_vector(50 downto 0);
		uart_wb_ack                                        : in  std_logic;
		gfx_upreq                                          : in  std_logic_vector(50 downto 0);
		gfx_upres                                          : out std_logic_vector(50 downto 0);
		gfx_upreq_full                                     : out std_logic;
		audio_upreq                                        : in  std_logic_vector(50 downto 0);
		audio_upres                                        : out std_logic_vector(50 downto 0);
		audio_upreq_full                                   : out std_logic;
		usb_upreq                                          : in  std_logic_vector(50 downto 0);
		usb_upres                                          : out std_logic_vector(50 downto 0);
		usb_upreq_full                                     : out std_logic;
		uart_upreq                                         : in  std_logic_vector(50 downto 0);
		uart_upres                                         : out std_logic_vector(50 downto 0);
		uart_upreq_full                                    : out std_logic;

		---write address channel
		waddr                                              : out std_logic_vector(31 downto 0);
		wlen                                               : out std_logic_vector(9 downto 0);
		wsize                                              : out std_logic_vector(9 downto 0);
		wvalid                                             : out std_logic;
		wready                                             : in  std_logic;
		---write data channel
		wdata                                              : out std_logic_vector(31 downto 0);
		wtrb                                               : out std_logic_vector(3 downto 0);
		wlast                                              : out std_logic;
		wdvalid                                            : out std_logic;
		wdataready                                         : in  std_logic;
		---write response channel
		wrready                                            : out std_logic;
		wrvalid                                            : in  std_logic;
		wrsp                                               : in  std_logic_vector(1 downto 0);

		---read address channel
		raddr                                              : out std_logic_vector(31 downto 0);
		rlen                                               : out std_logic_vector(9 downto 0);
		rsize                                              : out std_logic_vector(9 downto 0);
		rvalid                                             : out std_logic;
		rready                                             : in  std_logic;
		---read data channel
		rdata                                              : in  std_logic_vector(31 downto 0);
		rstrb                                              : in  std_logic_vector(3 downto 0);
		rlast                                              : in  std_logic;
		rdvalid                                            : in  std_logic;
		rdready                                            : out std_logic;
		rres                                               : in  std_logic_vector(1 downto 0);

		---usb write address channel
		waddr_usb                                          : out std_logic_vector(31 downto 0);
		wlen_usb                                           : out std_logic_vector(9 downto 0);
		wsize_usb                                          : out std_logic_vector(9 downto 0);
		wvalid_usb                                         : out std_logic;
		wready_usb                                         : in  std_logic;
		--_usb-write data channel
		wdata_usb                                          : out std_logic_vector(31 downto 0);
		wtrb_usb                                           : out std_logic_vector(3 downto 0);
		wlast_usb                                          : out std_logic;
		wdvalid_usb                                        : out std_logic;
		wdataready_usb                                     : in  std_logic;
		--_usb-write response channel
		wrready_usb                                        : out std_logic;
		wrvalid_usb                                        : in  std_logic;
		wrsp_usb                                           : in  std_logic_vector(1 downto 0);

		--_usb-read address channel
		raddr_usb                                          : out std_logic_vector(31 downto 0);
		rlen_usb                                           : out std_logic_vector(9 downto 0);
		rsize_usb                                          : out std_logic_vector(9 downto 0);
		rvalid_usb                                         : out std_logic;
		rready_usb                                         : in  std_logic;
		--_usb-read data channel
		rdata_usb                                          : in  std_logic_vector(31 downto 0);
		rstrb_usb                                          : in  std_logic_vector(3 downto 0);
		rlast_usb                                          : in  std_logic;
		rdvalid_usb                                        : in  std_logic;
		rdready_usb                                        : out std_logic;
		rres_usb                                           : in  std_logic_vector(1 downto 0);

		---gfx write address channel
		waddr_gfx                                          : out std_logic_vector(31 downto 0);
		wlen_gfx                                           : out std_logic_vector(9 downto 0);
		wsize_gfx                                          : out std_logic_vector(9 downto 0);
		wvalid_gfx                                         : out std_logic;
		wready_gfx                                         : in  std_logic;
		--_gfx-write data channel
		wdata_gfx                                          : out std_logic_vector(31 downto 0);
		wtrb_gfx                                           : out std_logic_vector(3 downto 0);
		wlast_gfx                                          : out std_logic;
		wdvalid_gfx                                        : out std_logic;
		wdataready_gfx                                     : in  std_logic;
		--_gfx-write response channel
		wrready_gfx                                        : out std_logic;
		wrvalid_gfx                                        : in  std_logic;
		wrsp_gfx                                           : in  std_logic_vector(1 downto 0);

		--_gfx-read address channel
		raddr_gfx                                          : out std_logic_vector(31 downto 0);
		rlen_gfx                                           : out std_logic_vector(9 downto 0);
		rsize_gfx                                          : out std_logic_vector(9 downto 0);
		rvalid_gfx                                         : out std_logic;
		rready_gfx                                         : in  std_logic;
		--_gfx-read data channel
		rdata_gfx                                          : in  std_logic_vector(31 downto 0);
		rstrb_gfx                                          : in  std_logic_vector(3 downto 0);
		rlast_gfx                                          : in  std_logic;
		rdvalid_gfx                                        : in  std_logic;
		rdready_gfx                                        : out std_logic;
		rres_gfx                                           : in  std_logic_vector(1 downto 0);

		---uart write address channel
		waddr_uart                                         : out std_logic_vector(31 downto 0);
		wlen_uart                                          : out std_logic_vector(9 downto 0);
		wsize_uart                                         : out std_logic_vector(9 downto 0);
		wvalid_uart                                        : out std_logic;
		wready_uart                                        : in  std_logic;
		--_uart-write data channel
		wdata_uart                                         : out std_logic_vector(31 downto 0);
		wtrb_uart                                          : out std_logic_vector(3 downto 0);
		wlast_uart                                         : out std_logic;
		wdvalid_uart                                       : out std_logic;
		wdataready_uart                                    : in  std_logic;
		--_uart-write response channel
		wrready_uart                                       : out std_logic;
		wrvalid_uart                                       : in  std_logic;
		wrsp_uart                                          : in  std_logic_vector(1 downto 0);

		--_uart-read address channel
		raddr_uart                                         : out std_logic_vector(31 downto 0);
		rlen_uart                                          : out std_logic_vector(9 downto 0);
		rsize_uart                                         : out std_logic_vector(9 downto 0);
		rvalid_uart                                        : out std_logic;
		rready_uart                                        : in  std_logic;
		--_uart-read data channel
		rdata_uart                                         : in  std_logic_vector(31 downto 0);
		rstrb_uart                                         : in  std_logic_vector(3 downto 0);
		rlast_uart                                         : in  std_logic;
		rdvalid_uart                                       : in  std_logic;
		rdready_uart                                       : out std_logic;
		rres_uart                                          : in  std_logic_vector(1 downto 0);

		---audio write address channel
		waddr_audio                                        : out std_logic_vector(31 downto 0);
		wlen_audio                                         : out std_logic_vector(9 downto 0);
		wsize_audio                                        : out std_logic_vector(9 downto 0);
		wvalid_audio                                       : out std_logic;
		wready_audio                                       : in  std_logic;
		--_audio-write data channel
		wdata_audio                                        : out std_logic_vector(31 downto 0);
		wtrb_audio                                         : out std_logic_vector(3 downto 0);
		wlast_audio                                        : out std_logic;
		wdvalid_audio                                      : out std_logic;
		wdataready_audio                                   : in  std_logic;
		--_audio-write response channel
		wrready_audio                                      : out std_logic;
		wrvalid_audio                                      : in  std_logic;
		wrsp_audio                                         : in  std_logic_vector(1 downto 0);

		--_audio-read address channel
		raddr_audio                                        : out std_logic_vector(31 downto 0);
		rlen_audio                                         : out std_logic_vector(9 downto 0);
		rsize_audio                                        : out std_logic_vector(9 downto 0);
		rvalid_audio                                       : out std_logic;
		rready_audio                                       : in  std_logic;
		--_audio-read data channel
		rdata_audio                                        : in  std_logic_vector(31 downto 0);
		rstrb_audio                                        : in  std_logic_vector(3 downto 0);
		rlast_audio                                        : in  std_logic;
		rdvalid_audio                                      : in  std_logic;
		rdready_audio                                      : out std_logic;
		rres_audio                                         : in  std_logic_vector(1 downto 0)
	);
end AXI;

architecture Behavioral of AXI is
	--fifo has 53 bits
	--3 bits for indicating its source
	--50 bits for packet


	type memory_type is array (31 downto 0) of std_logic_vector(53 downto 0);
	signal memory            : memory_type           := (others => (others => '0')); --memory for queue.
	signal readptr, writeptr : integer range 0 to 31 := 0; --read and write pointers.begin

	signal in1, in4             : std_logic_vector(72 downto 0);
	signal in6, in7, out6, out7 : std_logic_vector(552 downto 0);

	signal in3, out3                                                                          : std_logic_vector(73 downto 0);
	signal in2, out2, in5, out5                                                               : std_logic_vector(553 downto 0);
	signal we1, we2, we3, we4, we5, we6, we7, re7, re1, re2, re3, re4, re5, re6               : std_logic := '0';
	signal emp1, emp2, emp3, emp4, emp5, emp6, emp7, ful7, ful1, ful2, ful3, ful4, ful5, ful6 : std_logic := '0';

	signal bus_res1_1, bus_res1_2, bus_res2_1, bus_res2_2                 : std_logic_vector(552 downto 0);
	signal mem_ack1, mem_ack2, brs1_ack1, brs1_ack2, brs2_ack1, brs2_ack2 : std_logic;
	signal mem_ack,mem_ack3, mem_ack4,mem_ack5, mem_ack6                  : std_logic;

	signal tomem1, tomem2,tomem3, tomem4 ,tomem5, tomem6 : std_logic_vector(75 downto 0) := (others => '0');

	signal wb_ack1, wb_ack2 : std_logic;
	signal mem_wb1, mem_wb2 : std_logic_vector(552 downto 0) := (others => '0');
	--state information of power
	signal gfxpoweron       : std_logic                      := '0';

	signal adr_0, adr_1                                   : std_logic_vector(31 downto 0);
	signal tmp_sp1, tmp_sp2                               : std_logic_vector(72 downto 0);
	signal pwr_req1, pwr_req2                             : std_logic_vector(4 downto 0);
	signal pwr_ack1, pwr_ack2                             : std_logic;
	signal mem_wb                                         : std_logic_vector(552 downto 0);
	signal tomem_p, togfx_p, touart_p, tousb_p, toaudio_p : std_logic_vector(73 downto 0);

	signal in9, out9, in13, out13, in14, out14, in15, out15                                           : std_logic_vector(50 downto 0);
	signal in8, out8, in10, out10, in11, out11, in12, out12                                           : std_logic_vector(53 downto 0);
	signal we8, re8, re9, we9, re10, we10, re11, we11, re12, we12, re13, we13, re14, we14, re15, we15 : std_logic := '0';
	signal emp8, emp9, emp10, emp11, emp12, emp13, emp14, emp15                                       : std_logic := '0';

	signal bus_res1_3, bus_res2_3, bus_res1_4, bus_res1_5, bus_res2_4, bus_res2_5, bus_res1_6, bus_res2_6    : std_logic_vector(50 downto 0);
	signal gfx_ack1, gfx_ack2, audio_ack1, audio_ack2, usb_ack1, usb_ack2, uart_ack1                         : std_logic;
	signal uart_ack2, brs1_ack3, brs2_ack3, brs1_ack4, brs1_ack5, brs1_ack6, brs2_ack5, brs2_ack4, brs2_ack6 : std_logic;
	signal togfx1, togfx2                                                                                    : std_logic_vector(53 downto 0) := (others => '0');
	signal toaudio1, toaudio2                                                                                : std_logic_vector(53 downto 0) := (others => '0');
	signal tousb1, tousb2                                                                                    : std_logic_vector(53 downto 0) := (others => '0');
	signal touart1, touart2                                                                                  : std_logic_vector(53 downto 0) := (others => '0');

	signal gfx_wb_ack1, gfx_wb_ack2, audio_wb_ack1, audio_wb_ack2, usb_wb_ack1, usb_wb_ack2, uart_wb_ack1, uart_wb_ack2 : std_logic;
	signal gfx_wb1, gfx_wb2, audio_wb1, audio_wb2, usb_wb1, usb_wb2, uart_wb1, uart_wb2                                 : std_logic_vector(552 downto 0) := (others => '0');
	--state information of power
	signal audiopoweron                                                                                                 : std_logic                      := '0';
	signal usbpoweron                                                                                                   : std_logic                      := '0';
	signal uartpoweron                                                                                                  : std_logic                      := '0';

	signal pwr_req3, pwr_req4, pwr_req5, pwr_req6 : std_logic_vector(4 downto 0);
	signal pwr_ack3, pwr_ack4, pwr_ack5, pwr_ack6 : std_logic;

	signal snp1_1, snp1_2, snp1_3, snp1_4, snp1_5, snp1_6, snp2_1, snp2_2, snp2_3, snp2_4, snp2_5, snp2_6                                     : std_logic_vector(53 downto 0);
	signal snp1_ack1, snp1_ack2, snp1_ack3, snp1_ack4, snp1_ack5, snp1_ack6, snp2_ack1, snp2_ack2, snp2_ack3, snp2_ack4, snp2_ack5, snp2_ack6 : std_logic;

	signal gfx_upres1, gfx_upres2, gfx_upres3                   : std_logic_vector(50 downto 0);
	signal gfx_upres_ack1, gfx_upres_ack2, gfx_upres_ack3       : std_logic;
	signal audio_upres1, audio_upres2, audio_upres3             : std_logic_vector(50 downto 0);
	signal audio_upres_ack1, audio_upres_ack2, audio_upres_ack3 : std_logic;
	signal usb_upres1, usb_upres2, usb_upres3                   : std_logic_vector(50 downto 0);
	signal usb_upres_ack1, usb_upres_ack2, usb_upres_ack3       : std_logic;
	signal uart_upres1, uart_upres2, uart_upres3                : std_logic_vector(50 downto 0);
	signal uart_upres_ack1, uart_upres_ack2, uart_upres_ack3    : std_logic;
	signal gfx_upres4, gfx_upres5, gfx_upres6                   : std_logic_vector(50 downto 0);
	signal gfx_upres_ack4, gfx_upres_ack5, gfx_upres_ack6       : std_logic;
	signal audio_upres4, audio_upres5, audio_upres6             : std_logic_vector(50 downto 0);
	signal audio_upres_ack4, audio_upres_ack5, audio_upres_ack6 : std_logic;
	signal usb_upres4, usb_upres5, usb_upres6                   : std_logic_vector(50 downto 0);
	signal usb_upres_ack4, usb_upres_ack5, usb_upres_ack6       : std_logic;
	signal uart_upres4, uart_upres5, uart_upres6                : std_logic_vector(50 downto 0);
	signal uart_upres_ack4, uart_upres_ack5, uart_upres_ack6    : std_logic;

begin
	snp_res_fif1 : entity work.STD_FIFO
		generic map(
			DATA_WIDTH => 55,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in2,
			WriteEn => we2,
			ReadEn  => re2,
			DataOut => out2,
			Full    => full_srs1,
			Empty   => emp2
		);

	gfx_res_fif : entity work.STD_FIFO(Behavioral)
		generic map(
			DATA_WIDTH => 54,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in8,
			WriteEn => we8,
			ReadEn  => re8,
			DataOut => out8,
			Full    => full_gfxrs,
			Empty   => emp8
		);
	audio_res_fif : entity work.STD_FIFO(Behavioral)
		generic map(
			DATA_WIDTH => 54,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in10,
			WriteEn => we10,
			ReadEn  => re10,
			DataOut => out10,
			Full    => full_audiors,
			Empty   => emp10
		);
	usb_res_fif : entity work.STD_FIFO(Behavioral)
		generic map(
			DATA_WIDTH => 54,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in11,
			WriteEn => we11,
			ReadEn  => re11,
			DataOut => out11,
			Full    => full_usbrs,
			Empty   => emp11
		);
	uart_res_fif : entity work.STD_FIFO(Behavioral)
		generic map(
			DATA_WIDTH => 54,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in12,
			WriteEn => we12,
			ReadEn  => re12,
			DataOut => out12,
			Full    => full_uartrs,
			Empty   => emp12
		);

	snp_res_fif2 : entity work.STD_FIFO(Behavioral)
		generic map(
			DATA_WIDTH => 55,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in5,
			WriteEn => we5,
			ReadEn  => re5,
			DataOut => out5,
			Full    => full_srs2,
			Empty   => emp5
		);

	wb_fif1 : entity work.STD_FIFO(Behavioral) port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in6,
			WriteEn => we6,
			ReadEn  => re6,
			DataOut => out6,
			Full    => full_wb1,
			Empty   => emp6
		);
	wb_fif2 : entity work.STD_FIFO(Behavioral) port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in7,
			WriteEn => we7,
			ReadEn  => re7,
			DataOut => out7,
			Full    => full_wb2,
			Empty   => emp7
		);

	gfx_fif : entity work.STD_FIFO(Behavioral) port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in9,
			WriteEn => we9,
			ReadEn  => re9,
			DataOut => out9,
			Full    => gfx_upreq_full,
			Empty   => emp9
		);
	gfx_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we9 <= '0';
		elsif rising_edge(Clock) then
			if (gfx_upreq(50 downto 50) = "1") then
				in9 <= gfx_upreq;
				we9 <= '1';
			else
				we9 <= '0';
			end if;
		end if;
	end process;
	audio_fif : entity work.STD_FIFO(Behavioral) port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in13,
			WriteEn => we13,
			ReadEn  => re13,
			DataOut => out13,
			Full    => audio_upreq_full,
			Empty   => emp13
		);
	audio_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we13 <= '0';
		elsif rising_edge(Clock) then
			if (audio_upreq(50 downto 50) = "1") then
				in13 <= audio_upreq;
				we13 <= '1';
			else
				we13 <= '0';
			end if;
		end if;
	end process;
	usb_fif : entity work.STD_FIFO(Behavioral) port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in14,
			WriteEn => we14,
			ReadEn  => re14,
			DataOut => out14,
			Full    => usb_upreq_full,
			Empty   => emp14
		);
	usb_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we14 <= '0';
		elsif rising_edge(Clock) then
			if (usb_upreq(50 downto 50) = "1") then
				in14 <= usb_upreq;
				we14 <= '1';
			else
				we14 <= '0';
			end if;
		end if;
	end process;
	uart_fif : entity work.STD_FIFO(Behavioral) port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in15,
			WriteEn => we15,
			ReadEn  => re15,
			DataOut => out15,
			Full    => uart_upreq_full,
			Empty   => emp15
		);
	uart_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we15 <= '0';
		elsif rising_edge(Clock) then
			if (uart_upreq(50 downto 50) = "1") then
				in15 <= uart_upreq;
				we15 <= '1';
			else
				we15 <= '0';
			end if;
		end if;
	end process;

	gfx_upreq_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable stage  : integer                       := 0;
	---variable count: integer:=0;
	begin
		if reset = '1' then
			---snoop_req1 <= "000"&nilreq;
			pwr_req1 <= "00000";
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re9 = '0' and emp9 = '0' then
					re9   <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re9 <= '0';
				if out9(50 downto 50) = "1" then
					snp1_2 <= "001" & out9;
					stage  := 2;
				end if;
			elsif stage = 2 then
				if snp1_ack2 = '1' then
					snp1_2 <= "000" & nilreq;
					stage  := 0;
				end if;
			end if;
		end if;
	end process;

	audio_upreq_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable stage  : integer                       := 0;
	---variable count: integer:=0;
	begin
		if reset = '1' then
		---snoop_req1 <= "000"&nilreq;
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re13 = '0' and emp9 = '0' then
					re13  <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re13 <= '0';
				if out13(50 downto 50) = "1" then
					snp1_3 <= "100" & out13;
					stage  := 2;
				end if;
			elsif stage = 2 then
				if snp1_ack3 = '1' then
					snp1_3 <= "000" & nilreq;
					stage  := 0;
				end if;
			end if;
		end if;
	end process;

	usb_upreq_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable stage  : integer                       := 0;
	---variable count: integer:=0;
	begin
		if reset = '1' then
		---snoop_req1 <= "000"&nilreq;
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re14 = '0' and emp4 = '0' then
					re14  <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re14 <= '0';
				if out14(50 downto 50) = "1" then
					snp1_4 <= "011" & out14;
					stage  := 2;
				end if;
			elsif stage = 2 then
				if snp1_ack4 = '1' then
					snp1_4 <= "000" & nilreq;
					stage  := 0;
				end if;
			end if;
		end if;
	end process;

	uart_upreq_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable stage  : integer                       := 0;
	---variable count: integer:=0;
	begin
		if reset = '1' then
		---snoop_req1 <= "000"&nilreq;
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re15 = '0' and emp4 = '0' then
					re15  <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re15 <= '0';
				if out15(50 downto 50) = "1" then
					snp1_5 <= "010" & out14;
					stage  := 2;
				end if;
			elsif stage = 2 then
				if snp1_ack5 = '1' then
					snp1_5 <= "000" & nilreq;
					stage  := 0;
				end if;
			end if;
		end if;
	end process;

	tomem_arbitor : entity work.arbiter6(Behavioral) 
	generic map(
		DATA_WIDTH => 76
	)
	port map(
			clock => Clock,
			reset => reset,
			din1  => tomem1,
			ack1  => mem_ack1,
			din2  => tomem2,
			ack2  => mem_ack2,
			din3  => tomem3,
			ack3  => mem_ack3,
			din4  => tomem4,
			ack4  => mem_ack4,
			din5  => tomem5,
			ack5  => mem_ack5,
			din6  => tomem6,
			ack6  => mem_ack6,
			dout  => tomem_p
		);

	tomem_channel : process(reset, Clock)
		variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
		variable state   : integer                        := 0;
		variable lp      : integer                        := 0;
		variable tep_mem : std_logic_vector(73 downto 0);
		variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
	begin
		if reset = '1' then
			rvalid  <= '0';
			rdready <= '0';
		elsif rising_edge(Clock) then
			if state = 0 then
				bus_res1_1 <= nullreq;
				bus_res2_1 <= nullreq;
				gfx_upres1 <= (others => '0');
				uart_upres1 <= (others => '0');
				audio_upres1 <= (others => '0');
				usb_upres1 <= (others => '0');
				if tomem_p(72 downto 72) = "1" then
					tep_mem := tomem_p;
					state :=6;
				end if;
			elsif state =6 then
				if rready = '1' then
					mem_ack <= '0';
					rvalid  <= '1';
					raddr   <= tomem_p(63 downto 32);
					rlen    <= "00001" & "00000";
					rsize   <= "00001" & "00000";
					state   := 1;
				end if;
			elsif state = 1 then
				rvalid  <= '0';
				rdready <= '1';
				state   := 2;
			elsif state = 2 then
				if rdvalid = '1' and rres = "00" then
					rdready                            <= '0';
					tdata(lp * 32 + 31 downto lp * 32) := rdata;
					lp                                 := lp + 1;
					if rlast = '1' then
						state := 3;
						lp    := 0;
					end if;
					rdready <= '1';
				end if;
			elsif state = 3 then
				--mem_ack <= '1';
				if tep_mem(75 downto 73) = "000" then
					bus_res1_1 <= tep_mem(72 downto 32) & tdata;
					state := 4;
				elsif tep_mem(75 downto 73)="101" then
					bus_res2_1 <= tep_mem(72 downto 32) & tdata;
					state := 4;
				elsif tep_mem(75 downto 73)="001" then
					gfx_upres1 <= tep_mem(72 downto 32) & tdata;
					state := 5;
				elsif tep_mem(75 downto 73)="010" then
					uart_upres1 <= tep_mem(72 downto 32) & tdata;
					state := 6;
				elsif tep_mem(75 downto 73)="011" then
					usb_upres1<= tep_mem(72 downto 32) & tdata;
					state := 7;
				elsif tep_mem(75 downto 73)="100" then
					audio_upres1 <= tep_mem(72 downto 32) & tdata;
					state := 8;
				end if;
				
			elsif state = 4 then
				if brs2_ack1 = '1' then
					bus_res2_1 <= nullreq;
					state      := 0;
				elsif brs1_ack1 = '1' then
					bus_res1_1 <= nullreq;
					state      := 0;
				end if;
			elsif state =5 then
				if gfx_upres_ack1 ='1' then
					gfx_upres1 <= (others => '0');
					state :=0;
				end if;
			elsif state =6 then
				if uart_upres_ack1 ='1' then
					uart_upres1 <= (others => '0');
					state :=0;
				end if;	
			elsif state =7 then
				if usb_upres_ack1 ='1' then
					usb_upres1 <= (others => '0');
					state :=0;
				end if;
			elsif state =8 then
				if audio_upres_ack1 ='1' then
					audio_upres1 <= (others => '0');
					state :=0;
				end if;	
			end if;
		end if;
	end process;


	togfx_arbitor : entity work.arbiter2(Behavioral) 
	generic map(
		DATA_WIDTH=>76
	)
	port map(
			clock => Clock,
			reset => reset,
			din1  => togfx1,
			ack1  => gfx_ack1,
			din2  => togfx2,
			ack2  => gfx_ack2,
			dout  => togfx_p
		);
	togfx_channel : process(reset, Clock)
		variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
		variable state   : integer                        := 0;
		variable lp      : integer                        := 0;
		variable tep_gfx : std_logic_vector(73 downto 0);
		variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
	begin
		if reset = '1' then
			rvalid_gfx  <= '0';
			rdready_gfx <= '0';
		elsif rising_edge(Clock) then
			if state = 0 then
				bus_res1_2 <= nullreq;
				bus_res2_2 <= nullreq;
				gfx_upres2 <= (others => '0');
				uart_upres2 <= (others => '0');
				audio_upres2<= (others => '0');
				usb_upres2 <= (others => '0');
				if togfx_p(72 downto 72) = "1" then
					tep_gfx := togfx_p;
					state :=6;
				end if;
			elsif state =6 then
				if rready_gfx = '1' then
					--gfx_ack <= '0';
					rvalid_gfx  <= '1';
					raddr_gfx   <= togfx_p(63 downto 32);
					rlen_gfx    <= "00001" & "00000";
					rsize_gfx  <= "00001" & "00000";
					state   := 1;
				end if;
			elsif state = 1 then
				rvalid_gfx  <= '0';
				rdready_gfx <= '1';
				state   := 2;
			elsif state = 2 then
				if rdvalid_gfx = '1' and rres_gfx = "00" then
					rdready_gfx                            <= '0';
					tdata(lp * 32 + 31 downto lp * 32) := rdata_gfx;
					lp                                 := lp + 1;
					if rlast_gfx = '1' then
						state := 3;
						lp    := 0;
					end if;
					rdready_gfx <= '1';
				end if;
			elsif state = 3 then
				--gfx_ack <= '1';
				if tep_gfx(75 downto 73) = "000" then
					bus_res1_2 <= tep_gfx(72 downto 32) & tdata;
					state := 4;
				elsif tep_gfx(75 downto 73)="101" then
					bus_res2_2 <= tep_gfx(72 downto 32) & tdata;
					state := 4;
--				elsif tep_gfx(75 downto 73)="001" then
--					gfx_upres1 <= tep_gfx(72 downto 32) & tdata;
--					state := 5;
				elsif tep_gfx(75 downto 73)="010" then
					uart_upres2 <= tep_gfx(72 downto 32) & tdata;
					state := 6;
				elsif tep_gfx(75 downto 73)="011" then
					usb_upres2<= tep_gfx(72 downto 32) & tdata;
					state := 7;
				elsif tep_gfx(75 downto 73)="100" then
					audio_upres2 <= tep_gfx(72 downto 32) & tdata;
					state := 8;
				end if;
				
			elsif state = 4 then
				if brs2_ack2 = '1' then
					bus_res2_2 <= nullreq;
					state      := 0;
				elsif brs1_ack2 = '1' then
					bus_res1_2 <= nullreq;
					state      := 0;
				end if;
--			elsif state =5 then
--				if gfx_upres_ack1 ='1' then
--					gfx_upres1 <= (others => '0');
--					state :=0;
--				end if;
			elsif state =6 then
				if uart_upres_ack2 ='1' then
					uart_upres2 <= (others => '0');
					state :=0;
				end if;	
			elsif state =7 then
				if usb_upres_ack2 ='1' then
					usb_upres2<= (others => '0');
					state :=0;
				end if;
			elsif state =8 then
				if audio_upres_ack2 ='1' then
					audio_upres2 <= (others => '0');
					state :=0;
				end if;	
			end if;
		end if;
	end process;
	
	toaudio_arbitor : entity work.arbiter2(Behavioral) 
	generic map(
		DATA_WIDTH=>76
	)
	port map(
			clock => Clock,
			reset => reset,
			din1  => toaudio1,
			ack1  => audio_ack1,
			din2  => toaudio2,
			ack2  => audio_ack2,
			dout  => toaudio_p
		);
	tousb_arbitor : entity work.arbiter2(Behavioral) 
	generic map(
		DATA_WIDTH=>76
	)
	port map(
			clock => Clock,
			reset => reset,
			din1  => tousb1,
			ack1  => usb_ack1,
			din2  => tousb2,
			ack2  => usb_ack2,
			dout  => tousb_p
		);
	tousb_channel : process(reset, Clock)
		variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
		variable state   : integer                        := 0;
		variable lp      : integer                        := 0;
		variable tep_usb : std_logic_vector(73 downto 0);
		variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
	begin
		if reset = '1' then
			rvalid_usb  <= '0';
			rdready_usb <= '0';
		elsif rising_edge(Clock) then
			if state = 0 then
				bus_res1_4 <= nullreq;
				bus_res2_4 <= nullreq;
				gfx_upres4 <= (others => '0');
				uart_upres4<= (others => '0');
				audio_upres4<= (others => '0');
				usb_upres4 <= (others => '0');
				if tousb_p(72 downto 72) = "1" then
					tep_usb := tousb_p;
					state :=6;
				end if;
			elsif state =6 then
				if rready_usb = '1' then
					--usb_ack <= '0';
					rvalid_usb  <= '1';
					raddr_usb   <= tousb_p(63 downto 32);
					rlen_usb    <= "00001" & "00000";
					rsize_usb  <= "00001" & "00000";
					state   := 1;
				end if;
			elsif state = 1 then
				rvalid_usb  <= '0';
				rdready_usb <= '1';
				state   := 2;
			elsif state = 2 then
				if rdvalid_usb = '1' and rres_usb = "00" then
					rdready_usb                            <= '0';
					tdata(lp * 32 + 31 downto lp * 32) := rdata_usb;
					lp                                 := lp + 1;
					if rlast_usb = '1' then
						state := 3;
						lp    := 0;
					end if;
					rdready_usb <= '1';
				end if;
			elsif state = 3 then
				--usb_ack <= '1';
				if tep_usb(75 downto 73) = "000" then
					bus_res1_4 <= tep_usb(72 downto 32) & tdata;
					state := 4;
				elsif tep_usb(75 downto 73)="101" then
					bus_res2_4 <= tep_usb(72 downto 32) & tdata;
					state := 4;
				elsif tep_usb(75 downto 73)="001" then
					gfx_upres4 <= tep_usb(72 downto 32) & tdata;
					state := 5;
				elsif tep_usb(75 downto 73)="010" then
					uart_upres4 <= tep_usb(72 downto 32) & tdata;
					state := 6;
				elsif tep_usb(75 downto 73)="011" then
					usb_upres4<= tep_usb(72 downto 32) & tdata;
					state := 7;
				elsif tep_usb(75 downto 73)="100" then
					audio_upres4 <= tep_usb(72 downto 32) & tdata;
					state := 8;
				end if;
				
			elsif state = 4 then
				if brs2_ack4 = '1' then
					bus_res2_4 <= nullreq;
					state      := 0;
				elsif brs1_ack4 = '1' then
					bus_res1_4<= nullreq;
					state      := 0;
				end if;
			elsif state =5 then
				if gfx_upres_ack4 ='1' then
					gfx_upres4 <= (others => '0');
					state :=0;
				end if;
			elsif state =6 then
				if uart_upres_ack4 ='1' then
					uart_upres4 <= (others => '0');
					state :=0;
				end if;	
			elsif state =7 then
				if usb_upres_ack4 ='1' then
					usb_upres4 <= (others => '0');
					state :=0;
				end if;
			elsif state =8 then
				if audio_upres_ack4 ='1' then
					audio_upres4 <= (others => '0');
					state :=0;
				end if;	
			end if;
		end if;
	end process;
	touart_arbitor : entity work.arbiter2(Behavioral) 
	generic map(
		DATA_WIDTH=>76
	)
	port map(
			clock => Clock,
			reset => reset,
			din1  => touart1,
			ack1  => uart_ack1,
			din2  => touart2,
			ack2  => uart_ack2,
			dout  => touart_p
		);
	touart_channel : process(reset, Clock)
		variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
		variable state   : integer                        := 0;
		variable lp      : integer                        := 0;
		variable tep_uart : std_logic_vector(73 downto 0);
		variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
	begin
		if reset = '1' then
			rvalid_uart  <= '0';
			rdready_uart <= '0';
		elsif rising_edge(Clock) then
			if state = 0 then
				bus_res1_3 <= nullreq;
				bus_res2_3 <= nullreq;
				gfx_upres3 <= (others => '0');
				uart_upres3 <= (others => '0');
				audio_upres3<= (others => '0');
				usb_upres3 <= (others => '0');
				if touart_p(72 downto 72) = "1" then
					tep_uart := touart_p;
					state :=6;
				end if;
			elsif state =6 then
				if rready_uart = '1' then
					--uart_ack <= '0';
					rvalid_uart  <= '1';
					raddr_uart   <= touart_p(63 downto 32);
					rlen_uart    <= "00001" & "00000";
					rsize_uart  <= "00001" & "00000";
					state   := 1;
				end if;
			elsif state = 1 then
				rvalid_uart  <= '0';
				rdready_uart <= '1';
				state   := 2;
			elsif state = 2 then
				if rdvalid_uart = '1' and rres_uart = "00" then
					rdready_uart                            <= '0';
					tdata(lp * 32 + 31 downto lp * 32) := rdata_uart;
					lp                                 := lp + 1;
					if rlast_uart = '1' then
						state := 3;
						lp    := 0;
					end if;
					rdready_uart <= '1';
				end if;
			elsif state = 3 then
				--uart_ack <= '1';
				if tep_uart(75 downto 73) = "000" then
					bus_res1_3 <= tep_uart(72 downto 32) & tdata;
					state := 4;
				elsif tep_uart(75 downto 73)="101" then
					bus_res2_3 <= tep_uart(72 downto 32) & tdata;
					state := 4;
				elsif tep_uart(75 downto 73)="001" then
					gfx_upres3 <= tep_uart(72 downto 32) & tdata;
					state := 5;
				elsif tep_uart(75 downto 73)="010" then
					uart_upres3 <= tep_uart(72 downto 32) & tdata;
					state := 6;
				elsif tep_uart(75 downto 73)="011" then
					usb_upres3<= tep_uart(72 downto 32) & tdata;
					state := 7;
				elsif tep_uart(75 downto 73)="100" then
					audio_upres3<= tep_uart(72 downto 32) & tdata;
					state := 8;
				end if;
				
			elsif state = 4 then
				if brs2_ack3 = '1' then
					bus_res2_3 <= nullreq;
					state      := 0;
				elsif brs1_ack3 = '1' then
					bus_res1_3<= nullreq;
					state      := 0;
				end if;
			elsif state =5 then
				if gfx_upres_ack3 ='1' then
					gfx_upres3 <= (others => '0');
					state :=0;
				end if;
			elsif state =6 then
				if uart_upres_ack3 ='1' then
					uart_upres3 <= (others => '0');
					state :=0;
				end if;	
			elsif state =7 then
				if usb_upres_ack3 ='1' then
					usb_upres3 <= (others => '0');
					state :=0;
				end if;
			elsif state =8 then
				if audio_upres_ack3 ='1' then
					audio_upres3 <= (others => '0');
					state :=0;
				end if;	
			end if;
		end if;
	end process;
	
	brs2_arbitor : entity work.arbiter6(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => bus_res2_1,
			ack1  => brs2_ack1,
			din2  => bus_res2_2,
			ack2  => brs2_ack2,
			dout  => bus_res2,
			din3  => bus_res2_3,
			din4  => bus_res2_4,
			ack4  => brs2_ack4,
			din5  => bus_res2_5,
			ack5  => brs2_ack5,
			din6  => bus_res2_6,
			ack6  => brs2_ack6,
			ack3  => brs2_ack3
		);
	snp1_arbitor : entity work.arbiter6(Behavioral)
		generic map(
			DATA_WIDTH => 54
		)
		port map(
			clock => Clock,
			reset => reset,
			din1  => snp1_1,
			ack1  => snp1_ack1,
			din2  => snp1_2,
			ack2  => snp1_ack2,
			din3  => snp1_3,
			ack3  => snp1_ack3,
			din4  => snp1_4,
			ack4  => snp1_ack4,
			din5  => snp1_5,
			ack5  => snp1_ack5,
			din6  => snp1_6,
			ack6  => snp1_ack6,
			dout  => snoop_req1
		);
	snp2_arbitor : entity work.arbiter6(Behavioral) generic map(
			DATA_WIDTH => 54
		)
		port map(
			clock => Clock,
			reset => reset,
			din1  => snp2_1,
			ack1  => snp2_ack1,
			din2  => snp2_2,
			ack2  => snp2_ack2,
			din3  => snp2_3,
			ack3  => snp2_ack3,
			din4  => snp2_4,
			ack4  => snp2_ack4,
			din5  => snp2_5,
			ack5  => snp2_ack5,
			din6  => snp2_6,
			ack6  => snp2_ack6,
			dout  => snoop_req2
		);
	pwr_arbitor : entity work.arbiter61(Behavioral)
		generic map(
			DATA_WIDTH => 5
		)
		port map(
			clock => Clock,
			reset => reset,
			din1  => pwr_req1,
			ack1  => pwr_ack1,
			din2  => pwr_req2,
			ack2  => pwr_ack2,
			din3  => pwr_req3,
			ack3  => pwr_ack3,
			din4  => pwr_req4,
			ack4  => pwr_ack4,
			din5  => pwr_req5,
			ack5  => pwr_ack5,
			din6  => pwr_req6,
			ack6  => pwr_ack6,
			dout  => pwrreq
		);

	brs1_arbitor : entity work.arbiter6(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => bus_res1_1,
			ack1  => brs1_ack1,
			din2  => bus_res1_2,
			ack2  => brs1_ack2,
			din3  => bus_res1_3,
			ack3  => brs1_ack3,
			din4  => bus_res1_4,
			ack4  => brs1_ack4,
			din5  => bus_res1_5,
			ack5  => brs1_ack5,
			din6  => bus_res1_6,
			ack6  => brs1_ack6,
			dout  => bus_res1
		);
	gfx_upres_arbitor : entity work.arbiter6(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => gfx_upres1,
			ack1  => gfx_upres_ack1,
			din2  => gfx_upres2,
			ack2  => gfx_upres_ack2,
			din3  => gfx_upres3,
			ack3  => gfx_upres_ack3,
			din4  => gfx_upres4,
			ack4  => gfx_upres_ack4,
			din5  => gfx_upres5,
			ack5  => gfx_upres_ack5,
			din6  => gfx_upres6,
			ack6  => gfx_upres_ack6,
			dout  => gfx_upres
		);
	audio_upres_arbitor : entity work.arbiter6(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => audio_upres1,
			ack1  => audio_upres_ack1,
			din2  => audio_upres2,
			ack2  => audio_upres_ack2,
			din3  => audio_upres3,
			ack3  => audio_upres_ack3,
			din4  => audio_upres4,
			ack4  => audio_upres_ack4,
			din5  => audio_upres5,
			ack5  => audio_upres_ack5,
			din6  => audio_upres6,
			ack6  => audio_upres_ack6,
			dout  => audio_upres
		);
	usb_upres_arbitor : entity work.arbiter6(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => usb_upres1,
			ack1  => usb_upres_ack1,
			din2  => usb_upres2,
			ack2  => usb_upres_ack2,
			din3  => usb_upres3,
			ack3  => usb_upres_ack3,
			din4  => usb_upres4,
			ack4  => usb_upres_ack4,
			din5  => usb_upres5,
			ack5  => usb_upres_ack5,
			din6  => usb_upres6,
			ack6  => usb_upres_ack6,
			dout  => usb_upres
		);
	uart_upres_arbitor : entity work.arbiter6(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => uart_upres1,
			ack1  => uart_upres_ack1,
			din2  => uart_upres2,
			ack2  => uart_upres_ack2,
			din3  => uart_upres3,
			ack3  => uart_upres_ack3,
			din4  => uart_upres4,
			ack4  => uart_upres_ack4,
			din5  => uart_upres5,
			ack5  => uart_upres_ack5,
			din6  => uart_upres6,
			ack6  => uart_upres_ack6,
			dout  => uart_upres
		);

	wb_arbitor : entity work.arbiter2(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => mem_wb1,
			ack1  => wb_ack1,
			din2  => mem_wb2,
			ack2  => wb_ack2,
			dout  => mem_wb
		);
	gfx_wb_arbitor : entity work.arbiter2(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => gfx_wb1,
			ack1  => gfx_wb_ack1,
			din2  => gfx_wb2,
			ack2  => gfx_wb_ack2,
			dout  => gfx_wb
		);
	audio_wb_arbitor : entity work.arbiter2(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => audio_wb1,
			ack1  => audio_wb_ack1,
			din2  => audio_wb2,
			ack2  => audio_wb_ack2,
			dout  => audio_wb
		);
		toaudio_channel : process(reset, Clock)
		variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
		variable state   : integer                        := 0;
		variable lp      : integer                        := 0;
		variable tep_audio : std_logic_vector(73 downto 0);
		variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
	begin
		if reset = '1' then
			rvalid_audio  <= '0';
			rdready_audio <= '0';
		elsif rising_edge(Clock) then
			if state = 0 then
				bus_res1_5 <= nullreq;
				bus_res2_5 <= nullreq;
				gfx_upres5 <= (others => '0');
				uart_upres5 <= (others => '0');
				audio_upres5<= (others => '0');
				usb_upres5 <= (others => '0');
				if toaudio_p(72 downto 72) = "1" then
					tep_audio := toaudio_p;
					state :=6;
				end if;
			elsif state =6 then
				if rready_audio = '1' then
					--audio_ack <= '0';
					rvalid_audio  <= '1';
					raddr_audio   <= toaudio_p(63 downto 32);
					rlen_audio    <= "00001" & "00000";
					rsize_audio  <= "00001" & "00000";
					state   := 1;
				end if;
			elsif state = 1 then
				rvalid_audio  <= '0';
				rdready_audio <= '1';
				state   := 2;
			elsif state = 2 then
				if rdvalid_audio = '1' and rres_audio = "00" then
					rdready_audio                            <= '0';
					tdata(lp * 32 + 31 downto lp * 32) := rdata_audio;
					lp                                 := lp + 1;
					if rlast_audio = '1' then
						state := 3;
						lp    := 0;
					end if;
					rdready_audio <= '1';
				end if;
			elsif state = 3 then
				--audio_ack <= '1';
				if tep_audio(75 downto 73) = "000" then
					bus_res1_5 <= tep_audio(72 downto 32) & tdata;
					state := 4;
				elsif tep_audio(75 downto 73)="101" then
					bus_res2_5 <= tep_audio(72 downto 32) & tdata;
					state := 4;
				elsif tep_audio(75 downto 73)="001" then
					gfx_upres5 <= tep_audio(72 downto 32) & tdata;
					state := 5;
				elsif tep_audio(75 downto 73)="010" then
					uart_upres5 <= tep_audio(72 downto 32) & tdata;
					state := 6;
				elsif tep_audio(75 downto 73)="011" then
					usb_upres5<= tep_audio(72 downto 32) & tdata;
					state := 7;
				elsif tep_audio(75 downto 73)="100" then
					audio_upres5<= tep_audio(72 downto 32) & tdata;
					state := 8;
				end if;
				
			elsif state = 4 then
				if brs2_ack5 = '1' then
					bus_res2_5 <= nullreq;
					state      := 0;
				elsif brs1_ack5 = '1' then
					bus_res1_5 <= nullreq;
					state      := 0;
				end if;
			elsif state =5 then
				if gfx_upres_ack5 ='1' then
					gfx_upres5 <= (others => '0');
					state :=0;
				end if;
			elsif state =6 then
				if uart_upres_ack5 ='1' then
					uart_upres5 <= (others => '0');
					state :=0;
				end if;	
			elsif state =7 then
				if usb_upres_ack5 ='1' then
					usb_upres5 <= (others => '0');
					state :=0;
				end if;
			elsif state =8 then
				if audio_upres_ack5 ='1' then
					audio_upres5 <= (others => '0');
					state :=0;
				end if;	
			end if;
		end if;
	end process;	
	usb_wb_arbitor : entity work.arbiter2(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => usb_wb1,
			ack1  => usb_wb_ack1,
			din2  => usb_wb2,
			ack2  => usb_wb_ack2,
			dout  => usb_wb
		);
	uart_wb_arbitor : entity work.arbiter2(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => uart_wb1,
			ack1  => uart_wb_ack1,
			din2  => uart_wb2,
			ack2  => uart_wb_ack2,
			dout  => uart_wb
		);

	snp_res1_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we2 <= '0';
		elsif rising_edge(Clock) then
			if snoop_res1(50 downto 50) = "1" then
				if snp_hit1 = '0' then
					in2 <= '0' & snoop_res1;
				else
					in2 <= '1' & snoop_res1;
				end if;
				we2 <= '1';
			else
				we2 <= '0';
			end if;

		end if;
	end process;
	snp_res2_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we5 <= '0';
		elsif rising_edge(Clock) then
			if snoop_res2(50 downto 50) = "1" then
				if snp_hit2 = '0' then
					in5 <= '0' & snoop_res2;
				else
					in5 <= '1' & snoop_res2;
				end if;
				we5 <= '1';
			else
				we5 <= '0';
			end if;
		end if;
	end process;

	wb_req1_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we6 <= '0';
		elsif rising_edge(Clock) then
			if (wb_req1(552 downto 552) = "1") then
				in6 <= wb_req1;
				we6 <= '1';
			else
				we6 <= '0';
			end if;
		end if;
	end process;

	wb_req2_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we7 <= '0';
		elsif rising_edge(Clock) then
			if (wb_req2(552 downto 552) = "1") then
				in7 <= wb_req2;
				we7 <= '1';
			else
				we7 <= '0';
			end if;
		end if;
	end process;

	pwr_res_p : process(reset, Clock)
	begin
		if reset = '1' then
		elsif rising_edge(Clock) then
			if pwrres(4 downto 4) = "1" then
				if pwrres(3 downto 2) = "00" then
					if pwrres(1 downto 0) = "00" then
						gfxpoweron <= '0';
					elsif pwrres(1 downto 0) = "01" then
						audiopoweron <= '0';
					elsif pwrres(1 downto 0) = "10" then
						usbpoweron <= '0';
					elsif pwrres(1 downto 0) = "11" then
						uartpoweron <= '0';
					end if;
				elsif pwrres(3 downto 2) = "10" then
					if pwrres(1 downto 0) = "00" then
						gfxpoweron <= '1';
					elsif pwrres(1 downto 0) = "01" then
						audiopoweron <= '1';
					elsif pwrres(1 downto 0) = "10" then
						usbpoweron <= '1';
					elsif pwrres(1 downto 0) = "11" then
						uartpoweron <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	---write_back process
	wb_1_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable state  : integer;
	begin
		if reset = '1' then
			mem_wb1 <= (others => '0');
			state   := 0;

		elsif rising_edge(Clock) then
			if state = 0 then
				if re6 = '0' and emp6 = '0' then
					re6   <= '1';
					state := 1;
				end if;
			elsif state = 1 then
				re6 <= '0';
				if out6(50 downto 50) = "1" then
					if to_integer(unsigned(out6(47 downto 32))) < 32768 then
						state   := 2;
						mem_wb1 <= out6;
					else
						state   := 3;
						gfx_wb1 <= out6;
					end if;
				end if;

			elsif state = 2 then
				if wb_ack1 = '1' then
					mem_wb1 <= (others => '0');
					state   := 0;
				end if;
			elsif state = 3 then
				if gfx_wb_ack1 = '1' then
					gfx_wb1 <= (others => '0');
					state   := 0;
				end if;
			end if;

		end if;
	end process;

	---write_back process
	wb_2_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable state  : integer;
	begin
		if reset = '1' then
			mem_wb2 <= (others => '0');
			state   := 0;

		elsif rising_edge(Clock) then
			if state = 0 then
				if re7 = '0' and emp7 = '0' then
					re7   <= '1';
					state := 1;
				end if;
			elsif state = 1 then
				re7 <= '0';
				if out7(50 downto 50) = "1" then
					if to_integer(unsigned(out6(47 downto 32))) < 32768 then
						state   := 2;
						mem_wb2 <= out7;
					else
						state   := 3;
						gfx_wb2 <= out7;
					end if;
				end if;

			elsif state = 2 then
				if wb_ack2 = '1' then
					mem_wb2 <= (others => '0');
					state   := 0;
				end if;
			elsif state = 3 then
				if gfx_wb_ack2 = '1' then
					gfx_wb2 <= (others => '0');
					state   := 0;
				end if;
			end if;

		end if;
	end process;

	gfx_res_p : process(reset, Clock)
		variable stage : integer := 0;
		variable cpu1  : std_logic;
	begin
		if reset = '1' then
			bus_res1_3 <= (others => '0');
			bus_res2_3 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re8 = '0' and emp8 = '0' then
					re8   <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re8 <= '0';
				if out8(50 downto 50) = "1" then
					---response for cpu1
					if out8(53 downto 51) = "000" then
						---reg_1 <= out8(50 downto 0);
						bus_res1_3 <= out8(50 downto 0);
						cpu1       := '1';
						stage      := 2;
					elsif out8(53 downto 51) = "001" then
						gfx_upres3 <= out8(50 downto 0);
						stage      := 3;
					elsif out8(53 downto 51) = "010" then
						uart_upres3 <= out8(50 downto 0);
						stage       := 4;
					elsif out8(53 downto 51) = "011" then
						usb_upres3 <= out8(50 downto 0);
						stage      := 5;
					elsif out8(53 downto 51) = "100" then
						audio_upres3 <= out8(50 downto 0);
						stage        := 6;
					---response for cpu2
					elsif out8(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_3 <= out8(50 downto 0);
						cpu1       := '0';
						stage      := 2;
					end if;
				end if;
			elsif stage = 2 then
				if cpu1 = '1' and brs1_ack3 = '1' then
					bus_res1_3 <= (others => '0');
					stage      := 0;
				elsif cpu1 = '0' and brs2_ack3 = '1' then
					bus_res2_3 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 3 then
				if gfx_upres_ack3 = '1' then
					gfx_upres3 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 4 then
				if uart_upres_ack3 = '1' then
					uart_upres3 <= (others => '0');
					stage       := 0;
				end if;
			elsif stage = 5 then
				if usb_upres_ack3 = '1' then
					usb_upres3 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 6 then
				if audio_upres_ack3 = '1' then
					usb_upres3 <= (others => '0');
					stage      := 0;
				end if;
			end if;
		end if;

	end process;
	audio_res_p : process(reset, Clock)
		variable stage : integer := 0;
		variable cpu1  : std_logic;
	begin
		if reset = '1' then
			bus_res1_4 <= (others => '0');
			bus_res2_4 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re10 = '0' and emp10 = '0' then
					re10  <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re10 <= '0';
				if out10(50 downto 50) = "1" then

					---response for cpu1
					if out10(53 downto 51) = "000" then
						---reg_1 <= out10(50 downto 0);
						bus_res1_4 <= out10(50 downto 0);
						cpu1       := '1';
						stage      := 2;
					elsif out10(53 downto 51) = "001" then
						gfx_upres4 <= out10(50 downto 0);
						stage      := 3;
					elsif out10(53 downto 51) = "010" then
						uart_upres4 <= out10(50 downto 0);
						stage       := 4;
					elsif out10(53 downto 51) = "011" then
						usb_upres4 <= out10(50 downto 0);
						stage      := 5;

					---response for cpu2
					elsif out10(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_4 <= out10(50 downto 0);
						cpu1       := '0';
						stage      := 2;
					end if;
				end if;
			elsif stage = 2 then
				if cpu1 = '1' and brs1_ack3 = '1' then
					bus_res1_4 <= (others => '0');
					stage      := 0;
				elsif cpu1 = '0' and brs2_ack3 = '1' then
					bus_res2_4 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 3 then
				if gfx_upres_ack4 = '1' then
					gfx_upres4 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 4 then
				if uart_upres_ack4 = '1' then
					uart_upres4 <= (others => '0');
					stage       := 0;
				end if;
			elsif stage = 5 then
				if usb_upres_ack4 = '1' then
					usb_upres4 <= (others => '0');
					stage      := 0;
				end if;

			end if;
		end if;

	end process;
	usb_res_p : process(reset, Clock)
		variable stage : integer := 0;
		variable cpu1  : std_logic;
	begin
		if reset = '1' then
			bus_res1_5 <= (others => '0');
			bus_res2_5 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re11 = '0' and emp11 = '0' then
					re11  <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re11 <= '0';
				if out11(50 downto 50) = "1" then

					---response for cpu1
					if out11(53 downto 51) = "000" then
						---reg_1 <= out11(50 downto 0);
						bus_res1_5 <= out11(50 downto 0);
						cpu1       := '1';
						stage      := 2;
					elsif out11(53 downto 51) = "001" then
						gfx_upres5 <= out11(50 downto 0);
						stage      := 3;
					elsif out11(53 downto 51) = "010" then
						uart_upres5 <= out11(50 downto 0);
						stage       := 4;
					elsif out11(53 downto 51) = "100" then
						audio_upres5 <= out11(50 downto 0);
						stage        := 6;
					---response for cpu2
					elsif out11(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_5 <= out11(50 downto 0);
						cpu1       := '0';
						stage      := 2;
					end if;
				end if;
			elsif stage = 2 then
				if cpu1 = '1' and brs1_ack3 = '1' then
					bus_res1_5 <= (others => '0');
					stage      := 0;
				elsif cpu1 = '0' and brs2_ack3 = '1' then
					bus_res2_5 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 3 then
				if gfx_upres_ack5 = '1' then
					gfx_upres5 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 4 then
				if uart_upres_ack5 = '1' then
					uart_upres5 <= (others => '0');
					stage       := 0;
				end if;
			elsif stage = 6 then
				if audio_upres_ack5 = '1' then
					usb_upres5 <= (others => '0');
					stage      := 0;
				end if;
			end if;
		end if;

	end process;

	uart_res_p : process(reset, Clock)
		variable stage : integer := 0;
		variable cpu1  : std_logic;
	begin
		if reset = '1' then
			bus_res1_6 <= (others => '0');
			bus_res2_6 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re12 = '0' and emp12 = '0' then
					re12  <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re12 <= '0';
				if out12(50 downto 50) = "1" then

					---response for cpu1
					if out12(53 downto 51) = "000" then
						---reg_1 <= out12(50 downto 0);
						bus_res1_6 <= out12(50 downto 0);
						cpu1       := '1';
						stage      := 2;
					elsif out12(53 downto 51) = "001" then
						gfx_upres6 <= out12(50 downto 0);
						stage      := 3;

					elsif out12(53 downto 51) = "011" then
						usb_upres6 <= out12(50 downto 0);
						stage      := 5;
					elsif out12(53 downto 51) = "100" then
						audio_upres6 <= out12(50 downto 0);
						stage        := 6;
					---response for cpu2
					elsif out12(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_6 <= out12(50 downto 0);
						cpu1       := '0';
						stage      := 2;
					end if;
				end if;
			elsif stage = 2 then
				if cpu1 = '1' and brs1_ack6 = '1' then
					bus_res1_6 <= (others => '0');
					stage      := 0;
				elsif cpu1 = '0' and brs2_ack6 = '1' then
					bus_res2_6 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 3 then
				if gfx_upres_ack6 = '1' then
					gfx_upres6 <= (others => '0');
					stage      := 0;
				end if;

			elsif stage = 5 then
				if usb_upres_ack6 = '1' then
					usb_upres6 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 6 then
				if audio_upres_ack6 = '1' then
					usb_upres6 <= (others => '0');
					stage      := 0;
				end if;
			end if;
		end if;

	end process;
	---deal with cache request
	cache_req1_p : process(reset, Clock)
		variable nilreq : std_logic_vector(72 downto 0) := (others => '0');
		variable state  : integer                       := 0;
		variable count  : integer                       := 0;
	begin
		if reset = '1' then
			snoop_req2 <= nilreq;
		elsif rising_edge(Clock) then
			if state = 0 then
				if cache_req1(72 downto 72) = "1" and cache_req1(63 downto 32) = adr_1 then
					state   := 1;
					tmp_sp2 <= cache_req1;
				elsif cache_req1(72 downto 72) = "1" and cache_req1(71 downto 64) = "11111111" then
					---let's not consider power now, too complicated
					---pwr_req1 <= cache_req1(72 downto 46);
					state := 4;
				elsif cache_req1(72 downto 72) = "1" and full_srq2 /= '1' then
					snoop_req2 <= cache_req1;
					adr_0      <= cache_req1(63 downto 32);
					state      := 0;
				else
					snoop_req2 <= nilreq;
					state      := 0;
				end if;
			elsif state = 1 then
				state := 2;
			elsif state = 2 then
				count := count + 1;
				if count > 20 then
					state := 3;
					count := 0;
				end if;
			elsif state = 3 then
				snoop_req2 <= tmp_sp2;
				adr_0      <= tmp_sp2(63 downto 32);
				state      := 0;
			elsif state = 4 then
				if pwr_ack1 = '1' then
					---pwr_req1<= "00000";
					state := 0;
				end if;
			end if;
		end if;
	end process;

	---deal with cache request
	cache_req2_p : process(reset, Clock)
		variable nilreq : std_logic_vector(72 downto 0) := (others => '0');
		variable state  : integer                       := 0;
		variable count  : integer                       := 0;
	begin
		if reset = '1' then
			snoop_req1 <= nilreq;
		elsif rising_edge(Clock) then
			if state = 0 then
				if cache_req2(72 downto 72) = "1" and cache_req2(63 downto 32) = adr_0 then
					state   := 1;
					tmp_sp1 <= cache_req2;
				elsif cache_req1(72 downto 72) = "1" and cache_req1(71 downto 64) = "11111111" then
					---pwr_req2 <= cache_req2(72 downto 46);
					state := 4;
				elsif cache_req2(72 downto 72) = "1" and full_srq2 /= '1' then
					snoop_req1 <= cache_req2;
					adr_1      <= cache_req2(63 downto 32);
					state      := 0;
				else
					snoop_req1 <= nilreq;
					state      := 0;
				end if;
			elsif state = 1 then
				state := 2;
			elsif state = 2 then
				count := count + 1;
				if count > 20 then
					count := 0;
					state := 3;
				end if;
			elsif state = 3 then
				snoop_req1 <= tmp_sp1;
				adr_1      <= tmp_sp1(63 downto 32);
				state      := 0;
			elsif state = 4 then
				if pwr_ack2 = '1' then
					---pwr_req2<= "00000";
					state := 0;
				end if;
			end if;
		end if;
	end process;
	snp_res1_p : process(reset, Clock)
		variable nilreq : std_logic_vector(552 downto 0) := (others => '0');
		variable state  : integer                        := 0;
	begin
		if reset = '1' then
			re2        <= '0';
			bus_res2_1 <= nilreq;
			tomem1     <= nilreq(72 downto 0);
		---tmp_brs2_1 <= nilreq;
		---tmp_mem1 <=nilreq;
		elsif rising_edge(Clock) then
			if state = 0 then
				if re2 = '0' and emp2 = '0' then
					re2   <= '1';
					state := 1;
				end if;

			elsif state = 1 then
				re2 <= '0';
				if out2(552 downto 552) = "1" then
					if out2(553 downto 553) = "1" then --it;s a hit
						state      := 2;
						bus_res2_1 <= out2(552 downto 0);
					else                ---it's a miss
						state  := 3;
						tomem1 <= out2(552 downto 480);
					end if;
				end if;
			elsif state = 2 then
				if brs2_ack1 = '1' then
					bus_res2_1 <= nilreq;
					state      := 0;
				end if;

			elsif state = 3 then
				if mem_ack1 = '1' then
					tomem1 <= nilreq(72 downto 0);
					state  := 0;
				end if;

			end if;

		end if;
	end process;
	snp_res2_p : process(reset, Clock)
		variable nilreq : std_logic_vector(552 downto 0) := (others => '0');
		variable state  : integer                        := 0;
	begin
		if reset = '1' then
			re5        <= '0';
			bus_res1_2 <= nilreq;
			tomem2     <= nilreq(72 downto 0);
			--tmp_brs1_2 <= nilreq;
			--tmp_mem2 <=nilreq;
			state      := 0;
		elsif rising_edge(Clock) then
			if state = 0 then
				if re5 = '0' and emp5 = '0' then
					re5   <= '1';
					state := 1;
				end if;
			elsif state = 1 then
				re5 <= '0';
				if out5(552 downto 552) = "1" then
					if out5(553 downto 553) = "1" then --it;s a hit
						state      := 2;
						bus_res1_2 <= out5(552 downto 0);
					else                ---it's a miss
						tomem2 <= out5(552 downto 480);
						state  := 3;
					end if;
				end if;

			elsif state = 2 then
				if brs1_ack2 = '1' then
					bus_res1_2 <= nilreq;
					state      := 0;
				end if;

			elsif state = 3 then
				if mem_ack2 = '1' then
					tomem2 <= nilreq(72 downto 0);
					state  := 0;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
