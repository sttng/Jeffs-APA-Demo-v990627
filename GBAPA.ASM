; GBAPA V1.1
;  by Jeff Frohwein
;
; first edit: Nov 8th, 1995
; last edit: hell, who knows.
;

bs	.equ	8
cr	.equ	13

x1	.equ	$c000
x2	.equ	$c001
y1	.equ	$c002
y2	.equ	$c003
dels	.equ	$c004
delp	.equ	$c005
delse	.equ	$c006
delsx	.equ	$c007
delsy	.equ	$c008
delde	.equ	$c009
deldx	.equ	$c00a
deldy	.equ	$c00b
color	.equ	$c00c

.org 0

; Set all irq vectors to do nothing.

.org 40h		; VBlank IRQ
 reti			; Do nothing
.org 46h
 .word	ctable		; Character Table Data
.org 48h		; LCDC Status IRQ
 reti			; Do nothing
.org 50h		; Timer Owerflow
 reti			; Do nothing
.org $0058		; Serial Transfer Completion
 reti			; Do nothing
.org $0060		; Hmm, this is a wierd one.
			; I'm not sure how this one works
			; Transition from high to low
			; of pin p10-p13
			; I think Its a hardware thing
 reti			; Do nothing :)
; Irqs done..

ctable:
	.byte	"GBCI"	;GameBoy Configuration Info

	.word	0	;address of character info
	 .byte	 0
	.word	0	;address of configuration info
	 .byte	 0
	.word	0	;reserved (leave zero)
	 .byte	 0
	.word	0	;reserved (leave zero)
	 .byte	 0
	.word	0	;reserved (leave zero)
	 .byte	 0
	.word	0	;reserved (leave zero)
	 .byte	 0


; GameBoy Header with correct checksum
; Done 95-08-13 by HZ/DiESEL
; Do not use this one.. Make your own.

 .org 100h

.byte $00,$C3,$50,$01

.byte $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83
.byte $00,$0C,$00,$0D,$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6
.byte $DD,$DD,$D9,$99,$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F

.byte $BB,$B9,$33,$3E	; Standard Nintendo DO NOT CHANGE...

.byte "HEROZERO SAMPLE1"	; Cart name   16bytes
.byte 0,0,0			; Not used
.byte 0				; Cart type   ROM Only
.byte 0				; ROM Size    32k
.byte 0				; RAM Size     0k
.byte 0deh,0adh			; Maker ID    $dead=DiESEL Soft
.byte 1				; Version     =1
.byte 0dah			; Complement check (Important)
.byte 0ffh,0ffh			; Cheksum (Who cares)


start:			; This is addr $0150
 di
 ld	sp,0fff4h	; Put the stack where the GB wants it

 ld	a,0		; No IRQs at all
 ldh	(0ffh),a

 sub	a		; Misc standard init things..
 ldh	(41h),a		; LCDC Status
 ldh	(42h),a		; Screen scroll Y=0
 ldh	(43h),a		; Screen scroll X=0

 call	waitvbl		; Must be in VBL before turning the screen off.

 ld	a,00010001b	; LCD Controller = Off (No picture on screen)
			; WindowBank = $9800 (Not used)
			; Window = OFF
			; BG Chr = $8000
			; BG Bank= $9800
			; OBJ    = 8x8
			; OBJ    = Off
			; BG     = On
 ldh	(40h),a

 call	nor_col		; Normal palette
 call 	move_char	; Move the charset to $8000
 call	move_text	; Move the text to $9800


 ld	a,10010001b	; LCD Controller = On
 ldh	(40h),a


	ld	a,0
	ld	(y1),a
	ld	a,119
	ld	(y2),a
luper0:
	ld	a,3
	ld	(color),a

	ld	b,128
	ld	c,127
luper1:
	push	bc
	dec	b
	ld	a,b
	ld	(x1),a
	ld	a,c
	sub	b
	ld	(x2),a

	call	line
	pop	bc
	dec	b
	jr	nz,luper1

	ld	a,0
	ld	(x1),a
	ld	a,127
	ld	(x2),a

	ld	a,2
	ld	(color),a

	ld	b,120
	ld	c,119
luper2:
	push	bc
	dec	b
	ld	a,b
	ld	(y2),a
	ld	a,c
	sub	b
	ld	(y1),a

	call	line
	pop	bc
	dec	b
	jr	nz,luper2

	ld	a,0
	ld	(y1),a
	ld	a,119
	ld	(y2),a

	ld	a,3
	ld	(color),a

	ld	b,128
	ld	c,127
luper3:
	push	bc
	dec	b
	ld	a,b
	ld	(x1),a
	ld	(x2),a

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

	ld	a,(y1)
	ld	b,a
	ld	a,(y2)
	sub	b
	ld	h,a
	cp	80h
	jr	c,xline1

	ld	e,255
	ld	a,h
	cpl
	inc	a
	ld	h,a
xline1:
	ld	a,e
	ld	(deldy),a

; find [x2-x1]

	ld	a,(x1)
	ld	b,a
	ld	a,(x2)
	sub	b
	ld	l,a
	cp	80h
	jr	c,xline2

	ld	d,255
	ld	a,l
	cpl
	inc	a
	ld	l,a
xline2:
	ld	a,d
	ld	(deldx),a

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
	ld	(dels),a
	ld	a,h
	ld	(delp),a
	ld	a,d
	ld	(delsx),a
	ld	a,e
	ld	(delsy),a

	ld	a,(x1)
	ld	b,a
	ld	a,(y1)
	ld	c,a

; compute initial and inc for error function

	ld	a,(delp)
	add	a,a		; a = a * 2
	ld	(delse),a

	sub	l
	ld	e,a		; bx
	ld	d,0

	sub	l
	ld	(delde),a

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
	cp	80h
	jr	c,xline7

; case for straight move

	ld	a,(delsx)
	add	a,b
	ld	b,a

	ld	a,(delsy)
	add	a,c
	ld	c,a

	ld	a,(delse)
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
	ld	a,(deldx)
	add	a,b
	ld	b,a

	ld	a,(deldy)
	add	a,c
	ld	c,a

	ld	a,(delde)
	add	a,e
	ld	e,a
	ld	a,0ffh
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
 add	a,80h
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

 ld	a,(color)
 and	1
 jr	z,point5

point4:
 ldh	a,(41h)
 and	2
 jp	nz,point4


 ld	a,(hl)
 xor	b
 ldi	(hl),a

point5:
 ld	a,(color)
 and	2
 jr	z,point7

point6:
 ldh	a,(41h)
 and	2
 jp	nz,point6

 ld	a,(hl)
 xor	b
 ldi	(hl),a

point7:

 ret


fill:

chnuloop:
 ldh	a,(41h)
 and	2
 jp	nz,chnuloop

 ld	(hl),b
 inc	hl

chnuloop2:
 ldh	a,(41h)
 and	2
 jp	nz,chnuloop2

 ld	(hl),b
 inc	hl
 ret


waitvbl:		; Wait for VBL
 ldh	a,(40h)
 add	a,a
 ret	nc

notyet:
 ldh	a,(44h)		; $ff44=LCDC Y-Pos
 cp	90h		; $90 and bigger = in VBL
 jr	nz,notyet	; Loop until it $90
 ret

white:			; All colors to transparent
 ld	a,0
 ldh	(47h),a
 ret

black			; All colors to black
 ld	a,0ffh
 ldh	($47),a
 ret

nor_col:		; Sets the colors to normal palette
 ld	a,11100100b	; grey 3=11 (Black)
			; grey 2=10 (Dark grey)
			; grey 1=01 (Light grey)
			; grey 0=00 (Transparent)
 ldh	(47h),a
 ret

: * Initialize the Character Set *
cls:
move_char:
 ld	hl,8000h
 ld	d,0		; Like move 1024 bytes man
 ld	e,8		; x2=2048

lp1:
 xor	a		; A = 0
 ldi	(hl),a
 ldi	(hl),a
 dec	d
 jp	nz,lp1
 dec	e
 jp	nz,lp1

 ld	bc,(charset)
 ld	hl,8000h+(0f0h*16)
 ld	d,64

lp2:
 ld	a,(bc)
 ldi	(hl),a
 ldi	(hl),a
 inc	bc
 dec	d
 jp	nz,lp2

 ret

move_text:
 ld	bc,the_text
mve:
 ld	hl,9800h
 ld	d,0
 ld	e,4		; 256*4=1024=32x32=One whole GB Screen

wloop1:
 ld	a,(bc)
 ldi	(hl),a
hole1:
 ldh	a,(41h)
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
 .byte 0,0,0,01fh,16,16,16,16			; upper left of box
 .byte 0,0,0,0ffh,0,0,0,0			; upper middle of box
 .byte 0,0,0,0f8h,8,8,8,8			; upper right of box
 .byte 16,16,16,16,16,16,16,16			; left middle of box
 .byte 8,8,8,8,8,8,8,8				; right middle of box
 .byte 10h,10h,10h,10h,01fh,0,0,0		; lower left of box
 .byte 0,0,0,0,0ffh,0,0,0			; lower middle of box
 .byte 8,8,8,8,0f8h,0,0,0			; lower right of box

the_text:
.byte	255,0f0h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
.byte	0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
.byte	0f1h,0f1h,0f1h,0f2h,255
.byte	"            "
.byte	255,0f3h,00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0ah,0bh,0ch,0dh,0eh,0fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,10h,11h,12h,13h,14h,15h,16h,17h,18h,19h,1ah,1bh,1ch,1dh,1eh,1fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2ah,2bh,2ch,2dh,2eh,2fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4ah,4bh,4ch,4dh,4eh,4fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5ah,5bh,5ch,5dh,5eh,5fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6ah,6bh,6ch,6dh,6eh,6fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7ah,7bh,7ch,7dh,7eh,7fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,80h,81h,82h,83h,84h,85h,86h,87h,88h,89h,8ah,8bh,8ch,8dh,8eh,8fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,90h,91h,92h,93h,94h,95h,96h,97h,98h,99h,9ah,9bh,9ch,9dh,9eh,9fh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,0a0h,0a1h,0a2h,0a3h,0a4h,0a5h,0a6h,0a7h
.byte	0a8h,0a9h,0aah,0abh,0ach,0adh,0aeh,0afh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,0b0h,0b1h,0b2h,0b3h,0b4h,0b5h,0b6h,0b7h
.byte	0b8h,0b9h,0bah,0bbh,0bch,0bdh,0beh,0bfh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,0c0h,0c1h,0c2h,0c3h,0c4h,0c5h,0c6h,0c7h
.byte	0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh,0cfh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,0d0h,0d1h,0d2h,0d3h,0d4h,0d5h,0d6h,0d7h
.byte	0d8h,0d9h,0dah,0dbh,0dch,0ddh,0deh,0dfh
.byte	0f4h,255
.byte	"            "
.byte	255,0f3h,0e0h,0e1h,0e2h,0e3h,0e4h,0e5h,0e6h,0e7h
.byte	0e8h,0e9h,0eah,0ebh,0ech,0edh,0eeh,0efh
.byte	0f4h,255
.byte	"            "
.byte	255,0f5h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h
.byte	0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h
.byte	0f6h,0f6h,0f7h,255
.byte	"            "
.byte	255,255,255,255,255,255,255,255,255,255
.byte	255,255,255,255,255,255,255,255
.byte	255,255
.byte	"            "

.end
