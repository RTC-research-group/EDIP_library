----------------------------------------------------------------------------------
-- Company:  USE - CITEC (visiting professor)
-- Engineer: alejandro linares-barranco
-- 
-- Create Date:    22:56:03 09/08/2018 
-- Design Name: 
-- Module Name:    BioRob_AERrobot - Behavioral 
-- Project Name: 
-- Target Devices: Sparta3-400 AER-Robot platform
-- Tool versions:  ISE 14.7 on windows 7 (Sparta3 not supported on ISE 14.7 for win 10)
-- Description:    This entity is an interface between the BioRob robotic arm and the AER-Node
--						 AER-Node implements the spike-based controller and merge all spiking motor signals in an AER bus
-- 					 This blocks read that AER-bus, expand pulses and send them to the robot through AER-Robot power modules
--						 Furthermore, this design read ENC signals of the motors, convert them to spikes, merge them in a second 
--						 AER bus and send them to the AER-Node.
--						 Finally, this design is wiring the SPI interface of the 8051 microcontroller to the AER-Node throug AUX 
--						 digital port, so USB connection to AER-Robot will serve as a configuration port to the motor controller 
-- 					 in the AER-Node board.
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

entity BioRob_AERrobot is
    Port (
			  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  MicroRST : in  STD_LOGIC;
           STR : out  STD_LOGIC;
           NSS : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC;
			  S0 : in STD_LOGIC;
			  S1 : in STD_LOGIC;
			  
			  AERIN: in STD_LOGIC_VECTOR(15 downto 0);
           REQ_IN: in STD_LOGIC;
           ACK_IN: out STD_LOGIC;

			  AEROUT: out STD_LOGIC_VECTOR(15 downto 0);
           REQ_OUT: out STD_LOGIC;
           ACK_OUT: in STD_LOGIC;
			  
			  MOTOR_1: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_1: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_2: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_2: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_3: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_3: in STD_LOGIC_VECTOR(1 downto 0);
			  MOTOR_4: out STD_LOGIC_VECTOR(1 downto 0);
			  ENC_4: in STD_LOGIC_VECTOR(1 downto 0);
			  LEDS: out STD_LOGIC_VECTOR(2 downto 0);
			  
			  RAE_M1: inout STD_LOGIC_VECTOR(4 downto 0);
			  RAE_M2: inout STD_LOGIC_VECTOR(4 downto 0);
			  RAE_M3: inout STD_LOGIC_VECTOR(4 downto 0);
			  RAE_M4: inout STD_LOGIC_VECTOR(4 downto 0);
			  
			  S6_NSS: out STD_LOGIC;
			  S6_SCLK: out STD_LOGIC;
			  S6_MOSI: out STD_LOGIC;
			  S6_MISO: in STD_LOGIC;
			  S6_MICRORST: out STD_LOGIC);
			  
end BioRob_AERrobot;

architecture Behavioral of BioRob_AERrobot is

component EnCoderEventGenerator 
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           spikes : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

component BiDirPFM 
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
			  PULSE : in  STD_LOGIC_VECTOR (1 downto 0);
			  PFM_out: out  STD_LOGIC_VECTOR (1 downto 0));
end component;

component AER_DISTRIBUTED_MONITOR 
generic (N_SPIKES: integer:=64; LOG_2_N_SPIKES: integer:=6);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN : in  STD_LOGIC_VECTOR (N_SPIKES-1 downto 0);
           AER_DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           AER_REQ : out  STD_LOGIC;
           AER_ACK : in  STD_LOGIC);
end component;

component MICRO_CONTROLLER_SPI_SLAVE 
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
  			  ADDRESS: out STD_LOGIC_VECTOR(7 downto 0);		  
			  DATA_OUT: out STD_LOGIC_VECTOR(15 downto 0);
			  DATA_IN: in STD_LOGIC_VECTOR(23 downto 0);
			  WR: out STD_LOGIC;
           STR : out  STD_LOGIC;
           NSS : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC);
end component;

component SPI_MASTER_16bits is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           NSS : out  STD_LOGIC;
           MISO : in  STD_LOGIC;
           DATA : out  STD_LOGIC_VECTOR (15 downto 0);
           DR : out  STD_LOGIC);
end component;

component SPI_MASTER_64bits is
	 Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           NSS : out  STD_LOGIC;
           MISO : in  STD_LOGIC;
			  MOSI : out STD_LOGIC;
			  DATA_I : in STD_LOGIC_VECTOR (63 downto 0);
			  DR_I: in STD_LOGIC;
           DATA_O : out  STD_LOGIC_VECTOR (15 downto 0); -- byte1 byte0
			  DATA_ROLL_O: out STD_LOGIC_VECTOR (7 downto 0);
           DR_O : out  STD_LOGIC);
end component;

component FSM_MELEXIS is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
		   data_ready_o : out STD_LOGIC; 
		   --data to be sent to the the SPI_64 bits
           DATA_o : out  STD_LOGIC_VECTOR (63 downto 0); 
		   data_ready_i : in STD_LOGIC; 
		   --data coming from the slave (sensor). alpha is 14-bits wide the other two bits are used for diagnosis status.   
		   DATA_i: in STD_LOGIC_VECTOR (15 downto 0); 
			DATA_roll_i: in STD_LOGIC_VECTOR (7 downto 0);
			data_from_sensor_ok_o: out STD_LOGIC; 
           EN_i : in  STD_LOGIC); --input from the MUX. It enables the FSM so a data have to be read. 
end component;

 signal REQ_INX, REQ_INY, ACK_INX, ACK_INY, REQ_OUTX, REQ_OUTY, ACK_OUTX, ACK_OUTY: std_logic;
-- signal LEDS: std_logic_vector (2 downto 0);
 signal treqin,sreqin,led_reqin: std_logic;
 signal tackout,sackout, led_ackout: std_logic;
 signal rst_int, RSTh: std_logic;
 
 signal SPIKES_OUT: STD_LOGIC_VECTOR(63 downto 0);
 
 signal spike_M1, spike_M2, spike_M3, spike_M4: std_logic_vector (1 downto 0);
 signal spike_encoder_m1, spike_encoder_m2, spike_encoder_m3, spike_encoder_m4: std_logic_vector (1 downto 0);
 
 type tstate is (idle, read_event, wait_ack);
 signal state: tstate;
 --signal led_reqin: std_logic;
	
 signal ADDRESS: std_logic_vector (7 downto 0);
 signal DATA, aerinlatch: std_logic_vector (15 downto 0);
 signal DATA_IN: std_logic_vector (23 downto 0);
 signal WR: std_logic;
 
 signal led_config: std_logic;

 signal J1_reg, J2_reg, J3_reg, J4_reg: std_logic_vector (15 downto 0);
 signal J1_pos, J2_pos, J3_pos, J4_pos: std_logic_vector (15 downto 0);
 signal J1_dr, J2_dr, J3_dr, J4_dr: std_logic;

 signal NSS_RAE_J1, NSS_RAE_J2, NSS_RAE_J3, NSS_RAE_J4: std_logic;
 
 signal test_sensor_dr: std_logic;
 signal test_sensor: std_logic_vector(63 downto 0);
 
 signal enable_melexis: STD_LOGIC:='0';
 signal melexis_J3_dr: STD_LOGIC:='0';
  signal s_data_roll: std_logic_vector (7 downto 0);

 
begin
RST_int <= RST and MicroRST;
RSTh <= not RST_int;

STR <= '0';
--MISO <= S6_MISO;
S6_MOSI <= MOSI;
S6_NSS <= NSS;
S6_SCLK <= SCLK;
S6_MICRORST <= MICRORST;

--RAE_M3[0] <= MOSI;
--RAE_M1[1] <= MISO; --ojo
--RAE_M3[2] <= SCLK;
--RAE_M3[3] <= NSS_RAE_J4;

--RAE_M4[0] <= MOSI;
--RAE_M1[1] <= MISO; --ojo
--RAE_M4[2] <= SCLK;
--RAE_M4[3] <= NSS_RAE_J4;

BSPI: MICRO_CONTROLLER_SPI_SLAVE
Port map (
	CLK => CLK,
	RST => RSTh,
	ADDRESS => ADDRESS,
	DATA_OUT => DATA,
	DATA_IN => DATA_IN,
	WR => WR,
	STR => open,
	NSS => NSS,
	SCLK => SCLK,
	MOSI => MOSI,
	MISO => MISO);


----------------------------
-- ENCODER´S READ AND CONVERSION TO SPIKES, THEN MERGING TO AER BUS
----------------------------
ENCODER_M1:EnCoderEventGenerator
	Port map ( 
		  CLK =>CLK,
		  RST =>RSTh,
        A =>ENC_1(1),
        B =>ENC_1(0),
        spikes =>spike_encoder_m1
	);
SPIKES_OUT(2 downto 1) <= spike_encoder_m1;

ENCODER_M2:EnCoderEventGenerator
	Port map ( 
		  CLK =>CLK,
		  RST =>RSTh,
        A =>ENC_2(1),
        B =>ENC_2(0),
        spikes =>spike_encoder_m2
	);
SPIKES_OUT(17 downto 16) <= spike_encoder_m2;

ENCODER_M3:EnCoderEventGenerator
	Port map ( 
		  CLK =>CLK,
		  RST =>RSTh,
        A =>ENC_3(1),
        B =>ENC_3(0),
        spikes =>spike_encoder_m3
	);
SPIKES_OUT(33 downto 32) <= spike_encoder_m3;

ENCODER_M4:EnCoderEventGenerator
	Port map ( 
		  CLK =>CLK,
		  RST =>RSTh,
        A =>ENC_4(1),
        B =>ENC_4(0),
        spikes =>spike_encoder_m4
	);
SPIKES_OUT(49 downto 48) <= spike_encoder_m4;

	AER_MON: AER_DISTRIBUTED_MONITOR

     Port map(
			  CLK => CLK,
           RST => RSTh,
			  
           SPIKES_IN =>SPIKES_OUT,
			  
           AER_DATA_OUT =>AEROUT,
           AER_REQ =>REQ_OUT,
           AER_ACK =>sackout
			 );

----------------------------
-- AER INPUT BUS DECODIFICATION AND SPIKES EXPANSION FOR SENDING TO MOTORS
----------------------------

B_AER_TO_MOTOR: process (clk, rst_int) 
begin
   if (rst_int = '0') then
	   state <= idle;
		ACK_IN <= '1';
		spike_M1 <= (others => '0');
		spike_M2 <= (others => '0');
		spike_M3 <= (others => '0');
		spike_M4 <= (others => '0');
	elsif (clk'event and clk='1') then
	   if (sreqin = '0' and state = idle) then
			state <= read_event;
	   elsif (state = read_event) then
			state <= wait_ack;
			ACK_IN <= '0';
			if (aerinlatch = "0000000000001000") then
			   spike_M1 <= "01"; 
			elsif (aerinlatch = "0000000000001001") then
				spike_M1 <= "10";
		   elsif (aerinlatch = "0000000000011000") then
			   spike_M2 <= "01"; 
			elsif (aerinlatch = "0000000000011001") then
				spike_M2 <= "10";
		   elsif (aerinlatch = "0000000000101000") then
			   spike_M3 <= "01"; 
			elsif (aerinlatch = "0000000000101001") then
				spike_M3 <= "10";
		   elsif (aerinlatch = "0000000000111000") then
			   spike_M4 <= "01"; 
			elsif (aerinlatch = "0000000000111001") then
				spike_M4 <= "10";
		   end if;
		elsif (state = wait_ack and sreqin = '1') then
			state <= idle;
			ACK_IN <= '1';
	   elsif (state = idle) then
			spike_M1 <= (others => '0');
			spike_M2 <= (others => '0');
			spike_M3 <= (others => '0');
			spike_M4 <= (others => '0');
	   end if; 
	end if;
end process;

SPIKE_EXPANSOR_M1: BiDirPFM 
	port map (
			  CLK =>CLK,
			  RST =>RSTh,
			  BASE_ADDRESS=> x"12",
			  ADDRESS=> ADDRESS, 
			  DATA=> DATA,
			  WR=> WR, 
			  PULSE=>spike_M1,
	    	  PFM_out=>MOTOR_1
				);

SPIKE_EXPANSOR_M2: BiDirPFM 
	port map (
			  CLK =>CLK,
			  RST =>RSTh,
			  BASE_ADDRESS=> x"32",
			  ADDRESS=> ADDRESS, 
			  DATA=> DATA,
			  WR=> WR, 
			  PULSE=>spike_M2,
	    	  PFM_out=>MOTOR_2
				);

SPIKE_EXPANSOR_M3: BiDirPFM 
	port map (
			  CLK =>CLK,
			  RST =>RSTh,
			  BASE_ADDRESS=> x"52",
			  ADDRESS=> ADDRESS, 
			  DATA=> DATA,
			  WR=> WR, 
			  PULSE=>spike_M3,
	    	  PFM_out=>MOTOR_3
				);

SPIKE_EXPANSOR_M4: BiDirPFM 
	port map (
			  CLK =>CLK,
			  RST =>RSTh,
			  BASE_ADDRESS=> x"72",
			  ADDRESS=> ADDRESS, 
			  DATA=> DATA,
			  WR=> WR, 
			  PULSE=>spike_M4,
	    	  PFM_out=>MOTOR_4
				);

--------------------
-- SYNC SIGNALS AND LEDS
--------------------


BSYN_SPLIT: process (rst_int,clk)
begin
  if rst_int='0' then
     treqin <= '1';
	  sreqin <= '1';
	  led_reqin <= '1';
	  tackout <= '1';
	  sackout <= '1';
	  aerinlatch <= (others => '0');
  elsif clk'event and clk='1' then
     treqin <= REQ_IN;
	  sreqin <= treqin;
	  led_reqin <= sreqin;

  	  tackout <= ACK_OUT;
  	  sackout <= tackout;
	  led_ackout <= sackout;
	  aerinlatch <= AERIN;
  end if;
end process;

led_config <= '1' when (AERIN = x"0009") else '0';

LEDS <= (ENC_1(0) or ENC_2(0) or ENC_3(0) or ENC_4(0)) & (led_reqin) & (led_config);

BSPIS_reg: process (clk, rst_int) 
begin
	if (clk'event and clk='1') then
	   if (rst_int = '0') then
			J1_reg <= (others => '1');
			J2_reg <= (others => '1');
			J3_reg <= (others => '1');
			J4_reg <= (others => '1');
			DATA_IN <= (others =>'1');
			--test_sensor_dr <= '0';
			--test_sensor <= (others =>'0');
			enable_melexis<='0';
		else
			if (J1_dr = '1') then
				J1_reg <= J1_pos;
			end if;
			if (J2_dr = '1') then
				J2_reg <= J2_pos;
			end if;
			--if (J3_dr = '1') then
			if (melexis_J3_dr = '1') then
				J3_reg <= J3_pos;
			end if;
			if (J4_dr = '1') then
				J4_reg <= J4_pos;
			end if;
			--test_sensor_dr <= '0';
			if (WR = '1' and ADDRESS = x"F1") then
				DATA_IN <= x"01" & J1_reg;
			elsif (WR = '1' and ADDRESS = x"F2") then
				DATA_IN <= x"02" & J2_reg;
			elsif (WR = '1' and ADDRESS = x"F3") then
				DATA_IN <= x"03" & J3_reg;
				--test_sensor_dr <= '1';
				enable_melexis<='1';
				--test_sensor <= x"0000FFFF000013EA";
			elsif (WR = '1' and ADDRESS = x"F4") then
				DATA_IN <= x"04" & J4_reg;
			end if;
		end if;
	end if;
end process;

--DATA_IN <= x"01" & J1_pos;

BSPIS_J1: SPI_MASTER_16bits port map
			( clk => clk,
           rst => rst_int,
           SCK => RAE_M1(2),
           NSS => RAE_M1(3),
           MISO => RAE_M1(1),
           DATA => J1_pos,
           DR => J1_dr);

BSPIS_J2: SPI_MASTER_16bits port map
			( clk => clk,
           rst => rst_int,
           SCK => RAE_M2(2),
           NSS => RAE_M2(3),
           MISO => RAE_M2(1),
           DATA => J2_pos,
           DR => J2_dr);

BSPIS_J3: SPI_MASTER_64bits port map
			( clk => clk,
           rst => rst_int,
           SCK => RAE_M3(2),  -- brown  -- GND: black & red
           NSS => RAE_M3(3),  -- yellow
           MISO => RAE_M3(1), -- orange
			  MOSI => RAE_M3(0), -- green
			  DATA_I => test_sensor,
			  DR_I => test_sensor_dr,
           DATA_O => J3_pos,
			  DATA_ROLL_O => s_data_roll,
           DR_O => J3_dr);
			  
MELEXIS: FSM_MELEXIS port map
			( clk_i => clk, 
           rst_i => rst_int,
				data_ready_o => test_sensor_dr, 
		   --data to be sent to the the SPI_64 bits
           DATA_o => test_sensor,
				data_ready_i => J3_dr,
		   --data coming from the slave (sensor). alpha is 14-bits wide the other two bits are used for diagnosis status.   
				DATA_i => J3_pos, 
				DATA_roll_i =>s_data_roll,
				data_from_sensor_ok_o => melexis_J3_dr,
           EN_i => enable_melexis); --input from the MUX. It enables the FSM so a data have to be read. 



--BSPIS_J4: SPI_MASTER_16bits port map
--			( clk => clk,
--           rst => rst_int,
--           SCK => RAE_M4(2),
--           NSS => RAE_M4(3),
--           MISO => RAE_M4(1),
--           DATA => J4_pos,
--           DR => J4_dr);
end Behavioral;

