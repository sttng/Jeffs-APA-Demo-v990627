
        PUSHS

        SECTION "Fill Ram",WRAM0        ;SECTION "Fill Ram",BSS

EmptyColor:   db
StkSave:      dw
             ds      256
FillStack:

        POPS


; *** Solid fill an area ***
; Entry: [x1] = X coordinate
;        [y1] = Y Coordinate
;        [Color] = Fill Color (0-3)

SolidFill:
        ld      a,[x1]
        cp      128  ;160             ; Is X out of range ?
        ret     nc              ; Yes, exit
        ld      a,[y1]
        cp      120  ;144             ; Is Y out of range ?
        ret     nc              ; Yes, exit

        ld      [StkSave],sp

        ld      sp,FillStack

fill01: ld      a,[x1]          ; Get X coord
        ld      b,a
        ld      a,[y1]          ; Get Y coord
        ld      c,a

        call    PntTest         ; Get color under start point
        ld      [EmptyColor],a

        ld      l,0             ; Set Points On Stack Count to 0

fill1:  call    ptst            ; Is start point set?
        jr      nz,fill4        ; Yes

fill2:  dec     c
        call    ptst            ; Is point above this one set ?
        jr      z,fill2         ; No, so check again
        inc     c

fill3:  dec     b
        call    ptst            ; Is point on the left set ?
        jr      z,fill2         ; No, so check above again
        inc     b

        ld      a,b
        ld      [x1],a
        ld      a,c
        ld      [y1],a

        push    bc
        push    hl

        call    DrawPoint           ; Fill this point

        pop     hl
        pop     bc

        inc     c
        call    ptst            ; Is point below set ?
        jr      z,fill5         ; No

        dec     c
        inc     b
        call    ptst            ; Is point on the right set ?
        jr      z,fill2         ; No
        dec     b

; Are there any more points on the stack?

fill4:  ld      a,l
        or      a
        jr      z,fill8         ; No

; Get point on stack

        pop     bc

        dec     l
        jr      fill1

fill5:  dec     c
        inc     b
        call    ptst            ; Is point on the right set ?
        jr      nz,fill6        ; Yes

        inc     c
        call    ptst            ; Is lower right point set?
        jr      z,fill7         ; No

        dec     c

; Save point position to the right on stack

        inc     l               ; Increment points on stack count
        bit     7,l             ; Are there too many points on stack ?
        jr      nz,fill8        ; Yes, so quit

        push    bc              ; Save point on stack

;Point below is not set

fill6:  inc     c
fill7:  dec     b
        jr      fill3

;Exit fill routine

fill8:
        ld      a,[StkSave]
        ld      l,a
        ld      a,[StkSave+1]
        ld      h,a
        ld      sp,hl

	ret

; ** Test a fill point **
; Exit: Set NZ if point is full or out of bounds.

ptst:
        ld      a,b
        cp      160             ; Is point out of bounds in X?
        jr      nc,ptstoob      ; yes

        ld      a,c
        cp      144             ; Is point out of bounds in Y?
        jr      nc,ptstoob      ; yes

        ld      a,[EmptyColor]
        ld      h,a

        call    PntTest

        cp      h               ; Set Z flag if empty

        ret

; Out of bounds - Reset Z flag

ptstoob:
        ld      a,1
        or      a
        ret