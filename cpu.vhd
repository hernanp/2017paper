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
  Port(reset   : in  std_logic;
       Clock   : in  std_logic;
       cpu_id_i   : in  integer;
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
      report "cpu" & integer'image(cpu_id_i) & " sim ended, clock cycles is " & integer'image(count);
      b := false;
    elsif (rising_edge(clock)) then
      count := count + 1;
    end if;
  end process;

  --* t1: CPU1_R_TEST cpu1 sends a read req msg
  --* t2: CPU2_W_TEST cpu2 sends a write req msg
  --* t3: PETERSONS_TEST executes petersons algorithm
  --* t4: CPU_W20_TEST cpu 1 and 2 send 20 rand write reqs
  --* t5: CPU1_RW_04_TEST cpu1 writes and reads to mem[0..4]
  --* t6: PWR_TEST
  --* t7: RW_TEST
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
    variable t3_seed : natural := cpu_id_i;
    variable t3_cont : boolean := false;
    variable t3_reg : MSG_T;
    
    variable t4_adr : ADR_T;
    variable t4_dat : DAT_T;
    variable t4_ct, t4_tot_ct : natural := 0;
    variable t4_tot : natural := 20;

    -- t6 vars
    variable t6_f : boolean := true;
    variable t6_c, t6_tc, t6_r : natural := 0;
    variable t6_s : natural := cpu_id_i;
    -- _s is seed, _c is cnt, _tc is tot cnt
    variable t6_cpuid : DEVID_T;
    variable t6_cmd : CMD_T;
    variable t6_devid : DEVID_T;

    -- t7 vars
    variable t7_f : boolean := true;
    variable t7_s : natural := cpu_id_i;
    variable t7_tc, t7_c, t7_r : natural := 0;
    variable t7_cmd : CMD_T;
    variable t7_adr : ADR_T;

    ---- t8 vars
    --variable t8_f : boolean := true;
    --variable t8_s : natural := cpu_id_i;
    --variable t8_tc, t8_c, t8_r : natural := 0;
    --variable t8_cmd : CMD_T;
    --variable t8_adr : ADR_T;
    --variable t8_cpuid : DEVID_T;
    --variable t8_devid : DEVID_T;
    
  begin
    -- Set up tests
    if is_tset(CPU1_R_TEST) then
      t1 := true;
    end if;
    if is_tset(CPU2_W_TEST) then
      t2 := true;
    end if;
    if is_tset(PETERSONS_TEST) then
      t3 := true;
      -- assumming m[shared] is set to 0 TODO set in top.vhd
      if cpu_id_i = 1 then
        t3_adr_me := PT_VAR_FLAG0;
        t3_adr_other := PT_VAR_FLAG1;
      elsif cpu_id_i = 2 then
        t3_adr_me := PT_VAR_FLAG1;
        t3_adr_other := PT_VAR_FLAG0;
      end if;
    end if;
    if is_tset(CPU_W20_TEST) then
      t4 := true;
    end if;
    --if is_tset(CPU1_RW_04_TEST) then
    --  t5 := true;
    --end if;
    if is_tset(PWR_TEST) then
      t6 := true;
    end if;
    if is_tset(RW_TEST) then
      t7 := true;
    end if;
    
    if reset = '1' then
      cpu_req_o <= (others => '0');
      -- Set initial rnd delays for each test
      if t1 and (cpu_id_i = 1)then
        t1_ct := rand_nat(to_integer(unsigned(CPU1_R_TEST)));
        --t1_ct := rand_int(RAND_MAX_DELAY, to_int(t1_ct'instance_name),
        --                  to_integer(unsigned(CPU1_R_TEST)));
        --report "t1.delay is " & integer'image(t1_ct);
      end if;
      if t2 and (cpu_id_i = 2) then
        t2_ct := rand_nat(to_integer(unsigned(CPU2_W_TEST)));
      end if;
      if t4 then
        t4_ct := rand_nat(to_integer(unsigned(CPU_W20_TEST))); 
      end if;
      st := 0;
      
    elsif (rising_edge(Clock)) then
      -- REPORT ST **************************************************************
      --if st = 100 then
      --  --report "cpu_id_i:" & integer'image(cpu_id_i) &
      --  --  ", sd:" & integer'image(t3_seed) &
      --  --  ", cnt:" & integer'image(t3_ct3) &
      --  --  ", st:" & integer'image(st);
      --end if;
        
      if st = 0 then -- wait
        if t1 and (cpu_id_i = 1) then
          delay(t1_ct, st, 1);
        end if;
        if t2 and (cpu_id_i = 2) then
          delay(t2_ct, st, 1);
        end if;
        if t3 then
          st := 100; -- petersons test starts in state 100
        end if;
        --if t3 then
        --  t3_ct3 := 5;
        --end if;
        if t4 then
          --delay(t4_ct, st, 20); -- CPU_W20_TEST starts in state 20
          st := 20;
        end if;
        if t5 then
          st := 30; -- CPU1_RW_04_TEST starts in state 30
        end if;
        if t6 then
          st := 60; -- PWR_TEST starts in state 60
        end if;
        if t7 then
          st := 70; -- RW_TEST starts in state 70
        end if;

-- *** CPU_R_TEST and CPU_W_TEST start here ***
      elsif st = 1 then -- send
        -- send a random msg
        if t1 and (cpu_id_i = 1) then
          report "cpu1_r_test @ " & integer'image(time'pos(now));
          cpu_req_o <= "1" & READ_CMD &
                         "10000000000000000000000000000000" &
                         ZEROS32;
          st := 2;
        elsif t2 and (cpu_id_i = 2) then
          report "cpu2_w_test @ " & integer'image(time'pos(now));
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
          sim_end <= '1';
        --end if;
        cpu_req_o<=(others =>'0');

-- *** CPU_W20_TEST starts here ***
      elsif st = 20 then
        cpu_req_o <= (others => '0');
        if t4_tot_ct = 0 or is_valid(cpu_res_i) then
          t4_adr := rand_vect_range(2**6-1,7) & "000000000" & "0000000000000000";
          t4_dat := rand_vect_range(2**15-1,16) & "0000000000000000";
          st := 21;
        end if;
      elsif st = 21 then
        if t4_tot_ct < t4_tot then
          if cpu_id_i = 1 then
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
-- *** CPU1_RW_04_TEST starts here ***
      --elsif st = 50 then
      --  if(cpu_id_i = 1) then
      --    cpu_req_o <= "1" & WRITE_CMD & X"1c000000" & X"00000001";
      --    st := 51;
      --  end if;
      --elsif st = 51 then
      --  if(cpu_id_i = 1) and is_valid(cpu_res_i) then
      --    cpu_req_o <= "1" & READ_CMD & X"1c000000" & X"00000000";
      --    st := 52;
      --  end if;
      --elsif st = 52 then
      --  cpu_req_o <= (others => '0');

-- *** PWR_TEST starts here ***
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
        if cpu_id_i = 1 then
          t6_cpuid := CPU0_ID;
        else
          t6_cpuid := CPU1_ID;
        end if;
        
        -- rnmz pwr cmd
        t6_r := rand_nat(cpu_id_i + t6_s);
        if (t6_r mod 2) = 1 then
          -- report integer'image(cpu_id_i) & "up";
          t6_cmd := PWRUP_CMD;
        else
          -- report integer'image(cpu_id_i) & "dn";
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
        if is_tset(RW_TEST) then
          st_nxt := 80;
        else
          st_nxt := 60;
        end if;

        st := 69;
      elsif st = 69 then -- delay
        rnd_dlay(t6_f, t6_s, t6_c, st, st_nxt);

-- *** RW_TEST starts here ***
      elsif st = 70 then -- go to delay or done
        if t7_tc < RWT_CNT then
          t7_tc := t7_tc + 1;
          st_nxt := 71;
          st := 79;
        else
          st := 2;
        end if;
      elsif st = 71 then -- snd r|w req

        -- rndmz cmd
        t7_r := rand_nat(cpu_id_i + t7_s);
        --report integer'image(cpu_id_i) & ", r is " & integer'image(t7_r);
        if (t6_r mod 2) = 1 then
          t7_cmd := READ_CMD;
        else
          t7_cmd := WRITE_CMD;
        end if;

        -- rndmz adr
        t7_adr := rnd_adr(t7_r);
        
        cpu_req_o <= "1" & t7_cmd & t7_adr & t7_adr;
        st := 72;
      elsif st = 72 then -- wait some time        
        cpu_req_o <= (others => '0');
        -- do not wait for resp, dlay for rnd time and continue
        if is_tset(PWR_TEST) then -- if pwrt is set, rndmly choose next one to
                                  -- run
          st_nxt := 80;
        else
          st_nxt := 70;
        end if;
        st := 79;
      elsif st = 79 then -- delay
        rnd_dlay(t7_f, t7_s, t7_c, st, st_nxt);

-- *** RND_CPU_TEST starts here ***
      elsif st = 80 then -- rndmly choose between pwr_test and rw_test
        if (rand_nat(t6_s + t7_s) mod 2) = 1 then
          st := 60;
        else
          st := 70;
        end if;
        
-- *** Petersons algorithm starts here ***
      elsif st = 99 then -- delay
        pt_delay(t3_rdlay, t3_seed, t3_ct3, st, st_nxt);
      elsif st = 100 then -- line 1 (for loop)
        if t3_ct1 < PT_ITERATIONS then
          pt_delay(t3_rdlay, t3_seed, t3_ct3, st, 101);
        else
          st := 2; -- done
--          report "done at " & integer'image(time'pos(now));
        end if;
      elsif st = 101 then -- line 2
        cpu_req_o <= "1" & WRITE_CMD &
                   t3_adr_me &
                   t3_dat1; -- flag[me] = 1; (req)
        st := 102;
      elsif st = 102 then -- wait_rsp
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
--          report "got response";
          st := 99; -- st delay
          st_nxt := 1022;
        end if;
      elsif st = 1022 then -- line 3
--        report "done! st is " & integer'image(st);
        cpu_req_o <= "1" & WRITE_CMD &
                       PT_VAR_TURN &
                       t3_dat1; -- turn = 1; (req)
        st := 103;
      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
--          report "got response";
          st := 99;
          st_nxt := 1032;
        end if;
      elsif st = 1032 then -- read flag[other]
        cpu_req_o <= "1" & READ_CMD &
                       t3_adr_other &
                       ZEROS32;
        st := 104;
      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
--          report "got response";
          if (get_dat(cpu_res_i) = t3_dat1) then
            st_nxt := 1042; --if flag[other]=1
          else
            st_nxt := 108; -- jump out of loop
        end if;
          st := 99;
        end if;
      elsif st = 1042 then
        cpu_req_o <= "1" & READ_CMD &
                       PT_VAR_TURN &
                       ZEROS32; -- read turn
        st := 105;
      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          if (get_dat(cpu_res_i) = t3_dat1) then -- if turn=1
            st_nxt := 106; --TODO*
          else
            st_nxt := 108; -- jump out of loop
          end if;
        end if;
        st := 99;
      elsif st = 106 then -- busy wait
        st := 103;
      elsif st = 108 then -- line 6 (get val of shared)
        cpu_req_o <= "1" & READ_CMD &
                       PT_VAR_SHARED &
                       ZEROS32;
        st := 109;
      elsif st = 109 then -- wait_rsp
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
--          report "got response";
          st := 99; -- st delay
          st_nxt := 1092;          
        end if;
      elsif st = 1092 then
        cpu_req_o <= "1" & WRITE_CMD &
                       PT_VAR_SHARED &
                       std_logic_vector(unsigned(get_dat(cpu_res_i)) +
                                        unsigned(t3_dat1));
        st := 110;
      elsif st = 110 then
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          st := 99;
          st_nxt := 1102;
        end if;
      elsif st = 1102 then
        cpu_req_o <= "1" & WRITE_CMD &
                       t3_adr_other &
                       ZEROS32;
        st := 111;
      elsif st = 111 then -- jmp to FOR_LOOP_START
        cpu_req_o <= ZERO_MSG;
        if is_valid(cpu_res_i) then
          t3_ct1 := t3_ct1 + 1;
          st := 99;
          st_nxt := 100;
          if (t3_ct1 mod 50) = 0 then
            report "t3_ct1 is " & integer'image(t3_ct1);
          end if;
        end if;
      end if;
    end if;
  end process;    
end rtl;
