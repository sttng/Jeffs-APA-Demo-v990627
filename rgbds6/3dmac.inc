; 3D Macros

MACRO DIVOFF
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
MACRO ADDA
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
MACRO SUBA
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
MACRO MUL2
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

MACRO NEG
        ld      a,[\1]
        cpl
        inc     a
        ld      [\2],a
        ENDM