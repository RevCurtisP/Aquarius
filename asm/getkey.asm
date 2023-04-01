;Aquarius Key Read Replacement
;CTRL-Key combinations return actual control characters
;instead of expanding into BASIC keywords
;
;To assemble
;  tasm -80 -b -s getkey.asm
;  *ZMAC support to be added
;
;To assign to USR()
;POKE 14340,0:POKE 14341,128
;
;USR(0) returns key press as a string (like INKEY$)
;
;Control Key Assignments
; 
;
;
;
;
;Keyboard Layout 
;
; SHIFT    !   "   #   $  %    &  '   (   )   ?   _   +
;          1   2   3   4  5    6  7   8   9   0   -   =
;  CTRL    |   ~  lft up dn   rt  `   {   }  FS  US  ESC
;       
; SHIFT    Q   W   E   R   T   Y   U   I   O   P   ^   \
;          q   w   e   r   t   y   u   i   o   p   /  <--
;  CTRL  XOFF ETB ENQ DC2 DC4 EM  NAK Tab  SI DLE RS  DEL
;       
; SHIFT    A   S   D   F   G   H   J   K   L   @   *
;          a   s   d   f   g   h   j   k   l   ;   :
;  CTRL   SOH XON EOT ACK BEL BS  LF  VT  FF  NUL GS
;
; SHIFT        Z   X   C   V   B   N   M   <   >
;         SPC  z   x   c   v   b   n   m   ,   .  RTN
;  CTRL   alt SUB EM  ETX SYN STX SO  CR   {   }  menu
;

;BASIC System Variables
LSTX    .equ    $380E           ;Matrix Coordinate of Last Key Pressed
KCOUNT  .equ    $380F           ;Keyboard debounce counter
CHARC   .equ    $380A           ;Last Key Pressed
VALTYP  .equ    $38AB           ;Return Type: 0=Number, 1=String
FACLO   .equ    $38E4           ;Low Order of FAC Mantissa

;BASIC M/: Routines
REDDY   .equ    $036E           ;"Ok" Message, Preceded by 0 Byte
STRIN1  .equ    $0E4E           ;Create One Character Temporary String
SETSTR  .equ    $1019           ;Convert E to String, Return from calling Routine

        .org    $8000           ;Start of top 32k - The maximum value for CLEAR
 
;;BASIC INKEY$ function
GETKEY: jr      RTNNUL          ;Test - Try Returning a NUL String
        
        push    hl              ;Save Text Pointer
        call    KEYGET          ;Read Keyboard
        ld      (CHARC),a       ;Save It
        jr      z,RTNNUL        ;If No Key, Return ""
        push    af              ;
        call    STRIN1          ;Create Return String 
        pop     af              ;
        ld      e,a             ;Set E to Key Character
        call    SETSTR          ;Stuff in String and RETURN from USR Call

RTNNUL: ld      hl,REDDY-1      ;Get Address of 0 Byte (ASCII NUL)
        ld      (FACLO),hl      ;Set as String Pointer for Return
        ld      a,1             ;
        ld      (VALTYP),a      ;Set Type to String
        pop     hl              ;
        ret                     ;


;Key Read routine from BASIC with Reserved Word logic removed
;
;The Keyboard Matrix is 8 columns by 6 rows. The columns are wired to
;to address lines A8 through A15 and the rows to I/O Port 255.
;When the Z80 executes and IN instruction, it puts the contents of BC 
;on the address bus. So to read the keyboard, B is loaded with a column
;mask, C is loaded with $FF, and IN (C) reads the rows.
;
;        A8  A9  A10 A11 A12 A13 A14 A15            
;    D0   =   -   9   8   6   5   3   2
;    D1  <--  /   O   I   Y   T   E   W
;    D2   :   0   K   7   G   4   S   L
;    D3  RTN  P   M   U   V   R   Z   Q
;    D4   ;   L   N   H   C   D  SPC SHF   
;    D5   .   ,   J   B   F   X   A  CTL
;
; Note: The RESET key is wired directly to the Z80 reset line.
;
;Check for keypress
KEYGET: exx                    ;Save Registers        
;Scan Keyboard
KEYSCN: ld      bc,$FF          ;B=0 to scan all columns
        in      a,(c)           ;Read rows from I/O Port 255
        cpl                     ;and Invert
        and     $3F             ;Check all rows
        ld      hl,LSTX         ;Pointer to last scan code
        jr      z,NOKEYS        ;No key pressed? ???do a thing
        ;???Check for Shift and Control Keys
        ld      b,$7F           ;Scanning column 7 - %01111111
        in      a,(c)           ;Read rows and invert
        cpl
        and     $0F             ;Check rows 0 through 3 - %00001111
        jr      nz,KEYDN        ;Key down? Process it
        ;Scan the Rest of the Columns
        ld      b,$BF           ;Start with column 6 - %10111111 
KEYSCL: in      a,(c)           ;Read rows and invert
        cpl                     ;
        and     $3F             ;Check rows 0 through 5 - %00111111
        jr      nz,KEYDN        ;Key down? Process it
        rrc     b               ;Next column
        jr      c,KEYSCL        ;Loop if not out of columns
NOKEYS: inc     hl              ;Point to KCOUNT           
        ld      a,70            ;
        cp      (hl)            ;
        jr      c,KEYFIN        ;Less than 70? Clean up and return
        jr      z,SCNINC        ;0? Increment KCOUNT and return
        inc     (hl)            ;
KEYFIN: xor     a               ;Clear A
        exx                     ;Restore Registers
        ret                     ;
SCNINC: inc     (hl)            ;Increment KCOUNT
        dec     hl              ;
        ld      (hl),0          ;Clear LSTX 
        jr      KEYFIN          ;Clean up and Return

;Process Key Currently Pressed
KEYDN:  ld      de,0            ;
KEYROW: inc     e               ;Get row number (1-5) 
        rra                     ;
        jr      nc,KEYROW       ;
        ld      a,e             ;
KEYCOL: rr      b               ;Add column number times 6
        jr      nc,KEYCHK       ;
        add     a,6             ;
        jr      KEYCOL          ;
KEYCHK: ld      e,a             ;
        cp      (hl)            ;Compare scan code to LSTX
        ld      (hl),a          ;Update LSTX with scan code
        inc     hl              ;Point to KCOUNT
        jr      nz,KEYCLR       ;Not the same? Clear KCOUNT and exit
        ld      a,4             
        cp      (hl)            ;Check KCOUNT
        jr      c,KEYFN6        ;Greater than 4? Set to 6 and return
        jr      z,KEYASC        ;Equal to 4? Convert scan code
        inc     (hl)            ;Increment KCOUNT
        jr      KEYFN2          ;Clean up and exit
KEYFN6: ld      (hl),6          ;Set KCOUNT to 6
KEYFN2: xor     a               ;Clear A
        exx                     ;Restore registers
        ret                     ;
KEYCLR: ld      (hl),0          ;Clear KCOUNT
        jr      KEYFN2          ;Clean up and return

;Convert Keyboard Scan Code to ASCII Character
KEYASC: inc     (hl)            ;Increment KCOUNT
        ld      b,$7F           ;Read column 7
        in      a,(c)           ;Get row
        bit     5,a             ;Check Control key
        ld      ix,CTLTAB-1     ;Point to control table
        jr      z,KEYLUP        ;Control? Do lookup
        bit     4,a             ;Check Shift key
        ld      ix,SHFTAB-1     ;Point to shift table
        jr      z,KEYLUP        ;Shift? Do lookup
        ld      ix,KEYTAB-1       
KEYLUP: add     ix,de           ;Get pointer into table
        ld      a,(ix+0)        ;Load ASCII value
        exx                     ;Restore Registers
        ret

;Unmodified Key Lookup Table
KEYTAB: .byte    '=',$08,':',$0D,';','.' ;Backspace, Return
        .byte    '-','/','0','p','l',',' 
        .byte    '9','o','k','m','n','j' 
        .byte    '8','i','7','u','h','b' 
        .byte    '6','y','g','v','c','f' 
        .byte    '5','t','4','r','d','x' 
        .byte    '3','e','s','z',' ','a' 
        .byte    '2','w','1','q'         

;Shifted Key Lookup Table
SHFTAB: .byte    '+',$5C,'*',$0D,'@','>' ;Backslash, Return
        .byte    '_','^','?','P','L','<' 
        .byte    ')','O','K','M','N','J' 
        .byte    '(','I',$27,'U','H','B' ;Apostrophe
        .byte    '&','Y','G','V','C','F' 
        .byte    '%','T','$','R','D','X' 
        .byte    '#','E','S','Z',' ','A' 
        .byte    $22,'W','!','Q'         ;Quotation Mark

;Control Key Lookup Table
CTLTAB: .byte    $1B,$7F,$1D,$FF,$00,$7D ;ESC DEL GS  alt  NUL  }   
        .byte    $1F,$1E,$1C,$10,$0C,$7B ;GS  RS  FS  DLE FF   {   
        .byte    $5D,$0F,$0B,$0D,$0E,$0A ; ]  SI  VT  CR  SO  LF   
        .byte    $5B,$09,$60,$15,$08,$02 ; [  tab  `  NAK BS  SOH  
        .byte    $8E,$19,$07,$16,$03,$06 ;rt  EM  BEL SYN ETX ACK  
        .byte    $9F,$14,$8F,$12,$04,$18 ;dn  DC4 up  DC2 EOT CAN  
        .byte    $9E,$05,$13,$1A,$A0,$01 ;lft ENC DC3 SUB mnu SOH  
        .byte    $7E,$17,$7C,$11         ; ~  ETB  |  DC1

        .end     
