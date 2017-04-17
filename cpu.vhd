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
       cpu_id   : in  integer;
       cpu_res_in : in  std_logic_vector(72 downto 0);
       cpu_req_out : out std_logic_vector(72 downto 0);
       full_c  : in  std_logic -- an input signal from cache, enabled when
                               -- cache is full TODO confirm
       );
end cpu;

architecture Behavioral of cpu is
  type states is (init, send, idle);
  signal st, next_st : states;
  signal addr,data: std_logic_vector(31 downto 0);

  signal sim_end : std_logic := '0';
  ----* TODO is this a fun to create a power_req?
  --procedure power(variable cmd : in  std_logic_vector(1 downto 0);
  --                signal req   : out std_logic_vector(72 downto 0);
  --                variable hw  : in  std_logic_vector(1 downto 0)) is
  --begin
  --  req <= "111000000" & cmd & hw & "00000000" & "00000000" & "00000000" &
  --         "00000000" & "00000000" & "00000000" & "00000000" & "0000";
  --  -- TODO maybe wait statements here need to go, however power is not being
  --  -- called, so why does simulation fail?
  --  wait for 3 ps;
  --  req <= (others => '0');
  --  wait until cpu_res(72 downto 72) = "1";
  --  wait for 50 ps;
  --end power;

  --procedure run_petersons (rst, clk: in std_logic) is
  --begin
    
  --end;
  
begin
  clk_counter : process(clock, sim_end)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if sim_end = '1' and b then
      report "cpu" & integer'image(cpu_id) & " sim ended, clock cycles is " & integer'image(count);
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
  cpu_test : process(reset, Clock)
    variable st, st_nxt : natural := 0;
    variable t1, t2, t3, t4, t5 : boolean := false;
    
    variable t1_ct : natural;

    variable t2_ct : natural;
    
    variable t3_ct1, t3_ct2, t3_ct3 : natural;
    variable t3_adr_me, t3_adr_other: ADR_T; -- flag0 and flag1
    variable t3_dat1 : DAT_T := (0=>'1',others=>'0'); -- to cmp val of data=1
    variable t3_rdlay : boolean := PT_DELAY_FLAG;
    variable t3_seed : natural := cpu_id;
    variable t3_cont : boolean := false;
    variable t3_reg : MSG_T;
    
    variable t4_adr : ADR_T;
    variable t4_dat : DAT_T;
    variable t4_ct, t4_tot_ct : natural := 0;
    variable t4_tot : natural := 20;
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
      if cpu_id = 1 then
        t3_adr_me := PT_VAR_FLAG0;
        t3_adr_other := PT_VAR_FLAG1;
      elsif cpu_id = 2 then
        t3_adr_me := PT_VAR_FLAG1;
        t3_adr_other := PT_VAR_FLAG0;
      end if;
    end if;
    if is_tset(CPU_W20_TEST) then
      t4 := true;
    end if;
    if is_tset(CPU1_RW_04_TEST) then
      t5 := true;
    end if;
    
    if reset = '1' then
      cpu_req_out <= (others => '0');
      -- Set initial rnd delays for each test
      if t1 and (cpu_id = 1)then
        t1_ct := rand_nat(to_integer(unsigned(CPU1_R_TEST)));
        --t1_ct := rand_int(RAND_MAX_DELAY, to_int(t1_ct'instance_name),
        --                  to_integer(unsigned(CPU1_R_TEST)));
        --report "t1.delay is " & integer'image(t1_ct);
      end if;
      if t2 and (cpu_id = 2) then
        t2_ct := rand_nat(to_integer(unsigned(CPU2_W_TEST)));
      end if;
      if t4 then
        t4_ct := rand_nat(to_integer(unsigned(CPU_W20_TEST))); 
      end if;
      st := 0;
    elsif (rising_edge(Clock)) then
      -- REPORT ST **************************************************************
      if st = 100 then
        --report "cpu_id:" & integer'image(cpu_id) &
        --  ", sd:" & integer'image(t3_seed) &
        --  ", cnt:" & integer'image(t3_ct3) &
        --  ", st:" & integer'image(st);
      end if;
        
      if st = 0 then -- wait
        if t1 and (cpu_id = 1) then
          delay(t1_ct, st, 1);
        end if;
        if t2 and (cpu_id = 2) then
          delay(t2_ct, st, 1);
        end if;
        if t3 then
          st := 100; -- petersons algorithm starts at state 100
        end if;
        --if t3 then
        --  t3_ct3 := 5;
        --end if;
        if t4 then
          --delay(t4_ct, st, 20); -- CPU_W20_TEST starts at state 20
          st := 20;
        end if;
        if t5 then
          st := 30; -- CPU1_RW_04_TEST starts at state 30
        end if;
      elsif st = 1 then -- send
        -- send a random msg
        if t1 and (cpu_id = 1) then
          report "cpu1_r_test @ " & integer'image(time'pos(now));
          cpu_req_out <= "1" & READ_CMD &
                         "10000000000000000000000000000000" &
                         ZEROS32;
          st := 2;
        elsif t2 and (cpu_id = 2) then
          report "cpu2_w_test @ " & integer'image(time'pos(now));
          cpu_req_out <= "1" & X"80" & X"00000000" & X"00000000";
                         -- "1" & X"801c00000062040000";
                         -- TODO will not work with the following address:
                         --"1" & WRITE_CMD &
                         --"10000000000000000000000000000000" &
                         --ZEROS32;
          st := 2;
        end if;
      elsif st = 2 then -- done
        -- TODO wait for resp
        --if is_valid(cpu_res_in) then
          sim_end <= '1';
        --end if;
        cpu_req_out<=(others =>'0');
      -- CPU_W20_TEST starts here
      elsif st = 20 then
        cpu_req_out <= (others => '0');
        if t4_tot_ct = 0 or is_valid(cpu_res_in) then
          t4_adr := rand_vect_range(2**6-1,7) & "000000000" & "0000000000000000";
          t4_dat := rand_vect_range(2**15-1,16) & "0000000000000000";
          st := 21;
        end if;
      elsif st = 21 then
        if t4_tot_ct < t4_tot then
          if cpu_id = 1 then
            cpu_req_out <= "1" & WRITE_CMD & t4_adr & t4_dat;
          else
            cpu_req_out <= "1" & READ_CMD & t4_adr & t4_dat;            
          end if;
          t4_tot_ct := t4_tot_ct + 1;
          st := 20;
        else
          st := 22;
        end if;
      elsif st = 22 then
        cpu_req_out <= (others => '0');
        --if is_valid(cpu_res_in) then
          st := 2;
        --end if;
      elsif st = 30 then -- CPU1_RW_04_TEST starts here
        if(cpu_id = 1) then
          cpu_req_out <= "1" & WRITE_CMD & X"1c000000" & X"00000001";
          st := 31;
        end if;
      elsif st = 31 then
        if(cpu_id = 1) and is_valid(cpu_res_in) then
          cpu_req_out <= "1" & READ_CMD & X"1c000000" & X"00000000";
          st := 32;
        end if;
      elsif st = 32 then -- CPU1_RW_04_TEST ends here
        cpu_req_out <= (others => '0');
      -- petersons algorithm starts here
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
        cpu_req_out <= "1" & WRITE_CMD &
                   t3_adr_me &
                   t3_dat1; -- flag[me] = 1; (req)
        st := 102;
      elsif st = 102 then -- wait_rsp
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
--          report "got response";
          st := 99; -- st delay
          st_nxt := 1022;
        end if;
      elsif st = 1022 then -- line 3
--        report "done! st is " & integer'image(st);
        cpu_req_out <= "1" & WRITE_CMD &
                       PT_VAR_TURN &
                       t3_dat1; -- turn = 1; (req)
        st := 103;
      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
--          report "got response";
          st := 99;
          st_nxt := 1032;
        end if;
      elsif st = 1032 then -- read flag[other]
        cpu_req_out <= "1" & READ_CMD &
                       t3_adr_other &
                       ZEROS32;
        st := 104;
      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
--          report "got response";
          if (get_dat(cpu_res_in) = t3_dat1) then
            st_nxt := 1042; --if flag[other]=1
          else
            st_nxt := 108; -- jump out of loop
        end if;
          st := 99;
        end if;
      elsif st = 1042 then
        cpu_req_out <= "1" & READ_CMD &
                       PT_VAR_TURN &
                       ZEROS32; -- read turn
        st := 105;
      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
          if (get_dat(cpu_res_in) = t3_dat1) then -- if turn=1
            st_nxt := 106; --TODO*
          else
            st_nxt := 108; -- jump out of loop
          end if;
        end if;
        st := 99;
      elsif st = 106 then -- busy wait
        st := 103;
      elsif st = 108 then -- line 6 (get val of shared)
        cpu_req_out <= "1" & READ_CMD &
                       PT_VAR_SHARED &
                       ZEROS32;
        st := 109;
      elsif st = 109 then -- wait_rsp
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
--          report "got response";
          st := 99; -- st delay
          st_nxt := 1092;          
        end if;
      elsif st = 1092 then
        cpu_req_out <= "1" & WRITE_CMD &
                       PT_VAR_SHARED &
                       std_logic_vector(unsigned(get_dat(cpu_res_in)) +
                                        unsigned(t3_dat1));
        st := 110;
      elsif st = 110 then
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
          st := 99;
          st_nxt := 1102;
        end if;
      elsif st = 1102 then
        cpu_req_out <= "1" & WRITE_CMD &
                       t3_adr_other &
                       ZEROS32;
        st := 111;
      elsif st = 111 then -- jmp to FOR_LOOP_START
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
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
end Behavioral;
