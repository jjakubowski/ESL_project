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
		     chunk_in : in ChunkReg_t;
		     hash_in: in HashReg_t
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
					dmaEnd : out std_ulogic := '0'	
           );
	 end component MD5MasterInterface;
        
-------------------------------------------------------------------------------        
        
		signal slave_memory_inter: slave_memory_t;
		signal memory_md5_inter: memory_md5_t;
		signal memory_controller_in_inter : memory_controller_in_t;
		signal memory_controller_out_inter : memory_controller_out_t;
		signal chunk_dma_memory: ChunkReg_t;
		signal chunk_memory_md5: ChunkReg_t;
		signal hash_md5_memory: HashReg_t;
		
		
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
		 hash_in => hash_md5_memory
		 );
		 
MD5MASTER : MD5MasterInterface
generic map(hindex => hindex, haddr => haddr, hmask => 16#fff#)
port map(rst => rst,
		 clk =>clk,
		 ahbi => ahbi,
		 ahbo =>ahbo,
		 length_in => memory_controller_out_t.dma_length,
		 start_dma => memory_controller_out_t.start_dma,
		 address => memory_controller_out_t.dma_address,
		 dataToChunk => chunk_in,
		 newAddress => memory_controller_in_t.new_address,
		 dmaEnd => dma_done
	 );

----------------------------------------------------------------------------	 
	 
	 
end rtl;

