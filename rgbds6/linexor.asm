
; *
; * Fast line code for GB/GBC
; * by Jeff Frohwein
; * last edit 25-Jun-99
; *
; * Written with RGBDS
; *

; RENDER_TO_VRAM: 0 = $c000, 1 = $8000
;
; NOTE: Rendering is much slower when rendering to
; VRAM ($8000) due to waits for video RAM to be available.

; *** Draw a Xor line ***
; Entry: [x1] = Start X Coordinate
;        [y1] = Start Y Coordinate
;        [x2] = End X Coordinate
;        [y2] = End Y Coordinate
;        Line is only XOR color. No solid colors in this version.
;

;On the GBC in 2X speed:
; Random angle lines:
;  black/white - 1050 lines/sec at (64 pixel)
;  black/white -  595 lines/sec at (124 pixel)
;
;  grey scale - 1000 lines/sec at (64 pixel)
;  grey scale -  566 lines/sec at (124 pixel)
;
; Vertical lines:
;  black/white - 2844 lines/sec (64 pixel)
;  black/white - 1600 lines/sec (120 pixel)
;
;  grey scale - 2133 lines/sec (64 pixel)
;  grey scale - 1220 lines/sec (120 pixel)
;
; Horizontal lines:
;  black/white - 9230 lines/sec (64 pixel)
;  black/white - 6315 lines/sec (128 pixel)
;
;  grey scale - 8275 lines/sec (64 pixel)
;  grey scale - 5714 lines/sec (128 pixel)

XorLine:
        ld      a,[y1]
        ld      l,a
        ld      a,[y2]
        cp      l               ; Is it a vertical line?
        jp      z,.HorizLine    ; yes

        ld      a,[x1]
        ld      l,a
        ld      a,[x2]
        cp      l               ; Is it a vertical line?
        jp      z,.VertLine     ; yes

; find [y2-y1]

        ld      a,[y1]          ; hl = y2 - y1
        ld      b,a
        ld      l,a
        ld      a,[y2]
        ld      c,a
        sub     l
        ld      l,a
        ld      a,0
        sbc     a
        ld      h,a

        rlca                    ; Is hl positive ?
        jr      nc,.xline1       ; yes

        ld      a,[x2]
        ld      [tempx1],a

        ld      a,[x1]
        ld      [tempx2],a

        ld      a,c
        ld      [tempy1],a

        ld      a,b
        ld      [tempy2],a

        xor     a               ; hl = -hl
        sub     l
        ld      l,a
        jr      .xline1x

.xline1:
        ld      a,[x1]
        ld      [tempx1],a

        ld      a,[x2]
        ld      [tempx2],a

        ld      a,b
        ld      [tempy1],a

        ld      a,c
        ld      [tempy2],a

.xline1x:

; find [x2-x1]

        ld      a,[tempx1]          ; de = x2 - x1
        ld      e,a
        ld      a,[tempx2]
        sub     e
        ld      e,a
        ld      a,0
        sbc     a
        ld      d,a

        rlca                    ; Is de positive ?
        jr      nc,.xline2       ; yes

        ld      a,1
        ld      [leftlf],a

        xor     a               ; de = -de
        sub     e
        ld      e,a
        jr      .xline2x

.xline2:
        xor     a
        ld      [leftlf],a

.xline2x:

        ld      h,e

        ld      c,0

; sort [y2-y1] and [x2-x1]

        ld      a,h
        cp      l
        jr      nc,.xline3

        ld      c,1

        ld      h,l     ;exchange h & l
        ld      l,a

.xline3:

; store dels, delp, delsx, and delsy

;.xline4:
        ld      a,c
        ld      [talllf],a

        ld      a,l

; compute initial and inc for error function

        add     a,a
        ld      c,a

 if HIGH_LINE_PREC
        ld      [delse],a
 endc

        ld      a,0
        rla             ; put carry in lsb of A
        ld      b,a

 if HIGH_LINE_PREC
        ld      [delse+1],a
 endc

        ld      a,c             ; de = (delp * 2) - dels
        sub     h
        ld      e,a
        ld      a,b
        sbc     0
        ld      d,a

 if HIGH_LINE_PREC
 else
        push    de
 endc

        ld      a,e             ; delde = (delp * 2) - (dels * 2)
        sub     h

 if HIGH_LINE_PREC
        ld      [delde],a
 else
        ld      e,a
 endc

        ld      a,d
        sbc     0

 if HIGH_LINE_PREC
        ld      [delde+1],a
 else
        ld      d,a

        sra     d
        rr      e
        sra     d
        rr      e       ; de = delde / 4

        ld      a,e
        ld      [delde],a

        pop     de

        sra     d
        rr      e
        sra     d
        rr      e

        sra     b
        rr      c
        sra     b
        rr      c       ; bc = delse / 4
        ld      a,c
        ld      [delse],a
 endc

        push    de

; adjust count

        inc     h
        ld      c,h             ; c = total pixel count

        ld      a,[tempy1]
        ld      l,a

        ld      a,[tempx1]
        sla     l
        ld      h,a
        srl     h
 if RENDER_TO_VRAM
        or      a               ; clear carry
 else
        scf                     ; set carry
 endc
        rr      h
        scf
        rr      h               ; start addr = $c000 + f(x)

        and     7               ; b = Bitmask[b & 7]
        ld      e,a
        ld      d,0
        ld      a,[de]
        ld      b,a

;        B = Bit set mask


        pop     de


; *** Load this code to RAM so we can modify it ***

        ld      a,[talllf]
        or      a
        jr      nz,.mloop2

; *** "Line is wider than tall" code ***

.loop10:
        ld      a,[leftlf]
        or      a
        jr      nz,.loop15

; *** Line goes left to right ***

 if HIGH_LINE_PREC
 else
        ld      a,[delse]
        ld      d,a
 endc

.loop11:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

; Increment right

        rrc     b
        jr      nc,.skip11

        inc     h
.skip11:

 if HIGH_LINE_PREC
        bit     7,d
 else
        bit     7,e
 endc
        jr      nz,.skip13

; Increment down

        inc     l
        inc     l

        ld      a,[delde]
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delde+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop11

        ret

.skip13:

 if HIGH_LINE_PREC
        ld      a,[delse]
 else
        ld      a,d
 endc
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delse+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop11

        ret

; *** Line goes right to left ***

.loop15:
 if HIGH_LINE_PREC
 else
        ld      a,[delse]
        ld      d,a
 endc

.loop16:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

; Increment right

        rlc     b
        jr      nc,.skip16

        dec     h
.skip16:

 if HIGH_LINE_PREC
        bit     7,d
 else
        bit     7,e
 endc
        jr      nz,.skip18

; Increment down

        inc     l
        inc     l

        ld      a,[delde]
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delde+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop16

        ret

.skip18:

 if HIGH_LINE_PREC
        ld      a,[delse]
 else
        ld      a,d
 endc
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delse+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop16

        ret

; *** "Line is taller than wide" code ***

.mloop2:
.loop20:
        ld      a,[leftlf]
        or      a
        jr      nz,.loop25

; *** Line goes left to right ***

 if HIGH_LINE_PREC
 else
        ld      a,[delse]
        ld      d,a
 endc

.loop21:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

; Increment down

        inc     l
        inc     l


 if HIGH_LINE_PREC
        bit     7,d
 else
        bit     7,e
 endc
        jr      nz,.skip23

; Increment right

        rrc     b
        jr      nc,.skip22

        inc     h
.skip22:

        ld      a,[delde]
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delde+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop21

        ret

.skip23:

 if HIGH_LINE_PREC
        ld      a,[delse]
 else
        ld      a,d
 endc
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delse+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop21

        ret

; *** Line goes right to left ***

.loop25:

 if HIGH_LINE_PREC
 else
        ld      a,[delse]
        ld      d,a
 endc

.loop26:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

; Increment down

        inc     l
        inc     l


 if HIGH_LINE_PREC
        bit     7,d
 else
        bit     7,e
 endc
        jr      nz,.skip28

; Increment right

        rlc     b
        jr      nc,.skip27

        dec     h
.skip27:

        ld      a,[delde]
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delde+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop26

        ret

.skip28:

 if HIGH_LINE_PREC
        ld      a,[delse]
 else
        ld      a,d
 endc
        add     a,e
	ld	e,a

 if HIGH_LINE_PREC
        ld      a,[delse+1]
        adc     a,d
	ld	d,a
 endc

        dec     c
        jr      nz,.loop26

        ret

; ****** Render vertical lines ******

.VertLine:
        ld      a,[y1]
        add     a
        ld      l,a

        ld      a,[x1]
        ld      h,a
        srl     h
 if RENDER_TO_VRAM
        or      a               ; clear carry
 else
        scf                     ; set carry
 endc
        rr      h
        scf
        rr      h               ; hl = start addr = $c000 + f(x)

        and     7               ; b = Bitmask[b & 7]
        ld      e,a
        ld      d,0
        ld      a,[de]
        ld      b,a


        ld      a,[y1]          ; hl = y2 - y1
        ld      c,a
        ld      a,[y2]
        sub     c               ; is it just a single point?
;        ret     z               ; yes, exit
        jr      nc,.pos30       ; positive delta y

        inc     l               ; move to second color byte

        cpl
        inc     a               ; a = -a

        inc     a               ; a++
        ld      c,a             ; c = pixel count

        and     1               ; Is it an odd # of pixels?
        jr      nz,.skip30      ; yes

.loop30:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl-],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     c
.skip30:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl-],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     c
        jr      nz,.loop30

        ret

.pos30:
        inc     a               ; a++
        ld      c,a             ; c = pixel count

        and     1               ; Is it an odd # of pixels?
        jr      nz,.skip32      ; yes

.loop32:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl+],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     c
.skip32:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl+],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     c
        jr      nz,.loop32

        ret

; ****** Render horizontal lines ******

.HorizLine:
        ld      a,[x1]
        ld      b,a
        ld      a,[x2]
        ld      c,a
        sub     b               ; Is x2 larger?
        jr      nc,.nosort      ; yes

        ld      a,b
        ld      b,c
        ld      c,a             ; swap b & c

.nosort:
        ld      a,c
        ld      [tempx2],a
        ld      h,b
        ld      a,b
;        ld      [tempx1],a

        and     7
        ld      e,a
        ld      d,LEFT_LINE_MASK_ADDR/256
        ld      a,[de]
        ld      b,a

        ld      a,[y1]
        add     a
        ld      l,a

;        ld      a,[tempx1]
;        ld      h,a

        srl     h

 if RENDER_TO_VRAM
        or      a               ; clear carry
 else
        scf                     ; set carry
 endc

        rr      h
        scf
        rr      h               ; hl = strt adr = $c000 + f(x)

;        ld      a,[tempx2]
;        ld      d,a
        ld      d,c
        srl     d

 if RENDER_TO_VRAM
        or      a               ; clear carry
 else
        scf                     ; set carry
 endc

        rr      d
        scf
        rr      d
;        ld      e,l             ; de = end adr = $c000 + f(x)

        ld      a,d
        sub     h
        ld      c,a

        or      a               ; Is just a single address used?
        jr      z,.sameadr      ; yes

; Plot beginning of line

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        ld      b,$ff

        dec     c               ; Should we fill?
        jr      z,.done         ; no

        bit     0,c             ; Is pixel count odd?
        jr      nz,.blitloop2   ; yes

;        ld      a,c
;        and     $3
;        dec     a
;        jr      z,.blitloop3
;        dec     a
;        jr      z,.blitloop2
;        dec     a
;        jr      z,.blitloop1

.blitloop:
        inc     h               ; Increment right to next column

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        cpl
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        cpl
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     c

.blitloop2:
        inc     h               ; Increment right to next column

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        cpl
        ld      [hl+],a

        ld      a,[hl]
        cpl
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     c               ; Are we done?
        jr      nz,.blitloop    ; not yet

.done:
; Plot last part of line

        inc     h

.sameadr:
        ld      a,[tempx2]
        and     7
        ld      e,a
        ld      d,RIGHT_LINE_MASK_ADDR/256
        ld      a,[de]

        and     b
        ld      b,a

.DoEndPixels:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        xor     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        xor     b
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        ret