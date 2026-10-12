
.virtual $0002
velocity:		.char	?
.endv

*=$c000

start:
		lda deltas
		rts 

; read by: start
deltas:
		.char	-3, 3, -128, 127

speeds:
		.sint	-32768, -1

offset:
		.dint	-2