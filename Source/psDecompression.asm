

;========================================================
; Sample PSRLE Decompression algorithm from SMSPower.com
;========================================================

  ; Decompresses tile data from hl to VRAM address de
Decompress:
  ld b,$04
-:push bc
    push de
      call _f        ; called 4 times for 4 bitplanes
    pop de
    inc de           ; next bitplane
  pop bc
  djnz -
  ret

__:
  ld a,(hl)          ; read count byte <----+
  inc hl             ; increment pointer    |
  or a               ; return if zero       |
  ret z              ;                      |
                     ;                      |
  ld c,a             ; get low 7 bits in b  |
  and $7f            ;                      |
  ld b,a             ;                      |
  ld a,c             ; set z flag if high   |
  and $80            ; bit = 0              |
                     ;                      |
-:call SetVRAMAddressToDE ;            <--+ |
  ld a,(hl)          ; Get data byte in a | |
  out ($be),a        ; Write it to VRAM   | |
  jp z,+             ; If z flag then  -+ | |
                     ; skip inc hl      | | |
  inc hl             ;                  | | |
                     ;                  | | |
+:inc de             ; Add 4 to de <----+ | |
  inc de             ;                    | |
  inc de             ;                    | |
  inc de             ;                    | |
  djnz -             ; repeat block  -----+ |
                     ; b times              |
  jp nz,_b           ; If not z flag -------+
  inc hl             ; inc hl here instead  |
  jp _b              ; repeat forever ------+
                     ; (zero count byte quits)

SetVRAMAddressToDE:
    push af                     ;For safe keeping
        ld a, e                 ;Little endian
        out (VDPCommand), a     
        ld a, d
        out (VDPCommand), a
    pop af
    ret
   
