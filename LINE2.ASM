
        PUSHS

        SECTION "Low Ram",BSS

dels    db
delp    db
delse   db
delsx   db
delsy   db
delde   db
deldx   db
deldy   db

        POPS

; * Draw a line from X1,Y1 to X2,Y2 *

line:
	ld	d,1	; si
	ld	e,1	; di

; find [y2-y1]

        ld      a,[y1]
	ld	b,a
        ld      a,[y2]
	sub	b
	ld	h,a
        cp      $80
	jr	c,xline1

        ld      e,-1
	ld	a,h
	cpl
	inc	a
	ld	h,a
xline1:
	ld	a,e
        ld      [deldy],a

; find [x2-x1]

        ld      a,[x1]
	ld	b,a
        ld      a,[x2]
	sub	b
	ld	l,a
        cp      $80
	jr	c,xline2

        ld      d,-1
	ld	a,l
	cpl
	inc	a
	ld	l,a
xline2:
	ld	a,d
        ld      [deldx],a

; sort [y2-y1] and [x2-x1]

	ld	a,l
	cp	h
        jr      nc,xline3

        ld      d,0

	ld	l,h	;exchange h & l
	ld	h,a
	jr	xline4

xline3:
        ld      e,0

; store dels, delp, delsx, and delsy

xline4:
	ld	a,l
        ld      [dels],a
	ld	a,h
        ld      [delp],a
	ld	a,d
        ld      [delsx],a
	ld	a,e
        ld      [delsy],a

        ld      a,[x1]
	ld	b,a
        ld      a,[y1]
	ld	c,a

; compute initial and inc for error function

        ld      a,[delp]
	add	a,a		; a = a * 2
        ld      [delse],a

	sub	l
	ld	e,a		; bx
	ld	d,0

	sub	l
        ld      [delde],a

; adjust count

	inc	l	; cx

xline5:
;	cmp	si,[scrnx]
;	jnc	xline6
;	cmp	di,[scrny]
;	jnc	xline6

	push	bc
	push	de
	push	hl
	call	point
	pop	hl
	pop	de
	pop	bc

;xline6:
	ld	a,d
        cp      $80
	jr	c,xline7

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
	ld	a,0
	adc	a,d
	ld	d,a

	dec	l
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
;        ccf
        ld      a,$ff
        adc     a,d
	ld	d,a

	dec	l
	jr	nz,xline5

	ret

