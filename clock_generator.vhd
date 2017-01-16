library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLOCK_GENERATOR is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        clock_out : out STD_LOGIC;
        clock_ten : out STD_LOGIC
    );
end entity;

architecture BEHV of CLOCK_GENERATOR is

    signal out_signal : STD_LOGIC;
    signal out_counter : INTEGER range 0 to 4 - 1;

    signal ten_signal : STD_LOGIC;
    signal ten_counter : INTEGER range 0 to 1000000 - 1; 

begin

    vga_process : process (clock, clear)
    begin
        if clear = '1' then
            
            out_signal <= '0';
            out_counter <= 0;
            
            ten_signal <= '0';
            ten_counter <= 0;
            
        elsif clock'event and clock = '1' then
            
            out_signal <= '0';
            out_counter <= out_counter + 1;
            if out_counter = 4 - 1 then
                out_signal <= '1';
                out_counter <= 0;
            end if;
            
            ten_signal <= '0';
            ten_counter <= ten_counter + 1;
            if ten_counter = 1000000 - 1 then
                ten_signal <= '1';
                ten_counter <= 0;
            end if;
            
        end if;
    end process;
    
    clock_out <= out_signal;
    clock_ten <= ten_signal;
    
end architecture;
