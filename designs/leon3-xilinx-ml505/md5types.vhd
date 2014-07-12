library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

package interfaces is 

	type slave_memory_t is record
	
		reg_addr: std_logic_vector (6 downto 0);
		reg_we: std_logic;
		reg_data_wr: std_logic_vector ( 31 downto 0);
		reg_data_rd: std_logic_vector ( 31 downto 0);
			       
	end record slave_memory_t;
	
	
	 type	ChunkReg_t is array (15 downto 0) of std_logic_vector(31 downto 0);  
     type	HashReg_t  is array (3 downto 0) of std_logic_vector(31 downto 0);
	
	
	
	type memory_md5_t is record
		
		Chunk : ChunkReg_t;
		Hash  :	HashReg_t;
	
	end record memory_md5_t;
	
	
	
	type memory_controller_in_t is record
	
		new_address : std_logic_vector (31 downto 0);
		dma_done	: std_logic;
		hash_done: std_logic;
	    data_ready: std_logic;
	    
	end record memory_controller_in_t;
	
	
	
	
	type memory_controller_out_t is record
	
		start_hash : std_logic;
		continue_hash : std_logic;
		start_dma	:std_logic;
		dma_address :std_logic_vector (31 downto 0);
		dma_length : std_logic_vector (5 downto 0);
		dma_interrupt_enable :std_logic;
		hash_interrupt_enable :std_logic;
	
	end record memory_controller_out_t;

end package interfaces;	   

