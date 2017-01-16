library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package TETRIS_PACKAGE is

    constant BOARD_WIDTH : INTEGER := 10;
    constant BOARD_HEIGHT : INTEGER := 20;
    
    type SHAPE_TYPE is (SHAPE_T, SHAPE_SQUARE, SHAPE_LINE, SHAPE_L_LEFT, SHAPE_L_RIGHT, SHAPE_Z_LEFT, SHAPE_Z_RIGHT);
    
    -- BOARD
    type BOARD_TILE_TYPE is record
        shape : SHAPE_TYPE;
        state : STD_LOGIC;
    end record;	
    
    type BOARD_TILE_MATRIX is array(NATURAL range <>, NATURAL range <>) of BOARD_TILE_TYPE;
    subtype BOARD_TYPE is BOARD_TILE_MATRIX(0 to (BOARD_WIDTH - 1), 0 to (BOARD_HEIGHT - 1));
    
    -- TETRIMINO
    type TILE_COOR_TYPE is record
        x : INTEGER range 0 to (BOARD_WIDTH - 1);
        y : INTEGER range 0 to (BOARD_HEIGHT - 1);
    end record;
    
    type TILE_COOR_ARRAY is array(NATURAL range <>) of TILE_COOR_TYPE;
   
    type TETRIMINO_TYPE is record
        shape : SHAPE_TYPE;
        tiles : TILE_COOR_ARRAY(0 to 3);
    end record;
    
    --TETRIMINO DEFINITIONS
    constant TETRIMINO_T : TETRIMINO_TYPE :=
    (
        shape => SHAPE_T,
        tiles => ((x => 1, y => 1), (x => 0, y =>1), (x => 1, y => 0), (x => 2, y => 1))
    );
    
    constant TETRIMINO_SQUARE : TETRIMINO_TYPE :=
    (
        shape => SHAPE_SQUARE,
        tiles => ((x => 1, y => 1), (x => 1, y => 0), (x => 2, y => 0), (x => 2, y => 1))
    );
    
    constant TETRIMINO_LINE : TETRIMINO_TYPE :=
    (
        shape => SHAPE_LINE,
        tiles => ((x => 1, y => 0), (x => 0, y => 0), (x => 2, y => 0), (x => 3, y => 0))
    );
    
    constant TETRIMINO_L_LEFT : TETRIMINO_TYPE :=
    (
        shape => SHAPE_L_LEFT,
        tiles => ((x => 1, y => 1), (x => 0, y => 1), (x => 0, y => 0), (x => 2, y => 1))
    );
    
    constant TETRIMINO_L_RIGHT : TETRIMINO_TYPE :=
    (
        shape => SHAPE_L_RIGHT,
        tiles => ((x => 1, y => 1), (x => 0, y => 1), (x => 2, y => 1), (x => 2, y => 0))
    );
    
    constant TETRIMINO_Z_LEFT : TETRIMINO_TYPE :=
    (
        shape => SHAPE_Z_LEFT,
        tiles => ((x => 1, y => 1), (x => 1, y => 0), (x => 0, y => 0), (x => 2, y => 1))
    );
    
    constant TETRIMINO_Z_RIGHT : TETRIMINO_TYPE :=
    (
        shape => SHAPE_Z_RIGHT,
        tiles => ((x => 1, y => 1), (x => 0, y => 1), (x => 1, y => 0), (x => 2, y => 0))
    );
    
    -- FUNCTIONS
    
    function rotate_function (tetrimino : TETRIMINO_TYPE) return TETRIMINO_TYPE;
    function rotate_border_function (tetrimino : TETRIMINO_TYPE) return BOOLEAN;
    function shape_to_tetrimino (shape : SHAPE_TYPE) return TETRIMINO_TYPE;

end package;

package body TETRIS_PACKAGE is

    function rotate_function (tetrimino : TETRIMINO_TYPE) return TETRIMINO_TYPE is
    
        variable rotated_tetrimino : TETRIMINO_TYPE := TETRIMINO_SQUARE;
        variable deltaX : INTEGER := 0;
        variable deltaY : INTEGER := 0;
    
    begin
        
        if tetrimino.shape = SHAPE_SQUARE then
            return tetrimino;
        end if;
        
        rotated_tetrimino.shape := tetrimino.shape;
        rotated_tetrimino.tiles(0) := tetrimino.tiles(0);
        
        for i in 1 to 3 loop
        
            deltaX := tetrimino.tiles(i).x - tetrimino.tiles(0).x;
            deltaY := tetrimino.tiles(i).y - tetrimino.tiles(0).y;
            
            rotated_tetrimino.tiles(i).x := -deltaY + tetrimino.tiles(0).x;
            rotated_tetrimino.tiles(i).y := deltaX + tetrimino.tiles(0).y;
        
        end loop;
        
        return rotated_tetrimino;
        
    end function;
    
    
    function rotate_border_function (tetrimino : TETRIMINO_TYPE) return BOOLEAN is
       
        variable deltaX : INTEGER := 0;
        variable deltaY : INTEGER := 0;
        
        variable rotatedX : INTEGER := 0;
        variable rotatedY : INTEGER := 0;
    
    begin
       
        if tetrimino.shape = SHAPE_SQUARE then
            return FALSE;
        end if;
        
        for i in 1 to 3 loop
        
            deltaX := tetrimino.tiles(i).x - tetrimino.tiles(0).x;
            deltaY := tetrimino.tiles(i).y - tetrimino.tiles(0).y;
           
            rotatedX := -deltaY + tetrimino.tiles(0).x;
            rotatedY := deltaX + tetrimino.tiles(0).y;
            
            if (rotatedX < 0) or (rotatedX >= BOARD_WIDTH) then
                return TRUE;
            end if;
            
            if (rotatedY < 0) or (rotatedY >= BOARD_HEIGHT) then
                return TRUE;
            end if;
            
        end loop;
        
        return FALSE;
       
    end function;
    
    
    function shape_to_tetrimino (shape : SHAPE_TYPE) return TETRIMINO_TYPE is
        
        variable tetrimino : TETRIMINO_TYPE := TETRIMINO_SQUARE;
        
    begin
        
        if shape = SHAPE_T then
            tetrimino := TETRIMINO_T;
        elsif shape = SHAPE_SQUARE then
            tetrimino := TETRIMINO_SQUARE;
        elsif shape = SHAPE_LINE then
            tetrimino := TETRIMINO_LINE;
        elsif shape = SHAPE_L_LEFT then
            tetrimino := TETRIMINO_L_LEFT;
        elsif shape = SHAPE_L_RIGHT then
            tetrimino := TETRIMINO_L_RIGHT;
        elsif shape = SHAPE_Z_LEFT then
            tetrimino := TETRIMINO_Z_LEFT;
        else --SHAPE_Z_RIGHT
            tetrimino := TETRIMINO_Z_RIGHT;
        end if;
        
        return tetrimino;
        
    end function;
    
end package body;
