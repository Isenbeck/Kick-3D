
!zone sinus
; ********************************************************************************
;                                  SINUS
;
; Description:	Calculate sinus of an angle
;
; Input:		RAX		Word	Angle stored in A and X registers
;
;
; Output:		DX		Real	Result (fixed point arythmetic)
;				EX		Real	Absolute value of the sinus
;
; ********************************************************************************/

sinus 		

			ldy #0
			sty DL
			sty DH
			sty EL
			sty EH

			tay							; Store A to Y

			txa                         ; Check if quadrant is positive
			lsr							; If the quadrand is positive
			bcc .readFwd				; then read the table from the front.

			; Special case (angle 90 and 270 - just for negative quadrants)

			tya							; Y back to A
			bne .notSpec				; If A = 0 then it is special
			inc DH						; Angle 90 = quadrant 1 (negative)
			inc EH
			bne .setSign				; Angle 270 = quadrant 3 (negative)

			; If not special then read table from the back

.notSpec	eor #255					; Reversing table reading direction
			tay							; Two's complement
			iny

  			; Read table from the front
  
.readFwd	lda tblSine,y
			sta DL
		    sta EL 
   
			; Get sign from quadrants (X contains hi-byte, i.e. quadrant)
  
.setSign	lda .sinSign,x				; Return sign in Y register
			bpl .exit					; Don't negate if positive.

			lda #0						; Negating result if sign is negative.
			sec							; Two's complement.
			sbc DL						; Instead EOR#255 and then adding 1
			sta DL						; simply substract number from zero.
			lda #0
			sbc DH                                              
			sta DH

.exit	  	rts							; Second return (for odd cases)  

			; Local variables and tables

.sinSign	!byte -1,-1, 1, 1			; REVERSED!!!!



!zone cosinus
; ********************************************************************
;                                  Cosine
;
; Description: Calulate cosine of an angle
;
; Input:    	RAX		Word	Angle in ticks
;
; Output:  		DX		Real	Result (fixed point arythmetic)
;				EX		Real	Absolute value of the cosine
;
; ********************************************************************/

cosinus 	

			ldy #0
			sty DL						; DX will conatain result
			sty DH
			sty EL						; EX will contain absolute of the result
			sty EH

			tay							; Store A to Y

			txa							; If the quadrant is negative 
			lsr							; then read the table from the front.
			bcs .readFwd  

			; Special case (angle 0 and 180)

			tya							; Copy lo-byte to Y
			bne .notSpec
			inc DH						; If angle is 0 or 180 then
			inc EH
			bne .setSign

			; Normal case

.notSpec  	eor #255					; Reversing table reading direction
			tay
			iny
  
.readFwd 	lda tblSine,y
			sta DL 
			sta EL
  
			; Get sign from quadrants (X contains hi-byte, i.e. quadrant)
  
.setSign	lda .cosSign,x		
			bpl .exit					; Don't negate if positive.
	
			lda #0						; Negating result if sign is negative.
			sec							; Two's complement.
			sbc DL						; Instead EOR#255 and then adding 1
			sta DL						; simply substract number from zero.
			lda #0
			sbc DH
			sta DH

.exit	  	rts

			; Local variables and tables

.cosSign	!byte  1,-1,-1, 1  



;********************************************************************  
;               Ancient Egyptian Multiplication method
;
; Example:
; 1. Half the first number until we get to 1, ignoring reminders.
;    Double the second number each time we half the first number.
;
; Half    13 x 24    Double
;         6    48
;         3    96
;         1   192
;
; 2. Exclude rows that are starting (left column) with even numbers.
; 3. Then add numbers in the righ column.
;
; Half    13 x 24    Double
;         3    96
;         1   192
;         -------
;             312 <- result 
;********************************************************************



!zone multiply
;********************************************************************
;                            Multiplication
;
; multiply16:   Word x Word = DWord
; multiply32:   Word x DWord = DWord 
; Input:  	CX       Word    Factor1
;           DX       Word    Factor2 for 16x16-bit multiplication  
;           EL       Byte    Factor2 for 16x32-bit multiplication
;  
; Output: result   DWord   Result of the operation 24-bit       
;
; ******************************************************************** 
 
multiply 	

			lda #0
			sta EL
	
 			lda #0					
			sta result
			sta result+1
			sta result+2

			beq .enter

.doAdd		lda DL
			clc
			adc result
			sta result
			lda DH
			adc result+1
			sta result+1
			lda EL
			adc result+2
			sta result+2
  
.loop 		asl DL
			rol DH
			rol EL

.enter		lsr CH
			ror CL
			bcs .doAdd 					; If the number was odd then do addition

			lda CH
			ora CL
			bne .loop					; If the number <> 0 then do loop

			rts
			
 





