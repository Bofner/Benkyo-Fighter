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
.define VDPCommand $bf 
.define VDPData $be
.define VRAMWrite $4000
.define CRAMWrite $c000
.define NameTable $3800
.define TextBox $3ccc

;==============================================================
; SAT Buffer
;==============================================================
.equ kbVP $c000
.equ kbHP $c080
.equ kbCC $c081

.equ endSprite $c002       ;First empty sprite location

;==============================================================
; Variables 
;==============================================================
.enum $c000 export
    SATBuff dsb 256          ;Set aside 256 bytes for SAT buffer

    kbY db             ;Pilot's x coord
    kbX db             ;Pilot's Y coord
    kbAnim db          ;Pilot's animation frame
    kbPos db           ;What direction is pilot facing? (only uses two bits)

    
.ende

;==============================================================
; SDSC tag and ROM header
;==============================================================
.sdsctag 0.1, "Warning Forever", "Beginning stages of a shoot-em-up","Bofner"

.bank 0 slot 0
.org $0000
;==============================================================
; Boot Section
;==============================================================
    di              ;Disable interrupts
    im 1            ;Interrupt mode 1
    jp init      ;Jump to the initialization program

;==============================================================
; Interrupt Handler
;==============================================================
.orga $0038
    push af
        in a,(VDPCommand)
    pop af
    ei
    reti

;==============================================================
; Pause button handler
;==============================================================
.org $0066
    ;For now, do nothing
    retn


;==============================================================
; Start up/Initialization
;==============================================================
init: 
    ld sp, $dff0

    ;==============================================================
    ; Set up VDP Registers
    ;==============================================================
    ;ld hl, VDPInitData
    ;ld b, VDPInitDataEnd - VDPInitData
    ;ld c, VDPCommand
    ;otir

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
    ; Load Palette
    ;==============================================================
    ; First we set the VRAM write address to CRAM for Sprite
    ld hl, $c010 | CRAMWrite
    call SetVDPAddress
    ; Next we send the VDP the palette data
    ld hl, SpritePaletteData
    ld bc, SpritePaletteDataEnd-SpritePaletteData
    call CopyToVDP

    ;Next we do for Background
    ld hl, $0000 | CRAMWrite
    call SetVDPAddress
    ;Next we send the BG palette data
    ld hl, BGPaletteData
    ld bc, BGPaletteDataEnd-BGPaletteData
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

    ;Loading our testing background
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ; Then we send the VDP our tile data
    ld hl, groundTiles                ;Location of tile data
    ld bc, groundTilesEnd-groundTiles   ;Counter for the number of bytes we write
    call CopyToVDP

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


    ;==============================================================
    ; Initialize Sprite locations 
    ;==============================================================

    ;Initialize KB's starting position
    ld hl, kbY
    ld (hl), 100
    ld hl, kbX
    ld (hl), 150
    ld hl, kbAnim
    ld (hl), 0

    ;Initialize KB's direction
    ld hl, kbPos
    ld (hl), $01
    
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
    ld a, %01100010
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Doubled sprites -> 2 tiles per sprite, 8x16
;           ||||`--- Mega Drive mode 5 enable
;           |||`---- 30 row/240 line mode
;           ||`----- 28 row/224 line mode
;           |`------ VBlank interrupts
;            `------- Enable display    
    out (VDPCommand), a
    ld a, $81               ;Command byte for Register 1
    out (VDPCommand), a
    
    
    ei
    
;==============================================================
; Game loop 
;==============================================================
    
GameLoop:       ;This is the loop
    halt
    call UpdateSAT
    
    call UpdSATBuff

    ;Testing joypad 1 input
    call Joypad1Check

    jp GameLoop     ;Yarg

;========================================================
; Registers
;========================================================
; There are 11 registers, so 11 data
VDPInitData:
              .db %00000100             ; reg. 0

              .db %10100000             ; reg. 1

              .db $ff                   ; reg. 2, Name table at $3800

              .db $ff                   ; reg. 3

              .db $ff                   ; reg. 4

              .db $ff                   ; reg. 5, $ff = SAT at $3f00

              .db $ff                   ; reg. 6

              .db $f8                   ; reg. 7 Overrscan Color    

              .db $00                   ; reg. 8 

              .db $00                   ; reg. 9 

              .db $ff                   ; reg. 10

VDPInitDataEnd:

;========================================================
; Assets
;========================================================

    ;--------------------------------
    ; Background Palettes
    ;--------------------------------
BGPaletteData:
    .db $1A $2F $05 $15 $3E $20 $10 $00
BGPaletteDataEnd

    ;--------------------------------
    ; Sprite Palettes
    ;--------------------------------
SpritePaletteData:
    .db $24 $3F $00 $08 $3E $2A $15
SpritePaletteDataEnd:

Testing:
    .db $00 $15 $2A $3F $00 $15 $2A $3F $3F $2A $15 $00 $3F $2A $15 $00
TestingEnd

    ;--------------------------------
    ; Background Tiles
    ;--------------------------------

    ;Font Tile Data
    .include "assets\\tiles\\font.inc" 

    ;Testing Ground for animations/collision etc
    .include "assets\\tiles\\testingGround.inc"

    ;--------------------------------
    ; Sprite Tiles
    ;--------------------------------
    ;For now I'm using inc files. They're bigger, and I don't know if that
    ;   makes a difference or not, but I can edit them directly
    ;Pilot Tile Data:
    .include "assets\\tiles\\KBShip.inc" 

    ;--------------------------------
    ;Text Configuration
    ;--------------------------------
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

;========================================================
; Tile Maps
;========================================================
.include "assets\\maps\\testingGround.inc"

TestMessage:
    ;50Ch"0123456789ABCDEF789012345 123456789ABCDEF789012345"
    .asc "Intiate work on ISP"
    .db $ff     ;Terminator byte

;========================================================
; Include Files
;========================================================
.include "helperFunctions.asm"
.include "playerFunctions.asm"

