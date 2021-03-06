# Convert Annotated Aquarius ROM Disassembly to TASM Source Code

def convert(iname, oname):
  
  ifile = open(iname, 'r')
  ofile = open(oname, 'w')

  llblank = True
  llmeta = False
  llblock = False
  
  for line in ifile:
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

    #Write Line to ASM File
    ofile.write(line + '\n')

    if line[:12] == "        .end": break
    
  ofile.close()
  ifile.close()
  
convert("aquarius-rom.lst", "s2basic.asm")
  
