# Mattel Aquarius ROM Disassembly Convesions

# Convert Annotated Aquarius ROM Disassembly to TASM Source Code
def makeasm(iname, oname):

  #TASM Substitution Dictionarys
  RST = {"START": "00H", "SYNCHK": "08H", "CHRGET": "10H", "OUTCHR": "18H",
         "COMPAR": "20H", "FSIGN": "28H", "HOOKDO": "30H", "USRFN": "38H"}
  FIX = {"IF": "SIF", "FOR": "SFOR"}
  
  ifile = open(iname, 'r')
  ofile = open(oname, 'w')

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
    
    #Remove Test Line Marker
    if line[:1] == ' ': line = ' ' + line[1:]
    
    #Remove Unreferenced Labels
    if line[18:19] == '{': line = line[:24] + '        ' + line[32:]
    
    #Remove Address and Object Code Prefix
    line = line[24:]
 
    #Replace RST operand for TASM
    if line[0:1] != ';' and line[8:16] == "rst     ":
      arg = line[16:24].rstrip()
      if arg in RST:
        line = line[:16] + RST[arg].ljust(8) + line[24:]
      else:
        print("Illegal RST operand %s in line %d" % (arg, lineno))

    #Write Line to ASM File
    ofile.write(line + '\n')

    if line[:12] == "        .end": break
    
  ofile.close()
  ifile.close()

# Convert Annotated Aquarius ROM Disassembly to TASM Source Code
def makesym(iname, oname):
  ifile = open(iname, 'r')
  ofile = open(oname, 'w')

  for line in ifile:
    line = line.rstrip()
    if len(line) == 0:      continue  #Ignore Blank Lines
    if line[0:] == ';':     continue  #Ignore Meta Comments
    if line[0:] == ':':     continue  #Ignore Temporary Labels
    if line[24:25] == ';':  continue  #Ignore Block Comments
    if line[18:19] == ';':  continue  #Ignore Unreferenced Labels
    if line[18:19] == ';':  continue  #Ignore Local Labels

    address = line[0:4]  #Extract Address
    if address == "    ":   continue  #No Address Found
    
    symbol = line[24:32].rstrip()     #Extract Symbol from Line
    if len(symbol) == 0:    continue  #No Symbol Found  
    if symbol[-1:] != ':':  continue  #Not a label
    label = symbol[:-1].ljust(8)      #Remove Colon from End 
    
    ofile.write(address + '    ' + label + '\n')

  ofile.close()
  ifile.close()
    
makeasm("aquarius-rom.lst", "s2basic.asm")  
#makesym("aquarius-rom.lst", "aquarius-rom.sym")
