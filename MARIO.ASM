
        PUSHS

        SECTION "Low Ram",BSS

TriTable        dw
TriColor        db
TriScale        db
TriXOffset      db
TriYOffset      db

        POPS


XOFFS   equ     33-14
YOFFS   equ     3*46-17

DL_LINE equ     $fd
DL_SETC equ     $fe
DL_END  equ     $ff


DrawMario:
        call    ScreenOff

; Setup GBC Attribute memory with map

        ld      hl,MarioAttrMap
        call    SetCGBAttrMap1
        ld      hl,MarioAttrMap
        call    SetCGBAttrMap2

        ld      hl,MarioGBCPalettes
        call    SetCGB_BGP

        ld      a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON
        ld      [rLCDC],a        ; Turn screen on

        call    InstallEdgeLineCode
;        call    InstallFastLineCode

        ld      a,XOFFS
        ld      [TriXOffset],a
        ld      a,YOFFS
        ld      [TriYOffset],a
.loop1:

; Zoom in on face

        xor     a
.loop2:
        push    af
        ld      [TriScale],a
        call    DrawFace
        call    DrawEyes
        ld      a,1
        ld      [StartDMA],a    ; Render scene

        call    WaitAndClearRenderBuffer
        pop     af

        inc     a
        cp      12
        jr      nz,.loop2

; Draw but don't clear buffer

        push    af
        ld      [TriScale],a
        call    DrawFace
        call    DrawEyes

;        ld      hl,$c000
;        ld      de,$c000
;        call    ShrinkXY25
;        ld      hl,$c000
;        ld      de,$c000
;        call    ShrinkX50


;        ld      a,1
;        ld      [StartDMA],a    ; Render scene

        call    Blink1
        call    Blink2
;        ld      a,1
;        ld      [StartDMA],a

        call    WaitAndClearRenderBuffer
        pop     af

; Zoom out on face

        dec     a


.loop3:
        push    af
        ld      [TriScale],a
        call    DrawFace
        call    DrawEyes
        ld      a,1
        ld      [StartDMA],a    ; Render scene
        call    WaitAndClearRenderBuffer
        pop     af

        dec     a
        jr      nz,.loop3


        jp      .loop1

Blink1:
        ld      a,60
.loop1:
        call    DrawEyelash

        inc     a
        inc     a
        inc     a
        inc     a
        cp      75
        jr      c,.loop1

        push    af
        ld      hl,BlueeyesGBCPalettes
        call    SetCGB_BGP
        pop     af

.loop2:
        call    DrawEyelash

        dec     a
        dec     a
        dec     a
        dec     a
        cp      60
        jr      nc,.loop2

        ret
Blink2:
        ld      a,60
.loop1:
        call    DrawEyelash

        inc     a
        inc     a
        inc     a
        inc     a
        cp      75
        jr      c,.loop1

        push    af
        ld      hl,MarioGBCPalettes
        call    SetCGB_BGP
        pop     af

.loop2:
        call    DrawEyelash

        dec     a
        dec     a
        dec     a
        dec     a
        cp      60
        jr      nc,.loop2

        ret

XLOFF   equ     17

DrawEyelash:
        push    af

        call    DrawEyes
        pop     af
        push    af

        ld      b,65-14
        ld      c,55-12

        ld      d,62-5-14
        ld      e,a

        ld      h,76+5-14
        ld      l,a
        dec     l
        dec     l
        dec     l
        dec     l
        dec     l

        call    LightTri

        pop     af
        push    af

        ld      b,94-XLOFF
        ld      c,55-12

        ld      d,88-5-XLOFF
        ld      e,a
        dec     e
        dec     e
        dec     e
        dec     e
        dec     e

        ld      h,101+5-XLOFF
        ld      l,a

        call    LightTri

        ld      a,1
        ld      [StartDMA],a

; Wait until done rendering

.loop2: ld      a,[StartDMA]
        ld      b,a
        ld      a,[DMAState]
        or      b
        jr      nz,.loop2

        pop     af
        ret



FunkyDelay:
        ld      b,25
FunkyDly:
.loop1:
        ld      hl,0
.loop2:
        dec     hl
        ld      a,h
        or      l
        jr      nz,.loop2
        dec     b
        jr      nz,.loop1
        ret

DrawFace:
        ld      hl,FaceDisplayList
        jr      _DrawLoop2
DrawEyes:
        ld      hl,EyesDisplayList
        jr      _DrawLoop2

_DrawLoop1:
        ld      a,[TriTable]
        ld      l,a
        ld      a,[TriTable+1]
        ld      h,a
_DrawLoop2:
        ld      a,[hl]
        cp      DL_LINE         ; Draw a line?
        jp      z,.doline       ; yes

        cp      DL_SETC         ; Color select?
        jp      z,.setcolor     ; yes

        cp      DL_END          ; End of list?
        jp      z,.listdone     ; yes

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriYOffset]
        sub     c
        ld      c,a
        inc     hl

        push    bc

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    .ScaleCoord
        ld      e,a
        ld      a,[TriYOffset]
        sub     e
        ld      c,a
        inc     hl

        push    bc

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriYOffset]
        sub     c
        ld      c,a
        inc     hl

        ld      a,l
        ld      [TriTable],a
        ld      a,h
        ld      [TriTable+1],a

        pop     de
        pop     hl

        call    .DoTri

        jr      _DrawLoop1

.doline:
        inc     hl

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriYOffset]
        sub     c
        ld      c,a
        inc     hl

        ld      a,b
        ld      [x1],a
        ld      a,c
        ld      [y1],a

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    .ScaleCoord
        ld      c,a
        ld      a,[TriYOffset]
        sub     c
        ld      c,a
        inc     hl

        push    hl

        ld      a,b
        ld      [x2],a
        ld      a,c
        ld      [y2],a

        call    XorLine

        pop     hl
        jp      _DrawLoop2

.listdone:
        ret

.setcolor:
        inc     hl
        ld      a,[hl+]
        ld      [TriColor],a
        jp      _DrawLoop2

.DoTri:
        ld      a,[TriColor]
        or      a
        jp      z,WhiteTri
        dec     a
        jp      z,LightTri
        dec     a
        jp      z,DarkTri
        dec     a
        jp      z,BlackTri
        jp      XorTri

.ScaleCoord:
        ld      a,[TriScale]
        add     a
        add     .ScaleJmpTab%256
        ld      e,a
        ld      a,.ScaleJmpTab/256
        adc     0
        ld      d,a

        ld      a,[de]
        ld      c,a
        inc     de
        ld      a,[de]
        ld      d,a
        ld      e,c


        push    de
        ret             ; Jump to table entry


.ScaleJmpTab:
        dw      .TriScale_5
        dw      .TriScale_625
        dw      .TriScale_75
        dw      .TriScale_875
        dw      .TriScale1
        dw      .TriScale1_25
        dw      .TriScale1_5
        dw      .TriScale1_75
        dw      .TriScale2
        dw      .TriScale2_25
        dw      .TriScale2_5
        dw      .TriScale2_75
        dw      .TriScale3
        dw      .TriScale3_25

.TriScale_5:
        ld      a,[hl]
        srl     a
        ret

.TriScale_625:
        ld      a,[hl]
        srl     a
        ld      c,a     ; c = .5
        srl     a
        srl     a
        add     c
        ret

.TriScale_75:
        ld      a,[hl]
        srl     a
        ld      c,a     ; c = .5
        srl     a
        add     c
        ret

.TriScale_875:
        ld      a,[hl]
        srl     a
        ld      c,a     ; c = .5
        srl     a
        ld      d,a     ; d = .25
        srl     a
        add     c
        add     d
        ret

.TriScale1:
        ld      a,[hl]
        ret

.TriScale1_25:
        ld      a,[hl]
        ld      c,a
        srl     a
        srl     a
        add     c
        ret

.TriScale1_5:
        ld      a,[hl]
        ld      c,a
        srl     a
        add     c
        ret

.TriScale1_75:
        ld      a,[hl]
        ld      c,a     ; c = 1
        srl     a
        ld      d,a     ; d = .5
        srl     a
        add     c
        add     d
        ret

.TriScale2:
        ld      a,[hl]
        add     a
        ret

.TriScale2_25:
        ld      a,[hl]
        srl     a
        srl     a
        ld      c,a     ; c = .25
        ld      a,[hl]
        add     a
        add     c
        ret

.TriScale2_5:
        ld      a,[hl]
        srl     a
        ld      c,a
        ld      a,[hl]
        add     a
        add     c
        ret

.TriScale2_75:
        ld      a,[hl]
        srl     a
        ld      c,a
        srl     a
        add     c
        ld      c,a     ; c = .75
        ld      a,[hl]
        add     a
        add     c
        ret

.TriScale3:
        ld      a,[hl]
        add     a
        add     [hl]
        ret

.TriScale3_25:
        ld      a,[hl]
        srl     a
        srl     a
        ld      c,a     ; c = .25
        ld      a,[hl]
        add     a
        add     a,[hl]
        add     c
        ret

; 72 tri's for face + 40 for eyes = 112 total

FaceDisplayList:

        db      DL_SETC, 1      ; Skin drawing color
; Face
        db      27,21, 21,27, 9,27
        db      27,21, 9,27,  2,21
        db      27,9, 27,21, 2,21
        db      27,9, 2,21,  2,9

; Left ear
        db      2,13, 2,18, 0,15
        db      2,13, 0,15, 0,12
        db      2,13, 0,12, 2,9

; Right ear
        db      29,15, 27,18, 27,13
        db      29,12, 29,15, 27,13
        db      29,12, 27,13, 27,9

; Chin
        db      27,9,  2,9,  24,4
        db      24,4,  2,9,  5,4
        db      24,4,  5,4,  16,0
        db      16,0,  5,4,  13,0

        db      DL_SETC, 2  ; Red drawing color

; Hat
        db      24,37, 19,40, 11,40
        db      24,37, 11,40, 6,37
        db      28,32, 24,37, 6,37
        db      28,32, 6,37,  2,32
        db      30,27, 28,32, 2,32
        db      30,27, 2,32,  0,27
        db      9,27, 0,27,   3,21
        db      3,21, 0,27,   0,20
        db      3,21, 0,20,   2,18
        db      30,27, 21,27, 26,21
        db      30,27, 26,21, 29,20
        db      29,20, 26,21, 27,18

        db      DL_SETC, 0  ; White drawing color

; Hat Logo
        db      18,31, 17,32, 16,31
        db      14,31, 13,32, 12,31

        db      21,31, 20,36, 20,30
        db      20,36, 17,37, 20,30
        db      17,37, 12,37, 15,33
        db      12,37, 9,36,  9,30
        db      9,30,  9,36,  8,32

        db      DL_SETC, 3  ; Black drawing color

; Left eyebrow
        db      13,24, 12,26, 11,26
        db      12,26, 11,27, 11,26
        db      11,26, 11,27, 9,26
        db      11,27, 9,27,  7,25
        db      9,27,  6,26,  7,25
        db      7,25,  6,26,  5,23

; Right eyebrow
        db      24,23, 24,25, 22,25
        db      24,25, 21,27, 22,25
        db      22,25, 21,27, 20,26
        db      20,26, 21,27, 19,26
        db      19,26, 21,27, 18,27
        db      19,26, 18,27, 17,26
        db      19,26, 17,26, 16,24

; Left sideburn
        db      3,16, 3,21, 1,15
        db      3,16, 1,15, 2,13
        db      2,13, 1,15, 1,13
        db      2,13, 1,13, 2,11

; Right sideburn
        db      28,15, 26,21, 26,16
        db      28,15, 26,16, 27,12

; Left moustache

        db      4,15, 3,10, 7,11
        db      7,11, 3,10, 5,8
        db      8,8,  7,11, 5,8
        db      8,8,  5,8,  6,6
        db      10,6, 8,8,  6,6
        db      10,6, 6,6,  9,5
        db      10,4, 10,6, 9,5
        db      12,4, 10,6, 10,4
        db      15,5, 10,6, 12,4

; Right moustache
        db      26,10, 25,15, 22,12
        db      26,10, 22,12, 22,9
        db      26,10, 22,9,  24,8
        db      24,8,  22,9,  23,6
        db      23,6,  22,9,  19,4
        db      19,4,  22,9,  19,6
        db      19,4,  19,6,  17,4
        db      17,4,  19,6,  15,5

        db      DL_SETC, 2  ; Red drawing color

; Nose
        db      $fd, 7,11, 8,14
        db      $fd, 8,14, 13,17
        db      $fd, 22,12, 21,15
        db      $fd, 21,15, 17,17

; Mouth
        db      16,2, 19,4, 10,4
        db      16,2, 10,4, 13,2
        db      17,4, 15,5, 12,4

        db      DL_END

; 40 tri's for the eyes

EyesDisplayList:

        db      DL_SETC, 0  ; White drawing color

; Left eye
        db      13,22, 12,23, 10,23     ; white of eye
        db      13,22, 10,23, 9,21
        db      13,22, 9,21,  9,17
        db      13,22, 9,17,  10,16
        db      13,22, 12,21, 13,20

        db      DL_SETC, 2  ; Red drawing color

        db      13,20, 12,21, 11,21     ; blue of eye
        db      13,20, 11,21, 10,20
        db      13,20, 10,20, 10,17
        db      13,20, 10,17, 11,16
        db      13,20, 11,16, 12,17
        db      13,20, 12,20, 13,19
        db      13,17, 13,18, 12,17

        db      DL_SETC, 3  ; Black drawing color

        db      13,19, 12,20, 11,20
        db      13,19, 11,20, 10,19
        db      13,19, 10,19, 10,18
        db      13,19, 10,18, 11,17
        db      13,19, 11,17, 12,17
        db      13,19, 12,17, 13,18

        db      DL_SETC, 0  ; White drawing color

        db      12,19, 11,19, 11,18
        db      12,19, 11,18, 12,18

; Right eye
        db      DL_SETC, 0  ; White drawing color

        db      21,21, 20,23, 18,23
        db      21,21, 18,23, 17,22
        db      21,21, 17,22, 17,17
        db      21,21, 19,16, 20,16
        db      21,21, 20,16, 21,17

        db      DL_SETC, 2  ; Red drawing color

        db      20,20, 19,21, 18,21
        db      20,20, 18,21, 17,20
        db      18,20, 17,20, 17,19
        db      18,17, 17,18, 17,17
        db      20,20, 19,20, 20,19
        db      20,17, 20,18, 19,17
        db      20,17, 18,17, 19,16

        db      DL_SETC, 3  ; Black drawing color

        db      20,19, 19,20, 18,20
        db      20,19, 18,20, 17,19
        db      20,19, 17,19, 17,18
        db      20,19, 17,18, 18,17
        db      20,19, 18,17, 19,17
        db      20,19, 19,17, 20,18

        db      DL_SETC, 0  ; White drawing color

        db      19,19, 18,19, 18,18
        db      19,19, 18,18, 19,18

        db      DL_END

MarioAttrMap:
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00

        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$11,$11,$11,$11,$00,$00 ;,$00,$00

        DB      $00,$00,$11,$11,$11,$11,$00,$00 ;,$00,$00
        DB      $00,$01,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00

        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00

        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00

MarioGBCPalettes:
        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

BlueeyesGBCPalettes:
        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  64,64,255       ; Light Blue
        RGBSet  0,0,0           ; Black