----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:29:15 12/15/2008 
-- Design Name: 
-- Module Name:    POS_INT_n_GEN - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity POS_INT_n_GEN is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKE_IN_P : in  STD_LOGIC;
           SPIKE_IN_N : in  STD_LOGIC;
           SPIKE_OUT_P : out  STD_LOGIC;
           SPIKE_OUT_N : out  STD_LOGIC);
end POS_INT_n_GEN;

architecture Behavioral of POS_INT_n_GEN is

signal integrated_spikes: signed (15 downto 0):=(others=>'0') ;

signal DATA_IN: STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal ciclo: STD_LOGIC_VECTOR (14 downto 0):=(others=>'0');	--TOCAR AQUI
signal pulse: STD_LOGIC:='0';
signal pulse_p: STD_LOGIC:='0';
signal pulse_n: STD_LOGIC:='0';
signal data_temp: signed (15 downto 0):=(others=>'0') ;
signal CE: STD_LOGIC:='0';
begin

process(clk,rst,spike_in_p,spike_in_n,integrated_spikes)
begin
		if(clk='1' and clk'event) then
			if(rst='1') then
				integrated_spikes<=(others=>'0');
			else
			--He tocado aqui
				if(spike_in_p='1' and spike_in_n='0' and integrated_spikes<32535) then
					integrated_spikes<=integrated_spikes+1;
				elsif(spike_in_n='1' and spike_in_p='0' and integrated_spikes>-32535) then
					integrated_spikes<=integrated_spikes-1;
				end if;
			end if;
		end if;
end process;
			

data_in<=conv_std_logic_vector(integrated_spikes,16);

-------------------GENERATE
SPIKE_OUT_P<=pulse_p;
SPIKE_OUT_N<=pulse_n;

		--Solo 10 bits más significativos
data_temp<=abs(signed(data_in(15 downto 5)));

process(clk,rst,data_in,pulse,ciclo)
begin
		if(clk='1' and clk'event) then
			if(rst='1') then
				ciclo<=(others=>'0');
				CE<='0';

				pulse_p<='0';
				pulse_n<='0';			

				pulse<='0';				
			else
			
				CE<=not CE;
				if(CE='1') then
					ciclo<=ciclo+1;
				end if;

				if (CE='1' and ((conv_integer(ciclo)*conv_integer (data_temp)) mod 32768) < conv_integer(data_temp)) then
					pulse<='1';
				else
					pulse<='0';
				end if;
				
				if((signed(data_in))>0) then
					pulse_p<=pulse;
					pulse_n<='0';
				elsif ((signed(data_in))<0) then
					pulse_p<='0';
					pulse_n<=pulse;			
				else
					pulse_p<='0';
					pulse_n<='0';
				end if;
				
			end if;
			
	end if;
end process;


end Behavioral;

