library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.AUDIO_PACKAGE.ALL;

entity AUDIO_SOURCE is
    port(
        clock : in STD_LOGIC;
        clear : in STD_LOGIC;
        --
        play : in STD_LOGIC;
        tone : in STD_LOGIC;
        long : in STD_LOGIC;
        audio : out STD_LOGIC
    );
end entity;

architecture BEHV of AUDIO_SOURCE is

    signal note : INTEGER range 0 to NOTE_COUNT - 1 := 0;
    signal duration_counter : INTEGER range 0 to 40000000 - 1 := 0;
    signal pitch : INTEGER range 0 to 100000000 - 1 := 0;
    signal pitch_counter : INTEGER range 0 to 100000000 - 1 := 0;
    signal audio_signal : STD_LOGIC := '0';
    
    constant TONE_PITCH : INTEGER := 45454 - 1;
    signal tone_counter : INTEGER range 0 to TONE_PITCH := 0;
    signal tone_signal : STD_LOGIC := '0';
    signal tone_enable : INTEGER range 0 to 100000000 - 1 := 0;
    
    signal old_play : STD_LOGIC := '0';
    signal old_tone : STD_LOGIC := '0';
    signal old_long : STD_LOGIC := '0';
    
begin

    process (clock, clear)
    begin
        if clear = '1' then
        
            old_play <= '0';
            old_tone <= '0';
            old_long <= '0';
            
        elsif clock'event and clock = '1' then
                
            -- MUSIC
            pitch_counter <= pitch_counter - 1;
            duration_counter <= duration_counter - 1;
            
            if duration_counter = 0 then
            
                -- note is played, advances to the next note
                
                note <= note + 1;
                if note = NOTE_COUNT - 1 then note <= 0; end if;
                duration_counter <= duration_rom(note);
                
                pitch <= pitch_rom(note);
                pitch_counter <= pitch_rom(note);
                
            elsif pitch_counter = 0 then
                
                pitch_counter <= pitch;
                audio_signal <= not audio_signal;
                
            end if;
            
            -- MUSIC RESET
            old_play <= play;
            if (old_play = '0') and (play = '1') then -- on the positive edge of PLAY
                note <= 0;
                duration_counter <= 0;
            end if;
            
            if play = '0' then audio_signal <= '0'; end if;
            
            -- TONE (creates a tone with a certain frequency)
            tone_counter <= tone_counter - 1;
            if tone_counter = 0 then
                tone_counter <= TONE_PITCH;
                tone_signal <= not tone_signal;
            end if;
            
            -- MIXER (blends the tone and the music together)
            tone_enable <= tone_enable - 1;
            if tone_enable = 0 then tone_enable <= 0; end if;
            
            old_tone <= tone;       
            if (old_tone = '0') and (tone = '1') then
                tone_enable <= 10000000 - 1;
            end if;
            
            old_long <= long;       
            if (old_long = '0') and (long = '1') then
                tone_enable <= 100000000 - 1;
            end if;
            
            if tone_enable > 0 then
                audio_signal <= tone_signal;
            end if;
            
        end if;
    end process;

    audio <= audio_signal;
    
end architecture;
