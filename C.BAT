rem cnvt -r
rgbasm -ic:\A\GB\include\ -oapa.obj apa.asm
IF ERRORLEVEL 1 goto error
xlink -tg -mmap -zff apa.lnk
rgbfix -v apa
cgbload -n -m 5 -ROM 256 apa.gb
rem gb apa.gb
rem edit g.asm
goto abc

:error
pause
rem edit g.asm

:abc
