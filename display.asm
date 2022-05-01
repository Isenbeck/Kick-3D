
!zone screen:

	.ViewMode	!byte 0				; Game view mode (0=2D, 1=3D)
	.Column		!byte 0
	.DrawTop	!byte 0				; Top row
	.DrawBottom	!byte 0				; Bottom row
	.EndRow		!byte 0
	.ChrBuffer	!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	


!zone displayEvents
; ********************************************************************************
;                                    DISPLAY EVENTS
;
; Description:	Manage display events
; ********************************************************************************

displayEvents:

			lda screen.ViewMode
			bne .is3D
	
			; 2D display

			jsr movePlayerSpr			; Move player sprite
			jsr moveDirSpr				; Move direction spriteData
	
			lda player.Heading
			sta rayHeading
			lda player.Heading+1
			sta rayHeading+1
			jsr rayCast
	
			jmp moveRaySpr
	
			; 3D display
	
.is3D		jsr rayScan
			jsr drawScreen
			jsr moveBackSpr
	
			rts
			


!zone setViewMode
; ********************************************************************************
;                                 SET VIEW MODE
;
; Description:	Set display view mode. 0=2d, 1=3d
; ********************************************************************************

setViewMode
		
			sta screen.ViewMode
			bne .set_3D
	
			; Set 2D mode
	
			; Set player movement speed
	
			lda #1
			sta player.MovSpeed			; Movement speed multiplier as power of 2
			lda #1
			sta player.RotSpeed			; Rotation speed in Ticks

			; Enable sprites
	
			lda #%00000111				; Enable sprites 0 to 2
			sta SPRITE_ENABLE
			
			; Set interrupt routine
	
			lda #BLACK
			sta setInterrupt.scanColor1
			sta setInterrupt.scanColor2
			lda #50
			sta setInterrupt.scanLine1
			lda #250
			sta setInterrupt.scanLine2
			
			; Show map
	
			jmp showMap		
			
			
			; Set 3D mode
	
			; Set player movement speed

.set_3D		lda #6
			sta player.MovSpeed			; Movement speed multiplier as power of 2
			lda #32
			sta player.RotSpeed			; Rotation speed in Ticks
	
		 	; Enable sprites
	
			lda #%00111000				; Enable sprites 3 to 5
			sta SPRITE_ENABLE
			
			; Set interrupt routine

			lda #CYAN
			sta setInterrupt.scanColor1
			lda #GREEN
			sta setInterrupt.scanColor2
			lda #0
			sta setInterrupt.scanLine1
			lda #151
			sta setInterrupt.scanLine2
	
			rts
			
		

!zone showMap
; ********************************************************************************
;                                 SHOW MAP
;
; Description:	Show map on screen
; ********************************************************************************

showMap 	lda #<map					; Copy map
			sta CL
			lda #>map
			sta CH

			lda #<SCREEN_RAM
			sta DL
			lda #>SCREEN_RAM
			sta DH

			lda #$e8					; size of memory block
			ldx #$03

			jsr memCopy 
	
			; Copy color information

showColor	lda #<colorMap
			sta CL
			lda #>colorMap
			sta CH

			lda #<COLOR_RAM
			sta DL
			lda #>COLOR_RAM
			sta DH

			lda #$e8					; size of memory block
			ldx #$03

			jmp memCopy
			


!zone drawScreen
; ******************************************************************************
;                                    DRAW SCREEN
; ******************************************************************************

drawScreen: ldy #0

.loop		sty screen.Column
  
			lda zBuffer.lo,y			; n = int(ZBuffer(column) * 8)
			sta B
			lda zBuffer.hi,y
			asl B
			rol
			asl B
			rol
  
			tax							; drawStart = tblWallTop(n)
			lda wallTop,x
			sta screen.DrawTop

			lda #49						; drawEnd = 49 - drawStart
			sec
			sbc screen.DrawTop
			sta screen.DrawBottom

			; If rayCounter is odd then do the right column
		
			lda screen.Column
			lsr
			bcs .right

			; Draw the left column
	
			jsr drawLeft
			jmp .next


			; Draw the right column
	
.right		jsr drawRight
			jsr printColumn 

			; Loop
  
.next	 	ldy screen.Column
			iny
			cpy #80
			bcc .loop

			rts
			


!zone drawLeft
; ********************************************************************
;                             DRAW LEFT COLUMN 
; ********************************************************************

drawLeft 	; Fast buffer clear routine

			lda #0
			sta screen.ChrBuffer
			sta screen.ChrBuffer+1
			sta screen.ChrBuffer+2
			sta screen.ChrBuffer+3
			sta screen.ChrBuffer+4
			sta screen.ChrBuffer+5
			sta screen.ChrBuffer+6
			sta screen.ChrBuffer+7
			sta screen.ChrBuffer+8
			sta screen.ChrBuffer+9
			sta screen.ChrBuffer+10
			sta screen.ChrBuffer+11
			sta screen.ChrBuffer+12
			sta screen.ChrBuffer+13
			sta screen.ChrBuffer+14
			sta screen.ChrBuffer+15
			sta screen.ChrBuffer+16
			sta screen.ChrBuffer+17
			sta screen.ChrBuffer+18
			sta screen.ChrBuffer+19
			sta screen.ChrBuffer+20
			sta screen.ChrBuffer+21
			sta screen.ChrBuffer+22
			sta screen.ChrBuffer+23
			sta screen.ChrBuffer+24
  
			; 0. Clear the column
			; 1. Draw bottom break character at correct position 
			; 2. Draw top break character at correct psition
			; 3. Fill from the top to bottom break characters with the full column character

			; Prepare characters

			lda screen.DrawBottom 	; n = drawEnd / 2
			lsr						; endRow = n
			tax						; If drawEnd is odd then Carry = 1
			sta screen.EndRow		; Actual screen row [0 to 24]

			lda #10					; 10 = Full left column						    	■□
			bcs .full_btm			; If drawEnd is odd then draw a full column char. 	■□

			; Prepare bottom left character
	
			lda #8					; 8 = partial bottom char  ■□ 
									;						   □□
.full_btm	sta screen.ChrBuffer,x

			; Draw top break
	
			lda screen.DrawTop
			lsr						; If drawStart is odd then Carry = 1
			tax						; Store draw start row into X register
			bcc .full_top			; If drawStart is even then draw a full column char.

			lda #2					; □□
			bne .not_full			; ■□
	
			; Loop from start row to end row and fill with the full char 
	
.full_top	lda #10

.not_full	sta screen.ChrBuffer,x

			inx
			cpx screen.EndRow
			bne .full_top

			rts 
			 

  
!zone drawRight
; ********************************************************************
;                             DRAW RIGHT COLUMN 
; ********************************************************************

drawRight	; Draw bottom right break

			lda screen.DrawBottom
			lsr
			tax
			sta screen.EndRow

			lda #5
			bcs .full_btm

			lda #4

.full_btm	ora screen.ChrBuffer,x
			sta screen.ChrBuffer,x  

			; Draw top right break

			lda screen.DrawTop
			lsr
			tax                         // Store start row into the X register 
			bcc .full_top

			lda #1
			bne .not_full

			; Draw the rest
	
.full_top 	lda #5
  
.not_full  	ora screen.ChrBuffer,x
			sta screen.ChrBuffer,x

			inx
			cpx screen.EndRow
			bne .full_top
			rts 

			

!zone printColumn
; ********************************************************************
;                             PRINT COLUMN
; ******************************************************************** 

printColumn: 

			lda screen.Column
			lsr
			tax

			ldy screen.ChrBuffer
			lda PETscii,y
			sta SCREEN_RAM+0*40,x

			ldy screen.ChrBuffer+1
			lda PETscii,y  
			sta SCREEN_RAM+1*40,x 

			ldy screen.ChrBuffer+2
			lda PETscii,y
			sta SCREEN_RAM+2*40,x     

			ldy screen.ChrBuffer+3
			lda PETscii,y
			sta SCREEN_RAM+3*40,x

			ldy screen.ChrBuffer+4
			lda PETscii,y
			sta SCREEN_RAM+4*40,x 

			ldy screen.ChrBuffer+5
			lda PETscii,y
			sta SCREEN_RAM+5*40,x

			ldy screen.ChrBuffer+6
			lda PETscii,y
			sta SCREEN_RAM+6*40,x

			ldy screen.ChrBuffer+7
			lda PETscii,y
			sta SCREEN_RAM+7*40,x

			ldy screen.ChrBuffer+8
			lda PETscii,y
			sta SCREEN_RAM+8*40,x

			ldy screen.ChrBuffer+9
			lda PETscii,y
			sta SCREEN_RAM+9*40,x

			ldy screen.ChrBuffer+10
			lda PETscii,y
			sta SCREEN_RAM+10*40,x   

			ldy screen.ChrBuffer+11
			lda PETscii,y
			sta SCREEN_RAM+11*40,x

			ldy screen.ChrBuffer+12
			lda PETscii,y
			sta SCREEN_RAM+12*40,x

			ldy screen.ChrBuffer+13
			lda PETscii,y
			sta SCREEN_RAM+13*40,x

			ldy screen.ChrBuffer+14
			lda PETscii,y
			sta SCREEN_RAM+14*40,x

			ldy screen.ChrBuffer+15
			lda PETscii,y
			sta SCREEN_RAM+15*40,x

			ldy screen.ChrBuffer+16
			lda PETscii,y
			sta SCREEN_RAM+16*40,x

			ldy screen.ChrBuffer+17
			lda PETscii,y
			sta SCREEN_RAM+17*40,x 

			ldy screen.ChrBuffer+18
			lda PETscii,y
			sta SCREEN_RAM+18*40,x

			ldy screen.ChrBuffer+19
			lda PETscii,y
			sta SCREEN_RAM+19*40,x

			ldy screen.ChrBuffer+20
			lda PETscii,y
			sta SCREEN_RAM+20*40,x

			ldy screen.ChrBuffer+21
			lda PETscii,y
			sta SCREEN_RAM+21*40,x
	
			ldy screen.ChrBuffer+22
			lda PETscii,y
			sta SCREEN_RAM+22*40,x

			ldy screen.ChrBuffer+23
			lda PETscii,y
			sta SCREEN_RAM+23*40,x

			ldy screen.ChrBuffer+24
			lda PETscii,y
			sta SCREEN_RAM+24*40,x

			; Fast Draw Color 

			; ldx screen.column
	
			lda colorBuffer,x
			sta COLOR_RAM+0*40,x
			sta COLOR_RAM+1*40,x
			sta COLOR_RAM+2*40,x
			sta COLOR_RAM+3*40,x
			sta COLOR_RAM+4*40,x
			sta COLOR_RAM+5*40,x
			sta COLOR_RAM+6*40,x
			sta COLOR_RAM+7*40,x
			sta COLOR_RAM+8*40,x
			sta COLOR_RAM+9*40,x
			sta COLOR_RAM+10*40,x
			sta COLOR_RAM+11*40,x
			sta COLOR_RAM+12*40,x
			sta COLOR_RAM+13*40,x
			sta COLOR_RAM+14*40,x
			sta COLOR_RAM+15*40,x
			sta COLOR_RAM+16*40,x
			sta COLOR_RAM+17*40,x
			sta COLOR_RAM+18*40,x
			sta COLOR_RAM+19*40,x
			sta COLOR_RAM+20*40,x
			sta COLOR_RAM+21*40,x
			sta COLOR_RAM+22*40,x
			sta COLOR_RAM+23*40,x
			sta COLOR_RAM+24*40,x

			rts
			 
 	
			
