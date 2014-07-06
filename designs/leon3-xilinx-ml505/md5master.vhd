------------------------------------------------------------------------------------
---- AHB master inputs
--type ahb_mst_in_type is record
--hgrant : std_logic_vector(0 to NAHBMST-1); -- bus grant
--hready : std_ulogic; -- transfer done
--hresp : std_logic_vector(1 downto 0); -- response type
--hrdata : std_logic_vector(31 downto 0); -- read data bus
--hrdata : std_logic_vector(31 downto 0); -- read data bus
--hcache : std_ulogic; -- cacheable
--hirq : std_logic_vector(NAHBIRQ-1 downto 0); -- interrupt result bus
--end record;

---- AHB master outputs
--type ahb_mst_out_type is record
--hbusreq : std_ulogic; -- bus request
--hlock : std_ulogic; -- lock request
--htrans : std_logic_vector(1 downto 0); -- transfer type
--haddr : std_logic_vector(31 downto 0); -- address bus (byte)
--hwrite : std_ulogic; -- read/write
--hsize : std_logic_vector(2 downto 0); -- transfer size
--hburst : std_logic_vector(2 downto 0); -- burst type
--hprot : std_logic_vector(3 downto 0); -- protection control
--hwdata : std_logic_vector(31 downto 0); -- write data bus
--hirq : std_logic_vector(NAHBIRQ-1 downto 0);-- interrupt bus
--hconfig : ahb_config_type; -- memory access reg.
--hindex : integer range 0 to NAHBMST-1; -- diagnostic use only
--end record;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity MD5MasterInterface is
	 generic (
        hindex   : integer := 0;
        haddr    : integer := 0;
        hmask    : integer := 16#fff#
        );
		  
	 Port ( rst : in  std_ulogic;
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
end MD5MasterInterface;

architecture Behavioral of MD5MasterInterface is

	 constant hconfig : ahb_config_type := (
        0 => ahb_device_reg (VENDOR_OPENCHIP, OPENCHIP_APBSPI, 0, 0, 0),
        4 => ahb_membar(haddr, '1', '0', hmask),
		others => zero32);
		  
	 signal readData: std_logic_vector(31 downto 0);
	 signal readAddress: std_logic_vector(31 downto 0);
	 signal counter: std_logic_vector(5 downto 0);
	 type registers is record
          readData :  std_logic_vector(31 downto 0);
			 readAddress :  std_logic_vector(31 downto 0);
			 counter: std_logic_vector(5 downto 0);
    end record;
    signal r, rin : registers;
	
begin
combinatorial : process(rst, r, ahbi, start_dma, address)
	variable v	: registers;
	variable tempAddress : std_logic_vector(31 downto 0);	
	constant increment : std_logic_vector(31 downto 0) := x"00000004";

	begin
		  v := r;
		  if ahbi.hgrant(hindex) = '1' then
			  if (start_dma='1')and(v.counter < length_in) then
					if(v.counter="000000") then
						v.readAddress := address;
					else 
						null;
					end if;
					dmaEnd <= '0';
					ahbo.hbusreq <= '1'; 
					ahbo.hlock <='1';
					ahbo.haddr <= v.readAddress;
					tempAddress := v.readAddress;
					v.readAddress := v.readAddress+increment;
					v.counter := v.counter + "000001";
					if (tempAddress = v. readAddress - increment) then 
						v.readData := ahbi.hrdata;
					else
						null;
					end if;
			  else
					dmaEnd <= '1';
					v.readData := (others => '0');
			  end if;
		  
			  if (rst = '0')or(start_dma='0') then
					v.readData := (others => '0');
					v.counter := (others => '0');
			  else
					null;
			  end if;
		  else
			  null;
		  end if;
		  
		  rin <= v;
		   
		  newAddress <= rin.readAddress; 
		  dataToChunk <= rin.readData;
	end process;	
	
	 ahbo.hirq <= (others => '0');
	 ahbo.hindex <= hindex;
    ahbo.hconfig <= hconfig;
	
 sequential : process(clk)
	begin
		  if rising_edge(clk) then r <= rin; end if;
 end process;
	 
end Behavioral;