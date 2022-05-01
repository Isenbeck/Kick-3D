
!zone main
; ********************************************************************************
;                                      MAIN
; ********************************************************************************

main 		

			jsr setup
	
.loop		jsr userEvents
			jsr displayEvents

			jmp .loop


!zone setup
; ********************************************************************************
;                                    INITIALIZE
;
; Description:	Initialize program
;
; Inputs:		none
;
; Outputs:		none
;
; ********************************************************************************

setup 		

			lda CONTROL_REG_1			; Switch off Extended color mode               
			and #%10000000				; Preserve raster position bit 8
			ora #%00011011				; Set defaults
			sta CONTROL_REG_1	
	
			; Initialize sprites
	
			jsr initSprites
	
			; Set 2D game view mode
	
			lda #0
			jsr setViewMode
	
			; Initialize player
	
			lda #$00					; Set player heading
			sta player.Heading
			lda #$00
			sta player.Heading+1
	
			jsr getDirVect				; Get unit direction vector
	
			lda #0
			sta player.PosX				; Set remainder to zero
			sta player.PosX+1
	
			lda #20
			sta player.PosX+2			; Set integer part to 20
	
			lda #0
			sta player.PosY				; Set remainder to zero
			sta player.PosY+1	
	
			lda #12
			sta player.PosY+2			; Set integer part to 20
	
			; Set screen colors
	
			lda #0
			sta BORDER_COLOR
			sta BCKGRND_COLOR_0
	
			; set ray angle
			
			lda #0
			sta rayHeading
			sta rayHeading+1
			
			; Interrupts
			jsr setInterrupt
			
			;; Location event A sequencer
			;lda #0
			;sta sequencer_A.accum
			;sta sequencer_A.count
			;lda #20
			;sta sequencer_A.preset
			;lda #8
			;sta sequencer_A.rollover
	
			rts

			

!zone memCopy	
; *******************************************************************************
;                                   COPY MEMORY BLOCK
;
; Inputs:		CX		Word	Source address
;
;				DX		Word	Destination address
;
;				RAX		Word	Size of a memory block in bytes
;								A register	Low byte
;								X register	High byte 
; *******************************************************************************

memCopy 	

			sta EL					; EX = RAX (where A=low byte, X=high byte)
			stx EH
		
			ldy #0					; Using X and Y registers as a counter (RYX 16-bit word)
			ldx #0					; Y register is low byte, X register is hight byte

.loop		lda (CX),y
			sta (DX),y
			iny
			bne .skip

			inc CH
			inc DH
			inx

.skip	  	cpy EL					; If counter < EDX then loop 
			txa
			sbc EH
			bcc .loop

			rts



