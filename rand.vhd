library ieee;
use ieee.math_real.all; -- for uniform fun
use ieee.numeric_std.all; -- for int to std_logic_vect conversion
use ieee.std_logic_1164.all;
use work.type_defs.all;

package rand is
  --+ seeds
  constant SEED1: integer:= 844396720;
  constant SEED2: integer:= 821616997;

  --* Returns a number between 1 and num.
  function rand_int(constant num:in integer) return integer;
  --* Returns a std_logic_vector of size bits.
  function rand_vect(constant size:in integer) return std_logic_vector;
  --* Returns a std_logic_vector of size bits between 1 and num.
  function rand_vect_range(constant num:in integer;
                      constant size:in integer) return std_logic_vector;
  --* Returns random delay between lower and upper.
  function rand_delay(constant l:in integer;
                    constant u:in integer) return time;
  
  --* Returns a random request with command cmd
  function rand_req(cmd:CMD_TYP) return std_logic_vector;
end rand;

package body rand is
  function rand_int(constant num:in integer) return integer is
    variable result:integer;
    variable s1:integer := SEED1;
    variable s2:integer := SEED2;
    variable tmp_real: real; 
  begin
    uniform(s1,s2,tmp_real);
    result := 1 + integer(trunc(tmp_real * real(num)));
    return (result);
  end rand_int;

  function rand_vect(constant size:in integer)
    return std_logic_vector is
    variable s1:integer := SEED1;
    variable s2:integer := SEED2;    
    variable result:std_logic_vector(size-1 downto 0);
    variable tmp_real:real;
  begin
    uniform(s1,s2,tmp_real);
    result := std_logic_vector(to_unsigned(integer(trunc(tmp_real * real (2**size)))+1, size));
    return (result);
  end rand_vect;
  
  function rand_vect_range(constant num:in integer;
                       constant size:in integer)
    return std_logic_vector is
    variable s1:integer := SEED1;
    variable s2:integer := SEED2;
    variable result:std_logic_vector(size-1 downto 0);
    variable tmp_real:real;
  begin
    uniform(s1,s2,tmp_real);
    -- TODO replace with std_logic_vector(to_unsigned(..)) # or to_signed(..),
    -- so that ieee.std_logic_arith is not needed
    result := std_logic_vector(to_signed(integer(trunc(tmp_real * real (num)))
                                      +1,size));
    return (result);
  end rand_vect_range;

  function rand_delay(constant l:in integer;
                      constant u:in integer) return time is
    variable s1:integer := SEED1;
    variable s2:integer := SEED2;
    variable result:time;
    variable tmp : real;
  begin
    uniform(s1,s2,tmp);
    result:=(((tmp * real(u - 1)) + real(l)) * 1 ns);
    return result;
  end rand_delay;

  function rand_req(cmd:CMD_TYP) return std_logic_vector is
    variable addr : std_logic_vector(31 downto 0) :=
      rand_vect(32);
    variable data : std_logic_vector(31 downto 0) :=
      rand_vect(32);
  begin
    if cmd = read then
      return WRITE_CMD & addr & data;
    elsif cmd = write then 
      return READ_CMD & addr & data;
    else
      return ZEROS_CMD & addr & data; 
    end if;
  end rand_req;
end rand;
