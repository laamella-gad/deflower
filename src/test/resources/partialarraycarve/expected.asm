
*=$c000

; written by: entry
my_array:
		.byte	$11, $22, $33, $44, $55, $66

; written by: entry
mid_ptr:
		.word	$bbaa
		.byte	$77, $88, $99, $aa, $bb, $cc, $dd, $ee

entry:
		sta my_array + $5
		sta my_array + $8
		sta mid_ptr
		rts 