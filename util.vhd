library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

package util is
  --* Returns true if data (73 bit long) has msb set to 1
  function is_valid(data : std_logic_vector) return boolean;
  --* Returns true if CMD part of data matches cmd
  function cmd_eq(data, cmd : std_logic_vector) return boolean;
  --* Returns true if DST part of data matches dev_id
  function dst_eq(data, dev_id : std_logic_vector) return boolean;
end util;

package body util is
  function is_valid(data : std_logic_vector) return boolean is
  begin
    if data(DATA_WIDTH -1 downto DATA_WIDTH -1) = "1" then
      return true;
    end if;
    return false;
  end function;

  function cmd_eq(data, cmd : std_logic_vector) return boolean is
  begin
    if data(DATA_WIDTH - 2 downto DATA_WIDTH -9) = cmd then
      return true;
    end if;
    return false;
  end function;

  function dst_eq(data, dev_id : std_logic_vector) return boolean is
  begin
    if data(EXT_DATA_WIDTH - 1 downto EXT_DATA_WIDTH - 4) = dev_id then
      return true;
    end if;
    return false;
  end function;
end util;
