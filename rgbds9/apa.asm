
;***********************************
;*  Demo for 160x128 APA graphics  *
;***********************************
; By Jeff F.

; Last edit 23-Jun-99

MACRO RGBSet
        DW      ((\3 >> 3) << 10) + ((\2 >> 3) << 5) + (\1 >> 3)
        ENDM

MACRO lcd_WaitVRAM2
        ld      a,[rSTAT]       ; <---+
        and     STATF_BUSY      ;     |
        jr      nz,@-5          ; ----+
        ENDM

DEF RENDER_TO_VRAM     equ     0     ; 0 = $C000, 1 = $8000

DEF GREY_SCALE         equ     1     ; 0 = black/white, 1 = Grey Scale

DEF HIGH_LINE_PREC     equ     0     ; 0 = low line precision, 1 = high line precision

DEF LEFT_LINE_MASK_ADDR     equ     $200  ; MUST be $xx00 (page aligned)
DEF RIGHT_LINE_MASK_ADDR    equ     $300  ; MUST be $xx00 (page aligned)
DEF SinTable        equ     $04
DEF CosTable        equ     $05
DEF ZDivTable       equ     $06


        INCLUDE "hardware.inc"

;SpriteRoutine EQU $ff80

;ToggleRoutine EQU $ff90
;FatDelay      EQU ToggleRoutine+2

        SECTION "Low Ram",WRAM0        ;SECTION "Low Ram",BSS

SrnBuffer:       ds      $1680
SpriteTable:     ds      160
dd:              dw
Color:           db
RandomSeed:      db
StartDMA:        db
DMAState:        db
PointerY:        db
EnableAPA:       db
DMAFlag:         db

; High RAM assignments

DEF GeneralHRAM equ     $ff90
DEF TriangleHRAM equ    $ffb0

        RSSET   GeneralHRAM

DEF x1      RB      1
DEF y1      RB      1
DEF x2      RB      1
DEF y2      RB      1
DEF x3      RB      1
DEF y3      RB      1
DEF delde   RB      2
DEF delse   RB      2
DEF talllf  RB      1
DEF leftlf  RB      1
DEF tempx1  RB      1
DEF tempy1  RB      1
DEF tempx2  RB      1
DEF tempy2  RB      1


        SECTION "Org $0",ROM0[$00]        ;SECTION "Org $0",HOME

; Data required by point plot routine.

        DB      $80,$40,$20,$10,$8,$4,$2,$1


        SECTION "Org $40",ROM0[$40]  ;SECTION "Org $40",HOME[$40]     ; VBlank int
        jp      vblank_int

        SECTION "Org $48",ROM0[$48]     ; LCDC status int

        jp      lcdc_int




lcdc_int:
        push    af
        ld      a,[DMAState]
        cp      2       ; dma done?
        jr      nz,.skip2
        ld      a,[$ff55]
        ld      [DMAFlag],a
.skip2:

        lcd_WaitVRAM2

        ld      a,[EnableAPA]
        or      a               ; Is APA enabled?
        jr      z,.skip         ; no

;        ld      a,[rLCDC]       ; Set BG Tiles = $8800-$97ff
;        res     4,a
;        ld      [rLCDC],a
.skip:

        pop     af
        reti


        SECTION "Org $100",ROM0[$100]

;*** Beginning of rom execution point ***

        nop
        jp      begin

        NINTENDO_LOGO                   ; Nintendo graphic logo

;Rom Header Info

;    0123456789ABCDE
 DB "APA DEMO - JEFF"         ; Cart name   16bytes
 DB $80                       ; GBC=$80
 DB 0,0,0
 DB 0                  ; Cart type
 DB 0             ; ROM Size (in bits)
 DB 0             ; RAM Size (in bits)
 DB 1,1
 DB 0
 DB $e2                       ; Complement check (important)
 DW $c40e                     ; Checksum (not important)

; Library Includes


        INCLUDE "vblank.asm"
        INCLUDE "keypad.asm"
        INCLUDE "memory1.asm"
;        INCLUDE "line3.asm"
        INCLUDE "linexor.asm"
        INCLUDE "lineblk.asm"
        INCLUDE "linewht.asm"
        INCLUDE "linelite.asm"
        INCLUDE "linedark.asm"
        INCLUDE "fill1.asm"
        INCLUDE "ellip1.asm"
        INCLUDE "tri1.asm"
        INCLUDE "cls1.asm"
;        INCLUDE "shrnkx25.asm"
;        INCLUDE "shrnkx50.asm"
;        INCLUDE "shrnkxy5.asm"
;        INCLUDE "shrnkxy2.asm"
        INCLUDE "3dmath.asm"

; Demo code

        INCLUDE "hatman.asm"
        INCLUDE "xorline.asm"
        INCLUDE "tritests.asm"
        INCLUDE "mario.asm"
        INCLUDE "street.asm"


DEF NUM_ENTRIES     equ     7

;                12345678901234567890
Menu:
        db      " APA Demo Rev990627 "
        db      "                    "
        db      "  Hat Man- Fill demo"
        db      "  Fast XOR Line demo"
        db      "  Solid random Tri  "
        db      "  8x8Tex random Tri "
        db      "  Mario - 112 Tri's "
        db      "  Street-Pattrn Tris"
        db      "  16 Cubes at 8fps  "
        db      "                    "
        db      "                    "
        db      "                    "
        db      "                    "
        db      "                    "
        db      "                    "
        db      "                    "
        db      "                    "
        db      "                    "

JumpTable:
        dw      DrawPerson
        dw      XorLines
        dw      RandomTris
        dw      RandomTextureTris
        dw      DrawMario
        dw      AnimateStreet
;        dw      LargeTriTest
        dw      DrawCube

; Data table used by triangle render code

        SECTION "Main #1", ROM0[LEFT_LINE_MASK_ADDR]
        DB      $ff,$7f,$3f,$1f,$f,$7,$3,$1

; Data table used by triangle render code

        SECTION "Main #2", ROM0[RIGHT_LINE_MASK_ADDR]
        DB      $80,$c0,$e0,$f0,$f8,$fc,$fe,$ff

        SECTION "Main #3", ROM0[$400]
        INCLUDE "sin.asm"

        SECTION "Main #4", ROM0[$500]
        INCLUDE "cos.asm"

        SECTION "Main #5", ROM0[$600]
        INCLUDE "zdiv.asm"

        SECTION "Main Code",ROM0
begin:
        di

        ld      sp,$ffff

        cp      $11                     ; Is it a GBC?
        call    z,ToggleCPUSpeed        ; Yes

        ld      a,0
        ld      [rIE],a         ;disable interrupts
        ld      [rIF],a

        call    ScreenOff

        ld      a,$e4
        ld      [rBGP],a       ; Setup default background colors
        ld      [rOBP0],a      ; Setup default sprite colors
        ld      [rOBP1],a      ; Setup default sprite colors

        call    FillCGBAttrPage1
        call    FillCGBAttrPage2

        ld      hl,$8000
        call    ClearTiles      ; Clear the chrset at $8000

 if RENDER_TO_VRAM
 else
        ld      hl,$c000
        call    ClearTiles      ; Clear the chrset at NON_VIDEO_RAM
 endc

        call    SetAPATileMap1  ; Move the text to $9800
        call    SetAPATileMap2  ; Move the text to $9c00


        ld      hl,DefaultCGBPalettes
        call    SetCGB_OBJP
        ld      hl,DefaultCGBPalettes
        call    SetCGB_BGP

        ld      a,72        ; set line at which lcdc interrupt occurs
        ld      [rLYC],a

        ld      a,%01000000     ; set lcdc int to occur when LY = LCY
        ld      [rSTAT],a

        xor     a
        ld      [rSCX],a
        ld      [rSCY],a

        ld      hl,$c000
        ld      bc,$2000
        xor     a
        call    mem_Set

        ld      hl,Menu
        ld      de,$9800
        call    Copy20x18

        ld      hl,Font
        ld      de,$8000+(16*32)
        ld      bc,$800
        call    mem_Copy

        ld      a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON
        ld      [rLCDC],a        ; Turn screen on

        ld      a,2+1
        ld      [rIE],a
        ei

        call    DrawPointer

;        jp      DrawPerson

; *** User input main loop ***

WaitOnUser:

        call    pad_Read

        ld      a,[_PadDataEdge]
        bit     PADB_UP,a               ; Up pressed?
        jp      nz,.up                  ; yes
        bit     PADB_DOWN,a             ; Down pressed?
        jp      nz,.down                ; yes
        bit     PADB_A,a                ; A pressed?
        jp      nz,.execute             ; yes
        bit     PADB_B,a                ; B pressed?
        jp      nz,.execute             ; yes

        jr      WaitOnUser

.down:
        ld      a,[PointerY]
        inc     a
        cp      NUM_ENTRIES             ; Down too far?
        jr      c,.nowrap1              ; no

        xor     a
.nowrap1:
        ld      [PointerY],a

        call    DrawPointer
        jr      WaitOnUser

.up:
        ld      a,[PointerY]
        or      a                       ; Up too far?
        jr      nz,.nowrap2             ; no

        ld      a,NUM_ENTRIES
.nowrap2:
        dec     a
        jr      .nowrap1


.execute:

; Clear the screen

        call    ScreenOff

        ld      a,1
        ld      [EnableAPA],a   ; Enable Midscreen chrset switch

        call    SetAPATileMap1  ; Move the text to $9800

        ld      hl,$8000
        call    ClearTiles      ; Clear the chrset at $8000

        ld      a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON
        ld      [rLCDC],a       ; Turn screen on

; Jump to code

        ld      a,[PointerY]
        add     a
        ld      e,a
        ld      d,0
        ld      hl,JumpTable
        add     hl,de
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        jp      hl        ;jp      [hl]


DrawPointer:

; Erase old pointer

        ld      hl,$9800+(2*32)
        ld      b,18
.loop1:
        lcd_WaitVRAM

        ld      a,32
        ld      [hl+],a
        ld      [hl-],a

        ld      de,32
        add     hl,de

        dec     b
        jr      nz,.loop1

; Draw new pointer

        ld      a,[PointerY]
        ld      l,a
        ld      h,0
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        ld      de,$9800+(2*32)
        add     hl,de

        lcd_WaitVRAM

        ld      [hl],"-"
        inc     hl
        ld      [hl],">"
        ret

; *** Draw a line to the screen ***
; Entry: [x1] = First X Coordinate
;        [y1] = First Y Coordinate
;        [x2] = Last X Coordinate
;        [y2] = Last Y Coordinate
;        [Color] = Color to draw
;                 ( 0 = Color 0,
;                   1 = Color 1,
;                   2 = Color 2,
;                   3 = Color 3,
;                   4 = Xor )

DrawLine:
        ld      a,[Color]
        or      a
        jp      z,WhiteLine
        dec     a
        jp      z,LightLine
        dec     a
        jp      z,DarkLine
        dec     a
        jp      z,BlackLine
        jp      XorLine

; *** Draw a pixel to the screen ***
; Entry: B = X Coordinate
;        C = Y Coordinate
;        [Color] = Color to draw
;                 ( 0 = Color 0,
;                   1 = Color 1,
;                   2 = Color 2,
;                   3 = Color 3,
;                   4 = Xor )

DrawPoint:
        push    af
        push    bc
        push    de
        push    hl
        call    CalcPntAddr
        ld      a,[Color]
        or      a
        call    z,Color0
        dec     a
        call    z,Color1
        dec     a
        call    z,Color2
        dec     a
        call    z,Color3
        dec     a
        call    z,PntXor

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

; *** Return color of point B,C ***
; Entry: B = X Coordinate
;        C = Y Coordinate
; Exit:  A = 0 - 3 color

PntTest:
        push    bc
        push    de
        push    hl
        call    CalcPntAddr

        ld      c,0
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
 if RENDER_TO_VRAM
        ei
 endc
        and     b
        jr      z,.skip1
        inc     c
.skip1:
        inc     de

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
 if RENDER_TO_VRAM
        ei
 endc
        and     b
        jr      z,.skip2
        inc     c
        inc     c
.skip2:
        ld      a,c
        pop     hl
        pop     de
        pop     bc
        ret


; *** Calculate address of a pixel on the screen ***
; Entry: B = X Coordinate
;        C = Y Coordinate
; Exit:  DE = Address
;        B = Bit set mask
;        C = Bit reset mask

CalcPntAddr:
        ld      a,b
        ld      e,c
        sla     e
        ld      d,b
        srl     d
        srl     d
        srl     d

        set     7,d

 if RENDER_TO_VRAM
 else
        set     6,d
 endc

        and     7               ; b = Bitmask[b & 7]
        ld      l,a
        ld      h,0
        ld      a,[hl]
        ld      b,a
        cpl
        ld      c,a
        ret

Color0: push    af

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
        and     c
        ld      [de],a

        inc     de

        ld      a,[de]
        and     c
        ld      [de],a
        ei

        pop     af
        ret

Color1: push    af

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
        or      b
        ld      [de],a

        inc     de

        ld      a,[de]
        and     c
        ld      [de],a

 if RENDER_TO_VRAM
        ei
 endc

        pop     af
        ret

Color2: push    af
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
        and     c
        ld      [de],a

        inc     de

        ld      a,[de]
        or      b
        ld      [de],a
 if RENDER_TO_VRAM
        ei
 endc

        pop     af
        ret

Color3: push    af
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
        or      b
        ld      [de],a

        inc     de

        ld      a,[de]
        or      b
        ld      [de],a
 if RENDER_TO_VRAM
        ei
 endc

        pop     af
        ret

PntXor:
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc

        ld      a,[de]
        xor     b
        ld      [de],a

        inc     de

        ld      a,[de]
        xor     b
        ld      [de],a

 if RENDER_TO_VRAM
        ei
 endc

        ret

; *** Clear all APA tiles to $00 ***
; Entry: HL = Address of Tiles

ClearTiles:
        ld      d,0
        ld      e,23
        xor     a
.loop:
        ld      [hl+],a
        dec     d
        jr      nz,.loop
        dec     e
        jr      nz,.loop

        ld      a,1
        ld      [rVBK],a

        call    SetLastTiles

        xor     a
        ld      [rVBK],a

        call    SetLastTiles

        ret

SetLastTiles:
        ld      hl,$8ff0
        ld      [hl],$55
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$55
        inc     hl
        ld      [hl],$aa
        inc     hl
        ld      [hl],$aa

        ret

; *** Fill screen with APA tiles ***

SetAPATileMap1:
        ld      hl,_SCRN0+2
        jr      _initscrn

SetAPATileMap2:
        ld      hl,_SCRN1+2
_initscrn:
        call    .filledges
        xor     a

        ld      bc,32
        ld      e,16
.loop1:
        push    hl

        ld      d,15
.loop2:
        ld      [hl],a

        inc     a
        add     hl,bc

        dec     d
        jr      nz,.loop2

        inc     a

        ld      [hl],$ff
        add     hl,bc
        ld      [hl],$ff
        add     hl,bc
        ld      [hl],$ff

        pop     hl

        inc     hl

        dec     e
        jr      nz,.loop1

        ret

.filledges:
        push    hl
        dec     hl
        dec     hl
        call    .fillcol
        inc     hl
        call    .fillcol
        ld      bc,17
        add     hl,bc
        call    .fillcol
        inc     hl
        call    .fillcol
        pop     hl
        ret

.fillcol:
        push    hl

        ld      a,18
        ld      bc,32
.loop5:
        ld      [hl],$ff
        add     hl,bc

        dec     a
        jr      nz,.loop5

        pop     hl
        ret



; *** Turn screen off ***

ScreenOff:
        ld      hl,rLCDC
        bit     7,[hl]          ; Is LCD already off?
        ret     z               ; yes, exit

        ld      a,[rIE]
        push    af
        res     0,a
        ld      [rIE],a         ; Disable vblank interrupt if enabled

.loop:  ld      a,[rLY]         ; Loop until in first part of vblank
        cp      145
        jr      nz,.loop

        res     7,[hl]          ; Turn the screen off

        pop     af
        ld      [rIE],a         ; Restore the state of vblank interrupt
        ret

; *** Set background palettes ***
; Entry: HL = Pointer to BG palettes

SetCGB_BGP:
        ld      a,$80
        ld      [rBCPS],a

        ld      bc,$4069        ; b = 64, c = $69
.loop:
        ld      a,[hl+]
        ldh      [c],a
        dec     b
        jr      nz,.loop

        ret

; *** Set Object palettes ***
; Entry: HL = Pointer to OBJ (sprite) palettes

SetCGB_OBJP:

        ld      a,$80
        ld      [rOCPS],a

        ld      bc,$4069        ; b = 64, c = $69
.loop:
        ld      a,[hl+]
        ldh      [c],a
        dec     b
        jr      nz,.loop

        ret

; *** Fill GBC Attribute memory ***


FillCGBAttrPage1:
        ld      hl,_SCRN0
        ld      c,$0
        jr      _FillCGBAP

FillCGBAttrPage2:
        ld      hl,_SCRN1
        ld      c,$8

_FillCGBAP:
        ld      a,1
        ld      [rVBK],a

        ld      a,c
.memc0:
        ld      b,18
.memc1:

        ld      c,20
.memc2:
        ld      [hl+],a

        dec     c
        jr      nz,.memc2

        ld      de,12
        add     hl,de

        dec     b
        jr      nz,.memc1

        xor     a
        ld      [rVBK],a

        ret

; *** Setup GBC Attribute memory with map ***

SetCGBAttrMap1:
        ld      de,_SCRN0+2
        ld      c,0
        jr      _SetAttrMp

SetCGBAttrMap2:
        ld      de,_SCRN1+2
        ld      c,8

_SetAttrMp:
        ld      a,1
        ld      [rVBK],a

.memc0:
        ld      b,8  ;10
.memc1:
        push    bc

        push    hl
        push    de

; Do left nybble
        ld      b,15 ;18
.memc2:
        ld      a,[hl]
        swap    a
        and     $f
        or      c
        ld      [de],a

        push    hl
        ld      hl,32
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        push    de
        ld      de,8  ;10
        add     hl,de
        pop     de

        dec     b
        jr      nz,.memc2

        pop     de
        pop     hl
        inc     de
        push    hl
        push    de

; Do right nybble
        ld      b,15 ;18
.memc3:
        ld      a,[hl]
        and     $f
        or      c
        ld      [de],a

        push    hl
        ld      hl,32
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        push    de
        ld      de,8  ;10
        add     hl,de
        pop     de

        dec     b
        jr      nz,.memc3

        pop     de
        pop     hl
        inc     hl
        inc     de

        pop     bc

        dec     b
        jr      nz,.memc1

        xor     a
        ld      [rVBK],a

        ret

; Copy char map to screen
; Entry: HL = map in rom
;        DE = Screen Addr

Copy20x18:
        ld      b,18

Copy20xB:
        ld      c,20
.loop:
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop

        push    hl
        ld      hl,12
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl
        dec     b
        jr      nz,Copy20xB

        ret


ToggleCPUSpeed:
        di

        ld      hl,rIE
        ld      a,[hl]
        push    af

        xor     a
        ld      [hl],a         ;disable interrupts
        ld      [rIF],a

        ld      a,$30
        ld      [rP1],a

        ld      a,1
        ld      [rKEY1],a

        stop

        pop     af
        ld      [hl],a

        ei
        ret

Randomize:
; Increase randomness of random number generator

        ld      a,[rLY]
        ld      b,a
        ld      a,[rDIV]
        ld      c,a
        ld      a,[RandomSeed]
;        add     b
        add     c
        add     c
        add     c
        add     c
        ld      [RandomSeed],a
        ret

RandomFrom0To63:
        call    RandomNumber
        and     $3f
        ret

RandomFrom0To127:
        call    RandomNumber
        and     $7f
        ret

RandomFrom0To159:
        call    RandomNumber
        cp      160
        jr      nc,RandomFrom0To159
        ret

RandomFrom0To143:
        call    RandomNumber
        cp      144
        jr      nc,RandomFrom0To143
        ret

RandomNumber:
	push	hl

        ld      hl,RandomSeed
        inc     [hl]
        ld      a,[hl]

	ld	hl,.table
        add     l
        ld      l,a
        jr      nc,.nocarry
        inc     h
.nocarry:

	ld	a,[hl]
;        and     $7f
        pop     hl
	ret

.table
	db	$3B,$02,$B7,$6B,$08,$74,$1A,$5D,$21,$99,$95,$66,$D5,$59,$05,$42
	db	$F8,$03,$0F,$53,$7D,$8F,$57,$FB,$48,$26,$F2,$4A,$3D,$E4,$1D,$D9
	db	$9D,$DC,$2F,$F5,$92,$5C,$CC,$00,$73,$15,$BF,$B1,$BB,$EB,$9E,$2E
	db	$32,$FC,$4B,$CD,$A7,$E6,$C2,$10,$11,$80,$52,$B2,$DA,$77,$4F,$EC
	db	$13,$54,$64,$ED,$94,$8C,$C6,$9A,$19,$9F,$75,$FA,$AA,$8D,$FE,$91
	db	$01,$23,$07,$C1,$40,$18,$51,$76,$3C,$BD,$2A,$88,$2D,$F1,$8A,$72
	db	$F6,$98,$35,$97,$68,$93,$B3,$0C,$82,$4E,$CB,$39,$D8,$5F,$C7,$D4
	db	$CE,$AE,$6D,$A3,$7C,$6A,$B8,$A6,$6F,$5E,$E5,$1B,$F4,$B5,$3A,$14
	db	$78,$FD,$D0,$7A,$47,$2C,$A8,$1E,$EA,$2B,$9C,$86,$83,$E1,$7B,$71
	db	$F0,$FF,$D1,$C3,$DB,$0E,$46,$1C,$C9,$16,$61,$55,$AD,$36,$81,$F3
	db	$DF,$43,$C5,$B4,$AF,$79,$7F,$AC,$F9,$37,$E7,$0A,$22,$D3,$A0,$5A
	db	$06,$17,$EF,$67,$60,$87,$20,$56,$45,$D7,$6E,$58,$A9,$B0,$62,$BA
	db	$E3,$0D,$25,$09,$DE,$44,$49,$69,$9B,$65,$B9,$E0,$41,$A4,$6C,$CF
	db	$A1,$31,$D6,$29,$A2,$3F,$E2,$96,$34,$EE,$DD,$C0,$CA,$63,$33,$5B
	db	$70,$27,$F7,$1F,$BE,$12,$B6,$50,$BC,$4D,$28,$C8,$84,$30,$A5,$4C
	db	$AB,$E9,$8E,$E8,$7E,$C4,$89,$8B,$0B,$24,$85,$3E,$38,$04,$D2,$90


DefaultCGBPalettes:
        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black

        RGBSet  255,255,255     ; White
        RGBSet  255,255,0       ; Yellow
        RGBSet  255,0,0         ; Red
        RGBSet  0,0,0           ; Black



; Y offset table used by point drawing routines.

YTable:
 DW $0000,$0002,$0004,$0006,$0008,$000A
 DW $000C,$000E,$0140,$0142,$0144,$0146
 DW $0148,$014A,$014C,$014E,$0280,$0282
 DW $0284,$0286,$0288,$028A,$028C,$028E
 DW $03C0,$03C2,$03C4,$03C6,$03C8,$03CA
 DW $03CC,$03CE,$0500,$0502,$0504,$0506
 DW $0508,$050A,$050C,$050E,$0640,$0642
 DW $0644,$0646,$0648,$064A,$064C,$064E
 DW $0780,$0782,$0784,$0786,$0788,$078A
 DW $078C,$078E,$08C0,$08C2,$08C4,$08C6
 DW $08C8,$08CA,$08CC,$08CE,$0A00,$0A02
 DW $0A04,$0A06,$0A08,$0A0A,$0A0C,$0A0E
 DW $0B40,$0B42,$0B44,$0B46,$0B48,$0B4A
 DW $0B4C,$0B4E,$0C80,$0C82,$0C84,$0C86
 DW $0C88,$0C8A,$0C8C,$0C8E,$0DC0,$0DC2
 DW $0DC4,$0DC6,$0DC8,$0DCA,$0DCC,$0DCE
 DW $0F00,$0F02,$0F04,$0F06,$0F08,$0F0A
 DW $0F0C,$0F0E,$1040,$1042,$1044,$1046
 DW $1048,$104A,$104C,$104E,$1180,$1182
 DW $1184,$1186,$1188,$118A,$118C,$118E
 DW $12C0,$12C2,$12C4,$12C6,$12C8,$12CA
 DW $12CC,$12CE,$1400,$1402,$1404,$1406
 DW $1408,$140A,$140C,$140E,$1540,$1542
 DW $1544,$1546,$1548,$154A,$154C,$154E

        SECTION "Font Data", ROM0        ;SECTION "Font Data", DATA

Font:
        incbin  "font.til"


        SECTION "Pattern Data", ROM0       ;SECTION "Pattern Data", DATA[$4000]

; Street tree pattern
Patterns:
; leaves

        rept    16

        db      $00,$aa,$00,$55,$00,$aa,$00,$55
        db      $00,$aa,$00,$55,$00,$aa,$00,$55

        db      $00,$ff,$00,$aa,$00,$ff,$00,$55
        db      $00,$ff,$00,$aa,$00,$ff,$00,$55

        db      $00,$aa,$00,$55,$00,$aa,$00,$55
        db      $00,$aa,$00,$55,$00,$aa,$00,$55

        db      $00,$ff,$00,$aa,$00,$ff,$00,$55
        db      $00,$ff,$00,$aa,$00,$ff,$00,$55

        db      $00,$ff,$00,$ff,$00,$aa,$00,$ff
        db      $00,$ff,$00,$ff,$00,$55,$00,$ff

        db      $00,$ff,$00,$ff,$00,$ff,$00,$ff
        db      $00,$ff,$00,$ff,$00,$ff,$00,$ff
; Trunk
        db      $aa,$55,$ff,$00,$aa,$55,$ff,$00
        db      $aa,$55,$ff,$00,$aa,$55,$ff,$00

        db      $aa,$55,$ff,$00,$aa,$55,$ff,$00
        db      $aa,$55,$ff,$00,$aa,$55,$ff,$00

        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00
        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00

        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00
        db      $55,$aa,$ff,$00,$ff,$00,$ff,$00

        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00
        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00

        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00
        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00

        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00
        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00

        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00
        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00

        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00
        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00

        db      $aa,$55,$ff,$00,$ff,$00,$ff,$00
        db      $ff,$00,$ff,$00,$ff,$00,$ff,$00

        endr



        SECTION "8x8 Texture Data", ROM0        ;SECTION "8x8 Texture Data", DATA[$6000]
Textures:
;        rept    360
;        db      $cc,$cc,$cc,$cc,$33,$33,$33,$33
;        db      $cc,$cc,$cc,$cc,$33,$33,$33,$33
;        endr

        rept    16
        db      $00,$21,$33,$0c,$33,$c0,$00,$12
        db      $00,$12,$33,$c0,$33,$0c,$00,$21
        endr

        rept    16
        db      $08,$fc,$18,$7e,$32,$fd,$64,$fb
        db      $c0,$ef,$81,$e7,$40,$b3,$20,$d9
        endr

        rept    16
        db      $cc,$cc,$cc,$cc,$33,$33,$33,$33
        db      $cc,$cc,$cc,$cc,$33,$33,$33,$33
        endr

        rept    16
        db      $c0,$c0,$c0,$c0,$0c,$0c,$0c,$0c
        db      $c0,$c0,$c0,$c0,$0c,$0c,$0c,$0c
        endr

        rept    16
        db      $aa,$aa,$55,$55,$aa,$aa,$55,$55
        db      $aa,$aa,$55,$55,$aa,$aa,$55,$55
        endr

        rept    16
        db      $f1,$f1,$01,$01,$01,$01,$01,$01
        db      $1f,$1f,$10,$10,$10,$10,$10,$10
        endr

        rept    16
        db      $00,$aa,$00,$55,$00,$aa,$00,$55
        db      $00,$aa,$00,$55,$00,$aa,$00,$55
        endr

        rept    16
        db      $aa,$aa,$55,$55,$aa,$aa,$55,$55
        db      $aa,$aa,$55,$55,$aa,$aa,$55,$55
        endr
