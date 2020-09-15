
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity AER_DIF is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
	        SPIKES_IN_U: in STD_LOGIC_VECTOR(1 downto 0);
           SPIKES_IN_Y: in STD_LOGIC_VECTOR(1 downto 0);
			  SPIKES_OUT: out STD_LOGIC_VECTOR(1 downto 0)
);
end AER_DIF;

architecture Behavioral of AER_DIF is
component AER_HOLDER_AND_FIRE is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SET : in  STD_LOGIC;
           HOLD_TIME : in  STD_LOGIC_VECTOR (15 downto 0);
           HOLD_PULSE : out  STD_LOGIC;
			  FIRE_PULSE : out  STD_LOGIC);
end component;
   signal SPIKES_IN: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
	signal SPIKES_IN_TEMP: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
	signal SPIKES_HOLD: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
	signal SPIKES_SET: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
	signal SPIKES_RST: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
	signal SPIKES_FIRE_U: STD_LOGIC_VECTOR(1 downto 0):=(others=>'0');
	signal SPIKES_FIRE_Y: STD_LOGIC_VECTOR(1 downto 0):=(others=>'0');
	signal SPIKES_EXTRAS: STD_LOGIC_VECTOR(1 downto 0):=(others=>'0');
	signal HOLD_TIME_U:  STD_LOGIC_VECTOR(15 downto 0);
	signal HOLD_TIME_Y:  STD_LOGIC_VECTOR(15 downto 0);	
begin

SPIKES_OUT<=SPIKES_FIRE_U OR SPIKES_FIRE_Y OR SPIKES_EXTRAS;

process(clk,rst,wr,address,base_address,data)
begin
	if(clk='1' and clk'event) then
		if(rst='1') then
			HOLD_TIME_U<=(others=>'1');
			HOLD_TIME_Y<=(others=>'1');
--		elsif(WR='1') then
--			if(ADDRESS=BASE_ADDRESS) then
--				HOLD_TIME_U<=DATA;
--			elsif (ADDRESS=BASE_ADDRESS+1) then
--				HOLD_TIME_Y<=DATA; 
--			end if;		
		end if;
	end if;

end process;

SPIKES_IN_TEMP<=SPIKES_IN_U & SPIKES_IN_Y;

WITH SPIKES_IN_TEMP SELECT
	SPIKES_IN<=
		(others=>'0') when b"0011",
		(others=>'0') when b"1100",		
		(others=>'0') when b"0101",
		(others=>'0') when b"1010",
		(others=>'0') when b"1111",		
		b"0100"		  when b"0110",
		b"1000" 		  when b"1001",
		b"1000"		  when b"1011",
		b"0100"		  when b"0111",		
		b"0010"		  when b"1110",		
		b"0001"		  when b"1101",
		SPIKES_IN_TEMP when OTHERS;


--tpo u: 0x0fff - tpo y: 0x0002
u_AER_HOLDER_AND_FIRE_Up:AER_HOLDER_AND_FIRE
	port map (
			  CLK =>clk,
			  RST =>SPIKES_RST(3),
           SET =>SPIKES_SET(3),
           HOLD_TIME =>HOLD_TIME_U,
           HOLD_PULSE =>SPIKES_HOLD(3),
			  FIRE_PULSE =>SPIKES_FIRE_U(1)
	);
	
	u_AER_HOLDER_AND_FIRE_Un:AER_HOLDER_AND_FIRE
	port map (
			  CLK =>clk,
			  RST =>SPIKES_RST(2),
           SET =>SPIKES_SET(2),
           HOLD_TIME =>HOLD_TIME_U,
           HOLD_PULSE =>SPIKES_HOLD(2),
			  FIRE_PULSE =>SPIKES_FIRE_U(0)
	);

	u_AER_HOLDER_AND_FIRE_Yp:AER_HOLDER_AND_FIRE
	port map (
			  CLK =>clk,
			  RST =>SPIKES_RST(1),
           SET =>SPIKES_SET(1),
           HOLD_TIME =>HOLD_TIME_Y,
           HOLD_PULSE =>SPIKES_HOLD(1),
			  FIRE_PULSE =>SPIKES_FIRE_Y(0) --dispara un pulso hacia atr�s
	);
	
	u_AER_HOLDER_AND_FIRE_Yn:AER_HOLDER_AND_FIRE
	port map (
			  CLK =>clk,
			  RST =>SPIKES_RST(0),
           SET =>SPIKES_SET(0),
           HOLD_TIME =>HOLD_TIME_Y,
           HOLD_PULSE =>SPIKES_HOLD(0),
			  FIRE_PULSE =>SPIKES_FIRE_Y(1) --dispara un pulso hacia alante
	);

process(rst,spikes_in,spikes_hold)
begin

		if(rst='1') then
			SPIKES_SET<=(others=>'0');
			SPIKES_RST<=(others=>'1');
			SPIKES_EXTRAS<=(others=>'0');
		else
			case SPIKES_HOLD is
				when b"0000"=>
					SPIKES_SET<=SPIKES_IN;
					SPIKES_RST<=(others=>'0');
               SPIKES_EXTRAS<=(others=>'0');
				when b"1000"=>	--Retenido U+
					case SPIKES_IN is
						when b"0000"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=(others=>'0');
						when b"1000"=>
							SPIKES_SET<=b"1000";
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=b"10";
						when b"0100"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"1000";
							SPIKES_EXTRAS<=(others=>'0');
						when b"0010"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"1000";
							SPIKES_EXTRAS<=(others=>'0');
						when b"0001"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=b"10";
						when others=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=(others=>'0');
					end case;
				when b"0100"=>--Retenido U-
					case SPIKES_IN is
						when b"0000"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=(others=>'0');
						when b"1000"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"0100";
							SPIKES_EXTRAS<=(others=>'0');
						when b"0100"=>
							SPIKES_SET<=b"0100";
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=b"01";
						when b"0010"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=b"01";
						when b"0001"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"0100";	--He tocado aki!!
							SPIKES_EXTRAS<=(others=>'0');
						when others=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');		
							SPIKES_EXTRAS<=(others=>'0');							
						end case;
				when b"0010"=>--Retenido Y+
					case SPIKES_IN is
						when b"0000"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=(others=>'0');
						when b"1000"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"0010";
							SPIKES_EXTRAS<=(others=>'0');
						when b"0100"=>
							SPIKES_SET<=b"0100";
							SPIKES_RST<=b"0010";
							SPIKES_EXTRAS<=b"01";
						when b"0010"=>
							SPIKES_SET<=b"0010";
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=b"01";
						when b"0001"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"0010";
							SPIKES_EXTRAS<=(others=>'0');
						when others=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');		
							SPIKES_EXTRAS<=(others=>'0');		
						end case;							
				when b"0001"=>--Retenido Y-
					case SPIKES_IN is
						when b"0000"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=(others=>'0');
						when b"1000"=>
							SPIKES_SET<=b"1000";
							SPIKES_RST<=b"0001";
							SPIKES_EXTRAS<=b"10";
						when b"0100"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"0001";
							SPIKES_EXTRAS<=b"00";
						when b"0010"=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=b"0001";
							SPIKES_EXTRAS<=b"00";
						when b"0001"=>
							SPIKES_SET<=b"0001";
							SPIKES_RST<=(others=>'0');
							SPIKES_EXTRAS<=b"10";
						when others=>
							SPIKES_SET<=(others=>'0');
							SPIKES_RST<=(others=>'0');		
							SPIKES_EXTRAS<=(others=>'0');		
						end case;							
				when others=>
					SPIKES_SET<=SPIKES_IN;
					SPIKES_RST<=(others=>'0');
               SPIKES_EXTRAS<=(others=>'0');
			end case;
		end if;
end process;

end Behavioral;

