library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;
use work.test.all;
use work.rand.all;

entity proc is
  port(
    Clock        : in  std_logic;
    reset        : in  std_logic;

    id_i         : in IP_T;
    
    snp_req_i    : in  MSG_T;
    bus_res_i    : in  BMSG_T;
    snp_hit_o    : out std_logic;
    snp_res_o    : out MSG_T := (others => '0');

    --goes to cache controller ask for data
    snp_req_o    : out MSG_T;
    snp_res_i    : in  MSG_T;
    snp_hit_i    : in  std_logic;
    up_snp_req_i : in  WMSG_T; --TODO rename to ureq
    up_snp_res_o : out WMSG_T;
    up_snp_hit_o : out std_logic;
    wb_req_o     : out BMSG_T;

    bus_req_o    : out MSG_T :=
      (others => '0'); -- a down req

    -- for observation only:
    cpu_req_o    : out MSG_T;
    cpu_res_o    : out MSG_T    
    );

end proc;

architecture rtl of proc is
  signal cpu_req, cpu_req_wrapper : MSG_T;
  signal cpu_res : MSG_T;

  signal rwt_req : MSG_T;
  signal rwt_req_ack : std_logic;
  
  signal sim_end : std_logic := '0';
begin

  --cpu_ent : entity work.cpu(rtl) port map(
  --  reset     => reset,
  --  Clock     => Clock,

  --  id_i      => id_i,
    
  --  cpu_res_i => cpu_res,
  --  cpu_req_o => cpu_req,
  --  full_c_i  => '0' --NOT IMPLEMENTED
  --  );

  cache_ent : entity work.l1_cache(rtl) port map(
    Clock       => Clock,
    reset       => reset,

    cpu_req_i  => cpu_req,
    cpu_res_o => cpu_res,

    snp_req_i  => snp_req_i, -- snoop req from cache 2
    snp_hit_o => snp_hit_o,
    snp_res_o => snp_res_o,

    up_snp_req_i  => up_snp_req_i, -- upstream snoop req 
    up_snp_hit_o => up_snp_hit_o,
    up_snp_res_o => up_snp_res_o,

    snp_req_o => snp_req_o, -- fwd snp req to other cache
    snp_hit_i => snp_hit_i,
    snp_res_i => snp_res_i,

    bus_req_o  => bus_req_o, -- mem or pwr req to ic
    bus_res_i   => bus_res_i, -- mem or pwr resp from ic

    wb_req_o      => wb_req_o,

    -- NOT IMPLEMENTED
    --bsf_full_o    => , -- bus resp fifo full
    --srf_full_o    => , 
    --crf_full_o    => ,
	 
    full_crq_i    => '0',
    full_wb_i     => '0',
    full_srs_i    => '0'
    );

  -- signals for observation
--  cpu_req_o <= cpu_req_wrapper;
  cpu_req_o <= cpu_req;
  cpu_res_o <= cpu_res;

  --cpu_req_arbiter : entity work.arbiter6(rtl) port map(
  --  clock => Clock,
  --  reset => reset,
  --  din1  => cpu_req,
  --  --ack1  => uart_upres_ack1,
  --  din2  => rwt_req,
  --  ack2  => rwt_req_ack,
  --  din3  => ZERO_MSG,
  --  din4  => ZERO_MSG,
  --  din5  => ZERO_MSG,
  --  din6  => ZERO_MSG,
  --  dout  => cpu_req_wrapper
  --  );
  
  clk_counter : process(clock, sim_end)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if sim_end = '1' and b then
      inf(str(id_i) & " ended, clock cycles is " & str(count));
      b := false;
    elsif (rising_edge(clock)) then
      count := count + 1;
    end if;
  end process;
  
  --* t7: TEST(RW)
  rw_test : process(reset, Clock)
    variable st, st_nxt : natural := 0;
    variable st_prev : integer := -1;
    variable prev_req : MSG_T := (others => '0');
    
    variable t7 : boolean := false;
    
    -- t7 vars
    variable t7_f : boolean := true;
    variable t7_s : natural := nat(id_i);
    variable t7_tc, t7_c, t7_r : natural := 0;
    variable t7_cmd : CMD_T;
    variable t7_adr : ADR_T;

    -- HACKS
    variable c1: integer := 0;
    variable c2: integer := 200; -- offset so that cpus do not req same adr
    
  begin
    -- Set up test
    if is_tset(TEST(RW)) and
      (RWT_SRC and ip_enc(id_i)) /= ip_enc(NONE) then
      t7 := true;
    end if;
    
    if reset = '1' then
      rwt_req <= (others => '0');
      st := 0;
      
    elsif (rising_edge(Clock)) then
      dbg_chg("pcs: rw_test, st: ", st, st_prev);
        
      if st = 0 then -- START
        if t7_tc < RWT_CNT then
          t7_tc := t7_tc + 1;
          st_nxt := 2;
          st := 4;
        else
          st := 1;
        end if;
      elsif st = 1 then -- DONE
        sim_end <= '1';
        cpu_req<=(others =>'0');

      elsif st = 2 then -- SND (r|w req)

        -- get a random number
        t7_s := t7_s + 1;
        -- rndmz cmd
        t7_r := rand_nat(nat(id_i) + t7_s);
        --report str(id_i) & ", r is " & integer'image(t7_r);

        -- if read and write are enabled, randomly select one of them
        if RWT_CMD = (READ_CMD or WRITE_CMD) then
          if (t7_r mod 2) = 1 then
            t7_cmd := READ_CMD;
          else
            t7_cmd := WRITE_CMD;
          end if;
        else
          t7_cmd := RWT_CMD;
        end if;
          
        -- rndmz adr
        --t7_adr := rnd_adr(t7_r);

        -- HACK1 force each cpu to request different addresses
        if id_i = CPU0 then
          t7_adr := std_logic_vector(to_unsigned(c1, t7_adr'length));
          c1 := c1 + 1;
        else
          t7_adr := std_logic_vector(to_unsigned(c2, t7_adr'length));
          c2 := c2 + 1;
        end if;
        
        -- HACK2 force them to go to memory or gfx
        --if (t7_r mod 2) = 1 then
          t7_adr := t7_adr or X"80000000"; -- mem
        --else
        --  t7_adr := t7_adr and X"1FFFFFFF"; -- gfx --TODO need to change gfx
        --end if;

        cpu_req <= "1" & t7_cmd & t7_adr & t7_adr;
        dbg(t7_cmd & t7_adr & t7_adr);
        prev_req := "1" & t7_cmd & t7_adr & t7_adr;
        st := 3;
      elsif st = 3 then -- WAIT_RES
        cpu_req <= (others => '0');
        if (not RWT_WAITRES) or -- if no need to wait for resp
          cpu_res = prev_req then -- or need to wait for resp and resp has arrived
          st_nxt := 0;
          dbg("000" & cpu_res);
          st := 4;
        end if;
      elsif st = 4 then -- DELAY
        rnd_dlay(t7_f, t7_s, t7_c, st, st_nxt);
      end if;
    end if;
  end process;
  
end rtl;
