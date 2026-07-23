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
VIC_OSC3_FREQ       = $900C ;
VIC_NOISE_FREQ      = $900D ; v-1
VIC_VOLUME          = $900E ; v
VIC_BORDER          = $900F ; v+1

VIA1_TIMER2_LSB     = $9118
VIA1_TIMER2_MSB     = $9119

VIA1_PORTA          = $911F ; p1
VIA2_PORTB          = $9120 ; p2
VIA2_DDRB           = $9122 ; d

; d  = 37154 = 9122 = VIA#2 DDRB (keyboard column scan + joy3)
; p1 = 37151 = 911F = VIA#1 PortA (joy0,1,2,fire)
; p2 = 37152 = 9120 = VIA#2 PortB (joy3)

JIFFY_LSB           = $A2
JIFFY_HSB           = $A1
JIFFY_MSB           = $A0

LAST_KEY            = $C5

KEY_F7              = $3F

;======================================================================================
; Variables
;======================================================================================
VARS                = $00

TEMP                = VARS + $00

; SRC_LSB             = VARS + $08
; SRC_MSB             = VARS + $09
; SRC                 = SRC_LSB

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

X_UNITS             = VARS + $3E
X_TENS              = VARS + $3F

R_UNITS             = VARS + $40
R_TENS              = VARS + $41


;--------------------------------------------------------------------------------------
; 8 bit Variables
;--------------------------------------------------------------------------------------
X3                  = VARS + $50
J                   = VARS + $51
F                   = VARS + $52
M1                  = VARS + $53
C                   = VARS + $54

JIFFY               = VARS + $60

; Hard coded values from original code

MAP_TEMP            = $FD

MAP_LSB             = $FE
MAP_MSB             = $FF
MAP                 = MAP_LSB 

SCREEN_LSB          = $00
SCREEN_MSB          = $01
SCREEN              = SCREEN_LSB

OFFSET_LSB          = $033C
OFFSET_MSB          = $033D

;======================================================================================
; Code constants
;======================================================================================          


;======================================================================================
; Screen layout
;======================================================================================          
SCREEN_RAM          = $1E00
SCREEN_RAM_PAGE0    = SCREEN_RAM + $0000
SCREEN_RAM_PAGE1    = SCREEN_RAM + $0100

COLOUR_RAM          = $9600
COLOUR_RAM_PAGE0    = COLOUR_RAM + $0000
COLOUR_RAM_PAGE1    = COLOUR_RAM + $0100

LINE_LENGTH         = $16

COLOUR_RAM_OFFSET_MSB = $96-$1E

SCREEN_RAM_LINE_00  = SCREEN_RAM + (LINE_LENGTH *  0)
SCREEN_RAM_LINE_01  = SCREEN_RAM + (LINE_LENGTH *  1)
SCREEN_RAM_LINE_02  = SCREEN_RAM + (LINE_LENGTH *  2)
SCREEN_RAM_LINE_03  = SCREEN_RAM + (LINE_LENGTH *  3)
SCREEN_RAM_LINE_04  = SCREEN_RAM + (LINE_LENGTH *  4)
SCREEN_RAM_LINE_05  = SCREEN_RAM + (LINE_LENGTH *  5)
SCREEN_RAM_LINE_06  = SCREEN_RAM + (LINE_LENGTH *  6)
SCREEN_RAM_LINE_07  = SCREEN_RAM + (LINE_LENGTH *  7)
SCREEN_RAM_LINE_08  = SCREEN_RAM + (LINE_LENGTH *  8)
SCREEN_RAM_LINE_09  = SCREEN_RAM + (LINE_LENGTH *  9)
SCREEN_RAM_LINE_10  = SCREEN_RAM + (LINE_LENGTH * 10)
SCREEN_RAM_LINE_11  = SCREEN_RAM + (LINE_LENGTH * 11)
SCREEN_RAM_LINE_12  = SCREEN_RAM + (LINE_LENGTH * 12)
SCREEN_RAM_LINE_13  = SCREEN_RAM + (LINE_LENGTH * 13)
SCREEN_RAM_LINE_14  = SCREEN_RAM + (LINE_LENGTH * 14)
SCREEN_RAM_LINE_15  = SCREEN_RAM + (LINE_LENGTH * 15)
SCREEN_RAM_LINE_16  = SCREEN_RAM + (LINE_LENGTH * 16)
SCREEN_RAM_LINE_17  = SCREEN_RAM + (LINE_LENGTH * 17)
SCREEN_RAM_LINE_18  = SCREEN_RAM + (LINE_LENGTH * 18)
SCREEN_RAM_LINE_19  = SCREEN_RAM + (LINE_LENGTH * 19)
SCREEN_RAM_LINE_20  = SCREEN_RAM + (LINE_LENGTH * 20)
SCREEN_RAM_LINE_21  = SCREEN_RAM + (LINE_LENGTH * 21)

COLOUR_RAM_LINE_00  = COLOUR_RAM + (LINE_LENGTH *  0)
COLOUR_RAM_LINE_01  = COLOUR_RAM + (LINE_LENGTH *  1)
COLOUR_RAM_LINE_02  = COLOUR_RAM + (LINE_LENGTH *  2)
COLOUR_RAM_LINE_03  = COLOUR_RAM + (LINE_LENGTH *  3)
COLOUR_RAM_LINE_04  = COLOUR_RAM + (LINE_LENGTH *  4)
COLOUR_RAM_LINE_05  = COLOUR_RAM + (LINE_LENGTH *  5)
COLOUR_RAM_LINE_06  = COLOUR_RAM + (LINE_LENGTH *  6)
COLOUR_RAM_LINE_07  = COLOUR_RAM + (LINE_LENGTH *  7)
COLOUR_RAM_LINE_08  = COLOUR_RAM + (LINE_LENGTH *  8)
COLOUR_RAM_LINE_09  = COLOUR_RAM + (LINE_LENGTH *  9)
COLOUR_RAM_LINE_10  = COLOUR_RAM + (LINE_LENGTH * 10)
COLOUR_RAM_LINE_11  = COLOUR_RAM + (LINE_LENGTH * 11)
COLOUR_RAM_LINE_12  = COLOUR_RAM + (LINE_LENGTH * 12)
COLOUR_RAM_LINE_13  = COLOUR_RAM + (LINE_LENGTH * 13)
COLOUR_RAM_LINE_14  = COLOUR_RAM + (LINE_LENGTH * 14)
COLOUR_RAM_LINE_15  = COLOUR_RAM + (LINE_LENGTH * 15)
COLOUR_RAM_LINE_16  = COLOUR_RAM + (LINE_LENGTH * 16)
COLOUR_RAM_LINE_17  = COLOUR_RAM + (LINE_LENGTH * 17)
COLOUR_RAM_LINE_18  = COLOUR_RAM + (LINE_LENGTH * 18)
COLOUR_RAM_LINE_19  = COLOUR_RAM + (LINE_LENGTH * 19)
COLOUR_RAM_LINE_20  = COLOUR_RAM + (LINE_LENGTH * 20)
COLOUR_RAM_LINE_21  = COLOUR_RAM + (LINE_LENGTH * 21)

;======================================================================================
; Characters
;======================================================================================          
CHAR_V                   = $16

CHAR_UP_ARROW            = $1E
CHAR_SPACE               = $20
CHAR_EXCLAIMATION        = $21
CHAR_ASTERISK            = $2A
CHAR_PLUS                = $2B
CHAR_DASH                = $2D

CHAR_LESS_THAN           = $3C
CHAR_GREATER_THAN        = $3E

CHAR_BOX_HORIZONTAL      = $40
CHAR_BOX_VERTICAL        = $5D

CHAR_BOX_TOP_LEFT        = $70
CHAR_BOX_TOP_RIGHT       = $6E
CHAR_BOX_BOTTOM_LEFT     = $6D
CHAR_BOX_BOTTOM_RIGHT    = $7D

CHAR_BOX_TEE_LEFT        = $6B
CHAR_BOX_TEE_RIGHT       = $73
CHAR_BOX_TEE_DOWN        = $72
CHAR_BOX_TEE_UP          = $71

CHAR_TICK                = $7A

;CHAR_BAR_25              = $65
;CHAR_BAR_50              = $61
;CHAR_BAR_75              = $F6

CHAR_BAR_25              = $E5
CHAR_BAR_50              = $E1
CHAR_BAR_75              = $76
CHAR_BAR_100             = $E0

CHAR_INVERSE_CIRCLE      = $D1

CHAR_V                   = $16
CHAR_UP_ARROW            = $1E
CHAR_LESS_THAN           = $3C
CHAR_GREATER_THAN        = $3E

CHAR_SPACE               = $20

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
