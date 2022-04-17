# Mattel Aquarius Commented ROM Disassembly and Utilities

| File             | Description                                      |
| -----------      | -------------------------------------------------|
| aquarius-rom.lst | Commented S2 BASIC disassembly                   |
| aquarius-ext.lst | Commented Extended BASIC disassembly             |
| makeasm.py       | Utility to convert disassembly to TASM .asm file |

To convert disassembly to source file file:

    python makeasm.py

To assemble source file files:

    tasm -80 -b -s s2basic.asm
