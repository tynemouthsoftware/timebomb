;===================================================================================================
; Timebomb
; Based on BASIC type in program in Compute! July 1983 by Doug Smoak
; Dave Curran 2024-06-12
; Revised 2026-01-13
;===================================================================================================

; wine ACME.exe timebomb.asm
; or
; wine ACME.exe -r timebomb.lst timebomb.asm

!to "timebomb.prg",cbm

!source "defines.asm"
!source "macros.asm"

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
; Starting point
;===================================================================================================
; start:
    lda VIA1_TIMER2_LSB                 ; seed RND from the VIA timer
    sta SEED_LSB
    lda VIA1_TIMER2_MSB
    sta SEED_MSB

L1:
    ldy #0                              ; (leave Y as 0)

; some variables that are initialised to 0 by BASIC
    sty OM_LSB                          ; om = 0
    sty OM_MSB
    sty F                               ; f = 0
    sty C                               ; c = 0
    sty R_UNITS                         ; r = 0
    sty R_TENS                          ;
    sty K_UNITS                         ; k = 0
    sty K_TENS                          ; 

; 2 poke 56, 24 : poke 55, 103 : gosub 29
    lda #$67                            ; set memory limits, normally $1E00 to $1867
    sta $37                             ; - not required as not using BASIC?
    lda #$18
    sta $38
;    gosub 29 not required as that pokes assembler from data statments into the cassette buffer

; 3 d = 37154 : p1 = d-3 : p2 = d-2 : df = 30720 : v = 36878 : s = v-4 : m1 = 30 : x = 50 : goto 19
; d  = constant = 37154 = 9122 = VIA#2 DDRB (keyboard column scan + joy3)
; p1 = constant = 37151 = 911F = VIA#1 PortA (joy0,1,2,fire)
; p2 = constant = 37152 = 9120 = VIA#2 PortB (joy3)
; df = constant = 30720 = 7800 = display offset
; v  = constant = 36878 = 900E = VIC volume / aux colour
; s  = constant = 36874 = 900A = VIC oscillator 1 frequency
L3:
    lda #CHAR_UP                        ; m1 = 30 = ^
    sta M1

    lda #5                              ; x = 50
    sta X_TENS                          ; Tens and units stored separately to avoid several divide by 10s
                                        ; (X_UNITS is always 0, so is optimised out)

; 20 sys 861 : print "{clear} {down}making maze"
;===================================================================================================
; SYS 861 - fill maze with walls
;===================================================================================================
    ldy #$54
    lda #CHAR_WALL                      ; fill with wall characters
-
    sta $1800,y                         ; first loop from $1854 - $18FF
    iny
    bne -

-
    sta $1900,y                         ; second loop from $1900 - 1DFF
    sta $1A00,y
    sta $1B00,y
    sta $1C00,y
    sta $1D00,y
    iny
    bne -

;===================================================================================================
; Draw the maze
;===================================================================================================
; 19 dim a(3) : a(0) = 2 : a(1) = -44 : a(2) = -2 : a(3) = 44 : wl = 209 : hl = 32 : sc = 6228 : a9 = 6943
L19:
; a = 2, -44, -2, 44
    lda #2
    sta ARRAY
    lda #-44
    sta ARRAY+1
    lda #-2
    sta ARRAY+2
    lda #44
    sta ARRAY+3

; also create a half value version to avoid having to recalculate each time
    lda #1
    sta ARRAY_HALF
    lda #-22
    sta ARRAY_HALF+1
    lda #-1
    sta ARRAY_HALF+2
    lda #22
    sta ARRAY_HALF+3

; wl=209 - constant "Wall" (inverse circle)
; hl=32 - constant "Hall" (space)
; sc=6228
    lda #$54                            ; set SC to 6228 ($1854)
    sta SC_LSB
    lda #$18
    sta SC_MSB
; a9=6943
    lda #$1F                            ; set A9 to 6943 ($1B1F)
    sta A9_LSB
    lda #$1B
    sta A9_MSB


; 21 for t = sc+21 to 7679 step 22 : poke t, 32 : next : for t = sc to sc+21 : poke t, 32 : next
    ; add all the spaces down the right hand side
    lda SC_MSB                          ; start at SC + 21
    sta DST_MSB
    lda SC_LSB
    clc
    adc #21
    sta DST_LSB
    bcc +
    inc DST_MSB
+

    ldx #CHAR_PATH                      ; store a space

-   txa                                 ; retrieve the space
    sta (DST),y

    lda DST_LSB                         ; add 22
    clc
    adc #22
    sta DST_LSB
    bcc +
    inc DST_MSB
+
    lda DST_MSB
    cmp #$1E                            ; check if we have hit $1E00 (7679)
    bne -

    ; add a row of spaces at the top
    lda SC_MSB                          ; now doing SC to SC+21
    sta DST_MSB
    lda SC_LSB
    sta DST_LSB

    txa                                 ; retrieve the space
    ldy #22                             ; 22 times

-   dey
    sta (DST),y
    bne -

; 22 j = int(rnd(1)*4) : x3 = j
L22:
    jsr RAND16                          ; get a random number
    and #$03                            ; mask off all but the lower two bits (A=0-3)

    sta J
    sta X3

; 23 b = a9 + a(j)
L23:
    ; interesting challenge, add an 8 bit signed value to a 16 bit unsigned number
    ldx J                               ; get the random number in X

    lda A9_MSB                          ; copy the MSB first so it can be adjusted based on what happens to the LSB
    sta B_MSB

    lda ARRAY,x                         ; get the signed direction offset
    bpl +
    dec B_MSB                           ; if the offset is negative, decrement the MSB
+   clc
    adc A9_LSB                          ; now add the LSB
    sta B_LSB
    bcc +
    inc B_MSB                           ; increment MSB if there was a carry
+

; 24 if peek(b) = wl then poke b, j : poke a9 + a(j)/2, hl : a9 = b : goto 22
    ldy #0                              ; check what is pointed at by B
    lda (B),y
    cmp #CHAR_WALL                      ; is it a wall (wl)?
    bne L25

    lda J                               ; store the direction number instead
    sta (B),y

    ; poke a9 +a(j)/2, hl  Oh boy.

    ; safe to mangle A9 as it is set to a different value later

    lda ARRAY_HALF,x                    ; get half the signed direction offset
    bpl +
    dec A9_MSB                          ; if the offset is negative, decrement the MSB
+   clc
    adc A9_LSB                          ; now add the LSB
    sta A9_LSB
    bcc +
    inc A9_MSB                          ; increment MSB if there was a carry
+

    lda #CHAR_PATH                      ; set this to a space (hl)
    sta (A9),y

    lda B_MSB                           ; a9 = b
    sta A9_MSB
    lda B_LSB
    sta A9_LSB

    jmp L22

; not a wall
; 25 j = (j+1) * -(j<3) : if j <> x3 then 23
L25:   
    ;   j   (j+1)*-(j<3)    =
    ; -------------------------
    ;   0     1  *   1      1
    ;   1     2  *   1      2
    ;   2     3  *   1      3
    ;   3     4  *   0      0

    inc J                               ; 0123 > 1234
    lda J                               ; 
    and #$03                            ; 1234 > 1230
    sta J                               ; 
    cmp X3                              ; = X3?
    bne L23

; 26 j = peek(a9) : poke a9, hl : if j<4 then a9 = a9-a(j) : goto 22
    lda (A9),y
    sta J
    tax                                 ; save J for later
    lda #CHAR_PATH 
    sta (A9),y

    cpx #4                              ; J<4?
    bcs L27

    ; here we go again, subtract an 8 bit signed value from a 16 bit unsigned number

    lda ARRAY,x                         ; get signed direction offset
    sta TEMP                            ; save for later
    bpl +
    inc A9_MSB                          ; if the offset is negative, increment the MSB
+   sec
    lda A9_LSB                          ; now subtract the offset from the LSB
    sbc TEMP
    sta A9_LSB
    bcs +
    dec A9_MSB                          ; decrement MSB if there was a carry
+

    jmp L22

; 27 tb = sc + int(rnd(0)*20) + 220 : if (peek(tb) <> 32) goto 27 else poke tb, 42
L27:
    lda SC_MSB                          ; start with the MSB.
    sta TB_MSB

    ;   OK, so I want a random number from 0-19.

    jsr RAND16                          ; A now contains an 8 bit random number
    tax                                 ; save for later
    and #$03                            ; now have number from 0-3
    sta TEMP                            ; save for later
    txa                                 ; get the 8 bit number back
    ror                                 ; shift out the 3 bits already used
    ror
    ror
    and #$0F                            ; now have a number from 0-15
    clc
    adc TEMP                            ; now add the number from 0-3 and we have a number from 0-19 Yay!

    adc #$DC                            ; add 220 (will not be > 255, so no need to check carry)
    adc SC_LSB                          ; now add the LSB
    sta TB_LSB
    bcc +                               ; incrememnt MSB if necessary
    inc TB_MSB
+
    lda (TB),y                          ; lets see what's at this timebomb location
    cmp #CHAR_PATH                      ; is it a space?
    bne L27                             ; no, then try again

    lda #CHAR_BOMB                      ; plant the timebomb
    sta (TB),y


; 28 sys 830 : poke 828, 204 : poke 829, 28 : sys 923 : goto 4
;===================================================================================================
; SYS 830 - setup VIC and fill the colour memory
;===================================================================================================
    lda #$EE                            ; set the screen and border colours purple / light blue
    sta $900F

    ldy #$00

    lda #COLOUR_LIGHTRED                ; all text colour to light red
-   sta COLOUR_RAM_PAGE0,y
    sta COLOUR_RAM_PAGE1,y
    iny
    bne -

    lda #$CC                            ; maze offset to $1CCC (middle left hand edge)
    sta OFFSET_LSB
    lda #$1C
    sta OFFSET_MSB

    jsr sys923                          ; redraw without moving

;===================================================================================================
; Intro Sound
;===================================================================================================
; 4 for t = 240 to 208 step -4 : poke s, t : for tt = 0 to 30 : poke v, tt/2 : next : next t : poke s, 0 : me = 7932
L4:
    lda #$F0                            ; Start at 240
    ldy #0                              ; Y should have been left 0, but good point to reset it

L4_2:
    sta VIC_OSC1_FREQ, y                ; Tick, tick
    ldx #0

L4_3:
    stx VIC_VOLUME

    ldx #$0C                            ; short delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

    ldx VIC_VOLUME                      ; get X back
    inx
    cpx #$0F
    bne L4_3
    stx VIC_VOLUME                      ; the last of the 30 cycles will write 15 once

    sec
    sbc #04
    cmp #$D0                            ; reached 208?
    bcs L4_2

    sty VIC_OSC1_FREQ                   ; stop the oscillator

    lda #$FC                            ; set ME to $1EFC (7932) (middle of screen, starting point)
    sta ME_LSB
    lda #$1E
    sta ME_MSB

    lda JIFFY_LSB                       ; setup the timer
    sta JIFFY

;===================================================================================================
; Main Loop
;===================================================================================================
; 5 poke om, 32 : poke om+df, 10 : poke me, m1 : poke me+df, 7 : if f then 40
L5:    
    lda JIFFY                           ; wait for every 8th frame
    clc
    adc #$08
    sta JIFFY                           ; store value for next time
-   cmp JIFFY_LSB
    bne -    

    lda #CHAR_PATH                      ; First time around OM is 0, so writes to $0000
    sta (OM),y
    
    lda OM_MSB                          ; DST = OM+DF (offset from screen to colour RAM)
    clc
    adc #COLOUR_RAM_OFFSET_MSB
    sta DST_MSB

    lda OM_LSB                          ; DF is 32720 = $7800, so no need to alter LSB
    sta DST_LSB

    lda #COLOUR_LIGHTRED                ; set to background colour
    sta (DST),y                         

    lda M1                              ; poke me,m1, set the direction character
    sta (ME),y

    lda ME_MSB                          ; DST = ME+DF
    clc
    adc #COLOUR_RAM_OFFSET_MSB
    sta DST_MSB

    lda ME_LSB                          ; DF is 32720 = $7800, so no need to alter LSB
    sta DST_LSB

    lda #COLOUR_YELLOW                  ; set me colour yellow
    sta (DST),y

    lda F                               ; check F
    beq L6
    jmp L40                             ; if not 0, goto 40

; 6 k = k+1 : if (k/2 <> int(k/2)) goto 8 else if k>600 then 37
L6:
    inc K_UNITS                         ; K is stored as tens and units to simplify things
    
    lda K_UNITS
    cmp #10
    bcc +
    inc K_TENS                          ; K hit 10
    lda #0                              ; K_UNITS gets reset
    sta K_UNITS
+                     
    ror                                 ; check bit 0, if clear it is odd, so go to 8
    bcc L8

    lda K_TENS                          ; check if K > 600 
    cmp #60
    bcc L7 
    jmp L37

;======================================================================================
; Ominous ticking
;======================================================================================
; 7 for t = 1 to 2 : poke v, t*4 : poke s+1, 128+k/5 : next : poke s+1, 0
L7: 
    lda #4                              ; pass 1, t*4 = 4
    sta TEMP   

L7_1:
    sta VIC_VOLUME                      ; v

    ; pokes+1,128+k/5  - really, come on, give me a break here
    ; max K is 600, so max k/5 is 120. So range is 128-248
    
    lda K_TENS                          ; this is K/10
    asl                                 ; k/10 -> K/5
    ora #$80                            ; add 128

    sta VIC_OSC2_FREQ                   ; s+1

    ldx #$08
-   dey                                 ; short delay
    bne -                               ;
    dex                                 ;
    bne -                               ;

    lda #8                              ; was TEMP 8 ?
    cmp TEMP
    beq L7_2                            ; finished

    sta TEMP                            ; no, set it to 8 now
    bne L7_1                            ; branch always

L7_2:
    sty VIC_OSC2_FREQ                   ; s+1 = 0

;======================================================================================
; Check joystick and move
;======================================================================================
; 8 poke d, 127 : p = peek(p2) and 128 : j0 = -(p = 0)
; 9 poke d, 255 : p = peek(p1) : j1 = -((p and 8) = 0) : j2 = -((p and 16) = 0) : j3 = -((p and 4) = 0)
; 10 if j0 then c = 1 : m1 = 62 : goto 14
; 11 if j1 then c = 22 : m1 = 22 : goto 14
; 12 if j2 then c = -1 : m1 = 60 : goto 14
; 13 if j3 then c = -22 : m1 = 30
L8:

    lda #$7F                            ; set joystick 3 as input
    sta VIA2_DDRB

    lda VIA2_PORTB                      ; read the port

    ldx #$FF
    stx VIA2_DDRB                       ; back to all inputs for keyboard scanning

    and #$80                            ; mask of the pin
    bne +                               ; skip if not zero (active)
    lda #MOVE_RIGHT
    sta C
    lda #CHAR_RIGHT
    sta M1
    jmp L14
+

    lda VIA1_PORTA                      ; read port A and set J1,2 and 3 accordingly
    tax                                 ; save value

    and #8
    bne +                               ; skip if not zero (active)
    lda #MOVE_DOWN
    sta C
    lda #CHAR_DOWN
    sta M1
    jmp L14
+
    txa                                 ; get back the port reading
    and #16
    bne +                               ; skip if not zero (active)
    lda #MOVE_LEFT
    sta C
    lda #CHAR_LEFT
    sta M1
    jmp L14
+
    txa                                 ; get back the port reading
    and #4
    bne +                               ; skip if not zero (active)
    lda #MOVE_UP
    sta C
    lda #CHAR_UP
    sta M1
+

; 14 om = me : me = me+c : c = 0
L14:
    lda ME_LSB                          ; old me = current me
    sta OM_LSB
    lda ME_MSB
    sta OM_MSB

    lda C                               ; me=me+c - move me
    bpl +
    dec ME_MSB                          ; if c is negative, decrement the MSB
+   clc
    adc ME_LSB
    sta ME_LSB
    bcc +
    inc ME_MSB
+   
    sty C                               ; c=0 

; 15 if peek(me) <> 32 and peek(me) <> 42 then me = om
    lda (ME),y

    cmp #CHAR_PATH                      ; is it a clear path?
    beq L16                             ; yes, skip

    cmp #CHAR_BOMB                      ; is it a bomb?
    beq L16                             ; yes, skip

    ldx OM_LSB                          ; me = old me - you can't want into walls
    stx ME_LSB
    ldx OM_MSB
    stx ME_MSB

; 16 if peek(me) = 42 then f = 1 : goto 5
L16:
    cmp #CHAR_BOMB                      ; is it a bomb?
    bne L17                             ; no, skip

    lda #1                              ; it is a bomb, set found
    sta F
    jmp L5

    
; 17 if (me>7921) goto 18 else sys 887 : me = me+22 : goto 5
L17:
    lda ME_MSB                           ; if me>1EF1 goto 18
    cmp #$1E
    bne +
    lda ME_LSB
    cmp #$F1
+
    bcs L18

    jsr sys887                          ; scroll down

    lda ME_LSB                          ; me += 22 
    clc
    adc #MOVE_DOWN
    sta ME_LSB
    bcc +
    inc ME_MSB
+
    jmp L5

; 18 if (me<7944) goto 5 else sys 905 : me = me-22 : goto 5
L18
    lda ME_MSB                          ; is ME < 1F08
    cmp #$1F
    bne +
    lda ME_LSB
    cmp #$08
+
    bcc +

    jsr sys905                          ; scroll up

    lda ME_LSB                          ; me += -22
    dec ME_MSB
    clc
    adc #MOVE_UP
    sta ME_LSB
    bcc +
    inc ME_MSB
+
    jmp L5

;===================================================================================================
; Timeout, bomb explodes
;===================================================================================================
; 37 poke v, 15 : for t = 255 to 127 step -2 : poke s, t : poke v-9, 255 : for g = 1 to 10 : next
L37:
    lda #15                             ; full volume
    sta VIC_VOLUME

    ldx #$FF
L37_1:
    stx VIC_OSC1_FREQ                   ; s = t

    lda #$FF
    sta VIC_ADDRESSING                  ; v-9 = 255

    ldx #$09                            ; short delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

; 38 poke v-9, 242 : for g = 1 to 10 : next : poke v-9, 240 : next : poke v-1, 220 : for g = 15 to 0 step -.05
    lda #$F2
    sta VIC_ADDRESSING                  ; v-9 = 242

    ldx #$09                            ; short delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

    ldx VIC_OSC1_FREQ                   ; get X back

    lda #$F0
    sta VIC_ADDRESSING                  ; v-9 = 240

    dex                                 ; t=t-2
    dex
    bmi L37_1                           ; loop when t > 127

    ; now the explosion

    lda #$DC
    sta VIC_NOISE_FREQ                  ; v-1 = 220

; for g = 15 to 0 step -.05   oh no, what?

; 39 poke v, g : poke v+1, g*10 : next : poke v-1, 0 : poke v+1, 238 : gosub 42 : run
L39:
    lda #$96                            ; v+1 = g*10
    sta VIC_BORDER            

    lda #$0F                            ; v = g
    sta VIC_VOLUME

    ldx #$0A                            ; loop 10 times

-   dey                                 ; delay
    bne -

    dec VIC_BORDER                      ; v+1 = g*10
    dex
    bne -

    dec VIC_VOLUME                      ; v = g
    bne -

    sty VIC_NOISE_FREQ                  ; v-1 = 0 

    lda #$EE                            ; v+1 = 238
    sta VIC_BORDER            

    jsr L42                             ; display "ROUND R, PRESS F7"

    jmp L1                              ; restart

;===================================================================================================
; Success
;===================================================================================================

; 40 poke tb, 32 : poke v-1, 253 : for g = 30 to 0 step -.15 : poke v, g/2 : next : x = x+50 : if x>449 then x = 450
L40:
    lda #CHAR_PATH                     ; dispose of the timebomb
    sta (TB),y

    lda #$FD
    sta VIC_NOISE_FREQ                  ; v-1 = 253

    ; for g = 30 to 0 step -.15  oh come on, give me a break
    ldx #$0F                            ; g = 30, x = g/2 = 15

L40_1:    
    stx VIC_VOLUME                      ; v = g/2 = x

    ldx #$35                            ; delay
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;

    ldx VIC_VOLUME                      ; get X back

    dex
    bne L40_1

    clc
    lda X_TENS                          ; x = x+50
    adc #$05
    sta X_TENS

    cmp #$2D                            ; x > 450 ?
    bcc L41

    lda #$2D                            ; x = 450
    sta X_TENS                          ; X_UNITS is always 0

; 41 poke v-1, 0 : f = 0 : k = x : r = r+1 : gosub 42 : goto 27
L41:
    sty VIC_NOISE_FREQ                  ; v-1 = 0

    sty F                               ; f = 0

    lda X_TENS                          ; k = x, start K counter at X
    sta K_TENS
    sty K_UNITS                         ; X_UNITS is always 0
    
    inc R_UNITS                         ; r = r+1
    lda R_UNITS
    cmp #10
    bcc +
    sty R_UNITS                         ; if R_UNITS>9 then R_UNITS=0 R_TENS++
    inc R_TENS
+  
    jsr L42                             ; display "ROUND R, PRESS F7"

    jmp L27                             ; next round

;===================================================================================================
; Print ROUND R - PRESS F7
;===================================================================================================
; 42 print "{home}round" r "{right} " : print "{down}press f7 " : a$ = "" : get a$ : if (a$ <> "{f7}") goto 42 else return
L42:
    +WriteString TEXT_ROUND_x_LEN, TEXT_ROUND_x, 0, 0, COLOUR_BLUE

    lda R_TENS
    beq L42_1

    ; double digit
    clc    
    adc #$30                            ; A = R+30  (0->"0")
    sta SCREEN_RAM + 6                 

    lda R_UNITS
    clc
    adc #$30                            ; A = R+30  (0->"0")
    sta SCREEN_RAM + 7                  
    bne L42_2                           ; branch always

L42_1:
    ; single digit
    lda R_UNITS
    clc
    adc #$30                            ; A = R+30  (0->"0")
    sta SCREEN_RAM + 6                  

L42_2:
    +WriteString TEXT_PRESS_F7_LEN, TEXT_PRESS_F7, 2, 0, COLOUR_BLUE

    sty LAST_KEY                        ; clear last key
-
    lda LAST_KEY                        ; check last key pressed
    cmp #KEY_F7                         ; was it F7?
    bne -                               ; no, keep checking
    
    rts                                 ; yes, return

;===================================================================================================
; SYS 887 Scroll screen up
;===================================================================================================
sys887:
    lda #MOVE_UP                        ; offset = offset - 22
    dec OFFSET_MSB
    bne +

;===================================================================================================
; SYS 905 Scroll screen down
;===================================================================================================
sys905:
    lda #MOVE_DOWN                      ; offset = offset + 22
+
    clc
    adc OFFSET_LSB
    sta OFFSET_LSB
    bcc +
    inc OFFSET_MSB
+

;===================================================================================================
; SYS 923 redraw screen
;===================================================================================================
sys923:
    ldy #$00                            ; set the destination to the screen at 1E00
    sty SCREEN_LSB
    lda #$1E
    sta SCREEN_MSB

    lda OFFSET_LSB                      ; set the source (the map bitmap)
    sta MAP_LSB
    lda OFFSET_MSB
    sta MAP_MSB

-   lda (MAP),y                         ; copy first page
    sta (SCREEN),y
    iny
    bne -

    inc SCREEN_MSB
    inc MAP_MSB

-   lda (MAP),y                         ; copy second page
    sta (SCREEN),y
    iny
    bne -

    rts


;======================================================================================
; Pseudo-random-number generator. You can get 8-bit
; random numbers in A or 16-bit numbers from the zero
; page addresses. Leaves X/Y unchanged.
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

TEXT_ROUND_x_LEN  = 8

TEXT_PRESS_F7:
    !scr    "press f7"

TEXT_PRESS_F7_LEN  = 8