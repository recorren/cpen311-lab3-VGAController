library ieee;
use ieee.std_logic_1164.all;

package scrn_clearerDecs is
  component scrn_clearer is
    port(CLOCK_50: in std_logic;
       rst : in std_logic;
       colour: out std_logic_vector(2 downto 0);
       x : out std_logic_vector(7 downto 0);
       y : out std_logic_vector(6 downto 0);
       plot : out std_logic;
       done : out std_logic);
  end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.NbitRegDecs.all;

--Screen clearer module, runs an internal state machine on the rising edge of rst
--done is set to 1 after screen clear is complete. 

entity scrn_clearer is
  port(CLOCK_50: in std_logic;
       rst : in std_logic;
       colour: out std_logic_vector(2 downto 0);
       x : out std_logic_vector(7 downto 0);
       y : out std_logic_vector(6 downto 0);
       plot : out std_logic;
       done : out std_logic);
end entity; 

architecture impl of scrn_clearer is
  
  signal currentX, nextX : std_logic_vector(x'LENGTH-1 downto 0) := (others => '0'); 
  signal currentY, nextY : std_logic_vector(y'LENGTH-1 downto 0) := (others => '0'); 
  signal xEqualsLimit : std_logic := '0'; 
  signal yEqualsLimit : std_logic := '0';
  signal loady : std_logic := '0';
  signal done_internal : std_logic := '0';
  
  constant XLIMIT : integer := 159;
  constant YLIMIT : integer := 119;

  begin
    --XPOS asynchronously resets to value 0 if rst is high
    
    XPOS : NbitReg generic map(x'LENGTH, 0)
                   port map(D => nextX, clk => CLOCK_50, Q => currentX, rst => rst);
    
    YPOS : NbitReg generic map(y'LENGTH, 0)
                   port map(D => nextY, clk => CLOCK_50, Q => currentY, rst => rst);
                     
    process(all) begin 
        if(currentX = std_logic_vector(to_unsigned(XLIMIT, x'LENGTH))) then
          xEqualsLimit <= '1';
          loady <= '1';
          nextX <= (others => '0');
        else
          nextX <= std_logic_vector(unsigned(currentX) + 1); 
          xEqualsLimit <= '0'; 
          loady <= '0';
        end if;

      
    
    end process;
    
    process(all) begin
        if(currentY =  std_logic_vector(to_unsigned(YLIMIT, y'LENGTH))) then
          yEqualsLimit <= '1';
          nextY <= (others => '0');
        else 
          yEqualsLimit <= '0';
          
          if(loady = '1') then
            nextY <= std_logic_vector(unsigned(currentY) + 1);
          else
            nextY <= currentY;
          end if;
        end if;
    end process;
    colour <= currentX(2 downto 0); --x mod 8 is the same as taking the last 3 digits of a binary number
    plot <= '1';
    x <= currentX;
    y <= currentY;
    
end impl;