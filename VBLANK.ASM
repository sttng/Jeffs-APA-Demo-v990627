

vblank_int:
        push    af

        ld      a,[rLCDC]       ; Set BG Tiles = $8000-$87ff
        set     4,a
        ld      [rLCDC],a

 if RENDER_TO_VRAM
        xor     a
        ld      [StartDMA],a
 else
        ld      a,[DMAState]
        or      a               ; Is DMA in progress?
        jr      nz,.skip        ; yes

        ld      a,[StartDMA]
        or      a               ; Is there a request to start DMA?
        jr      z,.skip         ; no

        ld      a,1
        ld      [DMAState],a

        dec     a
        ld      [StartDMA],a    ; Clear 'start DMA' flag
.skip:


        ld      a,[DMAState]
        or      a               ; Should we do DMA ?
        jp      z,.vbexit       ; no

        ld      a,[rLCDC]
        rrca
        rrca
        rrca
        and     1
        xor     1
        ld      [rVBK],a        ; Set video bank for DMA

        ld      a,[DMAState]
        dec     a               ; Should we do DMA #2 ?
        dec     a
        jr      z,.vbdma2       ; yes

        dec     a               ; Should we do DMA #3 ?
        jr      z,.vbdma3       ; yes

        dec     a               ; Should we do DMA #4 ?
        jr      z,.vbdma4       ; yes

        ld      a,$c0
        ld      [rHDMA1],a               ; High Address value of source
        xor     a
        ld      [rHDMA2],a               ; Low Address value of source
        ld      a,$80
        ld      [rHDMA3],a               ; High Address value of destination
        xor     a
        ld      [rHDMA4],a               ; Low Address value of destination

        ld      a,$ff
        ld      [rHDMA5],a               ; 128 lines, HDMA

        ld      a,2
        ld      [DMAState],a
        jr      .vbexit

.vbdma2:
        ld      a,$c0+8
        ld      [rHDMA1],a               ; High Address value of source
        xor     a
        ld      [rHDMA2],a               ; Low Address value of source
        ld      a,$88
        ld      [rHDMA3],a               ; High Address value of destination
        xor     a
        ld      [rHDMA4],a               ; Low Address value of destination

        ld      a,$fe
        ld      [rHDMA5],a               ; 127 lines, HDMA

        ld      a,4
        ld      [DMAState],a
        jr      .vbexit

.vbdma3:
;        ld      a,NON_VIDEO_RAM+16
;        ld      [rHDMA1],a               ; High Address value of source
;        xor     a
;        ld      [rHDMA2],a               ; Low Address value of source
;        ld      a,$90
;        ld      [rHDMA3],a               ; High Address value of destination
;        xor     a
;        ld      [rHDMA4],a               ; Low Address value of destination
;
;        ld      a,128+104-1
;        ld      [rHDMA5],a               ; 128 lines, HDMA
;
;        ld      a,4
;        ld      [DMAState],a
        jr      .vbexit

.vbdma4:
        ld      a,[rLCDC]                ; Flip screens
        xor     $08
        ld      [rLCDC],a

        xor     a
        ld      [DMAState],a

.vbexit:

 endc

        pop     af
        reti