----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:36:07 06/06/2012 
-- Design Name: 
-- Module Name:    arb4-1 - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arb4_1 is
Port ( clk : in std_logic;
		 reset: in std_logic;
		 AERin1											  : in   std_logic_vector(16 downto 0);
		 reqIN1											  : in   std_logic;
		 ackIN1											  : out  std_logic;
		 AERin2											  : in   std_logic_vector(16 downto 0);
		 reqIN2											  : in   std_logic;
		 ackIN2											  : out  std_logic;
		 AERin3											  : in   std_logic_vector(16 downto 0);
		 reqIN3											  : in   std_logic;
		 ackIN3											  : out  std_logic;
		 AERin4											  : in   std_logic_vector(16 downto 0);
		 reqIN4											  : in   std_logic;
		 ackIN4											  : out  std_logic;
		 AERout											  : out  std_logic_vector(16 downto 0);
		 reqOUT											  : out  std_logic;
		 ackOUT										     : in	std_logic);	 
end arb4_1;

architecture Behavioral of arb4_1 is
component sync
Port ( clk : in  STD_LOGIC;
       reset : in  STD_LOGIC;
       sigIN : in  STD_LOGIC_VECTOR (1 downto 0);
       sigOUT : out  STD_LOGIC_VECTOR (1 downto 0));
end component;
signal REQbus,REQsync: std_logic_vector (3 downto 0);
type tarb is (PAER1,PAER2,PAER3,PAER4,none);
signal st_arb: tarb;
signal lfsr : std_logic_vector (7 downto 0);
begin
--REQbus <= reqIN1 & reqIN2 & reqIN3 & reqIN4;
REQsync <= reqIN1 & reqIN2 & reqIN3 & reqIN4;

--sync1 : sync
--Port Map( clk => clk,
--			 reset => reset,
--			 sigIN => REQbus(3 downto 2),
--			 sigOUT => REQsync(3 downto 2));
--sync2 : sync
--Port Map( clk => clk,
--			 reset => reset,
--			 sigIN => REQbus(1 downto 0),
--			 sigOUT => REQsync(1 downto 0));

PARB: process (reset, clk)
begin
  if (reset ='1' ) then
   st_arb <= none;
	REQout <= '1';
	AERout <= (others =>'0');
	lfsr <= x"AA";
  elsif clk'event and clk='1' then
	case st_arb is
	   when none =>    
		  case REQsync is
          when "0000" => 
			    case lfsr(1 downto 0) is
				   when "00" => REQout <= REQsync(3);
							AERout <=  AERin1;
							st_arb <= PAER1;
					when "01" => REQout <= REQsync(2);
							AERout <=  AERin2;
							st_arb <= PAER2;
					when "10" => REQout <= REQsync(1);
							AERout <=  AERin3;
							st_arb <= PAER3;
					when others => REQout <= REQsync(0);
							AERout <= AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "0001" =>
			    case lfsr(1 downto 0) is
				   when "00" => REQout <= REQsync(3);
							AERout <=  AERin1;
							st_arb <= PAER1;
					when "01" => REQout <= REQsync(2);
							AERout <=  AERin2;
							st_arb <= PAER2;
					when "10" => REQout <= REQsync(1);
							AERout <=  AERin3;
							st_arb <= PAER3;
					when others => REQout <= REQsync(1);
							AERout <=  AERin3;
							st_arb <= PAER3;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "0010" =>
			    case lfsr(1 downto 0) is
				   when "00" => REQout <= REQsync(3);
							AERout <=  AERin1;
							st_arb <= PAER1;
					when "01" => REQout <= REQsync(2);
							AERout <=  AERin2;
							st_arb <= PAER2;
					when "10" => REQout <= REQsync(2);
							AERout <=  AERin2;
							st_arb <= PAER2;
					when others => REQout <= REQsync(0);
							AERout <=  AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "0011" =>
			    case lfsr(0) is
				   when '0' => REQout <= REQsync(3);
							AERout <=  AERin1;
							st_arb <= PAER1;
					when others => REQout <= REQsync(2);
							AERout <=  AERin2;
							st_arb <= PAER2;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "0100" =>
			    case lfsr(1 downto 0) is
				   when "00" => REQout <= REQsync(3);
							AERout <=  AERin1;
							st_arb <= PAER1;
					when "01" => REQout <= REQsync(3);
							AERout <=  AERin1;
							st_arb <= PAER1;
					when "10" => REQout <= REQsync(1);
							AERout <=  AERin3;
							st_arb <= PAER3;
					when others => REQout <= REQsync(0);
							AERout <=  AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "0101" =>
			    case lfsr(0) is
				   when '0' => REQout <= REQsync(3);
							AERout <= AERin1;
							st_arb <= PAER1;
					when others => REQout <= REQsync(1);
							AERout <= AERin3;
							st_arb <= PAER3;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "0110" =>
			    case lfsr(0) is
				   when '0' => REQout <= REQsync(3);
							AERout <= AERin1;
							st_arb <= PAER1;
					when others => REQout <= REQsync(0);
							AERout <= AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
	       when "0111" => REQout <= REQsync(3);
							AERout <= AERin1;
							st_arb <= PAER1;
          when "1000" =>
			    case lfsr(1 downto 0) is
				   when "00" => REQout <= REQsync(2);
							AERout <= AERin2;
							st_arb <= PAER2;
					when "01" => REQout <= REQsync(2);
							AERout <= AERin2;
							st_arb <= PAER2;
					when "10" => REQout <= REQsync(1);
							AERout <= AERin3;
							st_arb <= PAER3;
					when others => REQout <= REQsync(0);
							AERout <= AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "1001" =>
			    case lfsr(0) is
					when '0' => REQout <= REQsync(2);
							AERout <= AERin2;
							st_arb <= PAER2;
					when others => REQout <= REQsync(1);
							AERout <= AERin3;
							st_arb <= PAER3;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
          when "1010" =>
			    case lfsr(0) is
					when '0' => REQout <= REQsync(2);
							AERout <= AERin2;
							st_arb <= PAER2;
					when others => REQout <= REQsync(0);
							AERout <= AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
	       when "1011" => REQout <= REQsync(2);
							AERout <= AERin2;
							st_arb <= PAER2;
          when "1100" =>
			    case lfsr(0) is
					when '0' => REQout <= REQsync(1);
							AERout <= AERin3;
							st_arb <= PAER3;
					when others => REQout <= REQsync(0);
							AERout <= AERin4;
							st_arb <= PAER4;
				end case;
				lfsr <= lfsr (6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
	       when "1101" => REQout <= REQsync(1);
							AERout <= AERin3;
							st_arb <= PAER3;
	       when "1110" => REQout <= REQsync(0);
							AERout <= AERin4;
							st_arb <= PAER4;
		    when others => null;
	     end case;
	   when PAER1 => if (REQsync(3)='1' or (REQsync(2) and REQsync(1) and REQsync(0))='0') then st_arb <= none; REQout <= '1'; end if;
	   when PAER2 => if (REQsync(2)='1' or (REQsync(3) and REQsync(1) and REQsync(0))='0') then st_arb <= none; REQout <= '1'; end if;
	   when PAER3 => if (REQsync(1)='1' or (REQsync(2) and REQsync(3) and REQsync(0))='0') then st_arb <= none; REQout <= '1'; end if;
	   when PAER4 => if (REQsync(0)='1' or (REQsync(2) and REQsync(1) and REQsync(3))='0') then st_arb <= none; REQout <= '1'; end if;
		when others => null;
	end case;
  end if;
end process;

PARB_ACK: process (st_arb,ACKout)
begin
--   if (ACKout = '0') then
	   case st_arb is
		  when PAER1 => ackIN1 <= ACKout; ackIN2 <= '1'; ackIN3 <= '1'; ackIN4 <= '1'; 
		  when PAER2 => ackIN2 <= ACKout; ackIN1 <= '1'; ackIN3 <= '1'; ackIN4 <= '1'; 
		  when PAER3 => ackIN3 <= ACKout; ackIN1 <= '1'; ackIN2 <= '1'; ackIN4 <= '1'; 
		  when PAER4 => ackIN4 <= ACKout; ackIN1 <= '1'; ackIN2 <= '1'; ackIN3 <= '1'; 
		  when none  => ackIN1 <= '1'; ackIN2 <= '1'; ackIN3 <= '1'; ackIN4 <= '1'; 
		end case;
--	else ACKin1 <= '1'; ACKin2 <= '1'; ACKin3 <= '1'; ACKin4 <= '1'; 
--	end if;
end process;

end Behavioral;