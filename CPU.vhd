library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.nondeterminism.all;

use std.textio.all;
use IEEE.std_logic_textio.all;

entity CPU is
	Port(reset   : in  std_logic;
		 Clock   : in  std_logic;
		 seed    : in  integer;
		 cpu_res : in  std_logic_vector(72 downto 0);
		 cpu_req : out std_logic_vector(72 downto 0);
		 full_c  : in  std_logic
	);
end CPU;

architecture Behavioral of CPU is
	signal tmp_req : std_logic_vector(72 downto 0);

	signal rand1 : integer                       := 1;
	signal rand2 : std_logic_vector(31 downto 0) := "01101010101010101010101010101010";
	signal rand3 : std_logic_vector(31 downto 0) := "10101010101010101010101010101010";

	procedure read(variable adx  : in  std_logic_vector(31 downto 0);
			       signal req    : out std_logic_vector(72 downto 0);
			       variable data : out std_logic_vector(31 downto 0)) is
	begin
		req <= "101000000" & adx & "00000000000000000000000000000000";
		wait for 3 ps;
		req <= (others => '0');
		if cpu_res(72 downto 72) = "1" then
			data := cpu_res(31 downto 0);
		end if;
		wait for 10 ps;
	end read;

	procedure write(variable adx  : in  std_logic_vector(31 downto 0);
			        signal req    : out std_logic_vector(72 downto 0);
			        variable data : in  std_logic_vector(31 downto 0)) is
	begin
		req <= "110000000" & adx & data;
------		wait for 3 ps;
		req <= (others => '0');
		if cpu_res(72 downto 72) = "1" then
		end if;
----		wait for 10 ps;
	end write;

	procedure power(variable cmd : in  std_logic_vector(1 downto 0);
			        signal req   : out std_logic_vector(72 downto 0);
			        variable hw  : in  std_logic_vector(1 downto 0)) is
	begin
		req <= "111000000" & cmd & hw & "00000000" & "00000000" & "00000000" & "00000000" & "00000000" & "00000000" & "00000000" & "0000";
		wait for 3 ps;
		req <= (others => '0');
		wait until cpu_res(72 downto 72) = "1";
		wait for 50 ps;
	end power;

begin
	req1 : process(reset, Clock)
	begin
		if reset = '1' then
			cpu_req <= (others => '0');
		elsif (rising_edge(Clock)) then
			cpu_req <= tmp_req;
		end if;
	end process;

	-- processor random generate read or write request
	p1 : process
		variable nilreq : std_logic_vector(72 downto 0) := (others => '0');

		variable flag0 : std_logic_vector(31 downto 0) := "1010" & "1010" & "0010" & "0000" & "0000" & "0000" & "0011" & "0000";
		variable turn  : std_logic_vector(31 downto 0) := "1111" & "1111" & "0100" & "0000" & "0000" & "0000" & "0011" & "0000";

		variable turn_v : std_logic_vector(31 downto 0) := "0000" & "0000" & "0100" & "0000" & "0000" & "0000" & "0011" & "0000";

		variable one : std_logic_vector(31 downto 0) := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0001";

		variable line_output : line;
		variable logsr       : string(8 downto 1);
		variable pwrcmd      : std_logic_vector(1 downto 0);
		variable hwlc        : std_logic_vector(1 downto 0);
	begin
--wait for 80 ps;
		pwrcmd := "00";
		hwlc   := "00";
		---power(pwrcmd, tmp_req, hwlc);
		if seed = 1 then
			write(flag0, tmp_req, one);

		elsif seed = 2 then
			read(turn, tmp_req, turn_v);

		end if;
	--	wait;

	end process;

end Behavioral;
