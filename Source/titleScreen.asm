prologueTitle:
;==============================================================
; Scene beginning
;==============================================================
    ld hl, sceneComplete
    ld (hl), $00

;==============================================================
; Defines
;==============================================================
.define startY 136
.define startX 94
.define optionsY 152
.define optionsX 94

;==============================================================
; Memory (Structures and Variables) 
;==============================================================

.enum postBoiler export
    cursor instanceof player_cursor
.ende

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
; Load Palettes
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
    ld hl, prologueTitle_bgPal
    ld bc, prologueTitle_bgPalEnd-prologueTitle_bgPal
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
    ld hl, prologueTitle_tiles                ;Location of tile data
    ld bc, prologueTitle_tilesEnd-prologueTitle_tiles   ;Counter for the number of bytes we write
    call CopyToVDP
    */
    ld hl, PrologueTitleTiles
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
    ld hl, Cursor                 ;Location of tile data
    ld bc, CursorEnd-Cursor  ;Counter for the number of bytes we write
    call CopyToVDP

;==============================================================
; Initialize Sprite variables 
;==============================================================

    ;Initialize arrow's starting position
    ld hl, cursor.y
    ld (hl), startY
    ld hl, cursor.x
    ld (hl), startX
    ld hl, cursor.cc
    ld (hl), $00        ;First spot in Sprite VRAM

    ;Initialize the number of sprites on the screen
    ld hl, spriteCount      ;Set sprite count to 0
    ld (hl), a              ;
    inc hl
    ld (hl), $C0

    ;Let the SATBuffer know we have added 1 sprites (for the arrow)
    ld b, 1
    call UpdateSprCnt

;==============================================================
; Initialize other variables
;==============================================================
    ld hl, scrollX          ;Set horizontal scroll to zero
    xor a                   ;
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
    ld hl, prologueTitle_map
    ld bc, prologueTitle_mapEnd-prologueTitle_map
    call CopyToVDP

    ;ld hl, PrologueTitleMap
    ;ld de, $3800 | VRAMWrite
    ;call Decompress

    ;Turn on screen (Maxim's explanation is too good not to use)
    ld a, %01100000
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Not doubled sprites -> 1 tile per sprite, 8x8
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
TitleLoop:       ;This is the loop
    halt
    
    call UpdateSAT

    call Joypad1MenuCheck

    call UpdateFrameCount

    ld a, (cursor.x)
    ld b, a
    ld a, (cursor.cc)
    ld c, a
    ld a, (cursor.y)   
    call SingleUpdateSATBuff

    ld a, (sceneComplete)
    ld c, 0
    cp c
    jp z, +
    call BlankScreen
    ret

+:
    jp TitleLoop     ;Yarg


;========================================================
; Joypad Check
;========================================================
;I won't bother making a new file for this, since it doesn't
;   need to do all the much to navigate a menu

Joypad1MenuCheck:
    ;Check for directional inputs
    ;All of the $Fx numbers correspond to the 8-bit flags set by the joypad
    ;Each direction corresponds to a single bit flip, where all bits are
    ;1 by default, and flip to 0 when activated
    in a, $dc                    ;Send Joypad port 1 input data to register A

    ld hl, cursor.input
    ld (hl), a

    ld b, a                      ;save A in B
    ;UP
    ld c, $FE
    xor c                         ;Check to see if JUST bit 0 is set
    jp z, TitleUp                 ;If it's 0, then it's set, and cursor MAY move up

    ;DOWN
    ld a, b                      ;restore A with B
    ld c, $FD                    
    xor c                         ;Check to see if JUST bit 1 is set
    jp z, TitleDown               ;If it's 0, then it's set, and cursor MAY move down

    ;Check for just shot button
    ld a,  b                ;For safe keeping
    ld c, $EF               ;Check SW1
    xor c
    jr z, Enter             ;If SW1 IS pressed, then...

    ret

TitleUp:
;Move cursor to START position
    ld c, optionsY
    ld a, (cursor.y)
    cp c
    jp z, +
    ret
+:
    ld hl, cursor.y
    ld a, (hl)
    sub 16
    ld (hl), a
    ret
    

TitleDown:
;Move cursor to OPTIONS position
    ld c, startY
    ld a, (cursor.y)
    cp c
    jp z, +
    ret
+:
    ld hl, cursor.y
    ld a, (hl)
    add a, 16
    ld (hl), a
    ret

Enter:
    ;If cursor is on START position...
    ld c, startY
    ld a, (cursor.y)
    cp c
    jp z, +
    ret
+:
;Start game
    ld hl, sceneComplete
    ld a, $01
    ld (hl), a
    ret

;========================================================
; Assets
;========================================================

    ;--------------------------------
    ; Background Palette
    ;--------------------------------

    .include "assets\\palettes\\backgrounds\\prologueTitle_bg_palette.inc"

    ;--------------------------------
    ; Background Tiles
    ;--------------------------------

    ;Testing Ground for animations/collision etc
    ;.include "assets\\tiles\\prologueTitle_tiles.inc"
PrologueTitleTiles:
    .incbin "assets\\tiles\\backgrounds\\prologueTitle_tiles.pscompr"

    ;--------------------------------
    ; Sprite Palette
    ;--------------------------------
    
    ;Same as in Village Fight, so it's already included
    ;.include "assets\\palettes\\sprites\\villageFight_spr_palette.inc"

    ;--------------------------------
    ; Sprite Tiles
    ;--------------------------------
    ;For now I'm using inc files, I can edit them directly
    .include "assets\\tiles\\sprites\\cursor_tiles.inc" 


;========================================================
; Tile Maps
;========================================================
    .include "assets\\maps\\prologueTitle_map.inc"
PrologueTitleMap:
    ;.incbin "assets\\maps\\prologueTitle_map.pscompr"