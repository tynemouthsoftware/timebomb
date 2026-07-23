!source "defines.asm"

;======================================================================================
; Macros
;======================================================================================

;======================================================================================
; Write string to screen and set colour RAM
;======================================================================================
!macro WriteString length, string, row, column, colour {
    ldx #length-1                   ; WriteColourString Macro               
-   lda string,x
    sta SCREEN_RAM + (LINE_LENGTH * row) + column,x
    lda #colour
    sta COLOUR_RAM + (LINE_LENGTH * row) + column,x
    dex 
    bpl -
}
