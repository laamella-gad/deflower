; jumped to by: start
l0116 = $0116
*=$0801

; BASIC stub: SYS 2061
basic_stub:
		.byte	$0b, $08, $ef, $00, $9e, $32, $30, $36, $31, $00, $00, $00

start:
		sei 
		inc $d030
		lda #$38
		sta $01
		ldx #$34
; jumped to by: start
l0817:
		lda $0842, x
		sta $01ff, x
		dex 
		bne l0817
		ldx #$cf
; jumped to by: start
l0822:
		lda $0875, x
		sta @w $00f6, x
		dex 
		bne l0822
		ldy #$69
; jumped to by: start
l082D:
		dex 
		lda $707b, x
; modified by: start
d0830 = $0830
		sta $ec13, x
; modified by: start
d0833 = $0833
		txa 
		bne l082D
		dec d0833
		dec d0830
		dey 
		bne l082D
		jmp l0116