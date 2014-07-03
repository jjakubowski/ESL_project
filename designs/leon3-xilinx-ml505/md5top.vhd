library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.interfaces.all;
use work.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity MD5top_module is
    generic (
        hindex   : integer := 0;
        haddr    : integer := 0;
        hmask    : integer := 16#fff#
        );
	 Port ( rst : in  std_ulogic;
           clk : in  std_ulogic;
           ahbsi : in  ahb_slv_in_type;
           ahbso : out ahb_slv_out_type
           );
			  
end MD5top_module;

architecture rtl of MD5top_module is
	
	 constant hconfig : ahb_config_type := (
        0 => ahb_device_reg (VENDOR_ESL, ESL_MD5, 0, 0, 0),
        4 => ahb_membar(haddr, '0', '0', hmask),
		others => zero32);

        
       
---------------------Component declarance------------------------------------
       
	 component MD5SlaveInterface is
			generic (
				hindex   : integer := 0;
				haddr    : integer := 0;
				hmask    : integer := 16#fff#
				);
			Port ( 	rst : in  std_ulogic;
					clk : in  std_ulogic;
					ahbi : in  ahb_slv_in_type;
					ahbo : out ahb_slv_out_type;
					reg_addr: out std_logic_vector (6 downto 0);
					reg_we: out std_logic;
					reg_data_wr: out std_logic_vector ( 31 downto 0);
					reg_data_rd: in std_logic_vector ( 31 downto 0)
           );
	 end component MD5SlaveInterface;
			  
		 
		 
	 component MD5Memory is
			Port (	rst : in  std_ulogic;
					clk : in  std_ulogic;
					reg_addr: in std_logic_vector (6 downto 0);
					reg_we: in std_logic;
					reg_data_wr: in std_logic_vector (31 downto 0);
					reg_data_rd: out std_logic_vector (31 downto 0));
	 end component MD5Memory;
        
-------------------------------------------------------------------------------        
        
		signal memory_inter: memory_t;
		
		--signal r,rin: registers;
begin
	 
------------------Component instance----------------------------------------

MD5SLAVE : MD5SlaveInterface
port map(rst => rst,
			clk => clk,
			ahbi => ahbsi,
			ahbo => ahbso,
			reg_addr => memory_inter.reg_addr,
			reg_we =>  memory_inter.reg_we,
			reg_data_wr => memory_inter.reg_data_wr,
			reg_data_rd => memory_inter.reg_data_rd
			);


--MD5MEMORY : MD5Memory
--port map(rst	=> rst,
--		 clk	=> clk,
--		 reg_addr => memory_inter.reg_addr,
--		 reg_we		=> memory_inter.reg_we,
--		 reg_data_wr	=> memory_inter.reg_data_wr,
--		 reg_data_rd	=> memory_inter.reg_data_rd);

----------------------------------------------------------------------------	 
	 
	 
end rtl;

