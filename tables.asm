

; Sine table
; Contains sine remainders in fixed point format with single precision.

tblSine:	!byte 000,002,003,005,006,008,009,011,013,014,016,017,019,020,022,024
			!byte 025,027,028,030,031,033,034,036,038,039,041,042,044,045,047,048
			!byte 050,051,053,055,056,058,059,061,062,064,065,067,068,070,071,073
			!byte 074,076,077,079,080,082,083,085,086,088,089,091,092,094,095,097
			!byte 098,099,101,102,104,105,107,108,109,111,112,114,115,117,118,119
			!byte 121,122,123,125,126,128,129,130,132,133,134,136,137,138,140,141
			!byte 142,144,145,146,147,149,150,151,152,154,155,156,157,159,160,161
			!byte 162,164,165,166,167,168,170,171,172,173,174,175,177,178,179,180
			!byte 181,182,183,184,185,186,188,189,190,191,192,193,194,195,196,197
			!byte 198,199,200,201,202,203,204,205,206,207,207,208,209,210,211,212
			!byte 213,214,215,215,216,217,218,219,220,220,221,222,223,224,224,225
			!byte 226,227,227,228,229,229,230,231,231,232,233,233,234,235,235,236
			!byte 237,237,238,238,239,239,240,241,241,242,242,243,243,244,244,245
			!byte 245,245,246,246,247,247,248,248,248,249,249,249,250,250,250,251
			!byte 251,251,252,252,252,252,253,253,253,253,254,254,254,254,254,255
			!byte 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255


; Bit mask table

bitMask:	!byte %00000001
			!byte %00000010
			!byte %00000100
			!byte %00001000
			!byte %00010000
			!byte %00100000
			!byte %01000000
			!byte %10000000


; Screen address line

!zone scrAddr
.lo 		!byte $00,$28,$50,$78,$a0
			!byte $c8,$f0,$18,$40,$68
			!byte $90,$B8,$e0,$08,$30
			!byte $58,$80,$a8,$d0,$f8
			!byte $20,$48,$70,$98,$c0
			
.hi			!byte $00,$00,$00,$00,$00
			!byte $00,$00,$01,$01,$01
			!byte $01,$01,$01,$02,$02
			!byte $02,$02,$02,$02,$02
			!byte $03,$03,$03,$03,$03


; Top of the wall table, View distance 40, table size 256

wallTop:	!byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,002,004
			!byte 005,006,007,008,009,010,010,011,012,012,013,013,014,014,014,015
			!byte 015,015,016,016,016,016,017,017,017,017,017,018,018,018,018,018
			!byte 018,018,019,019,019,019,019,019,019,019,019,020,020,020,020,020
			!byte 020,020,020,020,020,020,020,020,021,021,021,021,021,021,021,021
			!byte 021,021,021,021,021,021,021,021,021,021,021,021,022,022,022,022
			!byte 022,022,022,022,022,022,022,022,022,022,022,022,022,022,022,022
			!byte 022,022,022,022,022,022,022,022,022,022,022,022,022,022,022,022
			!byte 022,023,023,023,023,023,023,023,023,023,023,023,023,023,023,023
			!byte 023,023,023,023,023,023,023,023,023,023,023,023,023,023,023,023
			!byte 023,023,023,023,023,023,023,023,023,023,023,023,023,023,023,023
			!byte 023,023,023,023,023,023,023,023,023,023,023,023,023,023,023,023
			!byte 023,023,023,023,023,023,023,023,023,023,023,023,023,023,023,023
			!byte 023,023,023,023,023,023,024,024,024,024,024,024,024,024,024,024
			!byte 024,024,024,024,024,024,024,024,024,024,024,024,024,024,024,024
			!byte 024,024,024,024,024,024,024,024,024,024,024,024,024,024,024,024


; Colors

!set BLACK			= 0
!set WHITE			= 1
!set RED			= 2
!set CYAN			= 3
!set PURPLE			= 4
!set GREEN			= 5
!set BLUE			= 6
!set YELLOW			= 7
!set ORANGE			= 8
!set BROWN			= 9
!set LIGHT_RED		= 10
!set DARK_GRAY		= 11
!set GRAY			= 12
!set LIGHT_GREEN	= 13
!set LIGHT_BLUE		= 14
!set LIGHT_GRAY		= 15


; Color shade pairs

shaders		!byte DARK_GRAY				; Shade for color BLACK
			!byte LIGHT_GRAY			; Shade for color WHITE
			!byte LIGHT_RED				; Shade for color RED
			!byte BLUE					; Shade for color CYAN
			!byte RED                   ; Shade for color PURPLE
			!byte LIGHT_GREEN           ; Shade for color GREEN
			!byte LIGHT_BLUE            ; Shade for color BLUE
			!byte WHITE                 ; Shade for color YELLOW
			!byte BROWN                 ; Shade for color ORANGE
			!byte ORANGE                ; Shade for color BROWN
			!byte RED                   ; Shade for color LIGHT_RED
			!byte GRAY                  ; Shade for color DARK_GRAY
			!byte LIGHT_GRAY            ; Shade for color GRAY
			!byte GREEN                 ; Shade for color LIGHT_GREEN
			!byte BLUE                  ; Shade for color LIGHT_BLUE
			!byte GRAY                  ; Shade for color LIGHT_GRAY

    
;				   00  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15
;			  4 8  □□  □□  □□  □□  □■  □■  □■  □■  ■□  ■□  ■□  ■□  ■■  ■■  ■■  ■■
;  		  	  2 1  □□  □■  ■□  ■■  □□  □■  ■□  ■■  □□  □■  ■□  ■■  □□  □■  ■□  ■■  
PETscii 	!byte $20,$6c,$7b,$62,$7c,$e1,$ff,$fe,$7e,$7f,$61,$fc,$e2,$fb,$ec,$a0 



; Glow sequence

;glow		!byte BLACK, DARK_GRAY, GRAY, LIGHT_GRAY, WHITE, LIGHT_GRAY, GRAY, DARK_GRAY


