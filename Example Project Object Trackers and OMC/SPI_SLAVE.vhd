library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity SPI_SLAVE is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           NSS : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC;
			  WR: out STD_LOGIC;
			  ADDRESS: out STD_LOGIC_VECTOR(7 downto 0);		  
			  DATA_OUT: out STD_LOGIC_VECTOR(7 downto 0));
end SPI_SLAVE;


architecture Behavioral of SPI_SLAVE is

	component latch3 is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  DATA_IN : in  STD_LOGIC_VECTOR (2 downto 0);
				  DATA_OUT : out  STD_LOGIC_VECTOR (2 downto 0));
	end component;
	type STATE_TYPE is (IDLE,WAIT_FALL_EDGE,NEW_BIT,WAIT_NEW_BIT,NEW_RECIVED_WORD);
	signal CS, NS: STATE_TYPE;
	signal int_data: STD_LOGIC_VECTOR (2 downto 0);
	signal RECIVED_DATA: STD_LOGIC_VECTOR (15 downto 0):=(others=>'0');
	signal SCLK_int,MOSI_int,NSS_int,MISO_int: STD_LOGIC:='0';
	signal test_out:std_logic_vector(15 downto 0):=x"5AA5";
	signal i: integer range 0 to 16;
	signal twr: std_logic;
begin

	DATA_OUT<=RECIVED_DATA(7 DOWNTO 0) when twr='1' else 
	          (others=>'Z');
	ADDRESS<=RECIVED_DATA(15 DOWNTO 8);
	--STR<='0';
	MISO<=MISO_int;
	WR<=twr;
	latch0: latch3 
		 Port map( CLK =>clk,
				  RST =>rst,
				  DATA_IN(0)=>sclk,
				  DATA_IN(1)=>mosi,
				  DATA_IN(2)=>nss,
				  DATA_OUT =>int_data);
	latch1: latch3 
		 Port map( CLK =>clk,
				  RST =>rst,
				  DATA_IN=>int_data,
				  DATA_OUT(0)=>sclk_int,
				  DATA_OUT(1)=>mosi_int,
				  DATA_OUT(2)=>nss_int);

	process(CS,NS,SCLK_INT,MOSI_INT,i,recived_data,test_out,MISO_int)
	begin
		case CS is
				when IDLE=>
					tWR<='0';
					MISO_int<='0';
					if(sclk_int='0') then
						NS<=IDLE;
				  else
						NS<=WAIT_FALL_EDGE;
					end if;
				when WAIT_FALL_EDGE=>
					tWR<='0';
					if(i<16) then
						MISO_int<=test_out(15-i); -- RECEIVED_DATA(15);
					else
						MISO_int<='0';
					end if;
					if(sclk_int='1') then
						NS<=WAIT_FALL_EDGE;
					else
						NS<=NEW_BIT;
					end if;
				when NEW_BIT=>
					tWR<='0';
					NS<=WAIT_NEW_BIT;
					if(i<16) then
						MISO_int<=test_out(15-i); -- RECEIVED_DATA(15);
					else
						MISO_int<='0';
					end if;
				when WAIT_NEW_BIT=>
					tWR<='0';
					NS<=WAIT_NEW_BIT;
					if(sclk_int='1') then
					  if (i=16) then
						NS<=NEW_RECIVED_WORD;
						MISO_int<='0';
					  else
						MISO_int<=test_out(15-i);  -- RECEIVED_DATA(15);
						NS<=WAIT_FALL_EDGE;
					  end if;	
               end if;
				when NEW_RECIVED_WORD=>
					tWR<='1';
					MISO_int<=MISO_int; 
					NS<=IDLE;
				when others=>
					tWR<='0';
					MISO_int<=MISO_int; 
					NS<=IDLE;							
				end case;
	end process;

	process(CLK,RST) --,NSS_int,CS,NS
	begin
		if(rst='1') then
			CS<=IDLE;		
		elsif(clk='1' and clk'event) then			
			if (NSS_int='1' and  NS/=NEW_RECIVED_WORD) then
			 CS <= IDLE;
			 i<=0;
			else
				CS<=NS;
				if(CS=NEW_BIT) then
					RECIVED_DATA<=RECIVED_DATA(14 downto 0) & MOSI_INT; --Leemos el dato.
					i<=i+1;
				elsif(CS=IDLE) then
					i<=0;
				end if;
			end if;
		end if;
	end process;
end Behavioral;