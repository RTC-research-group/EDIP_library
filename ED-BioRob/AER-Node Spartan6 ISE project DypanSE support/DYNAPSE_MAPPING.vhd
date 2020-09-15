
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity DYNAPSE_MAPPING is
	Port (
			  CLK: in std_logic;
			  RST: in std_logic;
			  REQ: in std_logic;
			  AER: in std_logic_vector (15 downto 0);
			  ACK: out std_logic;
			  SPI_WR: in std_logic;
			  SPI_ADDRESS: in std_logic_vector (7 downto 0);
			  SPI_DATA_OUT: in std_logic_vector (15 downto 0);
			  J1_SP: out std_logic;
			  J1_SN: out std_logic;
			  J2_SP: out std_logic;
			  J2_SN: out std_logic;
			  J3_SP: out std_logic;
			  J3_SN: out std_logic;
			  J4_SP: out std_logic;
			  J4_SN: out std_logic
			);
end DYNAPSE_MAPPING;

architecture Behavioral of DYNAPSE_MAPPING is

type tsm_aer is (idle, J1P, J1N, J2P, J2N, J3P, J3N, J4P, J4N, gack);
signal sm_aer: tsm_aer;

begin

BSMAER: process (clk, rst)
begin
  if (rst='1') then
    sm_aer <= idle;
	 ACK <= '1';
	 J1_SP <= '0'; J1_SN <= '0';
	 J2_SP <= '0'; J2_SN <= '0';
	 J3_SP <= '0'; J3_SN <= '0';
	 J4_SP <= '0'; J4_SN <= '0';
  elsif clk'event and clk='1' then
    case sm_aer is
	   when idle =>
			if (REQ = '0' and AER(9 downto 8) = "00") then
				sm_aer <= J4P;
			elsif (REQ = '0' and AER(9 downto 8) = "01") then
				sm_aer <= J4N;
			end if;

--			if (REQ = '0' and AER(9 downto 4) = "000000") then
--				sm_aer <= J1P;
--			elsif (REQ = '0' and AER(9 downto 4) = "000001") then
--				sm_aer <= J1N;
--			elsif (REQ = '0' and AER(9 downto 4) = "000010") then
--				sm_aer <= J2P;
--			elsif (REQ = '0' and AER(9 downto 4) = "000011") then
--				sm_aer <= J2N;
--			elsif (REQ = '0' and AER(9 downto 4) = "000100") then
--				sm_aer <= J3P;
--			elsif (REQ = '0' and AER(9 downto 4) = "000101") then
--				sm_aer <= J3N;
--			elsif (REQ = '0' and AER(9 downto 4) = "000110") then
--				sm_aer <= J4P;
--			elsif (REQ = '0' and AER(9 downto 4) = "000111") then
--				sm_aer <= J4N;
--		   end if;
		when J1P =>
			J1_SP <= '1';
			ACK <= '0';
		   sm_aer <= gack;
		when J1N =>
			J1_SN <= '1';
			ACK <= '0';
		   sm_aer <= gack;
		when J2P =>
			J2_SP <= '1';
			ACK <= '0';
		   sm_aer <= gack;
		when J2N =>
			J2_SN <= '1';
			ACK <= '0';
		   sm_aer <= gack;
		when J3P =>
			ACK <= '0';
			J3_SP <= '1';
		   sm_aer <= gack;
		when J3N =>
			ACK <= '0';
			J3_SN <= '1';
		   sm_aer <= gack;
		when J4P =>
			J4_SP <= '1';
			ACK <= '0';
		   sm_aer <= gack;
		when J4N =>
			J4_SN <= '1';
			ACK <= '0';
		   sm_aer <= gack;
		when gack => 
		  if REQ = '1' then 
		     sm_aer <= idle;
			  ACK<='1';
		  end if;
		  J1_SP <= '0'; J1_SN <= '0';
		  J2_SP <= '0'; J2_SN <= '0';
		  J3_SP <= '0'; J3_SN <= '0';
		  J4_SP <= '0'; J4_SN <= '0';
	  end case;
	end if;
end process;

end Behavioral;

