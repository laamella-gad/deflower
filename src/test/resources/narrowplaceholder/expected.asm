
*=$c000

unknown_block:
		.byte	$11, $22, $33, $44

carved_word:
		.word	$beef
		.byte	$55, $66

carved_code:
		rts 
		.byte	$77, $88, $99, $aa, $bb, $cc