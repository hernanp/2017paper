library ieee,std;
use ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;
use work.rand.all;
use work.util.all;
use work.test.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity cpu is
  Port(reset   : in  std_logic;
       Clock   : in  std_logic;
       cpu_id   : in  integer;
       cpu_res : in  std_logic_vector(72 downto 0);
       cpu_req : out std_logic_vector(72 downto 0);
       full_c  : in  std_logic -- an input signal from cache, enabled when
                               -- cache is full TODO confirm
       );
end cpu;

architecture Behavioral of cpu is

begin
 cpu1_r_test : process
  begin
         wait for 100 ps;
			if cpu_id=1 then
				cpu_req <= "110000000"&"00011111000111110001111100011111"&"11110000111100001111000011110000";
				wait for 10 ps;
				cpu_req <=(others =>'0');
			
			
				wait for 700 ps;
				cpu_req <= "101000000"&"00011111000111110001111100011111"&"00000000000000000000000000000000";
				wait for 10 ps;
				cpu_req <=(others =>'0');
				wait;
			end if;
  end process;


end Behavioral;
