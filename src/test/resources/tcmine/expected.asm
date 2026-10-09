
*=$C000

xx_1:
		LDA #$40
		STA $FB
		LDA #$04
		STA $FD
		LDA #$00
		JSR lC40E
		NOP 
		STA $FE
		STA $FF
		LDX $033F

lC015:
		BEQ lC028
		LDA $FA
		CLC 
		ADC #$59
		STA $FA
		LDA $FB
		ADC #$01
		STA $FB
		DEX 
		JMP lC015

lC028:
		LDX #$00

lC02A:
		LDY #$00
		LDA ($FA), Y
		LSR 
		LSR 
		LSR 
		LSR 
		TAY 
		LDA $C076, Y
		LDY $FE
		STA ($FC), Y
		LDY #$00
		LDA ($FA), Y
		AND #$0F
		TAY 
		LDA $C080, Y
		INC $FE
		LDY $FE
		STA ($FC), Y
		INC $FE
		INX 
		LDA $FA
		CLC 
		ADC #$01
		STA $FA
		BCC lC058
		INC $FB

lC058:
		CPX #$0E
		BCC lC02A
		INC $FF
		LDA $FC
		CLC 
		ADC #$28
		STA $FC
		BCC lC069
		INC $FD

lC069:
		LDX #$00
		STX $FE
		LDX $FF
		CPX #$18
		BCC lC028
		RTS 
*=$C40E

lC40E:
		LDA #$29
		STA $FC
		LDA #$00
		STA $FA
		RTS 