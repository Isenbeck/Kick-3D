


!zone rayCast
; ******************************************************************************
;                              CAST RAY 
;
; Inputs:     plPosX      Real
;             plPosY      Real
;
; Outputs:    rayMapX     Byte
;             rayMapY     Byte
;             rayDistX    Real
;             rayDistY    Real
;
; ******************************************************************************

rayCast		jsr getUnitXDist			; Get the distance with X=1 unit long
			jsr getUnitYDist			; Get the distance with Y=1 unit long
			
			; For angles $0000, $0100, $0200, $0300 the value returned 
			; will be infinite approximation $ffff
			
			; Calculate the initial distance for the X axis
	 
			ldx #0	
			lda player.PosX+1			; Take the remainder of the player X position

			bit raySignX				; Verify if ray direction is negative, 
			bmi .isNX					; BIT opcode will match N and V flags from the target

			; If X is positive then we have to "flip" the value.
			; We need to calculate the distance to the first X axis from the current player position. 
			; If we are moving in X positive direction and the player position is for example 2.1,
			; that means that first positive X axis is at 3.0. This will give us a distance of 0.9 because
			; rayDeltaX = 3.0 - 2.1 = 0.9
			; Value 0.1 in fixed point format = round(0.1 * 256) = round(25,6) = 26 = $19
			; Value 0.9 in fixed point format = round(0.9 * 256) = round(230,4) = 230 = $e6
			; $19 EOR $FF = $E6

			eor #255					; rayDeltaX = 1 + (-plPosX(LO))

.isNX		sta rayDeltaX 
			stx rayDeltaX+1 
			
			; If rayUnitXDist is infinitive then don't multiply
			
			lda rayUnitXDist
			and rayUnitXDist
			eor #$ff
			bne .doMult1
			
			; If infinite  then just copy to rayDistX
			lda #$ff
			sta rayDistX
			sta rayDistX+1
			bne .doY
			
			; Multiply

.doMult1	lda rayDeltaX
			;ldx rayDeltaX+1

			sta DL						; DX = rayDeltaX
			stx DH

			lda rayUnitXDist			; CX = rayUnitXDist
			sta CL
			lda rayUnitXDist+1
			sta CH 
  
			jsr multiply				; rayDistX = rayDeltaX * rayUnitXDist

			;Get the result
	
			lda result+1				; Dropping the lowest byte
			sta rayDistX
			lda result+2
			sta rayDistX+1
  
			; Calculate the initial distance for the Y axis

.doY		ldx #0
			lda player.PosY+1

			bit raySignY
			bmi .isNY
  
			;Do if positive

			eor #255					; rayDeltaY = 1 + (-plPosY(LO))

			;Do if negative
	
.isNY		sta rayDeltaY
			stx rayDeltaY+1
			
			; If rayUnitYDist is infinitive then don't multiply
			
			lda rayUnitYDist
			and rayUnitYDist
			eor #$ff
			bne .doMult2
			
			; If infinite  then just copy to rayDistX
			lda #$ff
			sta rayDistY
			sta rayDistY+1
			bne .doDDE
			
			; Multiply			
			
.doMult2	lda rayDeltaY
			;ldx #0
			sta DL
			stx DH
                                                
			lda rayUnitYDist
			sta CL
			lda rayUnitYDist+1
			sta CH 
	
			jsr multiply				; rayDistY = rayDeltaY * rayDistUY
  
			;Get the result

			lda result+1				; Dropping the lowest byte
			sta rayDistY
			lda result+2
			sta rayDistY+1 

			; Preapare for the DDE algorythm
  
.doDDE		lda player.PosX+2			; Prepare mapX and mapY positions
			sta rayMapX
			lda player.PosY+2
			sta rayMapY

			; Use a counter just to prevent an endless loop 
	
			lda #51
			sta B

; ----------------------------------------------------------------------  
;                               DDE ALGORYTHM
; ----------------------------------------------------------------------

; Output:		rayDeltaX, rayDeltaY 
;				rayDistance


;	If rayDistY >= rayDistX Then
;		rayMapY = rayMapy + raySignY
; 		If getCellCode(rayMapX, rayMapY) <> 32 Then 
;			raySide = 2											; Hitting Y wall
;			rayDistance = rayDistY
;			If screenMode = 0 Then								; Calculate if 2D
;				rayDeltaX = Abs(Cos(rayHeading)) * rayDistance
;			End If
;		Else
;			rayDeltaY = rayDeltaY + 1
;			rayDistY = rayDistY + rayUnitYDist
;		End If
;	Else
;		rayMapX = rayMapX + raySignX
;		If getCellCode(rayMapX, rayMapY) <> 32 Then
;			raySide = 1											; Hitting X wall
;			rayDistance = rayDistX
;			If screenMode = 0 Then								; Calculate if 2D
;				rayDeltaY = Abs(Sin(rayHeading)) * rayDistance
;			End If
;		Else
;			rayDeltaX = rayDeltaX + 1
;			rayDistX = rayDistX + rayUnitXDist
;		End If
;	End If
;	
	
;.brk1
.loop	  	lda rayDistX				; Find the shortest distance
			cmp rayDistY
			lda rayDistX+1
			sbc rayDistY+1
			bcc .XLTY

			; If rayDistX >= rayDistY then step in y direction
  
			lda raySignY				; mapY = mapY + raySignY
			clc							; Uses ray signe (+1 or -1) to step
			adc rayMapY					; through the map in y direction.
			sta rayMapY

			; Check if cell is empty

			tax							; Y register =column of the map
			ldy rayMapX					; X register =row of the map 
			jsr getCellCode
	
			;cmp #$20					; If not empty the go to .cellFound
			;bne .cellFoundY
			cmp #128					; Anything below code 128 is empty space
			bcs .cellFoundY			
	
			; Cell is empty

			inc rayDeltaY+1  			;rayDeltaY = rayDeltaY + 1.0  

			; If cell is empty then accumulate the length of the ray
  
			lda rayUnitYDist			;rayDistY = rayDistY + rayDistUY            
			clc
			adc rayDistY
			sta rayDistY
			lda rayUnitYDist+1
			adc rayDistY+1
			sta rayDistY+1

			dec B
			bne .loop
			jmp .notFound    

			;  If rayDistX >= rayDistY then step in y direction

.XLTY  		lda raySignX				; mapX = mapX + raySignX ... where raySignX = can be -1 or +1
			clc							; Uses ray sign (+1 or -1) to step
			adc rayMapX					; through the map in x direction.
			sta rayMapX

			; Check if cell is empty
	
			tay							; Y register =column of the map
			ldx rayMapY					; X register =row of the map 
			jsr getCellCode

			;cmp #$20
			;bne .cellFoundX
			cmp #128					; Anything below code 128 is empty space
			bcs .cellFoundX				
  
			inc rayDeltaX+1				;rayDeltaX = rayDeltaX + 1.0

			;If cell is empty then accumulate the length of the ray
	
			lda rayUnitXDist			;rayDistX = rayDistX + rayDistUX              
			clc
			adc rayDistX
			sta rayDistX
			lda rayUnitXDist+1
			adc rayDistX+1
			sta rayDistX+1
  
			dec B
			bne .loop
			jmp .notFound

; ----------------------------------------------------------------------  
;                       Cell found at X intersection
; ----------------------------------------------------------------------
  
.cellFoundX	lda #1
			sta raySide					; 0=not found, 1=X axis, 2=Y axis 
	
			lda rayDistX				;rayDistance = rayDistX
			sta rayDistance
			ldx rayDistX+1
			stx rayDistance+1

			; If we are in the 3D view mode, then we don't have to 
			; calculate rayDeltaY. rayDeltaY is used for the ray sprite.
			; We can exit here and that will increase the speed.

			lda screen.ViewMode			; If 2D then calculate rayDeltaY
			beq .calcDeltaY
			rts

			; rayDeltaX is known. rayDeltaY has to be calculated 

.calcDeltaY	
			; abs(sin(Heading)) is already precalculated
			
			lda player.absHeadSin
			sta DL
			lda player.absHeadSin+1
			sta DH

			lda rayDistance				; result = DX * rayDistance
			sta CL
			lda rayDistance+1
			sta CH
			jsr multiply

			lda result+1				; rayDeltaX = result
			sta rayDeltaY
			lda result+2
			sta rayDeltaY+1 

			rts  
  
; ----------------------------------------------------------------------  
;                       Cell found at Y intersection
; ----------------------------------------------------------------------  

.cellFoundY	lda #2
			sta raySide					; 0=not found, 1=X axis, 2=Y axis 

			lda rayDistY				; rayDistance = rayDistY
			sta rayDistance
			lda rayDistY+1
			sta rayDistance+1

			; If we are in the 3D view mode, then we don't have to 
			; calculate rayDeltaX. rayDeltaX is used for the ray sprite.
			; We can exit here and that will increase the speed.

			lda screen.ViewMode			; If 2D then calculate rayDeltaX
			beq .calcDeltaX
			rts

			;rayDeltaY is known. rayDeltaX has to be calculated 
	
.calcDeltaX 
			; abs(cos(Heading)) is already precalculated
			
			lda player.absHeadCos
			sta DL
			lda player.absHeadCos+1
			sta DH
	
			lda rayDistance				; result = DX * rayDistance
			sta CL
			lda rayDistance+1
			sta CH
			jsr multiply
	
			lda result+1				; rayDeltaX = RESULT
			sta rayDeltaX
			lda result+2
			sta rayDeltaX+1   

			rts
  
; ----------------------------------------------------------------------  
;                                Cell not found
; ----------------------------------------------------------------------   

.notFound	lda #0
			sta raySide	; 0=not found, 1=X axis, 2=Y axis 
			rts
			
			

!zone getUnitXDist
; ******************************************************************************
;                   GET UNIT DISTANCE AT THE X INTERSECTION  
; 
; Description:	Return an absolute value of a slope length when X is 1 unit long.
; 				Angles 90° and 270° are special cases when X=1 because the length
; 				is infinite for those angles.
; 				Angles 0° and 180° are special cases when Y=1 because the length
; 				is infinite for those angles.
; 				Table contains angles from 0 to 255 ticks. 
; 				Tick 256 is not included.
;
; Input:		rayHeading		Word	Heading of the ray in ticks
; 
; Output:		rayUnitXDist	Float	Absolute value of the slope length
;				raySignX		Single	1=positive / -1=negative
; 
; ******************************************************************************

getUnitXDist

		 	lda rayHeading+1
			lsr							; Get quadrant parity (odd quadrant: Carry=1)

			ldy rayHeading				; Carry is still preserved
			bne .notSpecial				; If lo-byte is 0 then it is a special case.

			; Special case for X axis (90° = $0100 Ticks, 270° = $0300 Ticks)
	
			bcc .read					; Only odd quadrants. Skip if even.
	
			lda #255
			sta rayUnitXDist			; If the quadrant is odd (hi-byte) and
			sta rayUnitXDist+1			; the lo-byte is zero, then this it is
			jmp .setSign				; a special case (90°or 270°).  

.notSpecial	bcc .read					; If quadrant is even then read from the front.

			; For odd quadrants read the table from the rear to front.
	
			tya							; Calculate two's complement
			eor #255					; so that we read from the back
			tay
			iny

.read		lda slopeLen.lo,y
			sta rayUnitXDist			; Distance traveled with X=1 unit length
			lda slopeLen.hi,y
			sta rayUnitXDist+1			; Distance traveled with X=1 unit length

.setSign	ldy rayHeading+1			; Get quadrant
			lda .tblSignX,y
			sta raySignX				; Sign for the X axis
	
			rts
		    
; Quadrant signs

.tblSignX	!byte  1,-1,-1, 1 			 
  

!zone getUnitYDist
; ******************************************************************************
;                     GET UNIT DISTANCE AT THE Y INTERSECTION 
; 
; Description:	Return an absolute value of a slope length when y is 1 unit long.
; 				Angles 90° and 270° are special cases when y=1 because the length
; 				is infinite for those angles.
; 				Angles 0° and 180° are special cases when y=1 because the length
; 				is infinite for those angles.
; 				Table contains angles from 0 to 255 ticks. 
; 				Tick 256 is not included.
;
; Input:		rayHeading		Word	Heading of the ray in ticks
; 
; Output:		rayUnitYDist	Float	Absolute value of the slope length
;				raySignY		Single	1=positive / -1=negative
; 
; ******************************************************************************

getUnitYDist

			lda rayHeading+1
			lsr							; Get quadrant parity (odd quadrant: Carry=1)
		
			ldy rayHeading				; Carry is still preserved    
			bne .notSpecial				; If lo-byte is 0 then it is a special case.

			; Special case for X axis (0° = $0000 Tick, 180° = $0200 Tick)

			bcs .read					; Only even quadrant. Skip if odd.
	
			lda #255
			sta rayUnitYDist			; If the quadrant is even (hi-byte) and
			sta rayUnitYDist+1			; the lo-byte is zero, then this it is
			jmp .setSign				; a special case (0°or 180°).  

.notSpecial	bcs .read					; If quadrant is odd then read from the front.

			; For even quadrants read the table from the back to the front.

			tya							; Calculate two's complement	
			eor #255					; so that we read from the back	
			tay
			iny

.read		lda slopeLen.lo,y
			sta rayUnitYDist
			lda slopeLen.hi,y
			sta rayUnitYDist+1  

.setSign	ldy rayHeading+1			; Get the quadrant
			lda .tblSignY,y
			sta raySignY
	
			rts 

; Quadrant signs      

.tblSignY	!byte -1,-1, 1, 1 			; INVERTED!!!   


; Slope length for ticks 0 to 255
; slopeLen = 1 / cos(i)
; Where i is the angle between 0 and 90
; and step is 340/1024
; High byte is integer part, low byte is remainder in fixed point format

!zone slopeLen
.hi		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,001,001,001,001,001
		!byte 001,001,001,001,001,001,001,001,001,001,001,002,002,002,002,002
		!byte 002,002,002,002,002,002,002,002,002,002,002,002,002,002,002,002
		!byte 002,002,002,002,002,002,002,002,002,003,003,003,003,003,003,003
		!byte 003,003,003,003,003,003,003,004,004,004,004,004,004,004,004,004
		!byte 005,005,005,005,005,006,006,006,006,007,007,007,008,008,009,009
		!byte 010,010,011,012,013,014,016,018,020,023,027,032,040,054,081,162

.lo		!byte 000,000,000,000,000,000,000,000,000,000,000,001,001,001,001,001
		!byte 001,001,002,002,002,002,002,003,003,003,003,004,004,004,004,005
		!byte 005,005,006,006,006,007,007,008,008,008,009,009,010,010,011,011
		!byte 012,012,013,013,014,014,015,015,016,016,017,018,018,019,020,020
		!byte 021,022,023,023,024,025,026,026,027,028,029,030,031,031,032,033
		!byte 034,035,036,037,038,039,040,041,042,044,045,046,047,048,049,051
		!byte 052,053,054,056,057,058,060,061,063,064,066,067,069,070,072,074
		!byte 075,077,079,080,082,084,086,088,090,091,093,095,097,100,102,104
		!byte 106,108,111,113,115,118,120,123,125,128,130,133,136,139,142,145
		!byte 148,151,154,157,160,163,167,170,174,177,181,185,189,193,197,201
		!byte 205,209,213,218,223,227,232,237,242,247,252,002,007,013,019,025
		!byte 031,037,044,051,057,064,072,079,087,095,103,111,120,129,138,147
		!byte 157,167,177,188,199,211,223,235,248,005,019,033,048,064,080,096
		!byte 114,132,151,171,192,214,236,004,030,056,084,113,144,177,212,249
		!byte 032,074,119,166,217,016,076,139,209,028,110,200,043,153,019,155
		!byte 052,225,168,141,152,212,079,030,097,074,043,154,191,084,125,250
		
		
		
		
          