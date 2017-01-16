library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.TETRIS_PACKAGE.ALL;

entity TETRIS is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        red : out STD_LOGIC_VECTOR (3 downto 0);
        green : out STD_LOGIC_VECTOR (3 downto 0);
        blue : out STD_LOGIC_VECTOR (3 downto 0);
        --
        ps2_clk : in STD_LOGIC;
        ps2_data : in STD_LOGIC;
        --
        audio_left : out STD_LOGIC;
        audio_right : out STD_LOGIC
    );
end entity;

architecture BEHV of TETRIS is

    component CLOCK_GENERATOR is
        port(
            clock : in STD_LOGIC;
            clear : in STD_LOGIC;
            --
            clock_out : out STD_LOGIC;
            clock_ten : out STD_LOGIC
        );
    end component;
    
    component VGA_CONTROLLER is
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
    end component;
    
    component IMAGE_SOURCE is
        port(
            board : in BOARD_TYPE;
            next_tetrimino : in TETRIMINO_TYPE;
            next_null : in STD_LOGIC;
            hold_tetrimino : in TETRIMINO_TYPE;
            hold_null : in STD_LOGIC;
            --
            score : in INTEGER range 0 to 999999 ;
            remaining : in INTEGER range 0 to 19;
            stage : in INTEGER range 0 to 8;
            --
            x_coor : in STD_LOGIC_VECTOR (9 downto 0);
            y_coor : in STD_LOGIC_VECTOR (9 downto 0);
            vidon : in STD_LOGIC;
            --
            red : out STD_LOGIC_VECTOR (3 downto 0);
            green : out STD_LOGIC_VECTOR (3 downto 0);
            blue : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    
    component TETRIS_DATA is
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
            random_tetrimino : in TETRIMINO_TYPE
        );
    end component;
    
    component TETRIS_CONTROLLER is
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
            play_music : out STD_LOGIC
        );
    end component;
    
    component RAND_NUM_GEN is
        port(
            clock : in STD_LOGIC;
            clear : in STD_LOGIC;
            --
            start : in STD_LOGIC;
            tetrimino : out TETRIMINO_TYPE
        );        
    end component;
    
    component KEYBOARD_CONTROLLER is
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
    end component;
    
    component KEYBOARD_SOURCE is
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
    end component;
    
    component AUDIO_SOURCE is
        port(
            clock : in STD_LOGIC;
            clear : in STD_LOGIC;
            --
            play : in STD_LOGIC;
            tone : in STD_LOGIC;
            long : in STD_LOGIC;
            audio : out STD_LOGIC
        );
    end component;
    
    signal clock_out : STD_LOGIC;
    signal clock_ten : STD_LOGIC;
    
    signal wire : STD_LOGIC_VECTOR (12 downto 0);
    
    signal wire_board : BOARD_TYPE;
    signal wire_next : TETRIMINO_TYPE;
    signal wire_next_null : STD_LOGIC;
    signal wire_hold : TETRIMINO_TYPE;
    signal wire_hold_null : STD_LOGIC;
    signal wire_tetrimino : TETRIMINO_TYPE;
    
    signal wire_score : INTEGER range 0 to 999999;
    signal wire_remaining : INTEGER range 0 to 19;
    signal wire_stage : INTEGER range 0 to 8;
    
    signal x_coor : STD_LOGIC_VECTOR (9 downto 0);
    signal y_coor : STD_LOGIC_VECTOR (9 downto 0);
    signal vidon : STD_LOGIC;
    
    signal key_code : STD_LOGIC_VECTOR (7 downto 0);
    signal key_event : STD_LOGIC;
    signal key : STD_LOGIC_VECTOR (5 downto 0);
    
    signal audio_mono : STD_LOGIC;
    signal play_music : STD_LOGIC;
    
    signal game_over : STD_LOGIC;
    signal game_reset : STD_LOGIC;
    
begin

    audio_left <= audio_mono;
    audio_right <= audio_mono;
    
    game_reset <= clear or (key(0) and game_over);

    U1 : CLOCK_GENERATOR port map(
        clock => clock,
        clear => clear,
        --
        clock_out => clock_out,
        clock_ten => clock_ten
    );
    
    U2 : VGA_CONTROLLER port map(
        clock => clock_out,
        clear => clear,
        --
        hsync => hsync,
        vsync => vsync,
        x_coor => x_coor,
        y_coor => y_coor,
        vidon => vidon
    );
    
    U3 : IMAGE_SOURCE port map(
        board => wire_board,
        next_tetrimino => wire_next,
        next_null => wire_next_null,
        hold_tetrimino => wire_hold,
        hold_null => wire_hold_null,
        --
        score => wire_score,
        remaining => wire_remaining,
        stage => wire_stage,
        --
        x_coor => x_coor,
        y_coor => y_coor,
        vidon => vidon,
        --
        red => red,
        green => green,
        blue => blue
    );
        
    U4 : TETRIS_DATA port map(
        clock => clock_out,
        clear => game_reset,
        --
        fall => wire(0),
        move_left => wire(1),
        move_right => wire(2),
        rotate => wire(3),
        hold => wire(4),
        --
        can_fall => wire(5),
        can_move_left => wire(6),
        can_move_right => wire(7),
        can_rotate => wire(8),
        can_hold => wire(9),
        --
        merge => wire(10),
        create_new => wire(11),
        line_complete => wire(12),
        game_over => game_over,
        --
        board => wire_board,
        next_tetrimino => wire_next,
        next_null => wire_next_null,
        hold_tetrimino => wire_hold,
        hold_null => wire_hold_null,
        random_tetrimino => wire_tetrimino
    );
    
    U5 : TETRIS_CONTROLLER port map(
        clock => clock_out,
        clock_ten => clock_ten,
        clear => game_reset,
        --
        key_enter => key(0),
        key_left => key(1),
        key_right => key(2),
        key_up => key(3),
        key_down => key(4),
        key_space => key(5),
        --
        fall => wire(0),
        move_left => wire(1),
        move_right => wire(2),
        rotate => wire(3),
        hold => wire(4),
        --
        can_fall => wire(5),
        can_move_left => wire(6),
        can_move_right => wire(7),
        can_rotate => wire(8),
        can_hold => wire(9),
        --
        merge => wire(10),
        create_new => wire(11),
        line_complete => wire(12),
        game_over => game_over,
        --
        score => wire_score,
        remaining => wire_remaining,
        stage => wire_stage,
        play_music => play_music
    );
    
    U6 : RAND_NUM_GEN port map(
        clock => clock_out,
        clear => clear,
        --
        start => key(0),
        tetrimino => wire_tetrimino
    );
    
    U7 : KEYBOARD_CONTROLLER port map(
        clock => clock_out,
        clear => clear,
        --
        ps2_clk => ps2_clk,
        ps2_data => ps2_data,
        --
        key_code => key_code,
        key_event => key_event
    );
    
    U8 : KEYBOARD_SOURCE port map(
        clock => clock_out,
        clear => clear,
        --
        key_code => key_code,
        key_event => key_event,
        --
        key_enter => key(0),
        key_left => key(1),
        key_right => key(2),
        key_up => key(3),
        key_down => key(4),
        key_space => key(5)
    );
    
    U9 : AUDIO_SOURCE port map(
        clock => clock,
        clear => clear,
        --
        play => play_music,
        tone => wire(10),
        long => game_over,
        audio => audio_mono
    );
    
end architecture;
