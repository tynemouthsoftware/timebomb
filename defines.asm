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
; Zero page Variables
;======================================================================================
; $00 and $01 get overwritten

TEMP                    = $02

SRC_LSB                 = $03
SRC_MSB                 = $04
SRC                     = SRC_LSB

DST_LSB                 = $05
DST_MSB                 = $06
DST                     = DST_LSB

SEED_LSB                = $07
SEED_MSB                = $08
SEED                    = SEED_LSB

;--------------------------------------------------------------------------------------
; Arrays
;--------------------------------------------------------------------------------------
DIRECTION               = $10
DOUBLE_DIRECTION        = $14
CHAR_DIRECTION          = $18

;--------------------------------------------------------------------------------------
; 16 bit Variables
;--------------------------------------------------------------------------------------
CURRENT_SQUARE_LSB      = $20
CURRENT_SQUARE_MSB      = $21
CURRENT_SQUARE          = CURRENT_SQUARE_LSB

CHECK_SQUARE_LSB        = $22
CHECK_SQUARE_MSB        = $23
CHECK_SQUARE            = CHECK_SQUARE_LSB

TIMEBOMB_LSB            = $24
TIMEBOMB_MSB            = $25
TIMEBOMB                = TIMEBOMB_LSB

PLAYER_LSB              = $26
PLAYER_MSB              = $27
PLAYER                  = PLAYER_LSB

OLD_PLAYER_LSB          = $28
OLD_PLAYER_MSB          = $29
OLD_PLAYER              = OLD_PLAYER_LSB

OFFSET_LSB              = $2A
OFFSET_MSB              = $2B
OFFSET                  = OFFSET_LSB

ROUND_UNITS             = $2C
ROUND_TENS              = $2D

TIMER_UNITS             = $2E
TIMER_TENS              = $2F

;--------------------------------------------------------------------------------------
; 8 bit Variables
;--------------------------------------------------------------------------------------
INITIAL_DIRECTION       = $30
DIRECTION_INDEX         = $31
FOUND                   = $32
PLAYER_CHARACTER        = $33
LAST_JIFFY              = $34
PENALTY                 = $35

;======================================================================================
; Screen layout
;======================================================================================
SCREEN_RAM              = $1E00
SCREEN_RAM_PAGE0        = SCREEN_RAM + $0000
SCREEN_RAM_PAGE1        = SCREEN_RAM + $0100
END_OF_SCREEN_RAM       = $1FFF

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

MAZE_END                = SCREEN_RAM - $0101
MAZE_TOP                = MAZE_END - (MAZE_HEIGHT * MAZE_WIDTH) + 1

MAZE_END_OF_TOP_LINE    = MAZE_TOP + MAZE_WIDTH - 1
MAZE_START_OF_BOMB_LINE = MAZE_TOP + (MAZE_WIDTH * 10)
MAZE_DEBUG_OFFSET       = MAZE_TOP + (MAZE_WIDTH * 22)
MAZE_MIDDLE             = MAZE_TOP + (((MAZE_HEIGHT - 1) * MAZE_WIDTH) / 2 )
MAZE_LAST_LINE          = MAZE_END - MAZE_WIDTH + 1
MAZE_PLAYER_START       = MAZE_END - (MAZE_WIDTH * 2.5)
MAZE_START_OFFSET       = MAZE_END - (MAZE_WIDTH * 14) + 1

SCREEN_LINE_ABOVE_ME    = SCREEN_RAM + (SCREEN_WIDTH * 11) - 1      ; 1EF1
SCREEN_START_ME         = SCREEN_RAM + (SCREEN_WIDTH * 11.5) - 1    ; 1EFC
SCREEN_LINE_BELOW_ME    = SCREEN_RAM + (SCREEN_WIDTH * 12)          ; 1F08

;======================================================================================
; Characters
;======================================================================================

CHAR_V                  = $16
CHAR_UP_ARROW           = $1E
CHAR_SPACE              = $20
CHAR_ASTERISK           = $2A
CHAR_LESS_THAN          = $3C
CHAR_GREATER_THAN       = $3E
CHAR_CIRCLE             = $51
INVERSE                 = $80

;======================================================================================
; Game data
;======================================================================================

CHAR_WALL                = CHAR_CIRCLE + INVERSE
CHAR_PATH                = CHAR_SPACE
CHAR_UP                  = CHAR_UP_ARROW
CHAR_DOWN                = CHAR_V
CHAR_LEFT                = CHAR_LESS_THAN
CHAR_RIGHT               = CHAR_GREATER_THAN
CHAR_BOMB                = CHAR_ASTERISK

; direction indexes
RIGHT                    = 0
UP                       = 1
LEFT                     = 2
DOWN                     = 3

; direction offsets
MOVE_UP                  = -MAZE_WIDTH
MOVE_DOWN                = MAZE_WIDTH
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

