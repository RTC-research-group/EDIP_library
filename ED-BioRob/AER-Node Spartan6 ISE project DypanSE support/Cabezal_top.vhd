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

entity Cabezal_top is
    Port (
			  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  MicroRST : in  STD_LOGIC;
           STR : out  STD_LOGIC;
           NSS : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC;
			  
			  AERIN: in STD_LOGIC_VECTOR(15 downto 0);
           REQ_IN: in STD_LOGIC;
           ACK_IN: out STD_LOGIC;

			  AEROUT: out STD_LOGIC_VECTOR(15 downto 0);
           REQ_OUT: out STD_LOGIC;
           ACK_OUT: in STD_LOGIC;
			  
			  MOTOR_RY: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_RY: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_RX: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_RX: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_LY: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_LY: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_LX: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_LX: in STD_LOGIC_VECTOR(1 downto 0);
			  LEDS: out STD_LOGIC_VECTOR(2 downto 0);
			  MBASE3PH: out STD_LOGIC_VECTOR(0 to 2);
			  ENCBASE: in STD_LOGIC
			  );
end Cabezal_top;

architecture Behavioral of Cabezal_top is

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

component EDDIE_POS_CONTROL
   generic( BASE_ADD: std_logic_vector (7 downto 0):= x"00");
    Port (
			  CLK : in  STD_LOGIC;
           RST_int : in  STD_LOGIC;
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
			  
			  AERIN: in STD_LOGIC_VECTOR(15 downto 0);
           REQ_IN: in STD_LOGIC;
           ACK_IN: out STD_LOGIC;

			  AEROUT: out STD_LOGIC_VECTOR(15 downto 0);
           REQ_OUT: out STD_LOGIC;
           ACK_OUT: in STD_LOGIC;
			  
			  MOTOR_R: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_R: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_L: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_L: in STD_LOGIC_VECTOR(1 downto 0);
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
 signal ADDRESS: std_logic_vector (7 downto 0);
 signal DATA,AERINX,AERINY, AEROUTX, AEROUTY: std_logic_vector (15 downto 0);
 signal WR, REQ_INX, REQ_INY, ACK_INX, ACK_INY, REQ_OUTX, REQ_OUTY, ACK_OUTX, ACK_OUTY: std_logic;
 signal LEDSX,LEDSY: std_logic_vector (2 downto 0);
 signal AUXX, AUXY: std_logic_vector (1 downto 0);
 signal treqin,sreqin,sel: std_logic;
 signal rst_int, RSTh: std_logic;
 

begin
RST_int<=RST and MicroRST;
RSTh <= not RST_int;

BBASE: BASE generic map (BASE_ADD=>x"F0") 
            port map ( CLK50=> CLK, RSTz=>RSTh, ADDRESS => ADDRESS, DATA => DATA, WR=>WR, MU=>MBASE3PH);

BSYN_SPLIT: process (rst_int,clk)
begin
  if rst_int='0' then
     treqin <= '1';
	  sreqin <= '1';
  elsif clk'event and clk='1' then
     treqin <= REQ_IN;
	  sreqin <= treqin;
  end if;
end process;

REQ_INX <= sreqin when (aerin(15)='0') else '1';
REQ_INY <= sreqin when (aerin(15)='1') else '1';
AERINX  <= AERIN  when (aerin(15)='0') else (others =>'1');
AERINY  <= AERIN  when (aerin(15)='1') else (others =>'1');
ACK_IN  <= ACK_INX when (aerin(15)='0') else ACK_INY when (aerin(15)='1') else '1';


  
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

BMX: EDDIE_POS_CONTROL
    generic map (BASE_ADD => x"00")
    Port map(
			  CLK => clk,
           RST_int => rsth,
			  ADDRESS => ADDRESS,
			  DATA => DATA,
			  WR=> WR,
			  
			  AERIN => AERINX,
           REQ_IN => REQ_INX,
           ACK_IN => ACK_INX,

			  AEROUT => AEROUTX,
           REQ_OUT => REQ_OUTX,
           ACK_OUT => ACK_OUTX,
			  
			  MOTOR_R=> MOTOR_RX,
			  ENC_R => ENC_RX,
			  MOTOR_L => MOTOR_LX,
			  ENC_L => ENC_LX,
			  LEDS => LEDSX,
			  AUX => open
			  );
BMY: EDDIE_POS_CONTROL
    generic map (BASE_ADD => x"80")
    Port map(
			  CLK => clk,
           RST_int => rsth,
			  ADDRESS => ADDRESS,
			  DATA => DATA,
			  WR=> WR,
			  
			  AERIN => AERINY,
           REQ_IN => REQ_INY,
           ACK_IN => ACK_INY,

			  AEROUT => AEROUTY,
           REQ_OUT => REQ_OUTY,
           ACK_OUT => ACK_OUTY,
			  
			  MOTOR_R=> MOTOR_RY,
			  ENC_R => ENC_RY,
			  MOTOR_L => MOTOR_LY,
			  ENC_L => ENC_LY,
			  LEDS => LEDSY,
			  AUX => open
			  );
--MOTOR_LY<="00";
--MOTOR_RY<="00";
process (REQ_OUTX, REQ_OUTY, AEROUTX, AEROUTY)
begin
  if REQ_OUTX='0' then
     REQ_OUT <= '0';
	  AEROUT <= AEROUTX;
  elsif REQ_OUTX='1' and REQ_OUTY='0' then
     REQ_OUT <= '0';
	  AEROUT <= AEROUTY;
  else REQ_OUT <= '1'; AEROUT <= (others => '1');
  end if;
end process;

--REQ_OUT <= REQ_OUTX when (REQ_OUTX='0') else REQ_OUTY when (REQ_OUTX='1' and REQ_OUTY='0') else '1';
ACK_OUTX <= ACK_OUT;
ACK_OUTY <= ACK_OUT;
--AEROUT <= AEROUTX when (REQ_OUTX='0') else AEROUTY when (REQ_OUTY='0' and REQ_OUTX='1');

--AUX(1 downto 0) <= AUXX;
--AUX(3 downto 2) <= AUXY;
LEDS <= (LEDSX(2) or LEDSY(2)) & (LEDSX(1) or LEDSY(1)) & (LEDSX(0) or LEDSY(0));
end Behavioral;
