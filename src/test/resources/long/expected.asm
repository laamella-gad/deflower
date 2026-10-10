
.virtual $0004
timer:		.long	?
.endv

*=$c000

start:
		lda scores
		rts 

scores:
		.long	$123456, $ffffff

offsets:
		.lint	-3, -8388608