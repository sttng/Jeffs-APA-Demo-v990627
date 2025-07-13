; Low Precision triangles:
;  Black/White -
;   Size: X= 120,   Y= 100    ~77 triangles/sec  (? tri/sec 8x8 tex, ? for pattrn tex)
;   Size: X= 0-128, Y= 0-128  ~? triangles/sec (? tri/sec 8x8 textured)
;   Size: X= 0-63,  Y= 0-63   ~? triangles/sec (? tri/sec 8x8 textured)
;   Size: X= 9,     Y= 9      ~? triangles/sec
;
;  Grey Scale
;   Size: X= 120,   Y= 100    ~75 triangles/sec  (? tri/sec 8x8 tex, ? for pattrn tex)
;   Size: X= 0-128, Y= 0-128  ~? triangles/sec (? tri/sec 8x8 textured)
;   Size: X= 0-63,  Y= 0-63   ~? triangles/sec (? tri/sec 8x8 textured)
;   Size: X= 9,     Y= 9      ~? triangles/sec

DisplayWhiteEdgeBuf:

; Search for start of tri

        ld      hl,EdgeBuf
        ld      c,-1
.start2:
        ld      a,[hl+]
        inc     hl
        inc     c
        inc     a
        jr      z,.start2

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
        cpl
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
        cpl
        ld      c,a

;.....


; Figure out if start & end pixel locations on this
; line share the same memory address.

        ld      a,h
        sub     d

        or      a               ; Same address?
        jr      z,.sameadr      ; yes

        ld      e,a

 if RENDER_TO_VRAM
        di

; Plot End of line

        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        and     c
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        and     c
 endc
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     e
        jr      z,.done

        xor     a

        bit     0,e
        jr      nz,.blitloop2

.blitloop:
        dec     h

 if RENDER_TO_VRAM
        di

; Plot middle points of line

        lcd_WaitVRAM2
        xor     a
 endc

        ld      [hl+],a
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc
        dec     e

.blitloop2:
        dec     h

 if RENDER_TO_VRAM
        di

; Plot middle points of line

        lcd_WaitVRAM2
        xor     a
 endc

        ld      [hl+],a
        ld      [hl-],a

 if RENDER_TO_VRAM
        ei
 endc

        dec     e
        jr      nz,.blitloop

.done:
; Plot first part of line

        ld      a,[LastBitPos]
        ld      b,a

        dec     h

        jr      .DoEndPixels


.sameadr:
        ld      a,[LastBitPos]
        cpl
        and     b
        cpl
        ld      b,a

.DoEndPixels:

 if RENDER_TO_VRAM
        di

        lcd_WaitVRAM2
 endc

        ld      a,[hl]
        and     b
        ld      [hl+],a

 if GREY_SCALE
        ld      a,[hl]
        and     b
 endc
        ld      [hl],a

 if RENDER_TO_VRAM
       ei
 endc

; Move Y addr offset down one line

        inc     l

        pop     de

        ld      a,[de]
        inc     a               ; Is there another line to render?
 if RENDER_TO_VRAM
        jp      nz,.mainl2      ; yes
 else
        jr      nz,.mainl2      ; yes
 endc

        ret