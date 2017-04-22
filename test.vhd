library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
use work.rand.all;

package test is
  -- enable/disable tracing
  constant GEN_TRACE1 : boolean := true;
  
  -- TESTS
  constant TDW : positive := 64;
  subtype TEST_T is std_logic_vector(TDW-1 downto 0);
  constant ZERO_TEST : TEST_T := (others => '0');

  --* cpu1 sends a read req
  constant CPU1_R_TEST : TEST_T := (0=>'1', others=>'0');
  --* cpu2 sends a write req
  constant CPU2_W_TEST : TEST_T := (1=>'1', others => '0');
  
  --* cpu 1 and 2 send 20 rand write reqs (each)
  constant CPU_W20_TEST : TEST_T := (2=>'1', others=>'0');

  --* CPU1_RW_04_TEST cpu1 writes and reads to mem[0..4]
  -- constant CPU1_RW_04_TEST : TEST_T := (3=>'1', others=>'0');
  -- to enable, also need to uncomment code in cpu.vhd
  
  -- gfx upstream read req
  --constant GFX_R_TEST : TEST_T := (4=>'1', others => '0');
  
  
  -- test delay flag, used by rnd_dlay fun to re-enable rndmz_flg 
  constant TDLAY_FLG : boolean := true;

  --********* PWR TEST ************
  constant PWR_TEST : TEST_T := (5=>'1', others => '0');
  constant PWRT_CNT : natural := 1;

  --********* PETERSONS TEST ************
  --* cpus 1 and 2 execute petersons algorithm
  constant PETERSONS_TEST : TEST_T := (6=>'1', others => '0');
  constant PT_DELAY_FLAG : boolean := true;
  constant PT_ITERATIONS : natural := 50;
  -- petersons' shared variables
  constant PT_VAR_FLAG0 : ADR_T := (1=>'1', others=>'0'); -- M[1]
  constant PT_VAR_FLAG1 : ADR_T := (2=>'1', others=>'0'); -- M[2]
  constant PT_VAR_TURN : ADR_T := (2=>'1', 1=>'1', others=>'0'); -- M[3]
  constant PT_VAR_SHARED : ADR_T := (3=>'1', others=>'0'); -- M[4]
  procedure pt_delay(variable rndmz_dlay : inout boolean;
                     variable seed: inout natural;
                     variable cnt: inout natural;
                     variable st : inout natural;
                     constant next_st : in natural);


  --********* UREQ TEST ************
  constant UREQ_TEST : TEST_T := (7=>'1', others => '0');
  constant UREQT_CNT : natural := 1;

  --********* RW TEST ************
  -- sends rnd(rd|wr) reqs from cpu(0|1) w/rnd dlays
  constant RW_TEST : TEST_T := (8=>'1', others => '0');
  constant RWT_CNT : natural := 1;
  
  --* Warning: don't enable tests that are triggered on the same signals or
  --* weird things will happen.
  constant RUN_TEST : TEST_T := --RW_TEST or
                                --PWR_TEST or
                                UREQ_TEST;
                                --PETERSONS_TEST;
                                --ZERO_TEST;

  procedure rnd_dlay(variable rndmz_dlay : inout boolean; 
                     variable seed : inout natural;
                     variable cnt: inout natural; 
                     variable st : inout natural;
                     constant next_st : in natural);
  
  --* Checks if test is enabled
  function is_tset(test: std_logic_vector) return boolean;

  --procedure check_inv(variable timer : inout time;
  --                    constant mark : in time;
  --                    constant cond : in boolean;
  --                    constant msg : in string);
end test;

package body test is
  procedure pt_delay(variable rndmz_dlay : inout boolean;
                     variable seed : inout natural;
                     variable cnt: inout natural;
                     variable st : inout natural;
                     constant next_st : in natural) is
  begin
    if rndmz_dlay and st /= next_st then -- start
      --report "start";
      cnt := rand_nat(to_integer(unsigned(PETERSONS_TEST)) + seed);
      seed := seed + 1;
      rndmz_dlay := false;
--      report "pt_delay.cnt" & integer'image(cnt);
      delay(cnt, st, next_st);
    elsif (rndmz_dlay = false) then -- count
      --report "count";
      delay(cnt, st, next_st);
    end if;
    
    if st = next_st and PT_DELAY_FLAG then -- if done, set flag back to true
      --report "done";
      rndmz_dlay := true;
    end if;

    --report integer'image(cnt) & "," &
    --  integer'image(st) & "," &
    --  integer'image(next_st) & "," &
    --  boolean'image(rndmz_dlay);
  end;

  -- A generalized version of pt_delay
  -- @rndmz_dlay : flag, indicates if rndmly select value for cnt or start from
  -- current value of cnt; turned off while counting; turned on when done (if
  -- TDLAY_FLG is set)
  -- @seed : a num to offset rnd assignment, will be incremented once (if
  -- rmdmz_dlay is set)
  -- @cnt : counter current val will be read/written to cnt
  -- @st : current st
  -- @next_st : where to jump when done
  --
  -- Usage example:
  --   f := true;
  --   s := 0;
  --   st := 0;
  --   nxt_st := 1;
  --   rnd_dlay(f, s, c, st, nxt_st); 
  procedure rnd_dlay(variable rndmz_dlay : inout boolean; 
                     variable seed : inout natural;
                     variable cnt: inout natural; 
                     variable st : inout natural;
                     constant next_st : in natural) is
  begin
    if rndmz_dlay and st /= next_st then -- start
      cnt := rand_nat(to_integer(unsigned(PETERSONS_TEST)) + seed);
      seed := seed + 1;
      rndmz_dlay := false;
      delay(cnt, st, next_st);
    elsif (rndmz_dlay = false) then -- count
      delay(cnt, st, next_st);
    end if;
    
    if st = next_st and TDLAY_FLG then -- if done, set flag back to true
      rndmz_dlay := true;
    end if;
  end;
  
  function is_tset(test: std_logic_vector) return boolean is
  begin
    if (RUN_TEST and test) /= ZERO_TEST then
      return true;
    end if;
    return false;
  end function;

  --procedure check_inv(variable timer : inout time;
  --                    constant mark : in time;
  --                    constant cond : in boolean;
  --                    constant msg : in string) is
  --begin
  --  --wait for mark - timer;
  --  timer := mark;
  --  assert cond report msg severity error;
  --end;
end test;
        
