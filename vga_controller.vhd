library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_CONTROLLER is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        x_coor : out STD_LOGIC_VECTOR (9 downto 0);
        y_coor : out STD_LOGIC_VECTOR (9 downto 0);
        vidon : out STD_LOGIC
    );
end entity;

architecture BEHV of VGA_CONTROLLER is

    constant hpixels : STD_LOGIC_VECTOR (9 downto 0) := "1100100000"; --800
    constant hbp : STD_LOGIC_VECTOR (9 downto 0) := "0010010000"; --96+48
    constant hfp : STD_LOGIC_VECTOR (9 downto 0) := "1011110000"; --96+48+640
    constant hpw : INTEGER := 96;
    
    constant vlines : STD_LOGIC_VECTOR (9 downto 0) := "1000001001"; --521
    constant vbp : STD_LOGIC_VECTOR (9 downto 0) := "0000001100"; --2+10
    constant vfp : STD_LOGIC_VECTOR (9 downto 0) := "0111101100"; --2+10+480
    constant vpw : INTEGER := 2;
    
    signal hcounter : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    signal vcounter : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    signal v_enable : STD_LOGIC := '0';

begin
    
    horizontal_process : process (clock, clear)
    begin
        if clear = '1' then
            hcounter <= "0000000000";
        elsif clock'event and clock = '1' then
            
            if hcounter = hpixels - 1 then
                hcounter <= "0000000000";
                v_enable <= '1';
            else
                hcounter <= hcounter + 1;
                v_enable <= '0';
            end if;
            
         end if;
    end process;
    
    vertical_process : process (clock, clear, v_enable)
    begin
        if clear = '1' then
            vcounter <= "0000000000";
        elsif clock'event and clock = '1' and v_enable = '1' then
            
            if vcounter = vlines - 1 then
                vcounter <= "0000000000";
            else
                vcounter <= vcounter + 1;
            end if;
            
         end if;
    end process;

    hsync <= '0' when hcounter < hpw else '1';
    vsync <= '0' when vcounter < vpw else '1';
    
    vidon <= '1' when (hcounter < hfp) and (hcounter >= hbp)
                  and (vcounter < vfp) and (vcounter >= vbp) else '0';
    
    x_coor <= hcounter - hbp;
    y_coor <= vcounter - vbp;
    
end architecture;
