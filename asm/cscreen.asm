;Aquarius Screen CSAVE/CLOAD
;Does not display prompts, or wait for key to be pressed
;The Screen File has Filename "@@@@@@" and exactly 2048 bytes of data
;Code is Relocatable, HL is preserved

CMPNAM  .equ    $1CED   ;Compare Filename
RDBYTE  .equ    $1B4D   ;Read Byte
RDHEAD  .equ    $1CD9   ;Read Header
WRBYTE  .equ    $1B8A   ;Write Byte
WRHEAD  .equ    $1D28   ;Prompt and Write Headwr
WRTAIL  .equ    $1C1C   ;Write Trailer

SCREEN  .equ    $3000   ;Screen RAM
FILNAM  .equ    $3851   ;Filename for CSAVE and CLOAD
FILNAF  .equ    $3857   ;Filename Read from Cassette

        .org    $3906
        .byte   '@'     ;M/L Extract Flag
;Entry Point for USR() - Argument = 0 for CLOAD, 1 for CSAVE
CSCRNU: rst     28H             ;Test USR Argument
;Entry Point for CALL - A = 0 for CLOAD, 1 for CSAVE
CSCRN:  or      a               ;Set Flag if Direct Call
        push    hl              ;Save Text Pointer
        push    af              ;Save Flags
        ld      hl,FILNAM    
        ld      b,6             ;store 6 '@' in FILNAM
        ld      c,'@'
NAMEL:  ld      (hl),c
        inc     hl
        djnz    NAMEL 
        pop     af              ;Restore Flags
        jr      z,LOAD          ;0 = CLOAD
SAVE:   call    WRHEAD          ;Write Header
        ld      hl,SCREEN       ;from start of Screen RAM
        ld      bc,$0800        ;to end of Color RAM
SAVEL:  ld      a,(hl)          ;Read Byte from Memory 
        call    WRBYTE          ;Write to Cassette
        inc     hl              ;Next Address
        dec     bc              ;Count down
        ld      a,b
        or      c
        jr      nz,SAVEL        ;Loop if Not done
        jp      WRTAIL          ;Write Trailer, Pop HL, Return
LOAD:   call    RDHEAD          ;Read Header
        ld      hl,FILNAF       ;Compare Filename from Cassette
        call    CMPNAM          ;with FILNAM
        jr      nz,LOAD         ;If Different, skip to Next File
        ld      hl,SCREEN       ;from start of Screen RAM
        ld      bc,$0800        ;to end of Color RAM
LOADL:  call    RDBYTE          ;Read Byte from Cassette
        ld      (hl),a          ;Write to Memory
        inc     hl              ;Next Address
        dec     bc              ;Count down
        ld      a,b
        or      c
        jr      nz,LOADL        ;Loop if Not Done
DONE:   pop     hl              ;Restore Text Pointer
RETURN: ret
ABORT:  pop     af
        jr      DONE
        .end