
; Fast clear screen

TOT_TILES       equ     360

WaitAndClearRenderBuffer:

; Wait until done rendering & then
;  clear render buffer for next render.

.loop0: ld      a,[StartDMA]
        ld      b,a
        ld      a,[DMAState]
        or      b
        jr      nz,.loop0

ClearRenderBuffer:

        ld      hl,[sp+0]

 if RENDER_TO_VRAM
        ld      sp,$8000+(TOT_TILES*16)
 else
        ld      sp,$c000+(TOT_TILES*16)
 endc

        ld      de,$0000

        ld      b,TOT_TILES/4
.loop:

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc

 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc
 if RENDER_TO_VRAM
        di
        lcd_WaitVRAM2
 endc
        push    de
        push    de
        push    de
        push    de
 if RENDER_TO_VRAM
        ei
 endc

        dec     b
        jr      nz,.loop

        ld      sp,hl

        ret