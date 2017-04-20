library ieee;
use ieee.std_logic_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;

entity l1_cache is
  port(
    Clock                : in  std_logic;
    reset                : in  std_logic;
    cpu_req_i              : in  MSG_T;
    snp_req_i              : in  MSG_T;
    bus_res_i              : in  BMSG_T;
    --01: read response
    --10: write response
    --11: fifo full response
    cpu_res_o              : out MSG_T := (others => '0');
    --01: read response 
    --10: write response
    --11: fifo full response
    snp_hit_o            : out std_logic;
    snp_res_o            : out MSG_T := (others => '0');

    --goes to cache controller ask for data
    snp_req_o  : out MSG_T;
    snp_res_i  : in  MSG_T;
    snp_hit_i  : in  std_logic;
    up_snp_req_i    : in  WMSG_T;
    up_snp_res_o   : out WMSG_T;
    up_snp_hit_o   : out std_logic;
    wb_req_o           : out BMSG_T;
    --01: read request
    --10: write request
    --10,11: write back function

    -- FIFO flags
    crf_full_o : out std_logic := '0'; -- Full flag from cpu_req FIFO
    srf_full_o : out std_logic := '0'; -- Full flag from snp_req FIFO
    bsf_full_o : out std_logic := '0'; -- Full flag from bus_req FIFO

    full_crq_i   : in  std_logic; --TODO what is this? not implemented?
    full_wb_i    : in  std_logic;
    full_srs_i   : in  std_logic; --TODO where is this coming from? not implemented?
    bus_req_o : out MSG_T :=
      (others => '0') -- a req going to the other cache
	);

end l1_cache;

architecture rtl of l1_cache is
  --IMB cache 1
  --3 lsb: dirty bit, valid bit, exclusive bit
  --cache hold valid bit ,dirty bit, exclusive bit, 6 bits tag, 32 bits data,
  --41 bits in total
  type rom_type is
    array (natural(2 ** 14 - 1) downto 0) of std_logic_vector(52 downto 0);
  signal ROM_array : rom_type  := (others => (others => '0'));

  -- Naming conventions:
  -- [c|s|b]rf is [cpu|snoop|bus]_req fifo
  -- [us|s]sf is [upstream-snoop|snoop]_resp fifo
  
  -- FIFO queues inputs
  -- write_enable signals for FIFO queues
  signal crf_we, srf_we, bsf_we, brf_we, ssf_we : std_logic := '0';
  -- read_enable signals for FIFO queues
  signal crf_re, srf_re, bsf_re, brf_re, ssf_re : std_logic;
  -- data_in signals
  signal crf_in, srf_in, ssf_in : MSG_T:=(others => '0');
  
  -- Outputs from FIFO queues
  -- data_out signals
  signal out1, out3, -- TODO not used?
    srf_out, ssf_out : MSG_T:=(others => '0');
  signal brf_out, brf_in : std_logic_vector(75 downto 0):=(others => '0');
  -- empty signals
  signal crf_emp, srf_emp, bsf_emp, brf_emp, ssf_emp : std_logic;
  -- full signals
  signal brf_full, ssf_full: std_logic := '0'; -- TODO not implemented yet?

  -- MCU (Memory Control Unit)
  
  -- Memory requests (data_out signals from FIFO queues)
  -- Naming conventions:
  -- [cpu|snp|usnp]_mem_[req|res|ack] memory (write) request, response, or ack for
  --   cpu, snoop (from cache), or upstream snoop (from bus on behalf of a device)
  signal cpu_mem_req, snp_mem_req, mcu_write_req  : MSG_T;
  signal usnp_mem_req, usnp_mem_res : std_logic_vector(75 downto 0):=(others => '0'); -- usnp reqs are longer
  signal usnp_mem_ack : std_logic;
  signal snp_mem_req_1, snp_mem_req_2 : MSG_T :=(others => '0');

  signal snp_mem_ack1, snp_mem_ack2 : std_logic;
  signal bus_res, bsf_in : std_logic_vector(552 downto 0):=(others => '0');
  signal cpu_mem_res, write_res, upd_res : std_logic_vector(71 downto 0):=(others => '0');
  signal snp_mem_res : std_logic_vector(71 downto 0):=(others => '0');
  -- hit signals
  signal cpu_mem_hit, snp_mem_hit, usnp_mem_hit : std_logic;
  -- "done" signals
  signal upd_ack, write_ack, cpu_mem_ack, snp_mem_ack : std_logic;

  signal cpu_res1, cpu_res2             : MSG_T:=(others => '0');
  signal ack1, ack2                     : std_logic;
  signal snp_c_req1, snp_c_req2         : MSG_T:=(others => '0');
  signal snp_c_ack1, snp_c_ack2         : std_logic;

  signal prc          : std_logic_vector(1 downto 0);
  signal tmp_cpu_res1 : MSG_T := (others => '0');
  signal tmp_snp_res  : MSG_T:=(others => '0');
  signal tmp_hit      : std_logic;
  signal tmp_mem      : std_logic_vector(40 downto 0):=(others => '0');
  ---this one is important!!!!
  
  signal upreq : std_logic_vector(75 downto 0); -- used only by up_snp_req_handler
  signal snpreq       : MSG_T; -- used only by cpu_req_handler
  
  constant DEFAULT_DATA_WIDTH : positive := MSG_WIDTH;
  constant DEFAULT_WDATA_WIDTH : positive := WMSG_WIDTH;
  constant DEFAULT_FIFO_DEPTH : positive := 256;
begin
  cpu_req_fifo : entity work.fifo(rtl)
    generic map(
      DATA_WIDTH => DEFAULT_DATA_WIDTH,
      FIFO_DEPTH => DEFAULT_FIFO_DEPTH
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => crf_in,
      WriteEn => crf_we,
      ReadEn  => crf_re,
      DataOut => cpu_mem_req,
      Full    => crf_full_o,
      Empty   => crf_emp
      );
  snp_res_fifo : entity work.fifo(rtl)
    generic map(
      DATA_WIDTH => DEFAULT_DATA_WIDTH,
      FIFO_DEPTH => DEFAULT_FIFO_DEPTH
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => ssf_in,
      WriteEn => ssf_we,
      ReadEn  => ssf_re,
      DataOut => ssf_out,
      Full    => ssf_full,
      Empty   => ssf_emp
      );
  up_snp_req_fifo : entity work.fifo(rtl) -- req from device
    generic map(
      DATA_WIDTH => DEFAULT_WDATA_WIDTH,
      FIFO_DEPTH => DEFAULT_FIFO_DEPTH
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => brf_in,
      WriteEn => brf_we,
      ReadEn  => brf_re,
      DataOut => usnp_mem_req,
      Full    => brf_full,
      Empty   => brf_emp
      );

  --* Stores up snoop requests into fifo
  --* up_snp_req_i;; -> ;brf_in, brf_we;
  up_snp_req_fifo_handler : process(Clock)
  begin
    if reset = '1' then
      brf_we <= '0';
    elsif rising_edge(Clock) then
      if is_valid(up_snp_req_i) then
        brf_in <= up_snp_req_i;
        brf_we <= '1';
      else
        brf_we <= '0';
      end if;
    end if;
  end process;
  
  snp_req_fifo : entity work.fifo(rtl)
    generic map(
      DATA_WIDTH => DEFAULT_DATA_WIDTH,
      FIFO_DEPTH => DEFAULT_FIFO_DEPTH
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => srf_in,
      WriteEn => srf_we,
      ReadEn  => srf_re,
      DataOut => srf_out,
      Full    => srf_full_o,
      Empty   => srf_emp
      );
  bus_res_fifo : entity work.fifo(rtl)
    generic map(
      DATA_WIDTH => BMSG_WIDTH,
      FIFO_DEPTH => DEFAULT_FIFO_DEPTH
      )
    port map(
      CLK     => Clock,
      RST     => reset,
      DataIn  => bsf_in,
      WriteEn => bsf_we,
      ReadEn  => bsf_re,
      DataOut => bus_res,
      Full    => bsf_full_o,
      Empty   => bsf_emp
      );
  cpu_res_arbiter : entity work.arbiter2(rtl)
    port map(
      clock => Clock,
      reset => reset,
      din1  => cpu_res1,
      ack1  => ack1,
      din2  => cpu_res2,
      ack2  => ack2, -- o
      dout  => cpu_res_o
      );
  snp_c_req_arbiter : entity work.arbiter2(rtl)
    port map(
      clock => Clock,
      reset => reset,
      din1  => snp_c_req1,
      ack1  => snp_c_ack1,
      din2  => snp_c_req2,
      ack2  => snp_c_ack2,
      dout  => snp_req_o
      );

  snp_mem_req_arbiter : entity work.arbiter2(rtl)
    port map(
      clock => Clock,
      reset => reset,
      din1  => snp_mem_req_1,
      ack1  => snp_mem_ack1,
      din2  => snp_mem_req_2,
      ack2  => snp_mem_ack2,
      dout  => snp_mem_req
      );
  
  --* Stores cpu requests into fifo
  --* cpu_req_i;; -> ;crf_in, crf_we;
  cpu_req_fifo_handler : process(Clock)
  begin
    if reset = '1' then
      crf_we <= '0';
    elsif rising_edge(Clock) then
      if is_valid(cpu_req_i) then -- if req is valid
        crf_in <= cpu_req_i;
        crf_we <= '1';
      else
        crf_we <= '0';
      end if;
    end if;
  end process;

  --* Stores snoop requests into fifo
  --* snp_req_i;; -> ;srf_in, srf_we;
  snp_req_fifo_handler : process(Clock)
  begin
    if reset = '1' then
      srf_we <= '0';

    elsif rising_edge(Clock) then
      if is_valid(snp_req_i) then
        srf_in <= snp_req_i;
        srf_we <= '1';
      else
        srf_we <= '0';
      end if;
    end if;
  end process;
  
  --* Stores bus response into fifo
  --* bus_res_i;; -> ;bsf_in, bsf_we;
  bus_res_fifo_handler : process(Clock)
  begin
    if reset = '1' then
      bsf_we <= '0';

    elsif rising_edge(Clock) then
      if (bus_res_i(552 downto 552) = "1") then
        bsf_in <= bus_res_i;
        bsf_we <= '1';
      else
        bsf_we <= '0';
      end if;
    end if;
  end process;

  --* Process requests from cpu
  --* snp_res_i,snp_hit_i;cpu_mem_res;
  --*  -> ;cpu_res1, mcu_write_req, crf_re, snp_c_req1, cpu_mem_ack, cpu_mem_hit,
  --*      tmp_cpu_res1, cpu_res1, snp_req, snp_c_ack1;
  --*     bus_req_o
  cpu_req_handler : process(reset, Clock)
    -- TODO should they be signals instead of variables?
    variable nilreq : MSG_T := (others => '0');
    variable st  : integer := 0;
  begin
    if (reset = '1') then
      -- reset signals
      cpu_res1  <= nilreq;
      mcu_write_req <= nilreq;
      bus_req_o <= nilreq;
		crf_re <='0';
		snp_c_req1 <=(others =>'0');
    --tmp_write_req <= nilreq;
    elsif rising_edge(Clock) then
      if st = 0 then -- wait_fifo
        bus_req_o <= nilreq;

        if crf_re = '0' and crf_emp = '0' then
          crf_re   <= '1';
          st := 1;
        end if;

      elsif st = 1 then -- access
        crf_re <= '0';
        if cpu_mem_ack = '1' then
          if cpu_mem_hit = '1' then
            if cpu_mem_res(71 downto 64) = WRITE_CMD then
              mcu_write_req    <= '1' & cpu_mem_res;
              tmp_cpu_res1 <= '1' & cpu_mem_res;
              st        := 3;
            else -- read cmd
              cpu_res1 <= '1' & cpu_mem_res;
              st    := 4;
            end if;
          else -- it's a miss
            snp_c_req1 <= '1' & cpu_mem_res;
            snpreq     <= '1' & cpu_mem_res;
            st      := 5;
          end if;
        end if;

      elsif st = 3 then -- get_resp_from_mcu
        if write_ack = '1' then
          mcu_write_req <= nilreq;
          cpu_res1  <= tmp_cpu_res1;
          st     := 4;
        end if;
      elsif st = 4 then -- output_resp
        if ack1 = '1' then
          cpu_res1 <= nilreq;
          st    := 0;
        end if;
      elsif st = 5 then -- get_snp_req_ack
        if snp_c_ack1 = '1' then
          snp_c_req1 <= (others => '0');
          st      := 6;
        end if;
      --now we wait for the snoop response
      elsif st = 6 then -- get_snp_resp
        if is_valid(snp_res_i) then
          --if we get a snoop response  and the address is the same  => 
          if snp_res_i(63 downto 32) = snpreq(63 downto 32) then
            if snp_hit_i = '1' then
              st    := 4;
              cpu_res1 <= snp_res_i;
            else
              bus_req_o <= snp_res_i;
              st     := 0;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  --* Process snoop requests (from another cache)
  snp_req_handler : process(reset, Clock)
    variable nilreq1 : std_logic_vector(552 downto 0) := (others => '0');
    variable addr    : std_logic_vector(31 downto 0);
    variable state   : integer                        := 0;
  begin
    if (reset = '1') then
      -- reset signals
      snp_res_o <= (others => '0');
      snp_hit_o <= '0';
		srf_re <='0';
		snp_mem_req_1 <=(others => '0');
    elsif rising_edge(Clock) then
      if state = 0 then -- wait_fifo
        snp_res_o <= (others => '0');
        if srf_re = '0' and srf_emp = '0' then
          srf_re   <= '1';
          state := 1;
        end if;
      elsif state = 1 then -- gen_snp_mem_req (and send to arbiter)
        srf_re <= '0';
        if is_valid(srf_out) then
          snp_mem_req_1 <= srf_out;
          addr       := srf_out(63 downto 32);
          state      := 3;
        end if;
      elsif state = 3 then -- get_ack
        if snp_mem_ack1 = '1' then
          snp_mem_req_1 <= (others => '0');
          state      := 4;
        end if;
      elsif state = 4 then -- TODO should states 4 and 2 be merged?
        if snp_mem_ack = '1' and snp_mem_res(63 downto 32) = addr then
          snp_res_o <= '1' & snp_mem_res;
          snp_hit_o     <= snp_mem_hit;
          state       := 0;
        end if;
      end if;
    end if;
  end process;

  --* Process upstream snoop requests (from bus on behalf of devices)
  --the difference --with snp_req-- is that when it's  uprequest snoop, once it
  --fails (a miss), it will go to the other cache snoop
  --also when found, the write will be operated here directly, and return
  --nothing
  --if it's read, then the data will be returned to request source
  up_snp_req_handler : process(reset, Clock)
    variable state : integer := 0;
  begin
    if (reset = '1') then
      state := 0;
      up_snp_res_o <= (others => '0');
      up_snp_hit_o <= '1'; -- TODO should it be 0?
      brf_re <= '0';
      snp_c_req2 <= (others => '0');
    elsif rising_edge(Clock) then
      if state = 0 then -- wait_fifo
        up_snp_res_o <= (others => '0');
        up_snp_hit_o <= '0';
        if brf_re = '0' and brf_emp = '0' then
          brf_re <= '1';
          state := 1;
        end if;
      elsif state = 1 then -- access
        brf_re <= '0';
        if usnp_mem_ack = '1' then -- if hit
          if usnp_mem_hit = '1' then
            up_snp_res_o <= usnp_mem_res;
            up_snp_hit_o <= '1';
            state        := 0;
          else -- it's a miss
            snp_c_req2 <= usnp_mem_res(72 downto 0);
            upreq      <= usnp_mem_res;
            state      := 2;
          end if;
        end if;
      elsif state = 2 then -- wait_peer
        if snp_c_ack2 = '1' then
          snp_c_req2 <= (others => '0');
          state      := 3;
        end if;
      elsif state = 3 then -- output_resp
        if is_valid(snp_res_i) then
          --if we get a snoop response and the address is the same  => 
          if snp_res_i(63 downto 32) = upreq(63 downto 32) then
            up_snp_res_o <= upreq(75 downto 73) & snp_res_i; -- TODO upreq is
                                                             -- updated after
                                                             -- pcs is
                                                             -- finished. Is
                                                             -- this a problem?
                                                             -- (should it be a
                                                             -- variable?)
            up_snp_hit_o <= snp_hit_i;
				state :=0;
          end if;
        -- TODO do we need to go back to state 0?
        end if;
      end if;
    end if;
  end process;

  --* Process pwr response
  pwr_res_handler : process(reset,clock)
    variable tmp_msg : MSG_T;
  begin
    if reset='1' then
    elsif rising_edge(Clock) then
      tmp_msg := bus_res(BMSG_WIDTH-1 downto BMSG_WIDTH - MSG_WIDTH);
      if is_valid(tmp_msg) and is_pwr_cmd(tmp_msg) then
        cpu_res_o <= tmp_msg;
      end if;
    end if;
  end process;
  
  --* Process snoop response (to snoop request issued by this cache)
  bus_res_handler : process(reset, Clock)
    variable nilreq : MSG_T := (others => '0');
    variable state  : integer                       := 0;
  begin
    if reset = '1' then
      -- reset signals
      cpu_res2 <= nilreq;
    --upd_req <= nilreq;
	 bsf_re <='0';
    elsif rising_edge(Clock) then
      if state = 0 then -- wait_fifo
        if bsf_re = '0' and bsf_emp = '0' then
          bsf_re   <= '1';
          state := 1;
        end if;
      elsif state = 1 then -- 
        bsf_re <= '0';
        if upd_ack = '1' then
          cpu_res2 <= '1' & upd_res;
          state    := 2;
        end if;
      elsif state = 2 then -- 
        if ack2 = '1' then -- TODO ack2 from cpu_resp_arbiter? meaning?
          cpu_res2 <= nilreq;
          state    := 0;
        end if;
      end if;

    end if;
  end process;

  --* Deals with cache memory
  --* full_wb_i;
  --* cpu_mem_req, snp_mem_req, usnp_mem_req,
  --*   mcu_write_req, bus_res, ;
  --*   -> ;
  --*      ROM_array, write_ack, write_res, upd_ack, upd_res
  --*        cpu_mem_ack, cpu_mem_hit, cpu_mem_res,
  --*        snp_mem_ack, snp_mem_hit, snp_mem_res,
  --*        usnp_mem_ack, usnp_mem_hit, usnp_mem_res;
  --*      wb_req_o
  mem_control_unit : process(reset, Clock)
    variable idx    : integer;
    variable memcont : std_logic_vector(52 downto 0);
    variable nilreq  : MSG_T  := (others => '0');
    variable nilreq2 : std_logic_vector(552 downto 0) := (others => '0');
    variable shifter : boolean                        := false;
  begin
    if (reset = '1') then
      -- reset signals;
      cpu_mem_res  <= (others => '0');
      snp_mem_res  <= (others => '0');
      write_ack <= '0';
      upd_ack   <= '0';
    elsif rising_edge(Clock) then
      cpu_mem_res  <= nilreq(71 downto 0);
      snp_mem_res  <= nilreq(71 downto 0);
      write_ack <= '0';
      upd_ack   <= '0';
      wb_req_o    <= nilreq2;

      -- cpu memory request
      if is_valid(cpu_mem_req) then
        idx    := to_integer(unsigned(cpu_mem_req(45 downto 32)));
        memcont := ROM_array(idx);
        --if we can't find it in memory
        if memcont(52 downto 52) = "0" or
          (cpu_mem_req(71 downto 64) = "10100000" and ---this should be read command
           memcont(50 downto 50) = "0") or
          cpu_mem_req(71 downto 64) = "11000000" -- TODO writeback? how does it work?
          or memcont(49 downto 32) /= cpu_mem_req(63 downto 46) then
          cpu_mem_ack <= '1';
          cpu_mem_hit     <= '0';
          cpu_mem_res <= cpu_mem_req(71 downto 0);
        else -- it's a hit
          cpu_mem_ack <= '1';
          cpu_mem_hit     <= '1';
          if cpu_mem_req(71 downto 64) = "10" then -- TODO why compare to 10?
            cpu_mem_res <= cpu_mem_req(71 downto 0);
          else
            cpu_mem_res <= cpu_mem_req(71 downto 32) & memcont(31 downto 0);
          end if;
        end if;
      else
        cpu_mem_ack <= '0';
      end if;

      -- snoop memory request
      if is_valid(snp_mem_req) then
        idx    := to_integer(unsigned(snp_mem_req(45 downto 32)));
        memcont := ROM_array(idx);
        -- if we can't find it in memory
        if memcont(52 downto 52) = "0" or -- it's a miss
          memcont(49 downto 32) /= snp_mem_req(63 downto 46) then
          snp_mem_ack <= '1';
          snp_mem_hit     <= '0';
          snp_mem_res <= snp_mem_req(71 downto 0);
        else
          snp_mem_ack <= '1';
          snp_mem_hit     <= '1';
          --if it's write, invalidate the cache line
          if snp_mem_req(71 downto 64) = WRITE_CMD then
            ROM_array(idx)(52)          <= '0'; -- it's a miss
            ROM_array(idx)(31 downto 0) <= snp_mem_req(31 downto 0);
            snp_mem_res                     <= snp_mem_req(71 downto 32) &
                                            ROM_array(idx)(31 downto 0);
          else
            --if it's read, mark the exclusive as 0
            ROM_array(idx)(50) <= '0';
            snp_mem_res            <= snp_mem_req(71 downto 32) &
                                   ROM_array(idx)(31 downto 0);
          end if;

        end if;
      else
        snp_mem_ack <= '0';
      end if;

      -- upstream snoop req
      if is_valid(usnp_mem_req) then
        idx    := to_integer(unsigned(usnp_mem_req(41 downto 32))); -- memory addr
        memcont := ROM_array(idx);
        -- if we can't find it in memory
        --invalide  ---or tag different
        --or its write, but not exclusive
        if memcont(52 downto 52) = "0" or -- mem not found
          (cpu_mem_req(71 downto 64) = "10000000" and
           memcont(50 downto 50) = "0") or -- TODO what is this bit?
          memcont(49 downto 32) /= usnp_mem_req(63 downto 46) then -- TODO meaning?
          usnp_mem_ack <= '1';
          usnp_mem_hit     <= '0';
          usnp_mem_res <= usnp_mem_req;
        else -- it's a hit
          usnp_mem_ack <= '1';
          usnp_mem_hit <= '1';
          --if it's write, write it directly
          -----this need to be changed TODO ?
          if usnp_mem_req(71 downto 64) = WRITE_CMD then
            ROM_array(idx)(52)          <= '0';
            ROM_array(idx)(31 downto 0) <= usnp_mem_req(31 downto 0);
            usnp_mem_res                     <= usnp_mem_req(75 downto 32) &
                                            ROM_array(idx)(31 downto 0);
          else
            --if it's read, mark the exclusive as 0
            ---not for this situation, because it is shared by other ips
            ---ROM_array(idx)(54) <= '0';
            usnp_mem_res <= usnp_mem_req(75 downto 32) & ROM_array(idx)(31 downto 0);
          end if;
        end if;
      else -- invalid req
        usnp_mem_ack <= '0';
      end if;
      --first deal with write request from cpu_request
      --the write is only sent here if the data exist in cahce memory

      -- Handling write request from cpu_req_handler (when there's no update
      -- req from bus)
      if is_valid(mcu_write_req) and bus_res(552 downto 552) = "0" then
        idx            := to_integer(unsigned(mcu_write_req(45 downto 32)));
        ROM_array(idx) <= "110" & mcu_write_req(63 downto 46) &
                           mcu_write_req(31 downto 0);
        write_ack       <= '1';
        upd_ack         <= '0';
        write_res          <= mcu_write_req(71 downto 0);

      -- Handling update request from bus (when there's no mcu_write_req from
      -- cpu_req_handler)
      -- TODO why two cases?
      -- case invalid request
      elsif bus_res(552 downto 552) = "1" and not is_valid(mcu_write_req) then
        idx    := to_integer(unsigned(bus_res(525 downto 512))) /16 * 16;
        memcont := ROM_array(idx);
        --if tags do not match, dirty bit is 1,
        -- and write_back fifo in BUS is not full,
        if memcont(52 downto 52) = "1" and
          memcont(51 downto 51) = "1" and
          memcont(49 downto 32) /= bus_res(63 downto 46) and
          full_wb_i /= '1' then
          wb_req_o <= "110000000" & bus_res(63 downto 32) &
                    memcont(31 downto 0) &
                    ROM_array(idx + 1)(31 downto 0) &
                    ROM_array(idx + 2)(31 downto 0) &
                    ROM_array(idx + 3)(31 downto 0) &
                    ROM_array(idx + 4)(31 downto 0) &
                    ROM_array(idx + 5)(31 downto 0) &
                    ROM_array(idx + 6)(31 downto 0) &
                    ROM_array(idx + 7)(31 downto 0) &
                    ROM_array(idx + 8)(31 downto 0) &
                    ROM_array(idx + 9)(31 downto 0) &
                    ROM_array(idx + 10)(31 downto 0) &
                    ROM_array(idx + 11)(31 downto 0) &
                    ROM_array(idx + 12)(31 downto 0) &
                    ROM_array(idx + 13)(31 downto 0) &
                    ROM_array(idx + 14)(31 downto 0) &
                    ROM_array(idx + 15)(31 downto 0);
        end if;
		  ROM_array(idx) <= "100" & bus_res(63 downto 46) & bus_res(511 downto 480);
			 ROM_array(idx+1) <= "100" & bus_res(63 downto 46) & bus_res(479 downto 448);
			 ROM_array(idx+2) <= "100" & bus_res(63 downto 46) & bus_res(447 downto 416);
			 ROM_array(idx+3) <= "100" & bus_res(63 downto 46) & bus_res(415 downto 384);
          ROM_array(idx+4) <= "100" & bus_res(63 downto 46) & bus_res(383 downto 352);
			 ROM_array(idx+5) <= "100" & bus_res(63 downto 46) & bus_res(351 downto 320);
			 ROM_array(idx+6) <= "100" & bus_res(63 downto 46) & bus_res(319 downto 288);
			 ROM_array(idx+7) <= "100" & bus_res(63 downto 46) & bus_res(287 downto 256);
			 ROM_array(idx+8) <= "100" & bus_res(63 downto 46) & bus_res(255 downto 224);
			 ROM_array(idx+9) <= "100" & bus_res(63 downto 46) & bus_res(223 downto 192);
			 ROM_array(idx+10) <= "100" & bus_res(63 downto 46) & bus_res(191 downto 160);
			 ROM_array(idx+11) <= "100" & bus_res(63 downto 46) & bus_res(159 downto 128);
			 ROM_array(idx+12) <= "100" & bus_res(63 downto 46) & bus_res(127 downto 96);
			 ROM_array(idx+13) <= "100" & bus_res(63 downto 46) & bus_res(95 downto 64);
			 ROM_array(idx+14) <= "100" & bus_res(63 downto 46) & bus_res(63 downto 32);
			 ROM_array(idx+15) <= "100" & bus_res(63 downto 46) & bus_res(31 downto 0);
        upd_ack         <= '1';
        upd_res         <= bus_res(551 downto 512)&ROM_array(to_integer(unsigned(bus_res(525 downto 512))))(31 downto 0);
        write_ack       <= '0';
      -- case valid request
      elsif bus_res(552 downto 552) = "1" and is_valid(mcu_write_req) then
        if shifter = true then
          shifter         := false;
          idx            := to_integer(unsigned(mcu_write_req(45 downto 32)));
        ROM_array(idx) <= "110" & mcu_write_req(63 downto 46) &
                           mcu_write_req(31 downto 0);
        write_ack       <= '1';
        upd_ack         <= '0';
        write_res       <= mcu_write_req(71 downto 0);

          
        else
          shifter := true;
         idx    := to_integer(unsigned(bus_res(525 downto 512))) /16 * 16;
        memcont := ROM_array(idx);
        --if tags do not match, dirty bit is 1,
        -- and write_back fifo in BUS is not full,
        if memcont(52 downto 52) = "1" and
          memcont(51 downto 51) = "1" and
          memcont(49 downto 32) /= bus_res(63 downto 46) and
          full_wb_i /= '1' then
          wb_req_o <= "110000000" & bus_res(63 downto 32) &
                    memcont(31 downto 0) &
                    ROM_array(idx + 1)(31 downto 0) &
                    ROM_array(idx + 2)(31 downto 0) &
                    ROM_array(idx + 3)(31 downto 0) &
                    ROM_array(idx + 4)(31 downto 0) &
                    ROM_array(idx + 5)(31 downto 0) &
                    ROM_array(idx + 6)(31 downto 0) &
                    ROM_array(idx + 7)(31 downto 0) &
                    ROM_array(idx + 8)(31 downto 0) &
                    ROM_array(idx + 9)(31 downto 0) &
                    ROM_array(idx + 10)(31 downto 0) &
                    ROM_array(idx + 11)(31 downto 0) &
                    ROM_array(idx + 12)(31 downto 0) &
                    ROM_array(idx + 13)(31 downto 0) &
                    ROM_array(idx + 14)(31 downto 0) &
                    ROM_array(idx + 15)(31 downto 0);
        end if;
		  ROM_array(idx) <= "100" & bus_res(63 downto 46) & bus_res(511 downto 480);
			 ROM_array(idx+1) <= "100" & bus_res(63 downto 46) & bus_res(479 downto 448);
			 ROM_array(idx+2) <= "100" & bus_res(63 downto 46) & bus_res(447 downto 416);
			 ROM_array(idx+3) <= "100" & bus_res(63 downto 46) & bus_res(415 downto 384);
          ROM_array(idx+4) <= "100" & bus_res(63 downto 46) & bus_res(383 downto 352);
			 ROM_array(idx+5) <= "100" & bus_res(63 downto 46) & bus_res(351 downto 320);
			 ROM_array(idx+6) <= "100" & bus_res(63 downto 46) & bus_res(319 downto 288);
			 ROM_array(idx+7) <= "100" & bus_res(63 downto 46) & bus_res(287 downto 256);
			 ROM_array(idx+8) <= "100" & bus_res(63 downto 46) & bus_res(255 downto 224);
			 ROM_array(idx+9) <= "100" & bus_res(63 downto 46) & bus_res(223 downto 192);
			 ROM_array(idx+10) <= "100" & bus_res(63 downto 46) & bus_res(191 downto 160);
			 ROM_array(idx+11) <= "100" & bus_res(63 downto 46) & bus_res(159 downto 128);
			 ROM_array(idx+12) <= "100" & bus_res(63 downto 46) & bus_res(127 downto 96);
			 ROM_array(idx+13) <= "100" & bus_res(63 downto 46) & bus_res(95 downto 64);
			 ROM_array(idx+14) <= "100" & bus_res(63 downto 46) & bus_res(63 downto 32);
			 ROM_array(idx+15) <= "100" & bus_res(63 downto 46) & bus_res(31 downto 0);
        upd_ack         <= '1';
        upd_res         <= bus_res(551 downto 512)&ROM_array(to_integer(unsigned(bus_res(525 downto 512))))(31 downto 0);
        write_ack       <= '0';
      -- case valid request
        end if;
      end if;
    end if;
  end process;

end rtl;
