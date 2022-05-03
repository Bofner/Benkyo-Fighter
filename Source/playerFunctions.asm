;==================================================
; Check Controls
;==================================================

;Checks the input of player 1 joypad
;Parameters: None
;Affects: hl, a, e, bc
Joypad1Check:

;Update kb.frameCount
    ld hl, kb.frameCount           ;Update frame count
    inc (hl)                    ;Otherwise, increase

    ;Check for directional inputs
    ;All of the $Fx numbers correspond to the 8-bit flags set by the joypad
    ;Each direction corresponds to a single bit flip, where all bits are
    ;1 by default, and flip to 0 when activated
    in a, $dc                    ;Send Joypad port 1 input data to register A
    ;Right now we are only checking for movement, so we don't care about button 
    ;   presses juuuuuuust yet, so we shift that part out of the way, but not
    ;   before setting it aside
    ld hl, kb.input
    ld (hl), a
    SLA a
    SLA a
    SLA a
    SLA a

    ld b, a                      ;save A in B
    ;UP
    ld c, $E0
    xor c                         ;Check to see if JUST bit 0 is set
    jp z, Up                     ;If it's 0, then it's set, and pilot moves up
    ;DOWN
    ld a, b                      ;restore A with B
    ld c, $D0                    
    xor c                         ;Check to see if JUST bit 1 is set
    jp z, Down                   ;If it's 0, then it's set, and pilot moves down
    ;LEFT
    ld a, b                      ;restore A with B
    ld c, $B0
    xor c                         ;Check to see if JUST bit 2 is set
    jp z, Left                   ;If it's 0, then it's set, and pilot moves left
    ;UL
    ld a, b                      ;restore A with B
    ld c, $A0
    xor c                         ;Check to see if bit 0 & 2 is set
    jp z, UL                     ;If it's 0, then it's set, and pilot moves up & left
    ;DL
    ld a, b                      ;restore A with B
    ld c, $90                    
    xor c                         ;Check to see if bit 1 & 2 is set
    jp z, DL                   ;If it's 0, then it's set, and pilot moves down & left
    ;RIGHT
    ld a, b                      ;restore A with B
    ld c, $70
    xor c                         ;Check to see if JUST bit 3 is set
    jp z, Right                  ;If it's 0, then it's set, and pilot moves right
    ;UR
    ld a, b                      ;restore A with B
    ld c, $60
    xor c                         ;Check to see if bit 0 & 4 is set
    jp z, UR                     ;If it's 0, then it's set, and pilot moves up & right
    ;DR
    ld a, b                      ;restore A with B
    ld c, $50                    
    xor c                         ;Check to see if bit 1 & 4 is set
    jp z, DR                   ;If it's 0, then it's set, and pilot moves down & right
    call ButtonCheck             ;If not, then check button inputs

    ;Reset walk cycle if nothing was pressed
    call ResetWalkCycle

CheckPreviousInput:

    ;UP?
    ld a, (kb.direction)                ;Use proper still animation frame
    ld c, $00                    ;Check if last input was UP
    cp c                         ;
    jp z, UStill                 ;Draw still UP frame

    ;DOWN?
    ld c, $01                    ;Check if last input was DOWN
    cp c                         ;
    jp z, DStill                 ;Draw still DOWN frame

    ;LEFT? 
    ld c, $02           ;Check if last input was LEFT
    cp c                         ;
    jp z, LWalk2                 ;Draw still LEFT frame  
  
    ;UL? 
    ld c, $03                    ;Check if last input was UL
    cp c                         ;
    jp z, ULWalk2                 ;Draw still LEFT frame  
 
    ;DL? 
    ld c, $04                    ;Check if last input was DL
    cp c                         ;
    jp z, DLWalk2                 ;Draw still LEFT frame 
    
    ;RIGHT? 
    ld c, $05                    ;Check if last input was RIGHT
    cp c                         ;
    jp z, RWalk2                 ;Draw still LEFT frame  

    ;UR? 
    ld c, $06                    ;Check if last input was UR
    cp c                         ;
    jp z, URWalk2                 ;Draw still LEFT frame  

    ;DR? 
    ld c, $07                    ;Check if last input was DR
    cp c                         ;
    jp z, DRWalk2                 ;Draw still LEFT frame     

    ret

CheckPreviousInputActive:
    ;UP?
    ld a, (kb.direction)         ;Use proper  animation frame
    ld c, $00                    ;Check if last input was UP
    cp c                         ;
    jp z, UpAnim                 ;Draw  UP frame
    ;DOWN?
    ld c, $01                    ;Check if last input was DOWN
    cp c                         ;
    jP z, DownAnim                 ;Draw  DOWN frame
    ;LEFT? 
    ld c, $02                    ;Check if last input was LEFT
    cp c                         ;
    jP z, LeftAnim                 ;Draw  LEFT frame    
    ;UL? 
    ld c, $03                    ;Check if last input was UL
    cp c                         ;
    jP z, ULAnim                 ;Draw  LEFT frame   
    ;DL? 
    ld c, $04                    ;Check if last input was DL
    cp c                         ;
    jP z, DLAnim                 ;Draw  LEFT frame     
    ;RIGHT? 
    ld c, $05                    ;Check if last input was RIGHT
    cp c                         ;
    jP z, RightAnim                 ;Draw  LEFT frame  
    ;UR? 
    ld c, $06                    ;Check if last input was UR
    cp c                         ;
    jP z, URAnim                 ;Draw  LEFT frame  
    ;DR? 
    ld c, $07                    ;Check if last input was DR
    cp c                         ;
    jP z, DRAnim                 ;Draw  LEFT frame  
    ret


Up:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 2                     ;just below the nose of the ship
    ld c, UpBounds               ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jr c, +                      ;If we are, then skip collision detection, and don't move
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    add a, 8                     ;Right in the middle of the ship
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jr nz, +                    ;If Yes, then don't adjust x position
    ;If not, then adjust X-position
    ld hl, kb.y                   ;HL points to pilot's Y coord
    ld a, (kb.y)                  ;A takes pilot's Y coord
    dec a                        ;Decreases it
    ld (hl), a                   ;And it gets saved
    ;But first check if we need to normalize
    push hl
    ld hl, kb.frameCount
    bit 1, (hl)
    pop hl
    jr z, +
    dec a
    ld (hl), a 
    
+:
    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive

    ;else if button not pressed, go to up
+:
    jp UpAnim

Down:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 14                    ;Just under the nose of the ship
    ld c, DownBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jr nc, +                     ;If we are, then skip collision detection, and don't move
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    add a, 8                     ;Right in the middle of the ship
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jr nz, +                    ;If Yes, then don't adjust x position
    ;If not, then adjust Y-position
    ld hl, kb.y                   ;HL points to pilot's Y coord
    ld a, (kb.y)                  ;A takes pilot's Y coord
    inc a                        ;Increases it
    ld (hl), a                   ;And it gets saved
    ;But first check if we need to normalize
    push hl
    ld hl, kb.frameCount
    bit 1, (hl)
    pop hl
    jr z, +
    inc a
    ld (hl), a 
+:    
    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp DownAnim

Left:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 12                    ;just below the middle of the ship
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    add a, 2                     ;0 is the offset for the LEFT direction (we can move in front of the object a little)
    ld c, LeftBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jr c, +                      ;If we are, then skip collision detection, and don't move
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jr nz, +                    ;If Yes, then don't adjust x position
    ;If not, then adjust X-position
    ld hl, kb.x                   ;HL points to pilot's X coord
    ld a, (kb.x)                  ;A takes pilot's X coord
    dec a                        ;Decreases it
    ld (hl), a                   ;And it gets saved
    ;But first check if we need to normalize
    push hl
    ld hl, kb.frameCount
    bit 1, (hl)
    pop hl
    jr z, +
    dec a
    ld (hl), a 
+:
    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp LeftAnim

UL:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 2                     ;just below the nose of the ship
    ld c, UpBounds               ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp c, Left                   ;If we are, then skip collision detection, and try moving left
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    ld c, LeftBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp c, Up                     ;If we are, then skip collision detection, and try moving up
    add a, 8                     ;For collision detection, we want our X to be in the middle of the ship
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jr nz, Left                    ;If Yes, then don't adjust x position
    ;If not, then adjust X-position
    ld hl, kb.y                   ;HL points to pilot's Y coord
    ld a, (kb.y)                  ;A takes pilot's Y coord
    dec a                        ;Decreases it
    ld (hl), a                   ;And it gets saved

    ld hl, kb.x                   ;HL points to pilot's X coord
    ld a, (kb.x)                  ;A takes pilot's X coord
    dec a                        ;Decreases it
    ld (hl), a                   ;And it gets saved

    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp ULAnim

DL:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 14                    ;Just under the nose of the ship
    ld c, DownBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp nc, Left                  ;If we are, then skip collision detection, and try left
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    ld c, LeftBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp c, Down                  ;If we are, then skip collision detection, and try down
    add a, 8                     ;Right in the middle of the ship for collision detection
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jp nz, Left                  ;If Yes, then try and move left
    ;If not, then adjust Y-position
    ld hl, kb.y                   ;HL points to pilot's Y coord
    ld a, (kb.y)                  ;A takes pilot's Y coord
    inc a                        ;Increases it
    ld (hl), a                   ;And it gets saved

    ld hl, kb.x                   ;HL points to pilot's X coord
    ld a, (kb.x)                  ;A takes pilot's X coord
    dec a                        ;Decreases it
    ld (hl), a                   ;And it gets saved

    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp DLAnim

Right:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 12                    ;just below the middle of the ship
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    add a, 14                    ;16 is the offset for the RIGHT direction (we can move in front of the object a little)
    ld c, RightBounds            ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jr nc, +                     ;If we are, then skip collision detection, and don't move
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jr nz, +                     ;If Yes, then don't adjust x position

    ld hl, kb.x                   ;If no collision, then update X position
    ld a, (kb.x)
    inc a                        ;Increases it
    ld (hl), a                   ;And it gets saved
    ;But first check if we need to normalize
    push hl
    ld hl, kb.frameCount
    bit 1, (hl)
    pop hl
    jr z, +
    inc a
    ld (hl), a 
+:
    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp RightAnim

UR:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 2                     ;just below the nose of the ship
    ld c, UpBounds               ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp c, Right                  ;If we are, then skip collision detection, and try right
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    add a, 16                    ;The right edge of the ship
    ld c, RightBounds            ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp nc, Up                    ;If we are, then skip collision detection, and try up
    sub 8                        ;Right in the middle of the ship for collision detection
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jr nz, Right                     ;If Yes, then don't adjust x position
    ;If not, then adjust Y-position
    ld hl, kb.y                   ;HL points to pilot's Y coord
    ld a, (kb.y)                  ;A takes pilot's Y coord
    dec a                        ;Decreases it
    ld (hl), a                   ;And it gets saved

    ld hl, kb.x                   ;If no collision, then update X position
    ld a, (kb.x)
    inc a                        ;Increases it
    ld (hl), a                   ;And it gets saved

    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp URAnim

DR:
    ;Set up for collision detection, then detect
    ld a, (kb.y)                  ;Load our Y coordinate into C
    add a, 14                    ;Just under the nose of the ship
    ld c, DownBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp nc, Right                     ;If we are, then skip collision detection, and try right
    ld e, a                      ;
    ld a, (kb.x)                  ;Load our X coordinate into H
    add a, 16                    ;The right edge of the ship
    ld c, RightBounds             ;Before we check collision, see if we are at the screen boarder
    cp c                         ;
    jp nc, Down                  ;If we are, then skip collision detection, and try down
    sub 8                        ;Right in the middle of the ship
    ld h, a                      ;
    call BGTileCollision         ;Are we colliding with something? Yes (1) or no (0)?
    jp nz, Right                 ;If Yes, then try and move right
    ;If not, then adjust Y-position
    ld hl, kb.y                   ;HL points to pilot's Y coord
    ld a, (kb.y)                  ;A takes pilot's Y coord
    inc a                        ;Increases it
    ld (hl), a                   ;And it gets saved

    ld hl, kb.x                   ;If no collision, then update X position
    ld a, (kb.x)
    inc a                        ;Increases it
    ld (hl), a                   ;And it gets saved
   
    call ButtonCheck             ;Check to see if buttons being pressed
    ;If button pressed, then use last input for animation
    ld c, $01                    ;Checking to see if button was pressed
    xor c
    jp nz, +                     ;If button isn't pressed, then skip the following:
    jp CheckPreviousInputActive
+:
    jp DRAnim
    
;Returns: c = strafe (Yes or No, $01 or $00)
ButtonCheck:

;First, let's check on our active shots
    ld hl, shots.1.resetTimer
    call ContinueShot
    
    ld hl, shots.2.resetTimer
    call ContinueShot
;Now let's check out what buttons are being pressed
    ld a, (kb.input)         ;Check input again
    srl a                   ;Isolate the button press
    srl a
    srl a
    srl a
    ;Check for just strafe button
    ld b,  a                ;For safe keeping
    ld c, $0D               ;Check strafe
    xor c
    jr z, ++                ;If SW2 IS pressed, then...
    ;Check for strafe and shot button
    ld a, b                 ;We thank B for keeping A safe
    ld c, $0C               ;Check strafe with shot
    xor c
    jr z, +                 ;If SW2 IS pressed, then...
    ;Check for just shot button
    ld a,  b                ;For safe keeping
    ld c, $0E               ;Check strafe
    xor c
    jr z, +++               ;If SW1 IS pressed, then...
    ;No strafe detected
    ld a, $00
    call KBUpdateSprite
    ret
+: 
    call KBShoot

++: 
    ;Strafe detected
    call KBUpdateSprite
    ld a, $01               ;... Set A to 1
    ret
+++: 
    call KBShoot
    call KBUpdateSprite
    ret


KBUpdateSprite:
;These will always be the last sprites to be updated, and it needs to happen
;   Every frame after we have updated the coordinates. 
    ld de, kb.sprNum
    call MultiUpdateSATBuff
/*
    ;LEFT HULL
    ld a, (kb.x)
    ld b, a
    ld a, (kb.cc)
    ld c, a
    ld a, (kb.y)   
    call SingleUpdateSATBuff
    ;RIGHT HULL
    ld a, (kb.x)
    add a, 8
    ld b, a
    ld a, (kb.cc)
    add a, 2
    ld c, a
    ld a, (kb.y)   
    call SingleUpdateSATBuff
*/

    ret

;===================================================
; Check Animations
;===================================================
;----------------
; UP
;----------------
UpAnim:
    ld a, $00                    ;Set our Animation to face UP
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, UWalk1

    ld c, 12
    cp c
    jr c, UWalk2

    ld c, 18
    cp c
    jr c, UWalk3

    ld c, 24
    cp c
    jr c,UWalk2

    cp c
    jP nc, ResetWalkCycle

UStill:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp2                 ;Location of tile data
    ld bc, KBUp2End-KBUp2        ;Counter for the number of bytes we write
    call CopyToVDP
    ret

UWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp1                 ;Location of tile data
    ld bc, KBUp1End-KBUp1        ;Counter for the number of bytes we write
    call CopyToVDP
    ret

UWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp2                 ;Location of tile data
    ld bc, KBUp2End-KBUp2        ;Counter for the number of bytes we write
    call CopyToVDP
    ret


UWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp3                 ;Location of tile data
    ld bc, KBUp3End-KBUp3        ;Counter for the number of bytes we write
    call CopyToVDP
    ret
;-----------------
; DOWN
;-----------------
DownAnim:
    ld a, $01                    ;Set our Animation to face DOWN
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, DWalk1

    ld c, 12
    cp c
    jr c, DWalk2

    ld c, 18
    cp c
    jr c, DWalk3

    ld c, 24
    cp c
    jr c,DWalk2

    cp c
    jp nc, ResetWalkCycle

DStill:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown2                 ;Location of tile data
    ld bc, KBDown2End-KBDown2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown1                 ;Location of tile data
    ld bc, KBDown1End-KBDown1      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown2                 ;Location of tile data
    ld bc, KBDown2End-KBDown2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret


DWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown3                 ;Location of tile data
    ld bc, KBDown3End-KBDown3      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;-----------------
; LEFT
;-----------------
LeftAnim:
    ld a, $02                    ;Set our Animation to face LEFT
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, LWalk1

    ld c, 12
    cp c
    jr c, LWalk2

    ld c, 18
    cp c
    jr c, LWalk3

    ld c, 24
    cp c
    jr c,LWalk4

    cp c
    jp nc, ResetWalkCycle

;Walk cycle doesn't start with 1 because the 4th frame is the better STILL frame
LWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft3                 ;Location of tile data
    ld bc, KBLeft3End-KBLeft3      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

LWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft4                 ;Location of tile data
    ld bc, KBLeft4End-KBLeft4      ;Counter for the number of bytes we write
    call CopyToVDP
    ret


LWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft1                 ;Location of tile data
    ld bc, KBLeft1End-KBLeft1      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

LWalk4:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft2                 ;Location of tile data
    ld bc, KBLeft2End-KBLeft2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;-----------------
; UL
;-----------------
ULAnim:
    ld a, $03                    ;Set our Animation to face UP
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, ULWalk1

    ld c, 12
    cp c
    jr c, ULWalk2

    ld c, 18
    cp c
    jr c, ULWalk3

    ld c, 24
    cp c
    jr c,ULWalk2

    cp c
    jP nc, ResetWalkCycle

ULWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUL1                 ;Location of tile data
    ld bc, KBUL1End-KBUL1      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

ULWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUL2                 ;Location of tile data
    ld bc, KBUL2End-KBUL2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

ULWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUL3                 ;Location of tile data
    ld bc, KBUL3End-KBUL3      ;Counter for the number of bytes we write
    call CopyToVDP
    ret


;-----------------
; UL
;-----------------
DLAnim:
    ld a, $04                    ;Set our Animation to face DOWN
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, DLWalk1

    ld c, 12
    cp c
    jr c, DLWalk2

    ld c, 18
    cp c
    jr c, DLWalk3

    ld c, 24
    cp c
    jr c,DLWalk2

    cp c
    jP nc, ResetWalkCycle

DLWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDL1                 ;Location of tile data
    ld bc, KBDL1End-KBDL1      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DLWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDL2                 ;Location of tile data
    ld bc, KBDL2End-KBDL2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DLWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDL3                 ;Location of tile data
    ld bc, KBDL3End-KBDL3      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;-----------------
; RIGHT
;-----------------
RightAnim:
    ld a, $05                    ;Set our Animation to face RIGHT
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)          ;Hand counter back over to A
    ld c, 6                 ;Check where we are in our animation
    cp c
    jr c, RWalk1

    ld c, 12
    cp c
    jr c, RWalk2

    ld c, 18
    cp c
    jr c, RWalk3

    ld c, 24
    cp c
    jr c,RWalk4

    cp c
    jp nc, ResetWalkCycle

;Walk cycle doesn't start with 1 because the 4th frame is the better STILL frame
RWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight3                 ;Location of tile data
    ld bc, KBRight3End-KBRight3     ;Counter for the number of bytes we write
    call CopyToVDP
    ret

RWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight4                 ;Location of tile data
    ld bc, KBRight4End-KBRight4     ;Counter for the number of bytes we write
    call CopyToVDP
    ret

RWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight1                 ;Location of tile data
    ld bc, KBRight1End-KBRight1     ;Counter for the number of bytes we write
    call CopyToVDP
    ret

RWalk4:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight2                 ;Location of tile data
    ld bc, KBRight2End-KBRight2     ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;-----------------
; UR
;-----------------
URAnim:
    ld a, $06                    ;Set our Animation to face UP
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, URWalk1

    ld c, 12
    cp c
    jr c, URWalk2

    ld c, 18
    cp c
    jr c, URWalk3

    ld c, 24
    cp c
    jr c,URWalk2

    cp c
    jP nc, ResetWalkCycle

URWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUR1                 ;Location of tile data
    ld bc, KBUR1End-KBUR1      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

URWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUR2                 ;Location of tile data
    ld bc, KBUR2End-KBUR2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

URWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUR3                 ;Location of tile data
    ld bc, KBUR3End-KBUR3      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;-----------------
; DR
;-----------------
DRAnim:
    ld a, $07                    ;Set our Animation to face DOWN
    ld hl, kb.direction                 ;
    ld (hl), a                   ;
    ld a, (kb.frameCount)         ;Hand counter back over to A
    ld c, 6                ;Check where we are in our animation
    cp c
    jr c, DRWalk1

    ld c, 12
    cp c
    jr c, DRWalk2

    ld c, 18
    cp c
    jr c, DRWalk3

    ld c, 24
    cp c
    jr c,DRWalk2

    cp c
    jP nc, ResetWalkCycle

DRWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDR1                 ;Location of tile data
    ld bc, KBDR1End-KBDR1      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DRWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDR2                 ;Location of tile data
    ld bc, KBDR2End-KBDR2      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DRWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDR3                 ;Location of tile data
    ld bc, KBDR3End-KBDR3      ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;===================================================
; Reset Animation
;===================================================
ResetWalkCycle:
    ld hl, kb.frameCount                ;Reset animation counter 
    ld a, (kb.frameCount)               ;
    ld a, 0                      ;
    ld (hl), a                   ;
    ret

;===================================================
; KB has been hit Subroutine
;===================================================
KBGotHit:
