VillageFight:
;==============================================================
; Scene beginning
;==============================================================
    ld hl, sceneComplete
    ld (hl), $00


;==============================================================
; Memory (Structures and Variables) 
;==============================================================
;NOTE: structs may end up being overwritten if memory becomes limited
;   and certain enemies will never be seen together. I want this area
;   of memory to be dynamic to allow for a large cast of enemies. We
;   shall start ALL sprite objects data at $d000
.enum postBoiler export
    kb instanceof player
    shots instanceof player_shot 3
    carrier instanceof forever_carrier
    bigEye instanceof big_eye
    goose instanceof mongoose
    spinners instanceof chrome_spinner
.ende

;We currently have used 15 bytes, so we are at $D00F


;==============================================================
; Clear VRAM
;==============================================================
    
    ;First, let's set the VRAM write address to $0000
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ;Next, let's clear the VRAM with a bunch of zeros
    ld bc, $4000        ;Counter for our zeros in VRAM
-:  xor a
    out (VDPData), a    ;Output data in A to VRAM address (which auto increments)
    dec bc              ;Adjust the counter
    ld a, b             
    or c                ;Check if we are at zero
    jr nz,-             ;If not, loop back up

;==============================================================
; Load Palette
;==============================================================
    ; First we set the VRAM write address to CRAM for Sprite
    ld hl, $c010 | CRAMWrite
    call SetVDPAddress
    ; Next we send the VDP the palette data
    ld hl, villageFight_sprPal
    ld bc, villageFight_sprPalEnd-villageFight_sprPal
    call CopyToVDP

    ;Next we do for Background
    ld hl, $0000 | CRAMWrite
    call SetVDPAddress
    ;Next we send the BG palette data
    ld hl, villageFight_bgPal
    ld bc, villageFight_bgPalEnd-villageFight_bgPal
    call CopyToVDP

;==============================================================
; Load BG tiles 
;==============================================================
    ;First we write to VRAM write address for our font, which
    ;   resides at the end of our sprite characters
    ld hl, $1aa0 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, FontTiles                ;Location of tile data
    ld bc, FontTilesEnd-FontTiles   ;Counter for the number of bytes we write
    call CopyToVDP

    /*
    ;Loading our testing background
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, groundTiles                ;Location of tile data
    ld bc, groundTilesEnd-groundTiles   ;Counter for the number of bytes we write
    call CopyToVDP
    */
    ld hl, TestingGroundTiles
    ld de, $0000 | VRAMWrite
    call Decompress

;==============================================================
; Load Sprite tiles 
;==============================================================
    
    ;Now we want to write the character data. For now, we will just
    ;   keep all the frames in VRAM since there's so few
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, KBUp2                 ;Location of tile data
    ld bc, KBUp2End-KBUp2  ;Counter for the number of bytes we write
    call CopyToVDP

    ld hl, KBShotUp                 ;Location of tile data
    ld bc, KBShotUpEnd-KBShotUp  ;Counter for the number of bytes we write
    call CopyToVDP

    ld hl, CCWTiles1
    ld de, enemy1Loc | VRAMWrite
    call Decompress

    ld hl, CarrierCarry
    ld de, carrierLoc | VRAMWrite
    call Decompress

    ld hl, BigEyeCarry
    ld de, bigEyeRetLoc | VRAMWrite
    call Decompress

    ld hl, BigEyeClose
    ld de, bigEyeLoc | VRAMWrite
    call Decompress

    ld hl, Mongoose
    ld de, mongooseLoc | VRAMWrite
    call Decompress

;==============================================================
; Initialize Sprite variables 
;==============================================================
;Let a hold zero for initialization
    xor a          

;---------------------------------------
; KB
;---------------------------------------
;Initialize KB's starting position
    ld hl, kb.alive
    ld (hl), $01    ;KB is alive
    ld hl, kb.y
    ld (hl), 100
    ld hl, kb.x
    ld (hl), 150
    ld hl, kb.cc
    ld (hl), a

;Initialize KB's size
    ld hl, kb.hw
    ld (hl), $12            ;KB is 1x2

;Initialize KB's direction
    ld hl, kb.direction
    ld (hl), $01    

;Initialize the number of player shots
    ld hl, kbShotBuffer         ;Set number of player shots on screen
    ld (hl), a                  ;   to zero

;Initialize KB's hit detection subroutine
    ld hl, kb.hitAdr        
    ld bc, KBGotHit
    ld a, b                   ;High byte
    ld (hl), a
    inc hl
    ld a, c                   ;Low byte
    ld (hl), a
    xor a

;---------------------------------------
; KB's Shots
;---------------------------------------
;Initialize shots so they can fire
    ld hl, shots.1.resetTimer
    ld (hl), $03
    ld hl, shots.2.resetTimer
    ld (hl), $03

;Initialize VRAM Location for shots
    ld hl, shots.1.cc
    ld (hl), kbShotSpr1
    ld hl, shots.2.cc
    ld (hl), kbShotSpr2

;---------------------------------------
; Carrier
;---------------------------------------
;Initialize Forever Carrier's starting position
    ld hl, carrier.stage
    ld (hl), unspawned        ;Carrier is in the UNSPAWNED stage
    ld hl, carrier.y
    ld (hl), $e0
    ld hl, carrier.x
    ld (hl), 200
    ld hl, carrier.cc
    ld (hl), bigEyeRetSpr      ;It starts off carrying the big eye
    
;---------------------------------------
; Big Eye
;---------------------------------------
;Initialize Big Eye's starting position
    ld hl, bigEye.stage
    ld (hl), unspawned          ;Eye will start off closed
    ld hl, bigEye.y
    ld (hl), a
    ld hl, bigEye.x
    ld (hl), a
    ld hl, bigEye.cc
    ld (hl), bigEyeRetSpr       ;This is where the eye is stores in VRAM
    ld hl, bigEye.animTimer
    ld (hl), a
    ld hl, bigEye.health
    ld (hl), $10                ;Big Eye takes 16 hits to die (probably low)

;---------------------------------------
; Chrome Spinner
;---------------------------------------
;Initialize Chrome Spinner's starting position
    ld hl, spinners.alive
    ld (hl), $ff                ;Spinner is alive
;Initialize CS height x width
    ld hl, spinners.hw
    ld (hl), $12                ;spinner is 1x2
;Initialize CS starting position
    inc hl                      ;ld hl, spinners.y
    ld (hl), 86
    inc hl                      ;ld hl, spinners.x
    call random
    ld (hl), a
    inc hl                      ;ld hl, spinners.cc
    ld (hl), enemySpr1
;Initialize CS's hit detection subroutine
    ld hl, spinners.hitAdr        
    ld bc, SpinnerGotHit
    ld a, b                   ;High byte
    ld (hl), a
    inc hl
    ld a, c                   ;Low byte
    ld (hl), a
    xor a



;---------------------------------------
; Mongoose
;---------------------------------------
;Initialize Mongoose's starting position
    ld hl, goose.hw
    ld (hl), $23                  ;2x3
    inc hl                        ;ld hl, goose.y
    ld (hl), 45
    inc hl                        ;ld hl, goose.x
    ld (hl), 50
    inc hl                        ;ld hl, goose.cc
    ld (hl), $0c
    inc hl                        ; ld hl, goose.sprNum
    ld (hl), 6
    
    

;==============================================================
; Initialize other variables
;==============================================================
    ld hl, scrollX          ;Set horizontal scroll to zero
    ld (hl), a              ;

    ld hl, scrollY          ;Set vertical scroll to zero
    ld (hl), a              ;

    ld hl, frameCount       ;Set frame count to 0
    ld (hl), a              ;


;==============================================================
; Write background map
;==============================================================
;Loading in the testing background
    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, groundMap
    ld bc, groundMapEnd-groundMap
    call CopyToVDP

    ;Turn on screen (Maxim's explanation is too good not to use)
    ;This is for register 1
    ld a, %11100010
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Doubled sprites -> 2 tiles per sprite, 8x16
;           ||||`--- Mega Drive mode 5 enable
;           |||`---- 30 row/240 line mode
;           ||`----- 28 row/224 line mode
;           |`------ VBlank interrupts
;            `------- Enable display    
    ld c, $81
    call UpdateVDPRegister

    ;This could be used to make sure we only have the sprites that we need
    ;.redefine endSprite $c002
  
    ei
    
;==============================================================
; Game loop 
;==============================================================
    
GameLoop:       ;This is the loop
    halt

    call UpdateSAT

    call UpdateFrameCount

    ;Testing joypad 1 input, updating shots & updating Player Character
    call Joypad1Check

    ;Updating our CCW Spinner enemy
    ld de, spinners.sprNum
    call SpinnerAlive

    
    ;ld ix, carrier.x
    ;call CarrierHandler

    ;ld de, goose.sprNum
    ;call MultiUpdateSATBuff

    ;Update Scrolling
    ;call UpdateVDPRegister

    call CheckCollision

    jp GameLoop     ;Yarg


;========================================================
; Assets
;========================================================

    ;--------------------------------
    ; Background Palette
    ;--------------------------------

    .include "assets\\palettes\\backgrounds\\villageFight_bg_palette.inc"

    ;--------------------------------
    ; Background Tiles
    ;--------------------------------

    ;Testing Ground for animations/collision etc
    ;.include "assets\\tiles\\testingGround_tiles.inc"
TestingGroundTiles:
    .incbin "assets\\tiles\\backgrounds\\testingGround_tiles.pscompr"

    ;--------------------------------
    ; Sprite Palette
    ;--------------------------------

    .include "assets\\palettes\\sprites\\villageFight_spr_palette.inc"

    ;--------------------------------
    ; Sprite Tiles
    ;--------------------------------
    ;For now I'm using inc files, I can edit them directly
    ;KB Tile Data:
    .include "assets\\tiles\\sprites\\KBShip_tiles.inc" 
    .include "assets\\tiles\\sprites\\KBShot_tiles.inc"

;Chrome Spinner Enemy Tile Data:
CCWTiles1:
    .incbin "assets\\tiles\\sprites\\chromeSpinner\\chromeSpinner1.pscompr"
CCWTiles2:
    .incbin "assets\\tiles\\sprites\\chromeSpinner\\chromeSpinner2.pscompr"
CCWTiles3:
    .incbin "assets\\tiles\\sprites\\chromeSpinner\\chromeSpinner3.pscompr"

;Carrier Enemy Tile Data:
CarrierCarry:
    .incbin "assets\\tiles\\sprites\\carrier\\carry.pscompr"
CarrierFight:
    .incbin "assets\\tiles\\sprites\\carrier\\fight.pscompr"

;Big Eye Enemy Tile Data:
BigEyeClose:
    .incbin "assets\\tiles\\sprites\\bigEye\\bigEyeClose.pscompr"
BigEyeSquint:
    .incbin "assets\\tiles\\sprites\\bigEye\\bigEyeSquint.pscompr"
BigEyeOpen:
    .incbin "assets\\tiles\\sprites\\bigEye\\bigEyeOpen.pscompr"


BigEyeCarry:
    .incbin "assets\\tiles\\sprites\\bigEye\\bigEyeCarry.pscompr"
BigEyeRetina:
    .incbin "assets\\tiles\\sprites\\bigEye\\bigEyeRetina.pscompr"

;Mongoose Enemy Tile Data:
Mongoose:
    .incbin "assets\\tiles\\sprites\\mongoose\\mongoose.pscompr"



;========================================================
; Tile Maps
;========================================================
    .include "assets\\maps\\testingGround_map.inc"
TestingGroundMap:
    ;.include "assets\\maps\\testingGround_map.pscompr"