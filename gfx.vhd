library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
--use work.rand.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gfx is
	Port(Clock      : in  std_logic;
		 reset      : in  std_logic;
		 ---write address chanel
		 waddr      : in  std_logic_vector(31 downto 0);
		 wlen       : in  std_logic_vector(9 downto 0);
		 wsize      : in  std_logic_vector(9 downto 0);
		 wvalid     : in  std_logic;
		 wready     : out std_logic;
		 ---write data channel
		 wdata      : in  std_logic_vector(31 downto 0);
		 wtrb       : in  std_logic_vector(3 downto 0);
		 wlast      : in  std_logic;
		 wdvalid    : in  std_logic;
		 wdataready : out std_logic;
		 ---write response channel
		 wrready    : in  std_logic;
		 wrvalid    : out std_logic;
		 wrsp       : out std_logic_vector(1 downto 0);

		 ---read address channel
		 raddr      : in  std_logic_vector(31 downto 0);
		 rlen       : in  std_logic_vector(9 downto 0);
		 rsize      : in  std_logic_vector(9 downto 0);
		 rvalid     : in  std_logic;
		 rready     : out std_logic;
		 ---read data channel
		 rdata      : out std_logic_vector(31 downto 0);
		 rstrb      : out std_logic_vector(3 downto 0);
		 rlast      : out std_logic;
		 rdvalid    : out std_logic;
		 rdready    : in  std_logic;
		 rres       : out std_logic_vector(1 downto 0);
		 pwrreq     : in  std_logic_vector(2 downto 0);
		 pwrres     : out std_logic_vector(2 downto 0);
		 
		 
		 upreq      : out std_logic_vector(72 downto 0);
		 upres      : in  std_logic_vector(72 downto 0);
		 upreq_full : in  std_logic
	);
end gfx;

architecture Behavioral of gfx is
	type ram_type is array (0 to natural(2 ** 5 - 1) - 1) of std_logic_vector(31 downto 0);
	signal ROM_array : ram_type  := (others => (others => '0'));
	signal poweron   : std_logic := '1';

	signal emp3, emp2 : std_logic := '0';
	signal tmp_req                        : std_logic_vector(50 downto 0);

begin
	
--	p1 : process
--		variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
--
--		variable zero  : std_logic_vector(31 downto 0) := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000";
--		variable one   : std_logic_vector(31 downto 0) := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0001";
--		variable two   : std_logic_vector(31 downto 0) := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0010";
--		variable rand1 : integer                       := 1;
--		variable rand2 : std_logic_vector(15 downto 0) := "0101010101010111";
--		variable rand3 : std_logic_vector(31 downto 0) := "10101010101010101010101010101010";
--
--	begin
--		--    	wait for 70 ps;
--
--		---power(pwrcmd, tmp_req, hwlc);
--		--for I in 1 to 1 loop
--			rand1 := selection(2); -- TODO replace all calls "selection" in this file by rand_int, etc...
--			rand2 := '0' & selection(2 ** 2 - 1, 3) & "111111000000";
--			rand3 := selection(2 ** 15 - 1, 32);
--			rand2 := "0110101010101010";
--		---if rand1=1 then
--		---    write(rand2,tmp_req,rand3);
--		---else
--		--	   wait for 370 ps;
--		--  write(rand2,tmp_req,rand3);
--
--		---end if;
--
--		--end loop;
--
----		wait;
--
--	end process;
--
	write : process(Clock, reset)
		variable address : integer;
		variable len     : integer;
		variable size    : std_logic_vector(9 downto 0);
		variable state   : integer := 0;
		variable lp      : integer := 0;
	begin
		if reset = '1' then
			wready     <= '1';
			wdataready <= '0';
		elsif (rising_edge(Clock)) then
			if state = 0 then
				wrvalid <= '0';
				wrsp    <= "10";
				if wvalid = '1' then
					wready     <= '0';
					address    := to_integer(unsigned(waddr));
					len        := to_integer(unsigned(wlen));
					size       := wsize;
					state      := 2;
					wdataready <= '1';
				end if;

			elsif state = 2 then
				if wdvalid = '1' then
					---not sure if lengh or length -1
					if lp < len - 1 then
						wdataready              <= '0';
						---strob here is not considered
						ROM_array(address + lp) <= wdata(31 downto 0);
						lp                      := lp + 1;
						wdataready              <= '1';
						if wlast = '1' then
							state := 3;
						end if;
					else
						state := 3;
					end if;

				end if;
			elsif state = 3 then
				if wrready = '1' then
					wrvalid <= '1';
					wrsp    <= "00";
					state   := 0;
				end if;
			end if;
		end if;
	end process;
--
	read : process(Clock, reset)
		variable address : integer;
		variable len     : integer;
		variable size    : std_logic_vector(9 downto 0);
		variable state   : integer := 0;
		variable lp      : integer := 0;
		variable dt      : std_logic_vector(31 downto 0);
	begin
		if reset = '1' then
			rready  <= '1';
			rdvalid <= '0';
			rstrb   <= "1111";
			rlast   <= '0';
			address := 0;
		elsif (rising_edge(Clock)) then
			if state = 0 then
				lp := 0;
				if rvalid = '1' then
					rready  <= '0';
					address := to_integer(unsigned(raddr(31 downto 4)));
					len     := to_integer(unsigned(rlen));
					size    := rsize;
					state   := 2;
				end if;

			elsif state = 2 then
				if rdready = '1' then
					if lp < 16 then
						rdvalid <= '1';
						---strob here is not considered
						---left alone , dono how to fix
						---if ROM_array(address+lp) ="00000000000000000000000000000000" then
						---ROM_array(address+lp) := selection(2**15-1,32);
						---end if;
						--dt      := selection(2 ** 15 - 1, 32);
						---rdata <= dt;
						rdata   <= ROM_array(address);
						lp      := lp + 1;
						rres    <= "00";
						if lp = len then
							state := 3;
							rlast <= '1';
						end if;
					else
						state := 3;
					end if;

				end if;
			elsif state = 3 then
				rdvalid <= '0';
				rready  <= '1';
				rlast   <= '0';
				state   := 0;
			end if;
		end if;
	end process;

	pwr : process(Clock)
	begin
		if reset = '1' then
			pwrres <= (others => '0');

		elsif (rising_edge(Clock)) then
			if pwrreq(2 downto 2) = "1" then
				if pwrreq(1 downto 0) = "00" then
					poweron <= '0';
				elsif pwrreq(1 downto 0) = "11" or pwrreq(1 downto 0) = "10" then
					poweron <= '1';
				end if;
				pwrres <= pwrreq;
			else
				pwrres <= "000";
			end if;

		end if;
	end process;

end Behavioral;
