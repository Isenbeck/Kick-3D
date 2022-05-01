
;--------------------------------------------------------------------------------
; User defined type (structure) "player"
;--------------------------------------------------------------------------------

!zone player
	.Heading:	!word 0				; Word		Player angle in Ticks		
	.RotSpeed:	!byte 1				; Byte		Player angle rotation speed		
	.MovSpeed:	!byte 1				; Byte		Player map speed factor	
	.DirVectX:	!word 0				; Real		Player direction vector X axis component
	.DirVectY:	!word 0				; Real		Player direction vector Y axis component
	.PosX:		!word $0000			; Double	Player position x on the map
				!byte $00			;			Reminder as word and integer part as byte
	.PosY:		!word $0000			; Double	Player position y on the map 
				!byte $00			;			Reminder as word and integer part as byte
	.absHeadSin	!word 0				; Real		Absolute value of the heading sinus
	.absHeadCos !word 0				; Real		Absolute value of the heading cosinus


;--------------------------------------------------------------------------------
; User defined type (structure) "event"
; Lower two bytes of event.keyP are giving us the action:
; 00 (0) - key up
; 01 (1) - key just pressed
; 11 (3) - key down
; 10 (2) - key just released
; Note that odd values indicate that key is down, even values that key is up.
;--------------------------------------------------------------------------------

!zone event
	.keyQ		!byte 0
	.keyW		!byte 0
	.keyK 		!byte 0
	.keyL 		!byte 0
	.keyO 		!byte 0
	.keyP 		!byte 0
	.keyS		!byte 0	
	.button		!byte 0					; Joystick button event buffer
	
	
;--------------------------------------------------------------------------------
; User defined type (structure) "seqencer"
;--------------------------------------------------------------------------------

;!zone evtSeqencer
;	.preset		!byte 0					; Cycle count preset for delay
;	.accum      !byte 0					; Accumulated cycle count value
;	.count		!byte 0					; Sequence rayCounter
;	.rollover	!byte 0					; Rollover value (go to 0 when value reached)
	
	

!zone userEvents
;********************************************************************************
;                                   USER EVENTS
;
; Description:	Events that control the player.
;
;********************************************************************************

userEvents		
		
			; Get event
			jsr joystickEvents			; Get and process joystick events
			jsr keyboardEvents			; Get keyboard events
			jsr procKeys				; Process keyboard events
			
			; Process events
			jsr limitPlayerPos			; Limit player position (collision detect)
			jsr doMapEvents				; Process events triggered by positoin on the map.
			
			; Events are used to control the player motion
			jmp getDirVect

			;rts



!zone joystickEvents
;********************************************************************************
;                             UPDATE JOYSTICK EVENTS
;
; Description:	Process joystick events, i.e. player movement.
;
;********************************************************************************	

joystickEvents 
			
			lda PRA					; To save cycle time we won't update sprites
			eor #%0111111			; unless some movement is triggered.
			bne .up

			rts

.up			lda PRA					; Test if UP
			and #%00000001
			bne .down
			jsr joystickUp

.down		lda PRA					; Test if DOWN
			and #%00000010
			bne .left
			jsr joystickDown

.left		lda PRA					; Test if LEFT
			and #%00000100         
			bne .right
			jsr joystickLeft  
  
.right		lda PRA					; Test if RIGHT
			and #%00001000
			bne .button
			jsr joystickRight

.button		lda PRA
			eor #$ff				; Invert
			and #%00010000			; Filter out a button event		
			cmp #1					; If not zero it will set Carry=1
			rol event.button		; roll carry to the buffer.
			
			;; Process button events
			;
			;lda event.button
			;and #%00000011
			;cmp #%00000001			; Just pressed
			;bne .exit
			;
			;; Button is just pressed
			;
			;jsr buttonJustPressed

			rts
		
	
	
!zone joystickUp	
;********************************************************************************
;                              JOYSTICK UP EVENT
;
; Description:	Process joystick up event.
;
;********************************************************************************

joystickUp 

			jmp playerFWD			; Player move forward
			


!zone joystickDown
;********************************************************************************
;                             JOYSTICK DOWN EVENT
;
; Description:	Process joystick up event.
;
;********************************************************************************

joystickDown 

			jsr invertDirVect
			jsr playerFWD
			jmp invertDirVect



!zone joystickLeft
;********************************************************************************
;                              JOYSTICK LEFT EVENT
;
; Description:	Process joystick up event.
;
;********************************************************************************

joystickLeft: 

			jmp playerROL			; Player rotate left
			



!zone joystickRight
;********************************************************************************
;                              JOYSTICK RIGHT EVENT
;
; Description:	Process joystick right event.
;
;********************************************************************************

joystickRight: 

			jmp playerROR		; Player rotate right
			


!zone palyerFWD
;********************************************************************************
;                              MOVE PLAYER FORWARD
;
; Description:	Player forward movement. It wors similar to the turtle graphics.
;				Uses unit direction vector to calculate movement.
;
; Input:		player.DirVectX		Real	Player direction vector x component
;				player.DirVectY		Real	Player direction vector y compoment
;				player.PosX			Double	Player position x on the map
;				player.PosY			Double	Player position y on the map
;				player.MovSpeed 	Byte	Player movement speed factor
;
; Outputs:		player.PosX			Double	Player position x on the map
;				player.PosY			Double	Player position y on the map	
;
; Calls:		multiply
;
; Pseudocode:		
;	player.PosX = player.PosX + player.DirVectX * player.MovSpeed
;	player.posY = player.PosY + player.DirVectY * player.MovSpeed
;********************************************************************************

playerFWD 	; X DIRECTION
	
			lda #0
			sta EL
	
			ldy player.MovSpeed

			lda player.DirVectX	
			sta DL
			lda player.DirVectX+1 
			sta DH

			bpl .next1				; if dirVectX is negative then EL = $FF
			dec EL
			bmi .next1
		
			; Speed multiplier
		
.loop1		asl DL					; Multiply by player.MovSpeed (contained in Y register)	
			rol DH
			rol EL
	
.next1		dey
			bpl .loop1
	
			lda DL
			clc
			adc player.PosX
			sta player.PosX
			lda DH
			adc player.PosX+1
			sta player.PosX+1
			lda EL
			adc player.PosX+2
			sta player.PosX+2
			
			; Y DIRECTION

			lda #0
			sta EL
			
			ldy player.MovSpeed
	
			lda player.DirVectY
			sta DL
			lda player.DirVectY+1 
			sta DH

			bpl .next2					; if dirVectY is negative then EL = $FF
			dec EL
			bmi .next2
	
			; Speed multiplier
	
.loop2		asl DL						; Multiply by player.MovSpeed (contained in Y register)
			rol DH
			rol EL
	
.next2		dey
			bpl .loop2	
	
			lda DL						;Remainder part is in DX, integer part is in EL
			clc
			adc player.PosY
			sta player.PosY
			lda DH
			adc player.PosY+1
			sta player.PosY+1
			lda EL
			adc player.PosY+2
			sta player.PosY+2

			rts
			


!zone playerROL
;********************************************************************************
;                             PLAYER ROTATE LEFT
;
; Description:	Rotate player to the left. 
;
; Inputs:		player.Heading
;				player.RotSpeed
;
; Outputs:		player.Heading
;
; Calls:		getDirVect
;
; Pseudocode:
;	player.Heading = pleayer.Heading + player.RotSpeed
;	If player.Heading > $0400 Then
;	    player.Heading = player.Heading - $0400
;********************************************************************************

playerROL

		ldx player.Heading+1		; Word
		lda player.Heading
		clc
		adc player.RotSpeed			; Byte
		sta player.Heading
		bcc .skip
		
		inx
		txa
		and #%00000011
		sta player.Heading+1
		
.skip	rts ;jmp getDirVect
		
             

!zone playerROR
;********************************************************************************
;                             PLAYER ROTATE RIGHT
;
; Description:	Rotate player right
;
; Inputs:		player.Heading		Word	Player angle in Ticks
;				player.RotSpeed		Byte	Player angle rotation speed
;
; Outputs:		player.Heading		Word	Player angle in Ticks
;
; Calls:		getDirVect
;
;********************************************************************************

playerROR

 			ldx player.Heading+1
			lda player.Heading
			sec
			sbc player.RotSpeed
			sta player.Heading
			bcs .skip
			
			dex
			txa
			and #%00000011
			sta player.Heading+1
			
.skip		rts ;jmp getDirVect



!zone playerSTL
;********************************************************************************
;                             PLAYER STRIFE LEFT
;
; Description:	Strife player to the left.
;				To strife left first rotate the player 90 deg to the left, then
;				move forward and finally rotate player back to the original heading.
;
; Inputs:		player.Heading
;
; Calls:		getDirVect
;
; Pseudocode:
;********************************************************************************

playerSTL

 			lda player.Heading+1
			pha
			tay
			iny
			tya
			and #%00000011
			sta player.Heading+1

 			jsr getDirVect
			jsr playerFWD
	
			pla
			sta player.Heading+1
			rts; jmp getDirVect
			



!zone playerSTR
;********************************************************************************
;                             PLAYER STRIFE RIGHT
;
; Description:	Strife player to the right.
;				To strife left first rotate the player 90 deg to the right, then
;				move forward and finally rotate player back to the original heading.
;
; Inputs:		player.Heading
;
; Calls:		getDirVect
;
; Pseudocode:
;********************************************************************************

playerSTR

 			lda player.Heading+1
			pha
			tay
			dey
			tya
			and #%00000011
			sta player.Heading+1

			jsr getDirVect
			jsr playerFWD
	
			pla
			sta player.Heading+1
			rts ;jmp getDirVect	
			



!zone keyboardEvents
;********************************************************************************
;                             UPDATE KEYBOARD EVENTS
;
; Description:	Process keyboard events, i.e. player movement.
;
; CIA chip has port A and port B that make a mesh. To read a row or a column, 
; chip is expecting sink, i.e. to bring down the pin to 0 V. 
; We have to tell it first if port will be for reading or read/write. 
; After that we have to bring one column and then read a row.
;
;********************************************************************************

keyboardEvents 	

			jsr getKeyboard				; Scan keyboard
	
			;Check if Q is pressed
	
			lda getKeyboard.scan+7
			and #%01000000
			cmp #1
			rol event.keyQ
	
			;Check if W is pressed
	
			lda getKeyboard.scan+1
			and #%00000010
			cmp #1
			rol event.keyW
	
			;Check if P is pressed
	
			lda getKeyboard.scan+5		; If the key is not pressed then the value will be zero.
			and #%00000010				; When compared with 1 it will set Carry to 0.
			cmp #1						; If the key is pressed then the value will be >= 1 and whe
			rol event.keyP				; compared with 1 the Carry will be set to 1.
	
			;Check if S is pressed
	
			lda getKeyboard.scan+1
			and #%000100000
			cmp #1
			rol event.keyS

			;Check if K is pressed
	
			lda getKeyboard.scan+4
			and #%000100000
			cmp #1
			rol event.keyK

			;Check if L is pressed
	
			lda getKeyboard.scan+5
			and #%000000100
			cmp #1
			rol event.keyL	
	
			;Check if O is pressed
	
			lda getKeyboard.scan+4
			and #%001000000
			cmp #1
			rol event.keyO	
	
			rts



!zone procKeys
;********************************************************************************
;                                   KEY PRESS
;
; Description:	Process key presses
;********************************************************************************

procKeys	;Check if Q is pressed

			lda event.keyQ
			lsr
			bcc .not_Q
	
			;Do if Q is pressed
	
			jsr playerSTL				; Strife left
	
			;Check if W is pressed
	
.not_Q		lda event.keyW
			lsr
			bcc .not_W
	
			;Do if W is pressed
	
			jsr playerSTR				; Strife right
	
			;Check if S is pressed

.not_W:		lda event.keyS
			and #%00000011				; Filter lower 2 bytes
			cmp #1						; Check if just pressed
			bne .exit
	
			;Do if S was just pressed
	
			lda screen.ViewMode
			eor #%00000001
			jmp setViewMode
	
.exit:		rts




!zone getKeyboard
;********************************************************************************
;                            SCAN KEYBOARD FOR PRESSED KEYS
;
;Description:	Scan CIA 1 register for keyboard presses.
;
;********************************************************************************

getKeyboard 

			lda DDRA				; Store DDRA and DDRB	 
			pha
			lda DDRB
			pha
	
			lda #$FF				; Set port A to be an output
			sta DDRA				; Bit X: 0=Input (read only), 1=Output (read and write)
			lda #$00				; Set port B to be an input
			sta DDRB				; Bit X: 0=Input (read only), 1=Output (read and write)
	
			; Scan keyboard
	
			lda #%01111111			; Set low (connect) port A row - scanning row 7
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+7

			lda #%10111111			; Set low (connect) port A row - scanning row 6
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+6

			lda #%11011111			; Set low (connect) port A row - scanning row 5
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+5

			lda #%11101111			; Set low (connect) port A row - scanning row 4
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+4

			lda #%11110111			; Set low (connect) port A row - scanning row 3
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+3

			lda #%11111011			; Set low (connect) port A row - scanning row 2
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+2
	
			lda #%11111101			; Set low (connect) port A row - scanning row 1
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+1

			lda #%11111110			; Set low (connect) port A row - scanning row 0
			sta PRA			
			lda PRB					; Read port B column (Bit X low = active)
			eor #255
			sta .scan+0
	
			lda #%11111111			; Set port A high
			sta PRA
	
			pla						; Return original values
			sta DDRB
			pla
			sta DDRA
	
			rts

;Local variables
	
.scan		!byte 0, 0, 0, 0, 0, 0, 0, 0
			


!zone limitPlayerPos
;********************************************************************************
;                              LIMIT PLAYER POSITION
;
; Description:	Control player movements.
;********************************************************************************

limitPlayerPos 

			;Limit movement to the N (up) 
	
			lda player.PosY+1	
			cmp #80						; Value 80 = 2.5 pixels = 0.3125
			bcs .limit_S                
  
			ldx player.PosY+2			; Most significant byte is the cell in which player is in.
			dex
			ldy player.PosX+2
			jsr getCellCode
	
			;cmp #$20 
			;beq .limit_S				; If cell is empty then don't limit.
			cmp #128					; Anything below code 128 is empty space
			bcc .limit_S

			; Correct player position Y

			lda #80						; Don't allow below 80
			sta player.PosY+1

			; Limit movement to the S (down)
  
.limit_S	lda player.PosY+1
			cmp #176
			bcc .limit_E
    
			ldx player.PosY+2  
			inx
			ldy player.PosX+2
			jsr getCellCode
	
			;cmp #$20   
			;beq .limit_E				; If cell is empty then don't limit.
			cmp #128					; Anything below code 128 is empty space
			bcc .limit_E			

			;Correct player position y
	
			lda #176					; Don't allow above 176 = 0,6875
			sta player.PosY+1
  
			;Limit movement to the E (right)
	
.limit_E	lda player.PosX+1			; If position of the player is less than 2.5 pixels
			cmp #176					; from the right edge, then check.
			bcc .limit_W 

			ldy player.PosX+2  
			iny
			ldx player.PosY+2
			jsr getCellCode
	
			;cmp #$20 
			;beq .limit_W
			cmp #128					; Anything below code 128 is empty space
			bcc .limit_W			
			

			;Correct player position x
			
			lda #176
			sta player.PosX+1

			;Limit movement to the W (left)
	
.limit_W	lda player.PosX+1
			cmp #80
			bcs .exit
    
			ldy player.PosX+2  
			dey
			ldx player.PosY+2
			jsr getCellCode

			;cmp #$20 
			;beq .exit
			cmp #128					; Anything below code 128 is empty space
			bcc .exit			

			lda #80
			sta player.PosX+1

.exit		rts

			


!zone getCellCode
;********************************************************************************
;                                 GET MAP CELL CODE
;
; Description: 	Get content of the map cell.
; Input:		X			Byte		row of the map
;				Y			Byte		column of the map 
;
; Output:		A			Byte		code of the cell content  
;
; Using			CX			Virtual 	register 
;				scrAddr		Table 		with screen row addresses
;********************************************************************************

getCellCode

			lda scrAddr.lo,x
			clc 
			adc #<map
			sta CL
			lda scrAddr.hi,x
			adc #>map
			sta CH

			lda (CX),y
			rts



!zone setCellCode
;********************************************************************************
;                                 GET MAP CELL CODE
;
; Description:	Set content of the map cell.
; Input:		X			Byte		row of the map
;				Y			Byte		column of the map 
;
; Output:		A			Byte		code of the cell content  
;
; Using			CX			Virtual 	register 
;				scrAddr		Table 		with screen row addresses
;********************************************************************************

setCellCode

			pha
			lda scrAddr.lo,x
			clc 
			adc #<map
			sta CL
			lda scrAddr.hi,x
			adc #>map
			sta CH

			pla
			sta (CX),y
			rts			


!zone getCellColor
;********************************************************************************
;                                 GET MAP CELL CODE
;
; Description: 	Get color of the cell
;
; Input:		X	Byte	row of the map
;				Y	Byte	column of the map 
;
; Output:		A	Byte	color of the cell   
;
; Using			CX			Virtual register 
;				scrAddr		Table with screen row addresses
;********************************************************************************

getCellColor 

			lda scrAddr.lo,x
			clc 
			adc #<colorMap
			sta CL
			lda scrAddr.hi,x
			adc #>colorMap
			sta CH

			lda (CX),y
			rts
			


!zone setCellColor
;********************************************************************************
;                                 GET MAP CELL CODE
;
; Description:	Set color of the cell
;
; Input:		X	Byte	row of the map
;				Y	Byte	column of the map 
;
; Output:		A	Byte	code of the cell content  
;
; Using			CX			Virtual register 
;				scrAddr		Table with screen row addresses
;********************************************************************************

setCellColor 

			pha
			lda scrAddr.lo,x
			clc 
			adc #<colorMap
			sta CL
			lda scrAddr.hi,x
			adc #>colorMap
			sta CH

			pla
			sta (CX),y
			rts
			


!zone getDirVect
;********************************************************************************
;                           GET PLAYER DIRECTION VECTOR
;
; Description: 	Get player unit direction vector.
;
; Inputs:		player.Heading		Word	Player angle in Ticks
;
; Outputs:		player.DirVectX		Real	Player direction vector x axis component
;				player.DirVectY		Real	Player direction vector y axis component
;
; Calls:		sinus, cosinus
;
;********************************************************************************

getDirVect 

			; player.DirVectX = cos(player.Heading)

			lda player.Heading			; x axis
			ldx player.Heading+1
			jsr cosinus
			lda DH
			sta player.DirVectX+1
			lda DL
			sta player.DirVectX
			
			; Also save the absolute value of cosinus (without sign)
			; player.absHeadCos = abs(cos(Heading))
			
			lda EL
			sta player.absHeadCos
			lda EH
			sta player.absHeadCos+1
			
			; player.DirVectY = sin(player.Heading)

			lda player.Heading			; y axis
			ldx player.Heading+1
			jsr sinus					; Returning inverted Y coordinate
			lda DH
			sta player.DirVectY+1
			lda DL
			sta player.DirVectY
			
			; Also save the absolute value of sinus (without sign)
			; player.absHeadSin = abs(sin(Heading))
			
			lda EL						
			sta player.absHeadSin
			lda EH
			sta player.absHeadSin+1			

			rts 
			
				
	

!zone invertDirVect
;********************************************************************************
;                            INVERT DIRECTION VECTOR
;
; Get player unit direction vector.
;
; Inputs:	player.DirVectX		Real	Player direction vector x axis component
;			player.DirVectY		Real	Player direction vector y axis component Ticks
;
; Outputs:	player.DirVectX		Real	Player direction vector x axis component
;			player.DirVectY		Real	Player direction vector y axis component
;
;********************************************************************************

invertDirVect 	

			lda #0						; Negating result if sign is negative.
			sec							; Two's complement.
			sbc player.DirVectX			; Instead EOR#255 and then adding 1
			sta player.DirVectX			; simply substract number from zero.
			lda #0
			sbc player.DirVectX+1
			sta player.DirVectX+1
	 
			lda #0						; Negating result if sign is negative.
			sec							; Two's complement.
			sbc player.DirVectY			; Instead EOR#255 and then adding 1
			sta player.DirVectY			; simply substract number from zero.
			lda #0
			sbc player.DirVectY+1
			sta player.DirVectY+1
	
			rts  
			
				
	

!zone doMapEvents
;********************************************************************************
;                                  DO MAP EVENTS
;
; Description:	Do events that are triggered on certain locations of the map.
;				Here I have prepared 8 events: A, B, C, D, E, F, G and H.
;				It can be easily expanded.
;
;********************************************************************************

doMapEvents

			ldx player.PosY+2
			ldy player.PosX+2
			jsr getCellCode				; A register = cell code
			
			cmp #$08					; Allow only 8 events (can be expanded later)
			bcs .exit
			
			tay
			lda mapEvent.lo,y
			sta DL
			lda mapEvent.hi,y
			sta DH
			jmp (DX)

.exit		rts



!zone mapEvent

;--------------------------------------------------------------------------------
; Map event ET
;--------------------------------------------------------------------------------

mapEvent_ET

			rts
			
			
;--------------------------------------------------------------------------------
; 								Map event A
; When player steps on the cell, certain wall area will change color.
; After the joystick fire button is pressed, the wall will open.
;--------------------------------------------------------------------------------

mapEvent_A

			lda .stepA
			bne .skipA1					; If STEP 0 is done, then go to the STEP 1
			
			; STEP 0: Color the part of the wall

		 	lda #WHITE
			ldx #3						; Row 3
			ldy #31						; Collumn 31
		    jsr setCellColor 
			
			lda screen.ViewMode			; If ViewMode = 2D then update color map display
			bne .skipA1
			jsr showColor
			
			inc .stepA					; Go to the next step
			rts
			
.skipA1		ldx #3
			ldy #31
			jmp openWall
			
.stepA		!byte 0			
			


;--------------------------------------------------------------------------------
; Map event B
; Enable Mask: 00000100
;--------------------------------------------------------------------------------

mapEvent_B

			ldx #9
			ldy #35
			jmp openWall				; Open the wall if joystick button pressed.
			
			
;--------------------------------------------------------------------------------
; Map event C
;--------------------------------------------------------------------------------

mapEvent_C
			
			rts
			
			
			
;--------------------------------------------------------------------------------
; Map event D
;--------------------------------------------------------------------------------

mapEvent_D
			
			rts
			
			
			
;--------------------------------------------------------------------------------
; Map event E
;--------------------------------------------------------------------------------

mapEvent_E
			
			rts
			
			
			
;--------------------------------------------------------------------------------
; Map event F
;--------------------------------------------------------------------------------

mapEvent_F
			
			rts
			
			
			
;--------------------------------------------------------------------------------
; Map event G
;--------------------------------------------------------------------------------

mapEvent_G
			
			rts
		
		
			
;--------------------------------------------------------------------------------
; Map event H
;--------------------------------------------------------------------------------

mapEvent_H
			
			rts
			
			
; Jump table
.lo			!byte <mapEvent_ET
			!byte <mapEvent_A, <mapEvent_B, <mapEvent_C, <mapEvent_D 
			!byte <mapEvent_E, <mapEvent_F, <mapEvent_G, <mapEvent_H
.hi			!byte >mapEvent_ET
			!byte >mapEvent_A, >mapEvent_B, >mapEvent_C, >mapEvent_D 
			!byte >mapEvent_E, >mapEvent_F, >mapEvent_G, >mapEvent_H

			

!zone openWall
;********************************************************************************
;                                OPEN THE WALL
;
; Description:	Opens the wall at specific location if joystick button 
;				was just pressed.
;
; Input:		Xreg	Byte	Y coordinate of the wall
;				Yreg	Byte	X coordinate of the wall
;
;********************************************************************************

openWall

			lda event.button			; Check if button was just pressed
			and #%00000011
			cmp #%00000001
			bne .exit					; If not just pressed then skip
			
			; Open the wall if button is pressed
			
			lda #32						; Code to set on the map (empty space = 32)
			jsr setCellCode				; Must have Xreg and Yreg ready.
						
			; Remove the mark from the map / disable the event
			
			lda #32
			ldx player.PosY+2
			ldy player.PosX+2
			jsr setCellCode
			
			; Refresh the map
			
			lda screen.ViewMode			; If display mode is 2D then redraw the screen
			bne .exit			
			jsr showMap			
			
.exit		rts


	
;+----+----------------------+-------------------------------------------------------------------------------------------------------+
;|    |                      |                                Peek from $dc01 (code in paranthesis):                                 |
;|row:| $dc00:               +------------+------------+------------+------------+------------+------------+------------+------------+
;|    |                      |   BIT 7    |   BIT 6    |   BIT 5    |   BIT 4    |   BIT 3    |   BIT 2    |   BIT 1    |   BIT 0    |
;+----+----------------------+------------+------------+------------+------------+------------+------------+------------+------------+
;|0.  | #%11111110 (254/$fe) | DOWN  ($  )|   F5  ($  )|   F3  ($  )|   F1  ($  )|   F7  ($  )| RIGHT ($  )| RETURN($  )|DELETE ($  )|
;|1.  | #%11111101 (253/$fd) |LEFT-SH($  )|   e   ($05)|   s   ($13)|   z   ($1a)|   4   ($34)|   a   ($01)|   w   ($17)|   3   ($33)|
;|2.  | #%11111011 (251/$fb) |   x   ($18)|   t   ($14)|   f   ($06)|   c   ($03)|   6   ($36)|   d   ($04)|   r   ($12)|   5   ($35)|
;|3.  | #%11110111 (247/$f7) |   v   ($16)|   u   ($15)|   h   ($08)|   b   ($02)|   8   ($38)|   g   ($07)|   y   ($19)|   7   ($37)|
;|4.  | #%11101111 (239/$ef) |   n   ($0e)|   o   ($0f)|   k   ($0b)|   m   ($0d)|   0   ($30)|   j   ($0a)|   i   ($09)|   9   ($39)|
;|5.  | #%11011111 (223/$df) |   ,   ($2c)|   @   ($00)|   :   ($3a)|   .   ($2e)|   -   ($2d)|   l   ($0c)|   p   ($10)|   +   ($2b)|
;|6.  | #%10111111 (191/$bf) |   /   ($2f)|   ^   ($1e)|   =   ($3d)|RGHT-SH($  )|  HOME ($  )|   ;  ($3b)|   *   ($2a)|   £   ($1c)|
;|7.  | #%01111111 (127/$7f) | STOP  ($  )|   q   ($11)|COMMODR($  )| SPACE ($20)|   2   ($32)|CONTROL($  )|  <-   ($1f)|   1   ($31)|
;+----+----------------------+------------+------------+------------+------------+------------+------------+------------+------------+
;Source: https:;codebase64.org/doku.php?id=base:reading_the_keyboard


; SEQUENCER WITH ROLLOVER EXAMPLE
;
;locEvent_A
;
;		 	inc sequencer_A.accum
;			lda sequencer_A.accum
;			cmp sequencer_A.preset
;			bcc .skipA
;			
;			lda #0
;			sta sequencer_A.accum
;			
;			inc sequencer_A.count
;			ldy sequencer_A.count
;			cpy sequencer_A.rollover
;			bcc .skipB
;
;			sta sequencer_A.count		; A already contains 0	
;			
;.skipB		lda glow,y
;			ldx #3						; Row 3
;			ldy #31						; Collumn 31
;		    jsr setCellColor 
;			
;			lda screen.ViewMode			; If ViewMode = 2D then update color map display
;			bne .skipA
;			jmp showColor
;			
;.skipA		rts
