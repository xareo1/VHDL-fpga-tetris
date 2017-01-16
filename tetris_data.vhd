library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.TETRIS_PACKAGE.ALL;

entity TETRIS_DATA is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        fall : in STD_LOGIC;
        move_left : in STD_LOGIC;
        move_right : in STD_LOGIC;
        rotate : in STD_LOGIC;
        hold : in STD_LOGIC;
        --
        can_fall : out STD_LOGIC;
        can_move_left : out STD_LOGIC;
        can_move_right : out STD_LOGIC;
        can_rotate : out STD_LOGIC;
        can_hold : out STD_LOGIC;
        --
        merge : in STD_LOGIC;
        create_new : in STD_LOGIC;
        line_complete : out STD_LOGIC;
        game_over : out STD_LOGIC;
        --
        board : out BOARD_TYPE;
        next_tetrimino : out TETRIMINO_TYPE;
        next_null : out STD_LOGIC;
        hold_tetrimino : out TETRIMINO_TYPE;
        hold_null : out STD_LOGIC;
        --
        random_tetrimino : in TETRIMINO_TYPE
    );
end entity;

architecture BEHV of TETRIS_DATA is

    signal board_data : BOARD_TYPE;
    signal board_view : BOARD_TYPE;
    signal check_line : STD_LOGIC;
       
    signal tetrimino_data : TETRIMINO_TYPE;
    signal tetrimino_temp : TETRIMINO_TYPE;
    signal tetrimino_null : STD_LOGIC;
    
    signal tetrimino_next : TETRIMINO_TYPE;
    signal tetrimino_next_null : STD_LOGIC;
    
    signal tetrimino_hold : TETRIMINO_TYPE;
    signal tetrimino_hold_null : STD_LOGIC;
     
begin

    tetrimino_process : process (clock, clear)
    begin
        if clear = '1' then
        
            tetrimino_data <= TETRIMINO_SQUARE;
            tetrimino_null <= '1';
            
            tetrimino_next <= TETRIMINO_SQUARE;
            tetrimino_next_null <= '1';
            
            tetrimino_hold <= TETRIMINO_SQUARE;
            tetrimino_hold_null <= '1';
            
            can_hold <= '0';
            
        elsif clock'event and clock = '1' then
        
            if create_new = '1' then
            
                if tetrimino_next_null = '1' then
                
                    -- creates the first tetrimino which starts the game
                    tetrimino_data.shape <= random_tetrimino.shape;
                    for i in 0 to 3 loop
                        tetrimino_data.tiles(i).x <= random_tetrimino.tiles(i).x + 3;
                        tetrimino_data.tiles(i).y <= random_tetrimino.tiles(i).y;
                    end loop;
                    tetrimino_null <= '0';
                    
                else
                
                    -- copies the next tetrimino if available
                    tetrimino_data.shape <= tetrimino_next.shape;
                    for i in 0 to 3 loop
                        tetrimino_data.tiles(i).x <= tetrimino_next.tiles(i).x + 3;
                        tetrimino_data.tiles(i).y <= tetrimino_next.tiles(i).y;
                    end loop;
                    tetrimino_next <= random_tetrimino;
                    
                end if;
                
                can_hold <= '1'; -- a new tetrimino was created, can hold
                
            elsif hold = '1' then
            
                can_hold <= '0'; -- hold ability was used
            
                -- holds the current tetrimino           
                tetrimino_hold <= shape_to_tetrimino(tetrimino_data.shape);
                tetrimino_hold_null <= '0';
                                    
                if tetrimino_hold_null = '0' then
                
                    -- since there is no tetrimino that was previously held,
                    -- copies the next tetrimino
                    tetrimino_data.shape <= tetrimino_hold.shape;
                    for i in 0 to 3 loop
                        tetrimino_data.tiles(i).x <= tetrimino_hold.tiles(i).x + 3;
                        tetrimino_data.tiles(i).y <= tetrimino_hold.tiles(i).y;
                    end loop;
                    
                else
                
                    -- brings back the previously held tetrimino
                    tetrimino_data.shape <= tetrimino_next.shape;
                    for i in 0 to 3 loop
                       tetrimino_data.tiles(i).x <= tetrimino_next.tiles(i).x + 3;
                       tetrimino_data.tiles(i).y <= tetrimino_next.tiles(i).y;
                    end loop;
                    tetrimino_next <= random_tetrimino;
                    
                end if;
                
            else
            
                -- DATA and TEMP relation
                tetrimino_data <= tetrimino_temp;               
                
            end if;
            
            -- copies a random tetrimino to the next tetrimino after the first tetrimino is created
            if tetrimino_null = '0' and tetrimino_next_null = '1' then
                tetrimino_next <= random_tetrimino;
                tetrimino_next_null <= '0';
            end if;
            
        end if;
    end process;
    
    next_tetrimino <= tetrimino_next;
    next_null <= tetrimino_next_null;
    
    hold_tetrimino <= tetrimino_hold;
    hold_null <= tetrimino_hold_null;
    
    -- determines the TEMP tetrimino which is the next state of DATA tetrimino
    move_process : process (tetrimino_data, fall, move_left, move_right, rotate)
    begin
    
        -- assumes the tetrimino will not change
        tetrimino_temp <= tetrimino_data;
        
        if fall = '1' then
            for i in 0 to 3 loop
                tetrimino_temp.tiles(i).y <= tetrimino_data.tiles(i).y + 1;
            end loop;
            
        elsif move_left = '1' then
            for i in 0 to 3 loop
                tetrimino_temp.tiles(i).x <= tetrimino_data.tiles(i).x - 1;
            end loop;
            
        elsif move_right = '1' then
            for i in 0 to 3 loop
                tetrimino_temp.tiles(i).x <= tetrimino_data.tiles(i).x + 1;
            end loop;
            
        elsif rotate = '1' then
            tetrimino_temp <= rotate_function(tetrimino_data);
            
        end if;
            
    end process;
    
    -- determines the possible actions for the next clock cycle
    canmove_process : process (tetrimino_data, board_data)
    begin
    
        -- assumes every action is possible, eleminates the impossible ones
        can_fall <= '1';
        can_move_left <= '1';
        can_move_right <= '1';
        can_rotate <= '1';
        
        for i in 0 to 3 loop
        
            -- in each conditional statement,
            -- first the overflow of the game area is checked,
            -- then the collision with the stacked tetriminos is checked
            
            if (tetrimino_data.tiles(i).y = BOARD_HEIGHT - 1) or
               (board_data(tetrimino_data.tiles(i).x, tetrimino_data.tiles(i).y + 1).state = '1') then
                can_fall <= '0';
            end if;
            
            if (tetrimino_data.tiles(i).x = 0) or
               (board_data(tetrimino_data.tiles(i).x - 1, tetrimino_data.tiles(i).y).state = '1') then
                can_move_left <= '0';
            end if;
            
            if (tetrimino_data.tiles(i).x = BOARD_WIDTH - 1) or
               (board_data(tetrimino_data.tiles(i).x + 1, tetrimino_data.tiles(i).y).state = '1') then
                can_move_right <= '0';
            end if;
            
            if (rotate_border_function(tetrimino_data)) or 
               (board_data(rotate_function(tetrimino_data).tiles(i).x, rotate_function(tetrimino_data).tiles(i).y).state = '1') then
                can_rotate <= '0';
            end if;
            
        end loop;
    end process;
    
    board_data_process : process (clock, clear)
        
        variable line_complete_var : BOOLEAN := FALSE;
        
    begin
        if clear = '1' then
            
            for x in 0 to BOARD_WIDTH - 1 loop
                for y in 0 to BOARD_HEIGHT - 1 loop
                    board_data(x, y).shape <= SHAPE_SQUARE;
                    board_data(x, y).state <= '0';
                end loop;
            end loop;
            check_line <= '0';
            line_complete <= '0';
                        
        elsif clock'event and clock = '1' then
            
            if merge = '1' then
                
                --merges the tetrimino to the stack
                for i in 0 to 3 loop
                    board_data(tetrimino_data.tiles(i).x, tetrimino_data.tiles(i).y).shape <= tetrimino_data.shape;
                    board_data(tetrimino_data.tiles(i).x, tetrimino_data.tiles(i).y).state <= '1'; 
                end loop;
                check_line <= '1'; -- a line check must be done afterwards
                
            elsif check_line = '1' then
            
                -- checks whether there are completed lines
                check_line <= '0';
                line_complete <= '0';
                
                for j in 0 to BOARD_HEIGHT - 1 loop -- for each line
                    
                    line_complete_var := TRUE;
                    for i in 0 to BOARD_WIDTH - 1 loop
                        line_complete_var := line_complete_var and (board_data(i, j).state = '1');
                    end loop;
                    
                    if line_complete_var then
                    
                        -- there was at least one completed line,
                        -- another line check must be done in the next clock cyle,
                        -- this continues until no completed line is found 
                        check_line <= '1';
                        line_complete <= '1';
                        
                        -- deletes the completed line
                        for k in j downto 0 loop
                            if k = 0 then
                                for i in 0 to BOARD_WIDTH - 1 loop
                                    board_data(i, k).state <= '0';
                                end loop;
                            else
                                for i in 0 to BOARD_WIDTH - 1 loop
                                    board_data(i, k).shape <= board_data(i, k - 1).shape;
                                    board_data(i, k).state <= board_data(i, k - 1).state;
                                end loop;
                            end if;
                        end loop;
                        
                    end if;
                    
                end loop; -- end of for each line
            
            end if; -- end of check line
            
        end if;
    end process;
    
    -- generates the board state in which the tetrimino is merged,
    -- this board state is to be displayed 
    board_view_process : process (board_data, tetrimino_data, tetrimino_null)
    begin
    
        for x in 0 to BOARD_WIDTH - 1 loop
            for y in 0 to BOARD_HEIGHT - 1 loop
                board_view(x, y).shape <= board_data(x,y).shape;
                board_view(x, y).state <= board_data(x,y).state;
            end loop;
        end loop;
        
        if tetrimino_null = '0' then
            for i in 0 to 3 loop
                board_view(tetrimino_data.tiles(i).x, tetrimino_data.tiles(i).y).shape <= tetrimino_data.shape;
                board_view(tetrimino_data.tiles(i).x, tetrimino_data.tiles(i).y).state <= '1'; 
            end loop;
        end if;
        
    end process;
    
    board <= board_view;
    
    -- if the game is started (that is the tetrimino is not null),
    -- and the tetrimino collides with the stack (which can only happen when a new tetrimino is created in such a way,
    -- the game is over
    game_over_process : process (board_data, tetrimino_data, tetrimino_null)
    begin
    
        game_over <= '0';
        if tetrimino_null = '0' then
            for i in 0 to 3 loop
                if board_data(tetrimino_data.tiles(i).x, tetrimino_data.tiles(i).y).state = '1' then
                    game_over <= '1';
                end if;
            end loop;
        end if;
    
    end process;
    
end architecture;