library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

entity arbiter2 is
  Generic (
    constant DATA_WIDTH  : positive := MSG_WIDTH
	);
  Port (
    clock: in std_logic;
    reset: in std_logic;
    
    din1: 	in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    ack1: 	out STD_LOGIC;
    
    din2:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
    ack2:	out std_logic;
    
    dout:	out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end arbiter2;

-- version 2
architecture rtl of arbiter2 is

  signal s_ack1, s_ack2 : std_logic;
  signal wb_flag : std_logic;
  
begin
  process (reset, clock)
    variable nilreq : std_logic_vector(DATA_WIDTH - 1 downto 0):=(others => '0');
    variable cmd: std_logic_vector( 1 downto 0);
  begin
    if reset = '1' then
      wb_flag <= '0';
      s_ack1 <= '0';
      s_ack2 <= '0';
      dout <=  nilreq;
    elsif rising_edge(clock) then
      cmd:= din1(DATA_WIDTH-1 downto DATA_WIDTH-1) & din2(DATA_WIDTH-1 downto DATA_WIDTH-1);
      dout <= nilreq;
      s_ack1 <= '0';
      s_ack2 <= '0';    
      case cmd is    		      
        when "01" =>
          if s_ack2 = '0' then
            dout <=  din2;
            s_ack2 <= '1';
          end if;
        when "10" =>
          if s_ack1 = '0' then
            dout <= din1;
            s_ack1 <= '1';
          end if;
        when "11" =>
          if wb_flag = '1' and s_ack2 ='0' then
            dout <= din2;
            s_ack2 <= '1';
            wb_flag <= '0';
          elsif wb_flag = '0' and s_ack1 ='0' then
            dout <= din1;
            s_ack1 <= '1';
            wb_flag <= '1';
          end if;
        when others =>
      end case;
    end if;
    ack1 <= s_ack1;
    ack2 <= s_ack2;
  end process;
end architecture rtl;   
