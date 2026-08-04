;===================================================================================================
; Timebomb
; Based on BASIC type in program in Compute! July 1983 by Doug Smoak
; Dave Curran 2024-06-12
; Revised 2026-01-13, 2026-07-19, 2026-07-31, 2026-08-03
;===================================================================================================

; ACME.exe timebomb.asm
; or
; ACME.exe -r timebomb.lst timebomb.asm

!to "timebomb.prg",cbm

!source "defines.asm"

; BASIC loader stub
; 6502 SYS 4109
*=$1001
    !word end_of_stub                   ; link to next line (end of BASIC stub)
    !word 6502                          ; line number (can be anything, so why not)
    !byte SYS                           ; SYS token
    !text "4109"                        ; start of init code ($100D)
    !byte 0                             ; end of line
end_of_stub
    !word 0                             ; end of BASIC stub

;===================================================================================================
; Initialise
;===================================================================================================
    lda VIA1_TIMER2_LSB                 ; seed RND from the VIA timer
    sta SEED_LSB
    lda VIA1_TIMER2_MSB
    sta SEED_MSB

start:
    ldy #0                              ; (leave Y as 0)

    sty FOUND                           ; not found
    sty ROUND_UNITS                     ; rount 0
    sty ROUND_TENS                      ;
    sty TIMER_UNITS                     ; timer 0
    sty TIMER_TENS                      ;
    sty PENALTY                         ; no penalty to start with

    lda #CHAR_UP                        ; Initial player character facing North
    sta PLAYER_CHARACTER

;===================================================================================================
; Prepare the data structures
;===================================================================================================

; All arrays are indexed on direction
    ; 0 = right
    ; 1 = up
    ; 2 = left
    ; 3 = down

; Build the single direction array
    lda #MOVE_RIGHT
    sta DIRECTION
    lda #MOVE_UP
    sta DIRECTION + 1
    lda #MOVE_LEFT
    sta DIRECTION + 2
    lda #MOVE_DOWN
    sta DIRECTION + 3

; Build the double direction array
    lda #2*MOVE_RIGHT
    sta DOUBLE_DIRECTION
    lda #2*MOVE_UP
    sta DOUBLE_DIRECTION + 1
    lda #2*MOVE_LEFT
    sta DOUBLE_DIRECTION + 2
    lda #2*MOVE_DOWN
    sta DOUBLE_DIRECTION + 3

; build the direction character array
    lda #CHAR_RIGHT
    sta CHAR_DIRECTION
    lda #CHAR_UP
    sta CHAR_DIRECTION + 1
    lda #CHAR_LEFT
    sta CHAR_DIRECTION + 2
    lda #CHAR_DOWN
    sta CHAR_DIRECTION + 3

;===================================================================================================
; fill maze with walls
;===================================================================================================
    lda #<MAZE_TOP                      ; DST points to the top of the maze
    sta DST_LSB
    lda #>MAZE_TOP
    sta DST_MSB

    ldx #>MAZE_END+1                    ; pre-calculate the end point

    lda #CHAR_WALL                      ; fill with wall characters
-
    sta (DST),y
    inc DST_LSB
    bne -
    inc DST_MSB
    cpx DST_MSB
    bne -

; add all the spaces down the right hand side
    lda #>MAZE_END_OF_TOP_LINE          ; start at the end of the top line
    sta DST_MSB
    lda #<MAZE_END_OF_TOP_LINE
    sta DST_LSB

    ldx #MAZE_HEIGHT                    ; 66 times

-   lda #CHAR_PATH                      ; store a space
    sta (DST),y

    lda DST_LSB                         ; move down 1 line
    clc
    adc #MAZE_WIDTH
    sta DST_LSB
    bcc +
    inc DST_MSB
+
    dex                                 ; loop until complete
    bne -

; add a row of spaces at the top and bottom
    lda #CHAR_PATH                      ; store a space
    ldx #MAZE_WIDTH                     ; over the whole maze width

-   dex
    sta MAZE_TOP,x
    sta MAZE_END+1,x
    bne -

; leave a space where the player starts
    sta MAZE_PLAYER_START

;===================================================================================================
; Build the paths
;===================================================================================================

; start in the middle
    lda #<MAZE_MIDDLE                   ; set current sqaureto the middle of the maze
    sta CURRENT_SQUARE_LSB
    lda #>MAZE_MIDDLE
    sta CURRENT_SQUARE_MSB

next_move:

;######################## DEBUG ##################################

; DEBUG_SRC_LSB           = $F0
; DEBUG_SRC_MSB           = $F1
; DEBUG_SRC               = DEBUG_SRC_LSB

; DEBUG_DST_LSB           = $F2
; DEBUG_DST_MSB           = $F3
; DEBUG_DST               = DEBUG_DST_LSB

;     lda #COLOUR_BLUE                    ; all text colour to blue
; -   sta COLOUR_RAM_PAGE0,y
;     sta COLOUR_RAM_PAGE1,y
;     iny
;     bne -

;     lda #<MAZE_DEBUG_OFFSET
;     sta DEBUG_SRC_LSB
;     lda #>MAZE_DEBUG_OFFSET
;     sta DEBUG_SRC_MSB

;     sty DEBUG_DST_LSB                   ; set the destination to the screen at 1E00
;     lda #>SCREEN_RAM
;     sta DEBUG_DST_MSB

; -   lda (DEBUG_SRC),y                   ; copy character
;     cmp #4
;     bcs +
;     ;clc                                 ; 0-3 -> "0"-"3"
;     ;adc #$30
;     tax                                 ; 0-3 -> direction characters
;     lda CHAR_DIRECTION,x
; +
;     sta (DEBUG_DST),y

;     inc DEBUG_SRC_LSB
;     bne +
;     inc DEBUG_SRC_MSB

; +   inc DEBUG_DST_LSB
;     bne -
;     inc DEBUG_DST_MSB
;     lda DEBUG_DST_MSB                   ; check for end of screen RAM
;     cmp #$20
;     bne -                               ; not finished yet, continue

;     ldx #$08                            ; delay
; -   dey                                 ;
;     bne -                               ;
;     dex                                 ;
;     bne -                               ;

;#####################################################################


; get a random direction
    jsr RAND16                          ; get a random number
    and #$03                            ; mask off all but the lower two bits (A=0-3)

    sta DIRECTION_INDEX                 ; save the number
    sta INITIAL_DIRECTION

start_path:
; work out the location two squares in that direction
    lda CURRENT_SQUARE_MSB              ; copy the MSB first
    sta CHECK_SQUARE_MSB

    ldx DIRECTION_INDEX                 ; put the current direction into X
    lda DOUBLE_DIRECTION,x              ; get the signed direction offset

    bpl +                               ; 2 places in the direction
    dec CHECK_SQUARE_MSB                ; if the offset is negative, decrement the MSB
+   clc
    adc CURRENT_SQUARE_LSB              ; now add the LSB
    sta CHECK_SQUARE_LSB
    bcc +
    inc CHECK_SQUARE_MSB                ; increment MSB if there was a carry
+

; is there a wall there?
    lda (CHECK_SQUARE),y                ; check what is at the check square (Y=0)
    cmp #CHAR_WALL                      ; is it a wall?
    bne not_wall                        ; no, a previous path or the edge, skip

    txa                                 ; store the direction index there
    sta (CHECK_SQUARE),y

; work out the location of the square between here and where we just checked
    lda DIRECTION,x                     ; get the signed direction offset

    bpl +
    dec CURRENT_SQUARE_MSB              ; if the offset is negative, decrement the MSB
+   clc
    adc CURRENT_SQUARE_LSB              ; now add the LSB
    sta CURRENT_SQUARE_LSB
    bcc +
    inc CURRENT_SQUARE_MSB              ; increment MSB if there was a carry
+

    lda #CHAR_PATH                      ; set this to a path (space)
    sta (CURRENT_SQUARE),y

; jump over the newly created space to the one we previously looked at
; this is basically draughts
    lda CHECK_SQUARE_MSB
    sta CURRENT_SQUARE_MSB
    lda CHECK_SQUARE_LSB
    sta CURRENT_SQUARE_LSB

    jmp next_move                       ; keep moving

; we hit a previous path or the edge of the screen
not_wall:
    ; rotate 90 degrees counter-clockwise

    ; 0 = right -> up
    ; 1 = up    -> left
    ; 2 = left  -> down
    ; 3 = down  -> right

    inc DIRECTION_INDEX                 ; 0123 > 1234
    lda DIRECTION_INDEX                 ;
    and #$03                            ; 1234 > 1230
    sta DIRECTION_INDEX                 ;

    cmp INITIAL_DIRECTION               ; are we back to the direction we started?
    bne start_path                      ; no, have another go

; check the current square
    lda (CURRENT_SQUARE),y              ; x is what is at the current square
    tax

    lda #CHAR_PATH                      ; now make it a path
    sta (CURRENT_SQUARE),y

    cpx #4                              ; was it a previous direction index number?
    bcs next_round                      ; no, we must be back at the start, the maze is complete

; we can't go any further from this point, in any direction, retrace our steps
    lda DOUBLE_DIRECTION,x              ; get signed direction offset
    sta TEMP                            ; save for later
    bpl +
    inc CURRENT_SQUARE_MSB              ; if the offset is negative, increment the MSB
+   sec
    lda CURRENT_SQUARE_LSB              ; now subtract the offset from the LSB
    sbc TEMP
    sta CURRENT_SQUARE_LSB
    bcs +
    dec CURRENT_SQUARE_MSB              ; decrement MSB if there was a carry
+
    jmp next_move

;===================================================================================================
; Start a new round
;===================================================================================================
next_round:
    sty OLD_PLAYER_LSB                  ; clear the old me position
    sty OLD_PLAYER_MSB

; Set the location of the timebomb
; the bomb is always on the 10th row from the top, but any position horizontally
select_bomb_location:
    lda #>MAZE_START_OF_BOMB_LINE       ; start with the MSB.
    sta TIMEBOMB_MSB

; Get a random number from 0-19
; LSB masked gives number from 0-3
; MSB shifted into carry gives number 0-1
; MSB remainder masked gives number from 0-15
; total 0-19

get_rand
    jsr RAND16                          ; A now contains an 8 bit random number
    and #$03                            ; now have number from 0-3
    sta TEMP                            ; save for later
    lda SEED_LSB                        ; get another 8 bits of random number
    ror                                 ; shift 1 bit of that number into carry, 0-1
    and #$0F                            ; now have a number from 0-15
    adc TEMP                            ; now add the number from 0-3, and the 0-1 carry

    adc #<MAZE_START_OF_BOMB_LINE       ; add to the location
    sta TIMEBOMB_LSB
    bcc +                               ; incrememnt MSB if necessary
    inc TIMEBOMB_MSB
+

; check timebomb location
    lda (TIMEBOMB),y                    ; lets see what's at this timebomb location
    cmp #CHAR_PATH                      ; is it a space?
    bne select_bomb_location            ; no, then try again

    lda #CHAR_BOMB                      ; plant the timebomb
    sta (TIMEBOMB),y

;===================================================================================================
; Setup VIC and fill the colour memory
;===================================================================================================
    lda #$EE                            ; set the screen and border colours purple / light blue
    sta VIC_BORDER

    lda #COLOUR_LIGHTRED                ; all text colour to light red
-   sta COLOUR_RAM_PAGE0,y
    sta COLOUR_RAM_PAGE1,y
    iny
    bne -

    lda #<MAZE_START_OFFSET             ; set the maze offset so player is in middle of screen
    sta OFFSET_LSB
    lda #>MAZE_START_OFFSET
    sta OFFSET_MSB

    jsr draw_screen                     ; draw the starting view of the maze

;===================================================================================================
; Intro Sound
;===================================================================================================
intro:
    lda #$F0                            ; Start at 240

intro1:
    sta VIC_OSC1_FREQ, y                ; make the sound
    ldx #0

intro2:
    stx VIC_VOLUME

    ldx #$0C                            ; short delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

    ldx VIC_VOLUME                      ; get X back
    inx
    cpx #$0F
    bne intro2

    stx VIC_VOLUME                      ; set the volume to max

    sec                                 ; drop the frequency
    sbc #04
    cmp #$D0                            ; reached 208?
    bcs intro1                          ; no

    sty VIC_OSC1_FREQ                   ; stop the oscillator

; Position player
    lda #<SCREEN_START_ME               ; position player in the middle of screen
    sta PLAYER_LSB
    lda #>SCREEN_START_ME
    sta PLAYER_MSB

;===================================================================================================
; Main Loop
;===================================================================================================
main_loop:
    lda JIFFY_LSB                       ; wait until not an 8th frame
    and #$07
    beq main_loop

-   lda JIFFY_LSB                       ; wait until an 8th frame
    and #$07
    bne -

; clear previous player position
    lda #CHAR_PATH                      ; first time around OLD_PLAYER is at $0000
    sta (OLD_PLAYER),y

; clear the colour of that square
    lda OLD_PLAYER_MSB                  ; add the offset from screen to colour RAM
    clc
    adc #COLOUR_RAM_OFFSET_MSB
    sta DST_MSB

    lda OLD_PLAYER_LSB                  ; LSB remains the same
    sta DST_LSB

    lda #COLOUR_LIGHTRED                ; set to background colour
    sta (DST),y

; set new player position
    lda PLAYER_CHARACTER                ; set the direction character
    sta (PLAYER),y

; set the colour of that square
    lda PLAYER_MSB                      ; add the offset from screen to colour RAM
    clc
    adc #COLOUR_RAM_OFFSET_MSB
    sta DST_MSB

    lda PLAYER_LSB                      ; LSB remains the same
    sta DST_LSB

    lda #COLOUR_YELLOW                  ; set player colour yellow
    sta (DST),y

; has the bomb been found?
    lda FOUND                           ; check F, has player found the bomb?
    beq +
    jmp bomb_found                      ; if so, round is complete

; incrememnt the timer
+   inc TIMER_UNITS                     ; timer is stored as tens and units to simplify things

    lda TIMER_UNITS
    cmp #10
    bcc +
    inc TIMER_TENS                      ; timer hit 10, increment tens
    sty TIMER_UNITS                     ; reset units (Y=0)
+

; only tick on alternate cycles
    ror                                 ; check bit 0, if clear it is odd, so skip ticking
    bcc check_joystick

; odd cycle, how are we doing?
    lda TIMER_TENS                      ; only need to check the tens
    cmp #60
    bcc tick                            ; we're ok, kiip ticking
    jmp timed_out                       ; timed out, round over

;======================================================================================
; Ominous ticking
;======================================================================================
tick:
    lda #4                              ; pass 1, set volume to 4

tock:
    sta VIC_VOLUME                      ; v

    ; set vic oscillator based on remaining time
    ; max TIMER_TENS is 60, doubled max is 120.
    ; Range is 128-248

    lda TIMER_TENS                      ; get the tens
    asl                                 ; double it
    ora #$80                            ; add 128

    sta VIC_OSC2_FREQ                   ; set the frequency

    ldx #$08
-   dey                                 ; short delay
    bne -                               ;
    dex                                 ;
    bne -                               ;

    lda #8                              ; was VIC_VOLUME 8 already ?
    cmp VIC_VOLUME
    bne tock                            ; no, loop again, this time at volume 8

    sty VIC_OSC2_FREQ                   ; disable the oscillator (Y=0)

;======================================================================================
; Check joystick and move
;======================================================================================
check_joystick:
    lda VIA1_PORTA                      ; read port A where three of the joystick pins are
    tax                                 ; save value

    and #8
    bne +                               ; skip if not zero (active)
    ldx #DOWN                           ; set new direction
    bne move_player                     ; jump always
+
    txa                                 ; get back the port reading
    and #16
    bne +                               ; skip if not zero (active)
    ldx #LEFT                           ; set new direction
    bne move_player
+
    txa                                 ; get back the port reading
    and #4
    bne +                               ; skip if not zero (active)
    ldx #UP                             ; set new direction
    bne move_player

+
    lda #$7F                            ; set joystick3 as input
    sta VIA2_DDRB

    lda VIA2_PORTB                      ; read the port

    ldx #$FF
    stx VIA2_DDRB                       ; back to all inputs for keyboard scanning

    and #$80                            ; mask of the pin
    bne back_to_main_loop               ; nothing moving, back to main loop
    ldx #RIGHT                          ; set new direction

; try to move the player
move_player:
    lda PLAYER_LSB                      ; save the old location
    sta OLD_PLAYER_LSB
    lda PLAYER_MSB
    sta OLD_PLAYER_MSB

    lda CHAR_DIRECTION,x                ; get new player direction character
    sta PLAYER_CHARACTER

    lda DIRECTION,x                     ; get new player direction
    bpl +
    dec PLAYER_MSB                      ; if direction is negative, decrement the MSB
+   clc
    adc PLAYER_LSB
    sta PLAYER_LSB
    bcc +
    inc PLAYER_MSB
+

; check new location
    lda (PLAYER),y

    cmp #CHAR_PATH                      ; is it a clear path?
    beq ok_to_move                      ; yes, that's ok

    cmp #CHAR_BOMB                      ; is it a bomb?
    bne must_be_a_wall                  ; no
    inc FOUND                           ; yes, set found
    bne back_to_main_loop               ; back to the main loop to tidy up first

must_be_a_wall:
    lda OLD_PLAYER_LSB                  ; me = old me - you can't want into walls
    sta PLAYER_LSB
    lda OLD_PLAYER_MSB
    sta PLAYER_MSB

back_to_main_loop:
    jmp main_loop

; it is OK to move
ok_to_move:

; check if we need to scroll down now
    lda PLAYER_MSB                      ; is the player on the line above centre?
    cmp #>SCREEN_LINE_ABOVE_ME
    bne +
    lda PLAYER_LSB
    cmp #<SCREEN_LINE_ABOVE_ME
+
    bcs check_scroll_up

; yes, move the offset up and the player down
    lda #MOVE_UP                        ; offset = offset - 1 row
    dec OFFSET_MSB                      ; pre-decrement MSB for subtraction
    ldx #MOVE_DOWN                      ; player = player + 1 row
    bne scroll                          ; jump always

check_scroll_up:
    lda PLAYER_MSB                      ; is the player on the line below centre?
    cmp #>SCREEN_LINE_BELOW_ME
    bne +
    lda PLAYER_LSB
    cmp #<SCREEN_LINE_BELOW_ME
+
    bcc back_to_main_loop               ; no

; yes, move the offset down and the player up
    lda #MOVE_DOWN                      ; offset = offset + 1 row
    ldx #MOVE_UP                        ; player = player - 1 row
    dec PLAYER_MSB                      ; pre-decrement MSB for subtraction

; adjust offset view
scroll:
    clc                                 ; a contains + or - 1 row
    adc OFFSET_LSB
    sta OFFSET_LSB
    bcc +
    inc OFFSET_MSB
+

; move player back to the centre line
    txa                                 ; x contains + or - 1 row
    clc
    adc PLAYER_LSB
    sta PLAYER_LSB
    bcc +
    inc PLAYER_MSB
+

; redraw the screen
    jsr draw_screen

; back to the start
    jmp main_loop


;===================================================================================================
; Timeout, bomb explodes
;===================================================================================================
timed_out:
    lda #$0F                            ; set full volume
    sta VIC_VOLUME

    ldx #$FF                            ; start at 255
fizz:
    stx VIC_OSC1_FREQ                   ; set the frequency

; change the addressing to mess up the screen
    lda #$FF
    sta VIC_ADDRESSING

    ldx #$09                            ; short delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

; change the addressing to mess up the screen
    lda #$F2
    sta VIC_ADDRESSING                  ; v-9 = 242

    ldx #$09                            ; short delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

    lda #$F0
    sta VIC_ADDRESSING                  ; v-9 = 240

    ldx VIC_OSC1_FREQ                   ; what's the frequency Kenneth?
    dex                                 ; reduce it
    dex
    bmi fizz                            ; loop when until < 128

    ; now the explosion

    lda #$DC                            ; set the noise frequency
    sta VIC_NOISE_FREQ

    lda #$96                            ; change the colours
    sta VIC_BORDER

    ldx #$0A                            ; loop 10 times

flash:
    dey                                 ; delay
    bne flash

    dec VIC_BORDER                      ; flash the border colour
    dex
    bne flash

    dec VIC_VOLUME                      ; reduce the colume
    bne flash

; silence
    sty VIC_NOISE_FREQ                  ; stop the noice

    lda #$EE                            ; back to normal
    sta VIC_BORDER

    jsr end_of_round                    ; display "ROUND R, PRESS F7"

    jmp start                           ; restart with a new maze (since you blew the old one up)

;===================================================================================================
; Success
;===================================================================================================
bomb_found:
    lda #CHAR_PATH                      ; dispose of the timebomb
    sta (TIMEBOMB),y

    lda #$FD
    sta VIC_NOISE_FREQ                  ; defusing noise

    ldx #$0F                            ; g = 30, x = g/2 = 15

defuse:
    stx VIC_VOLUME                      ; v = g/2 = x

    ldx #$35                            ; delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

    ldx VIC_VOLUME                      ; get X back

    dex
    bne defuse

; reduce the available time for the next round
    clc
    lda PENALTY                         ; add 5 seconds penalty
    adc #$05
    sta PENALTY

    cmp #$2D                            ; have we gone too far?
    bcc +
    lda #$2D                            ; limit the maximum penalty
    sta PENALTY
+

    sty VIC_NOISE_FREQ                  ; stop the noise
    sty FOUND                           ; the bomb has not been found

    lda PENALTY                         ; start the timer, with the penalty
    sta TIMER_TENS
    sty TIMER_UNITS

; increment the round number
    inc ROUND_UNITS
    lda ROUND_UNITS
    cmp #10                             ; has it reached 10?
    bcc +
    sty ROUND_UNITS                     ; clear and increment the 10s count
    inc ROUND_TENS
+
    jsr end_of_round                    ; display "ROUND R, PRESS F7"

    jmp next_round                      ; next round

;===================================================================================================
; end of round, print ROUND R - PRESS F7
;===================================================================================================
end_of_round:
    ldx #TEXT_LEN-1                     ; write out two 8 character strings

-   lda TEXT_ROUND_x,x                  ; "ROUND   "
    sta SCREEN_RAM_LINE_00,x
    lda TEXT_PRESS_F7,x                 ; "PRESS F7"
    sta SCREEN_RAM_LINE_02,x

    lda #COLOUR_BLUE                    ; both blue
    sta COLOUR_RAM_LINE_00,x
    sta COLOUR_RAM_LINE_02,x

    dex
    bpl -

; display the round number
    lda ROUND_TENS                      ; any tens?
    beq single

    ; double digit
    clc                                 ; make printable (0->"0")
    adc #$30
    sta SCREEN_RAM + 6

    lda ROUND_UNITS
    clc                                 ; make printable (0->"0")
    adc #$30
    sta SCREEN_RAM + 7
    bne check_key                       ; branch always

single:
    ; single digit
    lda ROUND_UNITS
    clc                                 ; make printable (0->"0")
    adc #$30
    sta SCREEN_RAM + 6

check_key:
    lda LAST_KEY                        ; check last key pressed
    cmp #KEY_F7                         ; was it F7?
    bne check_key                       ; no, keep checking

    rts                                 ; yes, return

;===================================================================================================
; redraw the screen
;===================================================================================================
draw_screen:
    lda OFFSET_LSB                      ; set the source (offset into the map bitmap)
    sta SRC_LSB
    lda OFFSET_MSB
    sta SRC_MSB

    sty DST_LSB                         ; set the destination to the screen RAM
    lda #>SCREEN_RAM
    sta DST_MSB

-   lda (SRC),y                         ; copy character
    sta (DST),y

    inc SRC_LSB                         ; move the source pointer
    bne +
    inc SRC_MSB
    lda SRC_MSB                         ; at the end?
    cmp #>MAZE_END+1
    bne +

    lda #<MAZE_START_OFFSET             ; end of maze, duplicate the end section again
    sta SRC_LSB
    lda #>MAZE_START_OFFSET
    sta SRC_MSB

+   inc DST_LSB                         ; move the destination pointer
    bne -
    inc DST_MSB
    lda DST_MSB                         ; check for end of screen RAM
    cmp #>END_OF_SCREEN_RAM+1
    bne -                               ; not finished yet, continue

    rts

;======================================================================================
; Pseudo-random-number generator. You can get 8-bit random numbers in A
; or 16-bit numbers from the zero page addresses. Leaves X/Y unchanged.
;
; (36 clock cycles)
;
; See
; https://web.archive.org/web/20250328001550/https://codebase64.org/doku.php?id=base:16bit_xorshift_random_generator
; and
; https://github.com/markgbeckett/pet/tree/main/examples
;======================================================================================
RAND16:
    lda SEED_MSB                        ; (3)
    lsr			                        ; (2)
    lda SEED_LSB	                    ; (3)
    ror			                        ; (2)
    eor SEED_MSB	                    ; (3)
    sta SEED_MSB	                    ; (3) high part of x ^= x << 7 done
    ror             	                ; (2) A has now x >> 9 and high bit comes from low byte
    eor SEED_LSB	                    ; (3)
    sta SEED_LSB	                    ; (3) x ^= x >> 9 and the low part of x ^= x << 7 done
    eor SEED_MSB	                    ; (3)
    sta SEED_MSB	                    ; (3) x ^= x << 8 done

    rts			                        ; (6)

;======================================================================================
; Strings
;======================================================================================
TEXT_ROUND_x:
    !scr    "round   "

TEXT_PRESS_F7:
    !scr    "press f7"

TEXT_LEN  = 8


