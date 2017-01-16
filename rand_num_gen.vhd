library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.TETRIS_PACKAGE.ALL;

entity RAND_NUM_GEN is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        start : in STD_LOGIC;
        tetrimino : out TETRIMINO_TYPE
    );        
end entity;

architecture BEHV of RAND_NUM_GEN is

    signal start_flag : STD_LOGIC := '0';
    signal seed_counter : STD_LOGIC_VECTOR (11 downto 0);
    signal shift_register : STD_LOGIC_VECTOR (11 downto 0);

begin

    -- simple counter
    seed_process : process (clock, clear)
    begin
        if clear = '1' then
            seed_counter <= (others => '0');
        elsif clock'event and clock = '1' then
            seed_counter <= seed_counter + 1;
        end if;
    end process;

    generator_process : process (clock, clear)
    begin
        if clear = '1' then
        
            start_flag <= '0';
            shift_register <= (others => '0');
            
        elsif clock'event and clock = '1' then
            
            if start_flag = '1' then
            
                -- linear feedback shift register
                shift_register(11 downto 1) <= shift_register(10 downto 0);
                shift_register(0) <= not (shift_register(11) xor shift_register(5) xor shift_register(3) xor shift_register(0));
                
            else
            
                -- determines the seed and starts generating numbers
                if start = '1' then
                    start_flag <= '1';
                    shift_register <= seed_counter;
                end if;
                
            end if;
            
        end if;
    end process;
    
    -- NUMBER => SHAPE
    number_process : process (shift_register)
    
        variable number : INTEGER := 0;
        
    begin
        
        number := conv_integer(shift_register);
        number := number mod 7;
        
        case number is
            when 1 => tetrimino <= TETRIMINO_T;
            when 2 => tetrimino <= TETRIMINO_LINE;
            when 3 => tetrimino <= TETRIMINO_L_LEFT;
            when 4 => tetrimino <= TETRIMINO_L_RIGHT;
            when 5 => tetrimino <= TETRIMINO_Z_LEFT;
            when 6 => tetrimino <= TETRIMINO_Z_RIGHT;
            when others => tetrimino <= TETRIMINO_SQUARE;
        end case;
        
    end process;
    
end architecture;
