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

key_table:
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

