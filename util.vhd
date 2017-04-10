library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

package util is
  --* Returns true if data (73 bit long) has msb set to 1
  function is_valid(msg : std_logic_vector) return boolean;
  --* Returns true if CMD part of data matches cmd
  function cmd_eq(msg, cmd : std_logic_vector) return boolean;
  --* Returns true if DST part of data matches dev_id
  function dst_eq(msg, dev_id : std_logic_vector) return boolean;

  function get_dat(msg: MSG_T) return DAT_T;
end util;

package body util is
  function is_valid(msg : std_logic_vector) return boolean is
  begin
    if msg(MSG_WIDTH -1 downto MSG_WIDTH -1) = "1" then
      return true;
    end if;
    return false;
  end function;

  function cmd_eq(msg, cmd : std_logic_vector) return boolean is
  begin
    if msg(MSG_WIDTH - 2 downto MSG_WIDTH -9) = cmd then
      return true;
    end if;
    return false;
  end function;

  function dst_eq(msg, dev_id : std_logic_vector) return boolean is
  begin
    if msg(WMSG_WIDTH - 1 downto WMSG_WIDTH - 3) = dev_id then
      return true;
    end if;
    return false;
  end function;

  function get_dat(msg: MSG_T) return DAT_T is
  begin
    return msg(MSG_DAT_IDX + DAT_WIDTH - 1 downto MSG_DAT_IDX);
  end function;
  
end util;
