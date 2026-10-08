
*=$C000

two_words:
		.WORD	$1234, $5678

dword_val:
		.DWORD	$44332211

greeting:
		.BYTE	'H', 'i', '!'