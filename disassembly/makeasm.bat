@set makeasm_opt=
@if "%2"=="" goto :checkarg
set makeasm_opt=%1
shift

:checkarg
@if exist "aquarius-%1.lst" goto :makeasm
@echo Use argument s1, s2, ec, or ex.
@exit /b 9

:makeasm
python makeasm.py %makeasm_opt% aquarius-%1.lst %1basic.asm %1basic.bin
