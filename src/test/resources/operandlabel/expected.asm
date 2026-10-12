
*=$c000

entry:
		lda #$05
		lda #$00
; modified by: entry
dC003 = $c003
		ldx #$03
; modified by: entry
count = $c005
		dec dC003
		dec count
		inc entry + 1
		rts 