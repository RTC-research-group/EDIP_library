
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity VISION_MAPPING is
	Port (
			  CLK: in std_logic;
			  RST: in std_logic;
			  REQ: in std_logic;
			  AER: in std_logic_vector (15 downto 0);
			  ACK: out std_logic;
			  SPI_WR: in std_logic;
			  SPI_ADDRESS: in std_logic_vector (7 downto 0);
			  SPI_DATA_OUT: in std_logic_vector (15 downto 0);
			  WR:  out std_logic;
			  ADDRESS: out std_logic_vector (7 downto 0);
			  DATA_OUT: out std_logic_vector (15 downto 0)
			);
end VISION_MAPPING;

architecture Behavioral of VISION_MAPPING is

type tsm_aer is (idle, XR, XRw, XL, XLw, YR, YRw, YL, YLw, gack);
signal sm_aer: tsm_aer;

begin

BSMAER: process (clk, rst)
begin
  if (rst='1') then
    sm_aer <= idle;
	 ACK <= '1';
	 WR <= '0';
	 ADDRESS <= (others =>'1');
	 DATA_OUT <= (others => '0');
  elsif clk'event and clk='1' then
    case sm_aer is
	   when idle =>
		  if (SPI_WR = '1') then
		    WR <= '1';
			 ADDRESS <= SPI_ADDRESS;
			 DATA_OUT <= SPI_DATA_OUT;
		  else
		    if (REQ = '0') then
		       sm_aer <=XR;
		    end if;
		    WR <= '0';
		  end if;
		when XR =>
		  WR <= '1';
		  ADDRESS <= x"01";
		  if (AER(6 downto 0) < 64 ) then
				DATA_OUT <= "00" & ("111111"-AER(5 downto 0)) & x"00";
		  else		      
				DATA_OUT <= "11" & ("111111"-AER(5 downto 0)) & x"00";
		  end if;
		  sm_aer <= XRw;
		when XRw =>
		  WR <= '0';
		  sm_aer <= XL;
		when XL =>
		  WR <= '1';
		  ADDRESS <= x"02";
		  if (AER(6 downto 0) < 64 ) then
				DATA_OUT <= "00" & ("111111"-AER(5 downto 0)) & x"00";
		  else		      
				DATA_OUT <= "11" & ("111111"-AER(5 downto 0)) & x"00";
		  end if;
		  sm_aer <= XLw;
		when XLw =>
		  WR <= '0';
		  sm_aer <= YR;
		when YR =>
		  WR <= '1';
		  ADDRESS <= x"81";
		  if (AER(14 downto 8) <= 64 ) then 
				DATA_OUT <= '0' & ("1000000"-AER(14 downto 8)) & x"00";
		  else		      
				DATA_OUT <= '1' & ("1000000"-AER(14 downto 8)) & x"00";
		  end if;
		  sm_aer <= YRw;
		when YRw =>
		  WR <= '0';
		  sm_aer <= YL;
		when YL =>
		  WR <= '1';
		  ADDRESS <= x"82";
		  if (AER(14 downto 8) <= 64 ) then
				DATA_OUT <= '0' & ("1000000"-AER(14 downto 8)) & x"00";
		  else		      
				DATA_OUT <= '1' & ("1000000"-AER(14 downto 8)) & x"00";
		  end if;
		  sm_aer <= YLw;
		when YLw =>
		  WR <= '0';
		  ACK <= '0';
		  sm_aer <= gack;
		when gack => 
		  if REQ = '1' then 
		     sm_aer <= idle;
			  ACK<='1';
		  end if;
	  end case;
	end if;
end process;

end Behavioral;

