--------------------------------------------------------------------------------
-- Company: INI
-- Engineer: Diederik Paul Moeys
--
-- Create Date:    28.08.2014
-- Design Name:    
-- Module Name:    ObjectMotionCell
-- Project Name:   VISUALISE
-- Target Device:  Latticed LFE3-17EA-7ftn256i
-- Tool versions:  Diamond x64 3.0.0.97x
-- Description:	 Module to mimic the processing of the Object Motion Cell RGC
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
entity ObjectMotionCell is
	port (
		-- Clock and reset inputs
		Clock_CI					:  in  std_logic;
		Reset_RI					:  in  std_logic;
		-- LHS in communication
		MotherOMCreq_ABI 	   :	in	 std_logic;  -- Active low
		DaughterOMCack_ABO 	:	out std_logic;  -- Active low
		-- RHS out communication
		DaughterOMCreq_ABO   :	out std_logic;  -- Active low
		NextSMack_ABI 	      :	in  std_logic;  -- Active low
		OMCfire_DO				: 	out std_logic;
		-- Receptive Field
		ReceptiveField_ADI 	:  in  receptiveFieldDaughterOMC;
		Inhibition_SI			:  in  unsigned(24 downto 0);
		ExcitationStrength_SI:  in  unsigned(7 downto 0);
		-- Receive Parameters
		Threshold_SI			:	in  unsigned(31 downto 0); -- Threshold Parameter
		TauNDecay_SI			:	in  unsigned(31 downto 0) -- TauN Parameter
		);
end ObjectMotionCell;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------  

--------------------------------------------------------------------------------
-- Architecture Declaration ----------------------------------------------------
--------------------------------------------------------------------------------
architecture Behavioural of ObjectMotionCell is
	-- States
   type tst is (Idle, Decay, ExcitationCalculate, ExcitationNormalise, NetSynapticInputCalculate, MultiplyDT, VmembraneCalculate, Checkfire, Fire, Acknowledge);
	-- Current state and Next state
	signal State_DP, State_DN	: tst;

	-- Signals
	signal	Excitation_S					: unsigned (24 downto 0); -- Excitation of center normalised
	signal	tmpExcitation_S				: unsigned (24 downto 0); -- Excitation of center
	signal	Inhibition_S					: unsigned (24 downto 0); -- Inhibition	of periphery normalised
	signal	NetSynapticInput_S			: unsigned (24 downto 0); -- Subtraction of inhibition from excitation
	signal	NetSynapticInputTimesDT_S 	: unsigned (24 downto 0); -- Multiply the DT times the previous subtraction
	signal	MembranePotential_S  		: unsigned (24 downto 0); -- Membrane potential 
	signal	TimeStamp_S						: unsigned (31 downto 0); -- Timer's output used to get timestamp
	signal	CurrentTimeStamp_S			: unsigned (31 downto 0); -- Current event's timestamp
	signal	PreviousTimeStamp_S			: unsigned (31 downto 0); -- Previous event's timestamp
	signal	TimeBetween2Events_S			: unsigned (31 downto 0); -- Delta T
	signal   TimerLimit_S					: unsigned (31 downto 0);
	signal	ReceptiveField_S        	: receptiveFieldDaughterOMC;

	-- Parameters
	signal 	Threshold_S				:	unsigned(31 downto 0); -- Threshold Parameter
	signal   ExcitationStrength_S :  unsigned(7 downto 0);
	signal	TauNDecay_S				:	unsigned(31 downto 0); -- TauN
	
	-- TauN 
	signal 	OVFack_SO				: std_logic; -- Acknowledge of overflow
	signal	CounterOVF_S			: std_logic; -- Counter overflow for decay
	
	-- Debug
	signal	debugStateDaughter_DBG : unsigned(8 downto 0);
begin
--------------------------------------------------------------------------------
	-- Instantiate TimeStampTimer
	TimeStampTimer: entity work.ContinuousCounter
	generic map(
		SIZE              => 32, 				-- Maximum possible size
		RESET_ON_OVERFLOW => true, 			-- Reset when full (independent) 
		GENERATE_OVERFLOW => false, 			-- Don't generate overflow
		SHORT_OVERFLOW    => false, 			-- Keep the overflow
		OVERFLOW_AT_ZERO  => false) 			-- Overflow at "111.." not "000.." (Reset)
	port map(
		Clock_CI     		=> Clock_CI, 		-- Share the same clock
		Reset_RI     		=> Reset_RI, 		-- Share the same asynchronous reset
		Clear_SI     		=> Reset_RI, 		-- Clear with reset as well
		Enable_SI    		=> '1', 			-- Always enable
		DataLimit_DI 		=> TimerLimit_S, 	-- Set the counter's limit (set the maximum counting time)
		Overflow_SO  		=> open, 			-- Get the counter's overflow
		Data_DO      		=> TimeStamp_S); 	-- Leave unconnected
--------------------------------------------------------------------------------
	-- Instantiate TimeStampTimer
	TauNTimer: entity work.ContinuousCounter
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
		DataLimit_DI 		=> TauNDecay_S, 	-- Set the counter's limit (set the decay time)
		Overflow_SO  		=> CounterOVF_S, 	-- Get the counter's overflow
		Data_DO      		=> open); 			-- Leave unconnected			
--------------------------------------------------------------------------------
Sequential : process (Clock_CI, Reset_RI) -- Sequential Process
-- Temporal variables
variable TemporalVariable1 : unsigned(24 downto 0);
variable TemporalVariable2 : unsigned(49 downto 0);

begin
	-- External reset	
	if (Reset_RI = '1') then
		-- LHS in communication
		DaughterOMCack_ABO	<= '1'; -- Don't ack back the retina
		-- RHS out communication
		DaughterOMCreq_ABO	<= '1'; -- Don't req the next SM
		OMCFire_DO 				<= '0'; -- No firing
		OVFack_SO 					<= '0'; -- Don't give counter acknowledge

		State_DP							<= Idle;
		PreviousTimeStamp_S 			<= (others => '0'); 	-- Assign first timestamp
		Excitation_S 					<= (others => '0');
		tmpExcitation_S				<= (others => '0');
		Inhibition_S 					<= (others => '0');
		TimeBetween2Events_S 		<= (others => '0');
		MembranePotential_S 			<= (others => '0');
		NetSynapticInput_S 			<= (others => '0');
		NetSynapticInputTimesDT_S 	<= (others => '0');
		CurrentTimeStamp_S 			<= (others => '0');
		-- Reset Receptive Field
		for i in 0 to 1 loop
      	for j in 0 to 1 loop
				ReceptiveField_S(i,j) <= (others => '0');
      	end loop; -- j
    	end loop; -- i
		
		-- Reset values before SPIConfig assignment
		Threshold_S 			<= "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "1000" & "0000";
	 	TimerLimit_S 			<= (others => '1');
		TauNDecay_S				<= (others => '1');
		ExcitationStrength_S <= "0000" & "0001";
		
		-- Debug
		debugStateDaughter_DBG <= (others => '0');
		
---------------------------------------------------------------------------------
	-- At every clock cycle
	elsif (Rising_edge(Clock_CI)) then
		-- Assign next state to current state
		State_DP <= State_DN;
		
		-- Store SPIConfig
		Threshold_S 			<= Threshold_SI; 
	 	TimerLimit_S 			<= (others => '1');
		TauNDecay_S				<= TauNDecay_SI;
		ExcitationStrength_S <= ExcitationStrength_SI;
		
		-- Update from mother
		Inhibition_S 		<= Inhibition_SI; -- Update inhibition
		for i in 0 to 1 loop
      	for j in 0 to 1 loop
				ReceptiveField_S(i,j) <= ReceptiveField_ADI(i,j); -- Update receptive field
			end loop; -- j
    	end loop; -- i
		
		case State_DP is

			when Idle =>
				-- LHS in communication
				DaughterOMCack_ABO	<= '1'; -- Don't ack back the retina
				-- RHS out communication
				DaughterOMCreq_ABO	<= '1'; -- Don't req the next SM
				OMCFire_DO 				<= '0'; -- No firing
				OVFack_SO  				<= '0'; -- Remove counter acknowledge
				--Debug
				debugStateDaughter_DBG <= (0 => '1', others => '0');

			when ExcitationCalculate =>
				CurrentTimeStamp_S <= TimeStamp_S; -- Assign current timestamp
				TemporalVariable1  := (others => '0'); 
				for i in 0 to 1 loop
					for j in 0 to 1 loop
						-- Find the total Excitation
						TemporalVariable1 := TemporalVariable1 + ("000000000" & ReceptiveField_S(i,j));
					end loop; -- j
				end loop; -- i
				tmpExcitation_S <= TemporalVariable1;
				--Debug
				debugStateDaughter_DBG <= (1 => '1', others => '0');

			when ExcitationNormalise =>
				if (ExcitationStrength_S = "0000" & "0000") then
					-- Kill excitation
					Excitation_S <=  (others => '0');
				elsif (ExcitationStrength_S = "0000" & "0001") then
					-- Divide by 4 to normalise and multiply by 1 (Right shift by 2 bits)
					Excitation_S <=  "00" & tmpExcitation_S(24 downto 2);
				elsif (ExcitationStrength_S = "0000" & "0010") then
					-- Divide by 4 to normalise and multiply by 2 to give more strength (Right shift by 1 bit)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("00000000" & tmpExcitation_S(24 downto 8));
				elsif (ExcitationStrength_S = "0000" & "0100") then
					-- Divide by 4 to normalise and multiply by 4 to give more strength (shift by 0 bit)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("0000000" & tmpExcitation_S(24 downto 7));
				elsif (ExcitationStrength_S = "0000" & "1000") then
					-- Divide by 4 to normalise and multiply by 8 to give more strength (Left shift by 1 bit)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("000000" & tmpExcitation_S(24 downto 6));
				elsif (ExcitationStrength_S = "0001" & "0000") then
					-- Divide by 4 to normalise and multiply by 16 to give more strength (Left shift by 2 bits)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("00000" & tmpExcitation_S(24 downto 5));
				elsif (ExcitationStrength_S = "0010" & "0000") then
					-- Divide by 4 to normalise and multiply by 32 to give more strength (Left shift by 3 bits)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("0000" & tmpExcitation_S(24 downto 4));
				elsif (ExcitationStrength_S = "0100" & "0000") then
					-- Divide by 4 to normalise and multiply by 64 to give more strength (Left shift by 4 bits)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("000" & tmpExcitation_S(24 downto 3));
				elsif (ExcitationStrength_S = "1000" & "0000") then
					-- Divide by 4 to normalise and multiply by 128 to give more strength (Left shift by 5 bits)
					Excitation_S <=  ("00" & tmpExcitation_S(24 downto 2)) +  ("00" & tmpExcitation_S(24 downto 2));
				end if;
				--Debug
				debugStateDaughter_DBG <= (2 => '1', others => '0');

			when NetSynapticInputCalculate =>
				if (Excitation_S >= Inhibition_S) then -- Net synaptic input (+)
					NetSynapticInput_S <= (Excitation_S - Inhibition_S);
				else -- Net synaptic input (-)
					NetSynapticInput_S <= (Inhibition_S - Excitation_S);
				end if;
				-- Delta T (time passed between 2 events)
				if (CurrentTimeStamp_S >= PreviousTimeStamp_S) then -- Timer did not reset (+)
					TimeBetween2Events_S  <= CurrentTimeStamp_S - PreviousTimeStamp_S;
				else -- Timer did reset (-)
					TimeBetween2Events_S  <= "1111" & "1111" & "1111" & "1111" & "1111" & "1111" & "1111" & "1111" + CurrentTimeStamp_S - PreviousTimeStamp_S;
				end if;			
				--Debug
				debugStateDaughter_DBG <= (3 => '1', others => '0');
				
			when MultiplyDT => 
				TemporalVariable2 := NetSynapticInput_S * TimeBetween2Events_S(24 downto 0);
				NetSynapticInputTimesDT_S <= TemporalVariable2(24 downto 0); -- Integration
				PreviousTimeStamp_S       <= CurrentTimeStamp_S; -- Reset previous timestamp to current timestamp 
				--Debug
				debugStateDaughter_DBG <= (4 => '1', others => '0');
				
			when VmembraneCalculate =>
				if (Excitation_S >= Inhibition_S) then -- Membrane potential (+)
					MembranePotential_S <= MembranePotential_S + NetSynapticInputTimesDT_S;
				else -- Membrane potential (-)
					if(NetSynapticInputTimesDT_S <= MembranePotential_S) then
						MembranePotential_S <= MembranePotential_S - NetSynapticInputTimesDT_S;
					else -- Clip at zero the membrane potential
						MembranePotential_S <= (others => '0');
					end if;
				end if;	
				--Debug
				debugStateDaughter_DBG <= (5 => '1', others => '0');
				
			when CheckFire =>
				--Debug
				debugStateDaughter_DBG <= (6 => '1', others => '0');

			when Fire =>
				-- RHS out communication
				OMCFire_DO 				<= '1'; -- Fire
				DaughterOMCreq_ABO 	<= '0'; -- Request to next SM	
				--Debug
				debugStateDaughter_DBG <= (7 => '1', others => '0');
			
			when Acknowledge =>
				-- LHS in communication
				DaughterOMCack_ABO 	<= '0';
				-- RHS out communication
				DaughterOMCreq_ABO 	<= '1';
				--Debug
				debugStateDaughter_DBG <= (8 => '1', others => '0');
			
			when Decay =>
				if (MembranePotential_S = "0000" & "0000" & "0000" & "0000") then -- Already at minimum possible
					null;
				else
					MembranePotential_S <= '0' & MembranePotential_S(24 downto 1); -- Decay by dividing by 2
				end if;
				OVFack_SO  <= '1'; -- Give counter acknowledge					
				
			when others => null;

		end case;
	end if;
end process Sequential;
--------------------------------------------------------------------------------
Combinational : process (State_DP, MembranePotential_S, MotherOMCreq_ABI, NextSMack_ABI, Threshold_S, CounterOVF_S) -- Combinational Process
begin
	State_DN <= State_DP; -- Keep the same state

	case State_DP is

		when Idle =>
			if ((MotherOMCreq_ABI = '0') and (CounterOVF_S = '0')) then
				State_DN <= ExcitationCalculate;
			elsif (CounterOVF_S = '1') then
				State_DN <= Decay;
			end if;				

		when ExcitationCalculate =>
			State_DN <= ExcitationNormalise;

		when ExcitationNormalise =>
			State_DN <= NetSynapticInputCalculate;

		when NetSynapticInputCalculate =>
			State_DN <= MultiplyDT;
		
		when MultiplyDT =>
			State_DN <= VmembraneCalculate;
				
		when VmembraneCalculate =>
			State_DN <= CheckFire;

		when CheckFire =>
			if (MembranePotential_S >= Threshold_S(24 downto 0)) then
				State_DN <= Fire;
			else
				State_DN <= Acknowledge;
			end if;
		
		when Fire =>
			if (NextSMack_ABI = '0') then
				State_DN <= Acknowledge;
			end if;
		
		when Acknowledge =>
			if ((MotherOMCreq_ABI = '1') and (NextSMack_ABI = '1')) then
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