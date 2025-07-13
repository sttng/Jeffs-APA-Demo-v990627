
SetX:
        ld      b,$60
        ld      h,$00 ;$1030
        ld      d,$38

        ld      b,$10/2
        ld      d,$20/2 ;$1030
        ld      h,$18/2
        ret

SetY:
        ld      c,$20/2
        ld      e,$20/2 ;$1030
        ld      l,$30/2
        ret

DEF offs   equ 12
DEF offs2  equ 10

RandomTris:
        call    InstallEdgeLineCode
;        jp      tritest5
;        jp      tritest4
;        jp      tristuff


        jr      .loop1
.loop0:
        ld      bc,3200
.loop:
        push    bc

        call    RandomFrom0To63
        ld      b,a
        call    RandomFrom0To63
        ld      c,a

        call    RandomFrom0To63
        ld      d,a
        call    RandomFrom0To63
        ld      e,a

        call    RandomFrom0To63
        ld      h,a
        call    RandomFrom0To63
        ld      l,a

        call    RandomColorTri

        call    Randomize

        ld      a,1
        ld      [StartDMA],a

        pop     bc
        dec     bc
        ld      a,b
        or      c
        jr      nz,.loop

.loop1:

        ld      bc,1600
.loop2:
        push    bc

        call    RandomFrom0To159
        ld      b,a
        call    RandomFrom0To143
        ld      c,a

        call    RandomFrom0To159
        ld      d,a
        call    RandomFrom0To143
        ld      e,a

        call    RandomFrom0To159
        ld      h,a
        call    RandomFrom0To143
        ld      l,a

        call    RandomColorTri

        call    Randomize

        ld      a,1
        ld      [StartDMA],a

        pop     bc
        dec     bc
        ld      a,b
        or      c
        jr      nz,.loop2

        jr      .loop0


RandomTextureTris:

        call    InstallEdgeLineCode

        jr      .loop1
.loop0:
        ld      bc,800*4
.loop:
        push    bc

        call    RandomFrom0To63
        ld      b,a
        call    RandomFrom0To63
        ld      c,a

        call    RandomFrom0To63
        ld      d,a
        call    RandomFrom0To63
        ld      e,a

        call    RandomFrom0To63
        ld      h,a
        call    RandomFrom0To63
        ld      l,a

        call    RandomNumber
        and     $7
        add     Textures/256
        call    SetTextureAddress

        call    TextureTri

;        ld      hl,Patterns
;        call    SetPatternAddress

;        call    PatternTri

        call    Randomize

        ld      a,1
        ld      [StartDMA],a

        pop     bc
        dec     bc
        ld      a,b
        or      c
        jr      nz,.loop

.loop1:
;        ld      hl,Patterns
;        call    SetPatternAddress

        ld      bc,800*3
.loop2:
        push    bc

        call    RandomFrom0To159
        ld      b,a
        call    RandomFrom0To143
        ld      c,a

        call    RandomFrom0To159
        ld      d,a
        call    RandomFrom0To143
        ld      e,a

        call    RandomFrom0To159
        ld      h,a
        call    RandomFrom0To143
        ld      l,a

        call    RandomNumber
        and     $7
        add     Textures/256
        call    SetTextureAddress

        call    TextureTri

;        call    PatternTri

        call    Randomize

        ld      a,1
        ld      [StartDMA],a

        pop     bc
        dec     bc
        ld      a,b
        or      c
        jr      nz,.loop2

        jr      .loop0

LargeTriTest:
        call    InstallEdgeLineCode

        ld      hl,Patterns
        call    SetPatternAddress

        jr      .loop1
.loop0:
        ld      bc,800
.loop:
        push    bc

        ld      b,0
        ld      c,0

        ld      d,120/4
        ld      e,40

        ld      h,40/4
        ld      l,100/4

        call    BlackTri

        ld      b,0
        ld      c,0

        ld      d,120/4
        ld      e,40

        ld      h,40/4
        ld      l,100/4

        call    WhiteTri

;        call    RandomColorTriBW

;        call    PatternTri

;        call    Randomize

        ld      a,1
        ld      [StartDMA],a

        pop     bc
        dec     bc
        ld      a,b
        or      c
        jr      nz,.loop

.loop1:

        ld      bc,600
.loop2:
        push    bc

        ld      hl,Patterns
        call    SetPatternAddress

        ld      b,0
        ld      c,0    ;+43

        ld      d,120
        ld      e,40   ;+43

        ld      h,40
        ld      l,100  ;+43

;        ld      a,$60
;        ld      [TexOffset],a

;        call    TextureTri
        call    PatternTri

        ld      hl,Patterns ;+$4000
        call    SetPatternAddress

        ld      b,0
        ld      c,0    ;+43

        ld      d,120
        ld      e,40   ;+43

        ld      h,40
        ld      l,100  ;+43

;        ld      a,$61
;        ld      [TexOffset],a

;        call    TextureTri
;        call    BlackTri
        call    PatternTri
;        call    XorTri

;        call    Randomize
        ld      a,1
        ld      [StartDMA],a

        pop     bc
        dec     bc
        ld      a,b
        or      c
        jr      nz,.loop2

        jr      .loop0

tristuff:
        call    tritest2
        ld      a,1
        ld      [StartDMA],a

        call    tritest2


        call    tritest2
        call    tritest2

        ld      a,1
        ld    [StartDMA],a

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2
        ld      a,1
        ld    [StartDMA],a

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2
        ld      a,1
        ld    [StartDMA],a

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2
        ld      a,1
        ld    [StartDMA],a

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2
        ld      a,1
        ld    [StartDMA],a

        call    tritest2
        call    tritest2

        call    tritest2
        call    tritest2
        ld      a,1
        ld    [StartDMA],a

tri440: jr      tri440
        ret



tritest2:
        call    SetY
        ld      a,12

.outer:
        push    af
        ld      a,12

        call    SetX

.loop:
        push    af
        push    bc
        push    de
        push    hl
        call    XorTri
        pop     hl
        pop     de
        pop     bc

        ld      a,b
        add     offs
        ld      b,a

        ld      a,d
        add     offs
        ld      d,a

        ld      a,h
        add     offs
        ld      h,a

        pop     af

        dec     a
        jr      nz,.loop

        ld      a,c
        add     offs2
        ld      c,a

        ld      a,e
        add     offs2
        ld      e,a

        ld      a,l
        add     offs2
        ld      l,a

        pop     af
        dec     a
        jr      nz,.outer

        ret

tritest3:
        ld      bc,$0

        ld      d,2
        ld      e,143

        ld      h,159
        ld      l,72

        call    XorTri

.lpt:   jr      .lpt

tritest5:
        ld      b,80-20
        ld      c,72
        call    DrawX

        ld      b,80-15
        ld      c,72-15
        call    DrawX

        ld      b,80
        ld      c,72-20
        call    DrawX

        ld      b,80+15
        ld      c,72-15
        call    DrawX

        ld      b,80+20
        ld      c,72
        call    DrawX

        ld      b,80+15
        ld      c,72+15
        call    DrawX

        ld      b,80
        ld      c,72+20
        call    DrawX

        ld      b,80-15
        ld      c,72+15
        call    DrawX


        jr      tritest5

DrawX:
        ld      a,b
        ld      [Middle+1],a
        ld      a,c
        ld      [Middle],a

 if RENDER_TO_VRAM
 else
 endc

; Draw west tri
        ld      bc,$0
        ld      d,0
        ld      e,143

        ld      a,[Middle]
        ld      l,a
        ld      a,[Middle+1]
        ld      h,a

        call    WhiteTri

; North tri
        ld      bc,$0
        ld      d,159
        ld      e,0

        ld      a,[Middle]
        ld      l,a
        ld      a,[Middle+1]
        ld      h,a

        call    LightTri

; East tri
        ld      b,159
        ld      c,0

        ld      d,159
        ld      e,143

        ld      a,[Middle]
        ld      l,a
        ld      a,[Middle+1]
        ld      h,a

        call    BlackTri

; North tri
        ld      b,0
        ld      c,143

        ld      d,159
        ld      e,143

        ld      a,[Middle]
        ld      l,a
        ld      a,[Middle+1]
        ld      h,a

        call    DarkTri

        ld      a,1
        ld      [StartDMA],a

        call    MassiveDelay
.hpp:   jr      .hpp

        ret

MassiveDelay:
        ret
.loop2:
        ld      hl,65000
.loop1:
        dec     hl
        ld      a,h
        or      l
        jr      nz,.loop1


        ret

RandomColorBuffer:
;        jp      DisplayXorEdgeBuf

        call    RandomNumber
        and     $3
        jp      z,DisplayBlackEdgeBuf
        dec     a
        jp      z,DisplayLightEdgeBuf
        dec     a
        jp      z,DisplayDarkEdgeBuf
        jp      DisplayWhiteEdgeBuf

RandomColorTriBW:
        call    RandomNumber
        and     $1
        jr      RCT2

RandomColorTri:
;        jp      XorTri

        call    RandomNumber
        and     $3
RCT2:
        jp      z,BlackTri
        dec     a
        jp      z,WhiteTri
        dec     a
        jp      z,DarkTri
        jp      LightTri