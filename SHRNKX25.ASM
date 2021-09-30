;

;  Reduce X by 25%
; Entry: HL = Source screen data
;        DE = Destination screen data

ShrinkX25:
        ld      bc,4
.loop2:
.loop1:
        push    bc

        ld      a,[hl]
        inc     h
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rl      b

        ld      a,[hl]
        inc     h
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rl      c
        rlca
        rlca
        rl      c
        rlca
        rl      c
        rlca
        rl      c

        ld      a,b
        ld      [de],a
        inc     d

        ld      a,[hl]
        inc     h
        rlca
        rl      c
        rlca
        rl      c
        rlca
        rl      c
        rlca
        rlca
        rl      c
        rlca
        rl      b
        rlca
        rl      b

        ld      a,c
        ld      [de],a
        inc     d

        ld      a,[hl]
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rlca
        rl      b
        rlca
        rl      b
        rlca
        rl      b

        ld      a,b
        ld      [de],a

        dec     h
        dec     h
        dec     h
        inc     l

        dec     d
        dec     d
        inc     e

        pop     bc
        dec     b
        jr      nz,.loop1

        inc     h
        inc     h
        inc     h
        inc     h

        inc     d
        inc     d
        inc     d

        dec     c
        jr      nz,.loop2

        ret