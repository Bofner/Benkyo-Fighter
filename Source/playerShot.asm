

;==============================================================
; Player shots structure
;==============================================================
;For reference to the player_shots structure, look in villageFight.asm

;==============================================================
; Player fires shot
;==============================================================
;Handles KB firing his ship's gun, only called when button presssed
;Parameters: None
;Affects: A, HL, DE, BC
KBShoot:
;If it is, then check what shot we want to shoot
    ld hl, shots.1.resetTimer
    ld a, (hl)
    ld c, 4                 ;Check if this is our first shot
    cp c
    jp nz, @CreateShot

    ld hl, shots.2.resetTimer
    ld a, (hl)
    ld c, 4                 ;Check if this is our 2nd shot
    cp c
    jp nz, @CreateShot 
   
    ret

@CreateShot:
;Check to see if our shot buffer is satisfied
    ld de, kbShotBuffer
    ld a, (de)
    ld c, 0
    cp c
    jr z, ++
;We only want this to run for shot 1

    ld de, shots.1.resetTimer
    ld a, e
    ld c, l
    cp c
    jp nz, +

;Check to see if we need to wait before firing again
    ;ld hl, shots.resetTimer
    ld a, (hl)
    ld c, $00
    cp c
    jr nz, +
;Check if kbShotBuffer < 10
    ld de, kbShotBuffer
    ld a, (de)
    ld c, $0F
    cp c
    jr nc, +
;If it is, then let's reset it so we can have rapid fire at close range
    xor a
    ld (de), a
    jr ++
+:
    ret
++:
;Create a buffer period so we aren't rapid firing
    ld de, kbShotBuffer
    ld a, $1C
    ld (de), a

;Check to see if we need to wait before firing again
    ;ld hl, shots.resetTimer
    ld a, (hl)
    ld c, $00
    cp c
    jr z, +
    ret
+:

;Set up reset timer
    ld (hl), $04        ;Setting up for 3 frames of wait time
    inc hl

;Direction for shot 1
    ;ld hl, shots.direction
    ld a, (kb.direction)
    ld (hl), a

;Set X and Y coords
    call @SetShotPosition

;Make sure our shot is visible
    ld hl, spriteCount
    ld a, (spriteCount)
    inc a
    ld (hl), a
    ret
    ;jr ++
/*
+:  
;Decrease our reset timer each frame
    ;ld hl, shots.1.resetTimer
    ;ld a, (hl)
    dec a
    ld (hl), a
*/

;++:
;Leave 
    ;ret

;Sets the position coordinates for a shot depending on its direction
;Parameters: HL = shot.direction
;Affects: HL, A, C
@SetShotPosition:
;Check If we are facing UP
    ld a, (hl)
    ld c, 0
    cp c
    jp nz, +++
@@Up:
;Set location for facing UP
    ;Y
    inc hl
    ld a, (kb.y) 
    sub 9
    ld (hl), a
    
    ;X
    inc hl
    ld a, (kb.x) 
    add a, 3
    ld (hl), a
    inc hl          ;ld hl, sprite.cc

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotUp                 ;Location of tile data
    ld bc, KBShotUpEnd-KBShotUp  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

+++:
;Check if we are facing DOWN
    ld a, (hl)
    ld c, 1
    cp c
    jp nz, +++
@@Down:
;Set location for facing UP
    inc hl
    ld a, (kb.y) 
    add a, 9
    ld (hl), a
    inc hl  
    
    ld a, (kb.x) 
    add a, 3
    ld (hl), a      ;ld hl, sprite.cc
    inc hl

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotDown                 ;Location of tile data
    ld bc, KBShotDownEnd-KBShotDown  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

+++:
;Check if we are facing LEFT
    ld a, (hl)
    ld c, 2
    cp c
    jp nz, +++
@@Left:
;Set location for facing UP

    inc hl
    ld a, (kb.y) 
    add a, 1
    ld (hl), a
    inc hl  
    
    ld a, (kb.x) 
    sub 4
    ld (hl), a          ;ld hl, sprite.cc
    inc hl
 
;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotLeft                 ;Location of tile data
    ld bc, KBShotLeftEnd-KBShotLeft  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

+++:
;Check if we are facing UL
    ld a, (hl)
    ld c, 3
    cp c
    jp nz, +++
@@UL:
;Set location for facing UL
    
    inc hl
    ld a, (kb.y) 
    sub 6
    ld (hl), a
    inc hl  
    
    ld a, (kb.x) 
    sub 2
    ld (hl), a      ;ld hl, sprite.cc
    inc hl

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotUL                 ;Location of tile data
    ld bc, KBShotULEnd-KBShotUL  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

+++:
;Check if we are facing DL
    ld a, (hl)
    ld c, 4
    cp c
    jp nz, +++
@@DL:
;Set location for facing DL
        inc hl
    ld a, (kb.y) 
    add a, 6
    ld (hl), a
    inc hl  
    
    ld a, (kb.x) 
    sub 2
    ld (hl), a      ;ld hl, sprite.cc
    inc hl

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotDL                 ;Location of tile data
    ld bc, KBShotDLEnd-KBShotDL  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

+++:
;Check if we are facing RIGHT
    ld a, (hl)
    ld c, 5
    cp c
    jp nz, +++
@@Right:
;Set location for facing UP

    inc hl
    ld a, (kb.y) 
    add a, 1
    ld (hl), a

    inc hl
    ld a, (kb.x) 
    add a, 12
    ld (hl), a      ;ld hl, sprite.cc
    inc hl

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotRight                 ;Location of tile data
    ld bc, KBShotRightEnd-KBShotRight  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

+++:
;Check if we are facing UR
    ld a, (hl)
    ld c, 6
    cp c
    jp nz, +++
@@UR:
;Set location for facing UR

    inc hl
    ld a, (kb.y) 
    sub 6
    ld (hl), a
    inc hl  
    
    ld a, (kb.x) 
    add a, 9
    ld (hl), a      ;ld hl, sprite.cc
    inc hl

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotUR                 ;Location of tile data
    ld bc, KBShotUREnd-KBShotUR  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

+++:
;Check if we are facing DR
    ld a, (hl)
    ld c, 7
    cp c
    jp nz, +++
@@DR:
;Set location for facing DR
    

    inc hl
    ld a, (kb.y) 
    add a, 5
    ld (hl), a
    inc hl  
    
    ld a, (kb.x) 
    add a, 10
    ld (hl), a          ;ld hl, sprite.cc
    inc hl

;Set proper tile for shot angle
    ld a, (hl)
    ld c, kbShotSpr1
    cp c
    jr nz, +
    ld hl, plyShot1Loc | VRAMWrite
    jr ++
+:
    ld hl, plyShot2Loc | VRAMWrite
++:
    call SetVDPAddress
    ld hl, KBShotDR                 ;Location of tile data
    ld bc, KBShotDREnd-KBShotDR  ;Counter for the number of bytes we write
    call CopyToVDP

    ret

;Other options to be implemented
+++:
    ret

;Used to move our shot
;Parameters: HL = shots.resetTimer
;   May be referenced from outside of this file
;   Potentially called every frame
ContinueShot:
;Decrement the buffer each frame if it isn't at zero
    ld de, kbShotBuffer
    ld a, (de)
    ld c, 0
    cp c
    jp z, +
    dec a
    ld (de), a
    ;ret

+:
;Check if our shot is active
    ;ld hl, shots.restTimer
    ld d, h   ;Used for BYE SHOT, shots.resetTimer
    ld e, l   ;
    ld a, (hl)
    ld c, 4
    cp c
    jr z, ++
;... if not, then Decrease our reset timer each frame
;   and go back to the top
    ;ld hl, shots.1.resetTimer
    ld c, 0
    cp c
    jr z, +
    dec a
    ld (hl), a
+:
    ret

++:
;If the shot is at the border, then we can get rid of it
    ;ld hl, shots.y
    inc hl
    inc hl
    ;inc hl
    ld a, (hl)
    ld c, $e0       ;Slightly higher UpBounds
    cp c
    jp nc, ByeShot

    ;ld hl, shots.1.y
    ;ld a, (hl)
    ld c, DownBounds
    cp c
    jp nc, ByeShot

    ;ld hl, shots.x
    ;dec hl
    inc hl
    ld a, (hl)
    ld c, RightBounds
    cp c
    jp nc, ByeShot

    ;ld hl, shots.1.x
    ld a, (hl)
    ld c, LeftBounds
    cp c
    jp c, ByeShot

;Otherwise, adjust the location
;By first checking our direction for UP
    ;ld hl, shots.1.direction
    dec hl
    dec hl
    ld a, (hl)
    ld c, 0
    cp c
    jp nz, +
@ShotMoveUp:
/*
    ld hl, shots.1.x        ;Move shot latterally (Don't)
    ld a, (hl) 
    add a, 4
    ld (hl), a
*/
    ;ld hl, shots.y        ;Move shot vertically (Up)
    inc hl
    ;inc hl
    ld a, (hl) 
    sub 4
    ld (hl), a
    ;dec hl
    ;dec hl
    jp UpdateShotSprite
+:
;Checking our direction for DOWN
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 1
    cp c
    jp nz, +
@ShotMoveDown:
/*
    ld hl, shots.1.x        ;Move shot latterally (Don't)
    ld a, (hl) 
    add a, 4
    ld (hl), a
*/
    ;ld hl, shots.y        ;Move shot vertically (DOWN)
    inc hl
    ;inc hl
    ld a, (hl) 
    add a, 4
    ld (hl), a
    ;dec hl
    ;dec hl
    jp UpdateShotSprite
+:
;Checking our direction for LEFT
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 2
    cp c
    jp nz, +
@ShotMoveLeft:

    ;ld hl, shots.1.x        ;Move shot latterally (LEFT)
    inc hl
    inc hl
    ld a, (hl) 
    sub 4
    ld (hl), a
    dec hl
/*
    ld hl, shots.1.y        ;Move shot vertically (Don't)
    ld a, (hl) 
    add a, 4
    ld (hl), a
*/
    jp UpdateShotSprite
+:
;Checking our direction for UL
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 3
    cp c
    jp nz, +
@ShotMoveUL:

    ;ld hl, shots.1.x        ;Move shot latterally (LEFT)
    inc hl
    inc hl
    ld a, (hl) 
    sub 3
    ld (hl), a

    ;ld hl, shots.1.y        ;Move shot vertically (UP)
    dec hl
    ld a, (hl) 
    sub 3
    ld (hl), a
    ;dec hl
    ;dec hl
    jp UpdateShotSprite
+:
;Checking our direction for DL
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 4
    cp c
    jp nz, +
@ShotMoveDL:

    ;ld hl, shots.1.x        ;Move shot latterally (LEFT)
    inc hl
    inc hl
    ld a, (hl) 
    sub 3
    ld (hl), a

    ;ld hl, shots.1.y        ;Move shot vertically (DOWN)
    dec hl
    ld a, (hl) 
    add a, 3
    ld (hl), a
    ;dec hl
    ;dec hl
    jp UpdateShotSprite
+:
;Checking our direction for RIGHT
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 5
    cp c
    jp nz, +
@ShotMoveRight:

    ;ld hl, shots.1.x        ;Move shot latterally (RIGHT)
    inc hl
    inc hl
    ld a, (hl) 
    add a, 4
    ld (hl), a
    dec hl
/*
    ld hl, shots.1.y        ;Move shot vertically (Don't)
    ld a, (hl) 
    add a, 4
    ld (hl), a
*/
    jp UpdateShotSprite
+:
;Checking our direction for UL
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 6
    cp c
    jp nz, +
@ShotMoveUR:

    ;ld hl, shots.1.x        ;Move shot latterally (RIGHT)
    inc hl
    inc hl
    ld a, (hl) 
    add a, 3
    ld (hl), a

    ;ld hl, shots.1.y        ;Move shot vertically (UP)
    dec hl
    ld a, (hl) 
    sub 3
    ld (hl), a
    ;dec hl
    ;dec hl
    jp UpdateShotSprite
+:
;Checking our direction for UL
    ;ld hl, shots.1.direction
    ld a, (hl)
    ld c, 7
    cp c
    jp nz, +
@ShotMoveDR:

    ;ld hl, shots.1.x        ;Move shot latterally (RIGHT)
    inc hl
    inc hl
    ld a, (hl) 
    add a, 3
    ld (hl), a

    ;ld hl, shots.1.y        ;Move shot vertically (DOWN)
    dec hl
    ld a, (hl) 
    add a, 3
    ld (hl), a
    ;dec hl
    ;dec hl
    jp UpdateShotSprite
+:

UpdateShotSprite:
;Update shot sprite
    ;dec hl
    inc hl
    ld b, (hl) ;(shots.x)
    dec hl
    ld a, (hl) ;(shots.y)
    inc hl
    inc hl
    ld c, (hl) ;(shots.cc)   
    call SingleUpdateSATBuff

    ret
;Parameters: DE = shots.y
ByeShot:
;Reset the x and y locations of shot to reduce complications
    dec hl
    ld a, (de)
    dec a
    ld (de), a

;We remove the sprite from being seen
    ld hl, spriteCount
    ld a, (spriteCount)
    dec a
    ld (hl), a

    ret

    


    
