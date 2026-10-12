
*=$c000

entry:
		lda hiscore
		rts 

screen:
		.byte	$20, $20, $30, $30, $30, $30, $20, $20
; the high score sits inside the screen
; read by: entry
hiscore = $c006

vector:
		.word	$c000
vector_hi = $c00d