library ieee;
use ieee.std_logic_1164.all;

package type_defs is
  type CMD_TYP is (READ, WRITE);
  --constant RD_CMD : std_logic_vector(1 downto 0) := "01";
  --constant WR_CMD : std_logic_vector(1 downto 0) := "10";
  --constant WB_CMD : std_logic_vector(1 downto 0) := "11";
  
  constant READ_CMD  : std_logic_vector(7 downto 0) := "01000000";
  constant WRITE_CMD : std_logic_vector(7 downto 0) := "10000000";
  constant ZEROS_CMD : std_logic_vector(7 downto 0) := "00000000";

  constant CPU0_ID  : std_logic_vector(2 downto 0) := "000";
  constant GFX_ID   : std_logic_vector(2 downto 0) := "001";
  constant UART_ID  : std_logic_vector(2 downto 0) := "010";
  constant USB_ID   : std_logic_vector(2 downto 0) := "011";
  constant AUDIO_ID : std_logic_vector(2 downto 0) := "100";
  constant CPU1_ID  : std_logic_vector(2 downto 0) := "101";
  
  --constant ZEROS72 : std_logic_vector(72 downto 0) := (others => '0');
  --constant ZEROS75 : std_logic_vector(75 downto 0) := (others => '0');
  
  -- indices
  --constant MEM_FOUND_IDX : positive := 56;
end type_defs;
