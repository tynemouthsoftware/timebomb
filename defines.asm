;======================================================================================
; Defines
;======================================================================================

;======================================================================================
; Hardware addresses
;======================================================================================          
VIC                 = $9000
VIC_ADDRESSING      = $9005 ; v-9
VIC_OSC1_FREQ       = $900A ; s
VIC_OSC2_FREQ       = $900B ; s+1
VIC_NOISE_FREQ      = $900D ; v-1
VIC_VOLUME          = $900E ; v
VIC_BORDER          = $900F ; v+1

VIA1_TIMER2_LSB     = $9118
VIA1_TIMER2_MSB     = $9119

VIA1_PORTA          = $911F ; p1
VIA2_PORTB          = $9120 ; p2
VIA2_DDRB           = $9122 ; d

JIFFY_LSB           = $A2

LAST_KEY            = $C5

;======================================================================================
; Variables
;======================================================================================
VARS                = $00

TEMP                = VARS + $00

SRC_LSB             = VARS + $08
SRC_MSB             = VARS + $09
SRC                 = SRC_LSB

DST_LSB             = VARS + $0A
DST_MSB             = VARS + $0B
DST                 = DST_LSB

SEED_LSB            = VARS + $10
SEED_MSB            = VARS + $11
SEED                = SEED_LSB

;--------------------------------------------------------------------------------------
; Arrays
;--------------------------------------------------------------------------------------
ARRAY               = VARS + $20
ARRAY_HALF          = VARS + $24

;--------------------------------------------------------------------------------------
; 16 bit Variables
;--------------------------------------------------------------------------------------
SC_LSB              = VARS + $30
SC_MSB              = VARS + $31
SC                  = SC_LSB

A9_LSB              = VARS + $32
A9_MSB              = VARS + $33
A9                  = A9_LSB

B_LSB               = VARS + $34
B_MSB               = VARS + $35
B                   = B_LSB

TB_LSB              = VARS + $36
TB_MSB              = VARS + $37
TB                  = TB_LSB

ME_LSB              = VARS + $38
ME_MSB              = VARS + $39
ME                  = ME_LSB

OM_LSB              = VARS + $3A
OM_MSB              = VARS + $3B
OM                  = OM_LSB

K_UNITS             = VARS + $3C
K_TENS              = VARS + $3D

; X_UNITS             = VARS + $3E
X_TENS              = VARS + $3F

R_UNITS             = VARS + $40
R_TENS              = VARS + $41

OFFSET_LSB          = VARS + $42
OFFSET_MSB          = VARS + $43
OFFSET              = OFFSET_LSB

;--------------------------------------------------------------------------------------
; 8 bit Variables
;--------------------------------------------------------------------------------------
X3                  = VARS + $50
J                   = VARS + $51
F                   = VARS + $52
M1                  = VARS + $53
LAST_JIFFY          = VARS + $54

;======================================================================================
; Screen layout
;======================================================================================          
SCREEN_RAM              = $1E00
SCREEN_RAM_PAGE0        = SCREEN_RAM + $0000
SCREEN_RAM_PAGE1        = SCREEN_RAM + $0100

COLOUR_RAM              = $9600
COLOUR_RAM_PAGE0        = COLOUR_RAM + $0000
COLOUR_RAM_PAGE1        = COLOUR_RAM + $0100

SCREEN_WIDTH            = 22
SCREEN_HEIGHT           = 23

COLOUR_RAM_OFFSET_MSB   = (>COLOUR_RAM) - (>SCREEN_RAM)

SCREEN_RAM_LINE_00      = SCREEN_RAM + (SCREEN_WIDTH *  0)
SCREEN_RAM_LINE_02      = SCREEN_RAM + (SCREEN_WIDTH *  2)

COLOUR_RAM_LINE_00      = COLOUR_RAM + (SCREEN_WIDTH *  0)
COLOUR_RAM_LINE_02      = COLOUR_RAM + (SCREEN_WIDTH *  2)

;======================================================================================
; Maze Details
;======================================================================================          

MAZE_WIDTH              = 22
MAZE_HEIGHT             = 66

MAZE_END                = SCREEN_RAM - 1
MAZE_TOP                = MAZE_END - (MAZE_HEIGHT * MAZE_WIDTH) + 1

MAZE_END_OF_TOP_LINE    = MAZE_TOP + MAZE_WIDTH - 1
MAZE_MIDDLE             = MAZE_TOP + (((MAZE_HEIGHT - 1) * MAZE_WIDTH) / 2 )
MAZE_LAST_LINE          = MAZE_END - MAZE_WIDTH + 1
MAZE_START_ME           = MAZE_END - (MAZE_WIDTH * 2.5)
MAZE_START_OFFSET       = MAZE_END - (MAZE_WIDTH * 14) + 1

SCREEN_LINE_ABOVE_ME    = SCREEN_RAM + (SCREEN_WIDTH * 11) - 1      ; 1EF1
SCREEN_START_ME         = SCREEN_RAM + (SCREEN_WIDTH * 11.5) - 1    ; 1EFC
SCREEN_LINE_BELOW_ME    = SCREEN_RAM + (SCREEN_WIDTH * 12)          ; 1F08

;======================================================================================
; Characters
;======================================================================================          

CHAR_V                   = $16
CHAR_UP_ARROW            = $1E
CHAR_SPACE               = $20
CHAR_ASTERISK            = $2A
CHAR_LESS_THAN           = $3C
CHAR_GREATER_THAN        = $3E
CHAR_INVERSE_CIRCLE      = $D1

;======================================================================================
; Game characters
;======================================================================================

CHAR_WALL                = CHAR_INVERSE_CIRCLE
CHAR_PATH                = CHAR_SPACE
CHAR_UP                  = CHAR_UP_ARROW
CHAR_DOWN                = CHAR_V
CHAR_LEFT                = CHAR_LESS_THAN
CHAR_RIGHT               = CHAR_GREATER_THAN
CHAR_BOMB                = CHAR_ASTERISK

MOVE_UP                  = -22
MOVE_DOWN                = 22
MOVE_LEFT                = -1
MOVE_RIGHT               = 1

KEY_F7                   = $3F

;======================================================================================
; Colours
;======================================================================================          
COLOUR_BLACK             = $00
COLOUR_WHITE             = $01
COLOUR_RED               = $02
COLOUR_CYAN              = $03
COLOUR_VIOLET            = $04
COLOUR_PURPLE            = $04 ; == VIOLET
COLOUR_GREEN             = $05
COLOUR_BLUE              = $06
COLOUR_YELLOW            = $07
COLOUR_ORANGE            = $08
COLOUR_BROWN             = $09
COLOUR_LIGHTRED          = $0A
COLOUR_GRAY1             = $0B
COLOUR_GRAY2             = $0C
COLOUR_LIGHTGREEN        = $0D
COLOUR_LIGHTBLUE         = $0E
COLOUR_GRAY3             = $0F

;======================================================================================
; BASIC Tokens
;======================================================================================
SYS                      = $9E

