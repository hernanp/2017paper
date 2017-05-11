library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.defs.all;

package util is
  --* Returns true if data (73 bit long) has msb set to 1
  function is_valid(msg : std_logic_vector) return boolean;
  --* Returns true if CMD part of data matches cmd
  function cmd_eq(msg, cmd : std_logic_vector) return boolean;
  --* Returns true if DST part of data matches dev_id
  function dst_eq(msg, dev_id : std_logic_vector) return boolean;

  --+ getters
  function get_dat(msg: MSG_T) return DAT_T;
  function get_adr(msg: MSG_T) return ADR_T;
  function get_cmd(msg: MSG_T) return CMD_T;

  function is_pwr_cmd(msg : std_logic_vector) return boolean;
  --* returns true if adr's msb is 1
  function is_mem_req(msg: std_logic_vector) return boolean;

  --* delay st transition for cnt clock cycles
  procedure delay(variable cnt: inout natural;
                  variable st : inout natural;
                  constant next_st : in natural);

  --* left pad
  function pad32(v : IPTAG_T) return ADR_T;

  function rpad(v : MSG_T) return BMSG_T;

  --+ Poor man's logger
  type LOG_LEVEL_T is (OFF, ERROR, INFO, DEBUG);
  constant LOG_LEVEL : LOG_LEVEL_T := DEBUG;
  procedure log(constant s : in string; constant l : in LOG_LEVEL_T);
  procedure log(constant v : in std_logic_vector);
  procedure log_chg(constant s : in string;
                    constant st : in integer;
                    variable prev_st : inout integer);

  --+ info funs: only ouptut if logging level is INFO
  procedure inf(constant s : in string);
  
  --+ debugging funs: only output if logging level is DEBUG
  procedure dbg(constant s : in string);
  procedure dbg(constant v : in std_logic_vector);
  procedure dbg_chg(constant s : in string;
                    constant st : in integer;
                    variable prev_st : inout integer);

  --* log request
  procedure req(signal sig : out std_logic_vector;
                constant v : in std_logic_vector;
                constant str : in string);
  
  --+ type casting
  function str(n : integer) return string;
  function str(n : IP_T) return string;
  function nat(n : IP_T) return natural;
  function uint(v : std_logic_vector) return integer;
  
  --procedure clr(signal vector : out std_logic_vector);
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
  
  function get_adr(msg: MSG_T) return ADR_T is
  begin
    return msg(MSG_ADR_IDX + ADR_WIDTH - 1 downto MSG_ADR_IDX);
  end function;
  
  function get_cmd(msg: MSG_T) return CMD_T is
  begin
    return msg(MSG_CMD_IDX + CMD_WIDTH - 1 downto MSG_CMD_IDX);
  end function;
  
  procedure delay(variable cnt: inout natural;
                  variable st : inout natural;
                  constant next_st : in natural) is
  begin
--    report "delay is " & integer'image(cnt);
    if cnt > 0 then
      cnt := cnt - 1;
    else
      st := next_st;
    end if;
  end;

  function is_pwr_cmd(msg : std_logic_vector) return boolean is
  begin
    if (get_cmd(msg) = PWRUP_CMD) or
      (get_cmd(msg) = PWRDN_CMD) then
      return true;
    end if;
    return false;
  end;

  function is_mem_req(msg: std_logic_vector) return boolean is
  begin
    if msg(63 downto 63) = "1" then
      return true;
    end if;
    return false;
  end;
  
  --procedure clr(signal vector : out std_logic_vector) is
  --begin
  --  vector <= (others => '0');
  --end;

  function pad32(v : IPTAG_T) return ADR_T is
  begin
    return X"0000000" & "0" & v;
  end;

  function rpad(v : MSG_T) return BMSG_T is
    variable pad : std_logic_vector(479 downto 0) := (others => '0');
  begin
    return v & pad;
  end;

  procedure log(constant s : in string; constant l : in LOG_LEVEL_T) is
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(l) then
      report s;
    end if;
  end;

  procedure log(constant v : in std_logic_vector) is
    variable l : line;
  begin
    hwrite(l, v);
    writeline(output, l);
  end;
  
  procedure log_chg(constant s: in string;
                    constant st : in integer;
                    variable prev_st : inout integer) is
  begin
    if st /= prev_st then
      log(s & " " & str(st), INFO);
      prev_st := st;
    end if;
  end;

  procedure inf(constant s : in string) is
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(INFO) then
      report s;
    end if;
  end;
  
  procedure dbg(constant s : in string) is
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(DEBUG) then
      report s;
    end if;
  end;

  procedure dbg(constant v : in std_logic_vector) is
    variable l : line;
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(DEBUG) then
      hwrite(l, v);
      writeline(output, l);
    end if;
  end;
  
  procedure dbg_chg(constant s: in string;
                    constant st : in integer;
                    variable prev_st : inout integer) is
  begin
    if st /= prev_st then
      if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(DEBUG) then
        log(s & " " & str(st), DEBUG);
      end if;
      prev_st := st;
    end if;
  end;
  
  procedure req(signal sig : out std_logic_vector;
                constant v : in std_logic_vector;
                constant str : in string) is
    variable cmd : string(1 to 2);
    variable msg : string(1 to 6);
  begin
    if get_cmd(v) = WRITE_CMD then
      cmd := "wr";
      msg := " to M[" & str(to_integer(unsigned(get_adr(v)))) & "]: ";
    elsif get_cmd(v) = READ_CMD then
      cmd := "rd";
      msg := " to M[" & str(to_integer(unsigned(get_adr(v)))) & "]: ";
    elsif get_cmd(v) = PWRUP_CMD then
      cmd := "pu";
      msg := " " & str(to_integer(unsigned(get_adr(v)))) &
             " -> " & str(to_integer(unsigned(get_dat(v)))) & " : ";
    elsif get_cmd(v) = PWRDN_CMD then
      cmd := "pd";
      msg := " " & str(to_integer(unsigned(get_adr(v)))) &
             " -> " & str(to_integer(unsigned(get_dat(v)))) & " : ";
    end if;

    log(cmd & msg & str, DEBUG);
    sig <= v;
  end;
  
  function str(n : integer) return string is
  begin
    return integer'image(n);
  end;

  function str(n : IP_T) return string is
  begin
    return IP_T'image(n);
  end;

  function nat(n : IP_T) return natural is
  begin
    return IP_T'pos(n);
  end;

  function uint(v : std_logic_vector) return integer is
  begin
    return to_integer(unsigned(v));
  end;
  
end util;
