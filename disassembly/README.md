# Mattel Aquarius Annotated Dissasembly

| File             | Description                                             |
| ---------------- | ------------------------------------------------------- |
| aquarius-rom.lst | Combined Annotated Dissasembly                          |
| splitlst.py      | Split combined dissasembly into separate dissasemblies  |
| makeasm.bat      | Batch file to run makeasm.py                            | 
| makeasm.py       | Convert split dissasembly into assembly file            | 
| makehtml.bat     | Batch file to run makehtml.py                           | 
| makehtml.py      | Convert aquarius-rom.lst to a syntax colored HTML file  |

## Aquarius ROM image files

These are raw binary images of the actual Aquarius ROMs.

| Listing File    | Description                       |
| ----------------| --------------------------------- |
| aquarius-s1.lst | Aquarius BASIC S1                 | 
| aquarius-s2.lst | Aquarius BASIC S2                 |
| aquarius-ec.lst | Aquarius Extended BASIC cartridge |
| aquarius-ex.lst | Aquarius II Extended BASIC        |

## aquarius-rom.lst

(Almost) fully annotated ROM dissasembly. Contains both S1 and S2 BASIC, the
Extended BASIC cartridge, and Aquarius II Extended BASIC.

## splitlst.py
Creates four separate listing files from aquarius-rom.lst which can then be
converted to assembly language and binary image files using makeasm.py  

| Listing File    | Description                       |
| ----------------| --------------------------------- |
| aquarius-s1.lst | Aquarius BASIC S1                 | 
| aquarius-s2.lst | Aquarius BASIC S2                 |
| aquarius-ec.lst | Aquarius Extended BASIC cartridge |
| aquarius-ex.lst | Aquarius II Extended BASIC        |

It is run using the command line
  python splitlst.py

## makeasm.bat

Runs makeasm.py, creating an assembly language and binary files from the 
respective listing file. The listing file used and the files created are
specified using a two letter code. 

| Code | Listing File    | Assembly    | Binary      |
|  --  | ----------------| ------------|------------ |
|  s1  | aquarius-s1.lst | s1basic.asm | s1basic.bin |
|  s2  | aquarius-s2.lst | s2basic.asm | s2basic.bin |
|  ec  | aquarius-ec.lst | ecbasic.asm | ecbasic.bin |
|  ex  | aquarius-ex.lst | exbasic.asm | exbasic.bin |

It is run using the command line
  makeasm [-z] *code*
where *code* is one of the two letter codes in the table above and *-z*
is the optional command line argument to pass to makeasm.py

## makeasm.py

Reads one of the listing files created by splitlst.py and creates an
assembly language source file and binary image file. 

It is run using the command line
  python makeasm.py [-z] *lstfile* *asmfile* *binfile*
where *lstfile* is one of the listings created by splitasm.py, *asmfile* 
is the name of the assembly language source file to be created and
*binfile* is the name of the binary image file to be created. If the
command line option *-z* is used, the generated assembly language source
will be in ZMAC format, otherwise it will be in TASM format.

The binary image file is created from the hexadecimal machine code bytes
in columns 8 through 9 of the listing file. It can be compared against
the original ROM image to verify the hexadecimal machine code in the
listing file is correct.

## makehtml.py

Creates syntax colored HTML file aquarius-rom.html from aquarius-rom.lst

It is run using either of the following commands:
  makehtml
  python makehtml.py
  
