
*=$c000

; a lone comment
val:
		.byte	$42

; entry point
; second line of same comment
entry_point:
		lda #$01
		rts 