--------------------------------------------------------------------------------
-- Company: INI
-- Engineer: Hongjie Liu
--
-- Create Date:    16.03.2017
-- Design Name:    
-- Module Name:    ApproachCell
-- Project Name:   VISUALISE
-- Target Device:  Latticed LFE3-17EA-7ftn256i  // Spartan 6-1500 LXT of the AER-Node board (www.t-cober.es)
-- Tool versions:  Diamond x64 3.0.0.97x
-- Description:	 Module to mimic the processing of the Approach Cell RGC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
entity ApproachCell is

    port(
		Clock_CI                 : in  std_logic;----low
		Reset_RI                 : in  std_logic; ---high
--------------------lefthand side handshaking
		Req_I							 : in  std_logic;  ---low
		Ack_O							 : out std_logic;------low
--------------------righthand side handshaking
		AC_Fire_O    					 : out std_logic;   ----high
		NextBlock_Ack_I             :in  std_logic;  ---low

---------------DVS input		
		
		EventXAddr_I, EventYAddr_I	 : in  std_logic_vector( 4 downto 0);

		EventPolarity_I					 : in std_logic;
--------------Decay-------------------------
		DecayEnable_I				     : in std_logic; ----active high


		surroundSuppressionEnabled_I	 : in std_logic;----active high
		IFThreshold_I: 							in signed(47 downto 0);
		UpdateUnit_I:								in signed (2 downto 0);
		OVFack_O:                    out std_logic ---------------decay counter acknowledge----active high
	
--	   CounterSize : in Integer;
		);

end entity ApproachCell;

architecture Behavioral of ApproachCell is

	attribute syn_enum_encoding : string;

	type state is (stIdle, stDecay, stCheckPolarity, stOnEvent, stOffEvent, stComputeInputtoAC, stComputeSynapticInput, stComputeMembraneState, stComparetoIFThreshold_I, stFire, stAcknowledge);

	attribute syn_enum_encoding of state : type is "onehot";

	type tVmem is array ( 7 downto 0, 7 downto 0) of signed(15 downto 0);

	signal VmemOn, VmemOff, InputtoACOn, InputtoACOff :  tVmem;
    signal CounterOut_I:  unsigned(31 downto 0);
   
	signal State_DP, State_DN : state;
	signal Timestamp: unsigned(31 downto 0); -- := (others => '0');
	signal TimerLimit_S: unsigned (31 downto 0);
	signal Decay_active:  std_logic;
	signal MembraneState   : signed(47 downto 0); -- := (others => '0');
	signal netSynapticInput  : signed(15 downto 0); --:= (others => '0');
	signal dT: unsigned(31 downto 0); -- := (others => '0');
	signal CounterMax: unsigned(31 downto 0); --:=(others => '1');
	signal Voff, Von, resultOn, resultOff : tVmem; 

	signal MS:   signed(47 downto 0);
	signal a,b: integer range 0 to 7;

begin

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
	Data_DO      		=> CounterOut_I); 	-- Leave unconnected
	
p_memoryless : process(a,b, Decay_active, dt, von, netSynapticInput, updateunit_i, ifthreshold_i, voff, InputtoACOn, InputtoACOff, State_DP, CounterOut_I, Req_I, NextBlock_Ack_I , EventXAddr_I, EventYAddr_I, DecayEnable_I, EventPolarity_I,VmemOn,VmemOff,MembraneState)

	variable sumOff, sumOn : tVmem;	
		begin

			State_DN <= State_DP;
			for i in 0 to 7 loop
			   for j in 0 to 7 loop
				   sumOff(i,j) := (others =>'0');
				   sumOn(i,j) := (others => '0');
				   Voff(i,j) <= VmemOff(i,j); --(others =>'0');
					Von(i,j) <= VmemOn(i,j); --(others => '0');
					resultOn(i,j) <= VmemOn(i,j); --(others => '0');
					resultOff(i,j) <= VmemOff(i,j); --(others => '0');
				end loop;
			end loop;
			MS <=  MembraneState;
			case State_DP is
				when stIdle =>
					 if Req_I = '0' then
						State_DN <= stCheckPolarity;
					 elsif Decay_active = '1' then
							State_DN <= stDecay;
					 else State_DN <= stIdle;
					 end if;
				when stCheckPolarity =>
						if EventPolarity_I= '0' then  --------Polarity = 0 off event Polarity =1 On event; should be changed counterwise
						   State_DN <= stOffEvent;
					    elsif EventPolarity_I= '1' then
						   State_DN <= stOnEvent;
						end if;
				when stDecay =>
					State_DN <= stIdle;
					for i in 0 to 7 loop
						for j in 0 to 7 loop
							 VOn(i,j) <=  '0' & VmemOn(i,j)(15 downto 1);
							 VOff(i,j) <=  '0' & VmemOff(i,j)(15 downto 1);
						end loop;
					end loop; 
				when stOnEvent =>
					 State_DN <= stComputeInputtoAC;
					 VOn(a, b)<=VmemOn(a, b)+ UpdateUnit_I;
			    when stOffEvent =>
					 State_DN <= stComputeInputtoAC;
					 VOff(a, b)<=VmemOn(a, b)+ UpdateUnit_I;
				 when stComputeInputtoAC =>  
						State_DN <= stComputesynapticInput;
										if  (a>0 and a< 7 and b>0 and b<7) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a+1,b)+ VmemOff(a-1,b)+ VmemOff(a,b-1)+ VmemOff(a,b+1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a+1,b)+ VmemOn(a-1,b)+ VmemOn(a,b-1)+ VmemOn(a,b+1);
										end if;

										if (a=0 and b=0) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a+1,b)+ VmemOff(a+1,b)+ VmemOff(a,b+1)+VmemOff(a,b+1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a+1,b)+ VmemOn(a+1,b)+ VmemOn(a,b+1)+ VmemOn(a,b+1);
										end if;
										if  (a=7 and b=7) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a-1,b)+ VmemOff(a-1,b)+ VmemOff(a,b-1)+ VmemOff(a,b-1);											
											sumOn(a,b) := sumOn(a,b) + VmemOn(a-1,b)+ VmemOn(a-1,b)+ VmemOn(a,b-1)+ VmemOn(a,b-1);											
										end if;
										if (a=0 and b=7) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a+1,b) + VmemOff(a+1,b)+ VmemOff(a,b-1)+ VmemOff(a,b-1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a+1,b)+ VmemOn(a+1,b)+ VmemOn(a,b-1)+ VmemOn(a,b-1);
										end if;
										if (a=7 and b=0) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a-1,b)+ VmemOff(a-1,b)+ VmemOff(a,b+1)+ VmemOff(a,b+1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a-1,b)+ VmemOn(a-1,b)+ VmemOn(a,b+1)+ VmemOn(a,b+1);
										end if;
										if (a>0 and a<7 and b=0) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a-1,b)+ VmemOff(a+1,b) + VmemOff(a,b+1)+ VmemOff(a,b+1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a-1,b)+ VmemOn(a+1,b) + VmemOn(a,b+1)+ VmemOn(a,b+1);
										end if;									
										if (a>0 and a<7 and b=7) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a-1,b)+ VmemOff(a+1,b) + VmemOff(a,b-1)+ VmemOff(a,b-1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a-1,b)+ VmemOn(a+1,b) + VmemOn(a,b-1)+ VmemOn(a,b-1);
										end if;
										if (a=0 and b>0 and b<7) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a+1,b)+ VmemOff(a+1,b)+ VmemOff(a,b-1) + VmemOff(a,b+1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a+1,b)+ VmemOn(a+1,b)+ VmemOn(a,b-1) + VmemOn(a,b+1);
										end if;
										if (a=7 and b>0 and b<7) then
											sumOff(a,b) := sumOff(a,b) + VmemOff(a-1,b)+ VmemOff(a-1,b)+ VmemOff(a,b-1) + VmemOff(a,b+1);
											sumOn(a,b) := sumOn(a,b) + VmemOn(a-1,b)+VmemOn(a-1,b)+VmemOn(a,b-1) + VmemOn(a,b+1);
										end if;
										resultOff(a,b) <= VmemOff(a,b) - ("00" & sumOff(a,b)(15 downto 2));
										resultOn(a,b) <= VmemOn(a,b) - ("00" & sumOn(a,b)(15 downto 2));
				when stComputeSynapticInput =>
						State_DN <= stComputeMembraneState;
				when stComputeMembraneState =>
						State_DN <= stComparetoIFThreshold_I; 
						MS <= MembraneState + netSynapticInput * ( signed (dT));						-----MembraneState  multiplication 
				when stComparetoIFThreshold_I =>
						if (MembraneState > IFThreshold_I)    then                             -------[possion firing to be done later]
							State_DN <= stFire;
						elsif (Req_I = '1') then
						   State_DN <= stIdle;
						end if;
				when stFire =>
				      if(NextBlock_Ack_I  ='0') then  -- modified this condition to go on with AC_Fire
						   State_DN <= stAcknowledge;
						end if;
			   when stAcknowledge =>
			         if(NextBlock_Ack_I  = '1' and Req_I = '1') then
							State_DN <= stIdle;
			         end if;
				when others => null;
			end case;
		end process p_memoryless;



	p_states_change: process(Clock_CI, Reset_RI)
	begin
		if Reset_RI = '1' then          -- asynchronous reset (active-high for FPGAs)
			State_DP <= stIdle;
		elsif rising_edge(Clock_CI) then
	     	State_DP <= State_DN;
		end if;
	end process;


	p_memoryzing : process(Clock_CI, Reset_RI) 
	variable sumInputtoACOn: signed(15 downto 0); --:= (others => '0');
	variable sumInputtoACOff : signed(15 downto 0); --:= (others => '0');

	begin
		if Reset_RI = '1' then
			Decay_active <= '0';
         TimerLimit_S 			<= (others => '0');
			Ack_O <= '1';  -- Added the new output Ack_O of your cell in this process.
			netSynapticInput <= (others =>'0');
			for i in 0 to 7 loop
			   for j in 0 to 7 loop
				   VmemOff(i,j) <= (others =>'0');
					VmemOn(i,j) <= (others => '0');
					InputtoACOn(i,j) <= (others => '0');
					InputtoACOff(i,j) <= (others => '0');
				end loop;
			end loop;
			CounterMax <= (others => '0');
			dT <= (others =>'0');
			MembraneState <= (others =>'0');
			TimeStamp <= (others => '0');
		elsif rising_edge(Clock_CI) then
			CounterMax <= (others => '1');
			TimerLimit_S 			<= (others => '1'); 
			if DecayEnable_I ='1' then
			   Decay_active <='1';-----synchronized decay not so important as it is already triggered by symchronized signal(counter)

			elsif State_DP = stDecay then
			   Decay_active <= '0';
			end if;

			case State_DP is
				when stIdle =>
						 if Req_I = '0' then
							TimeStamp  <= CounterOut_I;

							if (CounterOut_I > Timestamp) then
							   dT <= CounterOut_I - Timestamp ;
							else
							   dT <= CounterOut_I + CounterMax  - Timestamp ;
							end if;
						 end if;
						 Ack_O <= '1';
						 AC_Fire_O  <= '0';  
				when stDecay =>

					for i in 0 to 7 loop
					 for j in 0 to 7 loop
						 VmemOn(i,j) <= VOn(i,j);
						 VmemOff(i,j) <= VOff(i,j);
					 end loop;
					end loop;
					Decay_active <= '0';
					OVFack_O  <= '1'; -- Give counter ack

				when stCheckPolarity =>
				    a<=to_integer(unsigned(EventXAddr_I(4 downto 2))); 
					 b<=to_integer(unsigned(EventYAddr_I(4 downto 2)));
				when stOnEvent =>
									VmemOn(a,b) <= VOn(a,b);
				when stOffEvent =>
									VmemOff(a,b) <= VOff(a,b);
				 when stComputeInputtoAC =>
							 if  surroundSuppressionEnabled_I = '1'	then

										if 	(resultOff(a,b) < 0) then
											InputtoACOff(a,b) <= (others =>'0');
										else InputtoACOff(a,b) <= resultOff(a,b);
										end if;

										if (resultOn(a,b) < 0)then
											InputtoACOn(a,b) <= ( others=>'0');    -----InputtoAC decides the input of each subunit to the AC
										else InputtoACOn(a,b) <= resultOn(a,b);    ----non linearity in the case with surround suppression is implemented. /////
										end if;
							 else  
										if (VmemOn(a,b) < 0)then
											InputtoACOn(a,b) <= ( others=>'0');
										else InputtoACOn(a,b) <= VmemOn(a,b);    ----non linearity in the case without surround suppression is implemented. /////
										end if;
										if (VmemOff(a,b) < 0)then
											InputtoACOff(a,b) <= ( others=>'0');
										else InputtoACOff(a,b) <= VmemOff(a,b);    ----non linearity in the case without surround suppression is implemented. /////
										end if;
							 end if;

				when stComputeSynapticInput => 
						sumInputtoACOn := (others => '0');
						sumInputtoACOff := (others => '0');
						for i in 0 to 7 loop
							for j in 0 to 7 loop
							sumInputtoACOn := sumInputtoACOn + InputtoACOn(i,j);
							sumInputtoACOff := sumInputtoACOff + InputtoACOff(i,j);
							end loop;
						end loop;
						netSynapticInput<= sumInputtoACOff - sumInputtoACOn;                  

				when stComputeMembraneState =>
						MembraneState <= MS ;
						Ack_O <= '0';
				when stComparetoIFThreshold_I =>
						if  MembraneState > IFThreshold_I then
							MembraneState <= (others=>'0') ;
							AC_Fire_O  <= '1';
						elsif MembraneState < to_signed(-10, 24)  then
							MembraneState <= (others=>'0');
						end if;
			   when stAcknowledge => 
					AC_Fire_O <= '0';
				when others => null;
			end case;

		end if;
	end process p_memoryzing;
end Behavioral;
