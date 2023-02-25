;*
;* Keypad Code
;*
;*   Started 15-April-97
;*
;* Initials: JF = Jeff Frohwein, CS = Carsten Sorensen
;*
;* V1.0 - 17-Jul-97 : Original Release - JF
;* V1.1 - 19-Jul-97 : Added Joypad equates - JF, inspired by CS
;*                  : Modified for new subroutine prefixes - JF
;* V1.2 - 16-Aug-97 : Output format similiar to CS - JF
;* V1.3 - 18-Aug-97 : Converted to newer 'hardware.inc' - JF
;*

;If all of these are already defined, don't do it again.

        IF      !DEF(KEYPAD_ASM)
KEYPAD_ASM  =  1 ;KEYPAD_ASM  SET  1

MACRO rev_Check_keypad_asm
;NOTE: REVISION NUMBER CHANGES MUST BE ADDED
;TO SECOND PARAMETER IN FOLLOWING LINE.
        IF      \1 > 1.3      ; <---- NOTE!!! PUT FILE REVISION NUMBER HERE
        WARN    "Version \1 or later of 'keypad.asm' is required."
        ENDC
        ENDM

        INCLUDE "hardware.inc"

SECTION "Keypad Code",ROM0        ;SECTION "Keypad Code",HOME

;***************************************************************************
;*
;* pad_Read - Read the joypad
;*
;* output:
;*   _PadData & A     - joypad matrix
;*   _PadDataEdge & B - edge data: which buttons were pressed since last time
;*                       this routine was called
;*
;***************************************************************************
pad_Read::
        ld      a,P1F_5
        ld      [rP1],a        ;turn on P15

        ld      a,[rP1]        ;delay
        ld      a,[rP1]
	cpl
        and     $0f
	swap	a
	ld	b,a

        ld      a,P1F_4
        ld      [rP1],a     ;turn on P14
        ld      a,[rP1]     ;delay
        ld      a,[rP1]
        ld      a,[rP1]
        ld      a,[rP1]
        ld      a,[rP1]
        ld      a,[rP1]
	cpl
        and     $0f
	or	b
        ld      b,a

	ld	a,[_PadData]
	xor	a,b
	and	a,b
	ld	[_PadDataEdge],a
	ld	a,b
	ld	[_PadData],a
        push    af

	ld	a,P1F_5|P1F_4
        ld      [rP1],a

        ld      a,[_PadDataEdge]
        ld      b,a
        pop     af
	ret

;*
;* Variables
;*

        SECTION "UtilityVars",WRAM0        ;SECTION "UtilityVars",BSS

_PadData::      DS      1
_PadDataEdge::  DS      1

        ENDC    ;keypad_asm

