Files updated to build on newer RGBDS versions (v0.9.3).

Maybe important to note is the -w and -t flags needed in rgblink to build correctly. This is to expand the WRAM0 section size from 4 KiB to the full 8 KiB and to expand the ROM0 section size from 16 KiB to the full 32 KiB assigned to ROM.

Also noteworthy mabe this change in apa.asm with the ```jr```:

```
MACRO lcd_WaitVRAM2
	.loop_lcd_WaitVRAM2\@                    ; <---+
        ld      a,[rSTAT]                        ;     |
        and     STATF_BUSY                       ;     |
        jr      nz, .loop_lcd_WaitVRAM2\@        ; ----+
        ENDM
```
