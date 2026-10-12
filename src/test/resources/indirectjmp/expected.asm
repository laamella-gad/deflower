
*=$c000

entry:
		jmp (aC010)
*=$c010

; read by: entry
aC010:
		.addr	lC020
*=$c020

lC020:
		lda #$42
		rts 