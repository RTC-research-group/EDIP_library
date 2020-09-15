library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity MICRO_CONTROLLER_SPI_SLAVE is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
  			  ADDRESS: out STD_LOGIC_VECTOR(7 downto 0);		  
			  DATA_OUT: out STD_LOGIC_VECTOR(15 downto 0);
			  WR: out STD_LOGIC;
           STR : out  STD_LOGIC;
           NSS : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC);
end MICRO_CONTROLLER_SPI_SLAVE;


architecture Behavioral of MICRO_CONTROLLER_SPI_SLAVE is

	component latch3 is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  DATA_IN : in  STD_LOGIC_VECTOR (2 downto 0);
				  DATA_OUT : out  STD_LOGIC_VECTOR (2 downto 0));
	end component;
	type STATE_TYPE is (IDLE,WAIT_FALL_EDGE,NEW_BIT,WAIT_NEW_BIT,NEW_RECIVED_WORD);
	signal CS: STATE_TYPE:=IDLE;
	signal NS: STATE_TYPE;
	signal int_data: STD_LOGIC_VECTOR (2 downto 0):=(others=>'0');
	signal RECIVED_DATA: STD_LOGIC_VECTOR (23 downto 0):=(others=>'0');
	signal SCLK_int,MOSI_int,NSS_int,MISO_int: STD_LOGIC:='0';
	signal test_out:std_logic_vector(23 downto 0):=x"F0AA0F";
	signal i: integer range 0 to 24:=0;
begin

	STR<=RST;
	MISO<=MISO_int;
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

	process(CS,NS,SCLK_INT,MOSI_INT,i,recived_data)
	begin
		case CS is
				when IDLE=>
					MISO_int<='0';
					if(sclk_int='0') then
						NS<=IDLE;
				  else
						NS<=WAIT_FALL_EDGE;
					end if;
				when WAIT_FALL_EDGE=>
					if(i<24) then
						MISO_int<=test_out(23-i);
					else
						MISO_int<='0';
					end if;
					if(sclk_int='1') then
						NS<=WAIT_FALL_EDGE;
					else
						NS<=NEW_BIT;
					end if;
				when NEW_BIT=>
					NS<=WAIT_NEW_BIT;
					if(i<24) then
						MISO_int<=test_out(23-i);
					else
						MISO_int<='0';
					end if;
				when WAIT_NEW_BIT=>
					if(i=24) then
--					if(i=23) then
						NS<=NEW_RECIVED_WORD;
						MISO_int<='0';
					elsif(sclk_int='1') then
						MISO_int<=test_out(23-i);
						NS<=WAIT_FALL_EDGE;
					else
						MISO_int<=test_out(23-i);
						NS<=WAIT_NEW_BIT;
					end if;
				when NEW_RECIVED_WORD=>
					MISO_int<=MISO_int; 
					NS<=IDLE;
				when others=>
					MISO_int<=MISO_int; 
					NS<=IDLE;							
				end case;
	end process;

	process(CLK,RST,NSS_int,CS,NS)
	begin	
		if(clk='1' and clk'event) then			
			if(rst='1' OR (NSS_int='1' and  NS/=NEW_RECIVED_WORD) ) then
				CS<=IDLE;	
				i<=0;
				RECIVED_DATA<=(others=>'0');
				WR<='0';
				DATA_OUT<=(others=>'0');
				ADDRESS<=(others=>'0');				
			else
				CS<=NS;
				case CS is
						when IDLE=>				
							i<=0;
							WR<='0';
							DATA_OUT<=(others=>'0');
							ADDRESS<=(others=>'0');
						when NEW_BIT=>
							RECIVED_DATA<=RECIVED_DATA(22 downto 0) & MOSI_INT; --Leemos el dato.
							i<=i+1;
							WR<='0';
						when NEW_RECIVED_WORD=>
							DATA_OUT<=RECIVED_DATA(15 DOWNTO 0);
							ADDRESS<=RECIVED_DATA(23 DOWNTO 16);
							WR<='1';
						when others=>
							WR<='0';
				end case;
			end if;
		
--			if(CS=NEW_BIT) then
--				RECIVED_DATA<=RECIVED_DATA(22 downto 0) & MOSI_INT; --Leemos el dato.
--				i<=i+1;
--				WR<='0';
--			elsif (CS=NEW_RECIVED_WORD) then	--Recibida la palabra, la decodificamos y la sacamos por el bus.
--				DATA_OUT<=RECIVED_DATA(15 DOWNTO 0);
--				ADDRESS<=RECIVED_DATA(23 DOWNTO 16);
--				WR<='1';
--			elsif(CS=IDLE) then
--				i<=0;
--				WR<='0';
--			else
--				WR<='0';
--			end if;

		end if;
	end process;

end Behavioral;

