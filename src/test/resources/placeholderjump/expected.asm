
*=$c000

entry:
		jsr blob
		rts 

blob:
		lda #$01
		rts 
		.byte	$11, $22