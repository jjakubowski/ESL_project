library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.interfaces.all;



entity MD5Memory is

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
			  
end MD5Memory;

architecture rtl of MD5Memory is
	   
     type registers is record
			ChunkReg: ChunkReg_t;
			HashReg:  HashReg_t;
			ControlReg: std_logic_vector(31 downto 0);
			AddressReg:	std_logic_vector(31 downto 0);
			StatusReg:	std_logic_vector(31 downto 0);
     
     end record;
        

    signal r, rin : registers;


begin
	 
	 comb : process(rst, r, reg_addr,reg_we,reg_data_wr,control_signals_in,chunk_in,hash_in) --control_signals_in
	  
        variable readdata : std_logic_vector(31 downto 0);
        
        variable v        : registers;

    begin
		  v := r;
		

 		control_signals_out.start_hash <= r.ControlReg (0);
		control_signals_out.continue_hash <= r.ControlReg(1);
		control_signals_out.start_dma  <= r.ControlReg(3);
		control_signals_out.dma_address <= r.AddressReg;
		control_signals_out.dma_length <= r.ControlReg(28 downto 23);
		control_signals_out.dma_interrupt_enable <= r.ControlReg(4);
		control_signals_out.hash_interrupt_enable <= r.ControlReg(2);
		
		chunk_out <= r.ChunkReg;
		  	  
		  if(r.ControlReg(5) = '1' and r.StatusReg(1) = '1' ) then --if increment adddress and dma running
			 v.AddressReg := control_signals_in.new_address;
		  end if;
		  
		  if(r.ControlReg(0) = '1') then    --clear hash start in next cycle
			v.ControlReg(0) := '0';
		  end if;

		  if(r.ControlReg(3) = '1') then --clear dma start in next cycle
			v.ControlReg(3) := '0';
		  end if;
		  v.StatusReg(0) := not control_signals_in.hash_done;
		  v.StatusReg(1) := not control_signals_in.dma_done;
		  
		  v.HashReg := hash_in;	  
		  
		  v.ChunkReg := chunk_in;
		  
-- read register
        readdata := (others => '0');
        
        case reg_addr is
        
			when "0000000" => readdata(31 downto 0) := r.StatusReg;
			when "0000100" => readdata(31 downto 0) := r.AddressReg;
			when "0001000" => readdata(31 downto 0) := r.ControlReg;
			when "0001100" => readdata(31 downto 0) := r.HashReg(0);
			when "0001101" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(0)(15 downto 8);
			when "0001110" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(0)(23 downto 16);
			when "0001111" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(0)(31 downto 24);
			when "0010000" => readdata(31 downto 0) := r.HashReg(1);
			when "0010001" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(1)(15 downto 8);
			when "0010010" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(1)(23 downto 16);
			when "0010011" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(1)(31 downto 24);
			when "0010100" => readdata(31 downto 0) := r.HashReg(2);
			when "0010101" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(2)(15 downto 8);
			when "0010110" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(2)(23 downto 16);
			when "0010111" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(2)(31 downto 24);
			when "0011000" => readdata(31 downto 0) := r.HashReg(3);
			when "0011001" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(3)(15 downto 8);
			when "0011010" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(3)(23 downto 16);
			when "0011011" => readdata(31 downto 0) := X"00_00_00" & r.hashReg(3)(31 downto 24);
			when "0011100" => readdata(31 downto 0) := r.ChunkReg(0);
			when "0100000" => readdata(31 downto 0) := r.ChunkReg(1);
			when "0100100" => readdata(31 downto 0) := r.ChunkReg(2);
			when "0101000" => readdata(31 downto 0) := r.ChunkReg(3);
			when "0101100" => readdata(31 downto 0) := r.ChunkReg(4);
			when "0110000" => readdata(31 downto 0) := r.ChunkReg(5);
			when "0110100" => readdata(31 downto 0) := r.ChunkReg(6);
			when "0111000" => readdata(31 downto 0) := r.ChunkReg(7);
			when "0111100" => readdata(31 downto 0) := r.ChunkReg(8);
			when "1000000" => readdata(31 downto 0) := r.ChunkReg(9);
			when "1000100" => readdata(31 downto 0) := r.ChunkReg(10);	
			when "1001000" => readdata(31 downto 0) := r.ChunkReg(11);
			when "1001100" => readdata(31 downto 0) := r.ChunkReg(12);
			when "1010000" => readdata(31 downto 0) := r.ChunkReg(13);
			when "1010100" => readdata(31 downto 0) := r.ChunkReg(14);
			when "1011000" => readdata(31 downto 0) := r.ChunkReg(15);
			when others => null;
        end case;


        if reg_we = '1' then
			case reg_addr is
        
				when "0000100" => 
					if r.StatusReg(1) = '0' then 
						v.AddressReg := reg_data_wr (31 downto 0);
					end if;
				when "0001000" => v.ControlReg := reg_data_wr (31 downto 0);
				when "0011100" => v.ChunkReg(0) := reg_data_wr (31 downto 0);
				when "0100000" => v.ChunkReg(1) := reg_data_wr (31 downto 0);
				when "0100100" => v.ChunkReg(2) := reg_data_wr (31 downto 0);
				when "0101000" => v.ChunkReg(3) := reg_data_wr (31 downto 0);
				when "0101100" => v.ChunkReg(4) := reg_data_wr (31 downto 0);
				when "0110000" => v.ChunkReg(5) := reg_data_wr (31 downto 0);
				when "0110100" => v.ChunkReg(6) := reg_data_wr (31 downto 0);
				when "0111000" => v.ChunkReg(7) := reg_data_wr (31 downto 0);
				when "0111100" => v.ChunkReg(8) := reg_data_wr (31 downto 0);
				when "1000000" => v.ChunkReg(9) := reg_data_wr (31 downto 0);
				when "1000100" => v.ChunkReg(10) := reg_data_wr (31 downto 0);
				when "1001000" => v.ChunkReg(11) := reg_data_wr (31 downto 0);
				when "1001100" => v.ChunkReg(12) := reg_data_wr (31 downto 0);
				when "1010000" => v.ChunkReg(13) := reg_data_wr (31 downto 0);
				when "1010100" => v.ChunkReg(14) := reg_data_wr (31 downto 0);
				when "1011000" => v.ChunkReg(15) := reg_data_wr (31 downto 0);
				when others => null;
				
			end case;
			
        end if;

			

        if rst = '0' then
			  v.StatusReg := X"50_00_00_00"; -- i don't remember our group number so i assumed it's 5
			  v.ControlReg := (others => '0');
			  v.AddressReg := (others => '0');
			  v.HashReg(0) := (others => '0');
			  v.HashReg(1) := (others => '0');
			  v.HashReg(2) := (others => '0');
			  v.HashReg(3) := (others => '0');
			  for i in 0 to 15 loop
			  v.ChunkReg(i) := (others => '0');
			  end loop;

			  
			  
        end if;
        
        
        
        
        
        rin <= v;
        reg_data_rd <= readdata; 	-- drive apb read bus
	 end process;
	 
	 
	 
	 regs : process(clk)
    begin
        if rising_edge(clk) then r <= rin; end if;
    end process;
	 
end rtl;

