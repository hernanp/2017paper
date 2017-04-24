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

       devid_i    : in DEVID_T;

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
       pwr_req_i     : in  MSG_T;
       pwr_res_o     : out MSG_T;
       
       -- up req
       upreq_o       : out MSG_T;
       upres_i       : in  MSG_T;
       upreq_full_i  : in  std_logic
       );
end peripheral;

architecture rtl of peripheral is
  type ram_type is array (0 to natural(2 ** 5 - 1) - 1) of std_logic_vector(31 downto 0);
  signal ROM_array : ram_type  := (others => (others => '0'));
  signal poweron   : std_logic := '1';

  signal emp3, emp2 : std_logic := '0';
  signal tmp_req : std_logic_vector(50 downto 0);

  signal sim_end : std_logic := '0';
  
begin

  --upreq_o_arbiter : entity work.arbiter2(rtl)
  --  port map(
  --    clock => Clock,
  --    reset => reset,
  --    din1  => upreq1_s,
  --    ack1  => ack1,
  --    din2  => upreq2_s,
  --    ack2  => ack2,
  --    dout  => upreq_o
  --    );

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
    variable pwr_req : MSG_T;
  begin
    if reset = '1' then
      pwr_res_o <= (others => '0');

    elsif (rising_edge(clock)) then
      pwr_res_o <= pwr_req;
      pwr_req := pwr_req_i;
      if get_cmd(pwr_req) = PWRUP_CMD then
        poweron <= '1';
      elsif get_cmd(pwr_req) = PWRDN_CMD then
        poweron <= '0';
      else
        pwr_req := (others => '0');
      end if;
    end if;
  end process;

  clk_counter : process(clock, sim_end)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if sim_end = '1' and b then
      report "per" & integer'image(to_integer(unsigned(devid_i))) & " sim ended, clock cycles is " & integer'image(count);
      b := false;
    elsif (rising_edge(clock)) then
      count := count + 1;
    end if;
  end process;
  
  t1 : process(clock, reset) -- up read test
    variable dc, tc, st_nxt : natural := 0;
    variable s : natural := to_integer(unsigned(devid_i));
    variable st : natural := 0;
    variable b : boolean := true;
    variable rnd_adr : std_logic_vector(30 downto 0);
    variable cmd : CMD_T;
  begin
      if reset = '1' then
        upreq_o <= (others => '0');
        --ct := rand_nat(to_integer(unsigned(UREQ_TEST)));
        st := 0;
      elsif(rising_edge(clock)) then
        if st = 1 then -- delay
          rnd_dlay(b, s, dc, st, st_nxt);
        elsif st = 2 then -- done
          upreq_o <= (others => '0');
          sim_end <= '1';
        elsif st = 0 then -- check
          if is_tset(UREQ_TEST) then
            if tc < UREQT_CNT then
              tc := tc + 1;
              --report integer'image(tc);
              st_nxt := 3;
              st := 1;
            else
              st := 2;
            end if;
          end if;
        elsif st = 3 then -- snd
          -- report integer'image(to_integer(unsigned(devid_i))) & " snd ureq";
          -- rmz adr
          rnd_adr := std_logic_vector(to_unsigned(rand_nat(s), rnd_adr'length));

          -- rmz cmd
          if (devid_i = USB_ID) or
            (devid_i = UART_ID) or
            (rand_nat(s) mod 2) = 1 then
            cmd := READ_CMD;
          else
            cmd := WRITE_CMD;
          end if;
          
          upreq_o <= "1" & cmd & "1" & rnd_adr & ZEROS32; -- TODO causes
                                                             -- warning when
                                                             -- reading adr 800..
                                                             -- (not happening when
                                                             -- reading addr 0)
          st := 4;
        elsif st = 4 then
          upreq_o <= (others => '0');
          -- do not wait for response
          st_nxt := 0;
          st := 1; -- delay next check
        end if;
      end if;
  end process;  
end rtl;