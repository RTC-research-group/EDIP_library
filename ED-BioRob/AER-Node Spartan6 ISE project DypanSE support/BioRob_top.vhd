----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:56:03 07/07/2012 
-- Design Name: 
-- Module Name:    Cabezal_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Dynapse_BioRob_top is
    Port (
			  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  MicroRST : in  STD_LOGIC;
           STR : out  STD_LOGIC;
           NSS : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC;
			  myrst: out std_logic;
			  
			  AERIN: in STD_LOGIC_VECTOR(15 downto 0);
           REQ_IN: in STD_LOGIC;
           ACK_IN: out STD_LOGIC;

           AERIN_E: in STD_LOGIC_VECTOR(5 downto 0);
           REQ_IN_E: in STD_LOGIC;
           ACK_IN_E: out STD_LOGIC;

			  AEROUT: out STD_LOGIC_VECTOR(15 downto 0);
           REQ_OUT: out STD_LOGIC;
           ACK_OUT: in STD_LOGIC;
			  
			  --MOTOR_1: out STD_LOGIC_VECTOR(1 downto 0);
			  tENC_1: out STD_LOGIC_VECTOR(1 downto 0);
			  --MOTOR_2: out STD_LOGIC_VECTOR(1 downto 0);
			  --ENC_2: in STD_LOGIC_VECTOR(1 downto 0);
			  --MOTOR_3: out STD_LOGIC_VECTOR(1 downto 0);
			  --ENC_3: in STD_LOGIC_VECTOR(1 downto 0);
			  --MOTOR_4: out STD_LOGIC_VECTOR(1 downto 0);
			  --ENC_4: in STD_LOGIC_VECTOR(1 downto 0);
			  LEDS: out STD_LOGIC_VECTOR(2 downto 0));
end Dynapse_BioRob_top;

architecture Behavioral of Dynapse_BioRob_top is

component DYNAPSE_MAPPING
	Port (
			  CLK: in std_logic;
			  RST: in std_logic;
			  REQ: in std_logic;
			  AER: in std_logic_vector (15 downto 0);
			  ACK: out std_logic;
			  SPI_WR: in std_logic;
			  SPI_ADDRESS: in std_logic_vector (7 downto 0);
			  SPI_DATA_OUT: in std_logic_vector (15 downto 0);
			  J1_SP: out std_logic;
			  J1_SN: out std_logic;
			  J2_SP: out std_logic;
			  J2_SN: out std_logic;
			  J3_SP: out std_logic;
			  J3_SN: out std_logic;
			  J4_SP: out std_logic;
			  J4_SN: out std_logic
			);
end component;

component BASE 
  generic (BASE_ADD: std_logic_vector (7 downto 0) := x"F0");
  port( rstz: in std_logic;
        clk50: in std_logic;
		  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
		  DATA: in STD_LOGIC_VECTOR(15 downto 0);
		  WR: in STD_LOGIC;
		  MU: out std_logic_vector (1 to 3)
     );
end component;

component POS_CONTROL_PID
   generic( BASE_ADD: std_logic_vector (7 downto 0):= x"00");
    Port (
			  CLK : in  STD_LOGIC;
           RST_int : in  STD_LOGIC;
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
			  
			  J_SP: in std_logic;
			  J_SN: in std_logic;
			  
			  SPIKES_OUT: out STD_LOGIC_VECTOR(13 downto 0);
			  
			  MOTOR: out STD_LOGIC_VECTOR(1 downto 0);
			  ENCODER: in STD_LOGIC_VECTOR(1 downto 0);
			  LEDS: out STD_LOGIC_VECTOR(2 downto 0);
			  AUX: out STD_LOGIC_VECTOR(1 downto 0)
			  );
end component;

	component MICRO_CONTROLLER_SPI_SLAVE is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  ADDRESS: out STD_LOGIC_VECTOR(7 downto 0);		  
				  DATA_OUT: out STD_LOGIC_VECTOR(15 downto 0);
				  WR: out STD_LOGIC;
				  STR : out  STD_LOGIC;
				  NSS : in  STD_LOGIC;
				  SCLK : in  STD_LOGIC;
				  MOSI : in  STD_LOGIC;
				  MISO : out  STD_LOGIC);
	end component;

	component AER_DISTRIBUTED_MONITOR is
   generic (N_SPIKES: integer:=64; LOG_2_N_SPIKES: integer:=6);
   Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN : in  STD_LOGIC_VECTOR (N_SPIKES-1 downto 0);
           AER_DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           AER_REQ : out  STD_LOGIC;
           AER_ACK : in  STD_LOGIC);
end component;

 signal ADDRESS,mADDRESS: std_logic_vector (7 downto 0);
 signal DATA,mDATA: std_logic_vector (15 downto 0);
 signal WR, mWR: std_logic;
 signal LEDS1,LEDS2,LEDS3,LEDS4: std_logic_vector (2 downto 0);
 signal treqin,sreqin,sel: std_logic;
 signal rst_int, RSTh: std_logic;
 
 signal data_int: std_logic_vector (15 downto 0);
 signal SPIKES_OUT: STD_LOGIC_VECTOR(63 downto 0);
 
 signal led_aux: std_logic;
 
 type tstate is (idle, read_event, wait_ack);
 signal state: tstate;
 
 signal ENC_1, ENC_2, ENC_3, ENC_4: STD_LOGIC_VECTOR(1 downto 0);
 signal treqine,sreqine: std_logic;
 signal aerinlatche: std_logic_vector (5 downto 0);
 signal my_spi_reset: std_logic;
 
 signal J1_SP, J1_SN, J2_SP, J2_SN, J3_SP, J3_SN, J4_SP, J4_SN: std_logic; 
 
begin
RST_int <= RST and MicroRST; -- and my_spi_reset;
RSTh <= not RST_int;
myrst <= RST;

--BBASE: BASE generic map (BASE_ADD=>x"F0") 
--            port map ( CLK50=> CLK, RSTz=>RSTh, ADDRESS => ADDRESS, DATA => DATA, WR=>WR, MU=>MBASE3PH);

BSPI_RESET: process (rst, clk)
begin
  if (rst='0') then
     my_spi_reset <= '1';
  elsif (clk'event and clk='1') then
     if (ADDRESS = x"FF" and DATA = x"FFFF" and my_spi_reset = '1') then
	     my_spi_reset <= '0';
	  else my_spi_reset <= '1';
	  end if;
  end if;
end process;

BSYN_SPLIT: process (rst_int,clk)
variable cnt: integer;
begin
  if clk'event and clk='1' then
   if rst_int='0' then
     treqin <= '1';
	  sreqin <= '1';
     treqine <= '1';
	  sreqine <= '1';
	  cnt:=0;
	  aerinlatche <= (others => '0');
	else
     treqin <= REQ_IN;
	  sreqin <= treqin;
     treqine <= REQ_IN_E;
	  sreqine <= treqine;
	  aerinlatche <= AERIN_E;
	  cnt:=cnt+1;
	  if (cnt=1000000) then
	     cnt:=0;
		  led_aux <= not led_aux;
	  end if;
	end if;
  end if;
end process;


BSPI: MICRO_CONTROLLER_SPI_SLAVE
Port map (
	CLK => CLK,
	RST => RSTh,
	ADDRESS => ADDRESS,
	DATA_OUT => DATA,
	WR => WR,
	STR => STR,
	NSS => NSS,
	SCLK => SCLK,
	MOSI => MOSI,
	MISO => MISO);

--BMAP: DYNAPSE_MAPPING
--	Port map (
--			  CLK => CLK, 
--			  RST => RSTh, 
--			  REQ => sreqin,
--			  AER => AERIN, 
--			  ACK => ACK_IN,
--			  SPI_WR => WR, 
--			  SPI_ADDRESS => ADDRESS, 
--			  SPI_DATA_OUT => DATA, 
--			  J1_SP => J1_SP,
--			  J1_SN => J1_SN,
--			  J2_SP => J2_SP,
--			  J2_SN => J2_SN,
--			  J3_SP => J3_SP,
--			  J3_SN => J3_SN,
--			  J4_SP => J4_SP,
--			  J4_SN => J4_SN);

B_AER_E_TO_ENC: process (clk, rst_int)
begin
  if (clk'event and clk='1') then
   if (rst_int = '0') then
     state <= idle;
	  ACK_IN_E <= '1';
	  ENC_1 <= "00";
	  ENC_2 <= "00";
	  ENC_3 <= "00";
	  ENC_4 <= "00";
	else
	  if (sreqine = '0' and state = idle) then
			state <= read_event;
	  elsif (state = read_event) then
			state <= wait_ack;
			ACK_IN_E <= '0';
			if (aerinlatche = "000001") then
				ENC_1 <= "01";
			elsif (aerinlatche = "000010") then
				ENC_1 <= "10";
			elsif (aerinlatche = "010000") then
				ENC_2 <= "01";
			elsif (aerinlatche = "010001") then
				ENC_2 <= "10";
			elsif (aerinlatche = "100000") then
				ENC_3 <= "01";
			elsif (aerinlatche = "100001") then
				ENC_3 <= "10";
			elsif (aerinlatche = "110000") then
				ENC_4 <= "01";
			elsif (aerinlatche = "110001") then
				ENC_4 <= "10";
			end if;
		elsif (state = wait_ack and sreqine = '1') then
			state <= idle;
			ACK_IN_E <= '1';
		elsif (state = idle) then
			ENC_1 <= "00";
			ENC_2 <= "00";
			ENC_3 <= "00";
			ENC_4 <= "00";
		end if;
	 end if;
	end if;
end process;
tENC_1 <= ENC_1;

BM1: POS_CONTROL_PID
    generic map (BASE_ADD => x"00")
    Port map(
			  CLK => clk,
           RST_int => rsth,
			  ADDRESS => ADDRESS,   --
			  DATA => DATA,			--
			  WR=> WR,					--
			  
			  J_SP => J1_SP,
			  J_SN => J1_SN,

			  SPIKES_OUT=>SPIKES_OUT(13 downto 0),
			  
			  MOTOR=> open,
			  ENCODER => ENC_1,
			  LEDS => LEDS1,
			  AUX => open
			  );
SPIKES_OUT(15 downto 14)<=(others=>'0');

			  
BM2: POS_CONTROL_PID
    generic map (BASE_ADD => x"20")
    Port map(
			  CLK => clk,
           RST_int => rsth,
			  ADDRESS => ADDRESS,   --
			  DATA => DATA,			--
			  WR=> WR,					--
			  
			  J_SP => J2_SP,
			  J_SN => J2_SN,

			  SPIKES_OUT=>SPIKES_OUT(29 downto 16),
			  
			  MOTOR=> open,
			  ENCODER => ENC_2,
			  LEDS => LEDS2,
			  AUX => open
			  );
SPIKES_OUT(31 downto 30)<=(others=>'0');


BM3: POS_CONTROL_PID
    generic map (BASE_ADD => x"40")
    Port map(
			  CLK => clk,
           RST_int => rsth,
			  ADDRESS => ADDRESS,   --
			  DATA => DATA,			--
			  WR=> WR,					--
			  
			  J_SP => J3_SP,
			  J_SN => J3_SN,

			  SPIKES_OUT=>SPIKES_OUT(45 downto 32),
			  
			  MOTOR=> open,
			  ENCODER => ENC_3,
			  LEDS => LEDS3,
			  AUX => open
			  );
SPIKES_OUT(47 downto 46)<=(others=>'0');

			  
BM4: POS_CONTROL_PID
    generic map (BASE_ADD => x"60")
    Port map(
			  CLK => clk,
           RST_int => rsth,
			  ADDRESS => ADDRESS,   --
			  DATA => DATA,			--
			  WR=> WR,					--
			  
			  J_SP => J4_SP,
			  J_SN => J4_SN,

			  SPIKES_OUT=>SPIKES_OUT(61 downto 48),
			  
			  MOTOR=> open,
			  ENCODER => ENC_4,
			  LEDS => LEDS4,
			  AUX => open
			  );
SPIKES_OUT(63 downto 62)<=(others=>'0');
			  
			  
--	AEROUT <= SPIKES_OUT (15 downto 0);
	AER_MON: AER_DISTRIBUTED_MONITOR

     Port map(
			  CLK => clk,
           RST => rsth,
			  
           SPIKES_IN =>SPIKES_OUT,
			  
           AER_DATA_OUT =>AEROUT,
           AER_REQ =>REQ_OUT,
           AER_ACK =>ACK_OUT
			 );

--REQ_OUT <= REQ_OUTX when (REQ_OUTX='0') else REQ_OUTY when (REQ_OUTX='1' and REQ_OUTY='0') else '1';
--ACK_OUTX <= ACK_OUT;
--ACK_OUTY <= ACK_OUT;
--AEROUT <= AEROUTX when (REQ_OUTX='0') else AEROUTY when (REQ_OUTY='0' and REQ_OUTX='1');

LEDS <= (LEDS1(2) or LEDS2(2) or LEDS3(2) or LEDS4(2)) & (LEDS1(1) or LEDS2(1) or LEDS3(1) or LEDS4(1)) & 
        led_aux; --(LEDS1(0) or LEDS2(0) or LEDS3(0) or LEDS4(0));
end Behavioral;

