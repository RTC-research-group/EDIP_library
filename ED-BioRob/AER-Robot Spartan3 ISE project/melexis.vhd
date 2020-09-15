library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;



entity FSM_MELEXIS is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
		   data_ready_o : out STD_LOGIC; 
		   --data to be sent to the the SPI_64 bits
           DATA_o : out  STD_LOGIC_VECTOR (63 downto 0); 
		   data_ready_i : in STD_LOGIC; 
		   --data coming from the slave (sensor). alpha is 14-bits wide the other two bits are used for diagnosis status.   
		   DATA_i: in STD_LOGIC_VECTOR (15 downto 0); 
						DATA_roll_i: in STD_LOGIC_VECTOR (7 downto 0);
						data_from_sensor_ok_o: out STD_LOGIC; 
           EN_i : in  STD_LOGIC); --input from the MUX. It enables the FSM so a data have to be read. 
end FSM_MELEXIS;


architecture Behavioral of FSM_MELEXIS is
--constants to build up the 64bits packet to be sent to the sensor
constant byte_0: STD_LOGIC_VECTOR (7 downto 0):=(others=>'0');  --bytes of 0s
constant byte_alpha: STD_LOGIC_VECTOR (7 downto 0):= "00010101";--"00010011"; --  --byte to be sent by the SPI master to read the alpha
constant byte_1s: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others=>'1'); --byte of '1s' (gonna be used to fix the time-out as it maximum)
constant byte_CRC: STD_LOGIC_VECTOR (7 DOWNTO 0):="00001000"; --for the GET_1code-- "11101010"; --for GET_3 code --

--register to store the alpha from the sensor
signal alpha: STD_LOGIC_VECTOR (13 DOWNTO 0);

signal code2sent: STD_LOGIC_VECTOR (63 DOWNTO 0);

--signals for the counter 
signal count_enable: STD_LOGIC;
signal count: INTEGER RANGE 0 to 50000:=0;
signal count_done: STD_LOGIC;

--how the GET is built: 
--bye 0 = 0x00
--byte 1 = 0x00 
--byte 2=0xFF 
--byte 3=0xFF 
--bye 4 = 0x00 
--byte 5 = 0x00 
--byte 6=00010011 
--byte 7 =CRC (0xEA)


------------------------------------------------------
-- STATES DEFINITION
-------------------------------------------------------
type state is (idle, send_GET_1, send_GET_2_data, wait_data_read, data_from_sensor, wait_tsref);
signal next_st,current_st: state;
 
attribute keep : string; 
attribute keep of code2sent: signal is "true"; 

--signal get_3_count: interger range 0 to 3; 
 
begin

DATA_o<=code2sent;

--This is the combinational process for the FSM 
fsm_comb: process (current_st)
begin
	case current_st is
	
		when idle => 
			data_ready_o<='0';
			count_enable<='0';
			data_from_sensor_ok_o<='0';
			if (EN_i = '1') then 
			-- the jAER wants to read the sensor. This pulse will last one cycle only. It will be repeated over time whenever the jAER wants to read but this module will never stop reading since the first one. 
			--Thus, only the first pulse will be considered by this block. After that, the register with the info from the sensor will be updated periodically even if the jAER is not asking. 
				next_st<=send_GET_1; 
			else
				next_st<=idle;
			end if; 
			
		when send_GET_1 =>
			
			count_enable<='0';
			data_ready_o<='1';
			next_st<=send_GET_2_data; 
			
		when send_GET_2_data => 
			count_enable<='0';
			  
			next_st<=wait_data_read; 
			
		when wait_data_read =>
			count_enable<='0';
			if (data_ready_i = '1') then 
				next_st<=data_from_sensor;
			else
				next_st<=wait_data_read;
			end if; 
							
		when data_from_sensor=> 
			count_enable<='0';
			next_st<=wait_tsref;
		
		when wait_tsref	=>
			count_enable<='1';
			--if (DATA_roll_i = "11101101") then --it means sensors is sending valid data 
			if (DATA_roll_i = "10110111") then --it means sensors is sending valid data 
				data_from_sensor_ok_o<='1';
			else
				data_from_sensor_ok_o<='0';
			end if; 
			
			if (count_done = '1') then 
				next_st<=send_GET_1;
			else
				next_st<=wait_tsref; 
				
			end if; 
	
		
		
			
			
	end case; 
	

end process fsm_comb;


 ---------------- 
 -- FSM-
 ---------------- 

sync: process (clk_i, rst_i)
begin 
	if 	(rst_i = '0') then 	
		current_st <= idle; 
		code2sent<=(others=>'0');
		
	elsif rising_edge(clk_i) then 
	
	
		if (current_st = data_from_sensor) then alpha<=DATA_i(13 downto 0); end if;
		if (current_st =send_GET_2_data) then code2sent<=byte_0 & byte_0 &  byte_1s & byte_1s &  byte_0 & byte_0 &  byte_alpha & byte_CRC ;  end if; --else DATA_o<=(others=>'1');
		current_st <= next_st;
		
	end if; 
end process sync; 




--------------------------------------
-- 1ms counter (50000 clock cycles) --
-- 1us counter (for GET 3) -- 
--------------------------------------

ms_second_count: process (clk_i, count_enable)
begin 
if (count_enable = '0') then 
	count_done<='0';
	count<=0;
elsif rising_edge(clk_i) then 
	if (count = 5000) then 
		count_done<='1';
		
	else
		count<=count+1;
		count_done<='0';
		
	end if; 
end if;
end process ms_second_count; 

end Behavioral;
