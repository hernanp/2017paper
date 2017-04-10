library ieee,std;
use ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
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
  --* t1: CPU1_R_TEST cpu1 sends a read req msg
  --* t2: CPU2_W_TEST cpu2 sends a write req msg
  --* t3: PETERSONS_TEST executes petersons algorithm
  cpu_test : process(reset, Clock)
    variable st : natural := 0;
    variable t1: boolean := false;
    variable t2: boolean := false;
    variable t3: boolean := false;
    variable t1_ct, t2_ct, t3_ct1, t3_ct2: natural;
    variable t3_adr_me, t3_adr_other: ADR_T; -- flag0 and flag1
    variable t3_dat1 : DAT_T := (0=>'1',others=>'0'); -- to cmp val of data=1 
  begin
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
    
    if reset = '1' then
      cpu_req_out <= (others => '0');
      if t1 and (cpu_id = 1)then
        t1_ct := rand_int(RAND_MAX_DELAY, to_int(t1_ct'instance_name),
                          to_integer(unsigned(CPU1_R_TEST)));
      --report "t1.delay is " & integer'image(ct1);
      end if;
      if t2 and (cpu_id = 2) then
        t2_ct := rand_int(RAND_MAX_DELAY, to_int(t2_ct'instance_name),
                          to_integer(unsigned(CPU2_W_TEST)));
      --report "t2.delay is " & integer'image(ct2);
      end if;
      st := 0;
    elsif (rising_edge(Clock)) then
      if st = 0 then -- wait
        if t1 and (cpu_id = 1) then
          if t1_ct > 0 then
            t1_ct := t1_ct-1;
          else
            st := 1;
          end if;
        end if;
        if t2 and (cpu_id = 2) then
          if t2_ct > 0 then
            t2_ct := t2_ct-1;
          else
            st := 1;
          end if;
        end if;
        if t3 then
          st := 100; -- petersons algorithm starts at state 100
        end if;
      elsif st = 1 then -- send
        -- send a random msg
        if t1 and (cpu_id = 1) then
          report "cpu1_r_test @ " & integer'image(time'pos(now));
          cpu_req_out <= "1" & READ_CMD &
                         "10000000000000000000000000000000" &
                         "00000000000000000000000000000000";
          st := 2;
        elsif t2 and (cpu_id = 2) then
          report "cpu2_w_test @ " & integer'image(time'pos(now));
          cpu_req_out <= "1" & WRITE_CMD &
                         "10000000000000000000000000000000" &
                         "00000000000000000000000000000000";
          st := 2;
        end if;
      elsif st = 2 then -- done
        -- TODO wait for resp
        cpu_req_out<=(others =>'0');
      -- petersons algorithm starts here
      elsif st = 100 then -- line 1 (for loop)
        if t3_ct1 < 500 then
          st := 101;
        else
          st := 2; -- done
        end if;
      elsif st = 101 then -- line 2
        cpu_req_out <= "1" & WRITE_CMD &
                   t3_adr_me &
                   t3_dat1; -- flag[me] = 1; (req)
        st := 102;
      elsif st = 102 then -- line 3
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then -- TODO check if check is ok
          cpu_req_out <= "1" & WRITE_CMD &
                         PT_VAR_TURN &
                         t3_dat1; -- turn = 1; (req)
          st := 103;
        end if;
      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
          cpu_req_out <= "1" & READ_CMD &
                         t3_adr_other &
                         ZEROS32; -- read flag[other]
          st := 104;
        end if;
      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
        if is_valid(cpu_res_in) then
          if (get_dat(cpu_res_in) = t3_dat1) then -- if flag[other] = 1
            cpu_req_out <= "1" & READ_CMD &
                           PT_VAR_TURN &
                           ZEROS32; -- read turn
            st := 105; 
          else
            st := 108; -- jump out of loop
          end if;
        end if;
      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
        if is_valid(cpu_res_in) then
          if (get_dat(cpu_res_in) = t3_dat1) then -- if turn=1
            st := 106;
          else
            st := 108; -- jump out of loop
          end if;
        end if;
      elsif st = 106 then -- gen rand delay
        st := 107;
      elsif st = 107 then -- line 5 (busy wait)
        -- TODO
        st := 103;
      elsif st = 108 then -- line 6 (get val of shared)
        cpu_req_out <= "1" & READ_CMD &
                       PT_VAR_SHARED &
                       ZEROS32;
        st := 109;
      elsif st = 109 then
        if is_valid(cpu_res_in) then
          cpu_req_out <= "1" & WRITE_CMD &
                         PT_VAR_SHARED &
                         std_logic_vector(unsigned(get_dat(cpu_res_in)) +
                                          unsigned(t3_dat1));
          st := 110;
        end if;
      elsif st = 110 then
        if is_valid(cpu_res_in) then
          cpu_req_out <= "1" & WRITE_CMD &
                         t3_adr_other &
                         ZEROS32;
          st := 111;
        end if;
      elsif st = 111 then -- jmp to FOR_LOOP_START
        if is_valid(cpu_res_in) then
          st := 100;
        end if;
      end if;
    end if;
  end process;
    
--=======
--  cpu1_r_test : process(reset, Clock)
--    variable st : natural := 0;
--  begin
--    ---if RUN_TEST = CPU1_R_T then
--      if reset = '1' then
--        cpu_req <= (others => '0');
--        st := 0;
		  
--      elsif (rising_edge(Clock)) then
--        if st = 0 then
--          st := 1;
--			 addr<=rand_vect_range(2**6-1,7)&"000000000"&"0000000000000000";
--			 data<=rand_vect_range(2**15-1,16)&"0000000000000000";
--        elsif st = 1 then
--          -- send a random msg
--          if cpu_id = 1 then
--            --- cpu_req <= rand_req(write);
--            cpu_req <= "110000000"&addr &data;
--          end if;
--          st := 2;
--        elsif st = 2 then
--          -- TODO wait for resp
--				cpu_req<=(others =>'0');
--				if (cpu_res(72 downto 72)="1") then
--					st :=0;
--				end if;
--        end if;
--      end if;
--   --- end if;
-->>>>>>> upstream/master
--  end process;
    
end Behavioral;
