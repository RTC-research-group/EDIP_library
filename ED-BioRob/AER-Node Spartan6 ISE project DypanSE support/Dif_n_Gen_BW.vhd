----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:36:20 05/25/2009 
-- Design Name: 
-- Module Name:    Dif_n_Gen - Behavioral 
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

entity Dif_n_Gen_BW is
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
end Dif_n_Gen_BW;

architecture Behavioral of Dif_n_Gen_BW is

	component AER_DIF is
		 Port (  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
           SPIKES_IN_U: in STD_LOGIC_VECTOR(1 downto 0);
           SPIKES_IN_Y: in STD_LOGIC_VECTOR(1 downto 0);
			  SPIKES_OUT: out STD_LOGIC_VECTOR(1 downto 0));
	end component;


	component Int_n_Gen_BW is
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
	
	signal int_spikes_p: STD_LOGIC :='0';
	signal int_spikes_n: STD_LOGIC :='0';
	signal spikes_out_tmp_p: STD_LOGIC :='0';
	signal spikes_out_tmp_n: STD_LOGIC :='0';
begin
spike_out_p<=spikes_out_tmp_p;
spike_out_n<=spikes_out_tmp_n;

	U_DIF:AER_DIF
	port map (
			  CLK =>clk,
			  RST =>RST,
			  BASE_ADDRESS=>x"FF",
			  ADDRESS=>ADDRESS ,
			  DATA=>DATA, 
			  WR=>WR, 
           SPIKES_IN_U(1)=>spike_in_p,
			  SPIKES_IN_U(0)=>spike_in_n,
           SPIKES_IN_Y(1)=>int_spikes_p, 
			  SPIKES_IN_Y(0)=>int_spikes_n, 
			  SPIKES_OUT(1)=>spikes_out_tmp_p,
			  SPIKES_OUT(0)=>spikes_out_tmp_n
			  );			  

			
	U_INT: Int_n_Gen_BW 
		Generic map(GL=>GL,SAT=>SAT)
		 Port map( CLK =>clk,
				  RST =>rst,
				  BASE_ADDRESS=>BASE_ADDRESS,
			     ADDRESS=>ADDRESS,
			     DATA=>DATA, 
			     WR=>WR, 
				  spike_in_p =>spikes_out_tmp_p,
				  spike_in_n =>spikes_out_tmp_n,
				  spike_out_p =>int_spikes_p,
				  spike_out_n =>int_spikes_n);

end Behavioral;

