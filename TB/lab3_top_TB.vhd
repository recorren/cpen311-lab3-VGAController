library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity lab3_top_TB is
end entity; 

architecture impl of lab3_top_TB is
  
  component lab3_top is
    port(KEY : in std_logic_vector(3 downto 0);
       CLOCK_50: in std_logic;
       SW : in std_logic_vector(17 downto 0);
       LEDG : out std_logic_vector(7 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic;
       HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(7 downto 0));

  end component;
  
  signal CLOCK_50: std_logic := '0';
  signal rst : std_logic := '0';
  signal color: std_logic_vector(2 downto 0);
  signal x : std_logic_vector(7 downto 0);
  signal y : std_logic_vector(6 downto 0);
  signal plot : std_logic;
  signal done : std_logic;
  
  begin
    
    DUT : lab3_top port map(CLOCK_50 => CLOCK_50, KEY => not rst & "000", SW => 18d"0");
    
    process begin
      
      wait for 10 ps;
      
      rst <= '1'; 
      
      wait for 10 ps; 
      
      rst <= '0';
      report("Running");
      for I in 0 to 50000 loop
        
        
        wait for 10 ps;
        
        CLOCK_50 <= not CLOCK_50; 
        
        if(I = 18) then
          wait for 5 ps;
          rst <= '1';
          wait for 5 ps;
          rst <= '0';
        end if;
        
      end loop; 
       report("TEST");
      wait for 500 ps;
      
      
      wait; 
    end process; 
end impl; 