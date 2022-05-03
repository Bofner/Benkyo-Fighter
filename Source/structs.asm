;==============================================================
;All Structs that are sprites MUST have the following
;==============================================================
/*
    hitAdr      dw      ;The address where hit-detection subroutine for that specific OBJ type is
    sprNum      db      ;The draw-number of the sprite      
    hw          db      ;The hight and width of the entire OBJ
    y           db      ;The Y coord of the OBJ
    x           db      ;The X coord of the OBJ
    cc          db      ;The first character code for the OBJ 
    sprSize     db      ;The total area of the OBJ
*/

;==============================================================
; Player structure
;==============================================================
.struct player
    alive       db
    direction   db 
    input       db
    hitAdr      dw
    sprNum      db
    hw          db
    y           db
    x           db 
    cc          db
    sprSize     db
    frameCount  db
.endst

;==============================================================
; Player shots structure
;==============================================================
.struct player_shot
    ;The variable order MATTERS, do NOT change
    resetTimer  db  ;$04 = active shot, Value <= $03 = Recharge, $00 = ready
    direction   db  ;Should be the same as kb.direction at time of fire
    y           db
    x           db 
    cc          db
    ;spriteNum   db
.endst

;==============================================================
; Player cursor structure
;==============================================================
.struct player_cursor
    input       db
    x           db
    y           db 
    cc          db
    spriteNum   db
.endst

;==============================================================
; Forever Carrier structure
;==============================================================
.struct forever_carrier
    stage       db      ;3 stages total, with a different frame
    x           db
    y           db 
    cc          db
    spriteNum   db

.endst

;==============================================================
; Big Eye structure
;==============================================================
.struct big_eye
    health      db      ;hitpoints that the eye has left (BIT 7 is a vulnerablity toggle)
    animTimer   db      ;Timer used for animations
    stage       db      ;Used for handler
    x           db
    y           db 
    cc          db
    spriteNum   db
.endst

;==============================================================
; Chrome Spinner structure
;==============================================================
.struct chrome_spinner
    alive       db
    hitAdr      dw
    sprNum      db
    hw          db
    y           db
    x           db 
    cc          db
    sprSize     db
    frameCount  db
.endst

;==============================================================
; Mongoose structure
;==============================================================
.struct mongoose
    hitAdr      dw
    sprNum      db
    hw          db
    y           db
    x           db 
    cc          db
    sprSize     db
.endst

