100 REM Convert Disassembly to Assembly Source
110 S$="aquarius-rom.lst":REM Source File
120 D$="s2basic.asm":REM Destination File
140 RU=1:REM Remove Umsed Labels
200 OPEN S$ FOR INPUT AS #1
210 OPEN D$ FOR OUTPUT AS #2
290 LB=1:REM Last Line was Blank
300 IF EOF(1) THEN GOTO 500
310 LINE INPUT#1,L$
315 IF LEFT$(L$,1)=";" THEN LM=1:GOTO 300
320 IF LEFT$(L$,1)=":" THEN MID$(L$,1)=" "
325 LM=0:REM Reset Last Meta Flag
330 REM IF LEN(L$) THEN GOSUB 600
340 IF (L=0 OR LB) AND L$="" THEN GOTO 300
345 LB=(L$="")
350 IF RU THEN IF MID$(L$,19,1)="{" THEN MID$(L$,25,8)="        "
400 UL=MID$(L$,19,1)="{"
410 L$=MID$(L$,25)
470 L=L+1
475 IF (L AND 15)=0 THEN PRINT ".";
480 PRINT #2,L$
485 IF MID$(L$,9,8)=".end    " THEN GOTO 500
490 GOTO 300
500 CLOSE #2 
510 CLOSE #1
590 END
600 FOR I=1 TO LEN(L$)
610 IF MID$(L$,I)>" " THEN RETURN
620 NEXT
630 L$="":RETURN
900 SAVE "MAKEASM",A
