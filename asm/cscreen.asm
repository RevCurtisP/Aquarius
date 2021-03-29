;Aquarius Screen CSAVE/CLOAD
;Does not display prompts, or wait for key to be pressed
;The Screen File has Filename "@@@@@@" and exactly 2048 bytes of data
;Code is Relocatable, HL is preserved

;tasm -80 -b -s cscreen.asm
;python objtobas.py cscreen

CMPNAM  .equ    $1CED   ;Compare Filename
RDHEAD  .equ    $1CD9   ;Read Header
RWMEM   .equ    $0CAD   ;Read/Write Memory
WRHEAD  .equ    $1D28   ;Prompt and Write Headwr

SCREEN  .equ    $3000   ;Screen RAM
TTYPOS  .equ    $3800
FILNAM  .equ    $3851   ;Filename for CSAVE and CLOAD
FILNAF  .equ    $3857   ;Filename Read from Cassette

        .org    $3906
        .byte   '@'     ;M/L Extract Flag
;Entry Point for USR() - Argument = 0 for CLOAD, 1 for CSAVE
CSCRNU: rst     28H             ;Test USR Argument
;Entry Point for CALL - A = 0 for CLOAD, 1 for CSAVE
CSCRN:  or      a               ;Set Flag if Direct Call
        push    hl              ;Save Text Pointer
        ld      hl,FILNAM    
        ld      b,6             ;store 6 '@' in FILNAM
        ld      c,'@'
NAMEL:  ld      (hl),c
        inc     hl
        djnz    NAMEL 
        push    af              ;Put CSAVE/CLOAD Flag on stack
        jr      z,LOAD          ;0 = CLOAD
SAVE:   call    WRHEAD          ;Write Header
        jr      RDWRT           ;Write Memory abd Trailer
LOAD:   call    RDHEAD          ;Read Header
        ld      hl,FILNAF       ;Compare Filename from Cassette
        call    CMPNAM          ;with FILNAM
        jr      nz,LOAD         ;If Different, skip to Next File
RDWRT:  ld      hl,SCREEN       ;Start of Screen RAM
        ld      de,TTYPOS       ;End of Color RAM plus 1
        jp      RWMEM           ;Read or Write memory and return        
        .end
