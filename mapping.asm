
; -----------
; DATA TYPES
; -----------

; Integer types
; Byte		Unsigned	1-byte	[0 to 255]
; Word		Unsigned	2-bytes	[0 to 65535]
; Short		Signed		1-byte	[-128 to 127]
; Integer	Signed		2-byte	[-32768 to 32767]

; Decimal point types
; Float		Unsigned	2-bytes	[0.0 to 255.0]
; Real		Signed		2-bytes	[-128.0 to 127.0]
; Double	Signed		3-bytes	[-128.00 to 127.00] Enhanced precision


; Real numbers:
; High 	byte 	Short 	Integer part
; Low 	byte 	Byte	Remainder part

; Double numbers:
; High 	byte 	Short 	Integer part
; Low 	byte 	Word	Remainder part


; VIRTUAL REGISTERS
;
;+-----+-------------+-------------+-------------+
;|  B  |     CX      |     DX      |     EX      |
;+-----+------+------+------+------+------+------+
;|     |  CL  |  CH  |  DL  |  DH  |  EL  |  EH  |
;| $02 | $07  | $08  | $fb  | $fc  | $fd  | $fe  |
;+-----+------+------+------+------+------+------+


B   = $02						; $02		Virtual register B

CX  = $07						; $07-$08	Virtual register C 
CL  = $07						; $07    	Lo-byte of the 16-bit virtual register C
CH  = $08						; $08    	Hi-byte of the 16-bit virtual register C

DX  = $fb						; $fb-$fc	Virtual register D
DL  = $fb						; $fb    	Lo-byte of the 16-bit virtual register D
DH  = $fc						; $fc    	Hi-byte of the 16-bit virtual register D

EX  = $fd						; $fd-$fe	Virtual register E
EL 	= $fd						; $fd    	Lo-byte of the 16-bit virtual register E
EH 	= $fe						; $fe    	Hi-byte of the 16-bit virtual register E

; RAX = 16-bit word that is stored in A and X registers, A register = low byte, X register = high byte
; RYX = 16-bit word that is stored in Y and X registers, Y register = low byte, X register = high byte


; ------------------
; VIC MEMORY MAPPING
; ------------------

SPRITE_0_X_POS		= $d000
SPRITE_0_Y_POS		= $d001
SPRITE_1_X_POS		= $d002
SPRITE_1_Y_POS		= $d003
SPRITE_2_X_POS		= $d004
SPRITE_2_Y_POS		= $d005
SPRITE_3_X_POS		= $d006
SPRITE_3_Y_POS		= $d007
SPRITE_4_X_POS		= $d008
SPRITE_4_Y_POS		= $d009
SPRITE_5_X_POS		= $d00a
SPRITE_5_Y_POS		= $d00b
SPRITE_6_X_POS		= $d00c
SPRITE_6_Y_POS		= $d00d
SPRITE_7_X_POS		= $d00e
SPRITE_7_Y_POS		= $d00f
SPRITE_X_MSB		= $d010
CONTROL_REG_1		= $d011
RASTER_POS			= $d012
LATCH_X_POS			= $d013
LATCH_Y_POS			= $d014
SPRITE_ENABLE		= $d015
CONTROL_REG_2		= $d016
SPRITE_EXPAND_Y		= $d017			; Sprites Expand 2x Vertical (Y)
MEMORY_CTRL_REG 	= $d018			; Memory Control Register
IRR					= $d019			; Interrupt Request Register 
IMR					= $d01a			; Interrupt Mask Register
SPRITE_PRIORITY 	= $d01b			; Sprite to Background Display Priority
SPRITE_MCM			= $d01c			; Sprites Multi-Color Mode Select
SPRITE_EXPAND_X		= $d01d			; Sprites Expand 2x Horizontal (X)
SPRITE_COL_SPR		= $d01e			; Sprite to Sprite Collision Detect
SPRITE_COL_BCK		= $d01f			; Sprite to Background Collision Detect
BORDER_COLOR		= $d020			; Background color
BCKGRND_COLOR_0		= $d021
BCKGRND_COLOR_1		= $d022			; Background Color 1, Multi-Color Register 0
BCKGRND_COLOR_2		= $d023			; Background Color 2, Multi-Color Register 1
BCKGRND_COLOR_3		= $d024
SPRITE_MCOLOR_0 	= $d025			; Sprite Multi-Color Register 0
SPRITE_MCOLOR_1 	= $d026			; Sprite Multi-Color Register 1
SPRITE_0_COLOR		= $d027			; Sprite 0 Color
SPRITE_1_COLOR		= $d028			; Sprite 1 Color
SPRITE_2_COLOR		= $d029			; Sprite 2 Color
SPRITE_3_COLOR		= $d02a			; Sprite 3 Color
SPRITE_4_COLOR		= $d02b			; Sprite 4 Color
SPRITE_5_COLOR		= $d02c			; Sprite 5 Color
SPRITE_6_COLOR		= $d02d			; Sprite 6 Color
SPRITE_7_COLOR		= $d02e			; Sprite 7 Color


;	VIC CONTROL_REG_1
;	Bit  7      Raster Position Bit 8 from $D012              
;	Bit  6      Extended Color Text Mode: 1 = Enable          
;	Bit  5      Bitmap Mode: 1 = Enable                       
;	Bit  4      Blank Screen to Border Color: 0 = Blank       
;	Bit  3      Select 24/25 Row Text Display: 1 = 25 Rows    
;	Bits 2-0    Smooth Scroll to Y Dot-Position (0-7)  



; ---------------
; SPRITE SPECIFIC
; ---------------

SPRITE_PTR  		= $07f8			; Sprite 0 to 7 data pointers ($07f8 to $07ff)
SPRITE_MGN_LEFT		= 24			; Sprite left margin (offset from the left)
SPRITE_MGN_TOP		= 50			; Sprite top margin (offset from the top)


; ----------
; CIA 1 CHIP
; ----------

PRA					= $dc00			; Data Port A (Keyboard, Joystick port 2, Paddles)
PRB					= $dc01			; Data Port A (Keyboard, Joystick port 1, Paddles)
DDRA				= $dc02			; Data Direction Register A
DDRB				= $dc03			; Data Direction Register B


; ----------------
; GLOBAL VARIABLES
; ----------------

; Math variables

result				= $68			; $68-$6a	Result of a mathematical operation
SCREEN_RAM			= $0400
COLOR_RAM			= $d800


; ---------
;RAYCASTING
;----------

rayUnitXDist		= $26			; $26-$27	Real	Distance traveled for 1 unit in X axis
rayUnitYDist		= $28			; $28-$29	Real	Distance traveled for 1 unit in Y axis
rayHeading			= $4e			; $4e-$4f	Word	Ray heading in Ticks
raySignX			= $50			; $50		Short	Sign 1=positive, -1=negative
raySignY			= $51			; $51		Short	Sign 1=positive, -1=negative 
rayDeltaX			= $57			; $57-$58	Real	Distance from player position to intersection with x axis
rayDeltaY			= $59			; $59-$5a	Real	Distance from player position to intersection with y axis
rayDistX			= $5b			; $5b-$5c	Real	Distance traveled till X axis intersect 
rayDistY			= $5d			; $5d-$5e	Real	Distance traveled till Y axis intersect
rayMapX				= $5f			; $5f		Byte	Map cell coordinate in X axis
rayMapY				= $60			; $60		Byte	Map cell coordinate in Y axis 
raySide    			= $61			; $61		Byte	Wall side that ray hits 0=not found, 1=X axis, 2=Y axis
rayDistance			= $62			; $62-$63	Real	Total ray distance
rayCounter			= $64			; $64		Byte	Actual scan column
rayProjDist   		= $65			; $65-$66	Real	Projected distance
rayColor   			= $67			; $67		Byte	Color of the map cell


