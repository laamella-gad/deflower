
*=$C000

entry_b:
		LDA #$40
		STA $FB
		LDA #$04
		STA $FD
		LDA #$00
		JSR _C40E_CODE
		NOP 
		STA $FE

marker_b:
		.BYTE	$85, $FF, $AE, $3F
*=$C40E

_C40E_CODE:
		LDA #$29
		STA $FC
		LDA #$00
		STA $FA
		RTS 