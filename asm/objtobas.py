#Convert .obj file to encoded text
import os
import sys


baslines = ['10 D=14598:IF PEEK(D)=64 GOTO 20',
            '12 FOR A=D TO D+%d:B=PEEK(A):IF B=0 THEN A=A+5:NEXT',
            '14 IF B<48 THEN A=A+1:C=PEEK(A):B=(B-32)*16+C-32',
            '16 POKE D,B:D=D+1:NEXT:POKE 14340,6:POKE 14341,57',
            '20 Z=USR(0)',
            '22 IF INKEY$="" GOTO 22'
           ]
#         '22 H$="0123456789ABCDEF":FOR A=14598 TO D-1:B=PEEK(A)',
#         '24 PRINT MID$(H$,INT(B/16)+1,1);MID$(H$,(BAND15)+1,1);" ";',
#         '26 NEXT:PRINT'
#        ]

objpath = sys.argv[1]
objdir, objbase = os.path.split(objpath)
objname, objext = os.path.splitext(objbase)
if objext == "": objpath += ".obj"
baspath = objdir + objname + ".bas.txt"
  
obj = open(objpath,'rb')     
bas = open(baspath,'w')
bas.write("NEW\n");
ba = obj.read() 
lineno = 1
remlen = 0
enclen = 0
for byte in ba: 
  if remlen > 63: 
    bas.write('\n')
    remlen = 0
    enclen += 6
  if remlen == 0: 
    bas.write("%d REM" % lineno)
    lineno += 1
  remlen += 1
  enclen += 1
  c = chr(byte)
  if c < '0' or c > 'z' or c in "@[]`":
    c = chr(byte//16+32) + chr((byte&15)+32)
    remlen += 1
    enclen +=1
  bas.write(c)
bas.write('\n')
for line in baslines: 
  if '%' in line: line = line % (enclen - 1)
  bas.write(line + '\n')
bas.write('RUN\n')
bas.close()
obj.close()
