
*=$0100

; called by: $247e
l0100:
		brk 
*=$0147

; jumped to by: $248b
l0147:
		brk 
*=$0801

; BASIC stub: SYS 2061
basic_stub:
		.byte	$0b, $08, $14, $00, $9e, $32, $30, $36, $31, $00, $00, $00

start:
		ldy #$1e
		tsx 

; jumped to by: start
l0810:
		lda $248d, x
		sta @w $00fc, x
		dex 
		bne l0810
		jmp l2452
*=$2452

; jumped to by: start, $2459
l2452:
		lda $255d, y
		sta $07fd, y
		dey 
		bne l2452

; jumped to by: $2487
l245B:
		inx 
		tya 
		and #$0f
		beq l2475
		txa 
		lsr 
		ldx $0333, y

; jumped to by: $246a
l2466:
		rol 
		rol $9f
		dex 
		bpl l2466
		adc $0367, y
		tax 
		lda $9f
		adc $039b, y

; jumped to by: $245f
l2475:
		sta $039c, y
		txa 
		sta $0368, y
		ldx #$04
		jsr l0100
		sta $0334, y
		iny 
		cpy #$34
		bne l245B
		ldy #$00
		jmp l0147