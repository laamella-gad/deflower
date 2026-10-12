
*=$c000

entry:
		ldx #$03
; jumped to by: entry
lC002:
		jsr lC016
		dex 
		bne lC002
		bmi lC021
		lda #$00
		beq lC00F
		nop 
; jumped to by: entry
lC00F:
		sta value
		jsr lC021
		rts 

; called by: entry
lC016:
		ldy #$00
; jumped to by: lC016
lC018:
		lda value
		iny 
		bne lC018
		jmp lC024

; called by: entry
; jumped to by: entry
lC021:
		inc value
; jumped to by: lC016
lC024:
		rts 

; read by: lC016
; written by: entry
; modified by: lC021
value:
		.byte	$00