library ieee;
use ieee.std_logic_1164.all;

package line_drawerDecs is
  component line_drawer is
    port(CLOCK_50: in std_logic;
       run : in std_logic;
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

--Line drawing module, runs an internal state machine to draw a line
--done is set to 1 after drawing a complete line

entity line_drawer is
  port(CLOCK_50: in std_logic;
       run : in std_logic;
       rst : in std_logic;
       colour: out std_logic_vector(2 downto 0);
       x : out std_logic_vector(7 downto 0);
       y : out std_logic_vector(6 downto 0);
       plot : out std_logic;
       done : out std_logic);
end entity; 

architecture Aamodt of line_drawer is
  
  signal currentX, nextX : std_logic_vector(x'LENGTH-1 downto 0) := (others => '0'); 
  signal currentY, nextY : std_logic_vector(y'LENGTH-1 downto 0) := (others => '0');
  signal dx, err : std_logic_vector(x'LENGTH downto 0) := (others => '0');
  signal dy : std_logic_vector(y'LENGTH downto 0) := (others => '0');
  signal sx, sy : signed(3 downto 0) := (others => '0');
  signal gray : std_logic_vector(2 downto 0);
  signal next_colour : std_logic := '0';
  signal i, next_i : std_logic_vector(3 downto 0);
  signal x0, next_x0, next_x1 : std_logic_vector(x'LENGTH downto 0) := (others => '0');
  signal x1 : std_logic_vector(x'LENGTH downto 0) := std_logic_vector(to_unsigned(159, x'LENGTH +1));
  signal next_y0, next_y1 : std_logic_vector(y'LENGTH downto 0) := (others => '0');
  signal y0 : std_logic_vector(y'LENGTH downto 0) := std_logic_vector(to_unsigned(8, y'LENGTH +1));
  signal y1 : std_logic_vector(y'LENGTH downto 0) := std_logic_vector(to_unsigned(112, y'LENGTH +1));
  signal err2 : std_logic_vector(x'LENGTH+1 downto 0) := (others => '0');
  
  --constant iLIMIT : integer := 14;

  begin
    
    --XPOS asynchronously resets to value 0 if rst is high
    XPOS : NbitReg generic map(x'LENGTH)
                   port map(D => nextX, clk => CLOCK_50, Q => currentX, rst => rst);
    YPOS : NbitReg generic map(y'LENGTH)
                   port map(D => nextY, clk => CLOCK_50, Q => currentY, rst => rst);
    iCounter : NbitReg generic map(4)
                   port map(D => next_i, clk => CLOCK_50, Q => i, rst => rst);
    
    FFx0 : NbitReg generic map(x'LENGTH)
                   port map(D => next_x0, clk => CLOCK_50, Q => x0, rst => rst);
    FFy0 : NbitReg generic map(y'LENGTH)
                   port map(D => next_y0, clk => CLOCK_50, Q => y0, rst => rst);
    FFx1 : NbitReg generic map(x'LENGTH)
                   port map(D => next_x1, clk => CLOCK_50, Q => x1, rst => rst);
    FFy1 : NbitReg generic map(y'LENGTH)
                   port map(D => next_y1, clk => CLOCK_50, Q => y1, rst => rst);
    
    process(all) begin
      
      --shifting through colours
      case i is
        when "1000" | "0000" =>
          gray <= "000";
        when "1001" | "0001" =>
          gray <= "001";
        when "1010" | "0010" =>
          gray <= "011";
        when "1011" | "0011" =>
          gray <= "010";
        when "1100" | "0100" =>
          gray <= "110";
        when "1101" | "0101" =>
          gray <= "111";
        when "0110" =>
          gray <= "101";
        when "0111" =>
          gray <= "100";
        when others =>
          gray <= "101"; --error state
      end case;
      
      --dx, dy, sx, sy, err, and err2 calculations
      dx <= std_logic_vector(abs(signed(x1)-signed(x0)));
      dy <= std_logic_vector(abs(signed(y1)-signed(y0)));
      if(unsigned(x0) < unsigned(x1)) then
          sx <= to_signed(1, sx'LENGTH);
        else
          sx <= to_signed(-1, sx'LENGTH);
      end if;
      if(unsigned(y0) < unsigned(y1)) then
          sy <= to_signed(1, sy'LENGTH);
        else
          sy <= to_signed(1, sy'LENGTH);
      end if;
      err <= std_logic_vector(signed(dx)-signed(dy));
      err2 <= err & '0';
      
    --looping the algorithm
      --line finished: resets values and exits outputs done
    if(run = '1') then
      if(x0 = x1 and y0 = y1) then --and i = "1101" if we are drawing more than one line
        done <= '1';
        next_x0 <= (others => '0');
        next_y0 <= std_logic_vector((unsigned(i)+1)*8);
        next_x1 <= "010011111";
        next_y1 <= std_logic_vector(120 - (signed(i)+1)*8);
        if(i > "1100") then
          next_i <= "0000";
        else
          next_i <= std_logic_vector(unsigned(i) + 1);
        end if;
      --line not finished: calculates the next x0 and y0
      else
        if(signed(err2) > -signed(dy)) then   --is the - sign allowed?
          err <= std_logic_vector(signed(err)-signed(dy));
          next_x0 <= std_logic_vector(signed(x0)+signed(sx));
        end if;
        if(err2 < dx) then
          err <= std_logic_vector(signed(err)+signed(dx));
          next_y0 <= std_logic_vector(signed(y0)+signed(sy));
        end if;
      end if;
      
      --output to VGA
      x <= x0(7 downto 0); --after converting to signed and back it got an extra bit? should be '0' afterwards anyways
      y <= y0(6 downto 0);
      colour <= gray;
      plot <= '1';    --I have no idea why this would change while the function is cycling
    end if;
  end process;
end Aamodt;