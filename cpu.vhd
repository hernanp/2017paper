--* Process req1:
--* <pre> 
--*    reset/ cpu_req <= others(0)
--*  +-----------------------------+
--*  v                             |
--* +---------------------------------+
--* |               st0               |
--* +---------------------------------+
--*   ^ clk/cpu_req <= tmp_req      |
--*   +-----------------------------+
--* </pre>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.nondeterminism.all;

use std.textio.all;
use IEEE.std_logic_textio.all;

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
  signal tmp_req : std_logic_vector(72 downto 0);

  --* TODO why are these signals are not being used?
  signal rand1 : integer                       := 1;
  signal rand2 : std_logic_vector(31 downto 0) := "01101010101010101010101010101010";
  signal rand3 : std_logic_vector(31 downto 0) := "10101010101010101010101010101010";

  --* wrapper fun to create read_req given an addr, req (?) and some data
  -- TODO what is req here?
  procedure read(variable adx  : in  std_logic_vector(31 downto 0);
                 signal req    : out std_logic_vector(72 downto 0);
                 variable data : out std_logic_vector(31 downto 0)) is
  begin
    --* TODO what does this value mean?
    req <= "101000000" & adx & "00000000000000000000000000000000";
    req <= (others => '0');
    if cpu_res(72 downto 72) = "1" then
      data := cpu_res(31 downto 0);
    end if;
  end read;

  --* wrapper fun to create write_req given an address, a req (?), and some data
  -- TODO what is req here?
  procedure write(variable adx  : in  std_logic_vector(31 downto 0);
                  signal req    : out std_logic_vector(72 downto 0);
                  variable data : in  std_logic_vector(31 downto 0)) is
  begin
    req <= "110000000" & adx & data;
    req <= (others => '0');
    if cpu_res(72 downto 72) = "1" then
    end if;
  end write;

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
  req1 : process(reset, Clock)
  begin
    if reset = '1' then
      cpu_req <= (others => '0');
    elsif (rising_edge(Clock)) then
      cpu_req <= tmp_req;
    end if;
  end process;
  
  --* processor 1 (2) generates random* write (read) request
  --* TODO *right now request is not random, why is random fun not being used?
  p1 : process(Clock)
    variable nilreq : std_logic_vector(72 downto 0) := (others => '0');

    -- cpu1_req.addr
    variable flag0 : std_logic_vector(31 downto 0) := "1010" & "1010" & "0010" &
                                                      "0000" & "0000" & "0000" &
                                                      "0011" & "0000";
    -- cpu1_req.data
    variable one : std_logic_vector(31 downto 0) := "0000" & "0000" & "0000" &
                                                    "0000" & "0000" & "0000" &
                                                    "0000" & "0001";
    
    -- cpu2_req.addr
    variable turn  : std_logic_vector(31 downto 0) := "1111" & "1111" & "0100" &
                                                      "0000" & "0000" & "0000" &
                                                      "0011" & "0000";
    -- cpu2_req.data
    variable turn_data : std_logic_vector(31 downto 0) := "0000" & "0000" & "0100" &
                                                          "0000" & "0000" & "0000" &
                                                          "0011" & "0000";
    -- not used
    variable line_output : line;
    variable logsr       : string(8 downto 1);

    -- vars for power messages
    variable pwrcmd      : std_logic_vector(1 downto 0);
    variable hwlc        : std_logic_vector(1 downto 0);
  begin
    ----wait for 80 ps;
    pwrcmd := "00";
    hwlc   := "00";
    ----power(pwrcmd, tmp_req, hwlc);
    -- TODO why is tmp_req is an empty message (not initialized)?
    if cpu_id = 1 then
      write(flag0, tmp_req, one);
    elsif cpu_id = 2 then
      read(turn, tmp_req, turn_data);
    end if;
  end process;
end Behavioral;
