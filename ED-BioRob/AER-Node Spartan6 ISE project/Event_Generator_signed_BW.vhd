library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Event_Generator_signed_BW is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           SPIKE : out  STD_LOGIC_VECTOR(1 downto 0));
end Event_Generator_signed_BW;

architecture Behavioral of Event_Generator_signed_BW is
signal ciclo: STD_LOGIC_VECTOR (14 downto 0):=(others=>'0');	--TOCAR AQUI
signal ciclo_wise: STD_LOGIC_VECTOR (14 downto 0):=(others=>'0') ;
signal pulse: STD_LOGIC:='0';
signal pulse_p: STD_LOGIC:='0';
signal pulse_n: STD_LOGIC:='0';
signal DATA_IN: STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal data_temp: STD_LOGIC_VECTOR (15 downto 0):=(others=>'0') ;

signal CE: STD_LOGIC:='0';
begin

process(clk,rst,wr,address,base_address,data,ciclo)
begin
	if(clk='1' and clk'event) then
		if(rst='1') then
			DATA_IN<=x"0000";
		elsif((ADDRESS=BASE_ADDRESS) and WR='1') then
			DATA_IN<=DATA;
		end if;
	end if;

for i in 0 to 14 loop
	ciclo_wise(14-i)<=ciclo(i);
end loop;
end process;


spike(1)<=pulse_p;
spike(0)<=pulse_n;



data_temp<=conv_std_logic_vector(abs(signed(data_in)),16);

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

--				if (CE='1' and ((conv_integer(ciclo)*conv_integer (data_temp)) mod 32768) < conv_integer(data_temp)) then
				if (CE='1' and (conv_integer(data_temp) > conv_integer(ciclo_wise) )) then
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

--process(rst,ciclo,data_temp)
--begin
--
--	if(rst='1') then
--		pulse<='0';
--	else
--		if ((conv_integer(ciclo)*conv_integer (data_temp)) mod 32768) < conv_integer(data_temp) then
--			pulse<='1';
--		else
--			pulse<='0';
--		end if;
--	end if;
--	
--	
--end process;

end Behavioral;

