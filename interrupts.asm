

!zone setInterrupt
; **********************************************************************
;                           RASTER INTERRUPTS
; **********************************************************************
setInterrupt

			sei						; set interrupt bit, make the CPU ignore interrupt requests
			lda #$7f				; switch off interrupt signals from CIA-1
			sta $dc0d
			sta $dd0d

			and CONTROL_REG_1		; clear most significant bit of VIC's raster register
			sta CONTROL_REG_1

			lda $dc0d				; acknowledge pending interrupts from CIA-1
			lda $dd0d				; acknowledge pending interrupts from CIA-2

			lda #151				; set rasterline where interrupt shall occur
			sta RASTER_POS

			lda #<irq1				; set interrupt vectors, pointing to interrupt service routine below
			sta $0314
			lda #>irq1
			sta $0315

			lda #$01				; enable raster interrupt signals from VIC
			sta IMR

			cli						; clear interrupt flag, allowing the CPU to respond to interrupt requests
			rts

irq1		asl IRR					; acknowledge the interrupt by clearing the VIC's interrupt flag
  
			lda .scanColor2
			sta BCKGRND_COLOR_0

			lda #<irq2				; set interrupt vectors to the second interrupt service routine at Irq2
			sta $0314
			lda #>irq2
			sta $0315

			lda .scanLine1
			sta RASTER_POS			; next interrupt will occur at line no. 0

			jmp $ea81				; jump into shorter ROM routine to only restore registers from the stack etc    
  
irq2		asl IRR					; acknowledge the interrupt by clearing the VIC's interrupt flag

			lda .scanColor1
			sta BCKGRND_COLOR_0  

			lda #<irq1				; set interrupt vectors back to the first interrupt service routine at Irq
			sta $0314
			lda #>irq1
			sta $0315

			lda .scanLine2
			sta RASTER_POS			; next interrupt will occur at line no. 210

			jmp $ea31				; jump into KERNAL's standard interrupt service routine to handle keyboard scan, cursor display etc.j
  
; Local variables			

.scanLine1:		!byte 0			
.scanLine2:		!byte 0			
.scanColor1:	!byte 0			
.scanColor2:	!byte 0			
			
			