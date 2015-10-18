library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lineGetterDecs.all;

entity lineGetter_TB is
end entity;

architecture impl of lineGetter_TB is
  
  signal slow_clock : std_logic;
  signal rst : std_logic;
  
  begin
    
    DUT : lineGetter port map(rst => rst, slow_clock => slow_clock);
    
    process begin
      
      
        rst <= '1';
        slow_clock <= '0';
        
        
      
        for I in 0 to 50 loop
          
          wait for 10 ps;
          
          rst <= '0';
          
          slow_clock <= not slow_clock;
          
          
        end loop;
        
        wait; 
        
    end process;
end impl; 