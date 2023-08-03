; Aquarius+ ESP32 Definitions and Routines

;ESP32 File I/O Commands
ESPCMD_RESET    = $01  ; Reset ESP
ESPCMD_OPEN     = $10  ; Open / create file
ESPCMD_CLOSE    = $11  ; Close open file
ESPCMD_READ     = $12  ; Read from file
ESPCMD_WRITE    = $13  ; Write to file
ESPCMD_SEEK     = $14  ; Move read/write pointer
ESPCMD_TELL     = $15  ; Get current read/write
ESPCMD_OPENDIR  = $16  ; Open directory
ESPCMD_CLOSEDIR = $17  ; Close open directory
ESPCMD_READDIR  = $18  ; Read from directory
ESPCMD_DELETE   = $19  ; Remove file or directory
ESPCMD_RENAME   = $1A  ; Rename / move file or directory
ESPCMD_MKDIR    = $1B  ; Create directory
ESPCMD_CHDIR    = $1C  ; Change directory
ESPCMD_STAT     = $1D  ; Get file status
ESPCMD_GETCWD   = $1E  ; Get current working directory
ESPCMD_CLOSEALL = $1F  ; Close any open file/directory descriptor

;ESP I/O Registers
_ESPCTRL        = $F4   
_ESPDATA        = $F5   

;;; reset_esp
;;; Reset ESP32
;;; Destroys: AF, AF'
do_esp_reset:
    ld      a,ESPCMD_RESET       ; Send RESET Command

;;; esp_cmd
;;; Send Command to ESP32
;;; Args: A = Byte
;;; Destroys: AF'
do_esp_cmd:
    ex      af,af'                ; Save Byte
    ld      a,$83                 
    ld      (_ESPCTRL),a        
    jp      esp_send_byte         ; Send the Command

;;; esp_send_long
;;; Send Long to ESP32
;;; Args: DEBC = Long
;;; Destroys: AF, AF',BC
do_esp_send_long:
    call    do_esp_send_word      ; Send Low Word
    ld      b,d
    ld      c,e                   ; Send High Word

;;; esp_send_word
;;; Send Word to ESP32
;;; Args: BC = Word
;;; Destroys: AF, AF'
do_esp_send_word:
    ld      a,c                   ; Send LSB
    call    do_esp_send_byte
    ld      a,b                   ; Send MSB

;;; esp_send_byte
;;; Send Single Byte to ESP32
;;; Args: A = Byte
;;; Destroys: AF'
do_esp_send_byte:
    ex      af,af'                ; Save Byte
_esp_send_byte:                     
    ld      a,(_ESPCTRL)          ; Wait for Ready
    and     2                     
    jr      nz,_esp_send_byte     
    ex      af,af'                ; Restore Byte
    ld      (_ESPDATA),a          ; Write It
    ret                               

; Get Single Byte from ESP32           
; Returns: A = Byte                    
do_esp_get_byte:
    ld      a,(_ESPCTRL)          ; Wait for Ready
    and     1                       
    jr      z,do_esp_get_byte       
    ld      a,(_ESPDATA)          ; Read a Byte
    ret

; Send Multiple Bytes to ESP32
; Args: BC = Byte Count
;       DE = Start Address
; Destroys: AF, AF', BC, DE
do_esp_send_bytes:
    ld      a,(de)                ; Get Next Byte
    call    do_esp_send_byte      ; Send It
    inc     de                    ; Bump Data Pointer
    dec     bc                    ; Decrement Byte Count
    ld      a,b                   
    or      c                     ; If Not Zero
    jr      nz,do_esp_send_bytes  ;   Send Another Byte
    ret

;Get Multiple Bytes from ESP32
;Args: BC = Byte Count
;      DE = Start Address
;Destroys: AF, AF', BC, DE
do_esp_get_bytes:
    call    do_esp_get_byte       ; Get a Byte
    ld      (de),a                ; Store It
    inc     de                    ; Bump Data Pointer
    dec     bc                    ; Decrement Byte Count
    ld      a,b   
    or      c                     ; If Not Zero
    jr      nz,do_esp_get_bytes   ;   Send Another Byte
    ret


;;; esp_get_word
;;; Get Word from ESP32
;;; Destroys: AF, AF'
;;; Returns: BC = Word
do_esp_get_word:
    call    do_esp_get_byte       ; Read LSB
    ld      c,a                   ; into C
    call    do_esp_get_byte       ; Read MSB
    ld      b,a                   ; into B
    ret

;;; esp_get_long
;;; Get Word from ESP32
;;; Destroys: AF, AF'
;;; Returns: BC = Word
do_esp_get_long:
    call    do_esp_get_word       ; Read Low Word
    call    do_esp_get_byte       ; Read High Word LSB
    ld      e,a                   ; into E
    call    do_esp_get_byte       ; Read High Word MSB
    ld      d,a                   ; into D
    ret
