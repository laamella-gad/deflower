
*=$C000

entry:
		JSR blob
		RTS 

blob:
		LDA #$01
		RTS 
		.byte	$11, $22