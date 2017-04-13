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
       cpu_res : in  std_logic_vector(72 downto 0);
       cpu_req : out std_logic_vector(72 downto 0);
       full_c  : in  std_logic -- an input signal from cache, enabled when
                               -- cache is full TODO confirm
       );
end cpu;

architecture Behavioral of cpu is
  --type states is (init, send, idle);
  --signal st, next_st : states;
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

begin
  --* CPU1_R_T cpu1 sends a read req msg
  cpu1_r_test : process(reset, Clock)
    variable st : natural := 0;
	variable total:integer :=0;
    variable wt: integer :=0;

  constant ZERO_MSG : std_logic_vector(72 downto 0) := (others => '0');
    
  -- petersons' shared variables
  constant PT_VAR_FLAG0 : std_logic_vector(31 downto 0) := (1=>'1', others=>'0'); -- M[1]
  constant PT_VAR_FLAG1 : std_logic_vector(31 downto 0) := (2=>'1', others=>'0'); -- M[2]
  constant PT_VAR_TURN : std_logic_vector(31 downto 0) := (2=>'1', 1=>'1', others=>'0'); -- M[3]
  constant PT_VAR_SHARED : std_logic_vector(31 downto 0) := (3=>'1', others=>'0'); -- M[4]
    
    --variable t3 : boolean := false;
    variable t3_ct1, t3_ct2, t3_ct3 : natural;
    variable t3_adr_me, t3_adr_other: std_logic_vector(31 downto 0); -- flag0 and flag1
    variable t3_dat1 : std_logic_vector(31 downto 0) := (0=>'1',others=>'0'); -- to cmp val of data=1
    
  begin
    ---if RUN_TEST = CPU1_R_T then
      if reset = '1' then
        cpu_req <= (others => '0');
        st := 0;
		  
      elsif (rising_edge(Clock)) then
        --if st = 0 and total < 20 then
        --  st := 1;
		--	 addr<=rand_vect_range(2**6-1,7)&"000000000"&"0000000000000000";
		--	 data<=rand_vect_range(2**15-1,16)&"0000000000000000";
        --elsif st = 1 then
        --  -- send a random msg
        --  --if cpu_id = 2 then
        --    --- cpu_req <= rand_req(write);
        --    cpu_req <= "110000000"&addr &data;
		--		total := total+1;
        --  --end if;
        --  st := 2;
        --elsif st = 2 then
        --  -- TODO wait for resp
		--		cpu_req<=(others =>'0');
		--		--wt := wt+1;
		--		if (cpu_res(72 downto 72)="1") then
		--			st :=0;
		--		end if;
        --end if;

      -- petersons algorithm starts here
      elsif st = 100 then -- line 1 (for loop)
        if t3_ct1 < 500 then
          st := 101;
          --TODO* replace previous line with randomly delayed transition below
          --t3_ct3 := rand_nat(0);
          --delay(t3_ct3, st, 101);
        else
          st := 2; -- done
        end if;
      elsif st = 101 then -- line 2
        cpu_req <= "1" & WRITE_CMD &
                   t3_adr_me &
                   t3_dat1; -- flag[me] = 1; (req)
        st := 102; -- TODO*
      elsif st = 102 then -- line 3
        cpu_req <= ZERO_MSG;
        if is_valid(cpu_res) then -- TODO check if check is ok
          cpu_req <= "1" & WRITE_CMD &
                         PT_VAR_TURN &
                         t3_dat1; -- turn = 1; (req)
          st := 103; --TODO*
        end if;
      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
        cpu_req <= ZERO_MSG;
        if is_valid(cpu_res) then
          cpu_req <= "1" & READ_CMD &
                         t3_adr_other &
                         ZEROS32; -- read flag[other]
          st := 104; --TODO*
        end if;
      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
        if is_valid(cpu_res) then
          if (get_dat(cpu_res) = t3_dat1) then -- if flag[other] = 1
            cpu_req <= "1" & READ_CMD &
                           PT_VAR_TURN &
                           ZEROS32; -- read turn
            st := 105; --TODO*
          else
            st := 108; -- jump out of loop
          end if;
        end if;
      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
        if is_valid(cpu_res) then
          if (get_dat(cpu_res) = t3_dat1) then -- if turn=1
            st := 106; --TODO*
          else
            st := 108; -- jump out of loop
          end if;
        end if;
      elsif st = 106 then -- gen rand delay
        st := 107;
      elsif st = 107 then -- line 5 (busy wait)
        -- TODO* delay(t3_ct3, st, 103)
        st := 103;
      elsif st = 108 then -- line 6 (get val of shared)
        cpu_req <= "1" & READ_CMD &
                       PT_VAR_SHARED &
                       ZEROS32;
        st := 109; --TODO*
      elsif st = 109 then
        if is_valid(cpu_res) then
          cpu_req <= "1" & WRITE_CMD &
                         PT_VAR_SHARED &
                         std_logic_vector(unsigned(get_dat(cpu_res)) +
                                          unsigned(t3_dat1));
          st := 110; --TODO*
        end if;
      elsif st = 110 then
        if is_valid(cpu_res) then
          cpu_req <= "1" & WRITE_CMD &
                         t3_adr_other &
                         ZEROS32;
          st := 111; --TODO*
        end if;
      elsif st = 111 then -- jmp to FOR_LOOP_START
        if is_valid(cpu_res) then
          st := 100; --TODO*
        end if;
      end if;
  -- end if;
  end process;
--
--  --* CPU2_W_T cpu2 sends a write req msg
--  cpu2_w_test : process(reset, Clock)
--    variable st : natural := 0;
--  begin
--   --- if RUN_TEST = CPU2_W_T then
--      if reset = '1' then
--        cpu_req <= (others => '0');
--        st := 0;
--      elsif (rising_edge(Clock)) then
--        if st = 0 then
--          st := 1;
--        elsif st = 1 then
--          if cpu_id = 2 then
--            cpu_req <= "101000000" &
--                       "10000000000000000000000000000000" &
--                       "00000000000000000000000000000000";
--          end if;
--          st := 2;
--        elsif st = 2 then
--          -- TODO wait for resp
--		  cpu_req<=(others =>'0');
--        end if;
--      end if;
--    end if;
--  end process;

end Behavioral;
