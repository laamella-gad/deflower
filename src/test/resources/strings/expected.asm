
*=$c000

entry:
		lda plain, x
		rts 

; read by: entry
plain:
		.text	"HELLO"
nulled:
		.text	"BYE", $00
counted:
		.text	$03, "ABC"
mixed:
		.text	"HI", $0d, $22, "Q", $22
long_nulled:
		.text	"THE QUICK BROWN FOX JUMPS OVER T"
		.text	"HE LAZY ", $00