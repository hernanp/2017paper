library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity arbiter2_ack is
  Generic (
    constant DATA_WIDTH  : positive := 73
	);
  Port (
    clock: in std_logic;
    reset: in std_logic;
    
    din1: 	in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    ack1: 	out STD_LOGIC;
    
    din2:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
    ack2:	out std_logic;
    
    dout:	out std_logic_vector(DATA_WIDTH - 1 downto 0);
    ack : 	in  std_logic
    );
end arbiter2_ack;

-- version 2
architecture rtl of arbiter2_ack is

  signal s_ack1, s_ack2 : std_logic;
  signal s_token : std_logic;
  
begin  
  process (reset, clock)
    variable nilreq : std_logic_vector(DATA_WIDTH - 1 downto 0):=(others => '0');
    variable cmd: std_logic_vector( 1 downto 0);
    variable state : integer :=0;
  begin
    if reset = '1' then
      s_token <= '0';
      s_ack1 <= '0';
      s_ack2 <= '0';
      dout <=  nilreq;
    elsif rising_edge(clock) then
      if state =0 then
        cmd:= din1(DATA_WIDTH-1 downto DATA_WIDTH-1) & din2(DATA_WIDTH-1 downto DATA_WIDTH-1);
        dout <= nilreq;
        s_ack1 <= '0';
        s_ack2 <= '0';    
        case cmd is                  		      
          when "01" =>
            if s_ack2 = '0' then
              dout <=  din2;
              state :=1;
            end if;
          when "10" =>
            if s_ack1 = '0' then
              dout <= din1;
              state :=2;
              s_ack1 <= '1';
            end if;
          when "11" =>
            if s_token = '1' and s_ack2 ='0' then
              dout <= din2;
              state :=1;
              s_token <= '0';
            elsif s_token = '0' and s_ack1 ='0' then
              state :=2;
              dout <= din1;
              s_token <= '1';
            end if;
          when others =>
        end case;
      elsif state =1 then
        dout <= nilreq;
        if ack ='1' then
          s_ack2 <= '1';
          state :=0;
        end if;
      elsif state =2 then
        dout <= nilreq;
        if ack ='1' then
          s_ack1 <= '1';
          state :=0;
        end if;
      end if;
    end if;
    ack1 <= s_ack1;
    ack2 <= s_ack2;
  end process;
end architecture rtl;
