
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
