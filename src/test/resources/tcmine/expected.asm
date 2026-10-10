
*=$c000

xx_1:
		lda #$40
		sta $fb
		lda #$04
		sta $fd
		lda #$00
		jsr lC40E
		nop 
		sta $fe
		sta $ff
		ldx $033f

lC015:
		beq lC028
		lda $fa
		clc 
		adc #$59
		sta $fa
		lda $fb
		adc #$01
		sta $fb
		dex 
		jmp lC015

lC028:
		ldx #$00

lC02A:
		ldy #$00
		lda ($fa), y
		lsr 
		lsr 
		lsr 
		lsr 
		tay 
		lda $c076, y
		ldy $fe
		sta ($fc), y
		ldy #$00
		lda ($fa), y
		and #$0f
		tay 
		lda $c080, y
		inc $fe
		ldy $fe
		sta ($fc), y
		inc $fe
		inx 
		lda $fa
		clc 
		adc #$01
		sta $fa
		bcc lC058
		inc $fb

lC058:
		cpx #$0e
		bcc lC02A
		inc $ff
		lda $fc
		clc 
		adc #$28
		sta $fc
		bcc lC069
		inc $fd

lC069:
		ldx #$00
		stx $fe
		ldx $ff
		cpx #$18
		bcc lC028
		rts 
*=$c40e

lC40E:
		lda #$29
		sta $fc
		lda #$00
		sta $fa
		rts 