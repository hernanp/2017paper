library ieee;
use ieee.math_real.all; -- for uniform fun
use ieee.numeric_std.all; -- for int to std_logic_vect conversion
use ieee.std_logic_1164.all;
use work.defs.all;

package rand is
  constant RAND_MAX_DELAY: natural := 10;
  
  --+ seeds
  constant SEED1: integer:= 844396720;
  constant SEED2: integer:= 821616997;

  constant sd1: positive := 844396720;
  constant sd2: positive := 821616997;

  --* Given a string, returns an int
  function to_int(constant s:string) return integer;
  
  --* Returns a number between 1 and num.
  function rand_nat(constant max:in natural; seed:natural) return natural;

  function rand_int(constant max:in integer; seed1, seed2:integer) return integer;
    
  --* Returns a number between 1 and num.
  function rand_int(constant max:in integer; seed:integer) return integer;

  ----* Returns a std_logic_vector of size bits.
  --function rand_vect(constant size:in integer) return std_logic_vector;

  --* Returns a std_logic_vector of size bits between 1 and num.
  function rand_vect_range(constant num:in integer;
                      constant size:in integer) return std_logic_vector;

  ----* Returns random delay between lower and upper.
  --function rand_delay(constant l:in integer;
  --                  constant u:in integer) return time;
  
  ----* Returns a random request with command cmd
  --function rand_req(cmd:CMD_TYP) return std_logic_vector;
end rand;

package body rand is
  function to_int(constant s:string) return integer is
    variable sum : integer := 0;
  begin
    for i in s'range loop
      sum := sum + character'pos(s(i));
    end loop;
    return sum;
  end to_int;

  --* Returns an random nat between 0 to max
  function rand_nat(constant max:in natural; seed:natural) return natural is
  begin
    return ((seed + time'pos(now)) mod max);
  end rand_nat;

  --* Returns an random nat between 0 to max
  function rand_int(constant max:in integer; seed1, seed2:integer) return integer is
  begin
    return ((seed1 + seed2 + time'pos(now)) rem max);
  end rand_int;
  
  -- renamed from selection to rand_int
  --* Returns an random integer between 0 to max
  function rand_int(constant max:in integer; seed:integer) return integer is
    variable result:integer;
    variable s1:positive := sd1;
    variable s2:positive := seed;
    variable tmp_real: real;
  begin
    -- TODO uniform always returns the same value? (given the same
    -- seeds)
    --uniform(s1,s2,tmp_real);
    --result := 1 + integer(trunc(tmp_real * real(max)));

    result := (seed + time'pos(now)) mod max;

    return (result);
  end rand_int;
  
  --function rand_vect(constant size:in integer)
  --  return std_logic_vector is
  --  variable s1:integer := SEED1;
  --  variable s2:integer := SEED2;    
  --  variable result:std_logic_vector(size-1 downto 0);
  --  variable tmp_real:real;
  --begin
  --  uniform(s1,s2,tmp_real);
  --  --report "val: " & real'image(tmp_real);
  --  result := std_logic_vector(to_unsigned(integer(tmp_real * real (2**size -1)), size));
  --  --report "val: " & to_string(result) severity NOTE;
  --  return (result);
  --end rand_vect;
  
  function rand_vect_range(constant num:in integer;
                       constant size:in integer)
    return std_logic_vector is
    variable s1:integer := SEED1;
    variable s2:integer := SEED2;
    variable result:std_logic_vector(size-1 downto 0);
    variable tmp_real:real;
  begin
    uniform(s1,s2,tmp_real);
    result := std_logic_vector(to_signed(integer(trunc(tmp_real * real (num)))
                                      +1,size));
    return (result);
  end rand_vect_range;

  --function rand_delay(constant l:in integer;
  --                    constant u:in integer) return time is
  --  variable s1:integer := SEED1;
  --  variable s2:integer := SEED2;
  --  variable result:time;
  --  variable tmp : real;
  --begin
  --  uniform(s1,s2,tmp);
  --  result:=(((tmp * real(u - 1)) + real(l)) * 1 ns);
  --  return result;
  --end rand_delay;

  --function rand_req(cmd:CMD_TYP) return std_logic_vector is
  --  variable addr : std_logic_vector(31 downto 0) :=
  --    rand_vect(32);
  --  variable data : std_logic_vector(31 downto 0) :=
  --    rand_vect(32);
  --  constant valid_bit : std_logic := '1';
  --begin
  --  if cmd = read then
  --    return valid_bit & WRITE_CMD & addr & data;
  --  elsif cmd = write then 
  --    return valid_bit & READ_CMD & addr & data;
  --  else
  --    return valid_bit & ZEROS_CMD & addr & data; 
  --  end if;
  --end rand_req;
end rand;
