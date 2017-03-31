library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity axi is
  Port(
    Clock                                   : in  std_logic;
    reset                                   : in  std_logic;
    cache_req1                              : in  STD_LOGIC_VECTOR(72 downto 0);
    cache_req2                              : in  STD_LOGIC_VECTOR(72 downto 0);
    wb_req1, wb_req2                        : in  std_logic_vector(552 downto 0);
    bus_res1                                : out STD_LOGIC_VECTOR(552 downto 0);
    bus_res2                                : out STD_LOGIC_VECTOR(552 downto 0);
    snp_req1                              : out STD_LOGIC_VECTOR(75 downto 0);
    snp_res1                              : in  STD_LOGIC_VECTOR(75 downto 0);
    snp_hit1                                : in  std_logic;
    full_srq1                               : in  std_logic;
    full_wb1, full_srs1, full_wb2, full_mrs : out std_logic;
    pwrreq                                  : out std_logic_vector(4 downto 0);
    pwrreq_full                             : in  std_logic;
    pwrres                                  : in  std_logic_vector(4 downto 0);

    --add 3 bits in snoop request to indicate the source
    --000 cpu0
    --001 gfx
    --010 uart
    --011 usb
    --100 audio
    --101 cpu1


    gfx_upreq                               : in  std_logic_vector(72 downto 0);
    gfx_upres                               : out std_logic_vector(72 downto 0);
    gfx_upreq_full                          : out std_logic;
    audio_upreq                             : in  std_logic_vector(72 downto 0);
    audio_upres                             : out std_logic_vector(72 downto 0);
    audio_upreq_full                        : out std_logic;
    usb_upreq                               : in  std_logic_vector(72 downto 0);
    usb_upres                               : out std_logic_vector(72 downto 0);
    usb_upreq_full                          : out std_logic;
    uart_upreq                              : in  std_logic_vector(72 downto 0);
    uart_upres                              : out std_logic_vector(72 downto 0);
    uart_upreq_full                         : out std_logic;

    ---write address channel
    waddr                                   : out std_logic_vector(31 downto 0);
    wlen                                    : out std_logic_vector(9 downto 0);
    wsize                                   : out std_logic_vector(9 downto 0);
    wvalid                                  : out std_logic;
    wready                                  : in  std_logic;
    ---write data channel
    wdata                                   : out std_logic_vector(31 downto 0);
    wtrb                                    : out std_logic_vector(3 downto 0);
    wlast                                   : out std_logic;
    wdvalid                                 : out std_logic;
    wdataready                              : in  std_logic;
    ---write response channel
    wrready                                 : out std_logic;
    wrvalid                                 : in  std_logic;
    wrsp                                    : in  std_logic_vector(1 downto 0);

    ---read address channel
    raddr                                   : out std_logic_vector(31 downto 0);
    rlen                                    : out std_logic_vector(9 downto 0);
    rsize                                   : out std_logic_vector(9 downto 0);
    rvalid                                  : out std_logic;
    rready                                  : in  std_logic;
    ---read data channel
    rdata                                   : in  std_logic_vector(31 downto 0);
    rstrb                                   : in  std_logic_vector(3 downto 0);
    rlast                                   : in  std_logic;
    rdvalid                                 : in  std_logic;
    rdready                                 : out std_logic;
    rres                                    : in  std_logic_vector(1 downto 0);

    ---usb write address channel
    waddr_usb                               : out std_logic_vector(31 downto 0);
    wlen_usb                                : out std_logic_vector(9 downto 0);
    wsize_usb                               : out std_logic_vector(9 downto 0);
    wvalid_usb                              : out std_logic;
    wready_usb                              : in  std_logic;
    --_usb-write data channel
    wdata_usb                               : out std_logic_vector(31 downto 0);
    wtrb_usb                                : out std_logic_vector(3 downto 0);
    wlast_usb                               : out std_logic;
    wdvalid_usb                             : out std_logic;
    wdataready_usb                          : in  std_logic;
    --_usb-write response channel
    wrready_usb                             : out std_logic;
    wrvalid_usb                             : in  std_logic;
    wrsp_usb                                : in  std_logic_vector(1 downto 0);

    --_usb-read address channel
    raddr_usb                               : out std_logic_vector(31 downto 0);
    rlen_usb                                : out std_logic_vector(9 downto 0);
    rsize_usb                               : out std_logic_vector(9 downto 0);
    rvalid_usb                              : out std_logic;
    rready_usb                              : in  std_logic;
    --_usb-read data channel
    rdata_usb                               : in  std_logic_vector(31 downto 0);
    rstrb_usb                               : in  std_logic_vector(3 downto 0);
    rlast_usb                               : in  std_logic;
    rdvalid_usb                             : in  std_logic;
    rdready_usb                             : out std_logic;
    rres_usb                                : in  std_logic_vector(1 downto 0);

    ---gfx write address channel
    waddr_gfx                               : out std_logic_vector(31 downto 0);
    wlen_gfx                                : out std_logic_vector(9 downto 0);
    wsize_gfx                               : out std_logic_vector(9 downto 0);
    wvalid_gfx                              : out std_logic;
    wready_gfx                              : in  std_logic;
    --_gfx-write data channel
    wdata_gfx                               : out std_logic_vector(31 downto 0);
    wtrb_gfx                                : out std_logic_vector(3 downto 0);
    wlast_gfx                               : out std_logic;
    wdvalid_gfx                             : out std_logic;
    wdataready_gfx                          : in  std_logic;
    --_gfx-write response channel
    wrready_gfx                             : out std_logic;
    wrvalid_gfx                             : in  std_logic;
    wrsp_gfx                                : in  std_logic_vector(1 downto 0);

    --_gfx-read address channel
    raddr_gfx                               : out std_logic_vector(31 downto 0);
    rlen_gfx                                : out std_logic_vector(9 downto 0);
    rsize_gfx                               : out std_logic_vector(9 downto 0);
    rvalid_gfx                              : out std_logic;
    rready_gfx                              : in  std_logic;
    --_gfx-read data channel
    rdata_gfx                               : in  std_logic_vector(31 downto 0);
    rstrb_gfx                               : in  std_logic_vector(3 downto 0);
    rlast_gfx                               : in  std_logic;
    rdvalid_gfx                             : in  std_logic;
    rdready_gfx                             : out std_logic;
    rres_gfx                                : in  std_logic_vector(1 downto 0);

    ---uart write address channel
    waddr_uart                              : out std_logic_vector(31 downto 0);
    wlen_uart                               : out std_logic_vector(9 downto 0);
    wsize_uart                              : out std_logic_vector(9 downto 0);
    wvalid_uart                             : out std_logic;
    wready_uart                             : in  std_logic;
    --_uart-write data channel
    wdata_uart                              : out std_logic_vector(31 downto 0);
    wtrb_uart                               : out std_logic_vector(3 downto 0);
    wlast_uart                              : out std_logic;
    wdvalid_uart                            : out std_logic;
    wdataready_uart                         : in  std_logic;
    --_uart-write response channel
    wrready_uart                            : out std_logic;
    wrvalid_uart                            : in  std_logic;
    wrsp_uart                               : in  std_logic_vector(1 downto 0);

    --_uart-read address channel
    raddr_uart                              : out std_logic_vector(31 downto 0);
    rlen_uart                               : out std_logic_vector(9 downto 0);
    rsize_uart                              : out std_logic_vector(9 downto 0);
    rvalid_uart                             : out std_logic;
    rready_uart                             : in  std_logic;
    --_uart-read data channel
    rdata_uart                              : in  std_logic_vector(31 downto 0);
    rstrb_uart                              : in  std_logic_vector(3 downto 0);
    rlast_uart                              : in  std_logic;
    rdvalid_uart                            : in  std_logic;
    rdready_uart                            : out std_logic;
    rres_uart                               : in  std_logic_vector(1 downto 0);

    ---audio write address channel
    waddr_audio                             : out std_logic_vector(31 downto 0);
    wlen_audio                              : out std_logic_vector(9 downto 0);
    wsize_audio                             : out std_logic_vector(9 downto 0);
    wvalid_audio                            : out std_logic;
    wready_audio                            : in  std_logic;
    --_audio-write data channel
    wdata_audio                             : out std_logic_vector(31 downto 0);
    wtrb_audio                              : out std_logic_vector(3 downto 0);
    wlast_audio                             : out std_logic;
    wdvalid_audio                           : out std_logic;
    wdataready_audio                        : in  std_logic;
    --_audio-write response channel
    wrready_audio                           : out std_logic;
    wrvalid_audio                           : in  std_logic;
    wrsp_audio                              : in  std_logic_vector(1 downto 0);

    --_audio-read address channel
    raddr_audio                             : out std_logic_vector(31 downto 0);
    rlen_audio                              : out std_logic_vector(9 downto 0);
    rsize_audio                             : out std_logic_vector(9 downto 0);
    rvalid_audio                            : out std_logic;
    rready_audio                            : in  std_logic;
    --_audio-read data channel
    rdata_audio                             : in  std_logic_vector(31 downto 0);
    rstrb_audio                             : in  std_logic_vector(3 downto 0);
    rlast_audio                             : in  std_logic;
    rdvalid_audio                           : in  std_logic;
    rdready_audio                           : out std_logic;
    rres_audio                              : in  std_logic_vector(1 downto 0)
	);
end axi;

architecture Behavioral of axi is
  --fifo has 53 bits
  --3 bits for indicating its source¡
  --50 bits for packet

  signal in6, in7, out6, out7 : std_logic_vector(552 downto 0);

  signal in2, out2                    : std_logic_vector(76 downto 0);
  signal we2, we6, we7, re7, re2, re6 : std_logic := '0';
  signal emp2, emp6, emp7, ful2       : std_logic := '0';

  signal bus_res1_1, bus_res1_2, bus_res2_1, bus_res2_2                 : std_logic_vector(552 downto 0);
  signal mem_ack1, mem_ack2, brs1_ack1, brs1_ack2, brs2_ack1, brs2_ack2 : std_logic;
  signal mem_ack, mem_ack3, mem_ack4, mem_ack5, mem_ack6                : std_logic;

  signal tomem1, tomem2, tomem3, tomem4, tomem5, tomem6 : std_logic_vector(75 downto 0) := (others => '0');

  signal wb_ack1, wb_ack2 : std_logic;
  signal mem_wb1, mem_wb2 : std_logic_vector(552 downto 0) := (others => '0');
  --state information of power
  signal gfxpoweron       : std_logic                      := '0';

  signal adr_0, adr_1                                   : std_logic_vector(31 downto 0);
  signal tmp_sp1, tmp_sp2                               : std_logic_vector(72 downto 0);
  signal pwr_req1, pwr_req2                             : std_logic_vector(4 downto 0);
  signal pwr_ack1, pwr_ack2                             : std_logic;
  signal mem_wb, gfx_wb, audio_wb, usb_wb, uart_wb      : std_logic_vector(552 downto 0);
  signal tomem_p, togfx_p, touart_p, tousb_p, toaudio_p : std_logic_vector(75 downto 0);

  signal in9, out9, in13, out13, in14, out14, in15, out15                                           : std_logic_vector(72 downto 0);
  signal in8, out8, in10, out10, in11, out11, in12, out12                                           : std_logic_vector(75 downto 0);
  signal we8, re8, re9, we9, re10, we10, re11, we11, re12, we12, re13, we13, re14, we14, re15, we15 : std_logic := '0';
  signal emp8, emp9, emp10, emp11, emp12, emp13, emp14, emp15                                       : std_logic := '0';

  signal bus_res1_3, bus_res2_3, bus_res1_4, bus_res1_5, bus_res1_7, bus_res2_4, bus_res2_5, bus_res1_6, bus_res2_6 : std_logic_vector(552 downto 0);

  signal gfx_ack1, gfx_ack2, audio_ack1, audio_ack2, usb_ack1, usb_ack2, uart_ack1                                    : std_logic;
  signal gfx_ack3, gfx_ack4, gfx_ack5, gfx_ack6,gfx_ack,usb_ack,uart_ack,audio_ack                                    : std_logic;
  signal uart_ack3, uart_ack4, uart_ack5, uart_ack6                                                                   : std_logic;
  signal usb_ack3, usb_ack4, usb_ack5, usb_ack6                                                                       : std_logic;
  signal audio_ack3, audio_ack4, audio_ack5, audio_ack6                                                               : std_logic;
  signal uart_ack2, brs1_ack3, brs2_ack3, brs1_ack4, brs1_ack5, brs1_ack6, brs1_ack7, brs2_ack5, brs2_ack4, brs2_ack6 : std_logic;
  signal togfx1, togfx2, togfx3, togfx4, togfx5, togfx6                                                               : std_logic_vector(75 downto 0) := (others => '0');
  signal toaudio1, toaudio2, toaudio3, toaudio4, toaudio5, toaudio6                                                   : std_logic_vector(75 downto 0) := (others => '0');
  signal tousb1, tousb2, tousb3, tousb4, tousb5, tousb6                                                               : std_logic_vector(75 downto 0) := (others => '0');
  signal touart1, touart2, touart3, touart4, touart5, touart6                                                         : std_logic_vector(75 downto 0) := (others => '0');

  signal gfx_wb_ack1, gfx_wb_ack2, audio_wb_ack1, audio_wb_ack2, usb_wb_ack1, usb_wb_ack2, uart_wb_ack1, uart_wb_ack2 : std_logic;
  signal gfx_wb1, gfx_wb2, audio_wb1, audio_wb2, usb_wb1, usb_wb2, uart_wb1, uart_wb2                                 : std_logic_vector(552 downto 0) := (others => '0');
  --state information of power
  signal audiopoweron                                                                                                 : std_logic                      := '0';
  signal usbpoweron                                                                                                   : std_logic                      := '0';
  signal uartpoweron                                                                                                  : std_logic                      := '0';

  signal pwr_req3, pwr_req4, pwr_req5, pwr_req6 : std_logic_vector(4 downto 0);
  signal pwr_ack3, pwr_ack4, pwr_ack5, pwr_ack6 : std_logic;

  signal snp1_1, snp1_2, snp1_3, snp1_4, snp1_5, snp1_6, snp2_1, snp2_2, snp2_3, snp2_4, snp2_5, snp2_6                                     : std_logic_vector(75 downto 0);
  signal snp1_ack1, snp1_ack2, snp1_ack3, snp1_ack4, snp1_ack5, snp1_ack6, snp2_ack1, snp2_ack2, snp2_ack3, snp2_ack4, snp2_ack5, snp2_ack6 : std_logic;

  signal gfx_upres1, gfx_upres2, gfx_upres3                   : std_logic_vector(72 downto 0);
  signal gfx_upres_ack1, gfx_upres_ack2, gfx_upres_ack3       : std_logic;
  signal audio_upres1, audio_upres2, audio_upres3             : std_logic_vector(72 downto 0);
  signal audio_upres_ack1, audio_upres_ack2, audio_upres_ack3 : std_logic;
  signal usb_upres1, usb_upres2, usb_upres3                   : std_logic_vector(72 downto 0);
  signal usb_upres_ack1, usb_upres_ack2, usb_upres_ack3       : std_logic;
  signal uart_upres1, uart_upres2, uart_upres3                : std_logic_vector(72 downto 0);
  signal uart_upres_ack1, uart_upres_ack2, uart_upres_ack3    : std_logic;
  signal gfx_upres4, gfx_upres5, gfx_upres6                   : std_logic_vector(72 downto 0);
  signal gfx_upres_ack4, gfx_upres_ack5, gfx_upres_ack6       : std_logic;
  signal audio_upres4, audio_upres5, audio_upres6             : std_logic_vector(72 downto 0);
  signal audio_upres_ack4, audio_upres_ack5, audio_upres_ack6 : std_logic;
  signal usb_upres4, usb_upres5, usb_upres6                   : std_logic_vector(72 downto 0);
  signal usb_upres_ack4, usb_upres_ack5, usb_upres_ack6       : std_logic;
  signal uart_upres4, uart_upres5, uart_upres6                : std_logic_vector(72 downto 0);
  signal uart_upres_ack4, uart_upres_ack5, uart_upres_ack6    : std_logic;
  
  signal gfx_write1,mem_write1,usb_write1,uart_write1,audio_write1:std_logic_vector(75 downto 0);
  signal mem_write2,mem_write3,gfx_write2,gfx_write3,usb_write2,usb_write3,uart_write2,uart_write3,audio_write2,audio_write3:std_logic_vector(552 downto 0);
  signal mem_write_ack1,gfx_write_ack1,usb_write_ack1,uart_write_ack1,audio_write_ack1: std_logic;
  signal mem_write_ack2,gfx_write_ack2,usb_write_ack2,uart_write_ack2,audio_write_ack2: std_logic;
  signal mem_write_ack3,gfx_write_ack3,usb_write_ack3,uart_write_ack3,audio_write_ack3: std_logic;

	signal tmp_cache_req1, tmp_cache_req2: std_logic_vector(72 downto 0);
begin
  wb_fif1 : entity work.fifo(Behavioral)
    generic map(
      DATA_WIDTH => 553
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => in6,
      WriteEn => we6,
      ReadEn  => re6,
      DataOut => out6,
      Full    => full_wb1,
      Empty   => emp6
      );
  wb_fif2 : entity work.fifo(Behavioral)
    generic map(
      DATA_WIDTH => 553
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => in7,
      WriteEn => we7,
      ReadEn  => re7,
      DataOut => out7,
      Full    => full_wb2,
      Empty   => emp7
      );

  gfx_fif : entity work.fifo(Behavioral) port map(
    CLK     => Clock,
    RST     => reset,
    DataIn  => in9,
    WriteEn => we9,
    ReadEn  => re9,
    DataOut => out9,
    Full    => gfx_upreq_full,
    Empty   => emp9
    );
  snp_res_fifo : entity work.fifo(Behavioral)
    generic map(
      DATA_WIDTH => 77
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => in2,
      WriteEn => we2,
      ReadEn  => re2,
      DataOut => out2,
      Full    => ful2,
      Empty   => emp2
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
  audio_fif : entity work.fifo(Behavioral) port map(
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
  usb_fif : entity work.fifo(Behavioral) port map(
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
  uart_fif : entity work.fifo(Behavioral) port map(
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
    ---snp_req1 <= "000"&nilreq;
    ---pwr_req1 <= "00000";
    elsif rising_edge(Clock) then
      if stage = 0 then
        if re9 = '0' and emp9 = '0' then
          re9   <= '1';
          stage := 1;
        end if;
      elsif stage = 1 then
        re9 <= '0';
        if out9(72 downto 72) = "1" then
          snp1_2 <= "001" & out9;
          stage  := 2;
        end if;
      elsif stage = 2 then
        if snp1_ack2 = '1' then
          snp1_2 <= (others => '0');
          stage  := 0;
        end if;
      end if;
    end if;
  end process;

  audio_upreq_p : process(reset, Clock)
    variable stage : integer := 0;
  begin
    if reset = '1' then
    ---snp_req1 <= "000"&nilreq;
    elsif rising_edge(Clock) then
      if stage = 0 then
        if re13 = '0' and emp13 = '0' then
          re13  <= '1';
          stage := 1;
        end if;
      elsif stage = 1 then
        re13 <= '0';
        if out13(72 downto 72) = "1" then
          snp1_3 <= "100" & out13;
          stage  := 2;
        end if;
      elsif stage = 2 then
        if snp1_ack3 = '1' then
          snp1_3 <= (others => '0');
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
    ---snp_req1 <= "000"&nilreq;
    elsif rising_edge(Clock) then
      if stage = 0 then
        if re14 = '0' and emp14 = '0' then
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
          snp1_4 <= (others => '0');
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
    ---snp_req1 <= "000"&nilreq;
    elsif rising_edge(Clock) then
      if stage = 0 then
        if re15 = '0' and emp15 = '0' then
          re15  <= '1';
          stage := 1;
        end if;
      elsif stage = 1 then
        re15 <= '0';
        if out15(50 downto 50) = "1" then
          snp1_5 <= "010" & out15;
          stage  := 2;
        end if;
      elsif stage = 2 then
        if snp1_ack5 = '1' then
          snp1_5 <= (others => '0');
          stage  := 0;
        end if;
      end if;
    end if;
  end process;

  tomem_arbitor : entity work.arbiter6_ack(Behavioral)
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
      dout  => tomem_p,
      ack   => mem_ack
      );

  tomem_channel : process(reset, Clock)
    variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
    variable sdata   : std_logic_vector(31 downto 0)  := (others => '0');
    variable state   : integer                        := 0;
    variable lp      : integer                        := 0;
    variable tep_mem : std_logic_vector(75 downto 0);
    variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
  begin
    if reset = '1' then
      rvalid  <= '0';
      rdready <= '0';
    elsif rising_edge(Clock) then
      if state = 0 then
        bus_res1_1   <= nullreq;
        bus_res2_1   <= nullreq;
        gfx_upres1   <= (others => '0');
        uart_upres1  <= (others => '0');
        audio_upres1 <= (others => '0');
        usb_upres1   <= (others => '0');
        if tomem_p(72 downto 72) = "1" and tomem_p(71 downto 64) = "10000000" then
          tep_mem := tomem_p;
          state   := 6;
        elsif tomem_p(72 downto 72) = "1" and tomem_p(71 downto 64) = "01000000" then
          if tomem_p(75 downto 73)="001" or tomem_p(75 downto 73)="011"  or tomem_p(75 downto 73)="010"  or tomem_p(75 downto 73)="100" then
            mem_write1<=tomem_p;
            state   := 9;
          else
            tep_mem := tomem_p;
            state   := 6;
          end if;
        end if;
        
      elsif state = 6 then
        if rready = '1' then
          --mem_ack <= '0';
          rvalid <= '1';
          raddr  <= tomem_p(63 downto 32);
          if (tomem_p(75 downto 73) = "000" or tomem_p(75 downto 73) = "101") then
            rlen <= "00000" & "10000";
          else
            rlen <= "00000" & "00001";
          end if;
          rsize <= "00001" & "00000";
          state := 1;
        end if;
      elsif state = 1 then
        rvalid  <= '0';
        rdready <= '1';
        state   := 2;
      elsif state = 2 then
        if rdvalid = '1' and rres = "00" then
          if tep_mem(75 downto 73) = "000" or tep_mem(75 downto 73) = "101" then
            rdready                            <= '0';
            tdata(lp * 32 + 31 downto lp * 32) := rdata;
            lp                                 := lp + 1;
            if rlast = '1' then
              state := 3;
              lp    := 0;
            end if;
            rdready <= '1';
          else
            rdready <= '1';
            sdata   := rdata;
            rdready <= '1';
          end if;

        end if;
      elsif state = 3 then
        --mem_ack <= '1';
        if tep_mem(75 downto 73) = "000" then
          bus_res1_1 <= tep_mem(72 downto 32) & tdata;
          state      := 4;
        elsif tep_mem(75 downto 73) = "101" then
          bus_res2_1 <= tep_mem(72 downto 32) & tdata;
          state      := 4;
        elsif tep_mem(75 downto 73) = "001" then
          gfx_upres1 <= tep_mem(72 downto 32) & sdata;
          state      := 5;
        elsif tep_mem(75 downto 73) = "010" then
          uart_upres1 <= tep_mem(72 downto 32) & sdata;
          state       := 6;
        elsif tep_mem(75 downto 73) = "011" then
          usb_upres1 <= tep_mem(72 downto 32) & sdata;
          state      := 7;
        elsif tep_mem(75 downto 73) = "100" then
          audio_upres1 <= tep_mem(72 downto 32) & sdata;
          state        := 8;
        end if;

      elsif state = 4 then
        if brs2_ack1 = '1' then
          bus_res2_1 <= nullreq;
          state      := 0;
        elsif brs1_ack1 = '1' then
          bus_res1_1 <= nullreq;
          state      := 0;
        end if;
      elsif state = 5 then
        if gfx_upres_ack1 = '1' then
          gfx_upres1 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 6 then
        if uart_upres_ack1 = '1' then
          uart_upres1 <= (others => '0');
          state       := 0;
        end if;
      elsif state = 7 then
        if usb_upres_ack1 = '1' then
          usb_upres1 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 8 then
        if audio_upres_ack1 = '1' then
          audio_upres1 <= (others => '0');
          state        := 0;
        end if;
      elsif state = 9 then
        if mem_write_ack1 ='1' then
          mem_write1<=(others=>'0');
          state := 0;
          mem_ack <= '1';
        end if;
      end if;
    end if;
  end process;

  togfx_arbitor : entity work.arbiter6_ack(Behavioral)
    generic map(
      DATA_WIDTH => 76
      )
    port map(
      clock => Clock,
      reset => reset,
      din1  => togfx1,
      ack1  => gfx_ack1,
      din2  => togfx2,
      ack2  => gfx_ack2,
      din3  => togfx3,
      ack3  => gfx_ack3,
      din4  => togfx4,
      ack4  => gfx_ack4,
      din5  => togfx5,
      ack5  => gfx_ack5,
      din6  => togfx6,
      ack6  => gfx_ack6,
      dout  => togfx_p,
      ack 	=> gfx_ack
      );
  togfx_channel : process(reset, Clock)
    variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
    variable sdata   : std_logic_vector(31 downto 0)  := (others => '0');
    variable state   : integer                        := 0;
    variable lp      : integer                        := 0;
    variable tep_gfx : std_logic_vector(75 downto 0);
    variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
  begin
    if reset = '1' then
      rvalid_gfx  <= '0';
      rdready_gfx <= '0';
    elsif rising_edge(Clock) then
    	if state = 0 then
    		gfx_ack <='0';
        bus_res1_2   <= nullreq;
        bus_res2_2   <= nullreq;
        --gfx_upres2 <= (others => '0');
        uart_upres2  <= (others => '0');
        audio_upres2 <= (others => '0');
        usb_upres2   <= (others => '0');
        if togfx_p(72 downto 72) = "1" and togfx_p(71 downto 64) = "10000000" then
          tep_gfx := togfx_p;
          state   := 6;
        elsif togfx_p(72 downto 72) = "1" and togfx_p(71 downto 64) = "01000000" then
          gfx_write1<=togfx_p;
          state   := 9;
        end if;
      elsif state = 6 then
        if rready_gfx = '1' then
          ---gfx_ack <= '0';
          rvalid_gfx <= '1';
          raddr_gfx  <= togfx_p(63 downto 32);
          if (togfx_p(75 downto 73) = "000" or togfx_p(75 downto 73) = "101") then
            rlen_gfx <= "00001" & "00000";
          else
            rlen_gfx <= "00000" & "00001";
          end if;
          rsize_gfx <= "00001" & "00000";
          state     := 1;
        end if;
      elsif state = 1 then
        rvalid_gfx  <= '0';
        rdready_gfx <= '1';
        state       := 2;
      elsif state = 2 then
        if rdvalid_gfx = '1' and rres_gfx = "00" then
          if tep_gfx(75 downto 73) = "000" or tep_gfx(75 downto 73) = "101" then
            rdready_gfx                        <= '0';
            tdata(lp * 32 + 31 downto lp * 32) := rdata;
            lp                                 := lp + 1;
            if rlast_gfx = '1' then
              state := 3;
              lp    := 0;
            end if;
            rdready_gfx <= '1';
          else
            rdready_gfx <= '1';
            sdata       := rdata;
            rdready_gfx <= '1';
          end if;

        end if;
      elsif state = 3 then
        --gfx_ack <= '1';
        if tep_gfx(75 downto 73) = "000" then
          bus_res1_2 <= tep_gfx(72 downto 32) & tdata;
          state      := 4;
        elsif tep_gfx(75 downto 73) = "101" then
          bus_res2_2 <= tep_gfx(72 downto 32) & tdata;
          state      := 4;
        --elsif tep_gfx(75 downto 73)="001" then
        --gfx_upres2 <= tep_gfx(72 downto 32) & sdata;
        --state := 5;
        elsif tep_gfx(75 downto 73) = "010" then
          uart_upres2 <= tep_gfx(72 downto 32) & sdata;
          state       := 6;
        elsif tep_gfx(75 downto 73) = "011" then
          usb_upres2 <= tep_gfx(72 downto 32) & sdata;
          state      := 7;
        elsif tep_gfx(75 downto 73) = "100" then
          audio_upres2 <= tep_gfx(72 downto 32) & sdata;
          state        := 8;
        end if;

      elsif state = 4 then
        if brs2_ack2 = '1' then
          bus_res2_2 <= nullreq;
          state      := 0;
        elsif brs1_ack2 = '1' then
          bus_res1_2 <= nullreq;
          state      := 0;
        end if;
        
      elsif state = 6 then
        if uart_upres_ack2 = '1' then
          uart_upres2 <= (others => '0');
          state       := 0;
        end if;
      elsif state = 7 then
        if usb_upres_ack2 = '1' then
          usb_upres2 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 8 then
        if audio_upres_ack2 = '1' then
          audio_upres2 <= (others => '0');
          state        := 0;
        end if;
      elsif state = 9 then
        if gfx_write_ack1 ='1' then
          gfx_write1<=(others=>'0');
          state := 0;
          gfx_ack <='1';
        end if;
      end if;
    end if;
  end process;

  mem_write:process(reset, Clock)
    variable state:integer :=0;
    variable tep_mem:std_logic_vector(75 downto 0);
    variable tep_mem_l:std_logic_vector(552 downto 0);
    variable flag:std_logic;
    variable tdata :std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  --if flag is 1, then return mem write 2
  begin
    if reset ='1' then
      flag :='0';
    elsif rising_edge(Clock)then
      if state = 0 then
        lp :=0;
        mem_write_ack1<='0';
        mem_write_ack2<='0';
        mem_write_ack3<='0';
        if mem_write1(72 downto 72)="1" then
          state := 1;
          tep_mem:=mem_write1;
        elsif mem_write2(552 downto 552)="1" then
          state := 4;
          tep_mem_l :=mem_write2;
          flag :='1';
        elsif mem_write3(552 downto 552)="1" then
          state := 4;
          tep_mem_l :=mem_write3;
          flag :='0';
        end if;
      elsif state =1 then
        if wready = '0' then
          wvalid <= '1';
          waddr  <= tep_mem(63 downto 32);
          wlen   <= "00000" & "10000";
          wsize  <= "00001" & "00000";
          --wdata_audio := tep_mem(31 downto 0);
          state      := 2;
        end if;
      elsif state = 2 then
        if wdataready = '1' then
          wdvalid <= '1';
          wtrb    <= "1111";
          wdata  <= tep_mem(31 downto 0);
          wlast   <= '1';
          state       := 3;
        end if;

      elsif state = 3 then
        wdvalid <= '0';
        wrready <= '1';
        if wrvalid = '1' then
          if wrsp = "00" then
            state := 0;
            mem_write_ack1<='1';
          ---this is a successful write back, yayyy
          end if;
          wrready <= '0';
        end if;
      elsif state =4 then
        if wready = '0' then
          wvalid <= '1';
          waddr  <= mem_wb(543 downto 512);
          wlen   <= "00000" & "10000";
          wsize  <= "00001" & "00000";
          tdata      := tep_mem_l(511 downto 0);
          state      := 5;
        end if;
      elsif state = 5 then
        if wdataready = '1' then
          wdvalid <= '1';
          wtrb   <= "1111";
          wdata   <= tdata(lp + 31 downto lp);
          lp          := lp + 32;
          if lp = 512 then
            wlast <= '1';
            state     := 6;
            lp        := 0;
          end if;
        end if;
      elsif state = 6 then
        wdvalid <= '0';
        wrready <= '1';
        if wrvalid = '1' then
          state := 0;
          if wrsp = "00" then
            ---this is a successful write back, yayyy
            if flag='1' then
              mem_write_ack2<='1';
            else
              mem_write_ack3<='1';
            end if;
          end if;
          wrready <= '0';
        end if;
      end if;
    end if;
  end process;
  
  gfx_write:process(reset, Clock)
    variable state:integer :=0;
    variable tep_gfx:std_logic_vector(75 downto 0);
    variable tep_gfx_l:std_logic_vector(552 downto 0);
    variable flag:std_logic;
    variable tdata :std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  --if flag is 1, then return gfx write 2
  begin
    if reset ='1' then
      flag :='0';
    elsif rising_edge(Clock)then
      if state = 0 then
        lp :=0;
        gfx_write_ack1<='0';
        gfx_write_ack2<='0';
        gfx_write_ack3<='0';
        if gfx_write1(72 downto 72)="1" then
          state := 1;
          tep_gfx:=gfx_write1;
        elsif gfx_write2(552 downto 552)="1" then
          state := 4;
          tep_gfx_l :=gfx_write2;
          flag :='1';
        elsif gfx_write3(552 downto 552)="1" then
          state := 4;
          tep_gfx_l :=gfx_write3;
          flag :='0';
        end if;
      elsif state =1 then
        if wready_gfx = '0' then
          wvalid_gfx <= '1';
          waddr_gfx  <= tep_gfx(63 downto 32);
          wlen_gfx   <= "00000" & "10000";
          wsize_gfx  <= "00001" & "00000";
          --wdata_audio := tep_gfx(31 downto 0);
          state      := 2;
        end if;
      elsif state = 2 then
        if wdataready_gfx = '1' then
          wdvalid_gfx <= '1';
          wtrb_gfx    <= "1111";
          wdata_gfx   <= tep_gfx(31 downto 0);
          wlast_gfx   <= '1';
          state       := 3;
        end if;

      elsif state = 3 then
        wdvalid_gfx <= '0';
        wrready_gfx <= '1';
        if wrvalid_gfx = '1' then
          if wrsp_gfx = "00" then
            state := 0;
            gfx_write_ack1<='1';
          ---this is a successful write back, yayyy
          end if;
          wrready_gfx <= '0';
        end if;
      elsif state =4 then
        if wready_gfx = '0' then
          wvalid_gfx <= '1';
          waddr_gfx  <= mem_wb(543 downto 512);
          wlen_gfx   <= "00000" & "10000";
          wsize_gfx  <= "00001" & "00000";
          tdata      := tep_gfx_l(511 downto 0);
          state      := 5;
        end if;
      elsif state = 5 then
        if wdataready_gfx = '1' then
          wdvalid_gfx <= '1';
          wtrb_gfx    <= "1111";
          wdata_gfx   <= tdata(lp + 31 downto lp);
          lp          := lp + 32;
          if lp = 512 then
            wlast_gfx <= '1';
            state     := 6;
            lp        := 0;
          end if;
        end if;
      elsif state = 6 then
        wdvalid_gfx <= '0';
        wrready_gfx <= '1';
        if wrvalid_gfx = '1' then
          state := 0;
          if wrsp_gfx = "00" then
            ---this is a successful write back, yayyy
            if flag='1' then
              gfx_write_ack2<='1';
            else
              gfx_write_ack3<='1';
            end if;
          end if;
          wrready_gfx <= '0';
        end if;
      end if;
    end if;
  end process;
  uart_write:process(reset, Clock)
    variable state:integer :=0;
    variable tep_uart:std_logic_vector(75 downto 0);
    variable tep_uart_l:std_logic_vector(552 downto 0);
    variable flag:std_logic;
    variable tdata :std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  --if flag is 1, then return uart write 2
  begin
    if reset ='1' then
      flag :='0';
    elsif rising_edge(Clock)then
      if state = 0 then
        lp :=0;
        uart_write_ack1<='0';
        uart_write_ack2<='0';
        uart_write_ack3<='0';
        if uart_write1(72 downto 72)="1" then
          state := 1;
          tep_uart:=uart_write1;
        elsif uart_write2(552 downto 552)="1" then
          state := 4;
          tep_uart_l :=uart_write2;
          flag :='1';
        elsif uart_write3(552 downto 552)="1" then
          state := 4;
          tep_uart_l :=uart_write3;
          flag :='0';
        end if;
      elsif state =1 then
        if wready_uart = '0' then
          wvalid_uart <= '1';
          waddr_uart  <= tep_uart(63 downto 32);
          wlen_uart   <= "00000" & "10000";
          wsize_uart  <= "00001" & "00000";
          --wdata_audio := tep_uart(31 downto 0);
          state      := 2;
        end if;
      elsif state = 2 then
        if wdataready_uart = '1' then
          wdvalid_uart <= '1';
          wtrb_uart    <= "1111";
          wdata_uart   <= tep_uart(31 downto 0);
          wlast_uart   <= '1';
          state       := 3;
        end if;

      elsif state = 3 then
        wdvalid_uart <= '0';
        wrready_uart <= '1';
        if wrvalid_uart = '1' then
          if wrsp_uart = "00" then
            state := 0;
            uart_write_ack1<='1';
          ---this is a successful write back, yayyy
          end if;
          wrready_uart <= '0';
        end if;
      elsif state =4 then
        if wready_uart = '0' then
          wvalid_uart <= '1';
          waddr_uart  <= mem_wb(543 downto 512);
          wlen_uart   <= "00000" & "10000";
          wsize_uart  <= "00001" & "00000";
          tdata      := tep_uart_l(511 downto 0);
          state      := 5;
        end if;
      elsif state = 5 then
        if wdataready_uart = '1' then
          wdvalid_uart <= '1';
          wtrb_uart    <= "1111";
          wdata_uart   <= tdata(lp + 31 downto lp);
          lp          := lp + 32;
          if lp = 512 then
            wlast_uart <= '1';
            state     := 6;
            lp        := 0;
          end if;
        end if;
      elsif state = 6 then
        wdvalid_uart <= '0';
        wrready_uart <= '1';
        if wrvalid_uart = '1' then
          state := 0;
          if wrsp_uart = "00" then
            ---this is a successful write back, yayyy
            if flag='1' then
              uart_write_ack2<='1';
            else
              uart_write_ack3<='1';
            end if;
          end if;
          wrready_uart <= '0';
        end if;
      end if;
    end if;
  end process;
  toaudio_arbitor : entity work.arbiter2_ack(Behavioral)
    generic map(
      DATA_WIDTH => 76
      )
    port map(
      clock => Clock,
      reset => reset,
      din1  => toaudio1,
      ack1  => audio_ack1,
      din2  => toaudio2,
      ack2  => audio_ack2,
      dout  => toaudio_p,
      ack 	=> audio_ack
      );
  tousb_arbitor : entity work.arbiter2_ack(Behavioral)
    generic map(
      DATA_WIDTH => 76
      )
    port map(
      clock => Clock,
      reset => reset,
      din1  => tousb1,
      ack1  => usb_ack1,
      din2  => tousb2,
      ack2  => usb_ack2,
      dout  => tousb_p,
      ack	=> usb_ack
      );
  audio_write:process(reset, Clock)
    variable state:integer :=0;
    variable tep_audio:std_logic_vector(75 downto 0);
    variable tep_audio_l:std_logic_vector(552 downto 0);
    variable flag:std_logic;
    variable tdata :std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  --if flag is 1, then return audio write 2
  begin
    if reset ='1' then
      flag :='0';
    elsif rising_edge(Clock)then
      if state = 0 then
        lp :=0;
        audio_write_ack1<='0';
        audio_write_ack2<='0';
        audio_write_ack3<='0';
        if audio_write1(72 downto 72)="1" then
          state := 1;
          tep_audio:=audio_write1;
        elsif audio_write2(552 downto 552)="1" then
          state := 4;
          tep_audio_l :=audio_write2;
          flag :='1';
        elsif audio_write3(552 downto 552)="1" then
          state := 4;
          tep_audio_l :=audio_write3;
          flag :='0';
        end if;
      elsif state =1 then
        if wready_audio = '0' then
          wvalid_audio <= '1';
          waddr_audio  <= tep_audio(63 downto 32);
          wlen_audio   <= "00000" & "10000";
          wsize_audio  <= "00001" & "00000";
          --wdata_audio := tep_audio(31 downto 0);
          state      := 2;
        end if;
      elsif state = 2 then
        if wdataready_audio = '1' then
          wdvalid_audio <= '1';
          wtrb_audio    <= "1111";
          wdata_audio   <= tep_audio(31 downto 0);
          wlast_audio   <= '1';
          state       := 3;
        end if;

      elsif state = 3 then
        wdvalid_audio <= '0';
        wrready_audio <= '1';
        if wrvalid_audio = '1' then
          if wrsp_audio = "00" then
            state := 0;
            audio_write_ack1<='1';
          ---this is a successful write back, yayyy
          end if;
          wrready_audio <= '0';
        end if;
      elsif state =4 then
        if wready_audio = '0' then
          wvalid_audio <= '1';
          waddr_audio  <= mem_wb(543 downto 512);
          wlen_audio   <= "00000" & "10000";
          wsize_audio  <= "00001" & "00000";
          tdata      := tep_audio_l(511 downto 0);
          state      := 5;
        end if;
      elsif state = 5 then
        if wdataready_audio = '1' then
          wdvalid_audio <= '1';
          wtrb_audio    <= "1111";
          wdata_audio   <= tdata(lp + 31 downto lp);
          lp          := lp + 32;
          if lp = 512 then
            wlast_audio <= '1';
            state     := 6;
            lp        := 0;
          end if;
        end if;
      elsif state = 6 then
        wdvalid_audio <= '0';
        wrready_audio <= '1';
        if wrvalid_audio = '1' then
          state := 0;
          if wrsp_audio = "00" then
            ---this is a successful write back, yayyy
            if flag='1' then
              audio_write_ack2<='1';
            else
              audio_write_ack3<='1';
            end if;
          end if;
          wrready_audio <= '0';
        end if;
      end if;
    end if;
  end process;
  tousb_channel : process(reset, Clock)
    variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
    variable sdata   : std_logic_vector(31 downto 0)  := (others => '0');
    variable state   : integer                        := 0;
    variable lp      : integer                        := 0;
    variable tep_usb : std_logic_vector(75 downto 0);
    variable nullreq : std_logic_vector(552 downto 0) := (others => '0');
  begin
    if reset = '1' then
      rvalid_usb  <= '0';
      rdready_usb <= '0';
    elsif rising_edge(Clock) then
    	if state =0 then
    		usb_ack <= '1';
    		state := 20;
    	elsif state = 20 then
    		usb_ack <='0';
        bus_res1_4   <= (others => '0');
        bus_res2_4   <= (others => '0');
        gfx_upres4   <= (others => '0');
        uart_upres4  <= (others => '0');
        audio_upres4 <= (others => '0');
        --usb_upres4 <= (others => '0');
        if tousb_p(72 downto 72) = "1" and tousb_p(71 downto 64) = "10000000" then
          tep_usb := tousb_p;
          state   := 6;
        elsif tousb_p(72 downto 72) = "1" and tousb_p(71 downto 64) = "01000000" then
          usb_write1<=tousb_p;
          state   := 9;
        end if;
      elsif state = 6 then
        if rready_usb = '1' then
          ---usb_ack <= '0';
          rvalid_usb <= '1';
          raddr_usb  <= tousb_p(63 downto 32);
          if (tousb_p(75 downto 73) = "000" or tousb_p(75 downto 73) = "101") then
            rlen_usb <= "00001" & "00000";
          else
            rlen_usb <= "00000" & "00001";
          end if;
          rsize_usb <= "00001" & "00000";
          state     := 1;
        end if;
      elsif state = 1 then
        rvalid_usb  <= '0';
        rdready_usb <= '1';
        state       := 2;
      elsif state = 2 then
        if rdvalid_usb = '1' and rres_usb = "00" then
          if tep_usb(75 downto 73) = "000" or tep_usb(75 downto 73) = "101" then
            rdready_usb                        <= '0';
            tdata(lp * 32 + 31 downto lp * 32) := rdata;
            lp                                 := lp + 1;
            if rlast_usb = '1' then
              state := 3;
              lp    := 0;
            end if;
            rdready_usb <= '1';
          else
            rdready_usb <= '1';
            sdata       := rdata;
            rdready_usb <= '1';
          end if;

        end if;
      elsif state = 3 then
        --usb_ack <= '1';
        if tep_usb(75 downto 73) = "000" then
          bus_res1_4 <= tep_usb(72 downto 32) & tdata;
          state      := 4;
        elsif tep_usb(75 downto 73) = "101" then
          bus_res2_4 <= tep_usb(72 downto 32) & tdata;
          state      := 4;
        elsif tep_usb(75 downto 73) = "001" then
          gfx_upres4 <= tep_usb(72 downto 32) & sdata;
          state      := 5;
        elsif tep_usb(75 downto 73) = "010" then
          uart_upres4 <= tep_usb(72 downto 32) & sdata;
          state       := 6;
        --				elsif tep_usb(75 downto 73)="011" then
        --					usb_upres4<= tep_usb(72 downto 32) & sdata;
        --					state := 7;
        elsif tep_usb(75 downto 73) = "100" then
          audio_upres4 <= tep_usb(72 downto 32) & sdata;
          state        := 8;
        end if;

      elsif state = 4 then
        if brs2_ack4 = '1' then
          bus_res2_4 <= nullreq;
          state      := 0;
        elsif brs1_ack4 = '1' then
          bus_res1_4 <= nullreq;
          state      := 0;
        end if;
      elsif state = 5 then
        if gfx_upres_ack4 = '1' then
          gfx_upres4 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 6 then
        if uart_upres_ack4 = '1' then
          uart_upres4 <= (others => '0');
          state       := 0;
        end if;
        
      elsif state = 8 then
        if audio_upres_ack4 = '1' then
          audio_upres4 <= (others => '0');
          state        := 0;
        end if;
      elsif state = 9 then
        if usb_write_ack1 ='1' then
          usb_write1<=(others=>'0');
          state := 0;
        end if;
      end if;
    end if;
  end process;
  usb_write:process(reset, Clock)
    variable state:integer :=0;
    variable tep_usb:std_logic_vector(75 downto 0);
    variable tep_usb_l:std_logic_vector(552 downto 0);
    variable flag:std_logic;
    variable tdata :std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  --if flag is 1, then return usb write 2
  begin
    if reset ='1' then
      flag :='0';
    elsif rising_edge(Clock)then
      if state = 0 then
        lp :=0;
        usb_write_ack1<='0';
        usb_write_ack2<='0';
        usb_write_ack3<='0';
        if usb_write1(72 downto 72)="1" then
          state := 1;
          tep_usb:=usb_write1;
        elsif usb_write2(552 downto 552)="1" then
          state := 4;
          tep_usb_l :=usb_write2;
          flag :='1';
        elsif usb_write3(552 downto 552)="1" then
          state := 4;
          tep_usb_l :=usb_write3;
          flag :='0';
        end if;
      elsif state =1 then
        if wready_usb = '0' then
          wvalid_usb <= '1';
          waddr_usb  <= tep_usb(63 downto 32);
          wlen_usb   <= "00000" & "10000";
          wsize_usb  <= "00001" & "00000";
          --wdata_audio := tep_usb(31 downto 0);
          state      := 2;
        end if;
      elsif state = 2 then
        if wdataready_usb = '1' then
          wdvalid_usb <= '1';
          wtrb_usb    <= "1111";
          wdata_usb   <= tep_usb(31 downto 0);
          wlast_usb   <= '1';
          state       := 3;
        end if;

      elsif state = 3 then
        wdvalid_usb <= '0';
        wrready_usb <= '1';
        if wrvalid_usb = '1' then
          if wrsp_usb = "00" then
            state := 0;
            usb_write_ack1<='1';
          ---this is a successful write back, yayyy
          end if;
          wrready_usb <= '0';
        end if;
      elsif state =4 then
        if wready_usb = '0' then
          wvalid_usb <= '1';
          waddr_usb  <= mem_wb(543 downto 512);
          wlen_usb   <= "00000" & "10000";
          wsize_usb  <= "00001" & "00000";
          tdata      := tep_usb_l(511 downto 0);
          state      := 5;
        end if;
      elsif state = 5 then
        if wdataready_usb = '1' then
          wdvalid_usb <= '1';
          wtrb_usb    <= "1111";
          wdata_usb   <= tdata(lp + 31 downto lp);
          lp          := lp + 32;
          if lp = 512 then
            wlast_usb <= '1';
            state     := 6;
            lp        := 0;
          end if;
        end if;
      elsif state = 6 then
        wdvalid_usb <= '0';
        wrready_usb <= '1';
        if wrvalid_usb = '1' then
          state := 0;
          if wrsp_usb = "00" then
            ---this is a successful write back, yayyy
            if flag='1' then
              usb_write_ack2<='1';
            else
              usb_write_ack3<='1';
            end if;
          end if;
          wrready_usb <= '0';
        end if;
      end if;
    end if;
  end process;
  touart_arbitor : entity work.arbiter2_ack(Behavioral)
    generic map(
      DATA_WIDTH => 76
      )
    port map(
      clock => Clock,
      reset => reset,
      din1  => touart1,
      ack1  => uart_ack1,
      din2  => touart2,
      ack2  => uart_ack2,
      dout  => touart_p,
      ack	=> uart_ack
      );
  touart_channel : process(reset, Clock)
    variable tdata    : std_logic_vector(511 downto 0) := (others => '0');
    variable sdata    : std_logic_vector(31 downto 0)  := (others => '0');
    variable state    : integer                        := 0;
    variable lp       : integer                        := 0;
    variable tep_uart : std_logic_vector(75 downto 0);
    variable nullreq  : std_logic_vector(552 downto 0) := (others => '0');
  begin
    if reset = '1' then
      rvalid_uart  <= '0';
      rdready_uart <= '0';
    elsif rising_edge(Clock) then
    	  if state = 0 then
    		uart_ack <= '1';
    	elsif state = 20 then
    		uart_ack <='0';
        bus_res1_3   <= nullreq;
        bus_res2_3   <= nullreq;
        gfx_upres3   <= (others => '0');
        --uart_upres3 <= (others => '0');
        audio_upres3 <= (others => '0');
        usb_upres3   <= (others => '0');
        if touart_p(72 downto 72) = "1" and touart_p(71 downto 64) = "10000000" then
          tep_uart := touart_p;
          state    := 6;
        elsif touart_p(72 downto 72) = "1" and touart_p(71 downto 64) = "01000000" then
          uart_write1<=touart_p;
          state   := 9;
        end if;
      elsif state = 6 then
        if rready_uart = '1' then
          ---uart_ack <= '0';
          rvalid_uart <= '1';
          raddr_uart  <= touart_p(63 downto 32);
          if (touart_p(75 downto 73) = "000" or touart_p(75 downto 73) = "101") then
            rlen_uart <= "00001" & "00000";
          else
            rlen_uart <= "00000" & "00001";
          end if;
          rsize_uart <= "00001" & "00000";
          state      := 1;
        end if;
      elsif state = 1 then
        rvalid_uart  <= '0';
        rdready_uart <= '1';
        state        := 2;
      elsif state = 2 then
        if rdvalid_uart = '1' and rres_uart = "00" then
          if tep_uart(75 downto 73) = "000" or tep_uart(75 downto 73) = "101" then
            rdready_uart                       <= '0';
            tdata(lp * 32 + 31 downto lp * 32) := rdata;
            lp                                 := lp + 1;
            if rlast_uart = '1' then
              state := 3;
              lp    := 0;
            end if;
            rdready_uart <= '1';
          else
            rdready_uart <= '1';
            sdata        := rdata;
            rdready_uart <= '1';
          end if;

        end if;
      elsif state = 3 then
        --uart_ack <= '1';
        if tep_uart(75 downto 73) = "000" then
          bus_res1_3 <= tep_uart(72 downto 32) & tdata;
          state      := 4;
        elsif tep_uart(75 downto 73) = "101" then
          bus_res2_3 <= tep_uart(72 downto 32) & tdata;
          state      := 4;
        elsif tep_uart(75 downto 73) = "001" then
          gfx_upres3 <= tep_uart(72 downto 32) & sdata;
          state      := 5;
        --				elsif tep_uart(75 downto 73)="010" then
        --					uart_upres3<= tep_uart(72 downto 32) & sdata;
        --					state := 6;
        elsif tep_uart(75 downto 73) = "011" then
          usb_upres3 <= tep_uart(72 downto 32) & sdata;
          state      := 7;
        elsif tep_uart(75 downto 73) = "100" then
          audio_upres3 <= tep_uart(72 downto 32) & sdata;
          state        := 8;
        end if;

      elsif state = 4 then
        if brs2_ack3 = '1' then
          bus_res2_3 <= nullreq;
          state      := 0;
        elsif brs1_ack3 = '1' then
          bus_res1_3 <= nullreq;
          state      := 0;
        end if;
      elsif state = 5 then
        if gfx_upres_ack3 = '1' then
          gfx_upres3 <= (others => '0');
          state      := 0;
        end if;
      --			elsif state =6 then
      --				if uart_upres_ack3 ='1' then
      --					uart_upres3 <= (others => '0');
      --					state :=0;
      --				end if;	
      elsif state = 7 then
        if usb_upres_ack3 = '1' then
          usb_upres3 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 8 then
        if audio_upres_ack3 = '1' then
          audio_upres3 <= (others => '0');
          state        := 0;
        end if;
      elsif state = 9 then
        if uart_write_ack1 ='1' then
          uart_write1<=(others=>'0');
          state := 0;
        end if;
      end if;
    end if;
  end process;

  brs2_arbitor : entity work.arbiter6(Behavioral)
    generic map(
      DATA_WIDTH => 553
      )
    port map(
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
      DATA_WIDTH => 76
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
      dout  => snp_req1
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

  brs1_arbitor : entity work.arbiter7(Behavioral)
    generic map(
      DATA_WIDTH => 553
      )
    port map(
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
      din7  => bus_res1_7,
      ack7  => brs1_ack7,
      dout  => bus_res1
      );
  gfx_upres_arbitor : entity work.arbiter6(Behavioral)
    generic map(
      DATA_WIDTH => 73
      ) port map(
        clock => Clock,
        reset => reset,
        din1 => gfx_upres1,
        ack1 => gfx_upres_ack1,
        din2 => gfx_upres2,
        ack2 => gfx_upres_ack2,
        din3 => gfx_upres3,
        ack3 => gfx_upres_ack3,
        din4 => gfx_upres4,
        ack4 => gfx_upres_ack4,
        din5 => gfx_upres5,
        ack5 => gfx_upres_ack5,
        din6 => gfx_upres6,
        ack6 => gfx_upres_ack6,
        dout => gfx_upres
		);
  audio_upres_arbitor : entity work.arbiter6(Behavioral)
    generic map(
      DATA_WIDTH => 73
      )
    port map(
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

  wb_arbitor : entity work.arbiter2(Behavioral)
    generic map(
      DATA_WIDTH => 553
      )
    port map(
      clock => Clock,
      reset => reset,
      din1  => mem_wb1,
      ack1  => wb_ack1,
      din2  => mem_wb2,
      ack2  => wb_ack2,
      dout  => mem_wb
      );
  gfx_wb_arbitor : entity work.arbiter2(Behavioral)
    generic map(
      DATA_WIDTH => 553
      ) port map(
        clock => Clock,
        reset => reset,
        din1 => gfx_wb1,
        ack1 => gfx_wb_ack1,
        din2 => gfx_wb2,
        ack2 => gfx_wb_ack2,
        dout => gfx_wb
		);
  audio_wb_arbitor : entity work.arbiter2(Behavioral) generic map(
    DATA_WIDTH => 553
    ) port map(
      clock => Clock,
      reset => reset,
      din1 => audio_wb1,
      ack1 => audio_wb_ack1,
      din2 => audio_wb2,
      ack2 => audio_wb_ack2,
      dout => audio_wb
      );
  toaudio_channel : process(reset, Clock)
    variable tdata     : std_logic_vector(511 downto 0) := (others => '0');
    variable sdata     : std_logic_vector(31 downto 0)  := (others => '0');
    variable state     : integer                        := 0;
    variable lp        : integer                        := 0;
    variable tep_audio : std_logic_vector(75 downto 0);
    variable nullreq   : std_logic_vector(552 downto 0) := (others => '0');
  begin
    if reset = '1' then
      rvalid_audio  <= '0';
      rdready_audio <= '0';
    elsif rising_edge(Clock) then
      if state = 0 then
        bus_res1_5  <= nullreq;
        bus_res2_5  <= nullreq;
        gfx_upres5  <= (others => '0');
        uart_upres5 <= (others => '0');
        --audio_upres5 <= (others => '0');
        usb_upres5  <= (others => '0');
        if toaudio_p(72 downto 72) = "1" and toaudio_p(71 downto 64) = "10000000" then
          tep_audio := toaudio_p;
          state     := 6;
        elsif toaudio_p(72 downto 72) = "1" and toaudio_p(71 downto 64) = "01000000" then
          audio_write1<=toaudio_p;
          state   := 9;
        end if;
      elsif state = 6 then
        if rready_audio = '1' then
          ---audio_ack <= '0';
          rvalid_audio <= '1';
          raddr_audio  <= toaudio_p(63 downto 32);
          if (toaudio_p(75 downto 73) = "000" or toaudio_p(75 downto 73) = "101") then
            rlen_audio <= "00001" & "00000";
          else
            rlen_audio <= "00000" & "00001";
          end if;
          rsize_audio <= "00001" & "00000";
          state       := 1;
        end if;
      elsif state = 1 then
        rvalid_audio  <= '0';
        rdready_audio <= '1';
        state         := 2;
      elsif state = 2 then
        if rdvalid_audio = '1' and rres_audio = "00" then
          if tep_audio(75 downto 73) = "000" or tep_audio(75 downto 73) = "101" then
            rdready_audio                      <= '0';
            tdata(lp * 32 + 31 downto lp * 32) := rdata;
            lp                                 := lp + 1;
            if rlast_audio = '1' then
              state := 3;
              lp    := 0;
            end if;
            rdready_audio <= '1';
          else
            rdready_audio <= '1';
            sdata         := rdata;
            rdready_audio <= '1';
          end if;

        end if;
      elsif state = 3 then
        --audio_ack <= '1';
        if tep_audio(75 downto 73) = "000" then
          bus_res1_5 <= tep_audio(72 downto 32) & tdata;
          state      := 4;
        elsif tep_audio(75 downto 73) = "101" then
          bus_res2_5 <= tep_audio(72 downto 32) & tdata;
          state      := 4;
        elsif tep_audio(75 downto 73) = "001" then
          gfx_upres5 <= tep_audio(72 downto 32) & sdata;
          state      := 5;
        elsif tep_audio(75 downto 73) = "010" then
          uart_upres5 <= tep_audio(72 downto 32) & sdata;
          state       := 6;
        elsif tep_audio(75 downto 73) = "011" then
          usb_upres5 <= tep_audio(72 downto 32) & sdata;
          state      := 7;
        --				elsif tep_audio(75 downto 73)="100" then
        --					audio_upres5 <= tep_audio(72 downto 32) & sdata;
        --					state := 8;
        end if;

      elsif state = 4 then
        if brs2_ack5 = '1' then
          bus_res2_5 <= nullreq;
          state      := 0;
        elsif brs1_ack5 = '1' then
          bus_res1_5 <= nullreq;
          state      := 0;
        end if;
      elsif state = 5 then
        if gfx_upres_ack5 = '1' then
          gfx_upres5 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 6 then
        if uart_upres_ack5 = '1' then
          uart_upres5 <= (others => '0');
          state       := 0;
        end if;
      elsif state = 7 then
        if usb_upres_ack5 = '1' then
          usb_upres5 <= (others => '0');
          state      := 0;
        end if;
      --			elsif state =8 then
      --				if audio_upres_ack5 ='1' then
      --					audio_upres5 <= (others => '0');
      --					state :=0;
      --				end if;	
      elsif state = 9 then
        if audio_write_ack1 ='1' then
          audio_write1<=(others=>'0');
          state := 0;
        end if;
      end if;
    end if;
  end process;

  usb_wb_arbitor : entity work.arbiter2(Behavioral) generic map(
    DATA_WIDTH => 553
    ) port map(
      clock => Clock,
      reset => reset,
      din1 => usb_wb1,
      ack1 => usb_wb_ack1,
      din2 => usb_wb2,
      ack2 => usb_wb_ack2,
      dout => usb_wb
      );
  uart_wb_arbitor : entity work.arbiter2(Behavioral) generic map(
    DATA_WIDTH => 553
    ) port map(
      clock => Clock,
      reset => reset,
      din1 => uart_wb1,
      ack1 => uart_wb_ack1,
      din2 => uart_wb2,
      ack2 => uart_wb_ack2,
      dout => uart_wb
      );

  snp_res1_fifo : process(reset, Clock)
  begin
    if reset = '1' then
      we2 <= '0';
    elsif rising_edge(Clock) then
      if snp_res1(72 downto 72) = "1" then
        if snp_hit1 = '0' then
          in2 <= '0' & snp_res1;
        else
          in2 <= '1' & snp_res1;
        end if;
        we2 <= '1';
      else
        we2 <= '0';
      end if;

    end if;
  end process;

  snp_res1_p : process(reset, Clock)
    variable state : integer := 0;
  begin
    if reset = '1' then
    elsif rising_edge(Clock) then
      if state = 0 then
        if re2 = '0' and emp2 = '0' then
          re2   <= '1';
          state := 1;
        end if;
      elsif state = 1 then
        re2 <= '0';
        if out2(76 downto 76) = "0" then
          ---now we look at which components it want to go
          if out2(63 downto 63) = "1" then
            ---this belongs to the memory					
            tomem3 <= out2(75 downto 0);
            state  := 5;
          elsif out2(62 downto 61) = "00" then
            togfx3 <= out2(75 downto 0);
            state  := 6;
          elsif out2(62 downto 61) = "01" then
            touart3 <= out2(75 downto 0);
            state   := 7;
          elsif out2(62 downto 61) = "10" then
            tousb3 <= out2(75 downto 0);
            state  := 8;
          elsif out2(62 downto 61) = "11" then
            toaudio3 <= out2(75 downto 0);
            state    := 13;
          end if;
        --it's a hit, return to the source ip
        else
          if out2(75 downto 73) = "001" then
            gfx_upres2 <= out2(72 downto 0);
            state      := 9;
          elsif out2(75 downto 73) = "010" then
            uart_upres3 <= out2(72 downto 0);
            state       := 10;
          elsif out2(75 downto 73) = "011" then
            usb_upres4 <= out2(72 downto 0);
            state      := 11;
          elsif out2(75 downto 73) = "100" then
            audio_upres5 <= out2(72 downto 0);
            state        := 12;
          end if;
        end if;
      elsif state = 5 then
        if mem_ack3 = '1' then
          state  := 0;
          tomem3 <= (others => '0');
        end if;
      elsif state = 6 then
        if gfx_ack3 = '1' then
          state  := 0;
          togfx3 <= (others => '0');
        end if;
      elsif state = 7 then
        if uart_ack3 = '1' then
          state   := 0;
          touart3 <= (others => '0');
        end if;
      elsif state = 8 then
        if audio_ack3 = '1' then
          state    := 0;
          toaudio3 <= (others => '0');
        end if;
      elsif state = 12 then
        if usb_ack3 = '1' then
          state  := 0;
          tousb3 <= (others => '0');
        end if;
      elsif state = 9 then
        if gfx_upres_ack2 = '1' then
          gfx_upres2 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 10 then
        if uart_upres_ack3 = '1' then
          uart_upres3 <= (others => '0');
          state       := 0;
        end if;
      elsif state = 11 then
        if usb_upres_ack4 = '1' then
          usb_upres4 <= (others => '0');
          state      := 0;
        end if;
      elsif state = 12 then
        if audio_upres_ack4 = '1' then
          audio_upres5 <= (others => '0');
          state        := 0;
        end if;

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
  ---this need to be edited, 
  --1. axi protocl
  ---2. more than 2 ips
  wb_1_p : process(reset, Clock)
    variable state : integer;
    variable tdata:std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  begin
    if reset = '1' then
      state   := 0;
    elsif rising_edge(Clock) then
      if state = 0 then
        if re6 = '0' and emp6 = '0' then
          re6   <= '1';
          state := 1;
        end if;
      elsif state = 1 then
        re6 <= '0';
        if out6(552 downto 552) = "1" then
          if out6(543 downto 543) = "1" then
            mem_write2 <=out6;
          elsif out6(542 downto 541) = "00" and wready_gfx = '0' then
            gfx_write2 <= out6;
            state      := 3;
          elsif out6(542 downto 541) = "01" and wready_uart = '0' then
            uart_write2 <= out6;
            state       := 4;
          elsif out6(542 downto 541) = "10" and wready_usb = '0' then
            usb_write2 <= out6;
            state      := 5;
          elsif out6(542 downto 541) = "11" and wready_audio = '0' then
            audio_write2 <= out6;
            state        := 6;
          end if;
        end if;
      elsif state = 1 then
        if mem_write_ack2='1' then
          mem_write2 <=(others => '0');
          state :=0;
        end if;
		
        
        
      elsif state = 3 then
        if gfx_write_ack2='1' then
          gfx_write2<=(others=>'0');
          state :=0;
        end if;
      elsif state = 4 then
        if uart_write_ack2='1' then
          uart_write2<=(others=>'0');
          state :=0;
        end if;
      elsif state = 5 then
        if usb_write_ack2='1' then
          usb_write2<=(others=>'0');
          state :=0;
        end if;
      elsif state = 6 then
        if audio_write_ack2='1' then
          audio_write2<=(others=>'0');
          state :=0;
        end if;
      end if;

    end if;
  end process;

  ---write_back process
  wb_2_p : process(reset, Clock)
    variable state : integer;
    variable tdata:std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  begin
    if reset = '1' then
      state   := 0;

    elsif rising_edge(Clock) then
      if state = 0 then
        if re7 = '0' and emp7 = '0' then
          re7   <= '1';
          state := 1;
        end if;
      elsif state = 1 then
        re7 <= '0';
        if out7(552 downto 552) = "1" then
          if out7(543 downto 543) = "1" then
            mem_write3 <=out7;
            state  := 1;
          elsif out7(542 downto 541) = "00" and wready_gfx = '0' then
            gfx_write3 <= out7;
            state      := 3;
          elsif out7(542 downto 541) = "01" and wready_uart = '0' then
            uart_write3 <= out7;
            state       := 4;
          elsif out7(542 downto 541) = "10" and wready_usb = '0' then
            usb_write3 <= out7;
            state      := 5;
          elsif out7(542 downto 541) = "11" and wready_audio = '0' then
            audio_write3 <= out7;
            state        := 6;
          end if;
        end if;
      elsif state = 1 then
        if mem_write_ack3='1' then
          mem_write3<=(others=>'0');
          state:=0;
        end if;
        
      elsif state = 3 then
        if gfx_write_ack3='1' then
          gfx_write3<=(others=>'0');
          state :=0;
        end if;
      elsif state = 4 then
        if uart_write_ack3='1' then
          uart_write3<=(others=>'0');
          state :=0;
        end if;
      elsif state = 5 then
        if usb_write_ack3='1' then
          usb_write3<=(others=>'0');
          state :=0;
        end if;
      elsif state = 6 then
        if audio_write_ack3='1' then
          audio_write3<=(others=>'0');
          state :=0;
        end if;
      end if;

    end if;
  end process;

  cache_req1_p : process(reset, Clock)
    variable nilreq  : std_logic_vector(72 downto 0)  := (others => '0');
    variable state   : integer                        := 0;
    variable count   : integer                        := 0;
    variable nildata : std_logic_vector(543 downto 0) := (others => '0');
  begin
    if reset = '1' then
    --snp_req2 <= nilreq;
    elsif rising_edge(Clock) then
      if state = 0 then
        if cache_req1(72 downto 72) = "1" and cache_req1(71 downto 64) = "11111111" then
          ---let's not consider power now, too complicated
          pwr_req1 <= '1' & cache_req1(64 downto 61);
          state    := 4;
        elsif cache_req1(72 downto 72) = "1" and cache_req1(63 downto 32) = adr_1 then
          state      := 3;
          ----should return to cache, let it perform snoop again!!!
          -----
          ----don't forget to fill this up
          -----
          bus_res1_7 <= '1' & "11111111" & nildata;
        elsif cache_req1(72 downto 72) = "1" then
          adr_0 <= cache_req1(63 downto 32);
			 tmp_cache_req1 <= cache_req1;
          state := 2;
        else
          state := 0;
        end if;
      elsif state = 2 then
        if tmp_cache_req1(63 downto 63) = "1" then
          ---this belongs to the memory					
          tomem1 <= "000" & tmp_cache_req1;
          state  := 5;
        elsif tmp_cache_req1(62 downto 61) = "00" then
          togfx1 <= "000" & tmp_cache_req1;
          state  := 6;
        elsif tmp_cache_req1(62 downto 61) = "01" then
          touart1 <= "000" & tmp_cache_req1;
          state   := 7;
        elsif tmp_cache_req1(62 downto 61) = "10" then
          tousb1 <= "000" & tmp_cache_req1;
          state  := 8;
        elsif tmp_cache_req1(62 downto 61) = "11" then
          toaudio1 <= "000" & tmp_cache_req1;
          state    := 9;
        end if;
      elsif state = 3 then
        if brs1_ack5 = '1' then
          bus_res1_7 <= (others => '0');
        end if;
      elsif state = 4 then
        if pwr_ack1 = '1' then
          ---pwr_req1<= "00000";
          state := 0;
        end if;
      elsif state = 5 then
        if mem_ack1 = '1' then
          state  := 0;
          tomem1 <= (others => '0');
        end if;
      elsif state = 6 then
        if gfx_ack1 = '1' then
          state  := 0;
          togfx1 <= (others => '0');
        end if;
      elsif state = 7 then
        if usb_ack1 = '1' then
          state  := 0;
          tousb1 <= (others => '0');
        end if;
      elsif state = 8 then
        if audio_ack1 = '1' then
          state    := 0;
          toaudio1 <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  ---deal with cache request
  cache_req2_p : process(reset, Clock)
    variable nilreq  : std_logic_vector(72 downto 0)  := (others => '0');
    variable state   : integer                        := 0;
    variable count   : integer                        := 0;
    variable nildata : std_logic_vector(543 downto 0) := (others => '0');
  begin
    if reset = '1' then
    --snp_req2 <= nilreq;
    elsif rising_edge(Clock) then
      if state = 0 then
        if cache_req2(72 downto 72) = "1" and cache_req2(71 downto 64) = "11111111" then
          ---let's not consider power now, too complicated
          pwr_req2 <= '1' & cache_req2(64 downto 61);
          state    := 4;
        elsif cache_req2(72 downto 72) = "1" and cache_req2(63 downto 32) = adr_1 then
          state      := 3;
          ----should return to cache, let it perform snoop again!!!
          -----
          ----don't forget to fill this up
          -----
          bus_res1_6 <= '1' & "11111111" & nildata;
        elsif cache_req2(72 downto 72) = "1" then
          ---snp_req2 <= cache_req2;
          adr_0 <= cache_req2(63 downto 32);
          state := 2;
			 tmp_cache_req2 <= cache_req2;
        else
          ---snp_req2 <= nilreq;
          state := 0;
        end if;
      elsif state = 2 then
        if tmp_cache_req2(63 downto 63) = "1" then
          ---this belongs to the memory
          tomem2 <= "101" & tmp_cache_req2;
          state  := 5;
        elsif tmp_cache_req2(62 downto 61) = "00" then
          togfx2 <= "101" & tmp_cache_req2;
          state  := 6;
        elsif tmp_cache_req2(62 downto 61) = "01" then
          touart2 <= "101" & tmp_cache_req2;
          state   := 7;
        elsif tmp_cache_req2(62 downto 61) = "10" then
          tousb2 <= "101" & tmp_cache_req2;
          state  := 8;
        elsif tmp_cache_req2(62 downto 61) = "11" then
          toaudio2 <= "101" & tmp_cache_req2;
          state    := 9;
        end if;
      elsif state = 3 then
        if brs1_ack6 = '1' then
          bus_res1_6 <= (others => '0');
        end if;
      elsif state = 4 then
        if pwr_ack2 = '1' then
          ---pwr_req2<= "00000";
          state := 0;
        end if;
      elsif state = 5 then
        if mem_ack2 = '1' then
          state  := 0;
          tomem2 <= (others => '0');
        end if;
      elsif state = 6 then
        if gfx_ack2 = '1' then
          state  := 0;
          togfx2 <= (others => '0');
        end if;
      elsif state = 7 then
        if usb_ack2 = '1' then
          state  := 0;
          tousb2 <= (others => '0');
        end if;
      elsif state = 8 then
        if audio_ack2 = '1' then
          state    := 0;
          toaudio2 <= (others => '0');
        end if;
      end if;
    end if;
  end process;

end Behavioral;
