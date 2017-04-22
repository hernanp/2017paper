library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.defs.all;
use work.rand.all;
use work.test.all;

entity top is
end top;

architecture tb of top is
  
-- Clock frequency and signal
  signal Clock : std_logic;
  constant tb_period : time := 10 ps;
  signal tb_clk : std_logic := '0';
  signal tb_sim_ended : std_logic := '0';

  signal reset : std_logic := '1';
  
  signal full_c1_u, full_c2_u, full_b_m : std_logic;
  signal cpu_res1, cpu_res2, cpu_req1, cpu_req2 : MSG_T;
  signal bus_res1, bus_res2 : std_logic_vector(552 downto 0);
  signal snp_hit1, snp_hit2 : std_logic;
  signal snp_req1, snp_req2 : MSG_T;
  signal snp_res1, snp_res2 : MSG_T;
  signal snp_req            : WMSG_T;
  ---this should be DATA_WIDTH - 1
  signal snp_res : WMSG_T;
  signal snp_hit : std_logic;
  signal bus_req1, bus_req2 : MSG_T;
  signal memres, tomem      : WMSG_T;
  signal full_crq1, full_srq1, full_brs1,
         full_wb1, full_srs1, full_crq2,
         full_brs2, full_wb2, full_srs2 : std_logic;
  ---signal full_mrs: std_logic;
  signal done1, done2                   : std_logic;
  signal mem_wb, wb_req1, wb_req2       : std_logic_vector(552 downto 0);
  signal wb_ack                         : std_logic;
  signal ic_pwr_req : MSG_T;
  signal ic_pwr_res : MSG_T;
  signal pwr_req_full                   : std_logic;

  signal gfx_b, togfx                 : WMSG_T;
  signal gfx_upreq, gfx_upres, gfx_wb : MSG_T;
  signal gfx_upreq_full, gfx_wb_ack   : std_logic;

  -- pwr
  signal pwr_gfx_req, pwr_gfx_res       : MSG_T;
  signal pwr_audio_req, pwr_audio_res   : MSG_T;
  signal pwr_usb_req, pwr_usb_res       : MSG_T;
  signal pwr_uart_req, pwr_uart_res     : MSG_T;
  
  signal audio_b, toaudio                   : std_logic_vector(53 downto 0);
  signal audio_upreq, audio_upres, audio_wb : MSG_T;
  signal audio_upreq_full, audio_wb_ack     : std_logic;

  signal usb_b, tousb                 : WMSG_T;
  signal usb_upreq, usb_upres, usb_wb : MSG_T;
  signal usb_upreq_full, usb_wb_ack   : std_logic;

  signal zero   : std_logic := '0';
  signal zero72 : MSG_T := (others => '0');
  signal zero75 : WMSG_T := (others => '0');
  
  signal uart_b, touart                  : WMSG_T;
  signal uart_upreq, uart_upres, uart_wb : MSG_T;
  signal uart_upreq_full, uart_wb_ack    : std_logic;

  signal up_snp_req, up_snp_res : WMSG_T;
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

  signal cpu1_pwr_req, cpu1_pwr_res, cpu2_pwr_req, cpu2_pwr_res : MSG_T;
  
begin
  cpu1 : entity work.cpu(rtl) port map(
    reset     => reset,
    Clock     => Clock,
    cpu_id_i  => 1,
    cpu_res_i => cpu_res1,
    cpu_req_o => cpu_req1,
    full_c_i  => full_c1_u
   --done    => done1
    );

  cpu2 : entity work.cpu(rtl) port map(
    reset     => reset,
    Clock     => Clock,
    cpu_id_i  => 2,
    cpu_res_i => cpu_res2,
    cpu_req_o => cpu_req2,
    full_c_i  => full_c2_u
   --done    => done2
    );

  ----proc1 : entity work.proc(rtl) port map(
  ----  reset => reset,
  ----  clock => clock,
  ----  -- cpu ports
  ----  proc_id_i => 1,
  ----  cpu_req_dbg_o => cpu_req1,
  ----  -- cache ports
  ----  cpu_res_o => cpu_res1,

  ----  snp_req_i  => snp_req1, -- snoop req from cache 2
  ----  snp_hit_o => snp_hit1,
  ----  snp_res_o => snp_res1,

  ----  up_snp_req_i  => up_snp_req, -- upstream snoop req 
  ----  up_snp_hit_o => up_snp_hit,
  ----  up_snp_res_o => up_snp_res,

  ----  snp_req_o => snp_req2, -- fwd snp req to other cache
  ----  snp_hit_i => snp_hit2,
  ----  snp_res_i => snp_res2,

  ----  ----------------------------------------------------------
  ----  dn_snp_req_o  => bus_req1, -- snp req to ic
  ----  dn_snp_res_i   => bus_res1, -- snp resp from ic    

  ----  wb_req_o      => wb_req1, -- TODO what is it doing?
  ----                          -- is it supposed be implemented outside cache?
    
  ----  bsf_full_o    => full_brs1, -- bus resp fifo full
  ----  srf_full_o    => full_srs2, 
  ----  crf_full_o    => full_c1_u,
	 
  ----  full_crq_i    => full_crq1,
  ----  full_wb_i     => full_wb1,  -- TODO are these outputs not implemented yet?
  ----  full_srs_i    => full_srs1
  ----  );
  
  cache1 : entity work.l1_cache(rtl) port map(
    Clock       => Clock,
    reset       => reset,

    cpu_req_i  => cpu_req1,
    cpu_res_o => cpu_res1,
    -- o - cpu req fifo full

    snp_req_i  => snp_req1, -- snoop req from cache 2
    snp_hit_o => snp_hit1,
    snp_res_o => snp_res1,

    up_snp_req_i  => up_snp_req, -- upstream snoop req 
    up_snp_hit_o => up_snp_hit,
    up_snp_res_o => up_snp_res,

    snp_req_o => snp_req2, -- fwd snp req to other cache
    snp_hit_i => snp_hit2,
    snp_res_i => snp_res2,

    bus_req_o  => bus_req1, -- mem or pwr req to ic
    bus_res_i   => bus_res1, -- mem or pwr resp from ic    

    wb_req_o      => wb_req1, -- TODO what is it doing?
                            -- is it supposed be implemented outside cache?
    
    bsf_full_o    => full_brs1, -- bus resp fifo full
    srf_full_o    => full_srs2, 
    crf_full_o    => full_c1_u,
	 
    full_crq_i    => full_crq1,
    full_wb_i     => full_wb1,  -- TODO are these outputs not implemented yet?
    full_srs_i    => full_srs1
    );

  cache2 : entity work.l1_cache(rtl) port map(
    Clock       => Clock,
    reset       => reset,

    cpu_req_i  => cpu_req2,
    cpu_res_o => cpu_res2,

    snp_req_o => snp_req1,
    snp_hit_i  => snp_hit1,
    snp_res_i  => snp_res1,
    
    snp_req_i   => snp_req2,
    snp_hit_o  => snp_hit2,
    snp_res_o  => snp_res2,

    bus_req_o  => bus_req2,
    bus_res_i   => bus_res2,

    up_snp_req_i   => zero75,   -- TODO not implemented yet
    up_snp_res_o   => zero75,
    --up_snp_hit_out => zero,

    wb_req_o       => wb_req2,

    -- full flags of fifo queues
    crf_full_o     => full_c2_u, -- o, cpu req fifo full
    bsf_full_o     => full_brs2, -- o - bus resp fifo full
    srf_full_o     => full_srs1,
    --full_srq    => zero,
    full_crq_i     => full_crq2,
    full_wb_i      => full_wb2,
    full_srs_i     => full_srs2
    );

  power : entity work.pwr(rtl) port map(
    Clock     => Clock,
    reset     => reset,
    
    req_i        => ic_pwr_req,
    res_o       => ic_pwr_res,
    
    audio_req_o  => pwr_audio_req,
    audio_res_i  => pwr_audio_res,
    
    usb_req_o    => pwr_usb_req,
    usb_res_i    => pwr_usb_res,
    
    uart_req_o   => pwr_uart_req,
    uart_res_i   => pwr_uart_res,

    full_preq => pwr_req_full,

    gfx_req_o    => pwr_gfx_req,
    gfx_res_i    => pwr_gfx_res
    );

  interconnect : entity work.ic(rtl) port map(
    Clock            => Clock,
    reset            => reset,
    
    gfx_upreq_i      => gfx_upreq,
    gfx_upres_o      => gfx_upres,
    gfx_upreq_full_o => gfx_upreq_full,
    
    audio_upreq_i      => audio_upreq,
    audio_upres_o      => audio_upres,
    audio_upreq_full_o => audio_upreq_full,

    usb_upreq_i        => usb_upreq,
    usb_upres_o        => usb_upres,
    usb_upreq_full_o   => usb_upreq_full,

    uart_upreq_i       => uart_upreq,
    uart_upres_o       => uart_upres,
    uart_upreq_full_o  => uart_upreq_full,

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
    wrvalid_o      => wrvalid,
    wrsp             => wrsp,
    -- read
    raddr            => raddr,
    rlen             => rlen,
    rsize            => rsize,
    rvalid_o       => rvalid,
    rready           => rready,
    rdata            => rdata,
    rstrb            => rstrb,
    rlast            => rlast,
    rdvalid_i       => rdvalid,
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

    up_snp_res_i     => up_snp_res,
    up_snp_hit_i     => up_snp_hit,

    cache1_req_i     => bus_req1,
    cache2_req_i     => bus_req2,

    pwr_res_i        => ic_pwr_res,
    
    wb_req1_i        => wb_req1,
    wb_req2_i        => wb_req2,
    pwr_req_full_i   => pwr_req_full,

    full_snp_req1_i  => full_srq1,
    
    bus_res1_o     => bus_res1,
    bus_res2_o     => bus_res2,
    up_snp_req_o   => up_snp_req,

    full_wb1_o         => full_wb1,
    full_srs1_o        => full_srs1,
    full_wb2_o         => full_wb2,
     --full_mrs_o
    
    pwr_req_o        => ic_pwr_req
    );

  gfx : entity work.peripheral(rtl) port map(
    Clock       => Clock,
    reset       => reset,
    
    -- write address channel
    waddr_i      => waddr_gfx,
    wlen_i       => wlen_gfx,
    wsize_i      => wsize_gfx,
    wvalid_i     => wvalid_gfx,
    wready_o     => wready_gfx,
    -- write data channel
    wdata_i      => wdata_gfx,
    wtrb_i       => wtrb_gfx,
    wlast_i      => wlast_gfx,
    wdvalid_i    => wdvalid_gfx,
    wdataready_o => wdataready_gfx,
    -- write response channel
    wrready_i    => wrready_gfx,
    wrvalid_o    => wrvalid_gfx,
    wrsp_o       => wrsp_gfx,

    -- read address channel
    raddr_i      => raddr_gfx,
    rlen_i       => rlen_gfx,
    rsize_i      => rsize_gfx,
    rvalid_i     => rvalid_gfx,
    rready_o     => rready_gfx,
    -- read data channel
    rdata_o      => rdata_gfx,
    rstrb_o      => rstrb_gfx,
    rlast_o      => rlast_gfx,
    rdvalid_o    => rdvalid_gfx,
    rdready_i    => rdready_gfx,
    rres_o       => rres_gfx,

    -- up snp
    upres_i      => gfx_upres,
    upreq_o      => gfx_upreq,
    upreq_full_i => gfx_upreq_full,

    -- power
    pwr_req_i    => pwr_gfx_req,
    pwr_res_o    => pwr_gfx_res
    );

  audio : entity work.peripheral(rtl) port map(
    Clock       => Clock,
    reset       => reset,
    
    -- write address channel
    waddr_i      => waddr_audio,
    wlen_i       => wlen_audio,
    wsize_i      => wsize_audio,
    wvalid_i     => wvalid_audio,
    wready_o     => wready_audio,
    -- write data channel
    wdata_i      => wdata_audio,
    wtrb_i       => wtrb_audio,
    wlast_i      => wlast_audio,
    wdvalid_i    => wdvalid_audio,
    wdataready_o => wdataready_audio,
    -- write response channel
    wrready_i    => wrready_audio,
    wrvalid_o    => wrvalid_audio,
    wrsp_o       => wrsp_audio,

    -- read address channel
    raddr_i      => raddr_audio,
    rlen_i       => rlen_audio,
    rsize_i      => rsize_audio,
    rvalid_i     => rvalid_audio,
    rready_o     => rready_audio,
    -- read data channel
    rdata_o      => rdata_audio,
    rstrb_o      => rstrb_audio,
    rlast_o      => rlast_audio,
    rdvalid_o    => rdvalid_audio,
    rdready_i    => rdready_audio,
    rres_o       => rres_audio,

    -- up snp
    upres_i      => audio_upres,
    upreq_o      => audio_upreq,
    upreq_full_i => audio_upreq_full,

    -- power
    pwr_req_i    => pwr_audio_req,
    pwr_res_o    => pwr_audio_res
    );

  usb : entity work.peripheral(rtl) port map(
    Clock       => Clock,
    reset       => reset,
    
    -- write address channel
    waddr_i      => waddr_usb,
    wlen_i       => wlen_usb,
    wsize_i      => wsize_usb,
    wvalid_i     => wvalid_usb,
    wready_o     => wready_usb,
    -- write data channel
    wdata_i      => wdata_usb,
    wtrb_i       => wtrb_usb,
    wlast_i      => wlast_usb,
    wdvalid_i    => wdvalid_usb,
    wdataready_o => wdataready_usb,
    -- write response channel
    wrready_i    => wrready_usb,
    wrvalid_o    => wrvalid_usb,
    wrsp_o       => wrsp_usb,

    -- read address channel
    raddr_i      => raddr_usb,
    rlen_i       => rlen_usb,
    rsize_i      => rsize_usb,
    rvalid_i     => rvalid_usb,
    rready_o     => rready_usb,
    -- read data channel
    rdata_o      => rdata_usb,
    rstrb_o      => rstrb_usb,
    rlast_o      => rlast_usb,
    rdvalid_o    => rdvalid_usb,
    rdready_i    => rdready_usb,
    rres_o       => rres_usb,

    -- up snp
    upres_i      => usb_upres,
    upreq_o      => usb_upreq,
    upreq_full_i => usb_upreq_full,

    -- power
    pwr_req_i    => pwr_usb_req,
    pwr_res_o    => pwr_usb_res
    );

  uart : entity work.peripheral(rtl) port map(
    Clock       => Clock,
    reset       => reset,
    
    -- write address channel
    waddr_i      => waddr_uart,
    wlen_i       => wlen_uart,
    wsize_i      => wsize_uart,
    wvalid_i     => wvalid_uart,
    wready_o     => wready_uart,
    -- write data channel
    wdata_i      => wdata_uart,
    wtrb_i       => wtrb_uart,
    wlast_i      => wlast_uart,
    wdvalid_i    => wdvalid_uart,
    wdataready_o => wdataready_uart,
    -- write response channel
    wrready_i    => wrready_uart,
    wrvalid_o    => wrvalid_uart,
    wrsp_o       => wrsp_uart,

    -- read address channel
    raddr_i      => raddr_uart,
    rlen_i       => rlen_uart,
    rsize_i      => rsize_uart,
    rvalid_i     => rvalid_uart,
    rready_o     => rready_uart,
    -- read data channel
    rdata_o      => rdata_uart,
    rstrb_o      => rstrb_uart,
    rlast_o      => rlast_uart,
    rdvalid_o    => rdvalid_uart,
    rdready_i    => rdready_uart,
    rres_o       => rres_uart,

    -- up snp
    upres_i      => uart_upres,
    upreq_o      => uart_upreq,
    upreq_full_i => uart_upreq_full,

    -- power
    pwr_req_i    => pwr_uart_req,
    pwr_res_o    => pwr_uart_res
    );

  mem : entity work.Memory(rtl) port map(
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

  -- -- Clock generation, starts at 0
  tb_clk <= not tb_clk after tb_period/2 when tb_sim_ended /= '1' else '0';
  Clock <= tb_clk;
  
  ----log_up_snp : process(tb_clk)
  ----  variable l : line;
  ----  constant SEP : String(1 to 1) := ",";
  ----  file log_file : TEXT open write_mode is "up_snp.log";
  ----begin
  ----  if rising_edge(tb_clk) then
  ----    write(l, gfx_upreq);
  ----    write(l, SEP);
  ----    write(l, up_snp_req);
  ----    write(l, SEP);
  ----    write(l, snp_req2);
  ----    write(l, SEP);
  ----    write(l, snp_res2);
  ----    write(l, SEP);
  ----    write(l, up_snp_res);
  ----    write(l, SEP);
  ----    write(l, rvalid);
  ----    write(l, SEP);
  ----    write(l, rres);
  ----    writeline(log_file, l); 
  ----  end if;
  ----end process;

  ----rand_template: process(tb_clk)
  ----  variable b : boolean := true;
  ----  variable max : positive := 255;
  ----begin
  ----  if b then
  ----    report integer'image(time'pos(now));
  ----    report integer'image(to_int(max'instance_name));
  ----    report integer'image(rand_int(max,to_int(max'instance_name)));
  ----    b := false;
  ----  end if;
  ----end process;
  
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
        write(l, rlast);
        write(l, SEP);
        ---- write
        write(l, wvalid);
        write(l, SEP);
        write(l, waddr);
        write(l, SEP);
        write(l, wrvalid);
        write(l, SEP);
        write(l, rlast);
        write(l, SEP);
        
        ---- gfx
        ---- read
        write(l, rvalid_gfx);
        write(l, SEP);
        write(l, rdvalid_gfx);
        write(l, SEP);
        write(l, rlast_gfx);
        write(l, SEP);
        ---- write
        write(l, wvalid_gfx);
        write(l, SEP);
        write(l, waddr_gfx);
        write(l, SEP);
        write(l, wrvalid_gfx);
        write(l, SEP);
        write(l, wlast_gfx);
        write(l, SEP);

        ---- uart
        ---- read
        write(l, rvalid_uart);
        write(l, SEP);
        write(l, rdvalid_uart);
        write(l, SEP);
        write(l, rlast_uart);
        write(l, SEP);
        ---- write
        write(l, wvalid_uart);
        write(l, SEP);
        write(l, waddr_uart);
        write(l, SEP);
        write(l, wrvalid_uart);
        write(l, SEP);
        write(l, wlast_uart);
        write(l, SEP);

        ---- usb
        ---- read
        write(l, rvalid_usb);
        write(l, SEP);
        write(l, rdvalid_usb);
        write(l, SEP);
        write(l, rlast_usb);
        write(l, SEP);
        ---- write
        write(l, wvalid_usb);
        write(l, SEP);
        write(l, waddr_usb);
        write(l, SEP);
        write(l, wrvalid_usb);
        write(l, SEP);
        write(l, wlast_usb);
        write(l, SEP);

        ---- audio
        ---- read
        write(l, rvalid_audio);
        write(l, SEP);
        write(l, rdvalid_audio);
        write(l, SEP);
        write(l, rlast_audio);
        write(l, SEP);
        ---- write
        write(l, wvalid_audio);
        write(l, SEP);
        write(l, waddr_audio);
        write(l, SEP);
        write(l, wrvalid_audio);
        write(l, SEP);
        write(l, wlast_audio);
        write(l, SEP);
        
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

        ---- pwr
        -- TODO add:
        -- ic_pwr_req
        -- ic_pwr_res

        -- pwr_<dev>_req
        -- pwr_<dev>_res
        -- where dev is one of gfx, uart, usb, audio
        
        writeline(trace_file, l); 
      end if;
    end if;
  end process;

  pwr_test_mon : process
    variable m, t : time := 0 ps;
    variable zeros553 : std_logic_vector(552 downto 0) := (others => '0');
    variable zeros73 : MSG_T := (others => '0');
  begin
    if is_tset(PWRUP_TEST) then
      wait until cpu_res1 /= zeros73;
      report "PWRUP_TEST OK";
    end if;
    wait;
  end process;

  --gfx_r_mon : process
  --  variable m, t : time := 0 ps;
  --  variable zeros553 : std_logic_vector(552 downto 0) := (others => '0');
  --  variable zeros73 : MSG_T := (others => '0');
  --begin
  --  if is_tset(GFX_R_TEST) then
  --    wait until gfx_upres /= zeros73;
  --    report "GFX_R_TEST OK";
  --  end if;
  --  wait;
  --end process;
  
  --cpu2_w_mon : process
  --  variable m, t : time := 0 ps;
  --  variable zeros553 : std_logic_vector(552 downto 0) := (others => '0');
  --  variable zeros73 : MSG_T := (others => '0');
  --begin
  --  if is_tset(CPU2_W_TEST) then
  --    wait until cpu_res2 /= zeros73;
  --    report "CPU2_W_TEST OK";
  --  ---- TODO ... more tests here ...
  --    --m := 510 ps;
  --    --wait for m - t;
  --    --t := m;
  --    --assert cpu_res2 /= zeros73 report "cpu2_w_mon, msg 8: cpu_res2 is 0" severity error;
  --  end if;
  --  wait;
  --end process;
    
  --cpu1_r_mon : process
  --  variable m, t : time := 0 ps;
  --  variable zeros553 : std_logic_vector(552 downto 0) := (others => '0');
  --  variable zeros73 : std_logic_vector(72 downto 0) := (others => '0');
  --begin
  --  if is_tset(CPU1_R_TEST) then
  --    m := 70 ps;
  --    wait for m - t;
  --    t := m;
  --    assert cpu_req1 /= zeros73 report "cpu1_r_mon, msg 1: cpu_req1 is 0" severity error;
      
  --    m := 140 ps;
  --    wait for m - t;
  --    t := m;
  --    assert snp_req2 /= zeros73 report "cpu1_r_mon, msg 2: snp_req2 is 0" severity error;
      
  --    m := 220 ps;
  --    wait for m - t;
  --    t := m;
  --    assert snp_res2 /= zeros73 report "cpu1_r_mon, msg 3: snp_res2 is 0" severity error;
      
  --    m := 230 ps;
  --    wait for m - t;
  --    t := m;
  --    assert bus_req1 /= zeros73 report "cpu1_r_mon, msg 4: bus_req1 is 0" severity error;
      
  --    m := 280 ps;
  --    wait for m - t;
  --    t := m;
  --    assert rvalid /= '0' report "cpu1_r_mon, msg 5: rvalid is 0" severity error;
      
  --    m := 300 ps;
  --    wait for m - t;
  --    t := m;
  --    assert rdvalid /= '0' report "cpu1_r_mon, msg 6: rdvalid is 0" severity error;
      
  --    m := 440 ps;
  --    wait for m - t;
  --    t := m;
  --    assert bus_res1 /= zeros73 report "cpu1_r_mon, msg 7: bus_res1 is 0" severity error;
      
  --    m := 550 ps;
  --    wait for m - t;
  --    t := m;
  --    assert cpu_res1 /= zeros73 report "cpu1_r_mon, msg 8: cpu_res1 is 0" severity error;
  --  --check_inv(t, 550 ps, cpu_res1 /= zeros73, "cpu1_r_mon, msg 8: cpu_res1 is 0");
  --  end if;
  --  wait;
  --end process;
  
  stimuli : process
  begin
   
    reset <= '1';
    wait for 15 ps;
    reset <= '0';
    
    wait;
  end process;
end tb;
