
*=$c000

entry:
		jsr blob
		rts 

; called by: entry
blob:
		lda #$01
		rts 
		.byte	$11, $22