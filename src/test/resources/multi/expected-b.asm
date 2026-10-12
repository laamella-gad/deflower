
*=$c000

entry_b:
		lda #$40
		sta $fb
		lda #$04
		sta $fd
		lda #$00
		jsr lC40E
		nop 
		sta $fe

marker_b:
		.byte	$85, $ff, $ae, $3f
*=$c40e

; called by: entry_b
lC40E:
		lda #$29
		sta $fc
		lda #$00
		sta $fa
		rts 