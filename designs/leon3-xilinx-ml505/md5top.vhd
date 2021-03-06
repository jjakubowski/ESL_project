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
           ahbso : out ahb_slv_out_type;
		   ahbmi : in  ahb_mst_in_type;
		   ahbmo : out ahb_mst_out_type
           );
			  
end MD5top_module;

architecture rtl of MD5top_module is
	
     
       
---------------------Component declarance------------------------------------
       
	 component MD5SlaveInterface is
			generic (
				hindex   : integer := 0;
				haddr    : integer := 0;
				hmask    : integer := 16#fff#
				);
			Port ( 	rst : in  std_ulogic;
					clk : in  std_ulogic;
					ahbsi : in  ahb_slv_in_type;
					ahbso : out ahb_slv_out_type;
					reg_addr: out std_logic_vector (6 downto 0);
					reg_we: out std_logic;
					reg_data_wr: out std_logic_vector ( 31 downto 0);
					reg_data_rd: in std_logic_vector ( 31 downto 0)
           );
	 end component MD5SlaveInterface;
			  
		 
		 
	 component MD5Memory is
	 Port ( rst : in  std_ulogic;
           clk : in  std_ulogic;
			  reg_addr: in std_logic_vector (6 downto 0);
		     reg_we: in std_logic;
		     reg_data_wr: in std_logic_vector(31 downto 0);
		     reg_data_rd: out std_logic_vector(31 downto 0);
		     control_signals_out: out memory_controller_out_t;
		     control_signals_in: in memory_controller_in_t;
		     chunk_out : out ChunkReg_t;
		     chunk_in : in std_logic_vector(31 downto 0);
		     hash_in: in HashReg_t;
		     data_ready: in std_logic
			  );		  
	 end component MD5Memory;
	 
	 
	 component MD5MasterInterface is
			generic (
				hindex   : integer := 0;
				haddr    : integer := 0;
				hmask    : integer := 16#fff#
				);
			Port ( 	rst : in  std_ulogic;
					clk : in  std_ulogic;
					ahbi : in  ahb_mst_in_type;
					length_in : in std_logic_vector(5 downto 0);  
					start_dma: in std_logic;
					address: in std_logic_vector(31 downto 0);
			  
					ahbo : out ahb_mst_out_type;
					dataToChunk: out std_logic_vector(31 downto 0); 
					newAddress : out std_logic_vector(31 downto 0); 
					dmaEnd : out std_ulogic;
					DataReady: out std_logic					
           );
	 end component MD5MasterInterface;
--		
--	 component MD5Controller is
--    Port ( nrst : in  std_ulogic;
--           clk : in  std_ulogic;
--			  startACK : in  STD_LOGIC;
--           hash_ready : in  STD_LOGIC;
--           start_hash : in  STD_LOGIC;
--           continue_hash : in  STD_LOGIC;
--           continue : out  STD_LOGIC;
--           start : out  STD_LOGIC;
--           hash_done : out  STD_LOGIC);
--
--		  			  
--	end component MD5Controller;
-------------------------------------------------------------------------------        
        
		signal slave_memory_inter: slave_memory_t;
		signal memory_md5_inter: memory_md5_t;
		signal memory_controller_in_inter : memory_controller_in_t;
		signal memory_controller_out_inter : memory_controller_out_t;
		signal chunk_dma_memory: std_logic_vector (31 downto 0);
		signal chunk_memory_md5: ChunkReg_t;
		signal hash_md5_memory: HashReg_t;
--		signal startACK: std_logic;
--		signal hash_ready: std_logic;
--		signal start:std_logic;
		
		
		
		--signal r,rin: registers;
begin
	 
------------------Component instance----------------------------------------

MD5SLAVE : MD5SlaveInterface
generic map(hindex => hindex, haddr => haddr, hmask => 16#fff#)
port map(rst,clk,ahbsi,ahbso,slave_memory_inter.reg_addr,
	 slave_memory_inter.reg_we, slave_memory_inter.reg_data_wr,
         slave_memory_inter.reg_data_rd
			);
MD5Mem : MD5Memory
port map(rst	=> rst,
		 clk	=> clk,
		 reg_addr => slave_memory_inter.reg_addr,
		 reg_we		=> slave_memory_inter.reg_we,
		 reg_data_wr	=> slave_memory_inter.reg_data_wr,
		 reg_data_rd	=> slave_memory_inter.reg_data_rd,
		 control_signals_out => memory_controller_out_inter,
		 control_signals_in => memory_controller_in_inter,
		 chunk_out => chunk_memory_md5,
		 chunk_in => chunk_dma_memory,
		 hash_in => hash_md5_memory,
		 data_ready =>memory_controller_in_inter.data_ready
		 );
		 
MD5MASTER : MD5MasterInterface
generic map(hindex => hindex, haddr => haddr, hmask => 16#fff#)
port map(rst => rst,
		 clk =>clk,
		 ahbi => ahbmi,
		 ahbo => ahbmo,
		 length_in => memory_controller_out_inter.dma_length,
		 start_dma => memory_controller_out_inter.start_dma,
		 address => memory_controller_out_inter.dma_address,
		 dataToChunk => chunk_dma_memory,
		 newAddress => memory_controller_in_inter.new_address,
		 dmaEnd => memory_controller_in_inter.dma_done,
		 DataReady => memory_controller_in_inter.data_ready
	 );

--MD5CONTROLLER: MD5Controller
--port map(rst=>rst,
--			clk=>clk,
--			startACK : in  STD_LOGIC;
--         hash_ready : in  STD_LOGIC;
--         start_hash : in  STD_LOGIC;
--         continue_hash : in  STD_LOGIC;
--         continue : out  STD_LOGIC;
--         start : out  STD_LOGIC;
--         hash_done : out  STD_LOGIC);
--
--		  			  
--end MD5Controller;

----------------------------------------------------------------------------	 
	 
	 
end rtl;

