library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
--use work.rand.all;

entity memory is
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
		 rvalid_in  : in  std_logic;
		 rready     : out std_logic;
		 ---read data channel
		 rdata      : out std_logic_vector(31 downto 0);
		 rstrb      : out std_logic_vector(3 downto 0);
		 rlast      : out std_logic;
		 rdvalid_out    : out std_logic; -- sig from mem to ic meaning "here comes
                                     -- the data"
		 rdready    : in  std_logic; -- sig from ic to mem meaning "done"
                                     -- sending data
		 rres_out   : out std_logic_vector(1 downto 0)
	);
end Memory;

architecture Behavioral of Memory is
	--type rom_type is array (2**32-1 downto 0) of std_logic_vector (31 downto 0);
	type ram_type is array (0 to natural(2 ** 5 - 1) - 1) of std_logic_vector(wdata'range);
	type ram_type1 is array (0 to natural(2 ** 2 - 1) - 1) of ram_type;
	signal ROM_array : ram_type1 := (others => (others => (others => '0')));

begin
	write : process(Clock, reset)
		variable slot    : integer;
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
					slot       := to_integer(unsigned(waddr(30 downto 15)));
					address    := to_integer(unsigned(waddr(15 downto 0)));
					len        := to_integer(unsigned(wlen));
					size       := wsize;
					state      := 2;
					wdataready <= '1';
				end if;

			elsif state = 2 then
				if wdvalid = '1' then
					---not sure if lengh or length -1
					if lp < len - 1 then
						wdataready                    <= '0';
						---strob here is not considered
						ROM_array(slot)(address + lp) <= wdata(31 downto 0);
						lp                            := lp + 1;
						wdataready                    <= '1';
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

	read : process(Clock, reset)
		variable slot    : integer;
		variable address : integer;
		variable len     : integer;
		variable size    : std_logic_vector(9 downto 0);
		variable state   : integer := 0;
		variable lp      : integer := 0;
		variable dt      : std_logic_vector(31 downto 0);
	begin
		if reset = '1' then
			rready  <= '1';
			rdvalid_out <= '0';
			rstrb   <= "1111";
			rlast   <= '0';
			address := 0;
		elsif (rising_edge(Clock)) then
			if state = 0 then
				lp := 0;
				if rvalid_in = '1' then
					rready  <= '0';
					slot    := to_integer(unsigned(waddr(30 downto 25)));
					address := to_integer(unsigned(waddr(15 downto 14)));
					len     := to_integer(unsigned(rlen));
					size    := rsize;
					state   := 2;
				end if;

			elsif state = 2 then
				if rdready = '1' then
					if lp < 16 then
						rdvalid_out <= '1';
						---strob here is not considered
						---left alone , dono how to fix
						---if ROM_array(address+lp) ="00000000000000000000000000000000" then
						---ROM_array(address+lp) := selection(2**15-1,32); -- TODO replace all calls "selection" in this file by rand_int, etc...
						---end if;
						--dt      := selection(2 ** 15 - 1, 32);
						---rdata <= dt;
						rdata   <= ROM_array(slot)(address + lp);
						lp      := lp + 1;
						rres_out <= "00";
						if lp = len then
							state := 3;
							rlast <= '1';
						end if;
					else
						state := 3;
					end if;

				end if;
			elsif state = 3 then
				rdvalid_out <= '0';
				rready  <= '1';
				rlast   <= '0';
				state   := 0;
			end if;
		end if;
	end process;

end Behavioral;
