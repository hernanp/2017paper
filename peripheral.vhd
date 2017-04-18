library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.test.all;
use work.rand.all;
use work.util.all;

entity peripheral is
  Port(Clock      : in  std_logic;
       reset      : in  std_logic;
       ---write address channel
       waddr_i      : in  std_logic_vector(31 downto 0);
       wlen_i       : in  std_logic_vector(9 downto 0);
       wsize_i      : in  std_logic_vector(9 downto 0);
       wvalid_i     : in  std_logic;
       wready_o     : out std_logic;
       ---write data channel
       wdata_i      : in  std_logic_vector(31 downto 0);
       wtrb_i       : in  std_logic_vector(3 downto 0);  --TODO not implemented
       wlast_i      : in  std_logic;
       wdvalid_i    : in  std_logic;
       wdataready_o : out std_logic;
       ---write response channel
       wrready_i    : in  std_logic;
       wrvalid_o    : out std_logic;
       wrsp_o       : out std_logic_vector(1 downto 0);

       ---read address channel
       raddr_i      : in  std_logic_vector(31 downto 0);
       rlen_i       : in  std_logic_vector(9 downto 0);
       rsize_i      : in  std_logic_vector(9 downto 0);
       rvalid_i     : in  std_logic;
       rready_o     : out std_logic;
       ---read data channel
       rdata_o       : out std_logic_vector(31 downto 0);
       rstrb_o       : out std_logic_vector(3 downto 0);
       rlast_o       : out std_logic;
       rdvalid_o     : out std_logic;
       rdready_i     : in  std_logic;
       rres_o        : out std_logic_vector(1 downto 0);
       pwr_req_i     : in  std_logic_vector(2 downto 0);
       pwr_res_o     : out std_logic_vector(2 downto 0);
       
       -- up req
       upreq_o       : out std_logic_vector(72 downto 0);
       upres_i       : in  std_logic_vector(72 downto 0);
       upreq_full_i  : in  std_logic
       );
end peripheral;

architecture rtl of peripheral is
  type ram_type is array (0 to natural(2 ** 5 - 1) - 1) of std_logic_vector(31 downto 0);
  signal ROM_array : ram_type  := (others => (others => '0'));
  signal poweron   : std_logic := '1';

  signal emp3, emp2 : std_logic := '0';
  signal tmp_req : std_logic_vector(50 downto 0);

begin
  write_req_handler : process(Clock, reset)
    variable address : integer;
    variable len     : integer;
    variable size    : std_logic_vector(9 downto 0);
    variable state   : integer := 0;
    variable lp      : integer := 0;
  begin
    if reset = '1' then
      wready_o     <= '1';
      wdataready_o <= '0';
    elsif (rising_edge(Clock)) then
      if state = 0 then
        wrvalid_o <= '0';
        wrsp_o    <= "10";
        if wvalid_i = '1' then
          wready_o     <= '0';
          address    := to_integer(unsigned(waddr_i(31 downto 29)));
          len        := to_integer(unsigned(wlen_i));
          size       := wsize_i;
          state      := 2;
          wdataready_o <= '1';
        end if;

      elsif state = 2 then
        if wdvalid_i = '1' then
          ---not sure if lengh or length -1
          if lp < len - 1 then
            wdataready_o              <= '0';
            ---strob here is not considered
            ROM_array(address + lp) <= wdata_i(31 downto 0);
            lp                      := lp + 1;
            wdataready_o              <= '1';
            if wlast_i = '1' then
              state := 3;
            end if;
          else
            state := 3;
          end if;

        end if;
      elsif state = 3 then
        if wrready_i = '1' then
          wrvalid_o <= '1';
          wrsp_o    <= "00";
          state   := 0;
        end if;
      end if;
    end if;
  end process;
--
  read_req_handler : process(Clock, reset)
    variable address : integer;
    variable len     : integer;
    variable size    : std_logic_vector(9 downto 0);
    variable state   : integer := 0;
    variable lp      : integer := 0;
    variable dt      : std_logic_vector(31 downto 0);
  begin
    if reset = '1' then
      rready_o  <= '1';
      rdvalid_o <= '0';
      rstrb_o   <= "1111";
      rlast_o   <= '0';
      address := 0;
    elsif (rising_edge(Clock)) then
      if state = 0 then
        lp := 0;
        if rvalid_i = '1' then
          rready_o  <= '0';
          address := to_integer(unsigned(raddr_i(31 downto 29)));
          len     := to_integer(unsigned(rlen_i));
          size    := rsize_i;
          state   := 2;
        end if;

      elsif state = 2 then
        if rdready_i = '1' then
          if lp < 16 then
            rdvalid_o <= '1';
            rdata_o   <= ROM_array(address);
            lp      := lp + 1;
            rres_o    <= "00";
            if lp = len then
              state := 3;
              rlast_o <= '1';
            end if;
          else
            state := 3;
          end if;

        end if;
      elsif state = 3 then
        rdvalid_o <= '0';
        rready_o  <= '1';
        rlast_o   <= '0';
        state   := 0;
      end if;
    end if;
  end process;

  pwr_req_handler : process(Clock)
  begin
    if reset = '1' then
      pwr_res_o <= (others => '0');

    elsif (rising_edge(Clock)) then
      if pwr_req_i(2 downto 2) = "1" then
        if pwr_req_i(1 downto 0) = "00" then
          poweron <= '0';
        elsif (pwr_req_i(1 downto 0) = "11" or
               pwr_req_i(1 downto 0) = "10") then
          poweron <= '1';
        end if;
        pwr_res_o <= pwr_req_i;
      else
        pwr_res_o <= "000";
      end if;

    end if;
  end process;

  t1 : process(clock, reset) -- up read test
    variable ct : natural;
    variable st : natural := 0;
  begin
    if is_tset(RND1_TEST) then
      if reset = '1' then
        upreq_o <= (others => '0');
        ct := rand_nat(to_integer(unsigned(RND1_TEST)));
        --ct := rand_int(RAND_MAX_DELAY, to_int(ct'instance_name),
        --        to_integer(unsigned(GFX_R_TEST)));
        st := 0;
      elsif(rising_edge(clock)) then
        if st = 0 then -- wait
          delay(ct, st, 1);
        elsif st = 1 then -- snd up_req 
          report "rnd1_test @ " & integer'image(time'pos(now));
          upreq_o <= '1' &
                       READ_CMD &
                       "1000000000000000" &
                       "1000000000000000" &
                       ZEROS32;
          st := 2;
        elsif st = 2 then -- done
          upreq_o <= (others => '0');
        end if;
      end if;
    end if;
  end process;  
end rtl;
