;;; Aquarius+ DOS Assemble Languaage Routines
;;; Requires esp.asm
;;;
;;; Note: Strings do not need to be null terminated,
;;; allowing BASIC strings to be passed to routines.

dos_statlen = 9

;;; dos_rename
;;; Args: BC = Old Path Length
;;;       DE = Old Path Address
;;;       HL = New Path Address
;;;       IX = New Path Length
;;; Destroys: AF, AF', BC, DE
;;; Returns: A = Result
do_dos_rename:
    ld      a,ESPCMD_RENAME       ; Send Rename Command
    call    esp_cmd               
    call    esp_send_bytes        ; Send Old Path
    ex      de,hl                 ; Get New Path Address into DE
    ld      b,ixh                 ; Get New Path Length into BC
    ld      c,ixl
    jr      _dos_cmd              ; Send New Path and Return Result

;;; dos_mkdir
;;; Create Directory
;;; Args: BC = String Length
;;;       DE = String Start Address
;;; Destroys: AF', BC, DE
;;; Returns: A = Result
do_dos_mkdir:
    ld      a,ESPCMD_MKDIR
    jr      _dos_cmd

;;; dos_opendir
;;; Args: BC = Dirspec Length
;;;       DE = Dirspec Start Address
;;; Destroys: AF', BC, DE
;;; Returns: A = File Number or Error
do_dos_opendir:
    ld      a,ESPCMD_OPENDIR
    jr      _dos_cmd

;;; dos_delete      
;;; Delete File
;;; Args: BC = String Length
;;;       DE = String Start Address
;;; Destroys: AF, AF', BC, DE
do_dos_delete:
    ld      a,ESPCMD_DELETE       ; Do Delete Command
    jp      _dos_cmd

;;; dos_chdir
;;; Change Directory
;;; Args: BC = String Length
;;;       DE = String Start Address
;;; Destroys: AF', BC, DE
;;; Returns: A = Result
do_dos_chdir:
    ld      a,ESPCMD_CHDIR

; Execute DOS Command
; Args: A = ESP32 DOS Command
;       BC = String Length
;       DE = String Start Address
; Destroys: AF', BC, DE
; Returns: A = Result
_dos_cmd:
    call    esp_cmd               ; Send DOS Command Byte
_send_string: 
    call    esp_send_bytes        ; Send Command String  
    xor     a 
_send_byte: 
    call    esp_send_byte         ; Send String Terminator
_get_result:  
    call    esp_get_byte          ; Get Result
    or      a                     ; Set Flags
    ret

;;; dos_open
;;; Args: A = Mode
;;;       BC = Filespec Length
;;;       DE = Filespec Start Address
;;; Destroys: AF', BC, DE
;;; Returns: A = File Number or Error
do_dos_open:
    push    af                    ; Save Mode
    ld      a,ESPCMD_OPEN         
    call    esp_cmd               ;
    pop     af                    ; Restore Mode
    call    esp_send_byte         ; and Send It
    jr      _send_string          ; Send Filespec and Return Result

;;; dos_close
;;; Close File
;;; Args: A = File Number
;;; Destroys: AF'
;;; Returns: A = Result
do_dos_close:
    push    af                    ; Save File Number
    ld      a,ESPCMD_CLOSE        ; Send Close Command
    jr      _send_cmd_byte        ; Send Command & Byte, Return Result
      
;;; dos_closeall
;;; Close all Files
;;; Args: A = File Number
;;; Destroys: AF'
;;; Returns: A = Result
do_dos_closeall:
    ld      a,ESPCMD_CLOSEALL     ; Send Close All Command
_send_cmd:  
    call    esp_cmd 
    jr      _get_result           ; Get Result and Routine
  
;;; dos_closedir  
;;; Close Directory
;;; Args: A = File Number
;;; Destroys: AF'
;;; Returns: A = Result
do_dos_closedir:
    push    af                    ; Save File Number
    ld      a,ESPCMD_CLOSEDIR     ; Send Close Command
_send_cmd_byte: 
    call    esp_cmd 
    pop     af                    ; Restore File Number
    jr      _send_byte            ; Send File Number and Return Result

;;; dos_getcwd
;;; Get Current Working Directory
;;; Args: C = Buffer Length
;;;       DE = Buffer Start Address
;;; Destroys: AF, AF', DE
;;; Returns: B = 0
;;;          C = Result Length
do_dos_getcwd:
      ld      a,ESPCMD_GETCWD     
      call    _send_cmd           ; Send Get Current Working Directory Command
      ret     m                   ; Return if Error
      push    af                  ; Save Result
_get_string:
      ld      b,c                 ; Put Buffer Length in B
      dec     b                   ; Decrement for Null Terminator
      ld      c,0                 ; Initialize Length
.loop
      call    esp_get_byte        ; Get Next Byte
      or      a                   ; 
      jr      z,_terminate        ; If Not ASCII 0
      ld      (de),a              ;   Store Byte
      inc     c                   ;   Increment Length
      djnz    .loop               ;   Decrement Counter and Loop
_terminate:
      xor     a
      ld      (de),a              ; Terminate String
_pop_result:
      pop     af                  ; Get Back Result
      ret
 
;;; dos_read:
;;; Read from File
;;; Args: A = File Number
;;;       BC = Byte Count
;;;       DE = Start Address
;;; Destroys: AF', BC, DE
;;; Returns: A = Result
do_dos_read:
    push    af                    ; Save File Number
    ld      a,ESPCMD_READ         ; Send READ Command
    call    esp_cmd               ; Send Command & Byte, Return Result
    pop     af                    ; Get Back File Number
    call    esp_send_byte         ; Send File Number
    call    esp_send_word         ; Send Byte Count
    jr      _get_result           ; Get Result and Return
    ret     m                     ; Return if Error
    push    af                    ; Save Result
    call    esp_get_word          ; Get Result Count in BC
.loop:  
    ld      a,b 
    or      c                     ; If Count = 0
    jr      z,_pop_result         ;   Pop Result and Return
    call    esp_get_byte          ; Read Byte
    ld      (de),a                ; Store in Memory
    inc     de                    ; Increment Pointer
    dec     bc                    ; Decrement Counter
    jr      .loop                 ; Get Next Byte

;;; dos_readdir:
;;; Read Directory Entry
;;; Args: A = File Number
;;;       BC = String Buffer Size
;;;       DE = String Buffer Start Address
;;;       HL = Stat Buffer Address
;;; Destroys: AF', BC, DE
;;; Returns: A = Result
;;;
;;; stat structure  9 bytes
;;;   word  DATE
;;;   word  TIME
;;;   char  ATTR
;;;   long  SIZE    32 bits
do_dos_readdir:
    push    af                    ; Save File Number
    ld      a,ESPCMD_READDIR      ; Send READDIR Command
    pop     af                    ; Restore File Number
    call    _send_byte            ; Send it and Get Result
    ret     m                     ; Return if Error
    push    af                    ; Save Result
    push    bc                    ; Save String Buffer Length
    call    _get_stat             ; Read STAT
    ex      de,hl                 ; Get String Address Back into DE
    pop     bc                    ; Restore String Buffer Length
    jr      _get_string           ; Read Filename and Return Result
    
;;; dos_seek
;;; Args: A = File Number
;;;       DEBC = File Position
;;; Destroys: AF, AF', BC, DE
;;; Returns: A = Result
do_dos_seek:
    push    af                    ; Save File Number
    ld      a,ESPCMD_SEEK         ; Send SEEK Command
    pop     af                    ; Restore File Number
    call    esp_send_byte         ; and Send It
    call    esp_send_long         ; Send File Position Low Word
    jr      _get_result           ; Get Result and Return

;;; dos_tell
;;; Args: A = File Number
;;; Destroys: AF, AF'
;;; Returns: A = Result
;;;          DEBC = File Position
do_dos_tell:
    push    af                    ; Save File Number
    ld      a,ESPCMD_TELL         ; Send TELL Command
    pop     af                    ; Restore File Number
    call    _send_byte            ; Send it and Get Result
    ret     m                     ; Return if Error
    push    af                    ; Save Result
    call    esp_get_long          ; Get File Position
    pop     af                    ; Restore Result
    ret
    
;;; dos_write:
;;; Write from File
;;; Args: A = File Number
;;;       BC = Byte Count
;;;       DE = Start Address
;;; Destroys: AF', BC, DE
;;; Returns: A = Result
;;;          BC = Bytes Written?
do_dos_write:
    push    af                    ; Save File Number
    ld      a,ESPCMD_READ         ; Send READ Command
    call    esp_cmd               ; Send Command & Byte, Return Result
    pop     af                    ; Get Back File Number
    call    esp_send_byte         ; Send File Number
    call    esp_send_bytes        ; Send Data
    call    _get_result           ; Get Result
    ret     m                     ; Return if Error
    push    af                    ; Save Result
    call    esp_get_word          ; Get Return Value
    pop     af                    ; Return Result
    ret

;;; dos_stat
;;; Args: BC = Filespec Length
;;;       DE = Filespec Start Address
;;;       HL = Stat Buffer Address
;;; Destroys: AF', BC, DE, HL
;;; Returns: A = Result
do_dos_stat:
    push    af                    ; Save Mode
    ld      a,ESPCMD_STAT         
    call    esp_cmd               ;
    pop     af                    ; Restore Mode
    call    esp_send_byte         ; and Send It
    call    _send_string          ; Send Filespec and Return Result
    ret     m                     ; Return if Error
    push    af                    ; Save Result
    call    _get_stat             ; Get Return Value
    pop     af                    ; Return Result
    ret

_get_stat:
    ld      bc,dos_statlen        ; Set Buffer Size to STAT length
    ex      de,hl                 ; Swap STAT Buffer Address into DE
    call    esp_get_bytes         ; Read STAT
    ret
