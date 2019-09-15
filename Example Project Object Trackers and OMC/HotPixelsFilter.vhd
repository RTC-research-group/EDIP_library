----------------------------------------------------------------------------------
-- Company: University of Seville & INI
-- Engineer: Alejandro Linares & Paco Gomez
-- 
-- Create Date:    18:56:31 01/05/2014 
-- Design Name: 
-- Module Name:    Background Activity Filter - Behavioral 
-- Project Name:   VISUALIZE
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity HotPixelsFilter is
    Generic (
		BASEADDRESS : std_logic_vector (7 downto 0) := (others => '0')
		  );
    Port (
	 	aer_in_data : in std_logic_vector(16 downto 0);
      aer_in_req_l : in std_logic;
      aer_in_ack_l : out std_logic;
		aer_out_data : out std_logic_vector(16 downto 0);
      aer_out_req_l : out std_logic;
      aer_out_ack_l : in std_logic;
      rst_l : in std_logic;
      clk50 : in std_logic;
		alex: out std_logic_vector (2 downto 0);
		spiWR: in STD_LOGIC;
		spiADDRESS: in STD_LOGIC_VECTOR(7 downto 0);
		spiDATA: in STD_LOGIC_VECTOR(7 downto 0));
end HotPixelsFilter;

architecture Behavioral of HotPixelsFilter is

  type estados is (IDLE, READ_ARRAY, READ_ARRAYb, SEND, FILTER, LEARN_WAIT, LEARN_COUNT, LEARN_ACK, LEARN_WR_ARRAY, MATRIX_PX_RST);
  signal CS, NS: estados;

  constant NPIXS : integer := 65536;
  constant COLS : integer := 240;
  constant ROWS : integer := 180;
  constant RESMAX: integer := 5; -- 32 eventos en el tiempo de aprendizaje.
  --constant LEARNING_TIME: integer := 1200000; -- 20ms at 60MHz FCLK
  --constant NUMEV_HP: integer := 5;
  
  type tarray_hpf is array (NPIXS-1 downto 0) of std_logic;
  signal array_hpf : tarray_hpf;
  type tram_hpf is array (NPIXS-1 downto 0) of unsigned (RESMAX-1 downto 0);
  signal rc, matrix_do, matrix_di: unsigned (RESMAX-1 downto 0);
  signal matrix_hpf: tram_hpf;
  signal learning_timer, learning_time: unsigned (31 downto 0);
  signal cnt_col, cnt_row: unsigned (7 downto 0);
  signal learning, fin_learning : std_logic;
  signal laer_data: std_logic_vector (16 downto 0);
  signal matrix_dir, array_dir: unsigned (15 downto 0);
  signal array_do, array_di, matrix_we, array_we: std_logic;
  signal numev_hp: unsigned(7 downto 0);
  signal filter_polarity: std_logic;
  signal taer_in_data: std_logic_vector (16 downto 0);
  
begin
aer_out_data <= laer_data;


process (aer_in_data)
begin
if     (aer_in_data = "0" & "1000000" & "0" & "1000000" & "0") then -- Center y 64 x 64 = 1000000 1000000 (OMC5) Red
	taer_in_data <= "0" & "1000001" & "0" & "1000000" & "0";
elsif  (aer_in_data = "0" & "0100000" & "0" & "0100000" & "0") then -- Bottom Left y 32 x 32 = 0100000 0100000 (OMC1) Green
	taer_in_data <= "0" & "0100001" & "0" & "0100000" & "0";
elsif  (aer_in_data = "0" & "0100000" & "0" & "1100000" & "0") then -- Bottom Right y 32 x 96 = 0100000 1100000 (OMC3) Blue
	taer_in_data <= "0" & "0100001" & "0" & "1100000" & "0";
elsif  (aer_in_data = "0" & "1100000" & "0" & "0100000" & "0") then -- Top Left y 96 x 32 = 1100000 0100000 (OMC2) Violet
	taer_in_data <= "0" & "1100001" & "0" & "0100000" & "0";
elsif  (aer_in_data = "0" & "1100000" & "0" & "1100000" & "0") then -- Top Right y 96 x 96 = 1100000 1100000 (OMC4) Light Blue
	taer_in_data <= "0" & "1100001" & "0" & "1100000" & "0";
elsif  (aer_in_data = "0" & "1000000" & "0" & "0100000" & "0") then -- Center Left y 64 x 32 = 1000000 0100000 (OMC7)
	taer_in_data <= "0" & "1000001" & "0" & "0100000" & "0";
elsif  (aer_in_data = "0" & "0100000" & "0" & "1000000" & "0") then -- Bottom Center y 32 x 64 = 0100000 1000000 (OMC6)
	taer_in_data <= "0" & "0100001" & "0" & "1000000" & "0";
elsif  (aer_in_data = "0" & "1000000" & "0" & "1100000" & "0") then -- Center Right y 64 x 96 = 1000000 1100000 (OMC9)
	taer_in_data <= "0" & "1000001" & "0" & "1100000" & "0";
elsif  (aer_in_data = "0" & "1100000" & "0" & "1000000" & "0") then -- Top Center y 96 x 64 = 1100000 1000000 (OMC8)
	taer_in_data <= "0" & "1100001" & "0" & "1000000" & "0";
else
	taer_in_data <= aer_in_data;
end if;
end process;

BRAM_MATRIX: process (clk50)
begin
	if (clk50'event and clk50 = '1') then
		if (matrix_we = '1') then
			matrix_hpf(to_integer(matrix_dir)) <= matrix_di;
		end if;
		matrix_do <= matrix_hpf(to_integer(matrix_dir));
	end if;
end process;

BRAM_ARRAY: process (clk50)
begin
	if (clk50'event and clk50 = '1') then
		if (array_we = '1') then
			array_hpf(to_integer(array_dir)) <= array_di;
		end if;
		array_do <= array_hpf(to_integer(array_dir));
	end if;
end process;

SYNC_AER: process(RST_L, CLK50)
begin
if(RST_L = '0') then
	CS <= IDLE;
	learning_timer <= (others =>'0');
	learning <= '0';
	cnt_col <= (others =>'0');
	cnt_row <= (others =>'0');
	fin_learning <= '0';
	rc <= (others => '0');
	aer_in_ack_l <= '1';
	aer_out_req_l <= '1';
	laer_data <= (others => '0');
	array_dir <= (others => '0');
	matrix_dir <= (others => '0');
	matrix_we <= '0';
	array_we <= '0';
	alex<=(others=>'0');
	learning_time <= x"00124F80"; -- 20 ms of learning time initially
	numev_hp <= x"05";
	filter_polarity <= '1';
elsif(CLK50'event and CLK50 ='1') then
	CS <= NS;
	if spiwr='1' then  
		case SPIADDRESS is
				when x"C0" => learning_time(7 downto 0) <= unsigned(spiDATA); 
				when x"C1" => learning_time(15 downto 8) <= unsigned(spiDATA); 
				when x"C2" => learning_time(23 downto 16) <= unsigned(spiDATA); 
				when x"C3" => learning_time(31 downto 24) <= unsigned(spiDATA); 
				when x"C4" => if (spiDATA=x"FF") then learning<='1'; end if;
				when x"C5" => numev_hp <= unsigned(spiDATA);
				when x"C6" => if (spiDATA=x"00") then filter_polarity<='0'; elsif (spiDATA=x"FF") then filter_polarity<='1'; end if;
--				when x"C7" => neighbors <= spiDATA(3 downto 0);
				when others => null;
			end case;
	elsif CS= LEARN_WAIT then learning <='0';
	end if;
	--alex(0) <= '0';
	case CS is
	   when IDLE => 
			learning_timer <= (others => '0');
			if (aer_in_req_l='0') then
			    array_dir <= unsigned(aer_in_data (16 downto 9) & aer_in_data (8 downto 1))+1;
				 laer_data <= taer_in_data;
		   end if;
			aer_in_ack_l <= '1';
			aer_out_req_l <= '1';
			alex<="000";
			array_we <= '0';
			matrix_we <='0';
		when READ_ARRAY =>
			aer_in_ack_l <= '0';
			alex<="001";
		when READ_ARRAYb =>
			aer_in_ack_l <= '0';
			alex<="001";
		when SEND =>
			aer_in_ack_l <= '0';
			aer_out_req_l <= '0';	
			alex<="001";
		when FILTER =>
			aer_in_ack_l <= '0';
			aer_out_req_l <= '1';			
			alex<="010";
		when LEARN_WAIT => 
			alex<="100";
		   learning_timer <= learning_timer +1;
			if (aer_in_req_l='0') then
			    matrix_dir <= unsigned(aer_in_data (16 downto 9) & aer_in_data (8 downto 1));
--			    lcol <= unsigned(aer_in_data (8 downto 1));
--				 lrow <= unsigned(aer_in_data (16 downto 9));
		   end if;
			cnt_col <= (others =>'0');
			cnt_row <= (others =>'0');
			fin_learning <= '0';
			matrix_we <= '0';
			aer_in_ack_l <= '1';
		when LEARN_COUNT => 
			alex<="100";
			--alex(0)<='1';
			learning_timer <= learning_timer +1;
			rc <= matrix_do;
		when LEARN_ACK => 
			alex<="100";
			--alex(0)<='1';
			learning_timer <= learning_timer +1; 
			if (rc < 2**RESMAX) then
				matrix_di <= rc +1;
			else matrix_di <= (others=>'1');
			end if;
			matrix_we <= '1';
			aer_in_ack_l <= '0';
			aer_out_req_l <= '1';	
		when LEARN_WR_ARRAY =>
			alex<="111";
		   if (cnt_col < COLS) then
			   cnt_col <= cnt_col +1;
			elsif (cnt_row < ROWS) then
			   cnt_col <= (others => '0');
				cnt_row <= cnt_row +1;
			else
			   fin_learning <= '1';
			end if;
			matrix_dir <= cnt_row & cnt_col;
			array_dir <= cnt_row & cnt_col;
			matrix_we <= '0';
			array_we <= '0';
		when MATRIX_PX_RST =>
			alex<="111";
			matrix_di <= (others => '0'); -- Maybe it has to be implemented in another state. Check this.
			matrix_we <= '1';
			if (matrix_do < NUMEV_HP) then
			   array_di <= '0'; -- must be '0'!!
			else 
			   array_di <= '1';
			end if;
			array_we <= '1';
		when others => null;
	end case;
	--array_di <='1';
end if;
end process;
--alex (2 downto 1)<=array_we & matrix_we;

COMB_AER: process(aer_in_req_l, CS, aer_out_ack_l, learning_timer, learning, fin_learning, array_do, filter_polarity, learning_time)
begin
NS <= CS;
case CS is
	when IDLE =>
	   if (learning= '1') then
		   NS <= LEARN_WAIT;
		elsif (aer_in_req_l='0') then
		   NS <= READ_ARRAY;
		end if;
	when READ_ARRAY =>
	   NS <= READ_ARRAYb;
	when READ_ARRAYb =>
	   if ((array_do='1' and filter_polarity='1') or (array_do='0' and filter_polarity='0')) then 
		   NS <= FILTER;
		else NS <= SEND;
		end if;
	when FILTER => 
	   if (aer_in_req_l ='1') then 
		   NS <= IDLE;
	   end if;
   when SEND =>
	   if (aer_out_ack_l='0' and aer_in_req_l ='1') then 
		   NS <= IDLE;
		end if;
	when LEARN_WAIT =>
	   if (learning_timer > LEARNING_TIME) then
		   NS <= LEARN_WR_ARRAY;
		elsif (aer_in_req_l = '0') then
		   NS <= LEARN_COUNT;
		end if;
	when LEARN_WR_ARRAY =>
	   NS <= MATRIX_PX_RST;
	when MATRIX_PX_RST =>
	   if (fin_learning = '1') then
		   NS <= IDLE;
		else 
		   NS <= LEARN_WR_ARRAY;
		end if;
	when LEARN_COUNT =>
	   NS <= LEARN_ACK;
	when LEARN_ACK =>
	   if (aer_in_req_l = '1') then
		   NS <= LEARN_WAIT;
		end if;
	when others =>
	   NS <= IDLE;
end case;
end process;
end Behavioral;
