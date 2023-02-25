;*
;* 16 Rotating cubes
;*
;*    by Jeff Frohwein
;*
;*  Last edit 27-Jun-99
;*
;* For info on how this code works and example code
;* that the following is based arounc check  the following link:
;*
;* http://services.canberra.edu.au/~scott/C%3DHacking/
;*
;* Check out issues 8,9,10,12, & 16 of C64 hacking magazine.
;*

        INCLUDE "3dmacro.asm"

ANGMAX  equ    128

        PUSHS
        SECTION "3D Vars",WRAM0        ;SECTION "3D Vars",BSS

acc:     db
ext:     db
aux:     db
rem:     db

sx:      db
sy:      db
sz:      db
t1:      db
t2:      db
t3:      db
t4:      db
t5:      db
t6:      db
t7:      db
t8:      db
t9:      db
t10:     db

ttx1:     db
tty1:     db

a11:     db
b12:     db
c13:     db
d21:     db
e22:     db
f23:     db
g31:     db
h32:     db
i33:     db

ta:      db
tb:      db
tc:      db
td:      db
te:      db
tf:      db
tg:      db
th:      db
ti:      db

p1x:     db
p2x:     db
p3x:     db
p4x:     db
p5x:     db
p6x:     db
p7x:     db
p8x:     db
p1y:     db
p2y:     db
p3y:     db
p4y:     db
p5y:     db
p6y:     db
p7y:     db
p8y:     db

xoff:    db
yoff:    db

        POPS

DrawCube:
        ld      a,64
        ld      [xoff],a
        ld      [yoff],a
        ld      a,0
        ld      [sx],a
        ld      a,0
        ld      [sy],a
        ld      a,0
        ld      [sz],a
.loop:
        call    ProcessInput

        call    SetRotationMatrix

; Row 1
        ld      a,64-30-15
        ld      [yoff],a
        call    OneRow

        ld      a,64-15
        ld      [yoff],a
        call    OneRow

        ld      a,64+30-15
        ld      [yoff],a
        call    OneRow

        ld      a,64+60-15
        ld      [yoff],a
        call    OneRow

        ld      a,1
        ld      [StartDMA],a

        call    WaitAndClearRenderBuffer

        jr      .loop

.done   jr      .done

OneRow:

        ld      a,64-32-15
        ld      [xoff],a
        ld      a,1
        ld      [Color],a

        call    ProjectCube

        ld      a,64-15
        ld      [xoff],a
        ld      a,2
        ld      [Color],a

        call    ProjectCube

        ld      a,64+32-15
        ld      [xoff],a
        ld      a,3
        ld      [Color],a

        call    ProjectCube

        ld      a,64+64-15
        ld      [xoff],a
        ld      a,2
        ld      [Color],a

        call    ProjectCube

        ret

ProcessInput:
        call    pad_Read

        ld      a,[_PadData]
        bit     PADB_UP,a               ; Up pressed?
        jr      z,.n0                   ; no

        ld      hl,sx
        inc     [hl]
        inc     [hl]
        inc     [hl]
        res     7,[hl]
.n0:
        bit     PADB_DOWN,a             ; Down pressed?
        jr      z,.n1                   ; no

        ld      hl,sx
        dec     [hl]
        dec     [hl]
        dec     [hl]
        res     7,[hl]
.n1:
        bit     PADB_LEFT,a             ; Down pressed?
        jr      z,.n2                   ; no

        ld      hl,sy
        dec     [hl]
        dec     [hl]
        dec     [hl]
        res     7,[hl]
.n2:
        bit     PADB_RIGHT,a             ; Down pressed?
        jr      z,.n3                   ; no

        ld      hl,sy
        inc     [hl]
        inc     [hl]
        inc     [hl]
        res     7,[hl]
.n3:
        bit     PADB_START,a            ; Down pressed?
        jr      z,.n4                   ; no

        ld      hl,sz
        inc     [hl]
        inc     [hl]
        inc     [hl]
        res     7,[hl]
.n4:
        bit     PADB_SELECT,a           ; Down pressed?
        jr      z,.n5                   ; no

        ld      hl,sz
        dec     [hl]
        dec     [hl]
        dec     [hl]
        res     7,[hl]
.n5:
        ret

ProjectCube:
; [1,1,1]
        ld      a,[a11]
        ld      [ta],a
        ld      a,[b12]
        ld      [tb],a
        ld      a,[c13]
        ld      [tc],a
        ld      a,[d21]
        ld      [td],a
        ld      a,[e22]
        ld      [te],a
        ld      a,[f23]
        ld      [tf],a
        ld      a,[g31]
        ld      [tg],a
        ld      a,[h32]
        ld      [th],a
        ld      a,[i33]
        ld      [ti],a
        call    ProjectPoint
        ld      a,[x1]
        ld      [p1x],a
        ld      a,[y1]
        ld      [p1y],a

; p2=[1,-1,1]
        NEG     b12,tb
        NEG     e22,te
        NEG     h32,th
        call    ProjectPoint
        ld      a,[x1]
        ld      [p2x],a
        ld      a,[y1]
        ld      [p2y],a

; p3=[-1,-1,1]
        NEG     a11,ta
        NEG     d21,td
        NEG     g31,tg
        call    ProjectPoint
        ld      a,[x1]
        ld      [p3x],a
        ld      a,[y1]
        ld      [p3y],a

; p4=[-1,1,1]
        ld      a,[b12]
        ld      [tb],a
        ld      a,[e22]
        ld      [te],a
        ld      a,[h32]
        ld      [th],a
        call    ProjectPoint
        ld      a,[x1]
        ld      [p4x],a
        ld      a,[y1]
        ld      [p4y],a

; p8=[-1,1,-1]
        NEG     c13,tc
        NEG     f23,tf
        NEG     i33,ti
        call    ProjectPoint
        ld      a,[x1]
        ld      [p8x],a
        ld      a,[y1]
        ld      [p8y],a

; p7=[-1,-1,-1]
        NEG     b12,tb
        NEG     e22,te
        NEG     h32,th
        call    ProjectPoint
        ld      a,[x1]
        ld      [p7x],a
        ld      a,[y1]
        ld      [p7y],a

; p6=[1,-1,-1]
        ld      a,[a11]
        ld      [ta],a
        ld      a,[d21]
        ld      [td],a
        ld      a,[g31]
        ld      [tg],a
        call    ProjectPoint
        ld      a,[x1]
        ld      [p6x],a
        ld      a,[y1]
        ld      [p6y],a

; p5=[1,1,-1]
        ld      a,[b12]
        ld      [tb],a
        ld      a,[e22]
        ld      [te],a
        ld      a,[h32]
        ld      [th],a
        call    ProjectPoint
        ld      a,[x1]
        ld      [p5x],a
        ld      a,[y1]
        ld      [p5y],a

; Draw the lines
    ;    ret

        ld      a,[p1x]
        ld      [x1],a
        ld      a,[p1y]
        ld      [y1],a
        ld      a,[p2x]
        ld      [x2],a
        ld      a,[p2y]
        ld      [y2],a
        call    DrawLine         ;1

        ld      a,[p3x]
        ld      [x1],a
        ld      a,[p3y]
        ld      [y1],a
        call    DrawLine         ;2


        ld      a,[p4x]
        ld      [x2],a
        ld      a,[p4y]
        ld      [y2],a
        call    DrawLine         ;3

        ld      a,[p1x]
        ld      [x1],a
        ld      a,[p1y]
        ld      [y1],a
        call    DrawLine         ;4

        ld      a,[p5x]
        ld      [x2],a
        ld      a,[p5y]
        ld      [y2],a
        call    DrawLine         ;5

        ld      a,[p6x]
        ld      [x1],a
        ld      a,[p6y]
        ld      [y1],a
        call    DrawLine         ;6

        ld      a,[p2x]
        ld      [x2],a
        ld      a,[p2y]
        ld      [y2],a
        call    DrawLine         ;7

        ld      a,[p7x]
        ld      [x2],a
        ld      a,[p7y]
        ld      [y2],a
        call    DrawLine         ;8

        ld      a,[p3x]
        ld      [x1],a
        ld      a,[p3y]
        ld      [y1],a
        call    DrawLine         ;9

        ld      a,[p8x]
        ld      [x1],a
        ld      a,[p8y]
        ld      [y1],a
        call    DrawLine         ;10

        ld      a,[p4x]
        ld      [x2],a
        ld      a,[p4y]
        ld      [y2],a
        call    DrawLine         ;11

        ld      a,[p5x]
        ld      [x2],a
        ld      a,[p5y]
        ld      [y2],a
        call    DrawLine         ;12

        ret

SetRotationMatrix:

;**.Now.calculate.t1,t2,etc.

        ld      b,b

        SUBA    sy,sz
        ld      [t1],a   ;t1=sy-sz
        ADDA    sy,sz
        ld      [t2],a   ;t2=sy+sz
        ADDA    sx,sz
        ld      [t3],a   ;t3=sx+sz
        SUBA    sx,sz
        ld      [t4],a   ;t4=sx-sz
        ADDA    sx,t2
        ld      [t5],a   ;t5=sx+t2
        SUBA    sx,t1
        ld      [t6],a   ;t6=sx-t1
        ADDA    sx,t1
        ld      [t7],a   ;t7=sx+t1
        SUBA    t2,sx
        ld      [t8],a   ;t8=t2-sx
        SUBA    sy,sx
        ld      [t9],a   ;t9=sy-sx
        ADDA    sx,sy
        ld      [t10],a  ;t10=sx+sy

calca:
        ld      b,b

        ld      a,[t1]
        ld      h,CosTable
        ld      l,a
        ld      b,[hl]

        ld      a,[t2]
        ld      l,a
        ld      a,[hl]
        add     a,b
        ld      [a11],a         ; a11=[cos[t1]+cos[t2]]/2
calcb:
        ld      a,[t2]
        ld      h,SinTable
        ld      l,a
        ld      b,[hl]

        ld      a,[t1]
        ld      l,a
        ld      a,[hl]
        sub     b
        ld      [b12],a         ; b12=[sin[t1]-sin[t2]]/2
calcc:
        ld      a,[sy]
        ld      l,a
        ld      a,[hl]
        ld      [c13],a         ; c13=sin[sy]
calcd:
        ld      h,CosTable
        ld      a,[t5]
        ld      l,a
        ld      b,[hl]

        ld      a,[t7]
        ld      l,a
        ld      c,[hl]

        ld      a,[t8]
        ld      l,a
        ld      a,[hl]

        sub     b
        sub     c
        ld      b,a

        ld      a,[t6]
        ld      l,a
        ld      a,[hl]

        add     a,b

        sra     a               ; signed divide by 2
        ld      b,a             ; Di = [cos[t8]-cos[t7]+cos[t6]-cos[t5]]/4

        ld      h,SinTable
        ld      a,[t4]
        ld      l,a
        ld      c,[hl]

        ld      a,[t3]
        ld      l,a
        ld      a,[hl]

        sub     c
        add     a,b

        ld      [d21],a         ; d21 = [sin[t3]-sin[t4]]/2 + Di
calce:
        ld      a,[t6]
        ld      l,a
        ld      b,[hl]

        ld      a,[t7]
        ld      l,a
        ld      c,[hl]

        ld      a,[t8]
        ld      l,a
        ld      a,[hl]

        add     a,b
        add     a,c
        ld      b,a

        ld      a,[t5]
        ld      l,a
        ld      a,[hl]

        sub     b
        sra     a               ; signed divide by 2
        ld      b,a             ; Ei = [sin[t5]-sin[t6]-sin[t7]-sin[t8]]/4

        ld      h,CosTable
        ld      a,[t3]
        ld      l,a
        ld      c,[hl]

        ld      a,[t4]
        ld      l,a
        ld      a,[hl]

        add     a,c
        add     a,b
        ld      [e22],a         ; e22 = [cos[t3]+cos[t4]]/2 + Ei
calcf:
        ld      h,SinTable
        ld      a,[t10]
        ld      l,a
        ld      b,[hl]

        ld      a,[t9]
        ld      l,a
        ld      a,[hl]

        sub     b
        ld      [f23],a         ; f23 = [sin[t9]-sin[t10]]/2
calcg:
        ld      a,[t8]
        ld      l,a
        ld      b,[hl]

        ld      a,[t7]
        ld      l,a
        ld      c,[hl]

        ld      a,[t5]
        ld      l,a
        ld      a,[hl]

        add     a,b
        add     a,c
        ld      b,a

        ld      a,[t6]
        ld      l,a
        ld      a,[hl]

        sub     b
        sra     a               ; signed divide by 2
        ld      b,a             ; Gi = [sin[t6]-sin[t8]-sin[t7]-sin[t5]]/4

        ld      h,CosTable
        ld      a,[t3]
        ld      l,a
        ld      c,[hl]

        ld      a,[t4]
        ld      l,a
        ld      a,[hl]

        sub     c
        add     a,b
        ld      [g31],a         ; g31 = [cos[t4]-cos[t3]]/2 + Gi
calch:
        ld      a,[t5]
        ld      l,a
        ld      b,[hl]

        ld      a,[t8]
        ld      l,a
        ld      c,[hl]

        ld      a,[t6]
        ld      l,a
        ld      a,[hl]

        sub     b
        sub     c
        ld      b,a

        ld      a,[t7]
        ld      l,a
        ld      a,[hl]

        add     a,b
        sra     a               ; sign divide /2
        ld      b,a             ; Hi = [cos[t6]+cos[t7]-cos[t5]-cos[t8]]/4

        ld      h,SinTable
        ld      a,[t3]
        ld      l,a
        ld      c,[hl]

        ld      a,[t4]
        ld      l,a
        ld      a,[hl]

        add     a,b
        add     a,c
        ld      [h32],a         ;h32 = sin[t3]+sin[t4]+]/2 + Hi
calci:
        ld      h,CosTable
        ld      a,[t9]
        ld      l,a
        ld      b,[hl]

        ld      a,[t10]
        ld      l,a
        ld      a,[hl]

        add     a,b
        ld      [i33],a         ;i33 = [cos[t9]+cos[t10]]/2
        ret

ProjectPoint:
        ld      a,[tg]
        ld      b,a

        ld      a,[th]
        add     b
        ld      b,a

        ld      a,[ti]
        add     b

        add     128
        ld      l,a
        ld      h,ZDivTable
        ld      a,[hl]
        ld      [aux],a
        ld      [rem],a

; Calculate X coord on screen

        ld      a,[ta]
        ld      b,a

        ld      a,[tb]
        add     b
        ld      b,a

        ld      a,[tc]
        add     b
        ld      [acc],a

        call    SMult

        ld      a,[acc]
        sra     a
        ld      b,a

        ld      a,[xoff]         ; offset the x coord
        add     b
        ld      [ttx1],a         ; Done with X
;        srl     a
        ld      [x1],a

        ld      a,[rem]
        ld      [aux],a

        ld      a,[td]
        ld      b,a

        ld      a,[te]
        add     b
        ld      b,a

        ld      a,[tf]
        add     b
        ld      [acc],a

        call    SMult

        ld      a,[acc]
        sra     a
        ld      b,a

        ld      a,[yoff]
        add     b
        ld      [tty1],a
;        srl     a
        ld      [y1],a

;        ld      a,3
;        ld      [Color],a

;        ld      a,[x1]
;        ld      b,a
;        ld      a,[y1]
;        ld      c,a

;        call    DrawPoint
        ret


; ** Signed multiply **
; [ext,acc [hi/lo]] = acc * aux/2^6

SMult:
        ld      a,[acc]
        ld      c,a
        ld      a,[aux]
        ld      h,a

        ld      a,c
        xor     h
        bit     7,a
        jr      nz,neg

; They are either both negative or
; both positive.

        bit     7,c             ; Both positive?
        jr      z,cont1         ; yes

        ld      a,c
        cpl
        inc     a
        ld      c,a

        ld      a,h
        cpl
        inc     a
        ld      h,a

cont1:
        ld      l,0
        ld      b,0
        ld      a,8
sloop:
        add     hl,hl
        jr      nc,jump1
        add     hl,bc
jump1:
        dec     a
        jr      nz,sloop

        ld      a,l
        ld      [acc],a
        ld      a,h
        DIVOFF
        ld      [ext],a
        ret


neg:
        bit     7,c
        jr      nz,cont2

        ld      a,h
        cpl
        inc     a
        ld      h,a

        jr      cont3
cont2:
        ld      a,c
        cpl
        inc     a
        ld      c,a
cont3:
        ld      l,0
        ld      b,0
        ld      a,8
sloop2:
        add     hl,hl
        jr      nc,jump2
        add     hl,bc
jump2:
        dec     a
        jr      nz,sloop2

        ld      a,l
        ld      [acc],a
        ld      a,h
        DIVOFF

        cpl
        inc     a
        ld      [ext],a

        ld      a,[acc]
        cpl
        inc     a
        ld      [acc],a

        ret