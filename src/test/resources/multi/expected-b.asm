
*=$C000

entry_b:
		LDA #$40
		STA $FB
		LDA #$04
		STA $FD
		LDA #$00
		JSR lC40E
		NOP 
		STA $FE

marker_b:
		.byte	$85, $FF, $AE, $3F
*=$C40E

lC40E:
		LDA #$29
		STA $FC
		LDA #$00
		STA $FA
		RTS 