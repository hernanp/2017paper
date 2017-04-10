library ieee;
use ieee.std_logic_1164.all;
--use work.defs.all;

package test is
  -- enable/disable tracing
  constant GEN_TRACE1 : boolean := true;
  
  -- TESTS
  constant TDW : positive := 64;
  constant ZERO_TEST : std_logic_vector(TDW-1 downto 0) := (others => '0');
  --* cpu1 sends a read req
  constant CPU1_R_T : std_logic_vector(TDW-1 downto 0) := (1=>'1', others=>'0');
  --* cpu2 sends a write req
  constant CPU2_W_T : std_logic_vector(TDW-1 downto 0) := (2=>'1', others => '0');
  -- gfx upstream read req
  constant GFX_R_T : std_logic_vector(TDW-1 downto 0) := (3=>'1', others => '0');
  --* ic sends a pwr req to power up gfx
  constant IC_PWR_GFX_T : std_logic_vector(TDW-1 downto 0) := (4=>'1', others => '0');

  --* Warning: don't enable tests that are triggered on the same signals or
  --* weird things will happen.
  constant RUN_TEST : std_logic_vector(TDW-1 downto 0) := CPU1_R_T or
                                                          CPU2_W_T or
                                                          GFX_R_T; -- or
                                                          --IC_PWR_GFX_T;

  --* Checks if test is enabled
  function is_tset(test: std_logic_vector) return boolean;

end test;

package body test is
  function is_tset(test: std_logic_vector) return boolean is
  begin
    if (RUN_TEST and test) /= ZERO_TEST then
      return true;
    end if;
    return false;
  end function;    
end test;
        
