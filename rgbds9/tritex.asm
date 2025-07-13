; Low Precision triangles:
;  Black/White -
;   Size: X= 120,   Y= 100    ~65 triangles/sec
;   Size: X= 0-128, Y= 0-128  ~? triangles/sec
;   Size: X= 0-63,  Y= 0-63   ~? triangles/sec
;   Size: X= 9,     Y= 9      ~? triangles/sec
;
;  Grey Scale
;   Size: X= 120,   Y= 100    ~60 triangles/sec
;   Size: X= 0-128, Y= 0-128  ~? triangles/sec
;   Size: X= 0-63,  Y= 0-63   ~? triangles/sec
;   Size: X= 9,     Y= 9      ~? triangles/sec

SetTextureAddress:
        ld      [TexOffset],a
        ret

DisplayTexturedEdgeBuf:

; Search for start of tri

        ld      hl,EdgeBuf
        ld      c,-1
.start2:
        ld      a,[hl+]
        inc     hl
        inc     c
        inc     a
        jr      z,.start2

        ld      b,b

        dec     hl
        dec     hl

; Render all lines of the tri

        ld      d,h
        ld      e,l

        ld      l,c
        sla     l               ; l = Y address

.mainl2:
        ld      a,[de]
        inc     de
        ld      h,a             ; h = minimum X

        ld      a,[de]
        inc     de
        ld      b,a
;        ld      [maxX],a

        push    de

;.....
; Get start address offset

        ld      a,h
        srl     h
 if RENDER_TO_VRAM
        or      a               ; clear carry
 else
        scf                     ; set carry
 endc
        rr      h
        scf
        rr      h               ; start addr = $c000 + f(x)

; Get bit positions

        and     7               ; b = Bitmask[b & 7]
        ld      e,a
        ld      d,LEFT_LINE_MASK_ADDR/256
        ld      a,[de]
        ld      [LastBitPos],a

;.....

        ld      d,h

;.....
; Get end address offset

        ld      a,b     ;[maxX]
        ld      h,a
        srl     h
 if RENDER_TO_VRAM
        or      a               ; clear carry
 else
        scf                     ; set carry
 endc
        rr      h
        scf
        rr      h               ; end addr = $c000 + f(x)

        and     7
        ld      c,a
        ld      b,RIGHT_LINE_MASK_ADDR/256
        ld      a,[bc]
        ld      b,a             ; b = Bitmask[a & 7]

;.....


; Figure out if start & end pixel locations on this
; line share the same memory address.

        ld      a,h
        sub     d

        or      a               ; Same address?
        jr      z,.sameadr      ; yes

        ld      [delse],a

        ld      d,b

        ld      a,[TexOffset]
        ld      b,a
        ld      c,l

        ld      a,[bc]
        and     d
        ld      e,a

        ld      a,[bc]
        cpl
        and     d
        cpl

        and     [hl]
        or      e
        ld      [hl+],a

 if GREY_SCALE
        inc     bc

        ld      a,[bc]
        and     d
        ld      e,a

        ld      a,[bc]
        cpl
        and     d
        cpl

        and     [hl]
        or      e
 endc
        ld      [hl-],a

        ld      a,[delse]

        dec     a
        jr      z,.done

        ld      e,a

        ld      a,[TexOffset]
        ld      b,a
        ld      c,l

        bit     0,e             ; Is count odd?
        jr      nz,.blitloop2   ; yes

.blitloop:
        dec     h

; Get & write 2 texture bytes

        ld      a,[bc]
        ld      [hl+],a
 if GREY_SCALE
        inc     c
        ld      a,[bc]
        dec     c
 endc
        ld      [hl-],a

        dec     e

.blitloop2:
        dec     h

; Get & write 2 texture bytes

        ld      a,[bc]
        ld      [hl+],a
 if GREY_SCALE
        inc     c
        ld      a,[bc]
        dec     c
 endc
        ld      [hl-],a

        dec     e
        jr      nz,.blitloop

.done:
; Plot first part of line
        dec     h

        ld      a,[LastBitPos]

        jr      .sameadr2

.sameadr:
        ld      a,[LastBitPos]
        and     b

.sameadr2:
        ld      d,a

        ld      a,[TexOffset]
        ld      b,a
        ld      c,l

        ld      a,[bc]
        and     d
        ld      e,a

        ld      a,[bc]
        cpl
        and     d
        cpl

        and     [hl]
        or      e
        ld      [hl+],a

 if GREY_SCALE
        inc     bc

        ld      a,[bc]
        and     d
        ld      e,a

        ld      a,[bc]
        cpl
        and     d
        cpl

        and     [hl]
        or      e
 endc
        ld      [hl],a

; Move Y addr offset down one line

        inc     l

        pop     de

        ld      a,[de]
        inc     a               ; Is there another line to render?

        jp      nz,.mainl2      ; yes

        ret