
*=$c000

entry:
		lda plain, x
		rts 

; read by: entry
plain:
		.text	"HELLO"
nulled:
		.null	"BYE"
counted:
		.ptext	"ABC"
mixed:
		.text	"HI", $0d, $22, "Q", $22
long_nulled:
		.text	"THE QUICK BROWN FOX JUMPS OVER T"
		.null	"HE LAZY "