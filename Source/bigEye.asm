;==============================================================
; Big Eye structure
;==============================================================
;For reference to the Big Eye structure, look in structs.asm

;Parameters: hl = bigEye.stage
    ;animTimer
    ;stage
    ;x           
    ;y            
    ;cc          
    ;health         BIT 7 is vulnerability toggle (1 = vulnerable)
    ;IF Big Eye gets hit, then he become invulnerable for a moment (a couple frames?)
    ;IF stage == opened && BIT 7, bigEye.health == 0 
    ;THEN jp BLinkyTime 

;==============================================================
; Big Eye Constants
;==============================================================
.define closed      $00
.define squinted    $01
.define opened      $02
.define moveDown    $03
.define moveUp      $04
.define palette     $05
.define spawn       $ff

.equ bigEyeRetLoc   $35c0        ;Sprite VRAM location for Big Eye
.equ bigEyeRetSpr   $ae       

.equ bigEyeLoc      $3680        ;Sprite VRAM location for Big Eye
.equ bigEyeSpr      $b8    

;==============================================================
; Big Eye Subroutines
;==============================================================
bigEyeHandler:  
       ld a, (hl)       ;ld hl, bigEye.stage
       ld c, closed
       cp c
       jp z, bigEyeClosing

       ld c, squinted
       cp c
       jp z, bigEyeSquinting

       ld c, opened
       cp c
       jp z, bigEyeOpening

       ld c, moveDown
       cp c
       jp z, bigEyeMoveDown

       ld c, moveUp
       cp c
       jp z, bigEyeMoveUp

       ld c, palette
       cp c
       jp z, bigEyePaletteSwap

       ld c, spawn
       cp c
       jp z, bigEyeRedraw

       ret

bigEyeRedraw:
;We need to spawn in the Big Eye, which is six sprites in size
    push hl
        ld b, 1
        call UpdateSprCnt
        ld b, 1
        call UpdateSprCnt
        ld b, 1
        call UpdateSprCnt

        ld b, 1
        call UpdateSprCnt
        ld b, 1
        call UpdateSprCnt
        ld b, 1
        call UpdateSprCnt
    pop hl

;Set Big Eye's Location (same as bigEye to start)
    ld (hl), closed          ;ld bigEye.stage, closed
    inc hl                   ;ld hl, bigEye.x
    ld a, (ix+0)             ;carrier.x
    ld (hl), a
    inc hl                   ;ld hl, bigEye.y
    ld a, (ix+1)             ;carrier.y
    ld (hl), a
    dec hl                   ;ld hl, bigEye.x
    dec hl                   ;ld hl, bigEye.stage
    ld (hl), moveDown        ;ld bigEye.stage, moveDown

;Update VRAM
    push hl
        ld hl, BigEyeRetina
        ld de, bigEyeRetLoc | VRAMWrite
        call Decompress

        ld hl, BigEyeClose
        ld de, bigEyeLoc | VRAMWrite
        call Decompress
    pop hl

    jp bigEyeUpdateSprite

bigEyeClosing:

bigEyeSquinting:

    push hl
        ld hl, BigEyeSquint
        ld de, bigEyeLoc | VRAMWrite
        call Decompress
    pop hl

    dec hl                       ;ld hl, bigEye.animTimer

    ld a, (hl)
    ld c, $00
    cp c
    jr nz, +
    inc (hl)                    ;Don't let animTimer roll over
    inc hl                      ;ld hl, bigEye.stage
    ld (hl), opened
    jp bigEyeUpdateSprite

+:
    dec (hl)                    ;bigEye.animTimer - 1
    inc hl                      ;ld hl, bigEye.stage
    jp bigEyeUpdateSprite

bigEyeOpening:
    
    push hl
        ld hl, BigEyeOpen
        ld de, bigEyeLoc | VRAMWrite
        call Decompress
    pop hl

    ld a, (frameCount)
    ld c, $1c
    cp c
    jr z, +
    ld (hl), palette

+:

    jp bigEyeUpdateSprite

bigEyeMoveDown:
;Move down one pixel
    inc hl                  ;ld hl, bigEye.x
    inc hl                  ;ld hl, bigEye.y
    ld a, (hl)
;Check if we are moved down a little enough
    ld c, $3a
    cp c
    jr z, ++
;Every other frame, move down one pixel
    ld iy, frameCount
    bit 1, (iy+0)
    jr z, +
    inc a
    ld (hl), a
+:
    dec hl                  ;ld hl, bigEye.x
    dec hl                  ;ld hl, bigEye.stage

    jp bigEyeUpdateSprite

++:
    inc hl                  ;ld hl, bigEye.cc
    inc hl                  ;ld hl, bigEye.health
    set 7, (hl)
    ld bc, -5                ;ld hl, bigEye.animTimer
    add hl, bc
    ld (hl), $10
    inc hl                  ;ld hl, bigEye.stage
    ld (hl), squinted
     

    jp bigEyeUpdateSprite


bigEyeMoveUp:

bigEyePaletteSwap:

    jp bigEyeUpdateSprite

;Make sure we are on bigEye.stage
bigEyeUpdateSprite:
;Update the sprite for our Big Eye
;LEFT RETINA
    inc hl      ;ld hl, bigEye.x
    ld b, (hl)
    inc hl      ;ld hl, bigEye.y
    ld a, (hl)
    inc hl      ;ld hl, bigEye.cc
    ld c, (hl)   
    call SingleUpdateSATBuff
;MIDDLE RETINA
    ;ld hl, bigEye.cc
    ld c, (hl)
    inc c
    inc c
    ld (hl), c  ;Update bigEye.cc
    dec hl      ;ld hl, bigEye.y
    dec hl      ;ld hl, bigEye.x
    ld a, 8
    add a, (hl)
    ld b, a
    inc hl      ;ld hl, bigEye.y
    ld a, (hl)
    call SingleUpdateSATBuff
;RIGHT RETINA
    dec hl      ;ld hl, bigEye.x
    ld a, 16
    add a, (hl)
    ld b, a
    inc hl      ;ld hl, bigEye.y
    ld a, (hl)
    inc hl      ;ld hl, bigEye.cc
    ld c, (hl)  
    inc c
    inc c
    ld (hl), c  ;Update bigEye.cc
    call SingleUpdateSATBuff


;Go through adding the eyeball part
;LEFT CORNIA
    ;ld hl, bigEye.cc
    ld c, (hl)
    inc c
    inc c
    ld (hl), c
    dec hl      ;ld hl, bigEye.y
    dec hl      ;ld hl, bigEye.x
    ld b, (hl)  ;Going back to the left hand side
    inc hl      ;ld hl, bigEye.y
    ld a, (hl)
    add a, 16    ;Moving down
    call SingleUpdateSATBuff

;MIDDLE CORNIA
    dec hl      ;ld hl, bigEye.x
    ld a, (hl)
    add a, 8
    ld b, a
    inc hl      ;ld hl, bigEye.y
    ld a, (hl)
    add a, 16
    inc hl      ;ld hl, bigEye.cc
    ld c, (hl)
    inc c
    inc c
    ld (hl), c  ;Update bigEye.cc
    call SingleUpdateSATBuff

;RIGHT CORNIA
    ;ld hl, bigEye.cc
    ld c, (hl)
    inc c
    inc c
    ld (hl), c  ;Update bigEye.cc
    dec hl      ;ld hl, bigEye.y
    dec hl      ;ld hl, bigEye.x
    ld a, 16
    add a, (hl)
    ld b, a
    inc hl      ;ld hl, bigEye.y
    ld a, (hl)
    add a, 16
    call SingleUpdateSATBuff


;Reset bigEye.cc
    inc hl              ;ld hl, bigEye.cc
    ld a, bigEyeRetSpr
    ld (hl), a
    
    ret