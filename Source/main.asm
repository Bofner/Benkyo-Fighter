;==============================================================
; WLA-DX banking setup
;==============================================================
.memorymap
defaultslot 0
slotsize $8000
slot 0 $0000
.endme

.rombankmap
bankstotal 1
banksize $8000
banks 1
.endro

;==============================================================
; SMS defines
;==============================================================
.define VDPCommand  $bf 
.define VDPData     $be
.define VRAMWrite   $4000
.define CRAMWrite   $c000
.define NameTable   $3800
.define TextBox     $3ccc

.define UpBounds    $02
.define DownBounds  $bd
.define LeftBounds  $05
.define RightBounds $fd

;==============================================================
; Game Constants
;==============================================================
.equ plyShot1Loc    $2080       ;Sprite VRAM location for first shot
.equ plyShot2Loc    $20c0       ;Sprite VRAM location for second shot
.equ kbShotSpr1     $04         ;CC VRAM location for first shot
.equ kbShotSpr2     $06         ;CC VRAM location for second shot

.equ enemy1Loc      $2100
.equ enemySpr1      $08         ;CC VRAM location for first enemy sprite


.equ enemySpr2      $0a         ;CC VRAM location for second enemy sprite

;==============================================================
; Variables 
;==============================================================
.enum $c000 export
    SATBuff         dsb 256     ;Set aside 256 bytes for SAT buffer $100
    SOAL            dsb 128     ;Set aside 128 bytes for Sprite Object Address List $ 80

    VDPStatus       db

    spriteCount     dw          ;How many sprites are on screen at once? It's a word to assist the SATBuffer
    sprUpdCnt       db          ;Keeps track of how many sprites we have updated per frame

    sprChkCntr      db          ;Sprite (Collision) Check Counter, used to keep track of what sprites we've gone through

    kbShotBuffer    db          ;Number of active projectiles from player

    scrollX         db          ;Scroll value for BG in x direction
    scrollY         db          ;Scroll value for BG in y direction

    colXOffset      db          ;Stored X value for Nametable offset in BG-Sprite collision
    colYOffset      db          ;Stored Y value for Nametable offset in BG-Sprite collision 

    frameCount      db          ;Used to count frames in intervals of 60

    sceneComplete   db          ;Used to determine if a scene is finished or not

    randSeed        db          ;Our seed for random numbers

    sprYOff         db          ;Offset for the Y position of sprites when drawing them to the screen (Updates by $10)
    sprXOff         db          ;Offset for the X position of sprites when drawing them to the screen (Updates by $08)
    sprCCOff        db          ;Offset for the CC of sprites when drawing them to the screen         (Updates by $02)

    ;Seems that $c000 to $dfff is the space I have to work with for variables and such
    ;Current usage: $c190
    
.ende



;=============================================================================
; Special numbers 
;=============================================================================
.define postBoiler  $c190   ;Location in memory that is past the boiler plate stuff

;Initialize our random seed
    ld hl, randSeed
    ld (hl), $69

;==============================================================
; SDSC tag and ROM header
;==============================================================
.sdsctag 0.1, "Benkyo Fighter: The Prologue", "Beginning stages of a shoot-em-up","Bofner"

.bank 0 slot 0
.org $0000
;==============================================================
; Boot Section
;==============================================================
    di              ;Disable interrupts
    im 1            ;Interrupt mode 1
    jp init         ;Jump to the initialization program

;==============================================================
; Interrupt Handler
;==============================================================
.orga $0038
    push af
        in a,(VDPCommand)
        ld (VDPStatus), a
    pop af
    ei
    reti

;==============================================================
; Pause button handler
;==============================================================
.org $0066
    ;For now, change the palette
        ; First we set the VRAM write address to CRAM for Sprite
    ld hl, $c010 | CRAMWrite
    call SetVDPAddress
    ; Next we send the VDP the palette data
    ld hl, TestPalette
    ld bc, TestPaletteEnd-TestPalette
    call CopyToVDP
    retn


;==============================================================
; Start up/Initialization
;==============================================================
init: 
    ld sp, $dff0

;==============================================================
; Set up VDP Registers
;==============================================================

    ld hl,VDPInitData                       ; point to register init data.
    ld b,VDPInitDataEnd - VDPInitData       ; 11 bytes of register data.
    ld c, $80                               ; VDP register command byte.
    call SetVDPRegisters
    

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
; Setup general sprite variables
;==============================================================
;Let a hold zero
    xor a

;Initialize the number of sprites on the screen
    ld hl, spriteCount      ;Set sprite count to 0
    ld (hl), a              ;
    inc hl                  ;Saving a memory address ($c000, beginning of SAT buffer)
    ld (hl), $C0

;Initialize the number of sprites that have been updated
    ld hl, sprUpdCnt        ;Set num of updated sprites to 0
    ld (hl), a              ;

;Initialize the offsets for our sprites to be zero
    ld hl, sprYOff
    ld (hl), a
    inc hl                  ;ld hl, sprXOff
    ld (hl), a
    inc hl                  ;ld hl, sprCCOff
    ld (hl), a

;==============================================================
; Game sequence
;==============================================================

    call prologueTitle

    jp VillageFight

;========================================================
; Include Object Files
;========================================================
.include "structs.asm"
.include "playerFunctions.asm"
.include "playerShot.asm"
.include "chromeSpinner.asm"
.include "carrier.asm"
.include "bigEye.asm"
.include "mongoose.asm"

;========================================================
; Include Helper Files
;========================================================
.include "psDecompression.asm"
.include "helperFunctions.asm"

;========================================================
; Include Level Files
;========================================================
.include "titleScreen.asm"
.include "villageFight.asm"


;========================================================
; Registers
;========================================================
; There are 11 registers, so 11 data
VDPInitData:
              .db %00000100             ; reg. 0

              .db %10100000             ; reg. 1

              .db $ff                   ; reg. 2, Name table at $3800

              .db $ff                   ; reg. 3 Always set to $ff

              .db $ff                   ; reg. 4 Always set to $ff

              .db $ff                   ; reg. 5 Address for SAT, $ff = SAT at $3f00 

              .db $ff                   ; reg. 6 Base address for sprite patterns

              .db $f2                   ; reg. 7 Overrscan Color    

              .db $00                   ; reg. 8 Horizontal Scroll

              .db $00                   ; reg. 9 Vertical Scroll

              .db $ff                   ; reg. 10 Raster line interrupt

VDPInitDataEnd:

;========================================================
; Text Configuration
;========================================================
    .asciitable
        map " " = $d5
        map "0" to "9" = $d6
        map "!" = $e0
        map "," = $e1
        map "." = $e2
        map "'" = $e3
        map "?" = $e4
        map "A" to "Z" = $e5
    .enda

TestMessage:
    ;50Ch"0123456789ABCDEF789012345 123456789ABCDEF789012345"
    .asc "Intiate work on ISP"
    .db $ff     ;Terminator byte

TestPalette:
    .db $00 $15 $2A $3F $00 $15 $2A $3F $3F $2A $15 $00 $3F $2A $15 $00
TestPaletteEnd:

;========================================================
; Extra Data
;========================================================
    .include "spriteDefines.asm"

    ;Font Tile Data
    .include "assets\\tiles\\backgrounds\\font_tiles.inc" 


