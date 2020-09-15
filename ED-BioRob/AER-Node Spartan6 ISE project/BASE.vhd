----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:57:38 03/29/2012 
-- Design Name: 
-- Module Name:    AER_Robot_2 - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BASE is
  generic (BASE_ADD: std_logic_vector (7 downto 0) := x"F0");
  port( rstz: in std_logic;
        clk50: in std_logic;
		  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
		  DATA: in STD_LOGIC_VECTOR(15 downto 0);
		  WR: in STD_LOGIC;
		  MU: out std_logic_vector (1 to 3)
     );
end BASE;

architecture Behavioral of BASE is
signal cnt: std_logic_vector (19 downto 0);
signal c: integer range 0 to 2:=0;
signal csig: integer range 0 to 2:=0;
signal sal1: std_logic:='0';
signal sal2: std_logic:='0';
signal sal3: std_logic:='0';
signal RL, GO: std_logic:='0';
signal FCR,FCL,fc: std_logic:='0';
begin

BCTL: process (clk50, rstz)
begin
  if rstz='1' then
    RL<='0';
	 GO<='0';
	 FCR<='0';
	 FCL<='0';
  elsif clk50'event and clk50='1' then
    if ADDRESS=BASE_ADD then
	    RL <= DATA(15);
		 GO <= DATA(14);
		 FCR <= DATA(13);
		 FCL <= DATA(12);
	 end if;
  end if;
end process;

fc <= '1' when (RL='0' and FCR='1') else
      '1' when (RL='1' and FCL='1') else 
		'0';
		
CLK_DIV: process (clk50,rstz)
  begin
	 if rstz='1' then
		cnt <= (others =>'0');
	 elsif clk50'event and clk50='1' then
	  if (GO='1' and fc='0') then
		cnt <= cnt + 1;
		if cnt = b"11111111111111111111" then
			c <=csig;			
		end if;
	  end if;
    end if;
  end process;
  
  MU(1) <= sal1;
  MU(2) <= sal2;
  MU(3) <= sal3;
  
 maq: process (c)
 begin
 case c is
	when 0=>
		sal1 <='1';
		sal2 <='0';
		sal3 <='0';
		if (RL='0') then csig <= 1;
		else csig <= 2;
		end if;
	when 1=>
		sal1 <='0';
		sal2 <='1';
		sal3 <='0';
		if (RL='0') then csig <= 2;
		else csig <= 0;
		end if;
	when 2=>
		sal1 <='0';
		sal2 <='0';
		sal3 <='1';
		if (RL='0') then csig <= 0;
		else csig <= 1;
		end if;
 end case;
 end process;
end Behavioral;