;==================================================
; Check Controls
;==================================================

Joypad1Check:
    ;Checks the input of player 1 joypad
    ;Parameters: None
    ;Affects: hl, a, bc

    ;Adjust animation Counter
    ld hl, kbAnim                ;Increase animation counter 
    ld a, (kbAnim)               ;
    inc a                           ;
    ld (hl), a                      ;
    ld c, a                         ;Set C to hold animation counter

    ;Check for directional inputs
    in a, $dc                       ;Send Joypad port 1 input data to register A
    ;UP
    bit 0, a                        ;Check to see if bit 0 is set
    jr z, Up                        ;If it's 0, then it's set, and pilot moves up
    ;DOWN
    bit 1, a                        ;Check to see if bit 1 is set
    jr z, Down                      ;If it's 0, then it's set, and pilot moves down
    ;LEFT
    bit 2, a                        ;Check to see if bit 2 is set
    jr z, Left                      ;If it's 0, then it's set, and pilot moves left
    ;RIGHT
    bit 3, a                        ;Check to see if bit 3 is set
    jr z, Right                     ;If it's 0, then it's set, and pilot moves right
    call ButtonCheck                ;If not, then check button inputs

    ;Reset walk cycle if nothing was pressed
    call ResetWalkCycle

    ;Check previous input
    ;UP?
    ld a, (kbPos)                ;Use proper still animation frame
    ld c, $00                       ;Check if last input was UP
    cp c                            ;
    jr z, UStill                   ;Draw still UP frame
    ;DOWN?
    ld c, $01                       ;Check if last input was UP
    cp c                            ;
    jP z, DStill                    ;Draw still DOWN frame
    ;LEFT? 
    ld c, $02                       ;Check if last input was UP
    cp c                            ;
    jP z, LWalk2                    ;Draw still LEFT frame    
    ;RIGHT? 
    ld c, $03                       ;Check if last input was UP
    cp c                            ;
    jP z, RWalk2                    ;Draw still LEFT frame  
    ret


Up:
    ld a, $00                       ;Set our Animation to face UP
    ld hl, kbPos                 ;
    ld (hl), a                      ;

    ld hl, kbY                   ;HL points to pilot's Y coord
    ld a, (kbY)                  ;A takes pilot's Y coord
    dec a                           ;Decreases it
    ld (hl), a                      ;And it gets saved
    call ButtonCheck                ;Check to see if buttons being pressed
    jr UpAnim

Down:
    ld a, $01                       ;Set our Animation to face DOWN
    ld hl, kbPos                 ;
    ld (hl), a                      ;

    ld hl, kbY                   ;HL points to pilot's Y coord
    ld a, (kbY)                  ;A takes pilot's Y coord
    inc a                           ;Increases it
    ld (hl), a                      ;And it gets saved
    call ButtonCheck                  ;Check to see if buttons being pressed
    jp DownAnim

Left:
    ld a, $02                       ;Set our Animation to face LEFT
    ld hl, kbPos                 ;
    ld (hl), a                      ;

    ld hl, kbX                   ;HL points to pilot's X coord
    ld a, (kbX)                  ;A takes pilot's X coord
    dec a                           ;Decreases it
    ld (hl), a                      ;And it gets saved
    call ButtonCheck                  ;Check to see if buttons being pressed
    jp LeftAnim

Right:
    ld a, $03                       ;Set our Animation to face RIGHT
    ld hl, kbPos                 ;
    ld (hl), a                      ;

    ld hl, kbX                   ;HL points to pilot's X coord
    ld a, (kbX)                  ;A takes pilot's X coord
    inc a                           ;Increases it
    ld (hl), a                      ;And it gets saved
    call ButtonCheck                ;Check to see if buttons being pressed
    jp RightAnim
    

ButtonCheck:
    ret

;===================================================
; Check Animations
;===================================================
;----------------
; UP
;----------------
UpAnim:
    ld a, c                 ;Hand counter back over to A
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
    ld bc, KBUp2End-KBUp2  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

UWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp1                 ;Location of tile data
    ld bc, KBUp1End-KBUp1  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

UWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp2                 ;Location of tile data
    ld bc, KBUp2End-KBUp2  ;Counter for the number of bytes we write
    call CopyToVDP
    ret


UWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp3                 ;Location of tile data
    ld bc, KBUp3End-KBUp3  ;Counter for the number of bytes we write
    call CopyToVDP
    ret
;----------------
; DOWN
;-----------------
DownAnim:
    ld a, c                 ;Hand counter back over to A
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
    ld bc, KBDown2End-KBDown2  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown1                 ;Location of tile data
    ld bc, KBDown1End-KBDown1  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

DWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown2                 ;Location of tile data
    ld bc, KBDown2End-KBDown2  ;Counter for the number of bytes we write
    call CopyToVDP
    ret


DWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBDown3                 ;Location of tile data
    ld bc, KBDown3End-KBDown3  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;----------------
; LEFT
;-----------------
LeftAnim:
    ld a, c                 ;Hand counter back over to A
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
    ld bc, KBLeft3End-KBLeft3  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

LWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft4                 ;Location of tile data
    ld bc, KBLeft4End-KBLeft4  ;Counter for the number of bytes we write
    call CopyToVDP
    ret


LWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft1                 ;Location of tile data
    ld bc, KBLeft1End-KBLeft1  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

LWalk4:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBLeft2                 ;Location of tile data
    ld bc, KBLeft2End-KBLeft2  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;----------------
; RIGHT
;-----------------
RightAnim:
    ld a, c                 ;Hand counter back over to A
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
    jr nc, ResetWalkCycle

;Walk cycle doesn't start with 1 because the 4th frame is the better STILL frame
RWalk1:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight3                 ;Location of tile data
    ld bc, KBRight3End-KBRight3  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

RWalk2:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight4                 ;Location of tile data
    ld bc, KBRight4End-KBRight4  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

RWalk3:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight1                 ;Location of tile data
    ld bc, KBRight1End-KBRight1  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

RWalk4:
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBRight2                 ;Location of tile data
    ld bc, KBRight2End-KBRight2  ;Counter for the number of bytes we write
    call CopyToVDP
    ret

;===================================================
; Reset Animation
;===================================================
ResetWalkCycle:
    ld hl, kbAnim                ;Reset animation counter 
    ld a, (kbAnim)               ;
    ld a, 0                      ;
    ld (hl), a                   ;
    ret
