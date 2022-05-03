;==============================================================
; Chiral Chrome Weaver structure
;==============================================================
;For reference to the spinner structure, look in structs.asm

;Parameters: DE = spinner.sprNum
SpinnerAlive:
;Check if spinner is alive or not
    ld h, d
    ld l, e
    dec hl                  ;ld hl, spinner.hitAdrLOW
    dec hl                  ;ld hl, spinner.hitAdrHIGH
    dec hl                  ;ld hl, spinner.alive
    xor a
    ld c, a
    ld a, (hl)
    cp c
;If spinner is not alive, then return, else, let's update this bad boy
    call nz, SpinnerMove
    ret

;For now this is just lateral movement, but eventually I'll build a real AI, I think
SpinnerMove:
;Update Spinner's x position
    ld h, d
    ld l, e
    inc hl                  ;ld hl, spinner.hw
    inc hl                  ;ld hl, spinner.y
    inc hl                  ;ld hl, spinner.x
    inc (hl)


SpinnerSATUpd:
;Let the SATBuffer know we have added 2 sprites (one for each half of the Spinner)
    call MultiUpdateSATBuff

    ret

SpinnerGotHit:

;Set ALIVE byte to be false
    ld h, d
    ld l, e
    ld (hl), 0

;Update the Sprite Collision Check Counter
    ld hl, sprChkCntr
    ld a, (hl)
    inc a
    ld (hl), a
;This feels dangerous, gotta keep our sprite djnz counter consistent
    pop bc
    dec b
    jp CollisionLoop                ;ret


    