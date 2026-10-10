
*=$C000

entry:
		LDA hiscore
		RTS 

screen:
		.byte	$20, $20, $30, $30, $30, $30, $20, $20
; the high score sits inside the screen
hiscore = $C006

vector:
		.word	$C000
vector_hi = $C00D