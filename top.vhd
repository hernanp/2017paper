library IEEE;
use ieee.std_logic_1164.all;
--use iEEE.std_logic_unsigned.all ;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.rand.all;
use work.test.all;

entity top is
  generic (
    constant DATA_WIDTH : positive := 73
    );
end top;

architecture tb of top is
  
-- Clock frequency and signal
  signal Clock : std_logic;
  constant tb_period : time := 10 ps;
  signal tb_clk : std_logic := '0';
  signal tb_sim_ended : std_logic := '0';

  signal reset                                                              : std_logic := '1';
  
  signal full_c1_u, full_c2_u, full_b_m                                     : std_logic;
  signal cpu_res1, cpu_res2, cpu_req1, cpu_req2                             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal bus_res1, bus_res2                                                 : std_logic_vector(552 downto 0);
  signal snp_hit1, snp_hit2                                             : std_logic;
  signal snp_req1, snp_req2                                             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal snp_res1, snp_res2                                             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal snp_req                                                          : std_logic_vector(75 downto 0);
  ---this should be DATA_WIDTH - 1
  signal snp_res                                                          : std_logic_vector(75 downto 0);
  signal snp_hit                                                          : std_logic;
  signal bus_req1, bus_req2                                                 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal memres, tomem                                                      : std_logic_vector(75 downto 0);
  signal full_crq1, full_srq1, full_brs1, full_wb1, full_srs1, full_crq2,
    full_brs2, full_wb2, full_srs2                                          : std_logic;
  ---signal full_mrs: std_logic;
  signal done1, done2                                                       : std_logic;
  signal mem_wb, wb_req1, wb_req2                                           : std_logic_vector(552 downto 0);
  signal wb_ack                                                             : std_logic;
  signal ic_pwr_req, ic_pwr_res                                             : std_logic_vector(4 downto 0);
  signal pwr_req_full                                                       : std_logic;

  signal gfx_b, togfx                 : std_logic_vector(75 downto 0);
  signal gfx_upreq, gfx_upres, gfx_wb : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal gfx_upreq_full, gfx_wb_ack   : std_logic;

  -- pwr
  signal pwr_gfx_req, pwr_gfx_res       : std_logic_vector(2 downto 0);
  signal pwr_audio_req, pwr_audio_res   : std_logic_vector(2 downto 0);
  signal pwr_usb_req, pwr_usb_res       : std_logic_vector(2 downto 0);
  signal pwr_uart_req, pwr_uart_res     : std_logic_vector(2 downto 0);
  
  signal audio_b, toaudio                   : std_logic_vector(53 downto 0);
  signal audio_upreq, audio_upres, audio_wb : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal audio_upreq_full, audio_wb_ack     : std_logic;

  signal usb_b, tousb                 : std_logic_vector(75 downto 0);
  signal usb_upreq, usb_upres, usb_wb : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal usb_upreq_full, usb_wb_ack   : std_logic;

  signal zero   : std_logic                     := '0';
  signal zero72 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal zero75 : std_logic_vector(75 downto 0) := (others => '0');
  signal uart_b, touart                  : std_logic_vector(75 downto 0);
  signal uart_upreq, uart_upres, uart_wb : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal uart_upreq_full, uart_wb_ack    : std_logic;

  signal up_snp_req, up_snp_res : std_logic_vector(75 downto 0);
  signal up_snp_hit           : std_logic;

  signal waddr      : std_logic_vector(31 downto 0);
  signal wlen       : std_logic_vector(9 downto 0);
  signal wsize      : std_logic_vector(9 downto 0);
  signal wvalid     : std_logic;
  signal wready     : std_logic;
  -- -write data channel
  signal wdata      : std_logic_vector(31 downto 0);
  signal wtrb       : std_logic_vector(3 downto 0);
  signal wlast      : std_logic;
  signal wdvalid    : std_logic;
  signal wdataready : std_logic;
  -- -write response channel
  signal wrready    : std_logic;
  signal wrvalid    : std_logic;
  signal wrsp       : std_logic_vector(1 downto 0);

  -- -read address channel
  signal raddr   : std_logic_vector(31 downto 0);
  signal rlen    : std_logic_vector(9 downto 0);
  signal rsize   : std_logic_vector(9 downto 0);
  signal rvalid  : std_logic;
  signal rready  : std_logic;
  -- -read data channel
  signal rdata   : std_logic_vector(31 downto 0);
  signal rstrb   : std_logic_vector(3 downto 0);
  signal rlast   : std_logic;
  signal rdvalid : std_logic;
  signal rdready : std_logic;
  signal rres    : std_logic_vector(1 downto 0);

  --GFX
  ---_gfx write address channel
  signal waddr_gfx      : std_logic_vector(31 downto 0);
  signal wlen_gfx       : std_logic_vector(9 downto 0);
  signal wsize_gfx      : std_logic_vector(9 downto 0);
  signal wvalid_gfx     : std_logic;
  signal wready_gfx     : std_logic;
  --_gfx-write data channel
  signal wdata_gfx      : std_logic_vector(31 downto 0);
  signal wtrb_gfx       : std_logic_vector(3 downto 0);
  signal wlast_gfx      : std_logic;
  signal wdvalid_gfx    : std_logic;
  signal wdataready_gfx : std_logic;
  --_gfx-write response channel
  signal wrready_gfx    : std_logic;
  signal wrvalid_gfx    : std_logic;
  signal wrsp_gfx       : std_logic_vector(1 downto 0);

  --_gfx-read address channel
  signal raddr_gfx   : std_logic_vector(31 downto 0);
  signal rlen_gfx    : std_logic_vector(9 downto 0);
  signal rsize_gfx   : std_logic_vector(9 downto 0);
  signal rvalid_gfx  : std_logic;
  signal rready_gfx  : std_logic;
  --_gfx-read data channel
  signal rdata_gfx   : std_logic_vector(31 downto 0);
  signal rstrb_gfx   : std_logic_vector(3 downto 0);
  signal rlast_gfx   : std_logic;
  signal rdvalid_gfx : std_logic;
  signal rdready_gfx : std_logic;
  signal rres_gfx    : std_logic_vector(1 downto 0);

  -- UART
  -- _uart-write address channel
  signal waddr_uart      : std_logic_vector(31 downto 0);
  signal wlen_uart       : std_logic_vector(9 downto 0);
  signal wsize_uart      : std_logic_vector(9 downto 0);
  signal wvalid_uart     : std_logic;
  signal wready_uart     : std_logic;
  --_uart-write data channel
  signal wdata_uart      : std_logic_vector(31 downto 0);
  signal wtrb_uart       : std_logic_vector(3 downto 0);
  signal wlast_uart      : std_logic;
  signal wdvalid_uart    : std_logic;
  signal wdataready_uart : std_logic;
  --_uart-write response channel
  signal wrready_uart    : std_logic;
  signal wrvalid_uart    : std_logic;
  signal wrsp_uart       : std_logic_vector(1 downto 0);

  --_uart-read address channel
  signal raddr_uart   : std_logic_vector(31 downto 0);
  signal rlen_uart    : std_logic_vector(9 downto 0);
  signal rsize_uart   : std_logic_vector(9 downto 0);
  signal rvalid_uart  : std_logic;
  signal rready_uart  : std_logic;
  --_uart-read data channel
  signal rdata_uart   : std_logic_vector(31 downto 0);
  signal rstrb_uart   : std_logic_vector(3 downto 0);
  signal rlast_uart   : std_logic;
  signal rdvalid_uart : std_logic;
  signal rdready_uart : std_logic;
  signal rres_uart    : std_logic_vector(1 downto 0);

  -- USB
  -- _usb-write address channel
  signal waddr_usb      : std_logic_vector(31 downto 0);
  signal wlen_usb       : std_logic_vector(9 downto 0);
  signal wsize_usb      : std_logic_vector(9 downto 0);
  signal wvalid_usb     : std_logic;
  signal wready_usb     : std_logic;
  --_usb-write data channel
  signal wdata_usb      : std_logic_vector(31 downto 0);
  signal wtrb_usb       : std_logic_vector(3 downto 0);
  signal wlast_usb      : std_logic;
  signal wdvalid_usb    : std_logic;
  signal wdataready_usb : std_logic;
  --_usb-write response channel
  signal wrready_usb    : std_logic;
  signal wrvalid_usb    : std_logic;
  signal wrsp_usb       : std_logic_vector(1 downto 0);

  --_usb-read address channel
  signal raddr_usb   : std_logic_vector(31 downto 0);
  signal rlen_usb    : std_logic_vector(9 downto 0);
  signal rsize_usb   : std_logic_vector(9 downto 0);
  signal rvalid_usb  : std_logic;
  signal rready_usb  : std_logic;
  --_usb-read data channel
  signal rdata_usb   : std_logic_vector(31 downto 0);
  signal rstrb_usb   : std_logic_vector(3 downto 0);
  signal rlast_usb   : std_logic;
  signal rdvalid_usb : std_logic;
  signal rdready_usb : std_logic;
  signal rres_usb    : std_logic_vector(1 downto 0);

  -- AUDIO
  --_audio-write address channel
  signal waddr_audio      : std_logic_vector(31 downto 0);
  signal wlen_audio       : std_logic_vector(9 downto 0);
  signal wsize_audio      : std_logic_vector(9 downto 0);
  signal wvalid_audio     : std_logic;
  signal wready_audio     : std_logic;
  --_audio-write data channel
  signal wdata_audio      : std_logic_vector(31 downto 0);
  signal wtrb_audio       : std_logic_vector(3 downto 0);
  signal wlast_audio      : std_logic;
  signal wdvalid_audio    : std_logic;
  signal wdataready_audio : std_logic;
  --_audio-write response channel
  signal wrready_audio    : std_logic;
  signal wrvalid_audio    : std_logic;
  signal wrsp_audio       : std_logic_vector(1 downto 0);

  --_audio-read address channel
  signal raddr_audio   : std_logic_vector(31 downto 0);
  signal rlen_audio    : std_logic_vector(9 downto 0);
  signal rsize_audio   : std_logic_vector(9 downto 0);
  signal rvalid_audio  : std_logic;
  signal rready_audio  : std_logic;
  --_audio-read data channel
  signal rdata_audio   : std_logic_vector(31 downto 0);
  signal rstrb_audio   : std_logic_vector(3 downto 0);
  signal rlast_audio   : std_logic;
  signal rdvalid_audio : std_logic;
  signal rdready_audio : std_logic;
  signal rres_audio    : std_logic_vector(1 downto 0);

begin
  cpu1 : entity work.cpu(Behavioral) port map(
    reset   => reset,
    Clock   => Clock,
    cpu_id  => 1,
    cpu_res_in => cpu_res1,
    cpu_req_out => cpu_req1,
    full_c  => full_c1_u
   --done    => done1
    );

  cpu2 : entity work.cpu(Behavioral) port map(
    reset   => reset,
    Clock   => Clock,
    cpu_id  => 2,
    cpu_res_in => cpu_res2,
    cpu_req_out => cpu_req2,
    full_c  => full_c2_u
   --done    => done2
    );

  cache1 : entity work.l1_cache(Behavioral) port map(
    Clock       => Clock,
    reset       => reset,

    cpu_req_in  => cpu_req1,
    cpu_res_out => cpu_res1,
    -- o - cpu req fifo full

    snp_req_in  => snp_req1, -- snoop req from cache 2
    snp_hit_out => snp_hit1,
    snp_res_out => snp_res1,

    up_snp_req_in  => up_snp_req, -- upstream snoop req 
    up_snp_hit_out => up_snp_hit,
    up_snp_res_out => up_snp_res,

    snp_req_out => snp_req2, -- fwd snp req to other cache
    snp_hit_in => snp_hit2,
    snp_res_in => snp_res2,

    ----------------------------------------------------------
    dn_snp_req_out  => bus_req1, -- snp req to ic
    dn_snp_res_in   => bus_res1, -- snp resp from ic    

    wb_req      => wb_req1, -- TODO what is it doing?
                            -- is it supposed be implemented outside cache?
    
    bsf_full    => full_brs1, -- bus resp fifo full
    srf_full   => full_srs2, 
    crf_full    => full_c1_u,
	 
    full_crq    => full_crq1,
    full_wb     => full_wb1,  -- TODO are these outputs not implemented yet?
    full_srs    => full_srs1
    );

  cache2 : entity work.l1_cache(Behavioral) port map(
    Clock       => Clock,
    reset       => reset,

    cpu_req_in  => cpu_req2,
    cpu_res_out => cpu_res2,

    snp_req_out => snp_req1,
    snp_hit_in  => snp_hit1,
    snp_res_in  => snp_res1,
    
    snp_req_in   => snp_req2,
    snp_hit_out  => snp_hit2,
    snp_res_out  => snp_res2,

    dn_snp_req_out  => bus_req2,
    dn_snp_res_in   => bus_res2,

    up_snp_req_in   => zero75,   -- TODO not implemented yet
    up_snp_res_out   => zero75,
    --up_snp_hit_out => zero,

    wb_req       => wb_req2,

    -- full flags of fifo queues
    crf_full     => full_c2_u, -- o, cpu req fifo full
    bsf_full     => full_brs2, -- o - bus resp fifo full
    srf_full     => full_srs1,
    --full_srq    => zero,
    full_crq     => full_crq2,
    full_wb      => full_wb2,
    full_srs     => full_srs2
    );

  power : entity work.pwr(Behavioral) port map(
    Clock     => Clock,
    reset     => reset,
    
    req_in        => ic_pwr_req,
    res_out       => ic_pwr_res,
    
    audio_req_out  => pwr_audio_req,
    audio_res_in  => pwr_audio_res,
    
    usb_req_out    => pwr_usb_req,
    usb_res_in    => pwr_usb_res,
    
    uart_req_out   => pwr_uart_req,
    uart_res_in   => pwr_uart_res,

    full_preq => pwr_req_full,

    gfx_req_out    => pwr_gfx_req,
    gfx_res_in    => pwr_gfx_res
    );

  interconnect : entity work.ic(Behavioral) port map(
    gfx_upreq_in     => gfx_upreq,
    gfx_upres_out    => gfx_upres,
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
    -- write
    waddr            => waddr,
    wlen             => wlen,
    wsize            => wsize,
    wvalid           => wvalid,
    wready           => wready,
    wdata            => wdata,
    wtrb             => wtrb,
    wlast            => wlast,
    wdvalid          => wdvalid,
    wdataready       => wdataready,
    wrready          => wrready,
    wrvalid_out          => wrvalid,
    wrsp             => wrsp,
    -- read
    raddr            => raddr,
    rlen             => rlen,
    rsize            => rsize,
    rvalid_out       => rvalid,
    rready           => rready,
    rdata            => rdata,
    rstrb            => rstrb,
    rlast            => rlast,
    rdvalid_in       => rdvalid,
    rdready          => rdready,
    rres             => rres,

    waddr_gfx        => waddr_gfx,
    wlen_gfx         => wlen_gfx,
    wsize_gfx        => wsize_gfx,
    wvalid_gfx       => wvalid_gfx,
    wready_gfx       => wready,
    wdata_gfx        => wdata_gfx,
    wtrb_gfx         => wtrb_gfx,
    wlast_gfx        => wlast_gfx,
    wdvalid_gfx      => wdvalid_gfx,
    wdataready_gfx   => wdataready_gfx,
    wrready_gfx      => wrready_gfx,
    wrvalid_gfx      => wrvalid_gfx,
    wrsp_gfx         => wrsp_gfx,

    raddr_gfx        => raddr_gfx,
    rlen_gfx         => rlen_gfx,
    rsize_gfx        => rsize_gfx,
    rvalid_gfx       => rvalid_gfx,
    rready_gfx       => rready_gfx,
    rdata_gfx        => rdata_gfx,
    rstrb_gfx        => rstrb_gfx,
    rlast_gfx        => rlast_gfx,
    rdvalid_gfx      => rdvalid_gfx,
    rdready_gfx      => rdready_gfx,
    rres_gfx         => rres_gfx,
    waddr_uart       => waddr_uart,
    wlen_uart        => wlen_uart,
    wsize_uart       => wsize_uart,
    wvalid_uart      => wvalid_uart,
    wready_uart      => wready_uart,
    wdata_uart       => wdata_uart,
    wtrb_uart        => wtrb_uart,
    wlast_uart       => wlast_uart,
    wdvalid_uart     => wdvalid_uart,
    wdataready_uart  => wdataready_uart,
    wrready_uart     => wrready_uart,
    wrvalid_uart     => wrvalid_uart,
    wrsp_uart        => wrsp_uart,
    raddr_uart       => raddr_uart,
    rlen_uart        => rlen_uart,
    rsize_uart       => rsize_uart,
    rvalid_uart      => rvalid_uart,
    rready_uart      => rready_uart,
    rdata_uart       => rdata_uart,
    rstrb_uart       => rstrb_uart,
    rlast_uart       => rlast_uart,
    rdvalid_uart     => rdvalid_uart,
    rdready_uart     => rdready_uart,
    rres_uart        => rres_uart,
    waddr_usb        => waddr_usb,
    wlen_usb         => wlen_usb,
    wsize_usb        => wsize_usb,
    wvalid_usb       => wvalid_usb,
    wready_usb       => wready_usb,
    wdata_usb        => wdata_usb,
    wtrb_usb         => wtrb_usb,
    wlast_usb        => wlast_usb,
    wdvalid_usb      => wdvalid_usb,
    wdataready_usb   => wdataready_usb,
    wrready_usb      => wrready_usb,
    wrvalid_usb      => wrvalid_usb,
    wrsp_usb         => wrsp_usb,
    raddr_usb        => raddr_usb,
    rlen_usb         => rlen_usb,
    rsize_usb        => rsize_usb,
    rvalid_usb       => rvalid_usb,
    rready_usb       => rready_usb,
    rdata_usb        => rdata_usb,
    rstrb_usb        => rstrb_usb,
    rlast_usb        => rlast_usb,
    rdvalid_usb      => rdvalid_usb,
    rdready_usb      => rdready_usb,
    rres_usb         => rres_usb,
    waddr_audio      => waddr_audio,
    wlen_audio       => wlen_audio,
    wsize_audio      => wsize_audio,
    wvalid_audio     => wvalid_audio,
    wready_audio     => wready_audio,
    wdata_audio      => wdata_audio,
    wtrb_audio       => wtrb_audio,
    wlast_audio      => wlast_audio,
    wdvalid_audio    => wdvalid_audio,
    wdataready_audio => wdataready_audio,
    wrready_audio    => wrready_audio,
    wrvalid_audio    => wrvalid_audio,
    wrsp_audio       => wrsp_audio,
    raddr_audio      => raddr_audio,
    rlen_audio       => rlen_audio,
    rsize_audio      => rsize_audio,
    rvalid_audio     => rvalid_audio,
    rready_audio     => rready_audio,
    rdata_audio      => rdata_audio,
    rstrb_audio      => rstrb_audio,
    rlast_audio      => rlast_audio,
    rdvalid_audio    => rdvalid_audio,
    rdready_audio    => rdready_audio,
    rres_audio       => rres_audio,
    Clock            => Clock,
    reset            => reset,
    cache1_req_in    => bus_req1,
    cache2_req_in    => bus_req2,
    wb_req1          => wb_req1,
    wb_req2          => wb_req2,
    bus_res1_out     => bus_res1,
    bus_res2_out     => bus_res2,
    up_snp_req_out   => up_snp_req,
    up_snp_res_in    => up_snp_res,
    up_snp_hit_in    => up_snp_hit,
    full_srq1        => full_srq1,
    full_wb1         => full_wb1,
    full_srs1        => full_srs1,
    full_wb2         => full_wb2,
    pwr_req_out      => ic_pwr_req,
    pwr_res_in       => ic_pwr_res,
    pwr_req_full     => pwr_req_full
    );

  gfx : entity work.gfx(Behavioral) port map(
    wrvalid    => wrvalid_gfx,
    wrsp       => wrsp_gfx,
    raddr      => raddr_gfx,
    rlen       => rlen_gfx,
    rsize      => rsize_gfx,
    rvalid     => rvalid_gfx,
    rready     => rready_gfx,
    --_gfx-read data channel
    rdata      => rdata_gfx,
    rstrb      => rstrb_gfx,
    rlast      => rlast_gfx,
    rdvalid    => rdvalid_gfx,
    rdready    => rdready_gfx,
    rres       => rres_gfx,
    -- write
    waddr      => waddr_gfx,
    wlen       => wlen_gfx,
    wsize      => wsize_gfx,
    wvalid     => wvalid_gfx,
    wdata      => wdata_gfx,
    wready     => wready_gfx,
    wtrb       => wtrb_gfx,
    wlast      => wlast_gfx,
    wdataready => wdataready_gfx,
    wdvalid    => wdvalid_gfx,
    wrready    => wrready_gfx,

    upres_in   => gfx_upres,
    upreq_out  => gfx_upreq,
    upreq_full => gfx_upreq_full,

    Clock       => Clock,
    reset       => reset,

    pwr_req_in  => pwr_gfx_req,
    pwr_res_out => pwr_gfx_res
    );

  audio : entity work.audio(Behavioral) port map(
    wrvalid    => wrvalid_audio,
    wrsp       => wrsp_audio,
    raddr      => raddr_audio,
    rlen       => rlen_audio,
    rsize      => rsize_audio,
    rvalid     => rvalid_audio,
    rready     => rready_audio,
    --_audio-read data channel
    rdata      => rdata_audio,
    rstrb      => rstrb_audio,
    rlast      => rlast_audio,
    rdvalid    => rdvalid_audio,
    rdready    => rdready_audio,
    rres       => rres_audio,
    waddr      => waddr_audio,
    wlen       => wlen_audio,
    wsize      => wsize_audio,
    wvalid     => wvalid_audio,
    wdata      => wdata_audio,
    wready     => wready_audio,
    wtrb       => wtrb_audio,
    wlast      => wlast_audio,
    wdataready => wdataready_audio,
    wdvalid    => wdvalid_audio,
    wrready    => wrready_audio,
    upres      => audio_upres,
    upreq      => audio_upreq,
    upreq_full => audio_upreq_full,

    Clock      => Clock,
    reset      => reset,
    pwr_req_in  => pwr_audio_req,
    pwr_res_out => pwr_audio_res
    );

  usb : entity work.usb(Behavioral) port map(
    wrvalid    => wrvalid_usb,
    wrsp       => wrsp_usb,
    raddr      => raddr_usb,
    rlen       => rlen_usb,
    rsize      => rsize_usb,
    rvalid     => rvalid_usb,
    rready     => rready_usb,
    --_usb-read data channel
    rdata      => rdata_usb,
    rstrb      => rstrb_usb,
    rlast      => rlast_usb,
    rdvalid    => rdvalid_usb,
    rdready    => rdready_usb,
    rres       => rres_usb,
    waddr      => waddr_usb,
    wlen       => wlen_usb,
    wsize      => wsize_usb,
    wvalid     => wvalid_usb,
    wdata      => wdata_usb,
    wready     => wready_usb,
    wtrb       => wtrb_usb,
    wlast      => wlast_usb,
    wdataready => wdataready_usb,
    wdvalid    => wdvalid_usb,
    wrready    => wrready_usb,
    upres      => usb_upres,
    upreq      => usb_upreq,
    upreq_full => usb_upreq_full,

    Clock      => Clock,
    reset      => reset,
    pwr_req_in     => pwr_usb_req,
    pwr_res_out     => pwr_usb_res
    );

  uart : entity work.uart(Behavioral) port map(
    wrvalid    => wrvalid_uart,
    wrsp       => wrsp_uart,
    raddr      => raddr_uart,
    rlen       => rlen_uart,
    rsize      => rsize_uart,
    rvalid     => rvalid_uart,
    rready     => rready_uart,
    --_uart-read data channel
    rdata      => rdata_uart,
    rstrb      => rstrb_uart,
    rlast      => rlast_uart,
    rdvalid    => rdvalid_uart,
    rdready    => rdready_uart,
    rres       => rres_uart,
    waddr      => waddr_uart,
    wlen       => wlen_uart,
    wsize      => wsize_uart,
    wvalid     => wvalid_uart,
    wdata      => wdata_uart,
    wready     => wready_uart,
    wtrb       => wtrb_uart,
    wlast      => wlast_uart,
    wdataready => wdataready_uart,
    wdvalid    => wdvalid_uart,
    wrready    => wrready_uart,
    upres      => uart_upres,
    upreq      => uart_upreq,
    upreq_full => uart_upreq_full,

    Clock      => Clock,
    reset      => reset,
    
    pwr_req_in  => pwr_uart_req,
    pwr_res_out => pwr_uart_res
    );

  mem : entity work.Memory(Behavioral) port map(
    Clock      => Clock,
    reset      => reset,
    waddr      => waddr,
    wlen       => wlen,
    wsize      => wsize,
    wvalid     => wvalid,
    wready     => wready,
    wdata      => wdata,
    wtrb       => wtrb,
    wlast      => wlast,
    wdvalid    => wdvalid,
    wdataready => wdataready,
    wrready    => wrready,
    wrvalid    => wrvalid,
    wrsp       => wrsp,
    raddr      => raddr,
    rlen       => rlen,
    rsize      => rsize,
    rvalid_in  => rvalid,
    rready     => rready,
    rdata      => rdata,
    rstrb      => rstrb,
    rlast      => rlast,
    rdvalid_out => rdvalid,
    rdready    => rdready,
    rres_out   => rres
    );

  -- Clock generation, starts at 0
  tb_clk <= not tb_clk after tb_period/2 when tb_sim_ended /= '1' else '0';
  Clock <= tb_clk;

  --log_up_snp : process(tb_clk)
  --  variable l : line;
  --  constant SEP : String(1 to 1) := ",";
  --  file log_file : TEXT open write_mode is "up_snp.log";
  --begin
  --  if rising_edge(tb_clk) then
  --    write(l, gfx_upreq);
  --    write(l, SEP);
  --    write(l, up_snp_req);
  --    write(l, SEP);
  --    write(l, snp_req2);
  --    write(l, SEP);
  --    write(l, snp_res2);
  --    write(l, SEP);
  --    write(l, up_snp_res);
  --    write(l, SEP);
  --    write(l, rvalid);
  --    write(l, SEP);
  --    write(l, rres);
  --    writeline(log_file, l); 
  --  end if;
  --end process;

  --rand_template: process(tb_clk)
  --  variable b : boolean := true;
  --  variable max : positive := 255;
  --begin
  --  if b then
  --    report integer'image(time'pos(now));
  --    report integer'image(to_int(max'instance_name));
  --    report integer'image(rand_int(max,to_int(max'instance_name)));
  --    b := false;
  --  end if;
  --end process;
  
  logger : process(tb_clk)
    file trace_file : TEXT open write_mode is "trace1.txt";
    variable l : line;
    constant SEP : String(1 to 1) := ",";
  begin
    if GEN_TRACE1 then
      if rising_edge(tb_clk) then
        ---- cpu
        write(l, cpu_req1);
        write(l, SEP);
        write(l, cpu_res1);
        write(l, SEP);
        write(l, cpu_req2);
        write(l, SEP);
        write(l, cpu_res2);
        write(l, SEP);

        ---- snp
        write(l, snp_req1);
        write(l, SEP);
        write(l, snp_res1);
        write(l, SEP);
        write(l, snp_hit1);
        write(l, SEP);

        write(l, snp_req2);
        write(l, SEP);
        write(l, snp_res2);
        write(l, SEP);
        write(l, snp_hit2);
        write(l, SEP);

        ---- up_snp
        write(l, up_snp_req);
        write(l, SEP);
        write(l, up_snp_res);
        write(l, SEP);
        write(l, up_snp_hit);
        write(l, SEP);

        ---- cache_req
        write(l, bus_req1);
        write(l, SEP);
        write(l, bus_res1);
        write(l, SEP);

        write(l, bus_req2);
        write(l, SEP);
        write(l, bus_res2);
        write(l, SEP);
        
        ---- ic
        ---- read
        write(l, rvalid);
        write(l, SEP);
        write(l, rdvalid);
        write(l, SEP);
        ---- write
        write(l, wvalid);
        write(l, SEP);
        write(l, waddr);
        write(l, SEP);
        write(l, wrvalid);
        write(l, SEP);

        ---- gfx
        ---- read
        write(l, rvalid_gfx);
        write(l, SEP);
        write(l, rdvalid_gfx);
        write(l, SEP);
        ---- write
        write(l, wvalid_gfx);
        write(l, SEP);
        write(l, waddr_gfx);
        write(l, SEP);
        write(l, wrvalid_gfx);
        write(l, SEP);

        ---- uart
        ---- read
        write(l, rvalid_uart);
        write(l, SEP);
        write(l, rdvalid_uart);
        write(l, SEP);
        ---- write
        write(l, wvalid_uart);
        write(l, SEP);
        write(l, waddr_uart);
        write(l, SEP);
        write(l, wrvalid_uart);
        write(l, SEP);

        ---- usb
        ---- read
        write(l, rvalid_usb);
        write(l, SEP);
        write(l, rdvalid_usb);
        write(l, SEP);
        ---- write
        write(l, wvalid_usb);
        write(l, SEP);
        write(l, waddr_usb);
        write(l, SEP);
        write(l, wrvalid_usb);
        write(l, SEP);

        ---- audio
        ---- read
        write(l, rvalid_audio);
        write(l, SEP);
        write(l, rdvalid_audio);
        write(l, SEP);
        ---- write
        write(l, wvalid_audio);
        write(l, SEP);
        write(l, waddr_audio);
        write(l, SEP);
        write(l, wrvalid_audio);
        write(l, SEP);
        
        ---- pwr
        ---- TODO not yet implemented

        -- upreq and upres
        write(l, gfx_upreq);
        write(l, SEP);
        write(l, gfx_upres);
        write(l, SEP);
        
        write(l, uart_upreq);
        write(l, SEP);
        write(l, uart_upres);
        write(l, SEP);
        
        write(l, usb_upreq);
        write(l, SEP);
        write(l, usb_upres);
        write(l, SEP);
        
        write(l, audio_upreq);
        write(l, SEP);
        write(l, audio_upres);
        
        writeline(trace_file, l); 
      end if;
    end if;
  end process;
  
  stimuli : process
  begin
   
    reset <= '1';
    wait for 15 ps;
    reset <= '0';
    
    wait;
  end process;
end tb;
