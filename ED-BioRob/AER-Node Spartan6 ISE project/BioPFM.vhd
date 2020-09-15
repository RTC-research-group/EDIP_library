library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity BioPFM is
port(clki:in std_logic;
	reset: in std_logic;
	PFM_out: out std_logic;
	pulse_width: in std_logic_vector(15 downto 0);
	pulse: in std_logic
	);
end BioPFM;

architecture Behavioral of BioPFM is
signal conta: std_logic_vector(15 downto 0):=(others=>'0');
begin

    process (clki,reset, pulse, pulse_width)
    begin
        if(reset='1') then
				conta<=(others=>'0');
		  elsif (pulse='1') then
				conta<=pulse_width;
		  else
			  if(clki='1' and clki'event) then
					if(conta>0) then
						conta<=conta-1;
					else
						conta<=(others=>'0');
					end if;
			  end if;
			end if;
    end process;

    process(conta)
    begin
        if(conta>0) then
            PFM_out<='1';
        else
            PFM_out<='0';
        end if;
    end process;



end Behavioral;


