
.virtual $0010
counter:		.byte	?
pair:
		.fill	2
.endv

*=$c000

entry:
		lda @w counter
		sta @w $00ff, x
		ldx @w $0020, y
		lda counter
		sta $ff, x
		ldx $20, y
		lda ($30, x)
		lda ($40), y
		lda pair
		lda pair + $1
		lda @w pair + $1
		jmp entry