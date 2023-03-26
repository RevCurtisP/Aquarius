# Split Annotated Aquarius ROM Disassembly into S1, S2, and Extended Disassemblies
# Python 2 and 3 compatible

# python splitasm.py

def splitasm(in_name, s1_name, s2_name, ex_name):
  
  eqlabels = []
  
  in_file = open(in_name, 'r')
  s1_file = open(s1_name, 'w')
  s2_file = open(s2_name, 'w')
  ex_file = open(ex_name, 'w')

  print("Creating %s, %s, %s from %s" % (s1_name, s2_name, ex_name, in_name)) 
  
  for line in in_file:

    line = line.rstrip()

    #Don't Copy Blank Lines
    blank = False if len(line) else True     
    if blank : continue
  
    #Don't Copy Meta Comments and Trailing Blank Lines
    meta = True if line[:1] == ';' else False
    if meta: continue
    
    #Set Destination Flags
    s1_flag = line[0:4].rstrip() != ""
    s2_flag = line[5:9].rstrip() != ""

    ex_char = line[10:11]
    ex_also = ex_char == "x"
    ex_only = ex_char == "X"
    ex_equl = ex_char == "="
    ex_dash = ex_char == "-"
    ex_flag = ex_also or ex_only or ex_equl or ex_dash
 
    #Remove Dashes from Address Columns
    addrs = line[:10]
    no_addr = True if addrs.count("-") or len(addrs.rstrip()) == 0 else False
    if no_addr: 
      addrs = " " * 9
      line = addrs + line[9:]
     
    #Get Machine Language Code Bytes
    code = line[12:23].rstrip()
    #print(code)

    #Do Extended BASIC Stuff
    if ex_flag:
      #Replace Flag Character at Column 11
      subst = ":" if len(code) else " "
      line = line[:10] + subst + line[11:]
      #print(line)
      #Generate Extended BASIC Output Line
      if ex_dash:
        ex_cmnt = line[29:]
        ex_flag = False
      elif ex_equl: 
        if ex_cmnt == None and len(line) > 62: ex_cmnt = line[63:]
        ex_line = " " * 21 + line[23:37] + "equ     $" + line [5:9] + "   " + ex_cmnt
        ex_cmnt = None
      else: 
        ex_line = line
    
    #Don't write collapsable comment lines
    if line[27:28] == "|": continue
 
    #Write Line to Destination File(s)
    if ex_flag: ex_file.write(line[:4] + line[9:] + "\n")
    if ex_only: continue
    if s1_flag: s1_file.write(line[:4] + line[9:] + "\n")
    if s2_flag: s2_file.write(line[5:] + "\n")
  
  print("Complete.")    
  
  s1_file.close()
  s2_file.close()
  ex_file.close()
  in_file.close()
  
if __name__ == "__main__":
  in_spec = "aquarius-rom.lst"
  s1_spec = "aquarius-s1.lst"
  s2_spec = "aquarius-s2.lst"
  ex_spec = "aquarius-ex.lst"

  splitasm(in_spec, s1_spec, s2_spec, ex_spec)
