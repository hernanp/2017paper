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

  function get_dat(msg: std_logic_vector) return std_logic_vector;

  procedure delay(variable cnt: inout natural;
                  variable st : inout natural;
                  constant next_st : in natural);
end util;

package body util is
  function is_valid(msg : std_logic_vector) return boolean is
  begin
    if msg(73 -1 downto 73 -1) = "1" then
      return true;
    end if;
    return false;
  end function;

  function cmd_eq(msg, cmd : std_logic_vector) return boolean is
  begin
    if msg(73 - 2 downto 73 -9) = cmd then
      return true;
    end if;
    return false;
  end function;

  function dst_eq(msg, dev_id : std_logic_vector) return boolean is
  begin
    if msg(EXT_DATA_WIDTH - 1 downto EXT_DATA_WIDTH - 3) = dev_id then
      return true;
    end if;
    return false;
  end function;

  function get_dat(msg: std_logic_vector) return std_logic_vector is
  begin
    return msg(31 downto 0);
  end function;

  procedure delay(variable cnt: inout natural;
                  variable st : inout natural;
                  constant next_st : in natural) is
  begin
    if cnt > 0 then
      cnt := cnt - 1;
    else
      st := next_st;
    end if;
  end;
end util;
