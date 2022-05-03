;Updates any sprite-OBJect. DE is our *pointer, and HL is used for
;   updating the properties of the sprite
;Parameters: DE = sprite.sprNum
;Affects: DE, A, BC

;Subroutine relies on the following structure pattern
;==============================================================
; Mongoose structure
;==============================================================
;.struct mongoose
;    hitAdr      dw
;    sprNum      db
;    hw          db
;    y           db
;    x           db 
;    cc          db
;    sprSize     db
;.endst
;Other bytes of data may be added before hitAdr, or after SprSize, but not between
;any of the data bytes labeled above, as this will mess with the pointer

MultiUpdateSATBuff:
    ;==============================================
    ;Update Sprite X, Y and CC
    ;==============================================
    push hl                     ;Preserving HL
    ;Determine Sprite Number
        ld a, (sprUpdCnt)
        ld (de), a
    ;Writing the hit detection address to the SOAL
        dec de                  ;ld de, OBJ.adrL
        dec de                  ;ld de, OBJ.adrH
    ;Adding the updated sprite number to the SOAL (words, so sprUpdCnt x2)
        ld b, 0
        ld c, a
        ld h, b
        ld l, c    
        add hl, bc                ;sprUpdCnt x2                 
        ld bc, SOAL
        add hl, bc              ;Matched for correct sprite
    ;Loading the data from our OBJ into the SOAL
        ld a, (de)
        ld (hl), a              ;ld hl, OBJ,adrH
        inc de                  ;ld de, OBJ.adrL
        ld a, (de)              
        inc hl                  ;ld hl, 2nd Byte
        ld (hl), a              ;ld hl, OBJ, adrL
        inc de                  ;ld hl, OBJ.sprNum
    ;Setting OBJ size to 0 and getting back to HW
        inc de                  ;ld de, OBJ.hw
        inc de                  ;ld de, OBJ.y
        inc de                  ;ld de, OBJ.x
        inc de                  ;ld de, OBJ.cc
        inc de                  ;ld de, OBJ.sprSize
        xor a
        ld (de), a              ;OBJ.size = 0
        dec de                  ;ld de, OBJ.cc
        dec de                  ;ld de, OBJ.x
        dec de                  ;ld de, OBJ.y
        dec de                  ;ld de, OBJ.hw
            
    ;Height
        ;ld de, OBJ.wh
        ld a, (de)              ;A now has hw
        ld b, %11110000         ;HEIGHT mask
        and b
        rrca
        rrca
        rrca
        rrca                    ;Shift right 4 times so B isn't carrying a higher value
        ld b, a                 ;B now contains the height
        ld a, (de)              ;A now has wh

    ;Width
        ;ld de, OBJ.wh
        ld a, (de)
        ld c, %00001111         ;WIDTH Mask
        and c
        ld c, a                 ;C now has the width
        jr +
        
MUSBWidthReset:
    ;Width
        ;ld de, OBJ.wh
        ld a, (de)
        ld c, %00001111         ;WIDTH Mask
        and c
        ld c, a                 ;C now has the width

    ;Adjust the height offset
        ld hl, sprYOff
        ld a, (hl)
        add a, $10              ;Specifically for 8x16 sprites
        ld (hl), a

    ;Adjust the width offset
        inc hl                  ;ld hl, sprXOff
        ld (hl), $00

    ;Adjust the cc offset
        inc hl                  ;ld hl, sprCCOff
        ld a, (hl)
        add a, $02              ;Specifically for 8x16
        ld (hl), a
        jr +                    ;Skip the *pointer reset

MUSBLoop:
    ;Resetting our *pointer
        dec de                      ;ld de, OBJ.cc
        dec de                      ;ld de, OBJ.x
        dec de                      ;ld de, OBJ.y
        dec de                      ;ld de, OBJ.hw
        dec c                       ;Decrease our counter

    ;Adjust the width offset
        ld hl, sprXOff
        ld a, (hl)
        add a, $08              ;Specifically for 8x16 sprites
        ld (hl), a

    ;Adjust the cc offset
        inc hl                  ;ld hl, sprCCOff
        ld a, (hl)
        add a, $02              ;Specifically for 8x16
        ld (hl), a
+:
    ;Y coords 
        ld hl, sprite0              ;HL points to the vertical poisiton sprite 0
        ld a, (sprUpdCnt)
        add a, l
        ld l, a                     ;HL now points to Y of the next sprite we are updating
        inc de                      ;ld de, OBJ.y
        ld a, (de)
        ld (hl), a                  ;OBJ.y updated to OBJ's top left sprite Y coord
        ld a, (sprYOff)
        add a, (hl)
        ld (hl), a                  ;OBJ.y has been adjusted to the proper location

    ;X coords
        ld a, offsetHP              ;A is the offset for HPos
        add a, l         
        ld l, a
        ld a, (sprUpdCnt)           ;Since CC and HPos are next to each other, we need this for true offset
        add a, l
        ld l, a                     ;HL Points to X of sprite we are updating
        inc de                      ;ld de, OBJ.x
        ld a, (de)
        ld (hl), a                  ;OBJ.x updated to OBJ's top left sprite Y coord
        ld a, (sprXOff)
        add a, (hl)
        ld (hl), a                  ;OBJ.x has been adjusted to the proper location
             
    
    ;Character code
        inc hl                      ;HL Points to CC of sprite we are updating
        inc de                      ;ld de, OBJ.cc
        ld a, (de)                  ;Load's CC into A
        ld (hl), a                  ;OBJ.cc updated to OBJ's top left sprite Y coord
        ld a, (sprCCOff)
        add a, (hl)
        ld (hl), a                  ;OBJ.cc has been adjusted to the proper location

        ld hl, sprUpdCnt            ;Update num of sprites that have been updated
        ld a, (hl)
        inc a
        ld (hl), a                  

    ;Update Sprite Size
        inc de                      ;ld de, OBJ.sprSize
        ld a, (de)
        inc a
        ld (de), a

    ;Check how many more we have to go
        ld a, $01                   ;IDK, zero indexing or something?
        cp c
        jp nz, MUSBLoop             ;If there are still more in our row, go back
    ;If we have finished a row
    ;Reset our *pointer
        dec de                      ;ld de, OBJ.cc
        dec de                      ;ld de, OBJ.x
        dec de                      ;ld de, OBJ.y
        dec de                      ;ld de, OBJ.hw
        djnz MUSBWidthReset         ;If our Height != 0, then we keep drawing

    ;==============================================
    ;End Sprites
    ;==============================================
    ;Don't use any more sprites, and  Update spriteCount
        ld bc, spriteCount
        ld a, (sprUpdCnt)
        ld (bc), a
        ld l, a
        inc bc
        ld a, (bc)
        ld h, a
        ld (hl), $d0

    ;Reset our offsets
        xor a
        ld hl, sprYOff
        ld (hl), a
        inc hl                  ;ld hl, (sprXOff)
        ld (hl), a
        inc hl                  ;ld hl, (sprCCOff)
        ld (hl), a              

    pop hl                      ;Recovering HL

    ret
