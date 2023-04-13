;RTC Date and Time to/from conversion for Aquarius MX USB BASIC
;
;Note: The DTS1244 has a Weekday register between Hour and Day (called 
;Date in the data sheet). 
;
;The RTC read routine must shift Date, Month, and Year forward 1 byte to 
;match the data structure below. In addition, if Hour is in AM/PM it will 
;need to be converted to 24 hour. Any other control bits must be masked
;to zeros.
;
;The write routine will shift Day, Month, and Year forward one bit and
;set Weekday to 1.  


        ;;Test in Z80 Simulator IDE 
        ;;tasm -80 -b -s datetime.asm
        .org    $0000
        call    str_to_dtm
        call    dtm_add_weekday
        halt

        ;.org    $0060
        ;       fnd  cc  ss  mm  HH  WD  DD  MM  YY
        .byte   $FF,$99,$32,$54,$21,$01,$12,$04,$23
        
        .org    $0080
        .byte   "230412215659",0


        .org $0100

;RTC Data Structure
TMPSTK  .equ $0060   
;TMPSTK  .equ 38A0    RTC Found - Non-Zero if RTC installed, Zero if not
            ;$38A1    Centiseconds
            ;$38A2    Seconds
            ;$38A3    Minutes
            ;$38A4    Hour       ;Needs to be in 24 Hour Format
            ;$38A5    Day
            ;$38A6    Month 
            ;$38A7    Year
            ;$38A8    Overflow - for RTCs that have Weekday field
            ;$38A9    Display Countdown - Set to 0 after RTC Read Write
            ;         May be used as an extra overflow byte
 
;Date String Buffer 
FBUFFR  .equ $0080    ;For Testing
;FBUFFR  .equ $38E8    ;[FBUFFR]             38E8         3EF6 3EF8           
            ;$38F6     [RESHO]                |             | |
            ;$38F7     [RESMO]           Raw: YYMMDDHHmmsscc. | 
            ;$38F8     [RESLO]     Formatted: YYYY-MM-DD HH:mm.
            ;                         Offset: 01234567890123456
            ;                      . is null terminator
            ;$38F9 is STKSAV, so this is all the space available


;Convert BCD Date to Formatted Date String
;Uses: TMPSTK (RTC Date)
;Sets: FBUFFR (YYYY-MM-DD HH:mm) 
;Destroys AF, BC, DE, HL
dtm_to_fmt:
        call  dtm_to_str          ;Convert dtm to raw date then fall into formatting routine

;Format Date String
;Converts FBUFFR from YYMMDDHHmmsscc to YYYY-MM-DD HH:mm
;Destroys AF, BC
format_dts: 
        xor     a                 ;Set String Terminator
        ld      (FBUFFR+16),a
        ld      bc,(FBUFFR+8)     ;Copy Minutes
        ld      (FBUFFR+14),bc  
        ld      a,':'             ;Colon Between Hours and Minutes
        ld      (FBUFFR+13),a   
        ld      bc,(FBUFFR+6)     ;Copy Hours
        ld      (FBUFFR+11),bc 
        ld      a,' '             ;Space Between Days and Hours
        ld      (FBUFFR+10),a   
        ld      bc,(FBUFFR+4)     ;Copy Day
        ld      (FBUFFR+8),bc 
        ld      a,'-'             ;Dash Between Month and Day
        ld      (FBUFFR+7),a   
        ld      bc,(FBUFFR+2)     ;Copy Month
        ld      (FBUFFR+5),bc   
        ld      (FBUFFR+4),a      ;Dash Between Month and Day
        ld      bc,(FBUFFR)       ;Copy Year
        ld      (FBUFFR+2),bc 
        ld      bc,$3032          ;Copy "20" to Century
        ld      (FBUFFR),bc 
        ret
        

;Convert BCD Date to Raw Date String
;Uses: TMPSTK (RTC date)
;Sets: FBUFFR (YYMMDDHHmmsscc) 
;Destroys AF, BC, DE, HL
dtm_to_str:
        ld      a,(TMPSTK)        ;Get RTC Is Present Flag
        or      a                 ;A = 0 means Not Found
        jr      nz,dtms_convert   
        ld      (FBUFFR),a        ;  Return a Null String
        ret                   
dtms_convert:
        ld      hl,FBUFFR         ;Start of Date String
        ld      de,TMPSTK+7       ;Start with Year
        ld      b,7               ;Converting 7 Bytes
dtms_loop:        
        ld      a,(de)
        ld      c,a               ;Convert Tens to ASCII Digit
        srl     a
        srl     a
        srl     a
        srl     a
        or      '0'
        ld      (hl),a            ;Write to String
        inc     HL  
        ld      a,c               ;Convert Ones to ASCII Digit
        and     $0F 
        or      '0' 
        ld      (hl),a            ;Write to String
        inc     hl  
        dec     de                ;Move Backwards through RTC bytes
        djnz    dtms_loop 
        ld      (hl),b            ;Terminate String (B is 0 after loop terminates)
        ret

 

;Convert Date String to BCD Date
;Uses: FBUFFR - Must be in format YYMMDDHHmmss (following characters are ignored)
;Sets: TMPSTK
;Destroys AF, BC, DE, HL
str_to_dtm:
        ld      hl,FBUFFR         ;Date String Starts with Year
        ld      de,TMPSTK+7       ;Start at BCD Year
        ld      b,6               ;Converting 6 BCD Bytes
sdtm_loop: 
        call    get_dtm_digit     ;Get Tens Digit
        sla     a                 ;Shift to High Nybble
        sla     a  
        sla     a  
        sla     a  
        ld      c,a               ;and save it
        call    get_dtm_digit     ;Get Ones Digit
        or      c                 ;Combine with Tens Digit
        ld      (de),a            ;Store in TMPSTK
        dec     de                ;and Move Backwards
        djnz    sdtm_loop         ;Do Next Two Digits
        xor     a                 ;Set centiseconds to 0
        ld      (de),a            ;and Fall into dtm_validate

;Validate dtm fields 
dtm_validate:
        ld      a,(TMPSTK+5)      ;Error if Day is 0
        call    dtm_zero         
        ld      a,(TMPSTK+6)      ;Error if Month is 0
        call    dtm_zero        
        ld      de,TMPSTK+2       ;RTC Byte Contents - start with seconds
        ld      hl,dtm_maxbcd     ;RTC Bytes Maximum Values
        ld      b,5               ;Checking 5 bytes - end with month
val_dtm_loop:
        ld      a,(de)            ;Get RTC Byte
        cp      (hl)              ;
        jr      nc,dtm_error      ;  Error Out
        inc     de                ;Move to Next RTC
        inc     hl                ;  and Max Bytes
        djnz    val_dtm_loop      ;Check Next Digit
        xor     a                 ;Return Success
        ret                       ;All Done

get_dtm_digit:
        ld      a,(HL)            ;Get ASCII Digit
        sub     '0'               ;Convert to Binary Value
        jr      c,dtm_error_pop   ;Error if Less than '0'
        cp      ':'
        jr      nc,dtm_error_pop  ;Error if Greater than '9'
        inc     hl                ;Move to Next Digit
        ret

dtm_zero:
        or      a                ;Error Out if A is 0
        ret     nz
dtm_error_pop:
        pop     de               ;Discard Return Address
dtm_error:
        ld      a,$FF            ;Date Format Error
        ret

dtm_maxbcd:
        .byte    $60,$60,$24,$32,$13

;Shift Down RTC data to remove Weekday
;Some RTC chips have a day of the week field between hours and days which 
;this module does not use
;Changes: TMPSTK - RTC fields
;Destroys: A,B,IX
dtm_del_weekday:
       ld       IX,TMPSTK
       ld       b,6
dtm_del_loop:
       ld       a,(IX+6)
       ld       (IX+5),a
       inc      IX
       djnz     dtm_del_loop
       ret

;Shift Up RTC data to add Weekday and set it to 1
;Some RTC chips have a day of the week field between hours and days which 
;this module does not use
;Changes: TMPSTK - RTC fields
;Destroys: A,B,IX
dtm_add_weekday:
       ld       IX,TMPSTK
       ld       b,6
dtm_add_loop:
       ld       a,(IX+7)
       ld       (IX+8),a
       dec      IX
       djnz     dtm_del_loop
       ret

        .end
