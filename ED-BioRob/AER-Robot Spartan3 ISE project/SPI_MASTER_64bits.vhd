----------------------------------------------------------------------------------
-- Company: 	 	 USE - CITEC
-- Engineer: 		 Alejandro Linares Barranco
-- 
-- Create Date:    11:34:05 09/11/2019 
-- Design Name: 
-- Module Name:    SPI_MASTER_64bits - Behavioral 
-- Project Name:   BIOROB spike based control
-- Target Devices: 
-- Tool versions: 
-- Description:    this block will send and read data from the joint position MELEXIS sensor that is a spi-slave device.
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

entity SPI_MASTER_64bits is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           NSS : out  STD_LOGIC;
           MISO : in  STD_LOGIC;
			  MOSI : out STD_LOGIC;
			  DATA_I : in STD_LOGIC_VECTOR (63 downto 0);
			  DR_I: in STD_LOGIC;
           DATA_O : out  STD_LOGIC_VECTOR (15 downto 0); -- byte1 byte0
			  DATA_ROLL_O: out STD_LOGIC_VECTOR (7 downto 0);
           DR_O : out  STD_LOGIC);
end SPI_MASTER_64bits;

architecture Behavioral of SPI_MASTER_64bits is
	signal cnt: integer range 0 to 127;
	signal isck: std_logic;
	type tsm is (idle, pulse_sync, pulse_sync_end, wait_read_miso, read_miso, send_data);
	signal current_state, next_state: tsm;
	signal nbits: integer range 0 to 64;
	signal idatai, idata: std_logic_vector (63 downto 0);
	signal miso_read, mosi_write: std_logic;
	
	attribute keep : string; 
	attribute keep of DATA_ROLL_O: signal is "true"; 

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
			mosi_write <= '0';
		elsif (current_state /= idle) then
			cnt <= cnt +1;
			miso_read <= '0';
			mosi_write <= '0';
			if (cnt >=100) then
				cnt <= 0;
				isck <= not isck;
				if (isck = '0') then
					miso_read <= '1';
				elsif (isck = '1') then
				   mosi_write <= '1';
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
		   if (DR_I='1') then
				next_state <= wait_read_miso;
			end if;
--		when pulse_sync =>
--		   if (miso_read = '1') then
--			   next_state <= pulse_sync_end;
--			end if;
--		when pulse_sync_end =>
--		   if (miso_read = '1') then
--				next_state <= wait_read_miso;
--			end if;
		when wait_read_miso =>
			next_state <= read_miso;
		when read_miso =>
		   if (nbits >= 64) then
			   next_state <= send_data;
		   end if;
	   when send_data =>
		   next_state <= idle;
			when others => null;
	end case;
end process;

NSS <= '0' when (current_state = read_miso or current_state = pulse_sync) else '1';
SCK <= isck when (current_state = read_miso) else '1';

process (clk, rst) 
begin
	if (clk'event and clk='1') then
		if (rst = '0') then
			nbits <= 0;
			idata <= (others => '0');
			idatai <= (others => '0');
			DR_O <= '0';
			DATA_O <= (others => '0');
			DATA_ROLL_O<=(others=>'1');
			MOSI <= '0';
		else
			current_state <= next_state;
			case (current_state) is
				when idle => 
					DR_O <= '0';
				when wait_read_miso => idatai <= DATA_I;
				when read_miso => 
					if (miso_read = '1') then
						idata (63 downto 1) <= idata (62 downto 0);
						idata (0) <= MISO;
					elsif (mosi_write = '1') then
					   MOSI <= idatai(63);
						idatai <= idatai(62 downto 0) & '0';
						nbits <= nbits +1;
					end if;
				when send_data =>
					nbits <= 0;
					DR_O <= '1';
					DATA_O <= idata(55 downto 48) & idata(63 downto 56);
								DATA_ROLL_O<=idata(15 downto 8);
				when others => null;
			end case;
		end if;
   end if;
end process;
			
end Behavioral;

