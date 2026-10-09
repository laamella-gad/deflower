
*=$C000

my_array:
		.byte	$11, $22, $33, $44, $55, $66

mid_ptr:
		.word	$BBAA
		.byte	$77, $88, $99, $AA, $BB, $CC, $DD, $EE

entry:
		STA my_array + $5
		STA my_array + $8
		STA mid_ptr
		RTS 