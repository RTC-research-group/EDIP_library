----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:04:27 11/18/2009 
-- Design Name: 
-- Module Name:    Bank_Int_n_Gen_BW - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bank_Dif_n_Gen_BW is
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  DATA: in STD_LOGIC_VECTOR(15 downto 0);
				  WR: in STD_LOGIC;
				  spike_in_p : in  STD_LOGIC;
				  spike_in_n : in  STD_LOGIC;
				  spike_out_p : out  STD_LOGIC;
				  spike_out_n : out  STD_LOGIC);
	
end Bank_Dif_n_Gen_BW;

architecture Behavioral of Bank_Dif_n_Gen_BW is


	component Dif_n_Gen_BW is
		generic (GL: in integer:=8; SAT: in integer:=127);
		 Port ( CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
				  DATA: in STD_LOGIC_VECTOR(15 downto 0);
				  WR: in STD_LOGIC;
				  spike_in_p : in  STD_LOGIC;
				  spike_in_n : in  STD_LOGIC;
				  spike_out_p : out  STD_LOGIC;
				  spike_out_n : out  STD_LOGIC);
	end component;
	
signal bank_sel: STD_LOGIC_VECTOR (2 downto 0);

signal rst_16: STD_LOGIC;
signal rst_18: STD_LOGIC;
signal rst_20: STD_LOGIC;
signal rst_22: STD_LOGIC;

signal spike_out_16: STD_LOGIC_VECTOR (1 downto 0);
signal spike_out_18: STD_LOGIC_VECTOR (1 downto 0);
signal spike_out_20: STD_LOGIC_VECTOR (1 downto 0);
signal spike_out_22: STD_LOGIC_VECTOR (1 downto 0);
signal BASE_ADDRESS_16: STD_LOGIC_VECTOR(7 downto 0);
signal BASE_ADDRESS_18: STD_LOGIC_VECTOR(7 downto 0);
signal BASE_ADDRESS_20: STD_LOGIC_VECTOR(7 downto 0);
signal BASE_ADDRESS_22: STD_LOGIC_VECTOR(7 downto 0);

begin


spike_out_p<=spike_out_16(1) or spike_out_18(1) or spike_out_20(1) or spike_out_22(1);
spike_out_n<=spike_out_16(0) or spike_out_18(0) or spike_out_20(0) or spike_out_22(0);


process(clk,rst,wr,address,base_address,data,bank_sel)
begin
	if(clk='1' and clk'event) then
		if(rst='1') then
			bank_sel<=b"111";
		elsif(ADDRESS=BASE_ADDRESS and WR='1') then
			bank_sel<=DATA(2 downto 0);
		end if;
	end if;

case bank_sel is
	when b"000"=>
		rst_16<='0';
		rst_18<='1';
		rst_20<='1';
		rst_22<='1';
	when b"001"=>
		rst_16<='1';
		rst_18<='0';
		rst_20<='1';
		rst_22<='1';
	when b"010"=>
		rst_16<='1';
		rst_18<='1';
		rst_20<='0';
		rst_22<='1';
	when b"011"=>
		rst_16<='1';
		rst_18<='1';
		rst_20<='1';
		rst_22<='0';		
	when others=>		
		rst_16<='1';
		rst_18<='1';
		rst_20<='1';
		rst_22<='1';		
end case;

end process;

BASE_ADDRESS_16<=BASE_ADDRESS+1;
BASE_ADDRESS_18<=BASE_ADDRESS+2;
BASE_ADDRESS_20<=BASE_ADDRESS+3;
BASE_ADDRESS_22<=BASE_ADDRESS+4;

U_Int_n_Gen_16: Dif_n_Gen_BW 
		Generic map(GL=>16,SAT=>32535)
		 Port map( CLK =>clk,
				  RST =>rst_16,
				  BASE_ADDRESS=>BASE_ADDRESS_16,
			     ADDRESS=>ADDRESS,
			     DATA=>DATA, 
			     WR=>WR, 
				  spike_in_p =>spike_in_p,
				  spike_in_n =>spike_in_n,
				  spike_out_p =>spike_out_16(1),
				  spike_out_n =>spike_out_16(0));
				        
U_Int_n_Gen_18: Dif_n_Gen_BW 
		Generic map(GL=>18,SAT=>131071)
		 Port map( CLK =>clk,
				  RST =>rst_18,
				  BASE_ADDRESS=>BASE_ADDRESS_18,
			     ADDRESS=>ADDRESS,
			     DATA=>DATA, 
			     WR=>WR, 
				  spike_in_p =>spike_in_p,
				  spike_in_n =>spike_in_n,
				  spike_out_p =>spike_out_18(1),
				  spike_out_n =>spike_out_18(0));

     
U_Int_n_Gen_20: Dif_n_Gen_BW 
		Generic map(GL=>20,SAT=>524287)
		 Port map( CLK =>clk,
				  RST =>rst_20,
				  BASE_ADDRESS=>BASE_ADDRESS_20,
			     ADDRESS=>ADDRESS,
			     DATA=>DATA, 
			     WR=>WR, 
				  spike_in_p =>spike_in_p,
				  spike_in_n =>spike_in_n,
				  spike_out_p =>spike_out_20(1),
				  spike_out_n =>spike_out_20(0));

U_Int_n_Gen_22: Dif_n_Gen_BW 
		Generic map(GL=>22,SAT=>2097151)
		 Port map( CLK =>clk,
				  RST =>rst_22,
				  BASE_ADDRESS=>BASE_ADDRESS_22,
			     ADDRESS=>ADDRESS,
			     DATA=>DATA, 
			     WR=>WR, 
				  spike_in_p =>spike_in_p,
				  spike_in_n =>spike_in_n,
				  spike_out_p =>spike_out_22(1),
				  spike_out_n =>spike_out_22(0));

end Behavioral;
