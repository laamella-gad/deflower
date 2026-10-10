
*=$c000

entry:
		lda greeting, x
		rts 

greeting:
		.enc	"screen"
		.text	"HELLO, World!"
; reverse video "HEI", a double quote, then "@A"
odd_codes:
		.text	$88, $85, $89, $22, "@A"
; lowercase only: no uppercase letters either way, a tie
ascii_text:
		.text	$61, $62, $63
ok_text:
		.text	"OK"
; digits read the same either way: a tie keeps the encoding in effect
digits:
		.text	"123HI"
upper_ascii:
		.enc	"none"
		.text	"XYZ"