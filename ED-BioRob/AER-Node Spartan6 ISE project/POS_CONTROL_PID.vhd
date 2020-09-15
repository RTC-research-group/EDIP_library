library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity POS_CONTROL_PID is
   generic( BASE_ADD: std_logic_vector (7 downto 0):= x"00");
    Port (
			  CLK : in  STD_LOGIC;
           RST_int : in  STD_LOGIC;
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
			  
			  SPIKES_OUT: out STD_LOGIC_VECTOR(13 downto 0);
			  
			  MOTOR: out STD_LOGIC_VECTOR(1 downto 0);
			  ENCODER: in STD_LOGIC_VECTOR(1 downto 0);
			  LEDS: out STD_LOGIC_VECTOR(2 downto 0);
			  AUX: out STD_LOGIC_VECTOR(1 downto 0)
			  );

end POS_CONTROL_PID;

architecture Behavioral of POS_CONTROL_PID is

	
	component LED_DRIVER is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           LEDS : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;
	
	component Event_Generator_signed_BW is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           SPIKE : out  STD_LOGIC_VECTOR(1 downto 0));
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

	component BiDirPFM is
		Port ( 	CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
			  PULSE : in  STD_LOGIC_VECTOR (1 downto 0);
			  PFM_out: out  STD_LOGIC_VECTOR (1 downto 0));
	end component;

	component EnCoderEventGenerator is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           spikes : out  STD_LOGIC_VECTOR (1 downto 0));
	end component;
	
	
	component Spikes_PID_MOD is
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

	component Bank_POS_Int_n_Gen_BW is
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

	signal spike_R_pos_ref: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_R_encoder: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_R_pos_error: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_R_PID: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal spike_R_motor_pos: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');
	signal motor_R_temp: STD_LOGIC_VECTOR (1 downto 0):=(others=>'0');	

begin

	AUX <=spike_R_pos_ref;
		
	Motor(0)<='0'; --motor_R_temp(1);
	Motor(1)<='0'; --motor_R_temp(0);
	

	SPIKES_OUT(1 downto 0) <=b"00"; --spike_R_pos_ref;
	SPIKES_OUT(3 downto 2) <=b"00"; --spike_R_pos_error;
	SPIKES_OUT(5 downto 4) <= b"00"; --motor_R_temp; --I
	SPIKES_OUT(7 downto 6) <= b"00"; --D
	SPIKES_OUT(9 downto 8) <=spike_R_PID;
	-- These two signals will be sent to the Spartan 3 for being expanded there.
	SPIKES_OUT(11 downto 10) <=b"00"; --spike_R_encoder;
	SPIKES_OUT(13 downto 12) <=b"00"; --spike_R_motor_pos;


--LEDS
	U_LED_DRIVER:LED_DRIVER
    Port map ( CLK => clk,
           RST => rst_int,
			  ADDRESS => ADDRESS,
			  BASE_ADDRESS=>x"00"+BASE_ADD,
			  DATA => DATA,
			  WR => WR,
           LEDS(2 downto 0)=>LEDS,
			  LEDS(3)=>open);



--GENERADOR DE REFERENCIA

	R_SpeedRef: Event_Generator_signed_BW 
		 Port map(  CLK =>clk,
			  RST =>RST_int,
			  BASE_ADDRESS=>x"02"+BASE_ADD,
			  ADDRESS=>ADDRESS,
			  DATA=>DATA, 
			  WR=>WR, 
           SPIKE=>spike_R_pos_ref
		 );
		

--MOTOR

	R_LOOP_SPEED:AER_DIF
	port map (
			  CLK =>clk,
			  RST =>RST_int,
			  BASE_ADDRESS=>x"10"+BASE_ADD,
			  ADDRESS=>ADDRESS ,
			  DATA=>DATA, 
			  WR=>WR, 
           SPIKES_IN_U=>spike_R_pos_ref ,
           SPIKES_IN_Y=>spike_R_motor_pos, 
			  SPIKES_OUT=>spike_R_pos_error
			  );			  

	R_Spikes_PID_MOD: Spikes_PID_MOD 
--    generic map( BASE_ADD=>x"03")
	 Port map (CLK =>CLK,
			  RST =>RST_int,
			  BASE_ADDRESS => x"03"+BASE_ADD,
			  ADDRESS=>ADDRESS ,
			  DATA=>DATA, 
			  WR=>WR, 
           spike_in_p =>spike_R_pos_error(1),
           spike_in_n =>spike_R_pos_error(0),
           spike_out_p =>spike_R_PID(1),
           spike_out_n =>spike_R_PID(0)
			  );

	--R_BI_DIR_PFM: BiDirPFM -- spikes expansors
	--port map (
	--		  CLK =>CLK,
	--		  RST =>RST_int,
	--		  BASE_ADDRESS=>x"12"+BASE_ADD,
	--		  ADDRESS=>ADDRESS ,
	--		  DATA=>DATA, 
	--		  WR=>WR, 
	--		  PULSE=>spike_R_PID,
	 --   	  PFM_out=>MOTOR_R_temp
	--			);

--	R_POS_INT_n_GEN: Int_n_Gen_BW 
--		Generic map(GL=>20,SAT=>1048575)
--		 Port map( CLK =>clk,
--				  RST =>RST_int,
--				  BASE_ADDRESS=>x"13"+BASE_ADD,
--			     ADDRESS=>ADDRESS,
--			     DATA=>DATA, 
--			     WR=>WR, 
--				  spike_in_p => ENCODER(1), --spike_R_encoder(1),
--				  spike_in_n => ENCODER(0), --spike_R_encoder(0),
--				  spike_out_p =>spike_R_motor_pos(1),
--				  spike_out_n =>spike_R_motor_pos(0));
	POS_INT_n_GEN: Bank_POS_Int_n_Gen_BW 
	Port map( CLK =>clk,
		  RST =>RST_int,
		  BASE_ADDRESS=>x"13"+BASE_ADD, -- +1,+2,+3,+4
		  ADDRESS=>ADDRESS,
		  DATA=>DATA, 
		  WR=>WR, 
		  spike_in_p =>ENCODER(1),
		  spike_in_n =>ENCODER(0),
		  spike_out_p =>spike_R_motor_pos(1),
		  spike_out_n =>spike_R_motor_pos(0));

-- This block sis moved to the Spartan 3 and here we will receive the spikes for the corresponding encoder.
--	R_ENCODER:EnCoderEventGenerator
--	Port map ( 
--		  CLK =>CLK,
--		  RST =>RST_int,
--        A =>ENC_R(1),
--        B =>ENC_R(0),
--        spikes =>spike_R_encoder
--			);
--AUX <= ENCODER;

end Behavioral;