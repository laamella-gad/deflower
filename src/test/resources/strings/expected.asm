
*=$C000

entry:
		LDA plain, X
		RTS 

plain:
		.text	"HELLO"
nulled:
		.text	"BYE", $00
counted:
		.text	$03, "ABC"
mixed:
		.text	"HI", $0D, $22, "Q", $22
long_nulled:
		.text	"THE QUICK BROWN FOX JUMPS OVER T"
		.text	"HE LAZY ", $00