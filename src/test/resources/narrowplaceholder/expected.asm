
*=$C000

unknown_block:
		.byte	$11, $22, $33, $44

carved_word:
		.word	$BEEF
		.byte	$55, $66

carved_code:
		RTS 
		.byte	$77, $88, $99, $AA, $BB, $CC