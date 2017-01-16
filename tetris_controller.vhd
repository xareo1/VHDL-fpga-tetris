library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.TETRIS_PACKAGE.ALL;

entity TETRIS_CONTROLLER is
    port(
        clock : in STD_LOGIC;
        clock_ten : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        key_enter : in STD_LOGIC;
        key_left : in STD_LOGIC;
        key_right : in STD_LOGIC;
        key_up : in STD_LOGIC;
        key_down : in STD_LOGIC;
        key_space : in STD_LOGIC;
        --
        fall : out STD_LOGIC;
        move_left : out STD_LOGIC;
        move_right : out STD_LOGIC;
        rotate : out STD_LOGIC;
        hold : out STD_LOGIC;
        --
        can_fall : in STD_LOGIC;
        can_move_left : in STD_LOGIC;
        can_move_right : in STD_LOGIC;
        can_rotate : in STD_LOGIC;
        can_hold : in STD_LOGIC;
        --
        merge : out STD_LOGIC;
        create_new : out STD_LOGIC;
        line_complete : in STD_LOGIC;
        game_over : in STD_LOGIC;
        --
        score : out INTEGER range 0 to 999999 ;
        remaining : out INTEGER range 0 to 19;
        stage : out INTEGER range 0 to 8;
        --
        play_music : out STD_LOGIC
    );
end entity;

architecture BEHV of TETRIS_CONTROLLER is

    signal start_flag : STD_LOGIC;
    
    signal key_left_old : STD_LOGIC;
    signal key_right_old : STD_LOGIC;
    signal key_up_old : STD_LOGIC;
    signal key_down_old : STD_LOGIC;
    signal key_space_old : STD_LOGIC;
    
    constant FALL_DELAY_STANDARD : NATURAL := 50;
    constant FALL_DELAY_FAST : NATURAL := 5;
    signal fall_delay : NATURAL range 0 to 50;
    signal fall_counter : NATURAL range 0 to 50 - 1;
    signal fall_signal : STD_LOGIC;
    
    constant MOVE_DELAY_INITIAL : NATURAL := 25;
    constant MOVE_DELAY_REPEATED : NATURAL := 10;
    signal move_counter : NATURAL range 0 to 25 - 1;
    signal move_signal : STD_LOGIC;
    
    signal score_register : INTEGER range 0 to 999999;
    signal line_complete_old : STD_LOGIC;
    signal line_complete_combo : INTEGER range 0 to 4;
    signal remaining_register : INTEGER range 0 to 19;
    signal stage_register : INTEGER range 0 to 7;
    
    
begin
    
    -- saves the current states of keys to be used in the next clock cycle
    key_process : process (clock, clear)
    begin
        if clear = '1' then
            
            key_left_old <= '0';
            key_right_old <= '0';
            key_up_old <= '0';
            key_down_old <= '0';
            key_space_old <= '0';
            
        elsif clock'event and clock = '1' then
            
            key_left_old <= key_left;
            key_right_old <= key_right;
            key_up_old <= key_up;
            key_down_old <= key_down;
            key_space_old <= key_space;
        
        end if;
    end process;
    
    -- generates the fall signal
    fall_process : process (clock, clear)
    begin
        if clear = '1' then
            
            fall_delay <= FALL_DELAY_STANDARD;
            fall_counter <= FALL_DELAY_STANDARD - 1;
            fall_signal <= '0';
            
        elsif clock'event and clock = '1' then
            
            fall_signal <= '0';
            
            if (key_down_old = '0') and (key_down = '1') then
            
                -- down key is pressed,
                -- fall delay is set to fast,
                -- a fall pulse is immediately sent
                fall_delay <= FALL_DELAY_FAST;
                fall_counter <= FALL_DELAY_FAST - 1;
                fall_signal <= '1';
                
            elsif (key_down_old = '1') and (key_down = '0') then
            
                -- down key is realesed,
                -- fall delay is set to normal
                fall_delay <= FALL_DELAY_STANDARD - stage_register * 5;
                fall_counter <= FALL_DELAY_STANDARD - 1;
                
            else
            
                if clock_ten = '1' then
                    fall_counter <= fall_counter - 1;
                    if fall_counter = 0 then
                        fall_signal <= '1';
                        fall_counter <= fall_delay - 1;
                    end if;
                end if;
                
            end if;
        
        end if;
    end process;
    
    -- generates the move signal
    move_process : process (clock, clear)
    begin
        if clear = '1' then
            
            move_counter <= MOVE_DELAY_INITIAL - 1;
            move_signal <= '0';
            
        elsif clock'event and clock = '1' then
            
            move_signal <= '0';
            
            if ((key_left_old = '0') and (key_left = '1')) or
               ((key_right_old = '0') and (key_right = '1')) then
                
                -- a movement key is pressed,
                -- delay before the next move pulse is increaded,
                -- a move pulse is immediately sent
                move_counter <= MOVE_DELAY_INITIAL - 1;
                move_signal <= '1';
            
            else
            
                if clock_ten = '1' then
                    move_counter <= move_counter - 1;
                    if move_counter = 0 then
                        move_signal <= '1';
                        move_counter <= MOVE_DELAY_REPEATED - 1;
                    end if;
                end if;
            
            end if;
            
        end if;
    end process;
    
    controller_process : process (clock, clear)
    begin
        if clear = '1' then
            
            start_flag <= '0';
            fall <= '0';
            move_left <= '0';
            move_right <= '0';
            rotate <= '0';
            hold <= '0';
            
            merge <= '0';
            create_new <= '0';
            
            play_music <= '0';
            score_register <= 0;
            
            line_complete_old <= '0';
            line_complete_combo <= 0;
            remaining_register <= 19;
            stage_register <= 0;
            
        elsif clock'event and clock = '1' then
        
            -- assumes no action will be taken
            
            fall <= '0';
            move_left <= '0';
            move_right <= '0';
            rotate <= '0';
            hold <= '0';
            
            merge <= '0';
            create_new <= '0';
            
            play_music <= '0';
            
            -- checks whether the game is active or not
            if (start_flag = '1' and game_over = '0') then
            
                if fall_signal = '1' then
                    if can_fall = '1' then
                        fall <= '1';
                    else
                        -- tetrimino reached bottom, needs to be merged
                        merge <= '1';
                        create_new <= '1';
                        score_register <= score_register + 1;
                    end if;
                    
                elsif move_signal = '1' then
                    if (key_left = '1') and (key_right = '0') and (can_move_left = '1') then
                        move_left <= '1';
                    elsif (key_left = '0') and (key_right = '1') and (can_move_right = '1') then
                        move_right <= '1';
                    end if;
                    
                elsif (key_up_old = '0') and (key_up = '1') and (can_rotate = '1') then
                    rotate <= '1';
                    
                elsif (key_space_old = '0') and (key_space = '1') and (can_hold = '1') then
                    hold <= '1';
                    
                end if;
                
                play_music <= '1';
                
                -- LINE_COMPLETE logic
                line_complete_old <= line_complete;
                
                -- when a combo is broken
                if (line_complete_old = '1') and (line_complete = '0') then
                
                    if line_complete_combo = 4 then
                        score_register <= score_register + 160;
                    elsif line_complete_combo = 3 then
                        score_register <= score_register + 90;
                    elsif line_complete_combo = 2 then
                        score_register <= score_register + 40;
                    elsif line_complete_combo = 1 then
                        score_register <= score_register + 10;
                    end if;
                    
                end if; 
                
                line_complete_combo <= 0;
                if line_complete = '1' then
                
                    -- combo counter
                    line_complete_combo <= line_complete_combo + 1;
                    
                    -- stage and remaining logic
                    if stage_register < 8 then
                        remaining_register <= remaining_register - 1;
                        if remaining_register = 0 then
                            remaining_register <= 19;
                            stage_register <= stage_register + 1;
                        end if;
                    end if;
                    
                end if;
                
            else
            
                -- starts the game 
                if key_enter = '1' then
                    start_flag <= '1';
                    create_new <= '1';
                end if;
                
            end if;
            
        end if;
    end process;
    
    score <= score_register;
    remaining <= remaining_register;
    stage <= stage_register;
    
end architecture;
