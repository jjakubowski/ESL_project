library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.interfaces.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity MD5SlaveInterface is
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
end MD5SlaveInterface;

architecture rtl of MD5SlaveInterface is
	
	 constant hconfig : ahb_config_type := (
        0 => ahb_device_reg (VENDOR_ESL, ESL_MD5, 0, 0, 0),
		  4 => ahb_membar(haddr, '0', '0', hmask),
		others => zero32);
		
		
	 type registers is record
			memory: slave_memory_t;	
			hwrite : std_ulogic;
			hready : std_ulogic;
			haddr : std_logic_vector(6 downto 0);
			hsel : std_ulogic;	       
     end record;
		
		
        

    signal r, rin : registers;
  

begin
     
    	ahbso.hresp <= "00";
	ahbso.hsplit <= (others => '0');
	ahbso.hirq <= (others => '0');
	ahbso.hcache <= '0';
	ahbso.hconfig <= hconfig; 
	ahbso.hindex <= hindex;

		

	 
	 comb : process(rst, r, ahbsi,reg_data_rd) 
		variable readdata : std_logic_vector(31 downto 0);
		variable v   : registers;
  
	     begin
			  v := r;
			  v.hready := '1';
			  readdata := (others => '0');
			   		  
			if ahbsi.hready = '1' then 
		  
				v.hwrite := ahbsi.hwrite;
				v.hsel := ahbsi.hsel(hindex);
				v.haddr := ahbsi.haddr(6 downto 0);
				
				--reg_addr <= ahbsi.haddr (6 downto 0);
				
			end if;		
			
			
			if  r.hsel = '1' then
				
				reg_addr <= r.haddr;
				if r.hwrite = '1' then
				
					reg_we <='1';
					reg_data_wr <= ahbsi.hwdata(31 downto 0);
					--reg_addr <= r.haddr;
				else
				
					reg_we <='0';
					reg_data_wr <=(others => '0');
					--reg_addr <= (others => '0');
					readdata := reg_data_rd;
			  --v.memory.reg_data_rd := reg_data_rd;				
				
				end if; 
			end if;			
				--if r.haddr = "000" then
				--	v.dummyControlReg := ahbsi.hwdata;
				--end if;

			   --v.hready := not (v.hsel and not ahbsi.hwrite);
				--v.hwrite := v.hwrite and v.hready;
		  

	          if rst = '0' then
	          	v.hwrite := '0';
				v.hready := '1';
	          end if;
	          
	          
	        
	          rin <= v;
		      ahbso.hrdata <= readdata;
			  ahbso.hready <= '1'; --r.hready
			  
			  
		 end process;
	 
 
	 regs : process(clk)
    begin
        if rising_edge(clk) then r <= rin; end if;
    end process;
	 
end rtl;

