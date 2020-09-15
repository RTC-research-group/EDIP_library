----------------------------------------------------------------------------------
-- Company: 	 	 USE - CITEC
-- Engineer: 		 Alejandro Linares Barranco
-- 
-- Create Date:    17:58:05 09/24/2018 
-- Design Name: 
-- Module Name:    SPI_MASTER_16bits - Behavioral 
-- Project Name:   BIOROB spike based control
-- Target Devices: 
-- Tool versions: 
-- Description:    this block will continuosly read the joint position sensor that is a spi-slave device.
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

entity SPI_MASTER_16bits is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           NSS : out  STD_LOGIC;
           MISO : in  STD_LOGIC;
           DATA : out  STD_LOGIC_VECTOR (15 downto 0);
           DR : out  STD_LOGIC);
end SPI_MASTER_16bits;

architecture Behavioral of SPI_MASTER_16bits is
	signal cnt: integer range 0 to 127;
	signal isck: std_logic;
	type tsm is (idle, read_miso, send_data);
	signal current_state, next_state: tsm;
	signal nbits: integer range 0 to 16;
	signal idata: std_logic_vector (15 downto 0);
	signal miso_read: std_logic;
begin

process (clk, rst)
begin
-- clk is supposed to be 50MHz and SCK  below 3MHz
-- so lets count 20 per SCK clock period, so 10 per edge.
	if (clk'event and clk='1') then
		if (rst = '0') then
			cnt <= 0;
			isck <= '0';
			miso_read <= '0';
		else
			cnt <= cnt +1;
			miso_read <= '0';
			if (cnt >=100) then
				cnt <= 0;
				isck <= not isck;
				if (isck = '0') then
					miso_read <= '1';
				end if;
			end if;
		end if;
   end if;
end process;

process (current_state, nbits)
begin
	next_state <= current_state;
	case (current_state) is
		when idle =>
			next_state <= read_miso;
		when read_miso =>
		   if (nbits >= 16) then
			   next_state <= send_data;
		   end if;
	   when send_data =>
		   next_state <= idle;
	end case;
end process;

NSS <= '0' when (current_state = read_miso) else '1';
SCK <= isck when (current_state = read_miso) else '1';

process (clk, rst) 
begin
	if (clk'event and clk='1') then
		if (rst = '0') then
			nbits <= 0;
			idata <= (others => '0');
			DR <= '0';
			DATA <= (others => '0');
		else
			current_state <= next_state;
			case (current_state) is
				when idle => 
					DR <= '0';
				when read_miso => 
					if (miso_read = '1') then
						idata (15 downto 1) <= idata (14 downto 0);
						idata (0) <= MISO;
						nbits <= nbits +1;
					end if;
				when send_data =>
					nbits <= 0;
					DR <= '1';
					DATA <= idata;
			end case;
		end if;
   end if;
end process;
			
end Behavioral;

