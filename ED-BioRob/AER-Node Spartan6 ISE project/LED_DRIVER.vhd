
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity LED_DRIVER is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           LEDS : out  STD_LOGIC_VECTOR (3 downto 0));
end LED_DRIVER;

architecture Behavioral of LED_DRIVER is

signal LEDS_temp : STD_LOGIC_VECTOR (3 downto 0):=b"0000";

begin
	
	LEDS<=LEDS_temp;

	process(clk,rst,wr,address,base_address)
	begin
	if(clk='1' and clk'event) then
		if(rst='1') then
			LEDS_temp<=b"1110";
		elsif(ADDRESS=BASE_ADDRESS and WR='1') then
			LEDS_temp<=DATA(3 downto 0);
		end if;
	end if;
	

	end process;


end Behavioral;

