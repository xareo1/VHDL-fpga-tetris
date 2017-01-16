library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity KEYBOARD_SOURCE is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        key_code : in STD_LOGIC_VECTOR (7 downto 0);
        key_event : in STD_LOGIC;
        --
        key_enter : out STD_LOGIC;
        key_left : out STD_LOGIC;
        key_right : out STD_LOGIC;
        key_up : out STD_LOGIC;
        key_down : out STD_LOGIC;
        key_space : out STD_LOGIC
    );
end entity;

architecture BEHV of KEYBOARD_SOURCE is

    signal key_code_0 : STD_LOGIC_VECTOR (7 downto 0);
    signal key_code_1 : STD_LOGIC_VECTOR (7 downto 0);
    
begin
    
    -- forms a shift register of size 2 for the key codes
    shift_process : process (clock, clear)
    begin
        if clear = '1' then
        
            key_code_0 <= X"00";
            key_code_1 <= X"00";
                    
        elsif clock'event and clock = '1' then
            
            if key_event = '1' then
                key_code_0 <= key_code;
                key_code_1 <= key_code_0;
            end if;
            
        end if;
    end process;

    -- tracks whether a key is pressed or not
    output_process : process (clock, clear)
    begin
        if clear = '1' then
        
            key_enter <= '0';
            key_left <= '0';
            key_right <= '0';
            key_up <= '0';
            key_down <= '0';
            key_space <= '0';
                    
        elsif clock'event and clock = '1' then
            
            -- in each conditional block,
            -- first the break code, then the make code of a key is checked
            
            -- ENTER
            if (key_code_1 = X"F0") and (key_code_0 = X"5A") then
                key_enter <= '0';
            elsif key_code_0 = X"5A" then
                key_enter <= '1';
            end if;
            
            -- LEFT ARROW
            if (key_code_1 = X"F0") and (key_code_0 = X"6B") then
                key_left <= '0';
            elsif key_code_0 = X"6B" then
                key_left <= '1';
            end if;
            
            -- RIGHT ARROW
            if (key_code_1 = X"F0") and (key_code_0 = X"74") then
                key_right <= '0';
            elsif key_code_0 = X"74" then
                key_right <= '1';
            end if;
            
            -- UP ARROW
            if (key_code_1 = X"F0") and (key_code_0 = X"75") then
                key_up <= '0';
            elsif key_code_0 = X"75" then
                key_up <= '1';
            end if;
            
            -- DOWN ARROW
            if (key_code_1 = X"F0") and (key_code_0 = X"72") then
                key_down <= '0';
            elsif key_code_0 = X"72" then
                key_down <= '1';
            end if;
            
            -- SPACE
            if (key_code_1 = X"F0") and (key_code_0 = X"29") then
                key_space <= '0';
            elsif key_code_0 = X"29" then
                key_space <= '1';
            end if;
            
        end if;
    end process;
    
end architecture;
