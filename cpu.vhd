library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.rand.all;
use work.util.all;
use work.test.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity cpu is
  Port(reset     : in  std_logic;
       Clock     : in  std_logic;

       id_i      : in IP_T;
       
       cpu_res_i : in  std_logic_vector(72 downto 0);
       cpu_req_o : out std_logic_vector(72 downto 0);
       full_c_i  : in  std_logic-- an input signal from cache, enabled when
       -- cache is full TODO confirm
       --TODO not implemented?
       );
end cpu;

architecture rtl of cpu is
  type states is (init, send, idle);
  signal st, next_st : states;
  signal addr,data: std_logic_vector(31 downto 0);
  signal sim_end : std_logic := '0';
  
begin
  clk_counter : process(clock, sim_end)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if sim_end = '1' and b then
      report str(id_i) & " ended, clock cycles is " & str(count);
      b := false;
    elsif (rising_edge(clock)) then
      count := count + 1;
    end if;
  end process;

  --* t1: TEST(CPU1R) cpu1 sends a read req msg
  --* t2: TEST(CPU2W) cpu2 sends a write req msg
  --* t3: TEST(PETERSONS) executes petersons algorithm
  --* t4: TEST(CPUW20) cpu 1 and 2 send 20 rand write reqs
  --* t6: TEST(PWR)
  --* t7: TEST(RW)
  --* t8: RND_CPU_TEST
  cpu_test : process(reset, Clock)
    variable st, st_nxt : natural := 0;
    variable t1, t2, t3, t4, t5, t6, t7 : boolean := false;
    
    variable t1_ct : natural;

    variable t2_ct : natural;
    
    variable t3_ct1, t3_ct2, t3_ct3 : natural;
    variable t3_adr_me, t3_adr_other: ADR_T; -- flag0 and flag1
    variable t3_dat1 : DAT_T := (0=>'1',others=>'0'); -- to cmp val of data=1
    variable t3_rdlay : boolean := PT_DELAY_FLAG;
    variable t3_seed : natural := nat(id_i);
    variable t3_cont : boolean := false;
    variable t3_reg : MSG_T;
    
    variable t4_adr : ADR_T;
    variable t4_dat : DAT_T;
    variable t4_ct, t4_tot_ct : natural := 0;
    variable t4_tot : natural := 20;

    -- t6 vars
    variable t6_f : boolean := true;
    variable t6_c, t6_tc, t6_r : natural := 0;
    variable t6_s : natural := nat(id_i);
    -- _s is seed, _c is cnt, _tc is tot cnt
    variable t6_cpuid : IPTAG_T;
    variable t6_cmd : CMD_T;
    variable t6_devid : IPTAG_T;

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
    -- Set up tests
    if is_tset(TEST(CPU1R)) then
      t1 := true;
    end if;
    if is_tset(TEST(CPU2W)) then
      t2 := true;
    end if;
    if is_tset(TEST(PETERSONS)) then
      t3 := true;
      -- assumming m[shared] is set to 0 TODO set in top.vhd
      if id_i = CPU0 then
        t3_adr_me := PT_VAR_FLAG0;
        t3_adr_other := PT_VAR_FLAG1;
      elsif id_i = CPU1 then
        t3_adr_me := PT_VAR_FLAG1;
        t3_adr_other := PT_VAR_FLAG0;
      end if;
    end if;
    if is_tset(TEST(CPUW20)) then
      t4 := true;
    end if;
    if is_tset(TEST(PWR)) and
     (PWRT_SRC and ip_enc(id_i)) /= ip_enc(NONE) then
      t6 := true;
    end if;
    if is_tset(TEST(RW)) and
      (RWT_SRC and ip_enc(id_i)) /= ip_enc(NONE) then
      t7 := true;
    end if;
    
    if reset = '1' then
      cpu_req_o <= (others => '0');
      -- Set initial rnd delays for each test
      if t1 and (id_i = CPU0)then
        t1_ct := rand_nat(to_integer(unsigned(TEST(CPU1R))));
      end if;
      if t2 and (id_i = CPU1) then
        t2_ct := rand_nat(to_integer(unsigned(TEST(CPU2W))));
      end if;
      if t4 then
        t4_ct := rand_nat(to_integer(unsigned(TEST(CPUW20)))); 
      end if;
      st := 0;
      
    elsif (rising_edge(Clock)) then
      -- REPORT ST **************************************************************
      --if st = 100 then
      --  --report str(id_i) &
      --  --  ", sd:" & integer'image(t3_seed) &
      --  --  ", cnt:" & integer'image(t3_ct3) &
      --  --  ", st:" & integer'image(st);
      --end if;
      log("st is " & str(st), DEBUG);
        
      if st = 0 then -- wait
        if t1 and (id_i = CPU0) then
          delay(t1_ct, st, 1);
        end if;
        if t2 and (id_i = CPU1) then
          delay(t2_ct, st, 1);
        end if;
        if t3 then
          st := 100; -- petersons test starts in state 100
        end if;
        --if t3 then
        --  t3_ct3 := 5;
        --end if;
        if t4 then
          --delay(t4_ct, st, 20); -- TEST(CPUW20) starts in state 20
          st := 20;
        end if;
        if t6 and t7 then -- PWR AND RW are set
          st := 80;
        elsif t6 then
          st := 60; -- TEST(PWR) starts in state 60
        elsif t7 then
          st := 70; -- TEST(RW) starts in state 70
        end if;

-- *** t1, t2: CPU_R_TEST and CPU_W_TEST start here ***
      elsif st = 1 then -- send
        -- send a random msg
        if t1 and (id_i = CPU0) then
          log("cpu0_r_test @ " & str(time'pos(now)), DEBUG);
          cpu_req_o <= "1" & READ_CMD & X"80000000" & ZEROS32;
          st := 2;
        elsif t2 and (id_i = CPU1) then
          log("cpu1_w_test @ " & str(time'pos(now)), DEBUG);
          cpu_req_o <= "1" & X"80" & X"00000000" & X"00000000";
                         -- "1" & X"801c00000062040000";
                         -- TODO will not work with the following address:
                         --"1" & WRITE_CMD &
                         --"10000000000000000000000000000000" &
                         --ZEROS32;
          st := 2;
        end if;
      elsif st = 2 then -- done
        --if is_valid(cpu_res_i) then
        --report "pbm";
        sim_end <= '1';
        --end if;
        cpu_req_o<=(others =>'0');

-- *** t4: TEST(CPUW20) starts here ***
      elsif st = 20 then
        cpu_req_o <= (others => '0');
        if t4_tot_ct = 0 or is_valid(cpu_res_i) then
          t4_adr := rand_vect_range(2**6-1,7) & "000000000" & "0000000000000000";
          t4_dat := rand_vect_range(2**15-1,16) & "0000000000000000";
          st := 21;
        end if;
      elsif st = 21 then
        if t4_tot_ct < t4_tot then
          if id_i = CPU0 then
            cpu_req_o <= "1" & WRITE_CMD & t4_adr & t4_dat;
          else
            cpu_req_o <= "1" & READ_CMD & t4_adr & t4_dat;            
          end if;
          t4_tot_ct := t4_tot_ct + 1;
          st := 20;
        else
          st := 22;
        end if;
      elsif st = 22 then
        cpu_req_o <= (others => '0');
        --if is_valid(cpu_res_i) then
          st := 2;
        --end if;

-- *** t6: TEST(PWR) starts here ***
      elsif st = 60 then -- go to delay or done
        if t6_tc < PWRT_CNT then
          t6_tc := t6_tc + 1;
          st_nxt := 61;
          st := 69;
        else
          st := 2;
        end if;
      elsif st = 61 then -- snd pwr req

        -- set cpu id vect
        if id_i = CPU0 then
          t6_cpuid := CPU0_TAG;
        else
          t6_cpuid := CPU1_TAG;
        end if;
        
        -- rnmz pwr cmd
        t6_r := rand_nat(nat(id_i) + t6_s);
        if (t6_r mod 2) = 1 then
          -- report str(id_i) & "up";
          t6_cmd := PWRUP_CMD;
        else
          -- report str(id_i) & "dn";
          t6_cmd := PWRDN_CMD;
        end if;

        -- calc devid
        --  (t6_r % 4) + 1 since there are 4 peripherals and their ids start at 1
        t6_devid := std_logic_vector(to_unsigned((t6_r mod 4) + 1, t6_devid'length));
        
        cpu_req_o <= "1" & t6_cmd & pad32(t6_cpuid) & pad32(t6_devid);
        st := 62;
      elsif st = 62 then -- wait res
        cpu_req_o <= (others => '0');
        --if is_valid(cpu_res_i) then
        --  st := 60;
        --end if;

        -- do not wait for resp, dlay for rnd time and continue
        if is_tset(TEST(RW)) then
          st_nxt := 80;
        else
          st_nxt := 60;
        end if;

        st := 69;
      elsif st = 69 then -- delay
        rnd_dlay(t6_f, t6_s, t6_c, st, st_nxt);

-- *** t7: TEST(RW) starts here ***
      elsif st = 70 then -- go to delay or done
        if t7_tc < RWT_CNT then
          t7_tc := t7_tc + 1;
          st_nxt := 71;
          st := 79;
        else
          st := 2;
        end if;
      elsif st = 71 then -- snd r|w req

        t7_s := t7_s + 1;
        -- rndmz cmd
        t7_r := rand_nat(nat(id_i) + t7_s);
        --report str(id_i) & ", r is " & integer'image(t7_r);
        if (t7_r mod 2) = 1 then
          t7_cmd := READ_CMD;
        else
          t7_cmd := WRITE_CMD;
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
        if (t7_r mod 2) = 1 then
          t7_adr := t7_adr or X"80000000"; -- mem
        else
          t7_adr := t7_adr and X"1FFFFFFF"; -- gfx
        end if;
        
        cpu_req_o <= "1" & t7_cmd & t7_adr & t7_adr;
        st := 72;
      elsif st = 72 then -- wait some time        
        cpu_req_o <= (others => '0');
        -- do not wait for resp, dlay for rnd time and continue
        if is_tset(TEST(PWR)) then -- if pwrt is set, rndmly choose next one to
                                  -- run
          st_nxt := 80;
        else
          st_nxt := 70;
        end if;
        st := 79;
      elsif st = 79 then -- delay
        rnd_dlay(t7_f, t7_s, t7_c, st, st_nxt);

-- *** t8: RND_RW_OR_PWR_TEST starts here ***
      elsif st = 80 then -- rndmly choose between pwr_test and rw_test
        if (rand_nat(t6_s + t7_s) mod 2) = 1 and t6_tc < PWRT_CNT then
          st := 60;
        elsif t7_tc < RWT_CNT then
          st := 70;
        else
          cpu_req_o<=(others =>'0');
          sim_end <= '1';
        end if;
        
-- *** t3: Petersons algorithm starts here ***
      elsif st = 99 then -- delay
        --TODO remember to put back
        --pt_delay(t3_rdlay, t3_seed, t3_ct3, st, st_nxt);
        st := st_nxt;
      elsif st = 100 then -- line 1 (for loop)
        if t3_ct1 < PT_ITERATIONS then
          pt_delay(t3_rdlay, t3_seed, t3_ct3, st, 101);
        else
          st := 2; -- done
--          report "done at " & integer'image(time'pos(now));
        end if;
      elsif st = 101 then -- line 2
        req(cpu_req_o, "1" & WRITE_CMD
            & t3_adr_me & t3_dat1, str(id_i)); -- flag[me] = 1; (req)
        st := 102;
      elsif st = 102 then -- wait_rsp
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          log("got response" & str(id_i), DEBUG);
          st := 99; -- st delay
          st_nxt := 1022;
        end if;
      elsif st = 1022 then -- line 3
--        report "done! st is " & integer'image(st);
        req(cpu_req_o, "1" & WRITE_CMD
            & PT_VAR_TURN & t3_dat1, str(id_i)); -- turn = 1; (req)
        st := 103;
      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          log("got response" & str(id_i), DEBUG);
          st := 99;
          st_nxt := 1032;
        end if;
      elsif st = 1032 then -- read flag[other]
        req(cpu_req_o, "1" & READ_CMD
            & t3_adr_other & ZEROS32, str(id_i));
        st := 104;
      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          report "got response" & str(id_i);
          if (get_dat(cpu_res_i) = t3_dat1) then
            --report str(id_i) &  "dat is 1";
            st_nxt := 1042; --if flag[other]=1
          else
            st_nxt := 108; -- jump out of loop
        end if;
          st := 99;
        end if;
      elsif st = 1042 then
        req(cpu_req_o, "1" & READ_CMD & PT_VAR_TURN & ZEROS32, str(id_i)); -- read turn
        st := 105;
      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          log("got response" & str(id_i), DEBUG);
          if (get_dat(cpu_res_i) = t3_dat1) then -- if turn=1
            st_nxt := 106; --TODO*
          else
            st_nxt := 108; -- jump out of loop
          end if;
        st := 99;
        end if;
      elsif st = 106 then -- busy wait
        st := 1032; -- go to loop again
      elsif st = 108 then -- line 6 (get val of shared)
        req(cpu_req_o, "1" & READ_CMD & PT_VAR_SHARED & ZEROS32, str(id_i));
        st := 109;
      elsif st = 109 then -- wait_rsp
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          log("got response" & str(id_i), DEBUG);
          st := 99; -- st delay
          st_nxt := 1092;          
        end if;
      elsif st = 1092 then
        req(cpu_req_o, "1" & WRITE_CMD & PT_VAR_SHARED &
                       std_logic_vector(unsigned(get_dat(cpu_res_i)) +
                                        unsigned(t3_dat1)), str(id_i));
        st := 110;
      elsif st = 110 then
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          log("got response" & str(id_i), DEBUG);
          st := 99;
          st_nxt := 1102;
        end if;
      elsif st = 1102 then
        req(cpu_req_o, "1" & WRITE_CMD & t3_adr_me & ZEROS32, str(id_i));
        st := 111;
      elsif st = 111 then -- jmp to FOR_LOOP_START
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          log("got response" & str(id_i), DEBUG);
          t3_ct1 := t3_ct1 + 1;
          st := 99;
          st_nxt := 100;
          if (t3_ct1 mod 50) = 0 then
            log("t3_ct1 is " & str(t3_ct1), DEBUG);
          end if;
        end if;
      end if;
    end if;
  end process;    
end rtl;
