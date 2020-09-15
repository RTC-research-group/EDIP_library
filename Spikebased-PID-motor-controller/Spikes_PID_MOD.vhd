
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Spikes_PID_MOD is
	--generic( BASE_ADD: std_logic_vector (7 downto 0):= x"00");
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
end Spikes_PID_MOD;

architecture Behavioral of Spikes_PID_MOD is

component Bank_Int_n_Gen_BW is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  DATA: in STD_LOGIC_VECTOR(15 downto 0);
				  WR: in STD_LOGIC;
				  spike_in_p : in  STD_LOGIC;
				  spike_in_n : in  STD_LOGIC;
				  spike_out_p : out  STD_LOGIC;
				  spike_out_n : out  STD_LOGIC);
	end component;

component Bank_Dif_n_Gen_BW is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  DATA: in STD_LOGIC_VECTOR(15 downto 0);
				  WR: in STD_LOGIC;
				  spike_in_p : in  STD_LOGIC;
				  spike_in_n : in  STD_LOGIC;
				  spike_out_p : out  STD_LOGIC;
				  spike_out_n : out  STD_LOGIC);
	end component;

	component AER_DIF is
		 Port (  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           SPIKES_IN_U: in STD_LOGIC_VECTOR(1 downto 0);
           SPIKES_IN_Y: in STD_LOGIC_VECTOR(1 downto 0);
			  SPIKES_OUT: out STD_LOGIC_VECTOR(1 downto 0));
	end component;

	
	signal spike_PID: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_I: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_D: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_ID: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_D_del: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal BASE_ADD: std_logic_vector (7 downto 0);

begin
	
	BASE_ADD<=BASE_ADDRESS;
	
	process(spike_D, clk, RST)
	begin
		if(clk='1' and clk'event) then
			if(rst='1') then
				spike_D_del<="00";
			else
				spike_D_del<=spike_D;
			end if;
		end if;
	end process;
	
	--Spikes de salida
	spike_out_p <=spike_PID(1);	--Posicion 1 positivo
	spike_out_n <=spike_PID(0);	--Posicion 0 negativo

	--Termino Integral		

	integrator: Bank_Int_n_Gen_BW 
	Port map( CLK =>clk,
		  RST =>RST,
		  BASE_ADDRESS=>BASE_ADD, -- +1,+2,+3,+4
		  ADDRESS=>ADDRESS,
		  DATA=>DATA, 
		  WR=>WR, 
		  spike_in_p =>spike_in_p,
		  spike_in_n =>spike_in_n,
		  spike_out_p =>spike_I(1),
		  spike_out_n =>spike_I(0));

		--Termino derivativo
		
	derivate: Bank_Dif_n_Gen_BW 
	Port map( CLK =>clk,
		  RST =>rst,
		  BASE_ADDRESS=>x"08"+BASE_ADD,
		  ADDRESS=>ADDRESS,
		  DATA=>DATA, 
		  WR=>WR, 
		  spike_in_p =>spike_in_p,
		  spike_in_n =>spike_in_n,
		  spike_out_p =>spike_D(1),
		  spike_out_n =>spike_D(0));

	
	ID:AER_DIF
	port map (
			  CLK =>clk,
			  RST =>RST,
			  BASE_ADDRESS=>x"00", --x"09"+BASE_ADD,  --not used internally for hold_time (set to max)
			  ADDRESS=>ADDRESS ,
			  DATA=>DATA, 
			  WR=>WR, 
           SPIKES_IN_U=>spike_D_del ,
           SPIKES_IN_Y(0)=>spike_I(1), 
			  SPIKES_IN_Y(1)=>spike_I(0), 
			  SPIKES_OUT=>spike_ID
			  );	

	PID:AER_DIF
	port map (
			  CLK =>clk,
			  RST =>RST,
			  BASE_ADDRESS=>x"00", --x"0A"+BASE_ADD,  --not used internally for hold_time (set to max)
			  ADDRESS=>ADDRESS ,
			  DATA=>DATA, 
			  WR=>WR, 
           SPIKES_IN_U(0)=>spike_in_n ,
			  SPIKES_IN_U(1)=>spike_in_p ,
           SPIKES_IN_Y(0)=>spike_ID(1), 
			  SPIKES_IN_Y(1)=>spike_ID(0), 
			  SPIKES_OUT=>spike_PID
			  );	

end Behavioral;

