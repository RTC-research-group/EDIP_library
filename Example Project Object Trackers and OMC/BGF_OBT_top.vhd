----------------------------------------------------------------------------------
-- Company: INI
-- Engineer: Alejandro Linares & Diederik Paul Moeys
-- 
-- Create Date:    18:56:31 01/05/2014 
-- Design Name: 
-- Module Name:    BAF, OMC and OT top module - Behavioral 
-- Project Name:   VISUALIZE
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ObjectMotionCellConfigRecords.all;

entity BGF_OBT_top is
    Port(
			-- From DVS
	 	   aer_in_data 	: in  std_logic_vector(16 downto 0);
         aer_in_req_l 	: in  std_logic;
         aer_in_ack_l 	: out std_logic;
		   -- To PC
			aer_out_data 	: out std_logic_vector(16+8 downto 0);
         aer_out_req_l 	: out std_logic;
         aer_out_ack_l 	: in  std_logic;
			-- Fundamental signals
         rst_l 			: in  std_logic;
         clk50 			: in  std_logic;
			NSS 				: in  std_logic;
		   SCLK 				: in  std_logic;
			MOSI 				: in  std_logic;
			MISO 				: out std_logic;
			-- SPI
         spi_data 		: out std_logic_vector(7 downto 0);
         spi_address 	: out std_logic_vector(7 downto 0);
         spi_wr 			: out std_logic;
			-- Enables
		   OT_active		: out std_logic_vector(3 downto 0);
		   BGAF_en			: out std_logic;
		   WS2CAVIAR_en	: out std_logic;
		   DAVIS_en			: out std_logic;
		   LED				: out std_logic_vector(2 downto 0)
		  );
end BGF_OBT_top;

architecture Behavioral of BGF_OBT_top is
--This component is used in AERnode board, not in DevBoard
component SPI_SLAVE
    Port( CLK 	: in   std_logic;
           RST 	: in   std_logic;
           --STR 	: out  std_logic;
           NSS 	: in   std_logic;
           SCLK 	: in   std_logic;
           MOSI 	: in   std_logic;
           MISO 	: out  std_logic;
		   WR       : out  std_logic;
		   ADDRESS  : out  std_logic_vector(7 downto 0);
		   DATA_OUT : out  std_logic_vector(7 downto 0));
end component;

component RetinaFilter -- Background Activity Filter
    Generic(
	          BASEADDRESS : std_logic_vector(7 downto 0) :=(others => '0')
		  );
    Port(
	 	   aer_in_data 	: in 	std_logic_vector(16 downto 0);
           aer_in_req_l : in 	std_logic;
           aer_in_ack_l : out std_logic;
		   aer_out_data 	: out	std_logic_vector(16 downto 0);
           aer_out_req_l: out std_logic;
           aer_out_ack_l: in 	std_logic;
           rst_l 			: in 	std_logic;
           clk50 			: in 	std_logic;
		   BGAF_en			: out std_logic;
		   WS2CAVIAR_en	: out std_logic;
		   DAVIS_en			: out std_logic;
		   alex				: out std_logic_vector(13 downto 0); -- for debugging purpose
		   spiWR				: in  std_logic;
		   spiADDRESS		: in  std_logic_vector(7 downto 0);
		   spiDATA			: in  std_logic_vector(7 downto 0);
			LED				: out std_logic);
end component;

--------------------------------------------------------------------------------
-- Mother OMC component declaration --------------------------------------------
--------------------------------------------------------------------------------
component ObjectMotionMotherCell
    port(
	 	-- Clock and reset inputs
		Clock_CI	  					:  in  std_logic;
		Reset_RI						:  in  std_logic;
		-- LHS in communication
		MotherOMCreq_ABI 	      :	in	 std_logic; -- Active low
		MotherOMCack_ABO 	      :	out std_logic; -- Active low
		PDVSdata_ADI				: 	in	 unsigned(16 downto 0); -- Data in size	
		-- RHS out communication
		DaughterOMCreq_ABO   	:	out std_logic; -- Active low
		NextSMack_ABI 	      	:	in  std_logic; -- Active low
		OMCfireMotherOMC_DO		: 	out unsigned(8 downto 0);
		--SPI
		spiWR							:  in  std_logic;
		spiADDRESS					:  in  std_logic_vector(7 downto 0);
		spiDATA						:  in  std_logic_vector(7 downto 0)
		);
end component;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Arbiter Merger for OMC and OBT ----------------------------------------------
--------------------------------------------------------------------------------
component arb4_1
Port ( clk 		: in std_logic;
		 reset	: in std_logic;
		 AERin1	: in   std_logic_vector(16 downto 0);
		 reqIN1	: in   std_logic;
		 ackIN1	: out  std_logic;
		 AERin2	: in   std_logic_vector(16 downto 0);
		 reqIN2	: in   std_logic;
		 ackIN2	: out  std_logic;
		 AERin3	: in   std_logic_vector(16 downto 0);
		 reqIN3	: in   std_logic;
		 ackIN3	: out  std_logic;
		 AERin4	: in   std_logic_vector(16 downto 0);
		 reqIN4	: in   std_logic;
		 ackIN4	: out  std_logic;
		 AERout	: out  std_logic_vector(16 downto 0);
		 reqOUT	: out  std_logic;
		 ackOUT	: in	std_logic	 
		);
end component;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

component HotPixelsFilter -- Shared Req with OMC, merged Ack
    Generic(
		BASEADDRESS 	: 		std_logic_vector(7 downto 0) :=(others => '0')
		  );
    Port(
	 	aer_in_data 	: in 	std_logic_vector(16 downto 0);
      aer_in_req_l 	: in 	std_logic;
      aer_in_ack_l 	: out std_logic;
		aer_out_data 	: out std_logic_vector(16 downto 0);
      aer_out_req_l 	: out std_logic;
      aer_out_ack_l 	: in 	std_logic;
      rst_l 			: in 	std_logic;
      clk50 			: in 	std_logic;
		alex				: out std_logic_vector(2 downto 0);
		spiWR				: in 	std_logic;
		spiADDRESS		: in 	std_logic_vector(7 downto 0);
		spiDATA			: in 	std_logic_vector(7 downto 0));
end component;

component ObjectTracker

Generic( BASEADDRESS : 	std_logic_vector(7 downto 0) :=(others => '0')
			  );
Port(
	 	aer_in_data 	: in 	std_logic_vector(16 downto 0);
        aer_in_req_l : in 	std_logic;
        aer_in_ack_l : out std_logic;
		aer_out_data 	: out std_logic_vector(16+8 downto 0);
        aer_out_req_l: out std_logic;
        aer_out_ack_l: in 	std_logic;
        rst_l 			: in 	std_logic;
        clk50 			: in 	std_logic;
		OT_active		: out std_logic_vector(3 downto 0);
 		CFG_en			: out std_logic_vector(3 downto 0);
		spiWR				: in 	std_logic;
		spiADDRESS		: in 	std_logic_vector(7 downto 0);
		spiDATA			: in 	std_logic_vector(7 downto 0);
		LED				: out std_logic_vector(2 downto 0)
		);
end component;

component BUF
 port(
   O : out std_logic;
   I : in  std_logic
 );
end component;

-- AER
signal aerouti : std_logic_vector(16 downto 0);
signal aerini  : std_logic_vector(9 downto 0);
signal rowdelay: unsigned(4 downto 0);
-- SPI
signal spiWR		: std_logic;
signal spiADDRESS	: std_logic_vector(7 downto 0);
signal spiDATA		: std_logic_vector(7 downto 0);
-- BF filter
signal taer_out_req_l, req_bf2ot, ack_bf2ot, kk1, kk2, tack_bf2ot: std_logic;
signal aer_bf2ot, aer_in_datat     : std_logic_vector(16 downto 0);
signal aer_bf2ot_i,aer_out_datat                 : std_logic_vector(16 downto 0); ---,aer_out_datat was 25
signal taer_out_datat: std_logic_vector(16+8 downto 0);
-- Enable
signal rst_lb, rst        	: std_logic;
signal tOT_active, tCFG_en	: std_logic_vector(3 downto 0);
-- CLK, Latch, LED
signal fx3_data						: std_logic_vector(15 downto 0);
signal dclk, d1clk, d2clk			: std_logic;
signal dlatch, d1latch, d2latch	: std_logic;
signal ddata, d1data					: std_logic;
signal dclk_pulse						: std_logic;
signal BGAFen							: std_logic;
signal alex								: std_logic_vector(13 downto 0);
signal saer_in_req_l, saer_out_ack_l, req1, ack1, reqouti, ackouti, led_baf: std_logic;
signal led_obt, led_alex			: std_logic_vector(2 downto 0);
-- Hot Pixel
signal aer_hotpixels 					: std_logic_vector(16 downto 0);
signal req_hotpixels, ack_hotpixels	: std_logic;
signal led_blinking						: unsigned(23 downto 0);
signal ntrackers, ntrackerscfg		: integer range 0 to 7;
-- OMC signals
signal usOMC_aer	       : unsigned(8 downto 0); -- Signal to gather OMC outputs
signal ack_hotpixels_OMC : std_logic; -- Combination of OMC MotherOMCack_S and HPF acks
signal MotherOMCack_S	 : std_logic; -- Ack back from OMC to Celem then to BAF (= Retina Filter)
signal OMC_aer_bf2ot	    : std_logic_vector(16 downto 0);
signal OMC_req		 		 : std_logic;
signal OMC_ack		 		 : std_logic;
signal OMC_aer    	    : std_logic_vector(16 downto 0);
-- Merger signals
signal OBT_req	    	: std_logic;
signal OBT_ack	    	: std_logic;
signal OMC_OBT_data	: std_logic_vector(16 downto 0);

begin

Bsync: process(clk50, rst_l)
begin
  if(rst_l='0') then
     req1 				<= '1';
	  saer_in_req_l 	<= '1';
	  ack1 				<= '1';
	  saer_out_ack_l 	<= '1';
	  led_blinking 	<=(others => '0');
  elsif clk50'event and clk50='1' then
     req1 				<= aer_in_req_l;
	  saer_in_req_l 	<= req1;
	  ack1 				<= aer_out_ack_l;
	  saer_out_ack_l 	<= ack1;
	  led_blinking 	<= led_blinking + 1;
  end if;
end process;

rst <= not rst_l;

--Used in AERnode board
B_SPI: SPI_SLAVE
port map(
		   CLK 		=> clk50,
           RST 	=> rst,
           NSS 	=> NSS,
           SCLK 	=> SCLK,
           MOSI 	=> MOSI,
           MISO 	=> MISO,
		   WR 		=> spiWR,
		   ADDRESS 	=> spiADDRESS,
		   DATA_OUT => spiDATA);
			  
aer_in_datat 		<= aer_in_data(15 downto 8) & '0' & aer_in_data(7 downto 0); -- Input with USBAERmini2 

B_RetinaFilter: RetinaFilter 
generic map(BASEADDRESS => x"80")
port map(
	 	   aer_in_data 	=> aer_in_datat,
         aer_in_req_l 	=> saer_in_req_l, --reqouti,
         aer_in_ack_l 	=> aer_in_ack_l,  --ackouti,
		   aer_out_data 	=> aer_hotpixels,
         aer_out_req_l 	=> req_hotpixels,
         aer_out_ack_l 	=> ack_hotpixels_OMC,
         rst_l 			=> rst_l,
         clk50 			=> clk50,
		   BGAF_en 			=> BGAFen,
		   WS2CAVIAR_en 	=> WS2CAVIAR_en,
		   DAVIS_en 		=> DAVIS_en,
		   alex 				=> alex,
		   spiWR 			=> spiWR,
		   spiADDRESS 		=> spiADDRESS,
		   spiDATA 			=> spiDATA,
			LED 				=> led_baf);

-- Merge Ack from Hot Pixel Filter and OMC
Celem: process(MotherOMCack_S, ack_hotpixels)
begin
   if(MotherOMCack_S = '1' and ack_hotpixels = '1') then
		ack_hotpixels_OMC <= '1';
	elsif(MotherOMCack_S = '0' and ack_hotpixels = '0') then
	   ack_hotpixels_OMC <= '0';
	end if;
end process;

--------------------------------------------------------------------------------
-- Mother OMC ------------------------------------------------------------------
--------------------------------------------------------------------------------
B_ObjectMotionMotherCell: ObjectMotionMotherCell
port map(
		-- Clock and reset inputs
		Clock_CI                => clk50,
		Reset_RI                => rst,
		-- LHS in communication
		MotherOMCreq_ABI 	      =>	req_hotpixels, 			 -- Share the Req of Hot Pixel Filter
		MotherOMCack_ABO 	      =>	MotherOMCack_S,			 -- Active low
		PDVSdata_ADI				=>	unsigned(aer_hotpixels), -- Share Data with HPF
		-- RHS out communication
		DaughterOMCreq_ABO   	=>	OMC_req, 	-- Active low, going off-board
		NextSMack_ABI 	      	=>	OMC_ack, 	-- Active low, coming from off-board
		OMCfireMotherOMC_DO		=>	usOMC_aer, 	-- Output
		--SPI
		spiWR 						=> spiWR,
		spiADDRESS 					=> spiADDRESS,
		spiDATA 						=> spiDATA
		);

-- Set OMC event out is 0 + y + 0 + x + pol
process (rst, clk50)
begin
if (rst = '1') then
	OMC_aer 	<= (others => '0');
elsif rising_edge(clk50) then
	if    (usOMC_aer(4) = '1') then  -- Center y 64 x 64 = 1000000 1000000 (OMC5) Red
		OMC_aer 	<= "0" & "1000000" & "0" & "1000000" & "0";
	elsif (usOMC_aer(0) = '1') then  -- Bottom Left y 32 x 32 = 0100000 0100000 (OMC1) Green
		OMC_aer 	<= "0" & "0100000" & "0" & "0100000" & "0";
	elsif (usOMC_aer(2) = '1') then  -- Bottom Right y 32 x 96 = 0100000 1100000 (OMC3) Blue
		OMC_aer 	<= "0" & "0100000" & "0" & "1100000" & "0";
	elsif (usOMC_aer(1) = '1') then  -- Top Left y 96 x 32 = 1100000 0100000 (OMC2) Violet
		OMC_aer 	<= "0" & "1100000" & "0" & "0100000" & "0";
	elsif (usOMC_aer(3) = '1') then  -- Top Right y 96 x 96 = 1100000 1100000 (OMC4) Light Blue
		OMC_aer 	<= "0" & "1100000" & "0" & "1100000" & "0";
	elsif (usOMC_aer(6) = '1') then  -- Center Left y 64 x 32 = 1000000 0100000 (OMC7)
		OMC_aer 	<= "0" & "1000000" & "0" & "0100000" & "0";
	elsif (usOMC_aer(5) = '1') then  -- Bottom Center y 32 x 64 = 0100000 1000000 (OMC6)
		OMC_aer 	<= "0" & "0100000" & "0" & "1000000" & "0";
	elsif (usOMC_aer(8) = '1') then  -- Center Right y 64 x 96 = 1000000 1100000 (OMC9)
		OMC_aer 	<= "0" & "1000000" & "0" & "1100000" & "0";
	elsif (usOMC_aer(7) = '1') then  -- Top Center y 96 x 64 = 1100000 1000000 (OMC8)
		OMC_aer 	<= "0" & "1100000" & "0" & "1000000" & "0";
	else 
		OMC_aer <= (others =>'0');
	end if;
end if;
end process;

-- Shift by 1 the y address of the Hot Pixel Filter if it happens to be on the OMCs centers (inside the Hot Pixel filer!)
	OMC_aer_bf2ot <= aer_bf2ot;
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 

--------------------------------------------------------------------------------
-- Arbiter Merger for OMC and OBT ----------------------------------------------
--------------------------------------------------------------------------------
Merger: arb4_1  
port map( 
		 clk 		=> clk50,
		 reset	=> rst,
		 AERin1	=> OMC_aer,
		 reqIN1	=> OMC_req,
		 ackIN1	=> OMC_ack,
		 AERin2	=> aer_out_datat,
		 reqIN2	=> OBT_req,
		 ackIN2	=> OBT_ack,
		 AERin3	=> (others => '0'),
		 reqIN3	=> '1', 
		 ackIN3	=> open,
		 AERin4	=> (others => '0'),
		 reqIN4	=> '1',
		 ackIN4	=> open,
		 AERout	=> OMC_OBT_data,
		 reqOUT	=> aer_out_req_l,
		 ackOUT	=>	saer_out_ack_l
		);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

B_HotPixelsFilter: HotPixelsFilter 
generic map(BASEADDRESS => x"C0")
port map(
	 	   aer_in_data 		=> aer_hotpixels,
         aer_in_req_l 		=> req_hotpixels,
         aer_in_ack_l 		=> ack_hotpixels,
		   aer_out_data 		=> aer_bf2ot,
         aer_out_req_l 		=> req_bf2ot,
         aer_out_ack_l 		=> ack_bf2ot,
         rst_l 				=> rst_l,
         clk50 				=> clk50,
		   alex 					=> led_alex,
		   spiWR 				=> spiWR,
		   spiADDRESS 			=> spiADDRESS,
		   spiDATA 				=> spiDATA);

-- Final signals
aer_bf2ot_i 	<= OMC_aer_bf2ot; 
aer_out_datat 	<= aer_bf2ot_i when(tOT_active="0000") else taer_out_datat(16 downto 0); --x"80" & 

process(rst,clk50)
begin
  if (rst='1') then
    OBT_req <='1';
  elsif (Rising_edge(clk50)) then
    if (tOT_active="0000") then OBT_req <= req_bf2ot;
	 else OBT_req <= taer_out_req_l;
	 end if; 	-- OBT_req		 	<= req_bf2ot when(tOT_active="0000") else taer_out_req_l;
  end if;
end process;

ack_bf2ot 		<= OBT_ack when(tOT_active="0000") else tack_bf2ot; --saer_out_ack_l

B_ObjectTracker: ObjectTracker
generic map(BASEADDRESS => x"00")
port map(
		   aer_in_data 		=> aer_bf2ot_i,
           aer_in_req_l 	=> req_bf2ot,
           aer_in_ack_l 	=> tack_bf2ot,
		   aer_out_data 		=> taer_out_datat,
           aer_out_req_l 	=> taer_out_req_l,
           aer_out_ack_l 	=> OBT_ack,
           rst_l 				=> rst_l,
           clk50 				=> clk50,
		   OT_active 			=> tOT_active,
			CFG_en 				=> tCFG_en,
		   spiWR 				=> spiWR,
		   spiADDRESS 			=> spiADDRESS,
		   spiDATA 				=> spiDATA,
		   LED 					=> led_obt);
	
aer_out_data 	<= x"00" & "00" & OMC_OBT_data(15 downto 9) & OMC_OBT_data(7 downto 0) ;--aer_out_datat; ?????
BGAF_en 			<= BGAFen;
OT_active 		<= tOT_active;

Bntracker	: process(tOT_active)
variable ntk: integer;
begin
  ntk :=0;
  for i in 0 to 3 loop
    if tOT_active(i)='1' then
	   ntk := ntk +1;
	 end if;
  end loop;
  ntrackers <= ntk;
end process;

Bntrackercfg	: process(tCFG_en)
variable ncfg	: integer;
begin
  ncfg :=0;
  for i in 0 to 3 loop
    if tCFG_en(i)='1' then
	   ncfg := ncfg +1;
	 end if;
  end loop;
  ntrackerscfg <= ncfg;
end process;

LED(0) <= led_blinking(23) when(ntrackers=1) else led_blinking(22) when(ntrackers=2) else led_blinking(21) when(ntrackers=3) else led_blinking(20) when(ntrackers=4) else '0';
LED(2) <= led_alex(1); -- active if HotPixels is learning.
LED(1) <= led_blinking(23) when(ntrackerscfg=1) else led_blinking(22) when(ntrackerscfg=2) else led_blinking(21) when(ntrackerscfg=3) else led_blinking(20) when(ntrackerscfg=4) else '0';

spi_wr 		<= spiWR;
spi_address <= spiADDRESS;
spi_data 	<= spiDATA(7 downto 2) & dDATA & dclk_pulse;

end Behavioral;
