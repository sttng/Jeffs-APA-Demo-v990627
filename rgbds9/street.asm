
        PUSHS

        SECTION "Low Ram Street",WRAM0        ;SECTION "Low Ram",BSS
;
;TriTable        dw
;TriColor        db
;TriScale        db
;TriXOffset      db
;TriYOffset      db

        POPS


;XTOFFS   equ     33
;YTOFFS   equ     3*46

DEF YTOFFS  equ     70-2-16

;DL_LINE2 equ     128
;DL_SETC2 equ     129
;DL_END2  equ     130


AnimateStreet:
        call    ScreenOff

; Setup GBC Attribute memory with map

        ld      hl,StreetGBCPalettes
        call    SetCGB_BGP

        ld      a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON
        ld      [rLCDC],a        ; Turn screen on

        call    InstallEdgeLineCode
;        call    InstallFastLineCode

;        ld      a,XTOFFS+10
;        ld      [TriXOffset],a
;        ld      a,YTOFFS-16
;        ld      [TriYOffset],a

        ld      a,12
        ld      [TriScale],a

.loop1:
        ld      a,0
.loop2:
        push    af
        ld      b,80
        ld      c,YTOFFS+4 ;72

        ld      d,20
        ld      e,YTOFFS+75 ;143

        ld      h,140
        ld      l,YTOFFS+75 ;143

        call    BlackTri

        pop     af
        push    af

        ld      c,0
        call    DrawLeftTree
 if 1
        ld      c,1
        call    DrawLeftTree

        ld      c,5
        call    DrawLeftTree

        ld      c,10
        call    DrawLeftTree

        ld      c,3
        call    DrawRightTree

        ld      c,7
        call    DrawRightTree

        ld      c,13
        call    DrawRightTree
 endc
        ld      a,1
        ld      [StartDMA],a    ; Render scene

        call    WaitAndClearRenderBuffer

        pop     af
        inc     a
        cp      16
        jr      nz,.loop2

        jr      .loop1


DrawLeftTree:
        push    af

        add     c
        cp      16
        jr      c,.skip
        sub     16
.skip:

        ld      [TriScale],a

        ld      c,a
        ld      b,0
        ld      hl,TreeOrgTable
        add     hl,bc
        ld      a,[hl]

        ld      hl,TreeXTable
        add     hl,bc

        ld      b,a
        ld      a,[hl]
        add     b
        ld      b,a

        ld      a,72+2+2+2
        sub     b
        ld      [TriXOffset],a

        ld      a,b
        add     a
        ld      c,a

        ld      a,[TriScale]
        ld      c,a
        add     a
;        add     c
        ld      c,a
        ld      a,YTOFFS
        add     c
        ld      [TriYOffset],a

        call    SetPatAdr

        call    DrawTree

        pop     af
        ret

DrawRightTree:
        push    af

        add     c
        cp      16
        jr      c,.skip
        sub     16
.skip:

        ld      [TriScale],a

        ld      c,a
        ld      b,0
        ld      hl,TreeOrgTable
        add     hl,bc
        ld      a,[hl]

        ld      hl,TreeXTable
        add     hl,bc

        ld      b,a
        ld      a,[hl]
;        ld      a,0
        sub     b
        ld      b,a

        ld      a,78
        add     b
        ld      [TriXOffset],a

        ld      a,b
        add     a
        ld      c,a

        ld      a,[TriScale]
        add     a
        ld      c,a
        ld      a,YTOFFS
        add     c
        ld      [TriYOffset],a

        call    SetPatAdr
        call    DrawTree

        pop     af
        ret

SetPatAdr:
        ld      hl,Patterns ;-(1280+0)
        call    SetPatternAddress

        ret

TreeOrgTable:
        db      0,0,0,1,2,3,4,6,7,8,9,10,12,14,16,18,22
        db      0,0,0,16,17,18,19,20

TreeXTable:
        db      0,1,2,4,6,9,12,16,20,25,30,36,42,49,56,64,72
        db      0,1,2,4,7,11,16,22,29,37,46,56,67,79,92


DrawTree:
        ld      hl,TreeDisplayList
        jr      _DrawSLoop2

_DrawSLoop1:
        ld      a,[TriTable]
        ld      l,a
        ld      a,[TriTable+1]
        ld      h,a
_DrawSLoop2:
        ld      a,[hl]
        cp      DL_LINE         ; Draw a line?
        jp      z,.doline       ; yes

        cp      DL_SETC         ; Color select?
        jp      z,.setcolor     ; yes

        cp      DL_END          ; End of list?
        jp      z,.listdone     ; yes

        call    ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    ScaleCoord
        ld      c,a
        ld      a,[TriYOffset]
        sub     c
        ld      c,a
        inc     hl

        push    bc

        call    ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    ScaleCoord
        ld      e,a
        ld      a,[TriYOffset]
        sub     e
        ld      c,a
        inc     hl

        push    bc

        call    ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    ScaleCoord
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

        call    DoTri

        jr      _DrawSLoop1

.doline:
        inc     hl

        call    ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    ScaleCoord
        ld      c,a
        ld      a,[TriYOffset]
        sub     c
        ld      c,a
        inc     hl

        ld      a,b
        ld      [x1],a
        ld      a,c
        ld      [y1],a

        call    ScaleCoord
        ld      c,a
        ld      a,[TriXOffset]
        add     c
        ld      b,a
        inc     hl

        call    ScaleCoord
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
        jp      _DrawSLoop2

.listdone:
        ret

.setcolor:
        inc     hl
        ld      a,[hl+]
        ld      [TriColor],a
        jp      _DrawSLoop2


DoTri:
        ld      a,[TriColor]
        or      a
        jp      z,WhiteTri
        dec     a
        jp      z,LightTri
        dec     a
        jp      z,DarkTri
        dec     a
        jp      z,BlackTri
        dec     a
        jp      z,XorTri
        dec     a
        jp      z,TextureTri
        jp      PatternTri

ScaleCoord:
        ld      a,[TriScale]
        add     a
        add     ScaleJmpTab%256
        ld      e,a
        ld      a,ScaleJmpTab/256
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


ScaleJmpTab:
        dw      TriScale_25
        dw      TriScale_5
        dw      TriScale_625
        dw      TriScale_75
        dw      TriScale_875
        dw      TriScale1
        dw      TriScale1_25
        dw      TriScale1_5
        dw      TriScale1_75
        dw      TriScale2
        dw      TriScale2_25
        dw      TriScale2_5
        dw      TriScale2_75
        dw      TriScale3
        dw      TriScale3_25
        dw      TriScale4
        dw      TriScale5
        dw      TriScale6
        dw      TriScale7
        dw      TriScale8

TriScale_25:
        ld      a,[hl]
        srl     a
        srl     a
        ret

TriScale_5:
        ld      a,[hl]
        srl     a
        ret

TriScale_625:
        ld      a,[hl]
        srl     a
        ld      c,a     ; c = .5
        srl     a
        srl     a
        add     c
        ret

TriScale_75:
        ld      a,[hl]
        srl     a
        ld      c,a     ; c = .5
        srl     a
        add     c
        ret

TriScale_875:
        ld      a,[hl]
        srl     a
        ld      c,a     ; c = .5
        srl     a
        ld      d,a     ; d = .25
        srl     a
        add     c
        add     d
        ret

TriScale1:
        ld      a,[hl]
        ret

TriScale1_25:
        ld      a,[hl]
        ld      c,a
        srl     a
        srl     a
        add     c
        ret

TriScale1_5:
        ld      a,[hl]
        ld      c,a
        srl     a
        add     c
        ret

TriScale1_75:
        ld      a,[hl]
        ld      c,a     ; c = 1
        srl     a
        ld      d,a     ; d = .5
        srl     a
        add     c
        add     d
        ret

TriScale2:
        ld      a,[hl]
        add     a
        ret

TriScale2_25:
        ld      a,[hl]
        srl     a
        srl     a
        ld      c,a     ; c = .25
        ld      a,[hl]
        add     a
        add     c
        ret

TriScale2_5:
        ld      a,[hl]
        srl     a
        ld      c,a
        ld      a,[hl]
        add     a
        add     c
        ret

TriScale2_75:
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

TriScale3:
        ld      a,[hl]
        add     a
        add     [hl]
        ret

TriScale3_25:
        ld      a,[hl]
        srl     a
        srl     a
        ld      c,a     ; c = .25
        ld      a,[hl]
        add     a
        add     a,[hl]
        add     c
        ret

TriScale4:
        ld      a,[hl]
        add     a
        add     a
        ret

TriScale5:
        ld      a,[hl]
        add     a
        add     a
        add     a,[hl]
        ret

TriScale6:
        ld      a,[hl]
        add     a
        ld      a,c
        add     a
        add     a,c
        ret

TriScale7:
        ld      a,[hl]
        add     a
        ld      a,c
        add     a
        add     a,c
        add     a,[hl]
        ret

TriScale8:
        ld      a,[hl]
        add     a
        add     a
        add     a
        ret

TreeDisplayList:
        db      DL_SETC, 6  ; Light drawing color

        db      7,0, 5,16, 3,0

;        db      DL_SETC,3   ; Dark drawing color

; Tree leaves

        db      9,12, 8,15, 7,14
        db      8,15, 2,15, 5,12
        db      3,14, 2,15, 1,12
        db      8,15, 7,16, 6,15
        db      6,15, 5,16, 4,15
        db      4,15, 3,16, 2,15

        db      DL_END

StreetGBCPalettes:
        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  0,255,0         ; Green
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black