
*=$C000

unknown_block:
		.BYTE	$11, $22, $33, $44

carved_word:
		.WORD	$BEEF
		.BYTE	$55, $66

carved_code:
		RTS 
		.BYTE	$77, $88, $99, $AA, $BB, $CC