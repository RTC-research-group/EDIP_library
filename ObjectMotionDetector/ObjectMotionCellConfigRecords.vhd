--------------------------------------------------------------------------------
-- Company: INI
-- Engineer: Diederik Paul Moeys
--
-- Create Date:    01.10.2014
-- Design Name:    
-- Module Name:    ObjectMotionCellConfigRecords
-- Project Name:   VISUALISE
-- Target Device:  Latticed LFE3-17EA-7ftn256i
-- Tool versions:  Diamond x64 3.0.0.97x
-- Description:	 Module to store the configuration of the Object Motion Cell RGC
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries -------------------------------------------------------------------
-------------------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Package Declaration ---------------------------------------------------------
--------------------------------------------------------------------------------
package ObjectMotionCellConfigRecords is
	constant OBJECTMOTIONCELLCONFIG_MODULE_ADDRESS : unsigned(6 downto 0) := to_unsigned(13, 7); -- Define address of module

	type tObjectMotionCellConfigParamAddresses is record -- Define type of address
		Threshold_S     		: unsigned (7 downto 0);
		DecayTime_S     		: unsigned (7 downto 0);
		ExcitationStrength_S : unsigned (7 downto 0);
		Saturation_S			: unsigned (7 downto 0);
		InhibitionStrength_S : unsigned (7 downto 0);
	end record tObjectMotionCellConfigParamAddresses;

	constant OBJECTMOTIONCELLCONFIG_PARAM_ADDRESSES : tObjectMotionCellConfigParamAddresses := ( -- Address of variable
		Threshold_S     			=> to_unsigned(0, 8),
		DecayTime_S     			=> to_unsigned(1, 8),
		ExcitationStrength_S		=> to_unsigned(2, 8),
		Saturation_S				=>	to_unsigned(3, 8),
		InhibitionStrength_S		=> to_unsigned(4, 8));

	type tObjectMotionCellConfig is record -- Define type of variable
		Threshold_S     			: unsigned (31 downto 0);
		DecayTime_S     			: unsigned (31 downto 0);
		ExcitationStrength_S    : unsigned (7 downto 0);
		Saturation_S				: unsigned (7 downto 0);
		InhibitionStrength_S    : unsigned (7 downto 0);
	end record tObjectMotionCellConfig;

	constant tObjectMotionCellConfigDefault : tObjectMotionCellConfig := ( -- Define default values
		Threshold_S     			=> "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "1000" & "0000",
		DecayTime_S     			=> "0000" & "0000" & "0000" & "0001" & "1000" & "0110" & "1010" & "0000",
		ExcitationStrength_S	   => "0000" & "0001",
		Saturation_S			   => "0001" & "0000",
		InhibitionStrength_S	   => "0000" & "0001");
	
	type receptiveFieldMotherOMC is array (7 downto 0, 7 downto 0) of unsigned(15 downto 0);
	type receptiveFieldDaughterOMC is array (1 downto 0, 1 downto 0) of unsigned(15 downto 0);
		
end package ObjectMotionCellConfigRecords;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------