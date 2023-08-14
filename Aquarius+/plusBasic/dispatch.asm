;=====================================================================================
; Statement/Function Dispatch, Keyword, and Error Message Tables and Related Routines
; Dispatch and Lookup Tables are all aligned to not cross boundaries
;======================================================================================

; ------------------------------------------------------------------------------
;  Statement, Function, and Hook Dispatch Tables
; ------------------------------------------------------------------------------

; Combined Statement Jump Table 
; 256 Bytes
; Standard BASIC Routines left as HEX
STJUMPS:
    dw      $0C21                 ;$80 END              
    dw      $05BC                 ;$81 FOR               
    dw      $0D13                 ;$82 NEXT              
    dw      $071C                 ;$83 DATA              
    dw      $0893                 ;$84 INPUT             
    dw      $10CC                 ;$85 DIM               
    dw      $08BE                 ;$86 READ              
    dw      $0731                 ;$87 LET               
    dw      $06DC                 ;$88 GOTO              
    dw      $06BE                 ;$89 RUN               
    dw      $079C                 ;$8A IFS               
    dw      $0C05                 ;$8B RESTOR            
    dw      $06CB                 ;$8C GOSUB             
    dw      $06F8                 ;$8D RETURN            
    dw      $071E                 ;$8E REM               
    dw      $0C1F                 ;$8F STOP              
    dw      $0780                 ;$90 ONGOTO            
    dw      $07B5                 ;$91 LPRINT            
    dw      $1B15                 ;$92 COPY              
    dw      $0B3B                 ;$93 DEF               
    dw      $0B6D                 ;$94 POKE              
    dw      $07BC                 ;$95 PRINT             
    dw      $0C4B                 ;$96 CONT              
    dw      $056C                 ;$97 LIST              
    dw      $0567                 ;$98 LLIST             
    dw      $0CCD                 ;$99 CLEAR             
    dw      $1C2C                 ;$9A CLOAD             
    dw      $1C08                 ;$9B CSAVE             
    dw      $1A4F                 ;$9C PSET              
    dw      $1A51                 ;$9D PRESET            
    dw      $1AD6                 ;$9E SOUND             
    dw      $0BBD                 ;$9F NEW
;Miscellaneous Functions
    dw      SNERR                 ;$A0 TAB(   
    dw      SNERR                 ;$A1 TO     
    dw      SNERR                 ;$A2 FN     
    dw      SNERR                 ;$A3 SPC(   
    dw      SNERR                 ;$A4 INKEY$ 
    dw      SNERR                 ;$A5 THEN   
    dw      SNERR                 ;$A6 NOT    
    dw      SNERR                 ;$A7 STEP   
;Operators
    dw      SNERR                 ;$A8 +      
    dw      SNERR                 ;$A9 -      
    dw      SNERR                 ;$AA *      
    dw      SNERR                 ;$AB /      
    dw      SNERR                 ;$AC ^      
    dw      SNERR                 ;$AD AND    
    dw      SNERR                 ;$AE OR     
    dw      SNERR                 ;$AF >      
    dw      SNERR                 ;$B0 =      
    dw      SNERR                 ;$B1 <      
;Standard BASIC Functions
    dw      SNERR                 ;$B2 SGN     
    dw      SNERR                 ;$B3 INT     
    dw      SNERR                 ;$B4 ABS     
    dw      SNERR                 ;$B5 USR  
    dw      SNERR                 ;$B6 FRE     
    dw      SNERR                 ;$B7 LPOS    
    dw      SNERR                 ;$B8 POS     
    dw      SNERR                 ;$B9 SQR     
    dw      SNERR                 ;$BA RND     
    dw      SNERR                 ;$BB LOG     
    dw      SNERR                 ;$BC EXP     
    dw      SNERR                 ;$BD COS     
    dw      SNERR                 ;$BE SIN     
    dw      SNERR                 ;$BF TAN     
    dw      SNERR                 ;$C0 ATN     
    dw      SNERR                 ;$C1 PEEK    
    dw      SNERR                 ;$C2 LEN     
    dw      SNERR                 ;$C3 STR$     
    dw      SNERR                 ;$C4 VAL     
    dw      SNERR                 ;$C5 ASC     
    dw      SNERR                 ;$C6 CHR$     
    dw      SNERR                 ;$C7 LEFT$    
    dw      SNERR                 ;$C8 RIGHT$   
    dw      SNERR                 ;$C9 MID$     
    dw      SNERR                 ;$CA POINT
;PlusBASIC Statements and Functions
    dw      SNERR                 ;$CB 
    dw      SNERR                 ;$CC  
    dw      SNERR                 ;$CD  
    dw      SNERR                 ;$CE  
    dw      SNERR                 ;$CF  
    dw      SNERR                 ;$D0  
    dw      SNERR                 ;$D1  
    dw      SNERR                 ;$D2  
    dw      SNERR                 ;$D3  
    dw      SNERR                 ;$D4 EDIT   
    dw      ST_CLS                ;$D5 CLS    
    dw      ST_LOCATE             ;$D6 LOCATE 
    dw      ST_OUT                ;$D7 OUT    
    dw      ST_PSG                ;$D8 PSG    
    dw      SNERR                 ;$D9 DEBUG  
    dw      ST_CALL               ;$DA CALL   
    dw      ST_LOAD               ;$DB LOAD   
    dw      ST_SAVE               ;$DC SAVE   
    dw      ST_DIR                ;$DD DIR    
    dw      ST_MKDIR              ;$DE MKDIR
    dw      ST_DEL                ;$DF DEL    
    dw      ST_CD                 ;$E0 CD     
    dw      SNERR                 ;$E1 IN
    dw      SNERR                 ;$E2 JOY
    dw      SNERR                 ;$E3 HEX
    dw      SNERR                 ;$E4 VER
    dw      SNERR                 ;$E5 DTM
    dw      SNERR                 ;$E6 DEC
    dw      SNERR                 ;$E7 KEY
    dw      SNERR                 ;$E8 
    dw      SNERR                 ;$E9 
    dw      SNERR                 ;$EA 
    dw      SNERR                 ;$EB 
    dw      SNERR                 ;$EC 
    dw      SNERR                 ;$ED 
    dw      SNERR                 ;$EE 
    dw      SNERR                 ;$EF 
    dw      SNERR                 ;$F0 
    dw      SNERR                 ;$F1 
    dw      SNERR                 ;$F2 
    dw      SNERR                 ;$F3 
    dw      SNERR                 ;$F4 
    dw      SNERR                 ;$F5 
    dw      SNERR                 ;$F6
    dw      SNERR                 ;$F7
    dw      SNERR                 ;$F8
    dw      SNERR                 ;$F9
    dw      SNERR                 ;$FA
    dw      SNERR                 ;$FB
    dw      SNERR                 ;$FC
    dw      SNERR                 ;$FD
    dw      SNERR                 ;$FE
    dw      SNERR                 ;$FF

; Combined Function Jump Table
; 106 Bytes
FNJUMPS:
; Standard BASIC Functions
    dw      HOOK27+1              ;$B2 SGN     
    dw      HOOK27+1              ;$B3 INT     
    dw      HOOK27+1              ;$B4 ABS     
    dw      HOOK27+1              ;$B5 USR  
    dw      HOOK27+1              ;$B6 FRE     
    dw      HOOK27+1              ;$B7 LPOS    
    dw      HOOK27+1              ;$B8 POS     
    dw      HOOK27+1              ;$B9 SQR     
    dw      HOOK27+1              ;$BA RND     
    dw      HOOK27+1              ;$BB LOG     
    dw      HOOK27+1              ;$BC EXP     
    dw      HOOK27+1              ;$BD COS     
    dw      HOOK27+1              ;$BE SIN     
    dw      HOOK27+1              ;$BF TAN     
    dw      HOOK27+1              ;$C0 ATN     
    dw      HOOK27+1              ;$C1 PEEK    
    dw      HOOK27+1              ;$C2 LEN     
    dw      HOOK27+1              ;$C3 STR$     
    dw      HOOK27+1              ;$C4 VAL     
    dw      HOOK27+1              ;$C5 ASC     
    dw      HOOK27+1              ;$C6 CHR$     
    dw      HOOK27+1              ;$C7 LEFT$    
    dw      HOOK27+1              ;$C8 RIGHT$   
    dw      HOOK27+1              ;$C9 MID$     
    dw      HOOK27+1              ;$CA POINT
; PlusBASIC Statements and Functions
    dw      SNERR                 ;$CB  
    dw      SNERR                 ;$CC   
    dw      SNERR                 ;$CD   
    dw      SNERR                 ;$CE   
    dw      SNERR                 ;$CF   
    dw      SNERR                 ;$D0   
    dw      SNERR                 ;$D1   
    dw      SNERR                 ;$D2   
    dw      SNERR                 ;$D3   
    dw      SNERR                 ;$D4 EDIT   
    dw      SNERR                 ;$D5 CLS    
    dw      SNERR                 ;$D6 LOCATE 
    dw      SNERR                 ;$D7 OUT    
    dw      SNERR                 ;$D8 PSG    
    dw      SNERR                 ;$D9 DEBUG  
    dw      SNERR                 ;$DA CALL   
    dw      SNERR                 ;$DB LOAD   
    dw      SNERR                 ;$DC SAVE   
    dw      SNERR                 ;$DD DIR    
    dw      SNERR                 ;$DE CAT    
    dw      SNERR                 ;$DF DEL    
    dw      SNERR                 ;$E0 CD     
    dw      FN_IN                 ;$E1 IN
    dw      FN_JOY                ;$E2 JOY
    dw      FN_HEX                ;$E3 HEX
    dw      SNERR                 ;$E4 
    dw      SNERR                 ;$E5 
    dw      SNERR                 ;$E6 
    dw      SNERR                 ;$E7 
    dw      SNERR                 ;$E8 
    dw      SNERR                 ;$E9 
    dw      SNERR                 ;$EA 
    dw      SNERR                 ;$EB 
    dw      SNERR                 ;$EC 
    dw      SNERR                 ;$ED 
    dw      SNERR                 ;$EE 
    dw      SNERR                 ;$EF 
    dw      SNERR                 ;$F0 
    dw      SNERR                 ;$F1 
    dw      SNERR                 ;$F2 
    dw      SNERR                 ;$F3 
    dw      SNERR                 ;$F4 
    dw      SNERR                 ;$F5 
    dw      SNERR                 ;$F6
    dw      SNERR                 ;$F7
    dw      SNERR                 ;$F8
    dw      SNERR                 ;$F9
    dw      SNERR                 ;$FA
    dw      SNERR                 ;$FB
    dw      SNERR                 ;$FC
    dw      SNERR                 ;$FD
    dw      SNERR                 ;$FE
    dw      SNERR                 ;$FF


; ------------------------------------------------------------------------------
;  Execute Statement with Token in A
; ------------------------------------------------------------------------------

exec_next_statement:
    exx                         ; save BC,DE,HL
    sub     $80                 ; Convert from Token to Table Position
    add     a,a                 ; A * 2 to index WORD size vectors
    ld      l,a
    ld      h,high(STJUMPS)
    ld      a,(hl)
    ld      ixl,a
    inc     hl
    ld      a,(hl)
    ld      ixh,a
    exx                         ; Restore BC,DE,HL
    rst     CHRGET              ; Skip Token and Eat Spaces
    jp      (ix)                ; Go Do It

; ------------------------------------------------------------------------------
;  Hook 27 - Execute Function
; ------------------------------------------------------------------------------

execute_function:
    push    af                  ; Save A
    exx                         ; save BC,DE,HL
    add     a,a                 ; A * 2 to index WORD size vectors
    ld      l,a
    ld      h,high(FNJUMPS)
    ld      a,(hl)
    ld      ixl,a
    inc     hl
    ld      a,(hl)
    ld      ixh,a
    exx                         ; Restore BC,DE,HL
    pop     af                  ; Restore A
    jp      (ix)                ; Go Do It

;-----------------------------------------------------------------------------
; Convert keyword to token - hook 10
;-----------------------------------------------------------------------------
keyword_to_token:
    ld      a, b               ; A = current index

    cp      $CB                ; If < $CB then keyword was found in BASIC table
    ld      IX,HOOK10+1        ;   CRUNCX will also return here when done
    push    IX
    ret     nz                 ;   so return
    ; Set our own keyword table and let BASIC code use that instead
    ex      de, hl             ; HL = Line buffer
    ld      de, TBLCMDS - 1    ; DE = our keyword table
    ld      b, BTOKEN - 1      ; B = our first token
    
    jp      CRUNCX             ; Continue searching using our keyword table

;-----------------------------------------------------------------------------
; Convert token to keyword - hook 22
;
; This function will check if the passed token is one of the stock BASIC or
; our extra commands. If it one of our commands, we pass our command table
; to the ROM code.
;-----------------------------------------------------------------------------
token_to_keyword:
    cp      BTOKEN              ; Is it one of our tokens?
    jr      nc, .expand_token   ; Yes, expand it
    jp      HOOK22+1            ; No, return to system for expansion

.expand_token:
    sub     BTOKEN - 1
    ld      c, a                ; C = offset to AquBASIC command
    ld      de, TBLCMDS         ; DE = table of AquBASIC command names
    jp      RESSRC              ; Print keyword indexed by C

; ------------------------------------------------------------------------------
;  Hook Jump Table
; ------------------------------------------------------------------------------

    org ($ & $FF00) + 256

; BASIC Hook Jump Table
; 58 Bytes
hook_table:                     ; ## caller   addr  performing function
    dw      HOOK0+1             ;  0 ERROR    03DB  Initialize Stack, Display Error, and Stop Program
    dw      HOOK1+1             ;  1 ERRCRD   03E0  Print Error Message
    dw      HOOK2+1             ;  2 READY    0402  BASIC command line (immediate mode)
    dw      HOOK3+1             ;  3 EDENT    0428  Save Tokenized Line  
    dw      HOOK4+1             ;  4 FINI     0480  Finish Adding/Removing Line or Loading Program
    dw      HOOK5+1             ;  5 LINKER   0485  Update BASIC Program Line Links
    dw      HOOK6+1             ;  6 PRINT    07BC  Execute PRINT Statement
    dw      HOOK7+1             ;  7 FINPRT   0866  End of PRINT Statement
    dw      HOOK8+1             ;  8 TRMNOK   0880  Improperly Formatted INPUT or DATA handler
    dw      HOOK9+1             ;  9 EVAL     09FD  Evaluate Number or String
    dw      keyword_to_token    ; 10 NOTGOS   0536  Converting Keyword to Token
    dw      HOOK11+1            ; 11 CLEAR    0CCD  Execute CLEAR Statement
    dw      HOOK12+1            ; 12 SCRTCH   0BBE  Execute NEW Statement
    dw      HOOK13+1            ; 13 OUTDO    198A  Execute OUTCHR
    dw      HOOK14+1            ; 14 ATN      1985  ATN() function
    dw      HOOK15+1            ; 15 DEF      0B3B  DEF statement
    dw      HOOK16+1            ; 16 FNDOER   0B40  FNxx() call
    dw      HOOK17+1            ; 17 LPTOUT   1AE8  Print Character to Printer
    dw      HOOK18+1            ; 18 INCHRH   1E7E  Read Character from Keyboard
    dw      HOOK19+1            ; 19 TTYCHR   1D72  Print Character to Screen
    dw      HOOK20+1            ; 20 CLOAD    1C2C  Load File from Tape
    dw      HOOK21+1            ; 21 CSAVE    1C09  Save File to Tape
    dw      token_to_keyword    ; 22 LISPRT   0598  expanding a token
    dw      exec_next_statement ; 23 GONE2    064B  interpreting next BASIC statement
    dw      run_cmd             ; 24 RUN      06BE  starting BASIC program
    dw      HOOK25+1            ; 25 ONGOTO   0780  ON statement
    dw      HOOK26+1            ; 26 INPUT    0893  Execute INPUT, bypassing Direct Mode check
    dw      execute_function    ; 27 ISFUN    0A5F  Executing a Function
    dw      HOOK28+1            ; 28 DATBK    08F1  Doing a READ from DATA
    dw      HOOK29+1            ; 29 NOTSTV   099E  Evaluate Operator (S3 BASIC Only)

; ------------------------------------------------------------------------------
;  Execute Hook Routine
; ------------------------------------------------------------------------------

fast_hook_handler:
    ex      af,af'              ; save AF
    exx                         ; save BC,DE,HL
    pop     hl                  ; get hook return address
    ld      a,(hl)              ; A = byte (RST $30 parameter)
    add     a,a                 ; A * 2 to index WORD size vectors
    ld      l,a
    ld      h,high(hook_table)
    ld      a,(hl)
    ld      ixl,a
    inc     hl
    ld      a,(hl)
    ld      ixh,a
    exx                         ; Restore BC,DE,HL
    ex      af,af'              ; Restore AF
    jp      (ix)


;;; Extended Error Message Table can go here