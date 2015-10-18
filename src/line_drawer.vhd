library ieee;
use ieee.std_logic_1164.all;

package line_drawerDecs is
  component line_drawer is
    port(CLOCK_50 : in std_logic;
       run : in std_logic;
       rst : in std_logic;
       x : out std_logic_vector(7 downto 0);
       y : out std_logic_vector(6 downto 0); 
       
       x0, x1 : in std_logic_vector(7 downto 0);
       y0, y1 : in std_logic_vector(6 downto 0);
       
       plot : out std_logic;
       done : out std_logic);
  end component;
end package; 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.NbitRegDecs.all;

entity line_drawer is
  port(CLOCK_50 : in std_logic;
       run : in std_logic;
       rst : in std_logic;
       x : out std_logic_vector(7 downto 0);
       y : out std_logic_vector(6 downto 0); 
       
       x0, x1 : in std_logic_vector(7 downto 0);
       y0, y1 : in std_logic_vector(6 downto 0);
       
       plot : out std_logic;
       done : out std_logic);
end entity; 

architecture impl of line_drawer is
  
  signal currErr : signed(x'LENGTH-1 downto 0) := (others => '0');  
  signal nextErr : signed(x'LENGTH-1 downto 0) := (others => '0'); 
  signal currx0, nextx0: unsigned(x'LENGTH-1 downto 0) := (others => '0');
  signal sx, dx : signed(x'LENGTH-1 downto 0) := (others => '0');
  signal curry0, nexty0 : unsigned(y'LENGTH-1 downto 0) := (others => '0');
  signal sy, dy : signed(y'LENGTH-1 downto 0) := (others => '0');
  signal err2 : signed((x'LENGTH) downto 0);
  
  
  
  begin
    
    ERRREG : NbitReg generic map(x'LENGTH)
                    port map(clk => CLOCK_50, rst => rst, D => std_logic_vector(nextErr), signed(Q) => (currErr));
    
    X0REG : NbitReg generic map(x'LENGTH)
                    port map(clk => CLOCK_50, rst => rst, D => std_logic_vector(nextx0), unsigned(Q) => (currx0));
                      
    Y0REG : NbitReg generic map(y'LENGTH)
                    port map(clk => CLOCK_50, rst => rst, D => std_logic_vector(nexty0), unsigned(Q) => (curry0));
                      
                      
    done <= '1' when std_logic_vector(currx0) = x1 and std_logic_vector(curry0) = y1 else '0';
    plot <= not done;
    
    sx <= to_signed(1, x'LENGTH) when x0 < x1 else (others => ('1'));
    sy <= to_signed(1, y'LENGTH) when y0 < y1 else (others => ('1'));
    
    err2 <= currErr & '0'; --err2 = err*2
    
    dx <= (abs(signed(x1) - signed(x0)));
    dy <= (abs(signed(y1) - signed(y0)));
    
    x <= std_logic_vector(currx0);
    y <= std_logic_vector(curry0); 
    
    process(all) 
      variable newErrTemp : signed(x'LENGTH-1 downto 0) := (others => '0');
      variable negativeDy : signed(y'LENGTH-1 downto 0) := (others => '0');
      variable newy0Temp : unsigned(y'LENGTH-1 downto 0) := (others => '0');
      variable newx0Temp : unsigned(x'LENGTH-1 downto 0) := (others => '0'); 
        
      
      
      begin
      if(run) then
        newErrTemp := currErr;
        negativeDy := (not dy) + 1; --two's complement
        newx0Temp := currx0;
        newy0Temp := curry0;
        
        if(err2 > negativeDy) then
          newErrTemp := newErrTemp - dy;
          newx0Temp := currx0 + (unsigned(sx));
        end if;
       
       if(err2 < dx) then
          newErrTemp := newErrTemp + dx;
          newy0Temp := curry0 + (unsigned(sy));
       end if;
      else
        newx0Temp := unsigned(x0);
        newy0Temp := unsigned(y0);
        newErrTemp := dx-dy;
      end if;
      
      
       nextx0 <= newx0Temp;
       nexty0 <= newy0Temp; 
       nextErr <= newErrTemp;
    
       
    end process; 
    
    
end impl; 