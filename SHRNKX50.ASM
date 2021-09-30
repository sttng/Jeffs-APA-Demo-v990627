;

;  Reduce X by 25%
; Entry: HL = Source screen data
;        DE = Destination screen data

ShrinkX50:
        ld      c,8
.loop2:
        ld      b,128
.loop1:
        push    bc

        ld      a,[hl+]
        rlca
        rl      b
        rlca

        rlca
        rl      b
        rlca

        rlca
        rl      b
        rlca

        rlca
        rl      b

        ld      a,[hl-]
        rlca
        rl      c
        rlca

        rlca
        rl      c
        rlca

        rlca
        rl      c
        rlca

        rlca
        rl      c

        inc     h

        ld      a,[hl+]
        rlca
        rl      b
        rlca

        rlca
        rl      b
        rlca

        rlca
        rl      b
        rlca

        rlca
        rl      b

        ld      a,[hl-]
        rlca
        rl      c
        rlca

        rlca
        rl      c
        rlca

        rlca
        rl      c
        rlca

        rlca
        rl      c

        inc     l
        inc     l
        dec     h

        ld      a,b
        ld      [de],a
        inc     e

        ld      a,c
        ld      [de],a
        inc     e

        pop     bc
        dec     b
        jr      nz,.loop1

        inc     d

        inc     h
        inc     h

        dec     c
        jr      nz,.loop2

        ret