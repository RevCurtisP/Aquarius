# Mattel Aquarius Assembly Language Programs and Utilities

| File             | Description                                         |
| -----------      | --------------------------------------------------- |
| csreen.asm       | USR() routine to save and load screen               |
| objtobas.py      | Utility to covert TASM object file to BASIC loader  |
| rempoker.bas.txt | Basic M/L load template                             |

To assemble .asm files:

    tasm -80 -b -s filename.asm
    
To convert object file to Basic loader:

    python objtobas.by filename
