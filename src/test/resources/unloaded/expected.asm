; called by: entry
l0100 = $0100
; copied here at run time
relocated = $0200
*=$c000

entry:
		jsr l0100
		beq lC040
		lda #$01
; jumped to by: entry
lC040 = $c040