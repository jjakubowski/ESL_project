library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

package interfaces is 

	type memory_t is record
	
		reg_addr: std_logic_vector (6 downto 0);
		reg_we: std_logic;
		reg_data_wr: std_logic_vector ( 31 downto 0);
		reg_data_rd: std_logic_vector ( 31 downto 0);
			       
	end record memory_t;

end package interfaces;	   
