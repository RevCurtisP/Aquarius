# Convert Aquarius ROM Disassembly to TASM or ZMAC Source Code
# Python 2 and 3 compatible

# python makeasm.py -z aquarius-s1.lst s1basic.asm s1basic.bin
#
# zmac -o s1basic.cim s1basic.asm
# fc /b s1basic.cim aquarius-s1.rom
#
# python makeasm.py aquarius-s1.lst s1basic.asm s1basic.bin
#
# tasm -80 -b -s s1basic.asm
# fc /b s1basic.obj aquarius-s1.rom

# python makeasm.py -z aquarius-s2.lst s2basic.asm s2basic.bin
#
# zmac -o s2basic.cim s2basic.asm
# fc /b s2basic.cim aquarius-s2.rom
#
# python makeasm.py aquarius-s2.lst s2basic.asm s2basic.bin
#
# tasm -80 -b -s s2basic.asm
# fc /b s2basic.obj aquarius-s2.rom

# python makeasm.py -z aquarius-ec.lst ecbasic.asm ecbasic.bin
#
# zmac -o exbasic.cim exbasic.asm
# fc /b ecbasic.cim aquarius-ec.rom
#
# python makeasm.py aquarius-ec.lst ecbasic.asm ecbasic.bin
#
# tasm -80 -b -s ecbasic.asm
# fc /b ecbasic.obj aquarius-ec.rom

# python makeasm.py -z aquarius-ex.lst exbasic.asm exbasic.bin
#
# zmac -o exbasic.cim exbasic.asm
# fc /b exbasic.cim aquarius-ex.rom
#
# python makeasm.py aquarius-ex.lst exbasic.asm exbasic.bin
#
# tasm -80 -b -s exbasic.asm
# fc /b exbasic.obj aquarius-ex.rom

import re

def makeasm(iname, oname, bname, zmac):

  tasm = not zmac

  #Psuedo-Op Replacement Dictionary
  PSO = {"byte": ".byte", "end": ".end", "equ": ".equ", 
           "org": ".org", "set": ".set", "word": ".word"}
  
  RST = {"START": "00H", "SYNCHK": "08H", "CHRGET": "10H", "OUTCHR": "18H",
         "COMPAR": "20H", "FSIGN": "28H", "HOOKDO": "30H", "USRFN": "38H"}
  ARGS = {"'\\'": "$5A", "a,'\\'": "a,$5C", "';'": "59"}
  
  eqlabels = []
  
  ifile = open(iname, 'r')
  ofile = open(oname, 'w')
  bfile = open(bname, 'wb')

  print("Creating %s, %s from %s" % (oname, bname, iname)) 

  llblank = True
  llmeta = False
  llblock = False
  
  lineno = 0
  
  for line in ifile:

    lineno += 1
  
    line = line.rstrip()
    blank = False if len(line) else True     

    #Remove Trailing Blank Lines
    if blank and (llblank or llmeta or llblock): continue
    llblank = blank
  
    #Remove Meta Comments and Trailing Blank Lines
    if line[:1] == ';': 
      llmeta = True
      continue
    llmeta = False    
   
    #Remove Block Comments and Trailing Blank Lines
    if line[22:23] == '|': 
      llblock = True
      continue
    llblock = False
        
    #Extract Object Code Bytes and Write to .bin file
    objtext = line[7:18].replace(' ','')
    if objtext:
      try:
        objbytes = bytes.fromhex(objtext)
        bfile.write(objbytes)
      except:
        print("Error parsing object code '%s' in line %d\n" % (objtext, lineno))
    
    #Remove lines containing only object code
    if 5 < len(line) <19 and line[5:6] == ':': continue

    #Remove Unreferenced Labels
    if line[18:19] == '{': 
      if line[32:40].rstrip() in ["=", "equ"]: continue
      else: line = line[:24] + '        ' + line[32:]
    
    #Check for proper formatting
    if line[23:24] > ' ': print("Misaligned label in line %d" % lineno)
    if line[23:33] == ' ': print("Misaligned mnemonic in line %d" % lineno)
    
    #Remove Address and Object Code Prefix
    line = line[24:]
    
    #Replace operands that cause errors
    if line[0:1] != ';':
      arg = line[16:24].rstrip()
      if tasm and arg in ARGS:
        line = line[:16] + ARGS[arg].ljust(8) + line[24:]  
      if zmac and arg[:1] == "*":
        line = line[:16] + "$" +line[17:]  
      if zmac and "%" in arg:
        line = line[:16] + re.sub("\%([0-1]+)","\g<1>b",line[16:])
 
    #Get Instruction Mnemonic for Psuedo-Op and RST Conversions
    if line[0:1] != ';' and line[8:9] != ';':
      label = line[:8].rstrip()
      mnemonic = line[8:16].rstrip()
      if mnemonic.find(" ") > -1:
        print("Misaligned operand in line %d" % lineno)
        print(">" + mnemonic)
    else:
      mnemonic = None

    #Replace Psuedo-Ops
    if mnemonic == "=":
      if zmac:
        mnemonic = "defl"
      elif tasm:
        if label in eqlabels:
          mnemonic = "set"
        else:
          eqlabels.append(label)
          mnemonic = "equ"
          mnemonic = "equ"
    if tasm:
      if mnemonic and mnemonic in PSO:
        line = line[:8] + PSO[mnemonic].ljust(8) + line[16:]
        
    #Replace RST operand for TASM
    if tasm: 
      if line[0:1] != ';' and line[8:16] == "rst     ":
        arg = line[16:24].rstrip()
        if arg in RST:
          line = line[:16] + RST[arg].ljust(8) + line[24:]
        else:
          print("Illegal RST operand s in line %d" % (arg, lineno))

    #Write Line to ASM File
    ofile.write(line + '\n')

    if line[:12] == "        .end": break
  
  print("Complete.")    
  
  bfile.close()
  ofile.close()
  ifile.close()
  
if __name__ == "__main__":
  import argparse
  parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument("-z", action="store_true", help="Generate ZMAC Assembler Syntax")
  parser.add_argument("infile", help="Input File Name (with extension)")
  parser.add_argument("outfile", help="Output File Name (with extension)")
  parser.add_argument("binfile", help="Binary File Name (with extension)")
  args = parser.parse_args()

  makeasm(args.infile, args.outfile, args.binfile, args.z)
