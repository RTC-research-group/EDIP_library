library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity BiDirPFM is
    Port ( 	CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  BASE_ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  ADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
			  DATA: in STD_LOGIC_VECTOR(15 downto 0);
			  WR: in STD_LOGIC;
				PULSE : in  STD_LOGIC_VECTOR (1 downto 0);
				PFM_out: out  STD_LOGIC_VECTOR (1 downto 0));
end BiDirPFM;

architecture Behavioral of BiDirPFM is

	component BioPFM is
	port
	(clki:in std_logic;
	reset: in std_logic;
	PFM_out: out std_logic;
	pulse_width: in std_logic_vector(15 downto 0);
	pulse: in std_logic
	);
	end component;

signal PFM_out_tmp_p,PFM_out_tmp_n: STD_LOGIC:='0';
signal pulse_tmp_p,pulse_tmp_n: STD_LOGIC:='0';
signal reset_p, reset_n: STD_LOGIC:='0';
signal pulse_width: STD_LOGIC_VECTOR (15 downto 0):=(others=>'0');
begin
	
process(clk,rst,wr,address,base_address,data)
begin
	if(clk='1' and clk'event) then
		if(rst='1') then
			pulse_width<=x"0300";
		elsif(WR='1'and ADDRESS=BASE_ADDRESS) then
				pulse_width<=DATA;
		end if;
	end if;

end process;	
	
	PFM_out<=PFM_out_tmp_p & PFM_out_tmp_n;

   U_PFM_P : BioPFM                              
      Port Map
      (clk,reset_p,PFM_out_tmp_p,pulse_width, pulse_tmp_p);

   U_PFM_N : BioPFM                              
      Port Map
      (clk,reset_n,PFM_out_tmp_n,pulse_width, pulse_tmp_n);

process(clk,rst,pulse,PFM_out_tmp_p,PFM_out_tmp_n)
begin
    if (clk='1' and clk'event) then
		 if(rst='1') then
			  reset_p<='1';
			  reset_n<='1';
			  pulse_tmp_n<='0';
			  pulse_tmp_p<='0';		  
        elsif(PFM_out_tmp_p='1' and pulse(0)='1') then
				reset_p<='1';
				reset_n<='0';
				pulse_tmp_n<='0';
				pulse_tmp_p<='0';
		  elsif(PFM_out_tmp_n='1' and pulse(1)='1') then 
				reset_n<='1';
				reset_p<='0';
				pulse_tmp_n<='0';
				pulse_tmp_p<='0';				
		  else
				reset_n<='0';
				reset_p<='0';
				pulse_tmp_n<=pulse(0);
				pulse_tmp_p<=pulse(1);				
    	  end if;
    end if;

end process;


end Behavioral;

