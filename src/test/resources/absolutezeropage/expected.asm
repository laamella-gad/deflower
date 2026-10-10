
.virtual $0010
counter:		.byte	?
pair:
		.fill	2
.endv

*=$C000

entry:
		LDA @w counter
		STA @w $00FF, X
		LDX @w $0020, Y
		LDA counter
		STA $FF, X
		LDX $20, Y
		LDA ($30, X)
		LDA ($40), Y
		LDA pair
		LDA pair + $1
		LDA @w pair + $1
		JMP entry