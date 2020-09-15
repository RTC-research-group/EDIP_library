library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity EnCoderEventGenerator is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           spikes : out  STD_LOGIC_VECTOR (1 downto 0));
end EnCoderEventGenerator;

architecture Behavioral of EnCoderEventGenerator is

	component latch2 is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  DATA_IN : in  STD_LOGIC_VECTOR (1 downto 0);
				  DATA_OUT : out  STD_LOGIC_VECTOR (1 downto 0));
	end component;

	type STATE_TYPE is (IDLE,AD_PULSE0,AD_PULSE1,AD_PULSE2,AD_PULSE3,AD_WAIT0,AD_WAIT1,AD_WAIT2
									,AT_PULSE0,AT_PULSE1,AT_PULSE2,AT_PULSE3,AT_WAIT0,AT_WAIT1,AT_WAIT2);
	signal CS, NS: STATE_TYPE;
	signal int_data: STD_LOGIC_VECTOR (1 downto 0);
	signal int_AB: STD_LOGIC_VECTOR (1 downto 0);
	signal int_A : STD_LOGIC;
	signal int_B : STD_LOGIC;

begin

	
		latch0: latch2 
		 Port map( CLK =>clk,
				  RST =>rst,
				  DATA_IN(0)=>A,
				  DATA_IN(1)=>B,
				  DATA_OUT =>int_data);
	latch1: latch2 
		 Port map( CLK =>clk,
				  RST =>rst,
				  DATA_IN=>int_data,
				  DATA_OUT=>int_AB);

	int_A<=int_AB(0);
	int_B<=int_AB(1);
	
--	int_A<=A;
--	int_B<=B;
	
	process(CS,int_A,int_B,NS)
	begin
	
		case CS is
				when IDLE=>
					spikes<=(others=>'0');

					if(int_A='1' and int_B='0') then
						NS<=AD_PULSE0;
					elsif(int_B='1' and int_A='0') then
						NS<=AT_PULSE0;	
					else
					  NS<=IDLE;
					end if;			

				when AD_PULSE0=>
					spikes<="10";
					NS<=AD_WAIT0;			

				when AD_WAIT0=>
					spikes<="00";
					if(int_A='1' and  int_B='0') then
						NS<=AD_WAIT0;
					elsif(int_A='1' and  int_B='1') then
						NS<=AD_PULSE1;
					else
						NS<=IDLE;
					end if;
				
				when AD_PULSE1=>
					spikes<="10";
					NS<=AD_WAIT1;	
	
				when AD_WAIT1=>
					spikes<="00";
					if(int_A='1' and  int_B='1') then
						NS<=AD_WAIT1;
					elsif(int_A='0' and  int_B='1') then
						NS<=AD_PULSE2;
					else
						NS<=IDLE;
					end if;
				
				when AD_PULSE2=>
					spikes<="10";
					NS<=AD_WAIT2;			
					
				when AD_WAIT2=>
					spikes<="00";
					if(int_A='0' and  int_B='1') then
						NS<=AD_WAIT2;
					elsif(int_A='0' and  int_B='0') then
						NS<=AD_PULSE3;
					else
						NS<=IDLE;
					end if;	
				
				when AD_PULSE3=>
					spikes<="10";
					NS<=IDLE;						
					
				when AT_PULSE0=>
					spikes<="01";
					NS<=AT_WAIT0;			

				when AT_WAIT0=>
					spikes<="00";
					if(int_A='0' and  int_B='1') then
						NS<=AT_WAIT0;
					elsif(int_A='1' and  int_B='1') then
						NS<=AT_PULSE1;
					else
						NS<=IDLE;
					end if;
				
				when AT_PULSE1=>
					spikes<="01";
					NS<=AT_WAIT1;	
	
				when AT_WAIT1=>
					spikes<="00";
					if(int_A='1' and  int_B='1') then
						NS<=AT_WAIT1;
					elsif(int_A='1' and  int_B='0') then
						NS<=AT_PULSE2;
					else
						NS<=IDLE;
					end if;
				
				when AT_PULSE2=>
					spikes<="01";
					NS<=AT_WAIT2;			
					
				when AT_WAIT2=>
					spikes<="00";
					if(int_A='1' and  int_B='0') then
						NS<=AT_WAIT2;
					elsif(int_A='0' and  int_B='0') then
						NS<=AT_PULSE3;
					else
						NS<=IDLE;
					end if;	
				
				when AT_PULSE3=>
					spikes<="01";
					NS<=IDLE;			
					
			end case;
	end process;

	process(clk,rst,CS,NS)
	begin
		if(rst='1') then
			CS<=IDLE;
		elsif(clk='1' and clk'event) then
			CS<=NS;
		end if;
	end process;


end Behavioral;

