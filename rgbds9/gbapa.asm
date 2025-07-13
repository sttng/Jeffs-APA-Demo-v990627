; GBAPA V1.1
;  by Jeff Frohwein
;
; first edit: Nov 8th, 1995
; last edit: hell, who knows.
;


; ==========================================================================
; Updated to compile with rgbds v0.9.3 by sttng
; Jul 13th, 2025
; ==========================================================================


SECTION "Start", ROM0[$0100]
    jp start       ; Jump past the header space to our actual code

    ds $150-@, 0        ; Allocate space for RGBFIX to insert our ROM header by allocating
                        ;  the number of bytes from our current location (@) to the end of the
                        ;  header ($150)

start:			; This is addr $0150
 di
 ld	sp, $fff4	; Put the stack where the GB wants it

 ld	a,0		; No IRQs at all
 ldh	[$FFFF],a

 sub	a		; Misc standard init things..
 ldh	[$FF41],a		; LCDC Status
 ldh	[$FF42],a		; Screen scroll Y=0
 ldh	[$FF43],a		; Screen scroll X=0

 call	waitvbl		; Must be in VBL before turning the screen off.

 ld	a, %00010001	; LCD Controller = Off (No picture on screen)
			; WindowBank = $9800 (Not used)
			; Window = OFF
			; BG Chr = $8000
			; BG Bank= $9800
			; OBJ    = 8x8
			; OBJ    = Off
			; BG     = On
 ldh	[$FF40],a

 call	nor_col		; Normal palette
 call 	move_char	; Move the charset to $8000
 call	move_text	; Move the text to $9800


 ld	a, %10010001	; LCD Controller = On
 ldh	[$FF40],a


	ld	a,0
	ld	[y1],a
	ld	a,119
	ld	[y2],a
luper0:
	ld	a,3
	ld	[color],a

	ld	b,128
	ld	c,127
luper1:
	push	bc
	dec	b
	ld	a,b
	ld	[x1],a
	ld	a,c
	sub	b
	ld	[x2],a

	call	line
	pop	bc
	dec	b
	jr	nz,luper1

	ld	a,0
	ld	[x1],a
	ld	a,127
	ld	[x2],a

	ld	a,2
	ld	[color],a

	ld	b,120
	ld	c,119
luper2:
	push	bc
	dec	b
	ld	a,b
	ld	[y2],a
	ld	a,c
	sub	b
	ld	[y1],a

	call	line
	pop	bc
	dec	b
	jr	nz,luper2

	ld	a,0
	ld	[y1],a
	ld	a,119
	ld	[y2],a

	ld	a,3
	ld	[color],a

	ld	b,128
	ld	c,127
luper3:
	push	bc
	dec	b
	ld	a,b
	ld	[x1],a
	ld	[x2],a

	call	line
	pop	bc
	dec	b
	jr	nz,luper3

	jp	luper0

; * Draw a line from X1,Y1 to X2,Y2 *

line:
	ld	d,1	; si
	ld	e,1	; di

; find [y2-y1]

	ld	a,[y1]
	ld	b,a
	ld	a,[y2]
	sub	b
	ld	h,a
	cp	$80
	jr	c,xline1

	ld	e,255
	ld	a,h
	cpl
	inc	a
	ld	h,a
xline1:
	ld	a,e
	ld	[deldy],a

; find [x2-x1]

	ld	a,[x1]
	ld	b,a
	ld	a,[x2]
	sub	b
	ld	l,a
	cp	$80
	jr	c,xline2

	ld	d,255
	ld	a,l
	cpl
	inc	a
	ld	l,a
xline2:
	ld	a,d
	ld	[deldx],a

; sort [y2-y1] and [x2-x1]

	ld	a,l
	cp	h
	jr	nc,xline3

	ld	d,0
	
	ld	l,h	;exchange h & l
	ld	h,a
	jr	xline4

xline3:
	ld	e,0

; store dels, delp, delsx, and delsy

xline4:
	ld	a,l
	ld	[dels],a
	ld	a,h
	ld	[delp],a
	ld	a,d
	ld	[delsx],a
	ld	a,e
	ld	[delsy],a

	ld	a,[x1]
	ld	b,a
	ld	a,[y1]
	ld	c,a

; compute initial and inc for error function

	ld	a,[delp]
	add	a,a		; a = a * 2
	ld	[delse],a

	sub	l
	ld	e,a		; bx
	ld	d,0

	sub	l
	ld	[delde],a

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
	cp	$80
	jr	c,xline7

; case for straight move

	ld	a,[delsx]
	add	a,b
	ld	b,a

	ld	a,[delsy]
	add	a,c
	ld	c,a

	ld	a,[delse]
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
	ld	a,[deldx]
	add	a,b
	ld	b,a

	ld	a,[deldy]
	add	a,c
	ld	c,a

	ld	a,[delde]
	add	a,e
	ld	e,a
	ld	a,$ff
	adc	a,d
	ld	d,a

	dec	l
	jr	nz,xline5

	ret

; * Xor a point at B,C *

point:

 ld	a,c
 srl	a
 srl	a
 srl	a
 add	a,$80
 ld	h,a	; h = (y div 8) + 80h

 ld	a,b
 srl	a
 srl	a
 srl	a
 rlc	a
 rlc	a
 rlc	a
 rlc	a
 ld	l,a	; l = (x div 8) * 16

 ld	a,c
 and	7
 add	a,a
 add	a,l
 ld	l,a	; l = l + ((y mod 8) * 2) 

 ld	a,0
 adc	a,h
 ld	h,a	; if addition had a carry add to h

;hl = 8000h + int(y/8)*256 + (y modulus 8)*2 + int(x/8)*16

 ld	a,b
 inc	a
 and	7
 ld	b,a

 ld	a,1

point1:
 rrc	a
 dec	b
 jp	nz,point1

 ld	b,a

 ld	a,[color]
 and	1
 jr	z,point5

point4:
 ldh	a,[$FF41]
 and	2
 jp	nz,point4


 ld	a,[hl]
 xor	b
 ldi	[hl],a

point5:
 ld	a,[color]
 and	2
 jr	z,point7

point6:
 ldh	a,[$FF41]
 and	2
 jp	nz,point6

 ld	a,[hl]
 xor	b
 ldi	[hl],a

point7:

 ret


fill:

chnuloop:
 ldh	a,[$FF41]
 and	2
 jp	nz,chnuloop

 ld	[hl],b
 inc	hl

chnuloop2:
 ldh	a,[$FF41]
 and	2
 jp	nz,chnuloop2

 ld	[hl],b
 inc	hl
 ret


waitvbl:		; Wait for VBL
 ldh	a,[$FF40]
 add	a,a
 ret	nc

notyet:
 ldh	a,[$FF44]		; $ff44=LCDC Y-Pos
 cp	$90		; $90 and bigger = in VBL
 jr	nz,notyet	; Loop until it $90
 ret

white:			; All colors to transparent
 ld	a,0
 ldh	[$FF47],a
 ret

black:			; All colors to black
 ld	a,$ff
 ldh	[$FF47],a
 ret

nor_col:		; Sets the colors to normal palette
 ld	a,%11100100	; grey 3=11 (Black)
			; grey 2=10 (Dark grey)
			; grey 1=01 (Light grey)
			; grey 0=00 (Transparent)
 ldh	[$FF47],a
 ret

; * Initialize the Character Set *
cls:
move_char:
 ld	hl,$8000
 ld	d,0		; Like move 1024 bytes man
 ld	e,8		; x2=2048

lp1:
 xor	a		; A = 0
 ldi	[hl],a
 ldi	[hl],a
 dec	d
 jp	nz,lp1
 dec	e
 jp	nz,lp1

 ld	bc, charset
 ld	hl,$8000+($0f0*16)
 ld	d,64

lp2:
 ld	a,[bc]
 ldi	[hl],a
 ldi	[hl],a
 inc	bc
 dec	d
 jp	nz,lp2

 ret

move_text:
 ld	bc,the_text
mve:
 ld	hl, $9800
 ld	d,0
 ld	e,4		; 256*4=1024=32x32=One whole GB Screen

wloop1:
 ld	a,[bc]
 ldi	[hl],a
hole1:
 ldh	a,[$FF41]
 and	2
 jp	nz,hole1

 inc	bc
 dec	d
 jp	nz,wloop1
 dec	e
 jp	nz,wloop1

 ret

; * ex de,hl *

exdehl:	push	af
	ld	a,d		;save address
	ld	d,h
	ld	h,a
	ld	a,e
	ld	e,l
	ld	l,a
	pop	af
	ret

charset:
 db 0,0,0, $1f,16,16,16,16			; upper left of box
 db 0,0,0, $ff,0,0,0,0			; upper middle of box
 db 0,0,0, $f8,8,8,8,8			; upper right of box
 db 16,16,16,16,16,16,16,16			; left middle of box
 db 8,8,8,8,8,8,8,8				; right middle of box
 db $10, $10, $10, $10, $1f,0,0,0		; lower left of box
 db 0,0,0,0,$ff,0,0,0			; lower middle of box
 db 8,8,8,8,$f8,0,0,0			; lower right of box

the_text:
db	255, $f0,$f1,$f1,$f1,$f1,$f1,$f1
db	$f1,$f1,$f1,$f1,$f1,$f1,$f1
db	$f1,$f1,$f1,$f2,255
db	"            "
db	255,$f3, $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
db	$0f4,255
db	"            "
db	255,$f3,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
db	$f4,255
db	"            "
db	255,$f3,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
db	$f4,255
db	"            "
db	255,$f3,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
db	$f4,255
db	"            "
db	255,$f3,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
db	$f4,255
db	"            "
db	255,$f3,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
db	$f4,255
db	"            "
db	255,$f3,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
db	$f4,255
db	"            "
db	255,$f3,$70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
db	$f4,255
db	"            "
db	255,$f3,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
db	$f4,255
db	"            "
db	255,$f3,$90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9a,$9b,$9c,$9d,$9e,$9f
db	$f4,255
db	"            "
db	255,$f3,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7
db	$a8,$a9,$aa,$ab,$ac,$ad,$ae,$af
db	$f4,255
db	"            "
db	255,$f3,$b0,$b1,$b2,$b3,$b4,$b5,$b6,$b7
db	$b8,$b9,$ba,$bb,$bc,$bd,$be,$bf
db	$f4,255
db	"            "
db	255,$f3,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$0c7
db	$c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
db	$f4,255
db	"            "
db	255,$f3,$d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7
db	$d8,$d9,$da,$db,$dc,$dd,$de,$df
db	$f4,255
db	"            "
db	255,$f3,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
db	$e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef
db	$f4,255
db	"            "
db	255,$f5,$f6,$f6,$f6,$f6,$f6,$f6
db	$f6,$f6,$f6,$f6,$f6,$f6,$f6,$f6
db	$f6,$f6,$f7,255
db	"            "
db	255,255,255,255,255,255,255,255,255,255
db	255,255,255,255,255,255,255,255
db	255,255
db	"            "
.end



SECTION "Variables", WRAM0

x1:	db	
x2:	db	
y1:	db	
y2: db	
dels: db	
delp: db	
delse: db	
delsx: db	
delsy: db	
delde: db	
deldx: db	
deldy: db	
color: db	
