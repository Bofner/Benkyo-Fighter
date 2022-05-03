;==============================================================
; Carrier structure
;==============================================================
;For reference to the Carrier structure, look in structs.asm

;Parameters: IX = carrier.x
    ;x           
    ;y            
    ;cc          
    ;stage      
    ;vel

;I'm anticipating there only being one Carrier on screen at once,
;   but I'm still going to keep the code general, just in case I 
;   end up having more than one at a time

;==============================================================
; Carrier Constants
;==============================================================

.define leftDown   $00
.define separate   $01
.define rejoin     $02
.define exitLeft   $03
.define rightUp    $04
.define unspawned  $FF

.equ carrierLoc     $3740       ;Sprite VRAM location for Forever Carrier
.equ carrierSpr     $ba         ;CC VRAM location for Forever Carrier

;==============================================================
; Carrier Subroutines
;==============================================================
CarrierHandler: 
;Find out which subroutine we need to jump to
    ld a, (ix-1)        ;carrier.stage
    ld c, leftDown
    cp c
    jp z, CarrierTopEnter

    ld c, separate
    cp c
    jp z, CarrierSeparate

    ld c, rejoin
    cp c
    jp z, CarrierJoin

    ld c, exitLeft
    cp c
    jp z, CarrierBottomExit

    ld c, rightUp
    cp c
    jp z, CarrierBottomEnter

    ld c, unspawned
    cp c
    jp z, CarrierTopEnter

    ret

CarrierTopEnter:
 ;Joined, We need 6 sprites
;If carrier is spawning for the first time, then add sprites 
    ld a, (ix - 1)          ;carrier.stage
    ld c, unspawned         ;Joined
    cp c
    jr nz, +
;Let the SATBuffer know we have added 6 sprites (Carrier is both eye and carrier)
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
    ld a, leftDown          ;Joined and moving down and left
    ld (ix - 1), a          ;carrier.stage

+:
;The following chunk of code makes our carrier fly down and left to the
;   centerish of the screen
;DE is used for speed related reasons

;Move across the screen
    ld d, ixh
    ld e, ixl
    ld a, (de)
    ld c, $7b       ;About 1/2 across screen
    cp c
    jr z, +
;Halving the speed
    ld iy, frameCount
    bit 0, (iy + 0)
    jr nz, +
    dec a
    ld (de), a
    jr +

;Move down the screen
+:
    inc de
    ld a, (de)
    ld c, $2e       ;About 1/2 down screen
    cp c
    jr z, +
;Halving the speed
    ;ld iy, frameCount
    bit 0, (iy + 0)
    jr nz, +
    inc a
    ld (de), a
    jr +

;Check if we are in position
+:
    ld a, (de)
    ld c, $2e       ;About 1/2 down screen
    cp c
    jr nz, +
    dec de
    ld a, (de)
    ld c, $7b       ;About 1/4 across screen
    cp c
    jr nz, +
    jp CarrierSeparate

+:
    jp CarrierUpdateSprite

CarrierSeparate:
;Going from 6 to 3 sprites
;If carrier is already separate, then don't remove sprites 
    ld a, (ix - 1)          ;carrier.stage
    ld c, separate          ;SEPARATE
    cp c
    jp z, +
;Otherwise, remove them, and update its stage to be separate ($01), and update cc
    ld b, 0
    call UpdateSprCnt
    ld b, 0
    call UpdateSprCnt
    ld b, 0
    call UpdateSprCnt
    ld a, separate          ;SEPARATE
    ld (ix - 1), a          ;carrier.stage
    ld a, carrierSpr
    ld (ix + 2), a          ;carrier.cc

+:
     call CarrierUpdateSprite
;Now Big Eye must exist on its own and be BEHIND the carrier
    ld hl, bigEye.stage
    jp bigEyeHandler

   

CarrierEnemySpawn:
;Palette is going to be swapping around, and we will need to 
;   call our different enemies to be spawned in. Preferably pseudo random
;   enemies at pseudo random locations

CarrierJoin:
;Going from 3 to 6 sprites

CarrierBottomExit:
 ;Joined, We need 6 sprites

CarrierBottomEnter:
;Joined, We need 6 sprites

CarrierTopExit:
;SEPARATE, We need to only 3 sprites

CarrierUpdateSprite:
;Update the sprite for our Carrier
;LEFT HULL
    ld b, (ix + 0)  ;carrier.x
    ld c, (ix + 2)  ;carrier.cc
    ld a, (ix + 1)  ;carrier.y
    call SingleUpdateSATBuff

;COCKPIT
    ld a, (ix + 0)  ;carrier.x
    add a, 8
    ld b, a
    ld c, (ix + 2)  ;carrier.cc
    inc c
    inc c
    ld a, (ix + 1)  ;carrier.y
    call SingleUpdateSATBuff

;RIGHT HULL
    ld a, (ix + 0)  ;carrier.x
    add a, 16
    ld b, a
    ld a, (ix + 2)  ;carrier.cc
    add a, 4
    ld c, a
    ld a, (ix + 1)  ;carrier.y
    call SingleUpdateSATBuff

;IF leftDown, then we need 6 sprites (+3, but this is handled at entry)
    ld a, (ix - 1)      ;ld ix, carrier.stage
    ld c, 0
    cp c
    jp nz, +

;Go through adding the eyeball part
;LEFT HULL
    ld b, (ix + 0)  ;carrier.x
    ld a, (ix + 2)  ;carrier.cc
    add a, 6
    ld c, a
    ld a, (ix + 1)  ;carrier.y
    add a, 16        ;Eyeball drops down one row
    call SingleUpdateSATBuff

;MIDDLE HULL
    ld a, (ix + 0)  ;carrier.x
    add a, 8
    ld b, a
    ld a, (ix + 2)  ;carrier.cc
    add a, 8
    ld c, a
    ld a, (ix + 1)  ;carrier.y
    add a, 16        ;Eyeball drops down one row
    call SingleUpdateSATBuff

;RIGHT HULL
    ld a, (ix + 0)  ;carrier.x
    add a, 16
    ld b, a
    ld a, (ix + 2)  ;carrier.cc
    add a, 10
    ld c, a
    ld a, (ix + 1)  ;carrier.y
    add a, 16        ;Eyeball drops down one row
    call SingleUpdateSATBuff

+:
    ret
