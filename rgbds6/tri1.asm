
; *
; * Triangle render code for GB/GBC
; * by Jeff Frohwein
; * last edit 14-Jun-99
; *
; * Written with RGBDS
; *

HIGH_TRI_PREC equ     0       ; 0 = low precision triangles, 1 = high precision


; High Precision triangles:
;
;   Size: X= 120,   Y= 100    ~ triangles/sec
;   Size: X= 0-128, Y= 0-128  ~ triangles/sec
;   Size: X= 0-63,  Y= 0-63   ~ triangles/sec
;   Size: X= 9,     Y= 9      ~ triangles/sec
;
; Low Precision triangles:
;
;   Size: X= 120,   Y= 100    ~75 triangles/sec  (60 tri/sec 8x8 tex, 54 for pattrn tex)
;   Size: X= 0-128, Y= 0-128  ~107 triangles/sec (87 tri/sec 8x8 textured)
;   Size: X= 0-63,  Y= 0-63   ~256 triangles/sec (155 tri/sec 8x8 textured)
;   Size: X= 9,     Y= 9      ~535 triangles/sec
;
;  When low precision angle calculations on the edges
; of triangles are done, the error is often not
; noticeable on most triangles. If the angle
; should drop by 1 pixel over a 120 pixel wide
; edge, the drop may not occur. Unless you
; specifically require higher precision, low
; precision should be suitable for most things.
;
;  The key to drawing fast triangles is drawing
; 3 lines (representing the edges of the tri)
; into an Edge Buffer & then rendering this
; Edge Buffer to the screen. The edge buffer
; only holds the minimum X & maximum X of each
; horizontal line slice of the screen.
;
;  When rendering large triangles, 80% of the
; time is used to render the Edge Buffer to the
; screen. Of this 80%, 1/3 of this time is spent
; waiting for VRAM and the other 2/3rds is caused
; by the code speed itself.
;
;
; Here are the exact steps for rendering a triangle:
;
; 1. Sort the X,Y coordinates of each corner of the
;     triangle. Sort by Y coordinate. (This is required
;     by the line drawing code which only draws lines
;     from top to bottom for speed.)
;
; 2. Clear each line of edge buffer to minX=255, maxX=0.
;
; 3. Draw 3 lines into the Edge Buffer. If The pixels you
;     draw to the Edge Buffer (for any given Y line)
;     have a X value that is lower than minX or greater
;     then maxX, then they replace the respective values.
;     (Below is a picture of what the Edge buffer might
;     look like after rendering into it.)
;
; 4. Render Edge buffer to the screen.

; An example Edge buffer after step 3 is complete:
; (You need a fixed width font to view this.)
;
; 255,0 -
; 255,0 -
; 9,10  -        **
; 9,12  -        * **
; 8,14  -       *    **
; 8,16  -       *      **
; 7,18  -      *         **
; 7,20  -      **************
; 255,0 -
; 255,0 -

; Textured Tiles
; --------------
; This allows an 8x8 pixel texture to be used on triangle.
; In order to use 8x8 texture mode 'TextureTri' you have to
; have a 16 byte texture tile. This tile MUST be repeated
; 16 times for a total of 256 bytes. These 256 bytes MUST
; be aligned on a page. (i.e. From $xx00 - $xxff).
; The upper byte of the page is set using 'SetTextureAddress'.

; Pattern Tiles
; -------------
;  This allows a 160x144 pixel pattern to be used on a triangle.
; The pattern isn't scaled and only the portion that will
; actually fit is used. The pattern data itself is layed out
; in the same format as the screen. That would be 360 tiles,
; 20 tiles per line, and tiles layed out from top to bottom
; of screen.
;
;  If you were to draw two large pattern triangles that
; completely cover the screen then the whole 160x144 pixel
; pattern would be completely drawn to the screen. Using
; this method of pattern drawing with triangles you can
; easily fade from one screen to another by covering every
; screen location with a triangle. The order & shape of
; the triangles would determine the effects you produce
; while fading from one screen to another.
;
;  The address of the pattern is set by calling 'SetPatternAddress'
; with the pattern address in HL. You can render a portion
; of a pattern to the screen several times, in different locations,
; by changing calling 'SetPatternAddress' with different address
; offsets.
;
; NOTE: You can't have a pattern smoothly follow a triangle across
; the screen. A pattern can follow a triangle, though, if changes
; to the X coordinates of the triangle are in 8 pixel increments
; and you set the pattern offset address accordingly.
;
;  You CAN have a pattern follow a triangle smoothly up & down the
; screen as long as the triangle isn't wider than 8 pixels and all
; of those pixels are in one tile column (i.e. X: 0-7,8-15,16-23,...)


        PUSHS

SECTION "Triangle Ram",WRAM0        ;SECTION "Triangle Ram",BSS

EdgeBuf:         ds      2*144+2         ; Need 2 extra for end-of-buffer markers
EdgeLineCode:    ds      82+82+18+18
Middle:          dw

        POPS

        RSSET   TriangleHRAM

LastBitPos      RB      1
TexOffset       RB      2
tx1             RB      1
ty1             RB      1
tx2             RB      1
ty2             RB      1


; For these routines:
; Entry:
;    B = X, C = Y - Coordinates for point #1
;    D = X, E = Y - Coordinates for point #2
;    H = X, L = Y - Coordinates for point #3

XorTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayXorEdgeBuf       ; Render the edge buffer as XOR tri
        ret

WhiteTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayWhiteEdgeBuf     ; Render the edge buffer as white tri
        ret

BlackTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayBlackEdgeBuf     ; Render the edge buffer as black tri
        ret

LightTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayLightEdgeBuf     ; Render the edge buffer as light tri
        ret

DarkTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayDarkEdgeBuf     ; Render the edge buffer as dark tri
        ret

TextureTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayTexturedEdgeBuf  ; Render the edge buffer as dark tri
        ret

PatternTri:
        call    SortYCoords             ; Sort tri Y coordinates
        call    ClearEdgeBuf            ; Clear the edge buffer
        call    RenderToEdgeBuf         ; Draw 3 lines in edge buffer
        call    DisplayPatternEdgeBuf  ; Render the edge buffer as dark tri
        ret

        include "trixor.asm"
        include "triblk.asm"
        include "triwht.asm"
        include "trilite.asm"
        include "tridark.asm"
        include "tritex.asm"
        include "tripat.asm"


RenderToEdgeBuf:

        ld      a,[x1]
        ld      [tx1],a
        ld      a,[y1]
        ld      [ty1],a

        ld      a,[x2]
        ld      [tx2],a
        ld      a,[y2]
        ld      [ty2],a
        call    DoLine

        ld      a,[x3]
        ld      [tx2],a
        ld      a,[y3]
        ld      [ty2],a
        call    DoLine

        ld      a,[x2]
        ld      [tx1],a
        ld      a,[y2]
        ld      [ty1],a
        call    DoLine

        ret

DoLine:

; find [y2-y1]

        ld      a,[ty1]          ; hl = y2 - y1
        ld      l,a
        ld      a,[ty2]
        sub     l
        ld      l,a
        ld      a,0
        sbc     a,a
        ld      h,a

; find [x2-x1]

        ld      a,[tx1]          ; de = x2 - x1
        ld      e,a
        ld      a,[tx2]
        sub     e
        ld      e,a
        ld      a,0
        sbc     a,a
        ld      d,a

        rlca                    ; Is de positive ?
        jr      nc,.yline2       ; yes

        ld      a,5    ; dec b
        ld      [EdgeLineCode+(_EXPatch11-_EdgeLoop1)],a
        ld      [EdgeLineCode+(_EXPatch12-_EdgeLoop1)],a

        xor     a               ; de = -de
        sub     e
        ld      e,a
        jr      .yline2x
.yline2:

        ld      a,4    ; inc b
        ld      [EdgeLineCode+(_EXPatch11-_EdgeLoop1)],a
        ld      [EdgeLineCode+(_EXPatch12-_EdgeLoop1)],a

.yline2x:
        ld      h,e

        ld      c,0

; sort [y2-y1] and [x2-x1]

        ld      a,h
        cp      l
        jr      nc,.yline3

        ld      c,_efloop3-_EdgeLoop1-2

        ld      h,l     ;exchange h & l
        ld      l,a

.yline3:

; store dels, delp, delsx, and delsy

;yline4:
        ld      a,c
        ld      [EdgeLineCode+1],a

;        ld      a,h
;        ld      [dels],a
        ld      a,l
;        ld      [delp],a

; compute initial and inc for error function

;        ld      a,[delp]        ; delse = delp * 2
        add     a,a
        ld      c,a

 if HIGH_TRI_PREC
        ld      [EdgeLineCode+(_ESPatch11-_EdgeLoop1)+1],a        ; delse (low)
        ld      [EdgeLineCode+(_ESPatch13-_EdgeLoop1)+1],a
  endc

        ld      a,0
        rla             ; put carry in lsb of A
        ld      b,a

 if HIGH_TRI_PREC
        ld      [EdgeLineCode+(_ESPatch12-_EdgeLoop1)+1],a        ; delse (high)
        ld      [EdgeLineCode+(_ESPatch14-_EdgeLoop1)+1],a
 endc

        ld      a,c             ; de = (delp * 2) - dels
        sub     h
        ld      e,a
        ld      a,b
        sbc     0
        ld      d,a

 if HIGH_TRI_PREC
 else
        push    de
 endc

        ld      a,e             ; delde = (delp * 2) - (dels * 2)
        sub     h

 if HIGH_TRI_PREC
        ld      [EdgeLineCode+(_EDPatch11-_EdgeLoop1)+1],a        ; delde (low)
        ld      [EdgeLineCode+(_EDPatch13-_EdgeLoop1)+1],a
 else
        ld      e,a
 endc

        ld      a,d
        sbc     0

 if HIGH_TRI_PREC
        ld      [EdgeLineCode+(_EDPatch12-_EdgeLoop1)+1],a        ; delde (high)
        ld      [EdgeLineCode+(_EDPatch14-_EdgeLoop1)+1],a
 else
        ld      d,a

        sra     d
        rr      e
        sra     d
        rr      e       ; de = delde / 4

        ld      a,e
        ld      [EdgeLineCode+(_EDPatch11-_EdgeLoop1)+1],a        ; delde (low)
        ld      [EdgeLineCode+(_EDPatch13-_EdgeLoop1)+1],a

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
        ld      [EdgeLineCode+(_ESPatch11-_EdgeLoop1)+1],a        ; delse (low)
        ld      [EdgeLineCode+(_ESPatch13-_EdgeLoop1)+1],a
 endc

        push    de

; adjust count

        inc     h
        ld      c,h             ; c = total pixel count

        ld      a,[ty1]
        ld      l,a
        ld      h,0
        add     hl,hl

        ld      de,EdgeBuf
        add     hl,de


        ld      a,[tx1]
	ld	b,a

        pop     de

        jp      EdgeLineCode

_EdgeLoop1:
        jr      .floop1

; *** "Line is wider than tall" code ***

.floop1:

 if HIGH_TRI_PREC
 else
_ESPatch11:
        ld      d,0     ;[delse]
 endc

_efloop2:
; b = X

        ld      a,b
        cp      [hl]             ; Is X < min in edge buffer ?
        jr      nc,.skip2        ; no

        ld      [hl],a

.skip2:
        inc     hl
        ld      a,[hl]
        cp      b               ; Is X > max in edge buffer ?
        jr      nc,.skip3       ; no

        ld      [hl],b
.skip3:
        dec     hl
;.skip4:

; Increment right

_EXPatch11:
        inc     b

 if HIGH_TRI_PREC
        bit     7,d
 else
        bit     7,e
 endc

        jr      nz,_eskip10

; Increment down

        inc     hl
        inc     hl

_EDPatch11:
        ld      a,0     ;[delde]
        add     a,e
	ld	e,a

 if HIGH_TRI_PREC
_EDPatch12:
        ld      a,0     ;[delde+1]
        adc     a,d
        ld      d,a
 endc

        dec     c
        jr      nz,_efloop2

        ret

_eskip10:

 if HIGH_TRI_PREC
_ESPatch11:
        ld      a,0     ;[delse]
 else
        ld      a,d
 endc
        add     a,e
	ld	e,a

 if HIGH_TRI_PREC
_ESPatch12:
        ld      a,0     ;[delse+1]
        adc     a,d
        ld      d,a
 endc

        dec     c
        jr      nz,_efloop2

        ret

; *** "Line is taller than wide" code ***

_efloop3:

 if HIGH_TRI_PREC
 else
_ESPatch13:
        ld      d,0     ;[delse]
 endc

_efloop4:
; b = X

        ld      a,b
        cp      [hl]             ; Is X < min in edge buffer ?
        jr      nc,.skip12       ; no

        ld      [hl],a

.skip12:
        inc     hl
        ld      a,[hl]
        cp      b               ; Is X > max in edge buffer ?
        jr      nc,.skip14      ; yes

        ld      [hl],b

.skip14:
        inc     hl

 if HIGH_TRI_PREC
        bit     7,d
 else
        bit     7,e
 endc

        jr      nz,_eskip11

; Increment right

_EXPatch12:
        inc     b

_EDPatch13:
        ld      a,0     ;[delde]
        add     a,e
	ld	e,a

 if HIGH_TRI_PREC
_EDPatch14:
        ld      a,0     ;[delde+1]
        adc     a,d
        ld      d,a
 endc

        dec     c
        jr      nz,_efloop4

        ret

_eskip11:

 if HIGH_TRI_PREC
_ESPatch13:
        ld      a,0     ;[delse]
 else
        ld      a,d
 endc
        add     a,e
	ld	e,a

 if HIGH_TRI_PREC
_ESPatch14:
        ld      a,0     ;[delse+1]
        adc     a,d
        ld      d,a
 endc
        dec     c
        jr      nz,_efloop4

        ret
_EdgeLoop3:


        ret

InstallEdgeLineCode:

; Copy line drawing code to RAM

        ld      hl,_EdgeLoop1
        ld      de,EdgeLineCode
        ld      bc,_EdgeLoop3-_EdgeLoop1
        call    mem_Copy

        ret

; bc = X,Y
; de = X,Y
; hl = X,Y

; Make Y coords C =< E  =< L

SortYCoords:
        ld      a,e
        cp      c
        jr      nc,.noswapbcde

        ld      e,c
        ld      c,a

        ld      a,d
        ld      d,b
        ld      b,a
.noswapbcde:

        ld      a,l
        cp      e
        jr      nc,.noswapdehl

        ld      l,e
        ld      e,a

        ld      a,d
        ld      d,h
        ld      h,a
.noswapdehl:

        ld      a,e
        cp      c
        jr      nc,.noswapbcde2

        ld      e,c
        ld      c,a

        ld      a,d
        ld      d,b
        ld      b,a
.noswapbcde2:

        ld      a,c
        ld      [y1],a

        ld      c,$90
        ld      a,b
        ld      [c],a
        inc     c
        inc     c
        ld      a,d
        ld      [c],a
        inc     c

        ld      a,e
        ld      [c],a
        inc     c

        ld      a,h
        ld      [c],a
        inc     c

        ld      a,l
        ld      [c],a
        ret


; *** Clear edge buffer ***

ClearEdgeBuf:
        di
        ld      hl, sp+0        ;ld      hl, [sp+0]

        ld      sp,EdgeBuf+(2*144)+2 ;-(32*4)
        ld      b,9
        ld      de,$00ff
.loop:
        push    de
        push    de
        push    de
        push    de

        push    de
        push    de
        push    de
        push    de

        push    de
        push    de
        push    de
        push    de

        push    de
        push    de
        push    de
        push    de

        dec     b
        jr      nz,.loop

        push    de      ; Attach an end-of-buffer marker on the end

        ld      sp,hl
        ei

        ret