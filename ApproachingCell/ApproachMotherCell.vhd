--------------------------------------------------------------------------------
-- Company: INI
-- Engineer: Hongjie Liu
--
-- Create Date:    16.03.2017
-- Design Name:    
-- Module Name:    ApproachMotherCell
-- Project Name:   VISUALISE
-- Target Device:  Latticed LFE3-17EA-7ftn256i  // Spartan 6 - 1500 AER-Node
-- Tool versions:  Diamond x64 3.0.0.97x
-- Description:	 Ensemble of 5 AC
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries -------------------------------------------------------------------
-------------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_MISC.ALL;
--use work.ACConfigRecords.all;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Entity Declaration ----------------------------------------------------------
--------------------------------------------------------------------------------
entity ApproachMotherCell is
	port (
		-- Clock and reset inputs
		Clock_CI						:  in	 std_logic;
		Reset_RI						:  in	 std_logic;
		-- LHS in communication
		MotherACreq_ABI 	      :	in	 std_logic; -- Active low
		MotherACack_ABO 	      :	out std_logic; -- Active low
		PDVSdata_ADI				: 	in	 std_logic_vector(16 downto 0); -- Data in size
		-- RHS out communication
--		DaughterACreq_ABO   	:	out std_logic; -- Active low
		NextSMack_ABI 	      	:	in  std_logic; -- Active low
		ACfireMotherAC_DO		: 	out std_logic;
		-- SPI
		spiWR							: 	in  std_logic;
		spiADDRESS					:	in  std_logic_vector(7 downto 0);
		spiDATA						: 	in  std_logic_vector(7 downto 0)
		);
end ApproachMotherCell;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------  

--------------------------------------------------------------------------------
-- Architecture Declaration ----------------------------------------------------
--------------------------------------------------------------------------------
architecture Behavioural of ApproachMotherCell is
	-- States

	-- Signals
	signal 	OVFack_SO				: std_logic; -- Acknowledge of overflow active high
	signal	CounterOVF_S, enable_continous_counter			: std_logic; -- Counter overflow for decay
	
	-- Parameters
	signal 	IFThreshold_S				:	signed(47 downto 0); -- Threshold Parameter
	signal 	DecayTime_S				   : 	unsigned(31 downto 0); -- Decay time constant
	signal	UpdateUnit_S			   :	signed(2 downto 0);  -- update unit for each coming event
	signal   surroundSuppressionEnabled_S   :  std_logic;---------------wheter or not enable surround suppresion for each subunit
	signal   EventXAddr_S, EventYAddr_S: std_logic_vector(4 downto 0);
	signal   EventPolarity_S: std_logic;

 
begin
--------------------------------------------------------------------------------
	-- Instantiate DecayCounter
	DecayCounter: entity work.ContinuousCounter
	generic map(
		SIZE              => 32, 	 -- Maximum possible size
		RESET_ON_OVERFLOW => false, -- Reset only when OVFack_SO is '1' 
		GENERATE_OVERFLOW => true,  -- Generate overflow
		SHORT_OVERFLOW    => false, -- Keep the overflow
		OVERFLOW_AT_ZERO  => false) -- Overflow at "111.." not "000.." (Reset)
	port map(
		Clock_CI     		=> Clock_CI, 		-- Share the same clock
		Reset_RI     		=> Reset_RI, 		-- Share the same asynchronous reset
		Clear_SI     		=> OVFack_SO, 		-- Clear with acknowledge of overflow
		Enable_SI    		=> enable_continous_counter, 				-- Always enable
		DataLimit_DI 		=> DecayTime_S, 	-- Set the counter's limit (set the decay time)
		Overflow_SO  		=> CounterOVF_S, 	-- Get the counter's overflow
		Data_DO      		=> open); 			-- Leave unconnected			
--------------------------------------------------------------------------------
	-- AC1
	AC1: entity work.ApproachCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset	
		-- LHS in communication
		Req_I 	   =>	MotherACreq_ABI, 	 -- Active low
		Ack_O 	=>	MotherACack_ABO, -- Active low
		-- RHS out communication
		NextBlock_Ack_I 	      =>	NextSMack_ABI,      -- Active low
		AC_Fire_O				=>	ACfireMotherAC_DO,
		OVFack_O=>OVFack_SO,
--------------------------------------------------------
		DecayEnable_I	=> CounterOVF_S,
----------------------------------------------------------
--------parameters
		surroundSuppressionEnabled_I => surroundSuppressionEnabled_S,---active high
		IFThreshold_I  => IFThreshold_S,
		UpdateUnit_I =>  UpdateUnit_S,
----------------------------------------------------------------
      EventXAddr_I  => EventXAddr_S,
		EventYAddr_I	=> EventYAddr_S,
		EventPolarity_I => EventPolarity_S					 
		);

--------------------------------------------------------------------------------
SPIassignment: process (Reset_RI, Clock_CI)
begin
	-- External reset	
	if (Reset_RI = '1') then
		-- Reset values before SPIConfig assignment
		IFThreshold_S  				<= "0000" & "0000" & "0000" & "0000" &"0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "1000" & "0000"; 
		DecayTime_S  				<= "0000" & "0000" & "0000" & "0001" & "1000" & "0110" & "1010" & "0000";
	   UpdateUnit_S	   <=   "010";
		surroundSuppressionEnabled_S  <= '1';
		enable_continous_counter <='0';
---------------------------------------------------------------------------------
	-- At every clock cycle
	elsif (Rising_edge(Clock_CI)) then
		-- Assign next state to current state
		EventXAddr_S<=PDVSdata_ADI(14 downto 10);
		EventYAddr_S<=PDVSdata_ADI(7 downto 3);
		EventPolarity_S<=PDVSdata_ADI(0);
      enable_continous_counter <= '1';
		-- Store SPIConfig
		if spiWR='1' then  
			case SPIADDRESS is
				when x"F0" 	=> IFThreshold_S(7 downto 0)   				<= signed(spiDATA); 
				when x"F1" 	=> IFThreshold_S(15 downto 8)  				<= signed(spiDATA); 
				when x"F2" 	=> IFThreshold_S(23 downto 16) 				<= signed(spiDATA);
				when x"F3" 	=> IFThreshold_S(31 downto 24) 				<= signed(spiDATA);
				when x"F4" 	=> IFThreshold_S(39 downto 32) 				<= signed(spiDATA);
				when x"F5" 	=> IFThreshold_S(47 downto 40) 				<= signed(spiDATA);
				when x"F6" 	=> DecayTime_S(7 downto 0)   				<= unsigned(spiDATA); 
				when x"F7" 	=> DecayTime_S(15 downto 8) 				<= unsigned(spiDATA); 
				when x"F8" 	=> DecayTime_S(23 downto 16) 				<= unsigned(spiDATA); 
				when x"F9" 	=> DecayTime_S(31 downto 24) 				<= unsigned(spiDATA); 
				when x"FA"	=> UpdateUnit_S (2 downto 0)  			<= signed(spiDATA(2 downto 0));
									surroundSuppressionEnabled_S  			<= std_logic(spiDATA(3));
				when others => null;
			 end case;
		 end if;
	 end if;
end process SPIassignment;
end Behavioural;
----------------------------------------------------------------------------------------------------------