# Convert Annotated A`quarius ROM Disassembly to formatted HTML file
# Python 2 and 3 compatible


def iscomment(text):
  return True if text.lstrip()[:1] == ";" else False

def span(text, spanclass):
  return "<span class=\"%s\">%s</span>" % (spanclass, text)

def comment(text):
  if text[1] == "[":
      return span(text[0], "comment") + span(text[1:7], "source") + span(text[7:], "comment")
  else:
      return span(text, "comment")

def constant(text):
  space = text[:18]
  source = span(text[18:24],"source")
  label = text[24:32]
  mnemonic = span(text[32:40], "mnemonic")
  operand = text[40:48]
  tail = comment(text[48:])
  return space + source + label + mnemonic + tail

def code(text):
  address = span(text[0:10], "number")
  colon = span(text[10:12], "colon")
  hex = span(text[12:23], "hex")
  source = span(text[23:29], "source")
  head = address + colon + hex + source
  tail = text[29:]
  if iscomment(tail):
    return head + comment(tail)
  label = span(text[29:36], "label")
  mnemonic = span(text[36:44], "mnemonic")
  if text[53] == ";":
    operand = text[44:53]
    tail = comment(text[53:])
  elif text[63] == ";":
    operand = text[44:63]
    tail = comment(text[63:])
  elif text[69] == ";":
    operand = text[44:69]
    tail = span(text[69:], "comment")
  else:
    operand = text[44:]
    tail = ""
  return  head + label + mnemonic + operand + tail

def format(text):
  text = text.ljust(70)
  if len(text[0:9].rstrip()):
    text = code(text)
  else:
    text = constant(text)
  return text

def makeasm(iname, oname):

  ifile = open(iname, 'r')
  ofile = open(oname, 'w')

  ofile.write("<html>\n")
  ofile.write("<head>\n")

  ofile.write("<style>\n")
  ofile.write("body {background: black; color: White;}\n")
  ofile.write(".colon {color: Blue;}\n")
  ofile.write(".comment {color: LightGreen;}\n")
  ofile.write(".hex {color: Plum}\n")
  ofile.write(".label {color: Cyan;}\n")
  ofile.write(".mnemonic {color: CornflowerBlue;}\n")
  ofile.write(".number {color: LightBlue;}\n")
  ofile.write(".source {color: Coral;}\n")
  ofile.write("</style>\n")
  
  ofile.write("</head>\n")
  ofile.write("<body>\n")
  ofile.write("<pre>\n")

  lineno = 0
  
  for line in ifile:

    lineno += 1
  
    line = line.rstrip()
    
    if iscomment(line):
      line = span(line, "comment")
    elif len(line):
      line = format(line)      
          
    ofile.write(line + "\n")
  
  ofile.write("</pre>\n")
  ofile.write("</body>\n")
  ofile.write("</html>\n")

if __name__ == "__main__":
  import argparse
  parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument("infile", help="Input File Name (with extension)")
  parser.add_argument("outfile", help="Output File Name (with extension)")
  args = parser.parse_args()

  makeasm(args.infile, args.outfile)
