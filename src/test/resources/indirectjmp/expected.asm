
*=$C000

entry:
		JMP (aC010)
*=$C010

aC010:
		.addr	lC020
*=$C020

lC020:
		LDA #$42
		RTS 