library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwr is
  Generic(
    constant REQ_WIDTH : positive := 5;
    constant DATA_WIDTH : positive := 3;
    --* Assume req is:
    --* [:2] dev_id
    --* [2:5] data, where:
    --*   [2:4] payload
    --*   [4] valid_bit

    constant GFX_ID : std_logic_vector := "00";
    constant AUDIO_ID : std_logic_vector := "01";
    constant USB_ID : std_logic_vector := "10";    
    constant UART_ID : std_logic_vector := "11"    
    );
  Port (  Clock: in std_logic;
          reset: in std_logic;
          
          req_in   : in STD_LOGIC_VECTOR(REQ_WIDTH - 1 downto 0);
          res_out  : out STD_LOGIC_VECTOR(REQ_WIDTH - 1 downto 0);
          full_preq: out std_logic:='0';
          
          gfx_res_in  : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
          gfx_req_out : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

          uart_res_in : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
          uart_req_out : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
          
          usb_res_in : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
          usb_req_out : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

          audio_res_in : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
          audio_req_out : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
          );            
end pwr;

architecture rtl of pwr is
  signal tmp_req: std_logic_vector(REQ_WIDTH - 1 downto 0);
  signal in1,out1 : std_logic_vector(REQ_WIDTH - 1 downto 0);
  signal in2,out2 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal we1,re1,emp1,we2,re2,emp2 : std_logic:='0';
begin

  pwr_req_fifo: entity work.fifo(rtl) 
	generic map(
      DATA_WIDTH => 5,
      FIFO_DEPTH => 16
     )
	port map(
      CLK=>Clock,
      RST=>reset,
      DataIn=>in1,
      WriteEn=>we1,
      ReadEn=>re1,
      DataOut=>out1,
      Full=>full_preq,
      Empty=>emp1
      );
  
  pwr_req_fifo_handler: process (Clock)      
  begin
    if reset='1' then
      we1<='0';
    elsif rising_edge(Clock) then
      if req_in(REQ_WIDTH - 1 downto REQ_WIDTH - 1)="1" then
        in1 <= req_in;
        we1 <= '1';
      else
        we1 <= '0';
      end if;
    end if;
  end process;

  --* Forwards req from ic to dev,
  --*    waits for resp from dev, and
  --*    forwards res back to ic
  req_handler : process (reset, Clock)
    variable nilreq:std_logic_vector(REQ_WIDTH - 1 downto 0):=(others => '0');
    variable state: integer :=0;
  begin
    if (reset = '1') then
      gfx_req_out<= nilreq(DATA_WIDTH - 1 downto 0);
    --tmp_write_req <= nilreq;
    elsif rising_edge(Clock) then
      res_out <= "00000";
      if state =0 then
        gfx_req_out <= nilreq(DATA_WIDTH - 1 downto 0);
        audio_req_out <= nilreq(DATA_WIDTH - 1 downto 0);
        usb_req_out <= nilreq(DATA_WIDTH - 1 downto 0);
        uart_req_out <= nilreq(DATA_WIDTH - 1 downto 0);
        if re1 = '0' and emp1 ='0' then
          re1 <= '1';
          state := 1;
        end if;
        
      elsif state = 1 then
        re1 <= '0';
        if out1(REQ_WIDTH - 1 downto REQ_WIDTH - 1)="1" then
          tmp_req <= out1;
          if out1(1 downto 0) = GFX_ID then
            state := 2;
          elsif out1(1 downto 0) = AUDIO_ID then
            state := 3;
          elsif out1(1 downto 0) = USB_ID then
            state := 4;
          elsif out1(1 downto 0) = UART_ID then
            state := 5;
          end if;
        end if;
      elsif state = 2 then
        gfx_req_out<=tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
        state := 6;
      elsif state = 3 then
        audio_req_out <= tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
        state := 7;
      elsif state = 4 then
        usb_req_out <= tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
        state := 8;
      elsif state = 5 then
        uart_req_out<=tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
        state := 9;
      elsif state = 6 then
        gfx_req_out <= (others => '0');
        if gfx_res_in(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
          res_out <= tmp_req;
          state :=0;
        end if;
      elsif state = 7 then
        audio_req_out <= (others => '0');
        if audio_res_in(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
          res_out <= tmp_req;
          state :=0;
        end if;
      elsif state = 8 then
        usb_req_out <= (others => '0');
        if usb_res_in(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
          res_out <= tmp_req;
          state :=0;
        end if;
      elsif state = 9 then
        uart_req_out <= (others => '0');
        if uart_res_in(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
          res_out <= tmp_req;
          state :=0;
        end if;
      end if;
    end if;
  end process;
  
end rtl;
