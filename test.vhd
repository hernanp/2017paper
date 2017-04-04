library ieee;
use ieee.std_logic_1164.all;
--use work.defs.all;

package test is
  -- TESTS
  constant TDW : positive := 64;
  -- [SRC_DEV_ID DST_DEV_ID CMD]

  --* cpu1 sends a read req msg
  constant CPU1_R_T : std_logic_vector(TDW-1 downto 0) := (1=>'1', others=>'0');
  
  --* cpu2 sends a write req msg
  constant CPU2_W_T : std_logic_vector(TDW-1 downto 0) := (2=>'1', others => '0');

  --* ic sends a pwr req to power up gfx
  constant IC_PWR_GFX_T : std_logic_vector(TDW-1 downto 0) := (3=>'1', others => '0');

  constant RUN_TEST : std_logic_vector(TDW-1 downto 0) := IC_PWR_GFX_T; --(others => '0');
  
  constant GEN_TRACE1 : boolean := false;
end test;
