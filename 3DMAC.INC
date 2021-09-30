; 3D Macros

DIVOFF: MACRO
        srl     a
        ld      hl,acc
        rr      [hl]
        srl     a
        rr      [hl]
        srl     a
        rr      [hl]
        srl     a
        rr      [hl]
        srl     a
        rr      [hl]
        srl     a
        rr      [hl]
        ENDM

; Add 2 angles
ADDA:   MACRO
        ld      a,[\1]
        ld      b,a
        ld      a,[\2]
        add     a,b
        cp      ANGMAX
        jr      c,.skip\@
        sub ANGMAX
.skip\@
        ENDM

; Subtract 2 angles
SUBA:   MACRO
        ld      a,[\2]
        ld      b,a
        ld      a,[\1]
        sub     b
        cp      ANGMAX
        jr      c,.skip\@
        sub ANGMAX
.skip\@
        ENDM

; Multiply an 8 bit signed number by 2
MUL2:   MACRO
        bit     7,a
        jr      z,.skip1\@
        cpl
        inc     a
        add     a,a
        cpl
        inc     a
        jr      .skip2\@
.skip1\@:
        add     a,a
.skip2\@:
        ENDM

NEG:    MACRO
        ld      a,[\1]
        cpl
        inc     a
        ld      [\2],a
        ENDM
