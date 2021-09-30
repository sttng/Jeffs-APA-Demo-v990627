
        PUSHS

        SECTION "Ellipse Ram",BSS

ColX    DW
ColY    DW
ChkVal  DB
SinInc  DB
XRad    DW
YRad    DW
RelX1   DW
RelX2   DW
RelY1   DW
RelY2   DW
SinCnt  DB
xm      DW
ym      DW

        POPS

; *** Draw an ellipse ***
; Entry: [xm] = Middle of ellipse X coordinate
;        [ym] = Middle of ellipse Y coordinate
;        [XRad] = X radius width of ellipse
;        [YRad] = Y radius height of ellipse
;        [Color] = Color of ellipse (0-4, 4 = Xor)

ellipse:
        xor     a
        ld      [xm+1],a
        ld      [ym+1],a
        ld      [XRad+1],a
        ld      [YRad+1],a

        ld      [SinCnt],a
        ld      [RelX1+1],a
        ld      [RelY1+1],a
        ld      [RelX2+1],a
        ld      [RelY2+1],a

        dec     a
        ld      [RelX1],a   ; Set RelX1 to 255, so compare below doesn't work
        ld      [RelY2],a   ;       "

Circ0:  ld      a,[SinCnt]  ; Get X count
        or      a
        rla

        ld      b,a
        ld      hl,XRad
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ld      a,b

        call    Mult        ; hl = hl * a
        ld      a,[RelX1]   ; Get last X1 coord
        sub     h
        ld      [ChkVal],a  ; IF RELX1=H, THEN A ZERO'S STORED HERE
        ld      a,h
        ld      [RelX1],a   ; Save rel X coord

        ld      a,[SinCnt]  ; Get Y count
        call    SinLUp      ; Get SIN of value

        ld      b,a
        ld      hl,YRad
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ld      a,b

        call    Mult        ; hl = hl * a
        ld      a,[RelY1]   ; Get last Y1 coord
        cp      h           ; Are they the same ?
        jr      nz,Circ1    ; No

        ld      a,[ChkVal]
        or      a
        jp      z,PlotSh    ; This point is the same as last so skip

Circ1:  ld      a,h
        ld      [RelY1],a   ; Save rel Y coord

        ld      hl,xm
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelX1
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        add     hl,de

        ld      a,l
        ld      [x1],a
        ld      [ColX],a    ; Save collision X coord
        ld      a,h
;        ld      [x1+1],a
        ld      [ColX+1],a  ; Save collision X coord

        ld      hl,ym
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelY1
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        add     hl,de

        ld      a,l
        ld      [y1],a
        ld      [ColY],a    ; Save collision Y coord
        ld      a,h
;        ld      [y1+1],a
        ld      [ColY+1],a  ; Save collision Y coord

        call    PlotXY      ; Plot vector 2-3

        ld      a,[RelX1]
        or      a           ; Is this the first point ?
        jr      z,Circ2     ; Yes, so don't draw it twice

        ld      hl,xm
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelX1
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        call    Comp

        add     hl,de

        ld      a,l
        ld      [x1],a
;        ld      a,h
;        ld      [x1+1],a

        call    PlotXY      ; Plot vector 2-1

Circ2:
        ld      hl,ym
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelY1
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        call    Comp

        add     hl,de

        ld      a,l
        ld      [y1],a
;        ld      a,h
;        ld      [y1+1],a

        call    PlotXY      ; Plot vector 8-7

        ld      a,[RelX1]
        or      a           ; Is this the first point?
        jr      z,PlotSh    ; Yes, so don't draw it twice

        ld      hl,xm
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelX1
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        add     hl,de

        ld      a,l
        ld      [x1],a
;        ld      a,h
;        ld      [x1+1],a

        call    PlotXY      ; Plot vector 8-9

; Now draw side walls

PlotSh: ld      a,[SinCnt]  ; Get Y count
        or      a
        rla

        ld      b,a
        ld      hl,YRad
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ld      a,b

        call    Mult        ; hl = hl * a

        ld      a,[RelY2]   ; Get last Y2 coord
        sub     h
        ld      [ChkVal],a  ; IF RelY2=H, then $00 is stored here
        ld      a,h
        ld      [RelY2],a   ; Save rel Y coord

        ld      a,[SinCnt]  ; Get X count
        call    SinLUp      ; Get SIN of value

        ld      b,a
        ld      hl,XRad
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ld      a,b

        call    Mult        ; hl = hl * a

        ld      a,[RelX2]   ; Get last X2 coord
        cp      h           ; Are they the same ?
        jr      nz,Circ3    ; No
        ld      a,[ChkVal]
        or      a
        jp      z,PlotSk    ; This point is the same as last so skip
Circ3:  ld      a,h
        ld      [RelX2],a   ; Save rel X coord

        ld      hl,ym
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelY2
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        add     hl,de

        ld      a,l
        ld      [y1],a
;        ld      a,h
;        ld      [y1+1],a

        ld      hl,xm
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelX2
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        add     hl,de

        ld      a,l
        ld      [x1],a
;        ld      a,h
;        ld      [x1+1],a

        ld      d,h             ; Put X1 in DE
        ld      e,l

        ld      hl,ColX         ; Put possible collision point in HL
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        call    CompHD          ; Are they the same ?
        jr      nz,Circ4        ; No

        ld      hl,y1           ; Put Y1 in DE
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,ColY         ; Put possible collision point in HL
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        call    CompHD          ; Are they the same ?
        ret     z               ; Yes, collision so exit

Circ4:  call    PlotXY          ; Plot vector 6-3

        ld      a,[RelY2]
        or      a               ; Is this the first point?
        jr      z,Circ5         ; Yes, so don't draw it twice

        ld      hl,ym
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelY2
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        call    Comp
        add     hl,de

        ld      a,l
        ld      [y1],a
;        ld      a,h
;        ld      [y1+1],a

        call    PlotXY          ; Plot vector 6-9

Circ5:
        ld      hl,xm
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelX2
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        call    Comp

        add     hl,de

        ld      a,l
        ld      [x1],a
;        ld      a,h
;        ld      [x1+1],a

        call    PlotXY          ; Plot vector 4-7

        ld      a,[RelY2]
        or      a               ; Is this the first point ?
        jr      z,PlotSk        ; Yes, so don't draw it twice

        ld      hl,ym
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ld      hl,RelY2
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        add     hl,de

        ld      a,l
        ld      [y1],a
;        ld      a,h
;        ld      [y1+1],a

        call    PlotXY          ; Plot vector 4-1

PlotSk: ld      a,[SinCnt]
        inc     a
        ld      [SinCnt],a
        cp      91              ; Are we done yet?
        jp      nz,Circ0        ; Not yet
        ret

PlotXY:
        ld      a,[x1]
        cp      160
        ret     nc
        ld      b,a
        ld      a,[y1]
        cp      144
        ret     nc
        ld      c,a
        call    DrawPoint
        ret


; lda     X1
;        sta     par1
;        lda     Y1
;        sta     par2
;        CALL    POINT
;        RET

; hl = l * a

Mult:   ld      c,l
        ld      l,0
        ld      h,a
        ld      b,0
        ld      a,8
Mult1:  add     hl,hl
        jr      nc,Mult2
        add     hl,bc
Mult2:  dec     a
        jr      nz,Mult1
        ret

;COMPARE HL & DE

CompHD: ld      a,h
        cp      d
        ret     nz
        ld      a,l
        cp      e
        ret

; A CONTAINS X COUNT, RETURN WITH SIN

SinLUp: ld      l,a
        ld      h,0
        ld      de,SABLE
        add     hl,de
        ld      a,[hl]
        ret

; SIN Lookup Table

SABLE:  DB      255,255,255,255,255,255,255,255
	DB	255,255,255,254,254,254,254,254
	DB	253,253,253,253,252,252,252,251
	DB	251,250,250,250,249,249,248,248
	DB	247,247,246,245,245,244,244,243
	DB	242,242,241,240,240,239,238,237
	DB	236,236,235,234,233,232,232,231
	DB	230,229,228,227,226,225,223,222
	DB	221,220,219,218,216,215,214,213
	DB	211,210,208,207,205,204,202,201
	DB	199,198,196,194,193,191,189,187
	DB	185,183,182


;************************
;*	Negate HL	*
;************************

Comp:
        xor     a
        sub     l
        ld      l,a
        ld      a,0
        sbc     h
        ld      h,a
        ret

;        ld      a,h
;        cpl
;        ld      h,a
;        ld      a,l
;        cpl
;        ld      l,a
;        inc     hl
;        ret
