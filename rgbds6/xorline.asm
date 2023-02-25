
XorLines:
        call    ScreenOff

; Setup GBC Attribute memory with map

        ld      hl,XorlineAttrMap
        call    SetCGBAttrMap1
        ld      hl,XorlineAttrMap
        call    SetCGBAttrMap2

        ld      hl,XorlineGBCPalettes
        call    SetCGB_BGP

        ld      a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON
        ld      [rLCDC],a        ; Turn screen on

;        call    InstallFastLineCode

 ;       jp      UpDown

        ; Draw vertical lines

LINE_WIDE       equ     128
LINE_HIGH       equ     120


;        ld      de,2000
.loop:
;        push    de

        ld      b,0
.loop0:
        ld      a,b
        ld      [y1],a
        ld      [y2],a

        srl     a
        srl     a
        srl     a
        srl     a
        and     3
        ld      [Color],a

        ld      a,0
        ld      [x1],a
        ld      a,127
        ld      [x2],a

        push    bc
        call    DrawLine
        pop     bc

        ld      a,1
        ld      [StartDMA],a

        inc     b
        ld      a,b
        cp      120
        jr      nz,.loop0

;.ploop:
;        jr      .ploop

.mloop:

        ld      b,LINE_WIDE
.loop1:
        ld      a,LINE_WIDE
        sub     b
        ld      [x1],a
        ld      a,0
        ld      [y1],a

        ld      a,b
        dec     a
        ld      [x2],a
        ld      a,LINE_HIGH-1
        ld      [y2],a

        push    bc
        call    XorLine
        pop     bc

        ld      a,1
        ld      [StartDMA],a

        dec     b
        jr      nz,.loop1

; Draw horizontal lines

        ld      b,LINE_HIGH
.loop2:
        ld      a,LINE_HIGH
        sub     b
        ld      [y1],a
        ld      a,0
        ld      [x1],a

        ld      a,b
        dec     a
        ld      [y2],a
        ld      a,LINE_WIDE-1
        ld      [x2],a

        push    bc
        call    XorLine
        pop     bc

        ld      a,1
        ld      [StartDMA],a

        dec     b
        jr      nz,.loop2

; Draw vertical lines

        ld      b,LINE_WIDE
.loop3:
        ld      a,LINE_WIDE
        sub     b
        ld      [x2],a
        ld      a,0
        ld      [y2],a

        ld      a,b
        dec     a
        ld      [x1],a
        ld      a,LINE_HIGH-1
        ld      [y1],a

        push    bc
        call    XorLine
        pop     bc

        ld      a,1
        ld      [StartDMA],a

        dec     b
        jr      nz,.loop3

; Draw horizontal lines

        ld      b,LINE_HIGH
.loop4:
        ld      a,LINE_HIGH
        sub     b
        ld      [y2],a
        ld      a,0
        ld      [x2],a

        ld      a,b
        dec     a
        ld      [y1],a
        ld      a,LINE_WIDE-1
        ld      [x1],a

        push    bc
        call    XorLine
        pop     bc

        ld      a,1
        ld      [StartDMA],a

        dec     b
        jr      nz,.loop4

        jp      .mloop

; Draw straight up & down lines

UpDown:
        ld      c,200
.loop1:
        ld      b,0
.loop2:
        ld      a,b
        ld      [x1],a
        ld      [x2],a

;        srl     a
;        srl     a
;        srl     a
;        srl     a
;        and     3
;        ld      [Color],a

        ld      a,0
        ld      [y1],a
        ld      a,63 ;119
        ld      [y2],a

        push    bc
        call    XorLine
        pop     bc

        ld      a,1
        ld      [StartDMA],a

        inc     b
        ld      a,b
        cp      128
        jr      nz,.loop2

        dec     c
        jr      nz,.loop1

UpDown2:
        jr      UpDown2

XorlineGBCPalettes:
        RGBSet  255,255,255     ; White
        RGBSet  64,255,64       ; Green
        RGBSet  0,0,255         ; Blue
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  128,64,0        ; Brown

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

XorlineAttrMap:
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11

        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11

        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11
        DB      $11,$11,$11,$11,$11,$11,$11,$11,$11,$11


;.done:
;        jr      .done