
        PUSHS

        SECTION "Low Ram",BSS

i1      db
i2      db
sx      db
sy      db
xc      db
yc      db

        POPS

line:
        xor     a
        ld      [dd],a
        ld      [dd+1],a

        ld      a,[x2]
        ld      b,a
        ld      a,[x1]
        ld      [xc],a
        sub     b
        ld      b,0
;        or      a
        jr      z,l_px

        dec     b               ; b = -1
        bit     7,a
        jr      z,l_px
        neg
        ld      b,1
l_px:
        ld      d,a             ; d = abs(dx)
        sla     a
        ld      [i2],a    ; i2=dx*2

        ld      a,b
        ld      [sx],a
        ld      a,[y2]
        ld      b,a
        ld      a,[y1]
        ld      [yc],a
        sub     b
        ld      b,0
        jr      z,l_py
        ld      b,$ff
        bit     7,a
        jr      z,l_py
        neg
        ld      b,1
l_py:   ld      e,a             ; dy sichern
        sla     a
        ld      [i1],a    ; i1=dy*2
        ld      a,b
        ld      [sy],a
        ld      a,d
        cp      e               ; dx<dy ?
        jr      c,dloop2

; dx>dy
dloop:  ld      a,[xc]    ; if [[x1==x2]&&[y1==y2]] return;
        ld      b,a
        ld      a,[yc]
        ld      c,a
        call    point

        ld      a,[xc]
        ld      b,a
        ld      a,[x2]
        cp      b
        jr      nz,dnext

        ld      a,[yc]
        ld      b,a
        ld      a,[y2]
        cp      b
        jr      nz,dnext
        ret

dnext:  ld      a,[dd]
        ld      e,a
        ld      a,[dd+1]
        ld      d,a
        bit     7,d
        jr      nz,xxp

        ld      a,[sy]    ; yc+=sy
        ld      b,a
        ld      a,[yc]
        add     a,b
        ld      [yc],a

        ld      a,[i2]    ; d-=i2
        ld      b,a
        ld      a,e
        sub     b
        ld      e,a
        jr      nc,jnc1
        dec     d
jnc1:
xxp:    ld      a,[sx]          ; xc+=sx
        ld      b,a
        ld      a,[xc]
        add     a,b
        ld      [xc],a

        ld      a,[i1]    ; d+=i1
        ld      b,a
        ld      a,e
        add     a,b
        ld      [dd],a
        jr      nc,jnc2
        inc     d
jnc2:   ld      a,d
        ld      [dd+1],a
        jr      dloop

; dy>dx
dloop2: ld      a,[xc]    ; if [[x1==x2]&&[y1==y2]] return;
        ld      b,a
        ld      a,[yc]
        ld      c,a
        call    point
        ld      a,[xc]
        ld      b,a
        ld      a,[x2]
        cp      b
        jr      nz,dnext2
        ld      a,[yc]
        ld      b,a
        ld      a,[y2]
        cp  b
        jr  nz,dnext2
        ret

dnext2: ld      a,[dd]
        ld      e,a
        ld      a,[dd+1]
        ld      d,a
        bit     7,d
        jr      nz,yyp

        ld      a,[sx]    ; xc+=sy
        ld      b,a
        ld      a,[xc]
        add     a,b
        ld      [xc],a

        ld      a,[i1]    ; d-=i2
        ld      b,a
        ld      a,e
        sub     b
        ld      e,a
        jr      nc,jnc12
        dec     d
jnc12:

yyp:    ld      a,[sy]          ; yc+=sy
        ld      b,a
        ld      a,[yc]
        add     a,b
        ld      [yc],a

        ld      a,[i2]    ; d+=i1
        ld      b,a
        ld      a,e
        add     a,b
        ld      [dd],a
        jr      nc,jnc22
        inc     d
jnc22:  ld      a,d
        ld      [dd+1],a
        jr      dloop2


