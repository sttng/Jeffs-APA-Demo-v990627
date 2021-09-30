
        PUSHS

        SECTION "Line Ram",BSS

dels    db
delp    db
;delse   dw
delsx   db
delsy   db
;delde   dw
deldx   db
deldy   db

        POPS

; *** Draw a line ***
; Entry: [x1] = Start X Coordinate
;        [y1] = Start Y Coordinate
;        [x2] = End X Coordinate
;        [y2] = End Y Coordinate
;        [Color] = Line Color (0-4, 4 = Xor)
;
; On the GB this routine can draw ~  75 lines a second.
; On the GBC in 2X speed this routine can draw ~ 150 lines a second.
;   (Average line length of 75 pixels at this rate.)

line:
        ld      b,1     ; si
        ld      c,1     ; di

; find [y2-y1]

        ld      a,[y1]          ; hl = y2 - y1
        ld      l,a
        ld      a,[y2]
        sub     l
        ld      l,a
        ld      a,0
        sbc     a,a
        ld      h,a

        rlca                    ; Is hl positive ?
        jr      nc,xline1       ; yes

        ld      c,-1

        xor     a               ; hl = -hl
        sub     l
        ld      l,a
        ld      a,0
        sbc     h
        ld      h,a
xline1:
        ld      a,c
        ld      [deldy],a

; find [x2-x1]

        ld      a,[x1]          ; de = x2 - x1
        ld      e,a
        ld      a,[x2]
        sub     e
        ld      e,a
        ld      a,0
        sbc     a,a
        ld      d,a

        rlca                    ; Is de positive ?
        jr      nc,xline2       ; yes

        ld      b,-1

        xor     a               ; de = -de
        sub     e
        ld      e,a
        ld      a,0
        sbc     d
        ld      d,a
xline2:
        ld      a,b
        ld      [deldx],a

        ld      h,e

; sort [y2-y1] and [x2-x1]

        ld      a,h
        cp      l
        jr      nc,xline3

        ld      b,0

        ld      h,l     ;exchange h & l
        ld      l,a
	jr	xline4

xline3:
        ld      c,0

; store dels, delp, delsx, and delsy

xline4:
        ld      a,h
        ld      [dels],a
        ld      a,l
        ld      [delp],a
        ld      a,b
        ld      [delsx],a
        ld      a,c
        ld      [delsy],a

; compute initial and inc for error function

        ld      a,[delp]        ; delse = delp * 2
        add     a,a
        ld      c,a
        ld      [delse],a
        ld      a,0
        adc     0
        ld      b,a
        ld      [delse+1],a

        ld      a,c             ; de = (delp * 2) - dels
        sub     h
        ld      e,a
        ld      a,b
        sbc     0
        ld      d,a

        ld      a,e             ; delde = (delp * 2) - (dels * 2)
        sub     h
        ld      [delde],a
        ld      a,d
        sbc     0
        ld      [delde+1],a

; adjust count

        inc     h               ; h = total pixel count

        ld      a,[x1]
	ld	b,a
        ld      a,[y1]
	ld	c,a

xline5:
        push    bc
	push	de
	push	hl
	call	point
	pop	hl
	pop	de
	pop	bc

;xline6:
        bit     7,d
        jr      z,xline7

; case for straight move

        ld      a,[delsx]
	add	a,b
	ld	b,a

        ld      a,[delsy]
	add	a,c
	ld	c,a

        ld      a,[delse]
	add	a,e
	ld	e,a
        ld      a,[delse+1]
	adc	a,d
	ld	d,a

        dec     h
	jr	nz,xline5

	ret

; case for diagonal move
xline7:
        ld      a,[deldx]
	add	a,b
	ld	b,a

        ld      a,[deldy]
	add	a,c
	ld	c,a

        ld      a,[delde]
        add     a,e
	ld	e,a
        ld      a,[delde+1]
        adc     a,d
	ld	d,a

        dec     h
	jr	nz,xline5

	ret
