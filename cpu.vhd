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
  --cpu1_r_test : process(reset, Clock)
  --  variable st : natural := 0;
  --begin
  --  if RUN_TEST = CPU1_R_T then
  --    if reset = '1' then
  --      cpu_req <= (others => '0');
  --      st := 0;
  --    elsif (rising_edge(Clock)) then
  --      if st = 0 then
  --        st := 1;
  --      elsif st = 1 then
  --        -- send a random msg
  --        if cpu_id = 1 then
  --          --- cpu_req <= rand_req(write);
  --          cpu_req <= "110000000" &
  --                     "10000000000000000000000000000000" &
  --                     "00000000000000000000000000000000";
  --        end if;
  --        st := 2;
  --      elsif st = 2 then
  --        -- TODO wait for resp
  --  	  cpu_req<=(others =>'0');
  --      end if;
  --    end if;
  --  end if;
  --end process;

  --* CPU2_W_T cpu2 sends a write req msg
  cpu_test : process(reset, Clock)
    variable st : natural := 0;
    variable t1: boolean := false;
    variable t2: boolean := false;
  begin
    if is_tset(CPU1_R_T) then
      t1 := true;
    end if;
    if is_tset(CPU2_W_T) then
      t2 := true;
    end if;
    
    if reset = '1' then
      cpu_req_out <= (others => '0');
      st := 0;
    elsif (rising_edge(Clock)) then
      if st = 0 then
        st := 1;
      elsif st = 1 then
        -- send a random msg
        if t1 and (cpu_id = 1) then
          report "t1";
          --- cpu_req <= rand_req(write);
          cpu_req_out <= "110000000" &
                     "10000000000000000000000000000000" &
                     "00000000000000000000000000000000";
        elsif t2 and (cpu_id = 2) then
          report "t2";
          cpu_req_out <= "101000000" &
                     "10000000000000000000000000000000" &
                     "00000000000000000000000000000000";            
        end if;
        st := 2;
      elsif st = 2 then
        -- TODO wait for resp
        cpu_req_out<=(others =>'0');
      end if;
    end if;
  end process;

end Behavioral;
