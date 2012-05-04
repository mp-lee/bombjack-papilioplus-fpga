--	(c) 2012 d18c7db(a)hotmail
--
--	This program is free software; you can redistribute it and/or modify it under
--	the terms of the GNU General Public License version 3 or, at your option,
--	any later version as published by the Free Software Foundation.
--
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- For full details, see the GNU General Public License at www.gnu.org/licenses

--------------------------------------------------------------------------------

-- ###########################################################################
-- ##### PAGE 3 schema - timing signals                                  #####
-- ###########################################################################
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity timing is
	port (
		I_CLK_6M_EN			: in  std_logic;
		I_FLIP				: in  std_logic;
		I_CS_9A00_n			: in  std_logic;
		I_MEWR_n				: in  std_logic;
		I_AB					: in  std_logic;
		I_DB					: in  std_logic_vector ( 3 downto 0);
		--
		O_SLOAD_n			: out std_logic;
		O_SLOAD				: out std_logic;
		O_SL1_n				: out std_logic;
		O_SL2_n				: out std_logic;
		O_SW_n				: out std_logic;
		O_SS					: out std_logic;
		O_HBL					: out std_logic;
		O_CONTROLDB_n		: out std_logic;
		O_CONTROLDA_n		: out std_logic;
		O_VPL_n				: out std_logic;
		O_CDL_n				: out std_logic;
		O_MDL_n				: out std_logic;
		O_SEL					: out std_logic;
		O_1V_r				: out std_logic;
		O_1V_n_r				: out std_logic;
		O_256H_r				: out std_logic;
		O_CMPBLK_n_r		: out std_logic;
		O_CMPBLK_n			: out std_logic;
		O_CMPBLK				: out std_logic;
		O_VBLANK_n			: out std_logic;
		O_VBLANK				: out std_logic;
		O_TVSYNC_n			: out std_logic;
		O_HSYNC_n			: out std_logic;

		O_1H					: out std_logic;
		O_2H					: out std_logic;
		O_4H					: out std_logic;
		O_8H					: out std_logic;
		O_16H					: out std_logic;
		O_32H					: out std_logic;
		O_64H					: out std_logic;
		O_128H				: out std_logic;
		O_256H_n				: out std_logic;

		O_8H_X				: out std_logic;
		O_16H_X				: out std_logic;
		O_32H_X				: out std_logic;
		O_64H_X				: out std_logic;
		O_128H_X				: out std_logic;

		O_1V_X				: out std_logic;
		O_2V_X				: out std_logic;
		O_4V_X				: out std_logic;
		O_8V_X				: out std_logic;
		O_16V_X				: out std_logic;
		O_32V_X				: out std_logic;
		O_64V_X				: out std_logic;
		O_128V_X				: out std_logic;
		O_VSYNC_n			: out std_logic
	);

end timing;

architecture RTL of timing is
--	Page 3
	signal s_1H					: std_logic := '0';
	signal s_2H					: std_logic := '0';
	signal s_4H					: std_logic := '0';
	signal s_8H					: std_logic := '0';
	signal s_16H				: std_logic := '0';
	signal s_32H				: std_logic := '0';
	signal s_64H				: std_logic := '0';
	signal s_128H				: std_logic := '0';
	signal s_256H_n			: std_logic := '0';

	signal s_1V					: std_logic := '0';
	signal s_2V					: std_logic := '0';
	signal s_4V					: std_logic := '0';
	signal s_8V					: std_logic := '0';
	signal s_16V				: std_logic := '0';
	signal s_32V				: std_logic := '0';
	signal s_64V				: std_logic := '0';
	signal s_128V				: std_logic := '0';

	signal s_hsync_n			: std_logic := '1';
	signal s_vsync_n			: std_logic := '1';
	signal s_sload_n			: std_logic := '1';
	signal s_vblank_n			: std_logic := '1';
	signal s_cmpblk_n			: std_logic := '1';

	signal hcount				: std_logic_vector( 8 downto 0) := (others => '1');
	signal vcount				: std_logic_vector( 8 downto 0) := (others => '1');
	signal s_9a00				: std_logic_vector( 3 downto 0) := (others => '0');
	signal s_9a01				: std_logic_vector( 3 downto 0) := (others => '0');

	signal s_7T8				: std_logic := '0';
	signal s_9a00_wr_n		: std_logic := '0';
	signal s_9a01_wr_n		: std_logic := '0';
	signal s_6T4				: std_logic := '0';
	signal s_5T8				: std_logic := '0';
	signal s_5R7				: std_logic := '0';
	signal s_5S7				: std_logic := '0';

begin
	-- chips 4T, 3T5 not required as clock generated by DCM externally

	-- chips 3T9, 3S, 3R, 4R8 page 3
	-- horizontal counter counts x080 to x1ff = 384 (6Mhz/384 = 15625 Hz)
	hcnt : process(I_CLK_6M_EN)
	begin
		if rising_edge(I_CLK_6M_EN) then
			if hcount = "111111111" then
				hcount <= "010000000";
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;

	-- chips 4P5, 3P, 3N, 2T12 page 3
	-- vertical counter counts 0xf8 to x1ff = 264 (15625/264 = 59.185 Hz)
	vcnt : process(s_256H_n)
	begin
	if falling_edge(s_256H_n) then -- falling edge means run off inverted s_256H_n
		if vcount = "111111111" then
			vcount <= "011111000";
		else
			vcount <= vcount + 1;
		end if;
	end if;
	end process;

	-- H counter signal outputs
	s_1H		<= hcount(0);
	s_2H		<= hcount(1);
	s_4H		<= hcount(2);
	s_8H		<= hcount(3);
	s_16H		<= hcount(4);
	s_32H		<= hcount(5);
	s_64H		<= hcount(6);
	s_128H	<= hcount(7);
	s_256H_n	<= hcount(8);

	O_1H		<= hcount(0);
	O_2H		<= hcount(1);
	O_4H		<= hcount(2);
	O_8H		<= hcount(3);
	O_16H		<= hcount(4);
	O_32H		<= hcount(5);
	O_64H		<= hcount(6);
	O_128H	<= hcount(7);
	O_256H_n	<= hcount(8);

	-- V counter signal outputs
	s_1V			<= vcount(0);
	s_2V			<= vcount(1);
	s_4V			<= vcount(2);
	s_8V			<= vcount(3);
	s_16V			<= vcount(4);
	s_32V			<= vcount(5);
	s_64V			<= vcount(6);
	s_128V		<= vcount(7);
	s_vsync_n	<= vcount(8);

	O_HSYNC_n	<= s_hsync_n;
	O_VSYNC_n	<= s_vsync_n;

	O_VBLANK_n <= s_vblank_n;
	O_VBLANK   <= not s_vblank_n;

	-- chip 4P9 page 3
	U4P9 : process(s_16H, s_256h_n)
	begin
		-- chip 4R6 page 3
		if s_256h_n = '1' then
			s_hsync_n <= '1';
		elsif rising_edge(s_16H) then
			-- chip 4R2, 4N12 page 3
			s_hsync_n <= (not s_32H) or s_64H;
		end if;
	end process;

	-- chip 5P9 page 3
	U5P9 : process(s_16V)
	begin
		if rising_edge(s_16V) then
			-- chip 4N8 page 3
			s_vblank_n <= not (s_32V and s_64V and s_128V);
		end if;
	end process;

	-- chip 1T6 page 3
	s_cmpblk_n <= s_vblank_n and s_256H_n;
	O_CMPBLK_n <= s_cmpblk_n;

	-- chip 1T8 page 3 (not used)
	O_TVSYNC_n <= s_hsync_n and s_vsync_n;

	-- chip 2T10 page 3
	O_CMPBLK <= not s_cmpblk_n;

	-- chip 1S6 page 3
	s_sload_n <= not (      s_1H  and      s_2H   and      s_4H);
	O_SLOAD_n <= s_sload_n;
	O_SLOAD   <= not s_sload_n;

	-- chip 1S12 page 3
	O_SL1_n   <= not (s_1H and (not s_2H) and (not s_4H));
	-- chip 1S8 page 3
	O_SL2_n   <= not (s_1H and      s_2H  and (not s_4H) );
	-- chip 1T3 page 3
	O_SW_n    <= (not s_2H) and s_4H;
	-- chip 1T11 page 3
	O_SS      <= (not s_4H) and s_cmpblk_n;

	-- chips 2R, 2N, 2P, 5T11 and 5T3 page 3
	O_128H_X	<= I_FLIP xor s_128H;
	O_64H_X	<= I_FLIP xor s_64H;
	O_32H_X	<= I_FLIP xor s_32H;
	O_16H_X	<= I_FLIP xor s_16H;
	O_8H_X	<= I_FLIP xor s_8H;
	O_128V_X	<= I_FLIP xor s_128V;
	O_64V_X	<= I_FLIP xor s_64V;
	O_32V_X	<= I_FLIP xor s_32V;
	O_16V_X	<= I_FLIP xor s_16V;
	O_8V_X	<= I_FLIP xor s_8V;
	O_4V_X	<= I_FLIP xor s_4V;
	O_2V_X	<= I_FLIP xor s_2V;
	O_1V_X	<= I_FLIP xor s_1V;

	-- chip 7N, s_7T8 page 3
	U7N : process(I_CLK_6M_EN)
	begin
		if rising_edge(I_CLK_6M_EN) then
			if s_sload_n = '0' then
				O_1V_r			<= s_1V;
				O_1V_n_r			<= not s_1V;
				O_256H_r			<= not s_256H_n;
				O_CMPBLK_n_r	<= s_cmpblk_n;
			end if;
		end if;
	end process;

	-- chip 4S5 page 3
	U4S5 : process(s_2H, s_256H_n)
	begin
		-- chip 4R6 page 3
		if s_256H_n = '1' then	-- active low, so really s_256H
			O_HBL <= '0';
		elsif rising_edge(s_2H) then
			-- chips 7D8, 4R4 page 3
			O_HBL <= not (s_64H and s_32H and s_16H and s_8H);
		end if;
	end process;


	-- chip 7R, 4S9 page 3
	U7R : process(I_CLK_6M_EN)
	begin
		if falling_edge(I_CLK_6M_EN) then	-- inverted because we need /6MHz
			O_MDL_n	<= ( s_1H or (    s_2H) or (    s_4H) );
			O_CDL_n	<= ( s_1H or (not s_2H) or (    s_4H) );
			O_VPL_n	<= ( s_1H or (    s_2H) or (not s_4H) );
		end if;
	end process;

	-- chip 7S page 3
	O_CONTROLDA_n <= s_sload_n or s_8H or s_6T4 or      s_1V;
	O_CONTROLDB_n <= s_sload_n or s_8H or s_6T4 or (not s_1V);

	-- chip 6T4 page 3
	s_6T4 <= s_5T8 and s_16H;

	-- chip 5T8 page 3
	s_5T8 <= s_5R7 xor s_5S7;
	O_SEL <= s_5T8;

	-- chip 5R page 3
	s_5R7		<=  '0' when (hcount(8 downto 5) > s_9a01) else '1'; -- high when less than or equal

	-- chip 5S page 3
	s_5S7		<=  '0' when (hcount(8 downto 5) > s_9a00) else '1'; -- high when less than or equal

	-- chip 6R page 3
	U6R : process(I_CLK_6M_EN)
	begin
		if rising_edge(I_CLK_6M_EN) then
			if s_9a01_wr_n = '0' then
				s_9a01 <= I_DB;
			end if;
		end if;
	end process;

	-- chip 6S page 3
	U6S : process(I_CLK_6M_EN)
	begin
		if rising_edge(I_CLK_6M_EN) then
			if s_9a00_wr_n = '0' then
				s_9a00 <= I_DB;
			end if;
		end if;
	end process;

	-- chip 7R6 page 3
	s_9a01_wr_n <= I_CS_9A00_n or I_MEWR_n or (not I_AB);
	-- chip 7R4 page 3
	s_9a00_wr_n <= I_CS_9A00_n or I_MEWR_n or      I_AB;

end RTL;
