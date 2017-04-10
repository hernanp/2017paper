library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

package test is
  -- enable/disable tracing
  constant GEN_TRACE1 : boolean := true;
  
  -- TESTS
  constant TDW : positive := 64;
  subtype TEST_T is std_logic_vector(TDW-1 downto 0);
  constant ZERO_TEST : TEST_T := (others => '0');
  --* cpu1 sends a read req
  constant CPU1_R_TEST : TEST_T := (1=>'1', others=>'0');
  --* cpu2 sends a write req
  constant CPU2_W_TEST : TEST_T := (2=>'1', others => '0');
  -- gfx upstream read req
  constant GFX_R_TEST : TEST_T := (3=>'1', others => '0');
  --* ic sends a pwr req to power up gfx
  constant IC_PWR_GFX_TEST : TEST_T := (4=>'1', others => '0');

  --* cpus 1 and 2 execute petersons algorithm
  constant PETERSONS_TEST : TEST_T := (4=>'1', others => '0');
  -- petersons' shared variables
  constant PT_VAR_FLAG0 : ADR_T := (1=>'1', others=>'0'); -- M[1]
  constant PT_VAR_FLAG1 : ADR_T := (2=>'1', others=>'0'); -- M[2]
  constant PT_VAR_TURN : ADR_T := (2=>'1', 1=>'1', others=>'0'); -- M[3]
  constant PT_VAR_SHARED : ADR_T := (3=>'1', others=>'0'); -- M[4]
  
  --* Warning: don't enable tests that are triggered on the same signals or
  --* weird things will happen.
  constant RUN_TEST : TEST_T := ZERO_TEST;
                                                          --CPU1_R_TEST or
                                                          --CPU2_W_TEST or
                                                          --GFX_R_TEST; -- or
                                                          --IC_PWR_GFX_TEST;

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
        
