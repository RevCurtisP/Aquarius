; Plus BASIC Main Memory Resident Code
; $2000 - $2FFF
;
; Requires Aquarius S3 BASIC at $0000-$1FFF
;
; Calls extended routines banked into $C000 - $FFFF

; To assemble:
;   zmac -o main.cim -o main.lst main.asm

    org     $E000                 ; Assemble to RAM for now


; ESP32 Symbols and Routines
    include "esp.asm"
    
; DOS Kernel Routines
    include "dos.asm"

; System Routines Jump Table

; ESP32 Routines Jump Table
esp_cmd:        jmp     do_esp_cmd
esp_reset:      jmp     do_esp_reset
esp_send_byte:  jmp     do_esp_send_byte
esp_get_byte:   jmp     do_esp_get_byte
esp_send_bytes: jmp     do_esp_send_bytes
esp_get_bytes:  jmp     do_esp_get_bytes
esp_send_word:  jmp     do_esp_send_word
esp_get_word:   jmp     do_esp_get_word
esp_send_long:  jmp     do_esp_send_word
esp_get_long:   jmp     do_esp_get_word
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return

; DOS Routines Jump Table
dos_open:       jmp     do_dos_open    
dos_close:      jmp     do_dos_close   
dos_read:       jmp     do_dos_read    
dos_write:      jmp     do_dos_write   
dos_seek:       jmp     do_dos_seek    
dos_tell:       jmp     do_dos_tell    
dos_opendir:    jmp     do_dos_opendir 
dos_closedir:   jmp     do_dos_closedir
dos_readdir:    jmp     do_dos_readdir 
dos_delete:     jmp     do_dos_delete  
dos_rename:     jmp     do_dos_rename  
dos_mkdir:      jmp     do_dos_mkdir   
dos_stat:       jmp     do_dos_stat    
dos_chdir:      jmp     do_dos_chdir   
dos_getcwd:     jmp     do_dos_getcwd  
dos_closeall:   jmp     do_dos_closeall
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return
                jmp     _return

_return         ret
