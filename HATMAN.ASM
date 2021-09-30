
DrawPerson:

        call    ScreenOff

; Setup GBC Attribute memory with map

        ld      hl,GB_AttrMap
        call    SetCGBAttrMap1
        ld      hl,GB_AttrMap
        call    SetCGBAttrMap2

        ld      hl,HatManCGBPalettes
        call    SetCGB_BGP

        ld      a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON
        ld      [rLCDC],a        ; Turn screen on

        ld      a,3
        ld      [Color],a

; Face outline
        ld      a,80
        ld      [xm],a
        ld      a,72-1
        ld      [ym],a
        ld      a,50
        ld      [XRad],a
        ld      a,50
        ld      [YRad],a
        call    ellipse

        ld      a,1
        ld      [StartDMA],a

; Left eye
        ld      a,80-12
        ld      [xm],a
        ld      a,72-10
        ld      [ym],a
        ld      a,10
        ld      [XRad],a
        ld      a,20
        ld      [YRad],a
        call    ellipse
        ld      a,1
        ld      [StartDMA],a
; Left eye pupil
        ld      a,80-12-2
        ld      [xm],a
        ld      a,72-10+3
        ld      [ym],a
        ld      a,3
        ld      [XRad],a
        ld      a,5
        ld      [YRad],a
        call    ellipse
        ld      a,1
        ld      [StartDMA],a
; Fill left pupil
        ld      a,80-12-2
        ld      [x1],a
        ld      a,72-10+3
        ld      [y1],a
        ld      a,3
        ld      [Color],a
        call    SolidFill
        ld      a,1
        ld      [StartDMA],a

; Fill left outsite pupil
        ld      a,80-12-2
        ld      [x1],a
        ld      a,72-10+3-8
        ld      [y1],a
        ld      a,2
        ld      [Color],a
        call    SolidFill
        ld      a,1
        ld      [StartDMA],a

        ld      a,3
        ld      [Color],a
; Right eye
        ld      a,80+12
        ld      [xm],a
        ld      a,72-10
        ld      [ym],a
        ld      a,10
        ld      [XRad],a
        ld      a,20
        ld      [YRad],a
        call    ellipse
        ld      a,1
        ld      [StartDMA],a
; Right eye pupil
        ld      a,80+12-2
        ld      [xm],a
        ld      a,72-10+3+1
        ld      [ym],a
        ld      a,3
        ld      [XRad],a
        ld      a,5
        ld      [YRad],a
        call    ellipse
        ld      a,1
        ld      [StartDMA],a
; Fill right pupil
        ld      a,80+12-2
        ld      [x1],a
        ld      a,72-10+3
        ld      [y1],a
        ld      a,3
        ld      [Color],a
        call    SolidFill

        ld      a,1
        ld      [StartDMA],a

; Fill right outsite pupil
        ld      a,80+12-2
        ld      [x1],a
        ld      a,72-10+3-8
        ld      [y1],a
        ld      a,2
        ld      [Color],a
        call    SolidFill

        ld      a,1
        ld      [StartDMA],a

; Mouth
        ld      a,80
        ld      [xm],a
        ld      a,72+20
        ld      [ym],a
        ld      a,30
        ld      [XRad],a
        ld      a,5
        ld      [YRad],a
        ld      a,3
        ld      [Color],a
        call    ellipse

; Erase top of mouth
        xor     a
        ld      [Color],a

        ld      a,80-30
        ld      [x1],a
        ld      a,80+30
        ld      [x2],a
        ld      a,72+20
        ld      [y1],a
        ld      [y2],a
        call    DrawLine
        ld      a,72+19
        ld      [y1],a
        ld      [y2],a
        call    DrawLine
        ld      a,72+18
        ld      [y1],a
        ld      [y2],a
        call    DrawLine
        ld      a,72+17
        ld      [y1],a
        ld      [y2],a
        call    DrawLine
        ld      a,72+16
        ld      [y1],a
        ld      [y2],a
        call    DrawLine

        ld      a,1
        ld      [StartDMA],a

; Draw brim of hat

        ld      a,3
        ld      [Color],a

        ld      a,80-50
        ld      [x1],a
        ld      a,80+50
        ld      [x2],a
        ld      a,35
        ld      [y1],a
        ld      a,30
        ld      [y2],a
        call    DrawLine

        ld      a,1
        ld      [StartDMA],a

; Draw hat

        ld      a,80-30
        ld      [x1],a
        ld      a,80+30
        ld      [x2],a
        ld      a,8
        ld      [y1],a
        ld      a,5
        ld      [y2],a
        call    DrawLine

        ld      a,80-30
        ld      [x1],a
        ld      a,80-25
        ld      [x2],a
        ld      a,8
        ld      [y1],a
        ld      a,34
        ld      [y2],a
        call    DrawLine

        ld      a,80+30
        ld      [x1],a
        ld      a,80+25
        ld      [x2],a
        ld      a,5
        ld      [y1],a
        ld      a,31
        ld      [y2],a
        call    DrawLine

        ld      a,80
        ld      [x1],a
        ld      a,10
        ld      [y1],a
        ld      a,1
        ld      [Color],a
        call    SolidFill

        ld      a,1
        ld      [StartDMA],a

; Draw shoulders
        ld      a,80-50
        ld      [x1],a
        ld      a,80+50
        ld      [x2],a
        ld      a,122
        ld      [y1],a
        ld      a,118
        ld      [y2],a
        ld      a,3
        ld      [Color],a
        call    DrawLine

        ld      a,80-50
        ld      [x1],a
        ld      a,16
        ld      [x2],a
        ld      a,122
        ld      [y1],a
        ld      a,143
        ld      [y2],a
        call    DrawLine

        ld      a,80+50
        ld      [x1],a
        ld      a,80+50+8
        ld      [x2],a
        ld      a,118
        ld      [y1],a
        ld      a,143
        ld      [y2],a
        call    DrawLine

        ld      a,1
        ld      [StartDMA],a

        ld      a,80
        ld      [x1],a
        ld      a,125
        ld      [y1],a
        ld      a,1
        ld      [Color],a
        call    SolidFill

        ld      a,1
        ld      [StartDMA],a

; Fill face

        ld      a,80
        ld      [x1],a
        ld      a,80
        ld      [y1],a
        ld      a,1
        ld      [Color],a
        call    SolidFill

        ld      a,1
        ld      [StartDMA],a

; Draw small stars

        ld      b,16
        ld      c,16
        call    SmallStar

        ld      b,20
        ld      c,90
        call    SmallStar

        ld      b,130
        ld      c,8
        call    SmallStar

        ld      b,143
        ld      c,70
        call    SmallStar

        ld      a,1
        ld      [StartDMA],a

; Fill background
        ld      a,8 ;80
        ld      [x1],a
        ld      a,8 ;40
        ld      [y1],a
        ld      a,2
        ld      [Color],a
        call    SolidFill

        ld      a,1
        ld      [StartDMA],a

.done:
        jr      .done

; *** Draw a small star ***
; Entry: B = X Coordinate of top point
;        C = Y Coordinate of top point

SmallStar:
        ld      a,3
        ld      [Color],a

        ld      a,b
        ld      [x1],a
        sub     5
        ld      [x2],a

        ld      a,c
        ld      [y1],a
        add     a,15
        ld      [y2],a
        call    sline

        ld      a,[x1]
        add     a,8
        ld      [x1],a

        ld      a,[y1]
        add     a,5
        ld      [y1],a
        call    sline

        ld      a,[x1]
        sub     16
        ld      [x2],a

        ld      a,[y1]
        ld      [y2],a
        call    sline

        ld      a,[x1]
        sub     4
        ld      [x1],a

        ld      a,[y1]
        add     a,10
        ld      [y1],a
        call    sline

        ld      a,[x2]
        add     8
        ld      [x2],a

        ld      a,[y2]
        sub     5
        ld      [y2],a
        call    sline

        ret

sline:
        push    bc
        call    DrawLine
        pop     bc
        ret

; Data for GBC attribute video RAM.
; ONLY color information in this map!

GB_AttrMap:
        DB      $00,$00,$00,$00,$00,$22,$22,$00 ;,$00,$00
        DB      $00,$00,$00,$22,$22,$22,$22,$00 ;,$00,$00
        DB      $00,$00,$00,$22,$22,$22,$22,$00 ;,$00,$00
        DB      $00,$00,$00,$22,$22,$22,$22,$00 ;,$00,$00

        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$01,$11,$11,$10,$00 ;,$00,$00
        DB      $00,$00,$00,$01,$11,$11,$10,$00 ;,$00,$00
        DB      $00,$00,$00,$01,$11,$11,$10,$00 ;,$00,$00

        DB      $00,$00,$00,$01,$11,$11,$10,$00 ;,$00,$00
        DB      $00,$00,$00,$01,$11,$11,$10,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$10,$01,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00

        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$00 ;,$00,$00
        DB      $00,$00,$00,$00,$00,$00,$00,$44 ;,$40,$00

;        DB      $00,$04,$44,$44,$44,$44,$44,$44 ;,$40,$00
;
;        DB      $00,$44,$44,$44,$44,$44,$44,$44 ;,$40,$00
;        DB      $00,$44,$44,$44,$44,$44,$44,$44 ;,$44,$00

HatManCGBPalettes:
        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  128,128,255     ; Light Blue
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  64,255,64       ; Green
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  64,255,64       ; Green
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,0,255       ; Purple
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black