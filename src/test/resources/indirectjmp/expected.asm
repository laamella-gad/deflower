
*=$C000

entry:
		JMP (pC010)
*=$C010

pC010:
		.addr	lC020
*=$C020

lC020:
		LDA #$42
		RTS 