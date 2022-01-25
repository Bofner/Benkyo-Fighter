;===================================================
;General VDP Functions
;===================================================
SetVDPAddress:
    ;Tells VDP where it should be writing/reading data from in VRAM
    ;Parameters: HL = address
    ;Affects: No registers
    push af                     ;For safe keeping
        ld a, l                 ;Little endian
        out (VDPCommand), a     
        ld a, h
        out (VDPCommand), a
    pop af
    ret

CopyToVDP:
    ;Copies data to the VRAM
    ;Parameters: HL = data address, BC = data length
    ;Affects: A, HL, BC
-:  ld a, (hl)                  ;Get data byte from location @ HL
    out (VDPData), a
    inc hl                      ;Point to next data byte
    dec bc                      ;Decrease our counter
    ld a, b
    or c
    jr nz, -
    ret

SetVDPRegisters:
    ;Sets one or more VDP Registers (Each one contains a byte)
    ;Parameters: HL = data address, B = # of registers to 
    ;            C = Which VDP regiseter $8(register#)
    ;Affects: A, B, C, HL
-:  ld a,(hl)                            ; load one byte of data into A.
    out (VDPCommand),a                   ; output data to VDP command port.
    ld a,c                               ; load the command byte.
    out (VDPCommand),a                   ; output it to the VDP command port.
    inc hl                               ; inc. pointer to next byte of data.
    inc c                                ; inc. command byte to next register.
    djnz -                               ; jump back to '-' if b > 0.   
    ret

;===================================================
;Sprite Functions
;===================================================
UpdSATBuff:
    ;Updates the buffer for the SAT
    ;Parameters: None
    ;Affects: HL, A, BC
    ;==============================================
    ;KB's data
    ;==============================================
    ;Y coords (Should be 2 for KB)
    ld hl, kbVP                   ;HL points to the vertical poisiton for KB
    ld a, (kbY)                   ;Loads KB's Y coords into A
    ld (hl), a                    ;LEFT HULL
    inc hl
    ld (hl), a                    ;RIGHT HULL
 
    ;Used for incrementing the CC and HP
    ld bc, 2                         

    ;X coords
    ld hl, kbHP                   ;Points to horizontal position
    ld a, (kbX)                   ;Load's KB's X coord into A
    ld (hl), a                     ;LEFT HULL
    add hl, bc                     ;Need to in 2, HP and CC are next to each other   
    add a, 8                       ;Draw RIGHT 8 pixels
    ld (hl), a                     ;RIGHT HULL
  
    ;Character code
    ld hl, kbCC                   ;Character code for KB's Ship
    ld (hl), $00                  ;LEFT HULL
    add hl, bc
    ld (hl), $02                  ;RIGHT HULL

    ;==============================================
    ;End Sprites
    ;==============================================
    ;Don't use any more sprites
    ld hl, endSprite
    ld (hl), $d0

UpdateSAT:
    ;Updates the Sprite Attribute table with the SAT Buffer
    ;Parameters: None
    ;Affects: B, C, HL
    ld hl, $3f00 | VRAMWrite            ;Telling the VDP where to write this data
    call SetVDPAddress                  ;

    ld b, 255                           ;SAT is 256 bytes
    ld c, VDPData                       ;We want to write data
    ld hl, SATBuff                      ;We are writing the contents of the SAT buffer
    otir                                ;Write contents of HL to C with B bytes
    ret

;===================================================
;Background Functions
;===================================================
TextToScreen:
    ;Writes text to the screen in the dialogue box area (bottom)
    ;Parameters: DE = Message
    ;Affects: A, BC, HL, DE
    ;First, let's set the RAM address to the correct tile map
    ld b, 0                                 ;Reset counter
    ld c, $00                               ;Set offset
    ld hl, TextBox | VRAMWrite
    call SetVDPAddress
    ;Then we can put stuff to the screen
    ex de, hl               ;load data in HL (from DE)
-:  ld a,25             
    cp b                    ;Check if we are at the end of the line
    jr nz, Write            ;
  
    ;We are writing on a new line, adding BC ($0040)
    push hl
        ld b, 0             ;Reset Counter
        ld a, c
        add a, $40
        ld c, a
        ld hl, TextBox | VRAMWrite
        add hl, bc
        add hl, bc          ;We are double spacing the text
        call SetVDPAddress   
    pop hl
    

Write:
    ld a, (hl)              ;Read until we hit $ff
    cp $ff                  ;
    jr z,+                  ;
    out (VDPData), a        ;
    xor a                   ;
    out (VDPData), a        ;
    inc hl                  ;
    inc b                   ;Increase counter
    jr -                                    ;
+:  ret

TestFunction:
    ;This sets the sprite color palette to be grayscale
    push hl
        push bc
            ld hl, $c010 | CRAMWrite
            call SetVDPAddress
            ; Next we send the VDP the palette data
            ld hl, Testing
            ld bc, TestingEnd-Testing
            call CopyToVDP
        pop bc
    pop hl
    ret
