;-----------------------------------------------------------------------------
; Aquarius+ system ROM
;-----------------------------------------------------------------------------
; By Frank van den Hoef
;
; Based on AQUBASIC source code by Bruce Abbott:
; http://bhabbott.net.nz/micro_expander.html
;
; Useful links:
; - Excellent Aquarius S2 ROM disassembly by Curtis F Kaylor:
; https://github.com/RevCurtisP/Aquarius/blob/main/disassembly/aquarius-rom.lst
;
; Extra BASIC commands:
; EDIT   - ** Not supported **
; CLS    - Clear screen
; LOCATE - Position on screen
; OUT    - Output data to I/O port
; PSG    - Program PSG register, value
; DEBUG  - ** Not supported **
; CALL   - Call machine code subroutine
; LOAD   - Load file from USB disk
; SAVE   - Save file to USB disk
; DIR    - Display USB disk directory with wildcard
; MKDIR  - Create directory
; DEL    - Delete file
; CD     - Change directory
;
; Extra BASIC functions:
; IN()   - Get data from I/O port
; JOY()  - Read joystick
; HEX$() - Convert number to hexadecimal string
;-----------------------------------------------------------------------------

    include "regs.inc"

    org     $2000
    jp      _reset          ; Called from main ROM at reset vector
    jp      _coldboot       ; Called from main ROM for cold boot
    jp      _start_cart

;-----------------------------------------------------------------------------
; Reset vector
;
; CAUTION: stack isn't available at this point, so don't use any instruction
;          that uses the stack.
;-----------------------------------------------------------------------------
_reset:
    ; Set up temp stack in text line buffer
    ld      sp, $38A0

    ; Initialize banking registers
    ld      a, 0 | BANK_OVERLAY | BANK_READONLY
    out     (IO_BANK0), a
    ld      a, 33
    out     (IO_BANK1), a
    ld      a, 34
    out     (IO_BANK2), a
    ld      a, 19
    out     (IO_BANK3), a

    ; Init video mode
    ld      a, 1
    out     (IO_VCTRL), a

    ; Init palette 0
    ld      hl, .default_palette
    ld      c, IO_VPALSEL
    ld      b, 0
    ld      d, 32
.palloop:
    out     (c), b
    ld      a, (hl)
    out     (IO_VPALDATA), a
    inc     hl
    inc     b
    dec     d
    jr      nz, .palloop

    ; Initialize character RAM
    call    init_charram

    ; Initialize ESP
    ld      a, ESPCMD_RESET
    call    esp_cmd

    ; Back to system ROM init
    jp      JMPINI

.default_palette:
    dw $111, $F11, $1F1, $FF1, $22E, $F1F, $3CC, $FFF
    dw $CCC, $3BB, $C2C, $419, $FF7, $2D4, $B22, $333

;-----------------------------------------------------------------------------
; Character RAM initialization
;-----------------------------------------------------------------------------
init_charram:
    ; Save current bank 1/2
    in      a, (IO_BANK1)
    push    a
    in      a, (IO_BANK2)
    push    a

    ; Temporarily set up mappings for character RAM and character ROM
    ld      a, 21           ; Page 21: character RAM
    out     (IO_BANK1), a
    ld      a, 0            ; Page 0: first page of flash ROM
    out     (IO_BANK2), a

    ; Copy character ROM to character RAM
    ld      de, BANK1_BASE
    ld      hl, BANK2_BASE + $3000
    ld      bc, 2048
    ldir

    ; Restore bank 1/2
    pop     a
    out     (IO_BANK2), a
    pop     a
    out     (IO_BANK1), a
    ret

;-----------------------------------------------------------------------------
; Cold boot entry point
;-----------------------------------------------------------------------------
_coldboot:
    ; Set memory size
    ld      hl, BASIC_RAM_END   ; Top of public RAM
    ld      (MEMSIZ), hl        ; MEMSIZ, Contains the highest RAM location
    ld      de, -1024           ; Subtract 1k for strings space
    add     hl, de
    ld      (TOPMEM), hl        ; TOPMEM, Top location to be used for stack
    ld      hl, BASTXT-1
    ld      (hl), $00           ; NULL at start of BASIC program
    inc     hl
    ld      (TXTTAB), hl        ; Beginning of BASIC program text
    call    SCRTCH              ; ST_NEW2 - NEW without syntax check

    ; Install BASIC HOOK
    ld      hl, hook_handler
    ld      (HOOK), hl

    ; Show our copyright message
    call    PRNTIT              ; Print copyright string in ROM
    ld      hl, .str_basic      ; Print ROM version
    call    STROUT
    ld      a, ESPCMD_VERSION
    call    esp_cmd
.print_version:
    call    esp_get_byte
    or      a
    jr      z, .print_done
    call    TTYCHR
    jr      .print_version
.print_done:
    call    CRDO
    call    CRDO

    jp      INITFF              ; Continue in ROM

.str_basic:
    db $0D, $0A
    db "Aquarius+ System ", 0

;-----------------------------------------------------------------------------
; Cartridge start entry point - A hold scramble value
;-----------------------------------------------------------------------------
_start_cart:
    cp      $00
    jp      nz, .descramble
    jp      XINIT

.descramble:
    ; Map destination RAM in bank2
    ld      a, 35
    out     (IO_BANK2), a

    ; Copy ROM cartridge to RAM
    ld      de, $8000
    ld      hl, $C000
    ld      bc, $4000
    ldir

    ; Map RAM in bank3
    ld      a, 35
    out     (IO_BANK3), a

    ; Descramble and start ROM
    jp      descramble_rom

;-----------------------------------------------------------------------------
; Hook handler
;-----------------------------------------------------------------------------
hook_handler:
    ; The hook index byte is stored after the RST $30 call. So SP currently
    ; points to this hook index byte. Retrieve the hook index byte into A
    ; and determine the correct return address.
    ex      (sp), hl            ; Save HL and get address of byte after RST $30
    push    af                  ; Save AF
    ld      a, (hl)             ; A = byte (RST $30 parameter)
    inc     hl                  ; Skip over byte after RST $30
    push    hl                  ; Push return address

    ; Find index in hook indexes table
    ld      hl, _hook_idxs
    push    bc
    ld      bc, _hook_handlers - _hook_idxs + 1
    cpir                        ; Find parameter in list
    ld      a, c                ; A = parameter number in list
    pop     bc

    ; Call handler from hook handlers table
    add     a, a                ; A * 2 to index WORD size vectors
    ld      hl, _hook_handlers
do_jump:
    add     a, l
    ld      l, a
    xor     a
    adc     a, h
    ld      h, a                ; HL += vector number
    ld      a, (hl)
    inc     hl
    ld      h, (hl)             ; Get vector address
    ld      l, a
    jp      (hl)                ; And jump to it will return to hook_exit

; End of hook handler
hook_exit:
    pop     hl                  ; Get return address
    pop     af                  ; Restore AF
    ex      (sp), hl            ; Restore HL and set return address
    ret                         ; Return to code after RST $30,xx

; Hook indexes we're handling
; NOTE: order is reverse of hook handlers table!
_hook_idxs:  ; xx      index caller            @addr  performing function:
    db      24      ; 5   RUN                 $06BE  starting BASIC program
    db      23      ; 4   exec_next_statement $0658  interpreting next BASIC statement
    db      22      ; 3   token_to_keyword    $05A0  expanding token to keyword
    db      10      ; 2   keyword_to_token    $0536  converting keyword to token
    db      27      ; 1   FUNCTIONS           $0A5F  executing a function

; Hook handler entry points
_hook_handlers:
    dw      hook_exit           ; 0 parameter not found in list
    dw      execute_function    ; 1 executing a function
    dw      keyword_to_token    ; 2 converting keyword to token
    dw      token_to_keyword    ; 3 expanding token to keyword
    dw      exec_next_statement ; 4 execute next BASIC statement
    dw      run_cmd             ; 5 run program

;-----------------------------------------------------------------------------
; Our commands and functions
;-----------------------------------------------------------------------------
BTOKEN:     equ $D4             ; Our first token number

TBLCMDS:
    db $80 + 'E'
    db "DIT"
    db $80 + 'C'
    db "LS"
    db $80 + 'L'
    db "OCATE"
    db $80 + 'O'
    db "UT"
    db $80 + 'P'
    db "SG"
    db $80 + 'D'
    db "EBUG"
    db $80 + 'C'
    db "ALL"
    db $80 + 'L'
    db "OAD"
    db $80 + 'S'
    db "AVE"
    db $80 + 'D'
    db "IR"
    db $80 + 'M'
    db "KDIR"
    db $80 + 'D'
    db "EL"
    db $80 + 'C'
    db "D"

    ; Functions
    db $80 + 'I'
    db "N"
    db $80 + 'J'
    db "OY"
    db $80 + 'H'
    db "EX$"
    db $80             ; End of table marker

TBLJMPS:
    dw ST_reserved     ; Previously EDIT
    dw ST_CLS
    dw ST_LOCATE
    dw ST_OUT
    dw ST_PSG
    dw ST_reserved     ; Previously DEBUG
    dw ST_CALL
    dw ST_LOAD
    dw ST_SAVE
    dw ST_DIR
    dw ST_MKDIR
    dw ST_DEL          ; Previously KILL
    dw ST_CD
TBLJEND:

BCOUNT: equ (TBLJEND - TBLJMPS) / 2     ; Number of commands

TBLFNJP:
    dw      FN_IN
    dw      FN_JOY
    dw      FN_HEX
TBLFEND:

FCOUNT: equ (TBLFEND - TBLFNJP) / 2  ; Number of functions

firstf: equ BTOKEN + BCOUNT          ; Token number of first function in table
lastf:  equ firstf + FCOUNT - 1      ; Token number of last function in table

;-----------------------------------------------------------------------------
; BASIC Function handler - hook 27
;-----------------------------------------------------------------------------
; called from $0a5f by RST $30,$1b
;
execute_function:
    pop     bc                  ; Get return address
    pop     af
    pop     hl
    push    bc                  ; Push return address back on stack
    cp      firstf - $B2        ; ($B2 = first system BASIC function token)
    ret     c                   ; Return if function number below ours
    cp      lastf - $B2 + 1
    ret     nc                  ; Return if function number above ours
    sub     firstf - $B2
    add     a, a                ; Index = A * 2
    push    hl
    ld      hl, TBLFNJP         ; Function address table
    jp      do_jump             ; JP to our function

;-----------------------------------------------------------------------------
; Convert keyword to token - hook 10
;-----------------------------------------------------------------------------
keyword_to_token:
    ld      a, b               ; A = current index

    cp      $CB                ; If < $CB then keyword was found in BASIC table
    jp      nz, hook_exit       ;    so return

    pop     bc                 ; Get return address from stack
    pop     af                 ; Restore AF
    pop     hl                 ; Restore HL
    push    bc                 ; Put return address back onto stack

    ; Set our own keyword table and let BASIC code use that instead
    ex      de, hl             ; HL = Line buffer
    ld      de, TBLCMDS - 1    ; DE = our keyword table
    ld      b, BTOKEN - 1      ; B = our first token
    jp      $04F9              ; Continue searching using our keyword table

;-----------------------------------------------------------------------------
; Convert token to keyword - hook 22
;
; This function will check if the passed token is one of the stock BASIC or
; our extra commands. If it one of our commands, we pass our command table
; to the ROM code.
;-----------------------------------------------------------------------------
token_to_keyword:
    pop     de
    pop     af                  ; Restore AF (token)
    pop     hl                  ; Restore HL (BASIC text)
    cp      BTOKEN              ; Is it one of our tokens?
    jr      nc, .expand_token   ; Yes, expand it
    push    de
    ret                         ; No, return to system for expansion

.expand_token:
    sub     BTOKEN - 1
    ld      c, a                ; C = offset to AquBASIC command
    ld      de, TBLCMDS         ; DE = table of AquBASIC command names
    jp      RESSRC              ; Print keyword indexed by C

;-----------------------------------------------------------------------------
; exec_next_statement - hook 23
;-----------------------------------------------------------------------------
exec_next_statement:
    pop     bc                  ; BC = return address
    pop     af                  ; AF = token, flags
    pop     hl                  ; HL = text
    jr      nc, .process        ; if NC then process BASIC statement
    push    bc
    ret                         ; else return to system

.process:
    ; Check if the token is own of our own, otherwise give syntax error
    sub     (BTOKEN) - $80
    jp      c, SNERR           ; SN error if < our 1st BASIC command token
    cp      BCOUNT              ; Count number of commands
    jp      nc, SNERR          ; SN error if > out last BASIC command token

    ; Execute handler 
    rlca                        ; A*2 indexing WORDs
    ld      c, a
    ld      b, $00              ; BC = index
    ex      de, hl
    ld      hl, TBLJMPS         ; HL = our command jump table
    jp      $0665               ; Continue with exec_next_statement

;-----------------------------------------------------------------------------
; RUN command - hook 24
;-----------------------------------------------------------------------------
run_cmd:
    pop     af                 ; Clean up stack
    pop     af                 ; Restore AF
    pop     hl                 ; Restore HL
    jp      z, RUNC            ; If no argument then RUN from 1st line

    push    hl
    call    FRMEVL             ; Get argument type
    pop     hl

    ld      a, (VALTYP)
    dec     a                  ; 0 = string
    jp      z, run_file

    ; RUN with line number
    call    CLEARC             ; Init BASIC run environment
    ld      bc, NEWSTT
    jp      RUNC2              ; GOTO line number

;-----------------------------------------------------------------------------
; Not implemented statement - do nothing
;-----------------------------------------------------------------------------
ST_reserved:
    ret

;-----------------------------------------------------------------------------
; CLS statement
;-----------------------------------------------------------------------------
ST_CLS:
    ; Clear screen
    ld      a, 11
    OUTCHR
    ret

;-----------------------------------------------------------------------------
; OUT statement
; syntax: OUT port, data
;-----------------------------------------------------------------------------
ST_OUT:
    call    FRMNUM              ; Get/evaluate port
    call    FRCINT              ; Convert number to 16 bit integer (result in DE)
    push    de                  ; Stored to be used in BC

    ; Expect comma
    SYNCHK  ","

    call    GETBYT              ; Get/evaluate data
    pop     bc                  ; BC = port
    out     (c), a              ; Out data to port
    ret

;-----------------------------------------------------------------------------
; LOCATE statement
; Syntax: LOCATE col, row
;-----------------------------------------------------------------------------
ST_LOCATE:
    call    GETBYT              ; Read number from command line (column). Stored in A and E
    push    af                  ; Column store on stack for later use
    dec     a
    cp      38                  ; Compare with 38 decimal (max cols on screen)
    jp      nc, FCERR           ; If higher then 38 goto FC error

    ; Expect comma
    SYNCHK  ','

    call    GETBYT              ; Read number from command line (row). Stored in A and E
    cp      $18                 ; Compare with 24 decimal (max rows on screen)
    jp      nc,FCERR            ; If higher then 24 goto FC error

    inc     e
    pop     af                  ; Restore column from store
    ld      d, a                ; Column in register D, row in register E
    ex      de, hl              ; Switch DE with HL
    call    .goto_hl            ; Cursor to screen location HL (H=col, L=row)
    ex      de, hl
    ret

.goto_hl:
    push    af

    ; Restore character behind cursor
    push    hl
    exx
    ld      hl, (CURRAM)        ; CHRPOS - address of cursor within matrix
    ld      a, (CURCHR)         ; BUFO - storage of the character behind the cursor
    ld      (hl), a             ; Put original character on screen
    pop     hl

    ; Calculate new cursor location
    ld      a, l
    add     a, a
    add     a, a
    add     a, l
    ex      de, hl
    ld      e, d
    ld      d, $00
    ld      h, d
    ld      l, a
    ld      a, e
    dec     a
    add     hl, hl
    add     hl, hl
    add     hl, hl              ; HL is now 40 * rows
    add     hl, de              ; Added the columns
    ld      de, SCREEN          ; Screen character-matrix (= 12288 dec)
    add     hl, de              ; Putting it all together
    jp      TTYFIS              ; Save cursor position and return

;-----------------------------------------------------------------------------
; PSG statement
; syntax: PSG register, value [, ... ]
;-----------------------------------------------------------------------------
ST_PSG:
    cp      $00
    jp      z, MOERR         ; MO error if no args

.psgloop:
    ; Get PSG register to write to
    call    GETBYT           ; Get/evaluate register
    cp      16
    jr      nc, .psg2

    out     (IO_PSG1ADDR), a ; Set the PSG register

    ; Expect comma
    SYNCHK  ','

    ; Get value to write to PSG register
    call    GETBYT           ; Get/evaluate value
    out     (IO_PSG1DATA), a ; Send data to the selected PSG register

.check_comma:
    ; Check for a comma
    ld      a, (hl)          ; Get next character on command line
    cp      ','              ; Compare with ','
    ret     nz               ; No comma = no more parameters -> return

    inc     hl               ; next character on command line
    jr      .psgloop         ; parse next register & value

.psg2:
    sub     16
    out     (IO_PSG2ADDR), a ; Set the PSG register

    ; Expect comma
    SYNCHK  ','

    ; Get value to write to PSG register
    call    GETBYT           ; Get/evaluate value
    out     (IO_PSG2DATA), a ; Send data to the selected PSG register

    jr      .check_comma

;-----------------------------------------------------------------------------
; IN() function
; syntax: var = IN(port)
;-----------------------------------------------------------------------------
FN_IN:
    pop     hl
    inc     hl

    call    PARCHK           ; Read number from line - ending with a ')'
    ex      (sp), hl
    ld      de, LABBCK       ; Return address
    push    de               ; On stack
    call    FRCINT           ; Evaluate formula pointed by HL, result in DE
    ld      b, d
    ld      c, e             ; BC = port

    ; Read from port
    in      a, (c)           ; A = in(port)
    jp      SNGFLT           ; Return with 8 bit input value in variable var

;-----------------------------------------------------------------------------
; JOY() function
; syntax: var = JOY(stick)
;    stick - 0 will read left or right
;          - 1 will read left joystick only
;          - 2 will read right joystick only
;-----------------------------------------------------------------------------
FN_JOY:
    pop     hl             ; Return address
    inc     hl             ; skip rst parameter
    call    PARCHK         ; Read number from line - ending with a ')'
    ex      (sp), hl
    ld      de, LABBCK     ; set return address
    push    de
    call    FRCINT         ; FRCINT - evalute formula pointed by HL result in DE

    ld      a, e
    or      a
    jr      nz, .joy01
    ld      a, $03

.joy01:
    ld      e, a
    ld      bc, $00F7
    ld      a, $FF
    bit     0, e
    jr      z, .joy03
    ld      a, $0e
    out     (c), a
    dec     c
    ld      b, $FF

.joy02:
    in      a,(c)
    djnz    .joy02
    cp      $FF
    jr      nz, .joy05

.joy03:
    bit     1,e
    jr      z, .joy05
    ld      bc, $00F7
    ld      a, $0F
    out     (c), a
    dec     c
    ld      b, $FF

.joy04:
    in      a, (c)
    djnz    .joy04

.joy05:
    cpl
    jp      SNGFLT

;-----------------------------------------------------------------------------
; HEX$() function
; eg. A$=HEX$(B)
;-----------------------------------------------------------------------------
FN_HEX:
    pop     hl
    inc     hl
    call    PARCHK          ; Evaluate parameter in brackets
    ex      (sp), hl
    ld      de, LABBCK      ; Return address
    push    de              ; On stack
    call    FRCINT          ; Evaluate formula @HL, result in DE
    ld      hl, FPSTR       ; HL = temp string
    ld      a, d
    or      a               ; > zero ?
    jr      z, .lower_byte
    ld      a, d
    call    .hexbyte        ; Yes, convert byte in D to hex string
.lower_byte:
    ld      a, e
    call    .hexbyte        ; Convert byte in E to hex string
    ld      (hl), 0         ; Null-terminate string
    ld      hl, FPSTR
.create_string:
    jp      $0E2F           ; Create BASIC string

.hexbyte:
    ld      b, a
    rra
    rra
    rra
    rra
    call    .hex
    ld      a, b
.hex:
    and     $0F
    cp      10
    jr      c, .chr
    add     7
.chr:
    add     '0'
    ld      (hl), a
    inc     hl
    ret

;-----------------------------------------------------------------------------
; ST_CALL
;
; syntax: CALL address
; address is signed integer, 0 to 32767   = $0000-$7FFF
;                            -32768 to -1 = $8000-$FFFF
;
; on entry to user code, HL = text after address
; on exit from user code, HL should point to end of statement
;-----------------------------------------------------------------------------
ST_CALL:
    call    FRMNUM           ; Get number from BASIC text
    call    FRCINT           ; Convert to 16 bit integer
    push    de
    ret                      ; Jump to user code, HL = BASIC text pointer

;-----------------------------------------------------------------------------
; DOS commands
;-----------------------------------------------------------------------------
    include "espdos.asm"

;-----------------------------------------------------------------------------
; Convert lower-case to upper-case
; in-out; A = char
;-----------------------------------------------------------------------------
to_upper:
    cp      'a'             ; >='a'?
    ret     c
    cp      'z'+1           ; <='z'?
    ret     nc
    sub     $20             ; a-z -> A-Z
    ret

;-----------------------------------------------------------------------------
; Print value in A as hex value
;-----------------------------------------------------------------------------
; printhex:
;     push    a

;     ; Print upper-nibble
;     srl     a
;     srl     a
;     srl     a
;     srl     a
;     call    .print

;     pop     a
;     push    a

;     ; Print lower-nibble
;     and     $0F
;     call    .print

;     pop     a
;     ret

; .print:
;     add     '0'
;     cp      ':'
;     jr      c, .print2
;     add     7
; .print2:
;     jp      TTYCHR

;-----------------------------------------------------------------------------
; Fill with $FF to start of Key Decode Tables
;-----------------------------------------------------------------------------
    assert !($2EFF<$)   ; ROM full!
    dc $2EFF-$+1,$FF

;-----------------------------------------------------------------------------
; Keyboard Decode Tables for S3 BASIC with Extended Keyboard Support
; Must be located at $2F00
;
; Non-printable keys generate High ASCII characters
;
; Key: PrtSc Pause PgUp PgDn Tab Right Up  SysRq Break End Home Menu Ins Left Down
; Hex:  $88   $89  $8A  $8B  $8C $8E   $8F  $98   $99  $9A $9B  $9C  $9D $9E  $9F
; Dec:  136   137  138  139  140 142   143  152   153  154 155  156  157 158  159
;
; Key: F1  F2  F3  F4  F5  F6  F7  F8  F9  F10 F11 F12    Function Keys are
; Hex: $80 $81 $82 $83 $84 $85 $86 $87 $90 $91 $92 $93    not implented yet
; Dec: 128 129 130 131 132 133 134 135 144 145 146 147
;
;-----------------------------------------------------------------------------

key_tables:
; Unshifted Keys
    byte    '=',$08,':',$0D,';','.',$9D,$7F ; Backspace, Return, INS DEL
    byte    '-','/','0','p','l',',',$8F,$8E ; CsrUp, CsrRt
    byte    '9','o','k','m','n','j',$9E,$9F ; CsrLf, CsrDn
    byte    '8','i','7','u','h','b',$9B,$9A ; Home, End
    byte    '6','y','g','v','c','f',$8A,$8B ; PgUp, PgDn
    byte    '5','t','4','r','d','x',$89,$88 ; Pause, PrtScr
    byte    '3','e','s','z',' ','a',$9C,$8C ; Menu, Tab
    byte    '2','w','1','q', 0 , 0 , 0 ,$8D ; GUI
; Shifted Keys
    byte    '+',$5C,'*',$0D,'@','>',$00,$00 ; Backslash, Return
    byte    '_','^','?','P','L','<',$00,$00
    byte    ')','O','K','M','N','J',$00,$00
    byte    '(','I',$27,'U','H','B',$00,$00 ; Apostrophe
    byte    '&','Y','G','V','C','F',$00,$00
    byte    '%','T','$','R','D','X',$00,$00
    byte    '#','E','S','Z',' ','A',$00,$00
    byte    $22,'W','!','Q', 0 , 0 , 0 , 0  ; Quotation Mark
; Control Keys
    byte    $1B,$7F,$1D,$0D,$A0,$7D,$00,$00 ; ESC DEL GS  CR  NUL  }
    byte    $1F,$1E,$1C,$10,$0C,$7B,$00,$00 ; GS  RS  FS  DLE FF   {
    byte    $5D,$0F,$0B,$0D,$0E,$0A,$00,$00 ;  ]  SI  VT  CR  SO  LF
    byte    $5B,$09,$60,$15,$08,$02,$00,$00 ;  [  Tab  `  NAK BS  SOH
    byte    $8E,$19,$07,$16,$03,$06,$99,$00 ; rt  EM  BEL SYN ETX ACK Break
    byte    $9F,$14,$8F,$12,$04,$18,$00,$00 ; dn  DC4 up  DC2 EOT CAN
    byte    $9E,$05,$13,$1A,' ',$01,$00,$00 ; lft ENC DC3 SUB     SOH
    byte    $7E,$17,$7C,$11, 0 , 0 , 0 , 0  ;  ~  ETB  |  DC1
; Alt Keys
    byte    $93,$DA,$00,$0D,$D6,$DF,$00,$00 ; F12 Grph\  RTN  BoxVt BoxBR BoxBL
    byte    $92,$CA,$91,$AC,$DD,$CC,$00,$00 ; F11 Grph/  F10  BoxHz BoxBt BoxRt
    byte    $90,$CE,$C8,$CF,$D9,$CD,$00,$00 ; F9  BoxTR BoxCt BoxBL BalLr BoxLf
    byte    $87,$DC,$86,$DE,$C9,$C7,$00,$00 ; F8  BoxTp  F7   BoxTL BalUR BalLL
    byte    $85,$97,$D7,$C2,$DB,$D2,$00,$00 ; F6   F16  BalUL BalBt BalRt BalTp
    byte    $84,$96,$83,$95,$CB,$D8,$00,$00 ; F5   F15   F4    F14  BalLf GrphX
    byte    $82,$94,$C5,$C6,' ',$C4,$00,$00 ; F3   F13  Dimnd  Dot        Squar
    byte    $81,$C1,$80,$C0, 0 , 0 , 0 , 0  ; F2  Trng\  F1   Trng/

;-----------------------------------------------------------------------------
; Verify ROM is correct length
;-----------------------------------------------------------------------------

    assert !($3000<>$)   ; Incorrect ROM! length

    end
