--* Process req1:
--* <pre> 
--*    reset/ cpu_req <= 00...
--*  +-----------------------------+
--*  v                             |
--* +---------------------------------+
--* |               st0               |
--* +---------------------------------+
--*   ^ clk/cpu_req <= rand_req     |
--*   +-----------------------------+
--* </pre>

library ieee,std;
use ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.type_defs.all;
use work.rand.all;

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
  process(reset, Clock)
  begin
    if reset = '1' then
     -- cpu_req <= (others => '0');
      st <= init;
    elsif (rising_edge(Clock)) then
      st <= next_st;
    end if;
	 
  end process;
  
  transitions : process(st)
    ---- vars for power messages
    --variable pwrcmd      : std_logic_vector(1 downto 0);
    --variable hwlc        : std_logic_vector(1 downto 0);
  begin
    --pwrcmd := "00";
    --hwlc   := "00";
    ----power(pwrcmd, tmp_req, hwlc);
    -- TODO why is tmp_req is an empty message (not initialized)?
    --if cpu_id = 1 then
    --  write(flag0, tmp_req, one);
    --elsif cpu_id = 2 then
    --  read(turn, tmp_req, turn_data);
    --end if;
	 
    case st is
      when init =>
        -- output nothing
        cpu_req <= (others => '0');
        next_st <= send;
      when send =>
        -- send a random msg
        if cpu_id = 1 then
         --- cpu_req <= rand_req(write);
			 cpu_req<="110000000"&"10000000000000000000000000000000"&"00000000000000000000000000000000";
        elsif cpu_id = 2 then
          cpu_req<="101000000"&"10000000000000000000000000000000"&"00000000000000000000000000000000";
        end if;
        next_st <= idle;
      when idle =>
        -- TODO wait for resp
		  cpu_req<=(others =>'0');
        next_st <= idle;
    end case;
  end process;
end Behavioral;
