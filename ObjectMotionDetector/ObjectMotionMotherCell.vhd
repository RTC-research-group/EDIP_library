--------------------------------------------------------------------------------
-- Company: INI
-- Engineer: Diederik Paul Moeys
--
-- Create Date:    28.08.2014
-- Design Name:    
-- Module Name:    ObjectMotionMotherCell
-- Project Name:   VISUALISE
-- Target Device:  Latticed LFE3-17EA-7ftn256i
-- Tool versions:  Diamond x64 3.0.0.97x
-- Description:	 Ensemble of 9 OMC
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries -------------------------------------------------------------------
-------------------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ObjectMotionCellConfigRecords.all;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Entity Declaration ----------------------------------------------------------
--------------------------------------------------------------------------------
entity ObjectMotionMotherCell is
	port (
		-- Clock and reset inputs
		Clock_CI						:  in	 std_logic;
		Reset_RI						:  in	 std_logic;
		-- LHS in communication
		MotherOMCreq_ABI 	      :	in	 std_logic; -- Active low
		MotherOMCack_ABO 	      :	out std_logic; -- Active low
		PDVSdata_ADI				: 	in	 unsigned(16 downto 0); -- Data in size
		-- RHS out communication
		DaughterOMCreq_ABO   	:	out std_logic; -- Active low
		NextSMack_ABI 	      	:	in  std_logic; -- Active low
		OMCfireMotherOMC_DO		: 	out unsigned(8 downto 0);
		-- SPI
		spiWR							: 	in  std_logic;
		spiADDRESS					:	in  std_logic_vector(7 downto 0);
		spiDATA						: 	in  std_logic_vector(7 downto 0)
		);
end ObjectMotionMotherCell;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------  

--------------------------------------------------------------------------------
-- Architecture Declaration ----------------------------------------------------
--------------------------------------------------------------------------------
architecture Behavioural of ObjectMotionMotherCell is
	-- States
   type tst is (Idle, ReadAndUpdate, Request, InhibitionCalculate, 
					 InhibitionNormalise, CheckIfDone, WaitReqIn, Decay);
	-- Current state and Next state
	signal State_DP, State_DN	: tst; 

	-- Signals
	signal 	OVFack_SO				: std_logic; -- Acknowledge of overflow
	signal	CounterOVF_S			: std_logic; -- Counter overflow for decay
	
	-- Signals of OMCs
	signal	MotherOMCreq1_S		: std_logic;
	signal	DaughterOMCack1_S		: std_logic;
	signal	DaughterOMCreq1_S    : std_logic;
	signal	OMCfireOMC1_S			: std_logic;

	signal	MotherOMCreq2_S		: std_logic;
	signal	DaughterOMCack2_S		: std_logic;
	signal	DaughterOMCreq2_S    : std_logic;
	signal	OMCfireOMC2_S			: std_logic;
	
	signal	MotherOMCreq3_S		: std_logic;
	signal	DaughterOMCack3_S		: std_logic;
	signal	DaughterOMCreq3_S    : std_logic;
	signal	OMCfireOMC3_S			: std_logic;
	
	signal	MotherOMCreq4_S		: std_logic;
	signal	DaughterOMCack4_S		: std_logic;
	signal	DaughterOMCreq4_S    : std_logic;
	signal	OMCfireOMC4_S			: std_logic;

	signal	MotherOMCreq5_S		: std_logic;
	signal	DaughterOMCack5_S		: std_logic;
	signal	DaughterOMCreq5_S    : std_logic;
	signal	OMCfireOMC5_S			: std_logic;
	
	signal	MotherOMCreq6_S		: std_logic;
	signal	DaughterOMCack6_S		: std_logic;
	signal	DaughterOMCreq6_S    : std_logic;
	signal	OMCfireOMC6_S			: std_logic;
	
	signal	MotherOMCreq7_S		: std_logic;
	signal	DaughterOMCack7_S		: std_logic;
	signal	DaughterOMCreq7_S    : std_logic;
	signal	OMCfireOMC7_S			: std_logic;
	
	signal	MotherOMCreq8_S		: std_logic;
	signal	DaughterOMCack8_S		: std_logic;
	signal	DaughterOMCreq8_S    : std_logic;
	signal	OMCfireOMC8_S			: std_logic;
	
	signal	MotherOMCreq9_S		: std_logic;
	signal	DaughterOMCack9_S		: std_logic;
	signal	DaughterOMCreq9_S    : std_logic;
	signal	OMCfireOMC9_S			: std_logic;
	
	-- Parameters
	signal 	Threshold_S				:	unsigned(31 downto 0); -- Threshold Parameter
	signal 	DecayTime_S				: 	unsigned(31 downto 0); -- Decay time constant
	signal   TauNDecay_S				:	unsigned(31 downto 0); -- TauN
	signal 	ExcitationStrength_S	:	unsigned(7 downto 0);  -- Set Excitation Strength
	signal	Saturation_S			:	unsigned(7 downto 0);  -- Set Subunit Saturation
	signal 	InhibitionStrength_S	:	unsigned(7 downto 0);  -- Set Inhibition Strength
	
	-- Create array of registers
	signal	arrayOfSubunitsSum		: 	receptiveFieldMotherOMC;
	signal	arrayOfSubunitsNonLinear: 	receptiveFieldMotherOMC;
	signal	arrayOfSubunitsOMC1		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC2		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC3		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC4		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC5		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC6		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC7		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC8		: 	receptiveFieldDaughterOMC;
	signal	arrayOfSubunitsOMC9		: 	receptiveFieldDaughterOMC;
	signal	Inhibition_S				:  unsigned(24 downto 0);
	signal   tmpInhibition_S			:  unsigned(24 downto 0);
	
	-- Debug
	signal   debugStateMother_DBG    :  unsigned(7 downto 0);
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
		Enable_SI    		=> '1', 				-- Always enable
		DataLimit_DI 		=> DecayTime_S, 	-- Set the counter's limit (set the decay time)
		Overflow_SO  		=> CounterOVF_S, 	-- Get the counter's overflow
		Data_DO      		=> open); 			-- Leave unconnected			
--------------------------------------------------------------------------------
	-- OMC1
	OMC1: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset	
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq1_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack1_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq1_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC1_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC1,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC2
	OMC2: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq2_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack2_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq2_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC2_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC2,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC3
	OMC3: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq3_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack3_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq3_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC3_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC3,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC4	
	OMC4: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq4_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack4_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq4_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=> OMCfireOMC4_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC4,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC5
	OMC5: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq5_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack5_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq5_S, -- Active low
		NextSMack_ABI 	      => NextSMack_ABI,      -- Active low
		OMCfire_DO				=> OMCfireOMC5_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC5,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC6
	OMC6: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset	
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq6_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack6_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq6_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC6_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC6,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC7
	OMC7: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset	
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq7_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack7_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq7_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC7_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC7,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC8
	OMC8: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset	
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq8_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack8_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq8_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC8_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC8,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
	-- OMC9
	OMC9: entity work.ObjectMotionCell
	port map(
		-- Clock and reset inputs
		Clock_CI     			=> Clock_CI, -- Share the same clock
		Reset_RI     			=> Reset_RI, -- Share the same asynchronous reset	
		-- LHS in communication
		MotherOMCreq_ABI 	   =>	MotherOMCreq9_S, 	 -- Active low
		DaughterOMCack_ABO 	=>	DaughterOMCack9_S, -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   =>	DaughterOMCreq9_S, -- Active low
		NextSMack_ABI 	      =>	NextSMack_ABI,      -- Active low
		OMCfire_DO				=>	OMCfireOMC9_S,
		-- Receptive Field
		ReceptiveField_ADI 	=> arrayOfSubunitsOMC9,
		Inhibition_SI			=> Inhibition_S,
		ExcitationStrength_SI=> ExcitationStrength_S,
		-- Receive Parameters
		Threshold_SI			=> Threshold_S, -- Threshold Parameter
		TauNDecay_SI			=> TauNDecay_S --TauN
		);
--------------------------------------------------------------------------------
Sequential : process (Clock_CI, Reset_RI) -- Sequential Process
variable TemporalVariable1 : unsigned(24 downto 0);
begin
	-- External reset	
	if (Reset_RI = '1') then
		-- LHS in communication
		MotherOMCack_ABO 	      <= '1'; -- Don't acknowledge previous state-machine
		-- RHS out communication
		DaughterOMCreq_ABO      <= '1'; -- Don't request to next SM
		OMCfireMotherOMC_DO  	<= (others => '0'); -- Don't fire
		
		OVFack_SO 					<= '0'; -- Don't give counter acknowledge
		State_DP 					<= Idle;
	
		-- Don't request to daughters
		MotherOMCreq1_S 	<= '1';
		MotherOMCreq2_S 	<= '1';
		MotherOMCreq3_S 	<= '1';
		MotherOMCreq4_S 	<= '1';
		MotherOMCreq5_S 	<= '1';
		MotherOMCreq6_S 	<= '1';
		MotherOMCreq7_S 	<= '1';
		MotherOMCreq8_S 	<= '1';
		MotherOMCreq9_S 	<= '1';
	
		-- Reset values before SPIConfig assignment
		Threshold_S  				<= "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "1000" & "0000"; 
		DecayTime_S  				<= "0000" & "0000" & "0000" & "0001" & "1000" & "0110" & "1010" & "0000";
		TauNDecay_S             <= "0000" & "0000" & "0000" & "0001" & "1000" & "0110" & "1010" & "0000";
		ExcitationStrength_S		<= "0000" & "0001";
		Saturation_S				<= "0000" & "0001";
		InhibitionStrength_S		<= "0000" & "0001";
		
		-- Debug
		debugStateMother_DBG 	<= (others => '0');
		
		-- Reset Receptive Fields
		for i in 0 to 1 loop
      	for j in 0 to 1 loop
        		arrayOfSubunitsOMC1(i,j) <= (others => '0');
        		arrayOfSubunitsOMC2(i,j) <= (others => '0');
        		arrayOfSubunitsOMC3(i,j) <= (others => '0');
        		arrayOfSubunitsOMC4(i,j) <= (others => '0');
        		arrayOfSubunitsOMC5(i,j) <= (others => '0');
        		arrayOfSubunitsOMC6(i,j) <= (others => '0');
        		arrayOfSubunitsOMC7(i,j) <= (others => '0');
        		arrayOfSubunitsOMC8(i,j) <= (others => '0');
        		arrayOfSubunitsOMC9(i,j) <= (others => '0');
      	end loop; -- j
    	end loop; -- i
	
		-- Reset all subunits to 1
		for i in 0 to 7 loop
      	for j in 0 to 7 loop
        		arrayOfSubunitsSum(i,j) <= (others => '0');
        		arrayOfSubunitsNonLinear(i,j) <= (others => '0');
      	end loop; -- j
    	end loop; -- i
		
---------------------------------------------------------------------------------
	-- At every clock cycle
	elsif (Rising_edge(Clock_CI)) then
		-- Assign next state to current state
		State_DP <= State_DN;
		
		-- Store SPIConfig
		if spiwr='1' then  
			case SPIADDRESS is
				when x"F0" 	=> Threshold_S(7 downto 0)   				<= unsigned(spiDATA); 
				when x"F1" 	=> Threshold_S(15 downto 8)  				<= unsigned(spiDATA); 
				when x"F2" 	=> Threshold_S(23 downto 16) 				<= unsigned(spiDATA);
				when x"F3" 	=> Threshold_S(31 downto 24) 				<= unsigned(spiDATA);
				when x"F4" 	=> DecayTime_S(7 downto 0)   				<= unsigned(spiDATA); 
				when x"F5" 	=> DecayTime_S(15 downto 8) 				<= unsigned(spiDATA); 
				when x"F6" 	=> DecayTime_S(23 downto 16) 				<= unsigned(spiDATA); 
				when x"F7" 	=> DecayTime_S(31 downto 24) 				<= unsigned(spiDATA); 
				when x"F8" 	=> ExcitationStrength_S(7 downto 0)  	<= unsigned(spiDATA);
				when x"F9"	=> Saturation_S(7 downto 0)				<= unsigned(spiDATA);
				when x"FA"	=> InhibitionStrength_S(7 downto 0)  	<= unsigned(spiDATA);
				when x"FB" 	=> TauNDecay_S(7 downto 0)   				<= unsigned(spiDATA); 
				when x"FC" 	=> TauNDecay_S(15 downto 8) 				<= unsigned(spiDATA); 
				when x"FD" 	=> TauNDecay_S(23 downto 16) 				<= unsigned(spiDATA); 
				when x"FE" 	=> TauNDecay_S(31 downto 24) 				<= unsigned(spiDATA); 
				when others => null;
			 end case;
			end if;

		-- Set Receptive Fields
		for i in 0 to 1 loop
      	for j in 0 to 1 loop
        		arrayOfSubunitsOMC1(i,j) <= arrayOfSubunitsNonLinear(i+1,j+1);
        		arrayOfSubunitsOMC2(i,j) <= arrayOfSubunitsNonLinear(i+5,j+1);
        		arrayOfSubunitsOMC3(i,j) <= arrayOfSubunitsNonLinear(i+1,j+5);
        		arrayOfSubunitsOMC4(i,j) <= arrayOfSubunitsNonLinear(i+5,j+5);
        		arrayOfSubunitsOMC5(i,j) <= arrayOfSubunitsNonLinear(i+3,j+3);
				arrayOfSubunitsOMC6(i,j) <= arrayOfSubunitsNonLinear(i+1,j+3);
				arrayOfSubunitsOMC7(i,j) <= arrayOfSubunitsNonLinear(i+3,j+1);
				arrayOfSubunitsOMC8(i,j) <= arrayOfSubunitsNonLinear(i+5,j+3);
				arrayOfSubunitsOMC9(i,j) <= arrayOfSubunitsNonLinear(i+3,j+5);
      	end loop; -- j
    	end loop; -- i
		
		-- RHS out communication (if any are zero then req to next SM)
		DaughterOMCreq_ABO <= (DaughterOMCreq1_S and DaughterOMCreq2_S and DaughterOMCreq3_S 
								 and DaughterOMCreq4_S and DaughterOMCreq5_S and DaughterOMCreq6_S 
								 and DaughterOMCreq7_S and DaughterOMCreq8_S and DaughterOMCreq9_S);
		
		case State_DP is

			when Idle =>
				-- Don't request to daughters
				MotherOMCreq1_S 	<= '1';
				MotherOMCreq2_S 	<= '1';
				MotherOMCreq3_S 	<= '1';
				MotherOMCreq4_S 	<= '1';
				MotherOMCreq5_S 	<= '1';
				MotherOMCreq6_S 	<= '1';
				MotherOMCreq7_S 	<= '1';
				MotherOMCreq8_S 	<= '1';
				MotherOMCreq9_S 	<= '1';
				
				MotherOMCack_ABO <='1';
				
				OVFack_SO  		<= '0'; -- Remove counter acknowledge
				--Debug
				debugStateMother_DBG <= (0 => '1', others => '0');
				
			when ReadAndUpdate =>
				if ((arrayOfSubunitsSum(to_integer(PDVSdata_ADI(15 downto 13)),to_integer(PDVSdata_ADI(7 downto 5)))(14 downto 0) & '0') >=  Saturation_S) then
					arrayOfSubunitsNonLinear(to_integer(PDVSdata_ADI(15 downto 13)),to_integer(PDVSdata_ADI(7 downto 5))) <= Saturation_S;
				else
					arrayOfSubunitsSum(to_integer(PDVSdata_ADI(15 downto 13)),to_integer(PDVSdata_ADI(7 downto 5))) 
						<= arrayOfSubunitsSum(to_integer(PDVSdata_ADI(15 downto 13)),to_integer(PDVSdata_ADI(7 downto 5)))(15 downto 0) + 1; -- Sum linearly ---ADDED+10 instead of 1
				end if;
				--Debug
				debugStateMother_DBG <= (1 => '1', others => '0');
				
			when Request =>
				-- Calculate non-linearity
				arrayOfSubunitsNonLinear(to_integer(PDVSdata_ADI(15 downto 13)),to_integer(PDVSdata_ADI(7 downto 5))) 
					<= arrayOfSubunitsSum(to_integer(PDVSdata_ADI(15 downto 13)),to_integer(PDVSdata_ADI(7 downto 5)))(14 downto 0) & '0'; -- Multiply by 2
				-- OMC1 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 2) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 2) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 1) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 1)) then
					MotherOMCreq1_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC2 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 6) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 2) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 5) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 1)) then
					MotherOMCreq2_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC3 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 2) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 6) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 1) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 5)) then
					MotherOMCreq3_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC4 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 6) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 6) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 5) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 5)) then
					MotherOMCreq4_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC5 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 4) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 4) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 3) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 3)) then
					MotherOMCreq5_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC6 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 2) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 4) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 1) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 3)) then
					MotherOMCreq6_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC7 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 4) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 2) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 3) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 1)) then
					MotherOMCreq7_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC8 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 6) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 4) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 5) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 3)) then
					MotherOMCreq8_S <= '0'; --MotherOMCreq_ABI;
				end if;
				-- OMC9 req
				if		((to_integer(PDVSdata_ADI(15 downto 13)) <= 4) and (to_integer(PDVSdata_ADI(7 downto 5)) <= 6) 
					and (to_integer(PDVSdata_ADI(15 downto 13)) >= 3) and (to_integer(PDVSdata_ADI(7 downto 5)) >= 5)) then
					MotherOMCreq9_S <= '0'; --MotherOMCreq_ABI;
				end if;
				--Debug
				debugStateMother_DBG <= (2 => '1', others => '0');
				
			when InhibitionCalculate =>
				TemporalVariable1 := (others => '0');
				for i in 0 to 7 loop
					for j in 0 to 7 loop
							-- Find the total Inhibition
							TemporalVariable1 := TemporalVariable1 + ("000000000" & arrayOfSubunitsNonLinear(i,j));
					end loop; -- j
				end loop; -- i
				tmpInhibition_S <= TemporalVariable1;
				--Debug
				debugStateMother_DBG <= (3 => '1', others => '0');

			when InhibitionNormalise =>
				if (InhibitionStrength_S = "0000" & "0000") then
					-- Kill excitation
					Inhibition_S <=  (others => '0');
				elsif (InhibitionStrength_S = "0000" & "0001") then
					-- Divide by 64 to normalise and multiply by 1 (Right shift by 6 bits)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("0000000000000" & tmpInhibition_S(24 downto 13));
				elsif (InhibitionStrength_S = "0000" & "0010") then
					-- Divide by 64 to normalise and multiply by 2 (Right shift by 5 bits)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("000000000000" & tmpInhibition_S(24 downto 12));
				elsif (InhibitionStrength_S = "0000" & "0100") then
					-- Divide by 64 to normalise and multiply by 4 (Right shift by 4 bits)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("00000000000" & tmpInhibition_S(24 downto 11));
				elsif (InhibitionStrength_S = "0000" & "1000") then
					-- Divide by 64 to normalise and multiply by 8 (Right shift by 3 bits)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("0000000000" & tmpInhibition_S(24 downto 10));
				elsif (InhibitionStrength_S = "0001" & "0000") then
					-- Divide by 64 to normalise and multiply by 16 (Right shift by 2 bits)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("000000000" & tmpInhibition_S(24 downto 9));
				elsif (InhibitionStrength_S = "0010" & "0000") then
					-- Divide by 64 to normalise and multiply by 32 (Right shift by 1 bit)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("00000000" & tmpInhibition_S(24 downto 8));
				elsif (InhibitionStrength_S = "0100" & "0000") then
					-- Divide by 64 to normalise and multiply by 64 (shift by 0 bit)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("0000000" & tmpInhibition_S(24 downto 7));
				elsif (InhibitionStrength_S = "1000" & "0000") then
					-- Divide by 64 to normalise and multiply by 128 (Left shift by 1 bit)
					Inhibition_S <= ("000000" & tmpInhibition_S(24 downto 6)) + ("000000" & tmpInhibition_S(24 downto 6));
				end if;
				--Debug
				debugStateMother_DBG <= (4 => '1', others => '0');				

			when CheckIfDone =>
				-- If any ack back then send the result
				if ((DaughterOMCack1_S and DaughterOMCack2_S and DaughterOMCack3_S 
				 and DaughterOMCack4_S and DaughterOMCack5_S and DaughterOMCack6_S 
				 and DaughterOMCack7_S and DaughterOMCack8_S and DaughterOMCack9_S) = '0') then
					OMCFireMotherOMC_DO <= (0 => OMCfireOMC1_S, 1 => OMCfireOMC2_S, 2 => OMCfireOMC3_S, 
													3 => OMCfireOMC4_S, 4 => OMCfireOMC5_S, 5 => OMCfireOMC6_S, 
													6 => OMCfireOMC7_S, 7 => OMCfireOMC8_S, 8 => OMCfireOMC9_S);
				end if;
				--Debug
				debugStateMother_DBG <= (5 => '1', others => '0');

			when WaitReqIn => 
				MotherOMCack_ABO <='0';
				-- Don't request to daughters
				MotherOMCreq1_S 	<= '1';
				MotherOMCreq2_S 	<= '1';
				MotherOMCreq3_S 	<= '1';
				MotherOMCreq4_S 	<= '1';
				MotherOMCreq5_S 	<= '1';
				MotherOMCreq6_S 	<= '1';
				MotherOMCreq7_S 	<= '1';
				MotherOMCreq8_S 	<= '1';
				MotherOMCreq9_S 	<= '1';
				--Debug
				debugStateMother_DBG <= (6 => '1', others => '0');
				
			when Decay =>
				for i in 0 to 7 loop
					for j in 0 to 7 loop
						if (arrayOfSubunitsSum(i,j) = "0000" & "0000" & "0000" & "0000") then -- Already at minimum possible
							null;
						else
							arrayOfSubunitsSum(i,j) <= '0' & arrayOfSubunitsSum(i,j)(15 downto 1); -- Decay by dividing by 2
						end if;
					end loop; -- j
				end loop; -- i
				OVFack_SO  <= '1'; -- Give counter acknowledge					
				--Debug
				debugStateMother_DBG <= (7 => '1', others => '0');
				
			when others => null;

		end case;
	end if;
end process Sequential;
--------------------------------------------------------------------------------
Combinational : process (State_DP, MotherOMCreq_ABI, CounterOVF_S, PDVSdata_ADI,
								 DaughterOMCack1_S, DaughterOMCack2_S, DaughterOMCack3_S, 
								 DaughterOMCack4_S, DaughterOMCack5_S, DaughterOMCack6_S, 
								 DaughterOMCack7_S, DaughterOMCack8_S, DaughterOMCack9_S,
								 MotherOMCreq1_S, MotherOMCreq2_S, MotherOMCreq3_S,
								 MotherOMCreq4_S, MotherOMCreq5_S, MotherOMCreq6_S,
								 MotherOMCreq7_S, MotherOMCreq8_S, MotherOMCreq9_S) -- Combinational Process
begin
	-- Default
	State_DN <= State_DP; -- Keep the same state

	case State_DP is

		when Idle =>
			if ((MotherOMCreq_ABI = '0') and (CounterOVF_S = '0')) then
				State_DN <= ReadAndUpdate;
			elsif (CounterOVF_S = '1') then
				State_DN <= Decay;
			end if;

		when ReadAndUpdate =>	
			State_DN <= Request;
				
		when Request =>
			State_DN <= InhibitionCalculate;		
				
		when InhibitionCalculate =>	
				State_DN <= InhibitionNormalise;
		
		when InhibitionNormalise =>	
			State_DN <= CheckIfDone;

		when CheckIfDone =>
			if ((((DaughterOMCack1_S and DaughterOMCack2_S and DaughterOMCack3_S 
				and DaughterOMCack4_S and DaughterOMCack5_S and DaughterOMCack6_S 
				and DaughterOMCack7_S and DaughterOMCack8_S and DaughterOMCack9_S) = '0') and
				  ((MotherOMCreq1_S and MotherOMCreq2_S and MotherOMCreq3_S
				and MotherOMCreq4_S and MotherOMCreq5_S and MotherOMCreq6_S
				and MotherOMCreq7_S and MotherOMCreq8_S and MotherOMCreq9_S) = '0')) or 
			     ((MotherOMCreq1_S and MotherOMCreq2_S and MotherOMCreq3_S
				and MotherOMCreq4_S and MotherOMCreq5_S and MotherOMCreq6_S
				and MotherOMCreq7_S and MotherOMCreq8_S and MotherOMCreq9_S) = '1')) then
				State_DN <= WaitReqIn;
			else
				null;
			end if;
		
		when WaitReqIn =>
		   if (MotherOMCreq_ABI = '1') then
			   State_DN <= Idle;
			end if;
			
		when Decay =>	 
			if (CounterOVF_S = '0') then
				State_DN <= Idle;		
			end if;
			
		when others => 
			State_DN <= Idle;

	end case;
end process Combinational;
--------------------------------------------------------------------------------
end Behavioural;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------