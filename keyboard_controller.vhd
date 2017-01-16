library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity KEYBOARD_CONTROLLER is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        ps2_clk : in STD_LOGIC;
        ps2_data : in STD_LOGIC;
        --
        key_code : out STD_LOGIC_VECTOR (7 downto 0);
        key_event : out STD_LOGIC
    );
end entity;

architecture BEHV of KEYBOARD_CONTROLLER is
    
    type STATE_TYPE is (start, wait_clock_low, wait_clock_high, get_key_code);
    signal state : STATE_TYPE;
    
    signal ps2_clk_f : STD_LOGIC;
    signal ps2_data_f : STD_LOGIC;
    signal ps2_clk_reg : STD_LOGIC_VECTOR (7 downto 0);
    signal ps2_data_reg : STD_LOGIC_VECTOR (7 downto 0);
    
    signal ps2_word_reg : STD_LOGIC_VECTOR (10 downto 0);
    signal bit_counter : STD_LOGIC_VECTOR (3 downto 0);
    constant BIT_COUNTER_MAX : STD_LOGIC_VECTOR (3 downto 0) := "1011";
    
begin
    
    -- filters clock and data signals of the keyboard using shift registers
    filter_process : process (clock, clear)
    begin
        if clear = '1' then
            
            ps2_clk_reg <= X"00";
            ps2_data_reg <= X"00";
            ps2_clk_f <= '1';
            ps2_data_f <= '1';
            
        elsif clock'event and clock = '1' then
            
            ps2_clk_reg <= ps2_clk & ps2_clk_reg(7 downto 1);
            ps2_data_reg <= ps2_data & ps2_data_reg(7 downto 1);
            
            if ps2_clk_reg = X"FF" then
                ps2_clk_f <= '1';
            elsif ps2_clk_reg = X"00" then
                ps2_clk_f <= '0';
            end if;
            
            if ps2_data_reg = X"FF" then
                ps2_data_f <= '1';
            elsif ps2_data_reg = X"00" then
                ps2_data_f <= '0';
            end if;
            
        end if;
    end process;
    
    -- revieves the series data coming from the keyboard,
    -- when the data transfer is complete,
    -- key_event is set to high for one clock cycle indicating that the data is available 
    state_machine : process (clock, clear)
    begin
        if clear = '1' then
        
            state <= start;
            bit_counter <= "0000";
            ps2_word_reg <= (others => '0');
            key_code <= (others => '0');
            key_event <= '0';
            
        elsif clock'event and clock = '1' then
            
            key_event <= '0'; 
            
            case state is
            
                when start =>
                    if ps2_data_f = '1' then
                        state <= start;
                    else
                        state <= wait_clock_low;
                    end if;
                
                when wait_clock_low =>
                    if bit_counter < BIT_COUNTER_MAX then
                        if ps2_clk_f = '1' then
                            state <= wait_clock_low;
                        else
                            state <= wait_clock_high;
                            ps2_word_reg <= ps2_data_f & ps2_word_reg(10 downto 1);
                        end if;
                    else
                        state <= get_key_code;
                    end if;
                
                when wait_clock_high =>
                    if ps2_clk_f = '0' then
                        state <= wait_clock_high;
                    else
                        state <= wait_clock_low;
                        bit_counter <= bit_counter + 1;
                    end if;
                    
                when get_key_code =>
                    key_code <= ps2_word_reg(9 downto 2);
                    key_event <= '1';
                    bit_counter <= "0000";
                    state <= wait_clock_low;
                
            end case;
            
        end if;
    end process;    
    
end architecture;
