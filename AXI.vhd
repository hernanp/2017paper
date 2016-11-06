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
		Clock                                                                      : in  std_logic;
		reset                                                                      : in  std_logic;
		cache_req1                                                                 : in  STD_LOGIC_VECTOR(50 downto 0);
		cache_req2                                                                 : in  STD_LOGIC_VECTOR(50 downto 0);
		wb_req1, wb_req2                                                           : in  std_logic_vector(50 downto 0);
		memres                                                                     : in  STD_LOGIC_VECTOR(53 downto 0);
		
		bus_res1                                                                   : out STD_LOGIC_VECTOR(50 downto 0);
		bus_res2                                                                   : out STD_LOGIC_VECTOR(50 downto 0);
		tomem                                                                      : out STD_LOGIC_VECTOR(53 downto 0);
		togfx                                                                      : out std_logic_vector(53 downto 0);
		gfxres                                                                     : in  std_logic_vector(53 downto 0);
		tousb                                                                      : out std_logic_vector(53 downto 0);
		usbres                                                                     : in  std_logic_vector(53 downto 0);
		toaudio                                                                      : out std_logic_vector(53 downto 0);
		audiores                                                                     : in  std_logic_vector(53 downto 0);
		touart                                                                      : out std_logic_vector(53 downto 0);
		uartres                                                                     : in  std_logic_vector(53 downto 0);
		--add 3 bits in snoop request to indicate the source
		--000 cpu0
		--001 gfx
		--010 uart
		--011 usb
		--100 audio
		--101 cpu1
		snoop_req1                                                                 : out STD_LOGIC_VECTOR(53 downto 0);
		snoop_req2                                                                 : out STD_LOGIC_VECTOR(53 downto 0);
		snoop_res1, snoop_res2                                                     : in  STD_LOGIC_VECTOR(53 downto 0);
		snp_hit1                                                                   : in  std_logic;
		snp_hit2                                                                   : in  std_logic;
		full_srq1, full_srq2                                                       : in  std_logic;
		full_brs1, full_brs2                                                       : in  std_logic;
		full_crq1, full_crq2, full_wb1, full_srs1, full_wb2, full_srs2, full_gfxrs,full_audiors,full_usbrs,full_uartrs : out std_logic;
		full_m                                                                     : in  std_logic;
		full_b_m                                                                   : out std_logic := '0';
		mem_wb                                                                     : out std_logic_vector(50 downto 0);
		wb_ack                                                                     : in  std_logic;
		gfx_wb                                                                     : out std_logic_vector(50 downto 0);
		gfx_wb_ack                                                                 : in  std_logic;
		usb_wb                                                                     : out std_logic_vector(50 downto 0);
		usb_wb_ack                                                                 : in  std_logic;
		audio_wb                                                                     : out std_logic_vector(50 downto 0);
		audio_wb_ack                                                                 : in  std_logic;
		uart_wb                                                                     : out std_logic_vector(50 downto 0);
		uart_wb_ack                                                                 : in  std_logic;
		pwrreq                                                                     : out std_logic_vector(4 downto 0);
		pwrreq_full                                                                : in  std_logic;
		pwrres                                                                     : in  std_logic_vector(4 downto 0);
		gfx_upreq                                                                  : in  std_logic_vector(50 downto 0);
		gfx_upres                                                                  : out std_logic_vector(50 downto 0);
		gfx_upreq_full                                                             : out std_logic;
		audio_upreq                                                                  : in  std_logic_vector(50 downto 0);
		audio_upres                                                                  : out std_logic_vector(50 downto 0);
		audio_upreq_full                                                             : out std_logic;
		usb_upreq                                                                  : in  std_logic_vector(50 downto 0);
		usb_upres                                                                  : out std_logic_vector(50 downto 0);
		usb_upreq_full                                                             : out std_logic;
		uart_upreq                                                                  : in  std_logic_vector(50 downto 0);
		uart_upres                                                                  : out std_logic_vector(50 downto 0);
		uart_upreq_full                                                             : out std_logic
	);
end AXI;

architecture Behavioral of AXI is
	--fifo has 53 bits
	--3 bits for indicating its source
	--50 bits for packet

	signal in1, in4, in6, in7, in9, out9,in13, out13 ,in14, out14 ,in15, out15                                                            : std_logic_vector(50 downto 0);
	signal in3, out3, in8, out8,in10,out10,in11,out11,in12,out12                                                                     : std_logic_vector(53 downto 0);
	signal in2, out2, in5, out5                                                                     : std_logic_vector(54 downto 0);
	signal we1, we2, we3, we4, we5, we6, we7, we8, re8, re9, we9, re7, re1, re2, re3, re4, re5, re6,re10,we10,re11,we11,re12,we12,re13,we13,re14,we14,re15,we15 : std_logic := '0';
	signal out1, out4, out6, out7                                                                   : std_logic_vector(50 downto 0);
	signal emp1, emp2, emp3, emp4, emp5, emp6, emp7, emp8, emp9,emp10  ,emp11,emp12,emp13, emp14, emp15                                 : std_logic := '0';

	signal bus_res1_1, bus_res1_2, bus_res2_1, bus_res2_2, bus_res1_3, bus_res2_3,bus_res1_4, bus_res1_5, bus_res2_4, bus_res2_5, bus_res1_6, bus_res2_6                                             : std_logic_vector(50 downto 0);
	signal mem_ack1, mem_ack2, mem_ack3, gfx_ack1, gfx_ack2, audio_ack1, audio_ack2, usb_ack1, usb_ack2, uart_ack1, uart_ack2, brs1_ack1, brs1_ack2, brs1_ack3, brs2_ack3, brs2_ack1, brs2_ack2,brs1_ack4, brs1_ack5, brs1_ack6, brs2_ack5, brs2_ack4, brs2_ack6 : std_logic;

	signal togfx1, tmp_togfx1, tmp_togfx2, togfx2 : std_logic_vector(53 downto 0) := (others => '0');
	signal toaudio1, tmp_toaudio1, tmp_toaudio2, toaudio2 : std_logic_vector(53 downto 0) := (others => '0');
	signal tousb1, tmp_tousb1, tmp_tousb2, tousb2 : std_logic_vector(53 downto 0) := (others => '0');
	signal touart1, tmp_touart1, tmp_touart2, touart2 : std_logic_vector(53 downto 0) := (others => '0');
	signal tomem1, tomem2, tomem3                 : std_logic_vector(53 downto 0) := (others => '0');

	signal wb_ack1, wb_ack2, gfx_wb_ack1, gfx_wb_ack2, audio_wb_ack1, audio_wb_ack2, usb_wb_ack1, usb_wb_ack2, uart_wb_ack1, uart_wb_ack2 : std_logic;
	signal mem_wb1, mem_wb2, gfx_wb1, gfx_wb2, audio_wb1, audio_wb2, usb_wb1, usb_wb2, uart_wb1, uart_wb2         : std_logic_vector(50 downto 0) := (others => '0');
	signal reg_1, reg_2                               : std_logic_vector(50 downto 0) := (others => '0');
	--state information of power
	signal gfxpoweron                                 : std_logic                     := '0';
	signal audiopoweron							:std_logic := '0';
	signal usbpoweron: std_logic:='0';
	signal uartpoweron: std_logic:='0';

	signal adr_0, adr_1                                                                                                                       : std_logic_vector(15 downto 0);
	signal tmp_sp1, tmp_sp2                                                                                                                   : std_logic_vector(50 downto 0);
	signal pwr_req1, pwr_req2, pwr_req3,pwr_req4, pwr_req5, pwr_req6                                                                                                     : std_logic_vector(4 downto 0);
	signal pwr_ack1, pwr_ack2, pwr_ack3   ,pwr_ack4, pwr_ack5, pwr_ack6                                                                                                     : std_logic;
	signal snp1_1, snp1_2, snp1_3, snp1_4, snp1_5, snp1_6, snp2_1, snp2_2, snp2_3, snp2_4, snp2_5, snp2_6                                     : std_logic_vector(53 downto 0);
	signal snp1_ack1, snp1_ack2, snp1_ack3, snp1_ack4, snp1_ack5, snp1_ack6, snp2_ack1, snp2_ack2, snp2_ack3, snp2_ack4, snp2_ack5, snp2_ack6 : std_logic;

	signal gfx_upres1, gfx_upres2, gfx_upres3             : std_logic_vector(50 downto 0);
	signal gfx_upres_ack1, gfx_upres_ack2, gfx_upres_ack3 : std_logic;
	signal audio_upres1, audio_upres2, audio_upres3             : std_logic_vector(50 downto 0);
	signal audio_upres_ack1, audio_upres_ack2, audio_upres_ack3 : std_logic;
	signal usb_upres1, usb_upres2, usb_upres3             : std_logic_vector(50 downto 0);
	signal usb_upres_ack1, usb_upres_ack2, usb_upres_ack3 : std_logic;
	signal uart_upres1, uart_upres2, uart_upres3             : std_logic_vector(50 downto 0);
	signal uart_upres_ack1, uart_upres_ack2, uart_upres_ack3 : std_logic;
	signal gfx_upres4, gfx_upres5, gfx_upres6             : std_logic_vector(50 downto 0);
	signal gfx_upres_ack4, gfx_upres_ack5, gfx_upres_ack6 : std_logic;
	signal audio_upres4, audio_upres5, audio_upres6             : std_logic_vector(50 downto 0);
	signal audio_upres_ack4, audio_upres_ack5, audio_upres_ack6 : std_logic;
	signal usb_upres4, usb_upres5, usb_upres6             : std_logic_vector(50 downto 0);
	signal usb_upres_ack4, usb_upres_ack5, usb_upres_ack6 : std_logic;
	signal uart_upres4, uart_upres5, uart_upres6             : std_logic_vector(50 downto 0);
	signal uart_upres_ack4, uart_upres_ack5, uart_upres_ack6 : std_logic;

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

	mem_res_fif : entity work.STD_FIFO(Behavioral)
		generic map(
			DATA_WIDTH => 54,
			FIFO_DEPTH => 256
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in3,
			WriteEn => we3,
			ReadEn  => re3,
			DataOut => out3,
			Full    => full_b_m,
			Empty   => emp3
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
					re13   <= '1';
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
					re14   <= '1';
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
					re15   <= '1';
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
	
	
	tomem_arbitor : entity work.arbiter(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => tomem1,
			ack1  => mem_ack1,
			din2  => tomem2,
			ack2  => mem_ack2,
			dout  => tomem
		);
	togfx_arbitor : entity work.arbiter(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => togfx1,
			ack1  => gfx_ack1,
			din2  => togfx2,
			ack2  => gfx_ack2,
			dout  => togfx
		);
	toaudio_arbitor : entity work.arbiter(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => toaudio1,
			ack1  => audio_ack1,
			din2  => toaudio2,
			ack2  => audio_ack2,
			dout  => toaudio
		);
	tousb_arbitor : entity work.arbiter(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => tousb1,
			ack1  => usb_ack1,
			din2  => tousb2,
			ack2  => usb_ack2,
			dout  => tousb
		);
	touart_arbitor : entity work.arbiter(Behavioral) port map(
			clock => Clock,
			reset => reset,
			din1  => touart1,
			ack1  => uart_ack1,
			din2  => touart2,
			ack2  => uart_ack2,
			dout  => touart
		);
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
	
	mem_res_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we3 <= '0';
		elsif rising_edge(Clock) then
			if memres(50 downto 50) = "1" then
				in3 <= memres;
				we3 <= '1';
			else
				we3 <= '0';
			end if;

		end if;
	end process;

	gfx_res_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we8 <= '0';
		elsif rising_edge(Clock) then
			if gfxres(50 downto 50) = "1" then
				in8 <= gfxres;
				we8 <= '1';
			else
				we8 <= '0';
			end if;

		end if;
	end process;
	audio_res_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we8 <= '0';
		elsif rising_edge(Clock) then
			if audiores(50 downto 50) = "1" then
				in8 <= audiores;
				we8 <= '1';
			else
				we8 <= '0';
			end if;

		end if;
	end process;
	usb_res_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we8 <= '0';
		elsif rising_edge(Clock) then
			if usbres(50 downto 50) = "1" then
				in8 <= usbres;
				we8 <= '1';
			else
				we8 <= '0';
			end if;

		end if;
	end process;
	uart_res_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we8 <= '0';
		elsif rising_edge(Clock) then
			if uartres(50 downto 50) = "1" then
				in8 <= uartres;
				we8 <= '1';
			else
				we8 <= '0';
			end if;

		end if;
	end process;
	
	wb_req1_fifo : process(reset, Clock)
	begin
		if reset = '1' then
			we6 <= '0';
		elsif rising_edge(Clock) then
			if (wb_req1(50 downto 50) = "1") then
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
			if (wb_req2(50 downto 50) = "1") then
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
					gfxpoweron <= '0';
				elsif pwrres(3 downto 2) = "10" then
					gfxpoweron <= '1';
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

	---mem_res process
	mem_res_p : process(reset, Clock)
		variable stage  : integer                       := 0;
		variable cpu1   : std_logic;
	begin
		if reset = '1' then
			bus_res1_1 <= (others => '0');
			bus_res2_2 <= (others => '0');
			gfx_upres3 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re3 = '0' and emp3 = '0' then
					re3   <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re3 <= '0';
				if out3(50 downto 50) = "1" then
					---response for cpu1
					if out3(53 downto 51) = "000" then
						reg_1      <= out3(50 downto 0);
						bus_res1_1 <= out3(50 downto 0);
						cpu1       := '1';
						stage      := 2;
					---response for cpu2
					elsif out3(53 downto 51) = "101" then
						reg_2      <= out3(50 downto 0);
						bus_res2_2 <= out3(50 downto 0);
						cpu1       := '0';
						stage      := 2;
					elsif out3(53 downto 51) = "001" then
						gfx_upres3 <= out3(50 downto 0);
						stage      := 3;
					end if;

				end if;
			elsif stage = 2 then
				if cpu1 = '1' and brs1_ack1 = '1' then
					bus_res1_1 <= (others => '0');
					stage      := 0;
				elsif cpu1 = '0' and brs2_ack2 = '1' then
					bus_res2_2 <= (others => '0');
					stage      := 0;
				end if;
			elsif stage = 3 then
				if gfx_upres_ack3 = '1' then
					gfx_upres3 <= (others => '0');
					stage      := 0;
				end if;
			end if;
		end if;

	end process;

	gfx_res_p : process(reset, Clock)

		variable stage  : integer                       := 0;
		variable cpu1   : std_logic;
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
						stage := 2;
					elsif out8(53 downto 51) ="001" then
						gfx_upres3 <= out8(50 downto 0);
						stage := 3;
					elsif out8(53 downto 51) ="010" then
						uart_upres3 <= out8(50 downto 0);
						stage := 4;
					elsif out8(53 downto 51) ="011" then
						usb_upres3 <= out8(50 downto 0);
						stage := 5;
					elsif out8(53 downto 51) ="100" then
						audio_upres3 <= out8(50 downto 0);
						stage := 6;
					---response for cpu2
					elsif out8(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_3 <= out8(50 downto 0);
						cpu1       := '0';
						stage := 2;
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
			elsif stage =3 then
				if gfx_upres_ack3 ='1' then
					gfx_upres3 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =4 then
				if uart_upres_ack3 ='1' then
					uart_upres3 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =5 then
				if usb_upres_ack3 ='1' then
					usb_upres3 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =6 then
				if audio_upres_ack3 ='1' then
					usb_upres3 <= (others => '0');
					stage :=0;
				end if;
			end if;
		end if;

	end process;
	audio_res_p : process(reset, Clock)

		variable stage  : integer                       := 0;
		variable cpu1   : std_logic;
	begin
		if reset = '1' then
			bus_res1_4 <= (others => '0');
			bus_res2_4 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re10 = '0' and emp10 = '0' then
					re10   <= '1';
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
						stage := 2;
					elsif out10(53 downto 51) ="001" then
						gfx_upres4 <= out10(50 downto 0);
						stage := 3;
					elsif out10(53 downto 51) ="010" then
						uart_upres4 <= out10(50 downto 0);
						stage := 4;
					elsif out10(53 downto 51) ="011" then
						usb_upres4 <= out10(50 downto 0);
						stage := 5;
					
					---response for cpu2
					elsif out10(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_4 <= out10(50 downto 0);
						cpu1       := '0';
						stage := 2;
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
			elsif stage =3 then
				if gfx_upres_ack4 ='1' then
					gfx_upres4 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =4 then
				if uart_upres_ack4 ='1' then
					uart_upres4 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =5 then
				if usb_upres_ack4 ='1' then
					usb_upres4 <= (others => '0');
					stage :=0;
				end if;
			
			end if;
		end if;

	end process;
	usb_res_p : process(reset, Clock)

		variable stage  : integer                       := 0;
		variable cpu1   : std_logic;
	begin
		if reset = '1' then
			bus_res1_5 <= (others => '0');
			bus_res2_5 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re11 = '0' and emp11 = '0' then
					re11   <= '1';
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
						stage := 2;
					elsif out11(53 downto 51) ="001" then
						gfx_upres5 <= out11(50 downto 0);
						stage := 3;
					elsif out11(53 downto 51) ="010" then
						uart_upres5 <= out11(50 downto 0);
						stage := 4;
					elsif out11(53 downto 51) ="100" then
						audio_upres5 <= out11(50 downto 0);
						stage := 6;
					---response for cpu2
					elsif out11(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_5 <= out11(50 downto 0);
						cpu1       := '0';
						stage := 2;
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
			elsif stage =3 then
				if gfx_upres_ack5 ='1' then
					gfx_upres5 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =4 then
				if uart_upres_ack5 ='1' then
					uart_upres5 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =6 then
				if audio_upres_ack5 ='1' then
					usb_upres5 <= (others => '0');
					stage :=0;
				end if;
			end if;
		end if;

	end process;
	
	uart_res_p : process(reset, Clock)

		variable stage  : integer                       := 0;
		variable cpu1   : std_logic;
	begin
		if reset = '1' then
			bus_res1_6 <= (others => '0');
			bus_res2_6 <= (others => '0');
		elsif rising_edge(Clock) then
			if stage = 0 then
				if re11 = '0' and emp11 = '0' then
					re11   <= '1';
					stage := 1;
				end if;
			elsif stage = 1 then
				re11 <= '0';
				if out11(50 downto 50) = "1" then
					
					---response for cpu1
					if out11(53 downto 51) = "000" then
						---reg_1 <= out11(50 downto 0);
						bus_res1_6 <= out11(50 downto 0);
						cpu1       := '1';
						stage := 2;
					elsif out11(53 downto 51) ="001" then
						gfx_upres6 <= out11(50 downto 0);
						stage := 3;
					
					elsif out11(53 downto 51) ="011" then
						usb_upres6 <= out11(50 downto 0);
						stage := 5;
					elsif out11(53 downto 51) ="100" then
						audio_upres6 <= out11(50 downto 0);
						stage := 6;
					---response for cpu2
					elsif out11(53 downto 51) = "101" then
						---reg_2 <= out3(50 downto 0);
						bus_res2_6 <= out11(50 downto 0);
						cpu1       := '0';
						stage := 2;
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
			elsif stage =3 then
				if gfx_upres_ack6 ='1' then
					gfx_upres6 <= (others => '0');
					stage :=0;
				end if;
			
			elsif stage =5 then
				if usb_upres_ack6 ='1' then
					usb_upres6 <= (others => '0');
					stage :=0;
				end if;
			elsif stage =6 then
				if audio_upres_ack6 ='1' then
					usb_upres6 <= (others => '0');
					stage :=0;
				end if;
			end if;
		end if;

	end process;
	---deal with cache request
	cache_req1_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable state  : integer                       := 0;
		variable count  : integer                       := 0;
	begin
		if reset = '1' then
			---snoop_req2 <= "000"&nilreq;
			pwr_req1 <= "00000";
		elsif rising_edge(Clock) then
			if state = 0 then
				if cache_req1(50 downto 50) = "1" and cache_req1(47 downto 32) = adr_1 then
					state   := 1;
					tmp_sp2 <= cache_req1;
				elsif cache_req1(50 downto 50) = "1" and cache_req1(49 downto 48) = "11" then
					pwr_req1 <= cache_req1(50 downto 46);
					state    := 4;
				elsif cache_req1(50 downto 50) = "1" and full_srq1 /= '1' then
					snp2_1 <= "000" & cache_req1;
					adr_0  <= cache_req1(47 downto 32);
					state  := 5;
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
				snp2_1 <= "000" & tmp_sp2;
				adr_0  <= tmp_sp2(47 downto 32);
				state  := 5;
			elsif state = 4 then
				if pwr_ack1 = '1' then
					pwr_req1 <= "00000";
					state    := 0;
				end if;
			elsif state = 5 then
				if snp2_ack1 = '1' then
					snp2_1 <= "000" & nilreq;
					state  := 0;
				end if;
			end if;
		end if;
	end process;

	---deal with cache request
	cache_req2_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable state  : integer                       := 0;
		variable count  : integer                       := 0;
	begin
		if reset = '1' then
			---snoop_req1 <= "000"&nilreq;
			pwr_req2 <= "00000";
		elsif rising_edge(Clock) then
			if state = 0 then
				if cache_req2(50 downto 50) = "1" and cache_req2(47 downto 32) = adr_0 then
					state   := 1;
					tmp_sp1 <= cache_req2;
				elsif cache_req2(50 downto 50) = "1" and cache_req2(49 downto 48) = "11" then
					pwr_req2 <= cache_req2(50 downto 46);
					state    := 4;
				elsif cache_req2(50 downto 50) = "1" and full_srq2 /= '1' then
					snp1_1 <= "101" & cache_req2;
					adr_1  <= cache_req2(47 downto 32);
					state  := 5;

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
				snp1_1 <= "101" & tmp_sp1;
				adr_1  <= tmp_sp1(47 downto 32);
				state  := 5;
			elsif state = 4 then
				if pwr_ack2 = '1' then
					pwr_req2 <= "00000";
					state    := 0;
				end if;
			elsif state = 5 then
				if snp1_ack1 = '1' then
					snp1_1 <= "000" & nilreq;
					state  := 0;
				end if;
			end if;

		end if;
	end process;

	snp_res1_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable state  : integer                       := 0;
	begin
		if reset = '1' then
			re2        <= '0';
			bus_res2_1 <= (others => '0');
			tomem1     <= "000" & nilreq;
			togfx1     <= "000" & nilreq;
			toaudio1     <= "000" & nilreq;
			tousb1     <= "000" & nilreq;
			touart1     <= "000" & nilreq;
			gfx_upres1 <= (others => '0');
			audio_upres1 <= (others => '0');
			usb_upres1 <= (others => '0');
			uart_upres1 <= (others => '0');
			pwr_req3   <= "00000";
		---tmp_brs2_1 <= (others => '0');
		---tmp_mem1 <= (others => '0');
		elsif rising_edge(Clock) then
			if state = 0 then
				if re2 = '0' and emp2 = '0' then
					re2   <= '1';
					state := 1;
				end if;

			elsif state = 1 then
				re2 <= '0';
				if out2(50 downto 50) = "1" then
					if out2(54 downto 54) = "1" then --it;s a hit
						if out2(53 downto 51) = "000" then
							bus_res2_1 <= out2(50 downto 0);
							state      := 2;
						elsif out2(53 downto 51) = "001" or out2(53 downto 51) = "010" or out2(53 downto 51) = "011" or out2(53 downto 51) = "100" then
							if out2(49 downto 48) = "01" then
								if out2(47 downto 45)="001" then
									gfx_upres1 <= out2(50 downto 0);
									state      := 7;
								elsif out2(47 downto 45)="010" then
									audio_upres1 <= out2(50 downto 0);
									state      := 17;
								elsif out2(47 downto 45)="011" then
									usb_upres1 <= out2(50 downto 0);
									state      := 18;
								elsif out2(47 downto 45)="100" then
									uart_upres1 <= out2(50 downto 0);
									state      := 19;	
								else
									tomem1 <= out2(53 downto 0);
									state  := 3;
								end if; 
								
							else
								if out2(47 downto 45)="001" then
									togfx1 <= out2(53 downto 0);
									state  := 4;
								elsif out2(47 downto 45)="010" then
									toaudio1 <= out2(53 downto 0);
									state  := 8;
								elsif out2(47 downto 45)="011" then
									tousb1 <= out2(53 downto 0);
									state  := 9;
								elsif out2(47 downto 45)="100" then
									touart1 <= out2(53 downto 0);
									state  := 10;	
								else
									tomem1 <= out2(53 downto 0);
									state  := 3;
								end if;
							end if;

						end if;
					else                ---it's a miss
						if out2(53 downto 51) = "001" or out2(53 downto 51) = "010" or out2(53 downto 51) = "011" or out2(53 downto 51) = "100" then
							snp2_2 <= out2(53 downto 0);
							state  := 8;
						elsif out2(47 downto 45)="001" then
							if gfxpoweron = '1' then
								state  := 4;
								togfx1 <=  out2(53 downto 0);
							else
								state      := 5;
								tmp_togfx1 <=  out2(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						elsif out2(47 downto 45)="010" then
							if audiopoweron = '1' then
								state  := 8;
								toaudio1 <=  out2(53 downto 0);
							else
								state      := 11;
								tmp_toaudio1 <=  out2(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						elsif out2(47 downto 45)="011" then
							if usbpoweron = '1' then
								state  := 9;
								tousb1 <=  out2(53 downto 0);
							else
								state      := 12;
								tmp_tousb1 <=  out2(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						elsif out2(47 downto 45)="100" then
							if uartpoweron = '1' then
								state  := 10;
								touart1 <=  out2(53 downto 0);
							else
								state      := 13;
								tmp_touart1 <=  out2(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						else
							state  := 3;
							tomem1 <= out2(53 downto 0);
						end if;
					end if;
				end if;

			elsif state = 2 then
				if brs2_ack1 = '1' then
					bus_res2_1 <= (others => '0');
					state      := 0;
				end if;

			elsif state = 3 then
				if mem_ack1 = '1' then
					tomem1 <= "000" & nilreq;
					state  := 0;
				end if;
			elsif state = 4 then
				if gfx_ack1 = '1' then
					togfx1 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 8 then
				if audio_ack1 = '1' then
					toaudio1 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 9 then
				if usb_ack1 = '1' then
					tousb1 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 10 then
				if uart_ack1 = '1' then
					touart1 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 5 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 6;
				end if;
			elsif state = 11 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 14;
				end if;
			elsif state = 12 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 15;
				end if;
			elsif state = 13 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 16;
				end if;
			elsif state = 6 then
				if pwrres(4 downto 4) = "1" then
					togfx1 <= tmp_togfx1;
					state  := 4;
				end if;
			elsif state = 14 then
				if pwrres(4 downto 4) = "1" then
					toaudio1 <= tmp_toaudio1;
					state  := 4;
				end if;
			elsif state = 15 then
				if pwrres(4 downto 4) = "1" then
					tousb1 <= tmp_tousb1;
					state  := 4;
				end if;
			elsif state = 16 then
				if pwrres(4 downto 4) = "1" then
					touart1 <= tmp_touart1;
					state  := 4;
				end if;
			elsif state = 7 then
				if gfx_upres_ack1 = '1' then
					gfx_upres1 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 17 then
				if audio_upres_ack1 = '1' then
					audio_upres1 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 18 then
				if usb_upres_ack1 = '1' then
					usb_upres1 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 19 then
				if uart_upres_ack1 = '1' then
					uart_upres1 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 8 then
				if snp2_ack2 = '1' then
					state  := 0;
					snp2_2 <= (others => '0');
				end if;
			end if;

		end if;
	end process;

	snp_res2_p : process(reset, Clock)
		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
		variable state  : integer                       := 0;
	begin
		if reset = '1' then
			re5        <= '0';
			bus_res1_2 <= (others => '0');
			tomem2     <= (others => '0');
			--tmp_brs1_2 <= (others => '0');
			--tmp_mem2 <= (others => '0');
			gfx_upres2 <= (others => '0');
			audio_upres2 <= (others => '0');
			usb_upres2 <= (others => '0');
			uart_upres2 <= (others => '0');
			state      := 0;
		elsif rising_edge(Clock) then
			if state = 0 then
				if re5 = '0' and emp5 = '0' then
					re5   <= '1';
					state := 1;
				end if;
			elsif state = 1 then
				re5 <= '0';
				if out5(50 downto 50) = "1" then
					if out5(54 downto 54) = "1" then --it;s a hit
						if out5(53 downto 51) = "000" then
							bus_res1_2 <= out5(50 downto 0);
							state      := 2;
						elsif out5(53 downto 51) = "001" or out5(53 downto 51) = "010" or out5(53 downto 51) = "011" or out5(53 downto 51) = "100" then
							if out5(49 downto 48) = "01" then
								if out5(47 downto 45)="001" then
									gfx_upres2 <= out5(50 downto 0);
									state      := 7;
								elsif out5(47 downto 45)="010" then
									audio_upres2 <= out5(50 downto 0);
									state      := 17;
								elsif out5(47 downto 45)="011" then
									usb_upres2 <= out5(50 downto 0);
									state      := 18;
								elsif out5(47 downto 45)="100" then
									uart_upres2 <= out5(50 downto 0);
									state      := 19;	
								else
									tomem2 <= out5(53 downto 0);
									state  := 3;
								end if; 
								
							else
								if out5(47 downto 45)="001" then
									togfx2 <= out5(53 downto 0);
									state  := 4;
								elsif out5(47 downto 45)="010" then
									toaudio2 <= out5(53 downto 0);
									state  := 8;
								elsif out5(47 downto 45)="011" then
									tousb2 <= out5(53 downto 0);
									state  := 9;
								elsif out5(47 downto 45)="100" then
									touart2 <= out5(53 downto 0);
									state  := 10;	
								else
									tomem2 <= out5(53 downto 0);
									state  := 3;
								end if;
							end if;

						end if;
					else                ---it's a miss
						if out2(47 downto 45)="001" then
							if gfxpoweron = '1' then
								state  := 4;
								togfx2 <=  out5(53 downto 0);
							else
								state      := 5;
								tmp_togfx2 <=  out5(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						elsif out2(47 downto 45)="010" then
							if audiopoweron = '1' then
								state  := 8;
								toaudio2 <=  out5(53 downto 0);
							else
								state      := 11;
								tmp_toaudio2 <=  out5(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						elsif out2(47 downto 45)="011" then
							if usbpoweron = '1' then
								state  := 9;
								tousb2 <=  out5(53 downto 0);
							else
								state      := 12;
								tmp_tousb2 <=  out5(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						elsif out2(47 downto 45)="100" then
							if uartpoweron = '1' then
								state  := 10;
								touart2 <=  out5(53 downto 0);
							else
								state      := 13;
								tmp_touart2 <=  out5(53 downto 0);
								pwr_req3   <= "11000";
							end if;
						else
							state  := 3;
							tomem2 <= out2(53 downto 0);
						end if;
						
					end if;
				end if;

			elsif state = 2 then
				if brs1_ack2 = '1' then
					bus_res1_2 <= (others => '0');
					state      := 0;
				end if;

			elsif state = 3 then
				if mem_ack2 = '1' then
					tomem2 <= "000" & nilreq;
					state  := 0;
				end if;
			elsif state = 4 then
				if gfx_ack2 = '1' then
					togfx2 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 5 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 6;
				end if;
			elsif state = 6 then
				if pwrres(4 downto 4) = "1" then
					togfx2 <= tmp_togfx2;
					state  := 4;
				end if;
			elsif state = 7 then
				if gfx_upres_ack2 = '1' then
					gfx_upres2 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 8 then
				if audio_ack2 = '1' then
					toaudio2 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 9 then
				if usb_ack2 = '1' then
					tousb2 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 10 then
				if uart_ack2 = '1' then
					touart2 <= (others => '0');
					state  := 0;
				end if;
			elsif state = 11 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 14;
				end if;
			elsif state = 12 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 15;
				end if;
			elsif state = 13 then
				if pwr_ack3 = '1' then
					pwr_req3 <= "00000";
					state    := 16;
				end if;
			elsif state = 14 then
				if pwrres(4 downto 4) = "1" then
					toaudio2 <= tmp_toaudio2;
					state  := 4;
				end if;
			elsif state = 15 then
				if pwrres(4 downto 4) = "1" then
					tousb2 <= tmp_tousb2;
					state  := 4;
				end if;
			elsif state = 16 then
				if pwrres(4 downto 4) = "1" then
					touart2 <= tmp_touart2;
					state  := 4;
				end if;
			
			elsif state = 17 then
				if audio_upres_ack2 = '1' then
					audio_upres2 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 18 then
				if usb_upres_ack2 = '1' then
					usb_upres2 <= (others => '0');
					state      := 0;
				end if;
			elsif state = 19 then
				if uart_upres_ack2 = '1' then
					uart_upres2 <= (others => '0');
					state      := 0;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
