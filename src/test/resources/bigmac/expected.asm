
*=$0314

; the IRQ vector
irq_vector:
		.addr	irq
*=$c100

lC100:
		lda $c0c1
		beq lC109
		dec $c0c1
		rts 

lC109:
		lda $c0bc
		sta $c0c1
		lda $c0c0
		beq lC127
		cmp #$01
		bne lC123
		jsr lC1DF
		bmi lC123
		ldx $c0a4
		stx $d404

lC123:
		dec $c0c0
		rts 

lC127:
		jsr lC1CA

lC12A:
		jsr lC1D8
		bne lC14E
		lda $e7e0
		bne lC137
		jmp lC1E6

lC137:
		lda $e7e1
		sta $c0c4
		jsr lC1BB
		lda $e7e2
		sta $c0c3
		lda #$00
		sta $e7e0
		clc 
		bcc lC192

lC14E:
		cmp #$ff
		bne lC198
		jsr lC1DF
		bne lC168
		lda #$01
		sta $e7e0
		lda $c0c4
		sta $e7e1
		sty $e7e2
		clc 
		bcc lC175

lC168:
		lda $c0c2
		bmi lC16F
		bne lC18D

lC16F:
		jsr lC1DF
		sta $c0c2

lC175:
		jsr lC1CA
		jsr lC1DF
		sta $c0c4
		jsr lC1D8
		sta $c0c3
		jsr lC1BB
		ldy $c0c3
		clc 
		bcc lC12A

lC18D:
		dec $c0c2
		bne lC175

lC192:
		jsr lC1CA
		clc 
		bcc lC127

lC198:
		cmp #$7f
		beq lC1B0
		tax 
		lda $c000, x
		sta $d401
		lda $c050, x
		sta $d400
		ldx $c0a4
		inx 
		stx $d404

lC1B0:
		jsr lC1DF
		asl 
		sta $c0c0
		jmp lC123
*=$c1bb

lC1BB:
		lda $c0c4
		clc 
		adc #$e0
		sta $c1dd
		adc #$08
		sta $c1e4
		rts 

lC1CA:
		inc $c0c3
		ldy $c0c3
		bne lC1D7
		inc $c0c4
		bne lC1BB

lC1D7:
		rts 

lC1D8:
		ldy $c0c3
		lda $e000, y
		rts 

lC1DF:
		ldy $c0c3
		lda $e800, y
dC1E4 = $c1e4
		rts 

lC1E6:
		lda $c0cf
		and #$fe
		sta $c0cf
		lda #$00
		sta $e7e0
		sta $c0c2
		sta $c0c0
		sta $c0c1
		sta $c0c3
		rts 

lC200:
		lda $c0c6
		beq lC209
		dec $c0c6
		rts 

lC209:
		lda $c0bd
		sta $c0c6
		lda $c0c5
		beq lC227
		cmp #$01
		bne lC223
		jsr lC2DF
		bmi lC223
		ldx $c0ab
		stx $d40b

lC223:
		dec $c0c5
		rts 

lC227:
		jsr lC2CA

lC22A:
		jsr lC2D8
		bne lC24E
		lda $a7e0
		bne lC237
		jmp lC2E6

lC237:
		lda $a7e1
		sta $c0c9
		jsr lC2BB
		lda $a7e2
		sta $c0c8
		lda #$00
		sta $a7e0
		clc 
		bcc lC292

lC24E:
		cmp #$ff
		bne lC298
		jsr lC2DF
		bne lC268
		lda #$01
		sta $a7e0
		lda $c0c9
		sta $a7e1
		sty $a7e2
		clc 
		bcc lC275

lC268:
		lda $c0c7
		bmi lC26F
		bne lC28D

lC26F:
		jsr lC2DF
		sta $c0c7

lC275:
		jsr lC2CA
		jsr lC2DF
		sta $c0c4
		jsr lC2D8
		sta $c0c8
		jsr lC2BB
		ldy $c0c8
		clc 
		bcc lC22A

lC28D:
		dec $c0c7
		bne lC275

lC292:
		jsr lC2CA
		clc 
		bcc lC227

lC298:
		cmp #$7f
		beq lC2B0
		tax 
		lda $c000, x
		sta $d408
		lda $c050, x
		sta $d407
		ldx $c0ab
		inx 
		stx $d40b

lC2B0:
		jsr lC2DF
		asl 
		sta $c0c5
		jmp lC223
*=$c2bb

lC2BB:
		lda $c0c9
		clc 
		adc #$a0
		sta $c2dd
		adc #$08
		sta $c2e4
		rts 

lC2CA:
		inc $c0c8
		ldy $c0c8
		bne lC2D7
		inc $c0c9
		bne lC2BB

lC2D7:
		rts 

lC2D8:
		ldy $c0c8
		lda $a000, y
		rts 

lC2DF:
		ldy $c0c8
		lda $a800, y
dC2E4 = $c2e4
		rts 

lC2E6:
		lda $c0cf
		and #$fd
		sta $c0cf
		lda #$00
		sta $a7e0
		sta $c0c7
		sta $c0c5
		sta $c0c6
		sta $c0c8
		rts 

lC300:
		lda $c0cb
		beq lC309
		dec $c0cb
		rts 

lC309:
		lda $c0be
		sta $c0cb
		lda $c0ca
		beq lC327
		cmp #$01
		bne lC323
		jsr lC3DF
		bmi lC323
		ldx $c0b2
		stx $d412

lC323:
		dec $c0ca
		rts 

lC327:
		jsr lC3CA

lC32A:
		jsr lC3D8
		bne lC34E
		lda $b7e0
		bne lC337
		jmp lC3E6

lC337:
		lda $b7e1
		sta $c0ce
		jsr lC3BB
		lda $b7e2
		sta $c0cd
		lda #$00
		sta $b7e0
		clc 
		bcc lC392

lC34E:
		cmp #$ff
		bne lC398
		jsr lC3DF
		bne lC368
		lda #$01
		sta $b7e0
		lda $c0ce
		sta $b7e1
		sty $b7e2
		clc 
		bcc lC375

lC368:
		lda $c0cc
		bmi lC36F
		bne lC38D

lC36F:
		jsr lC3DF
		sta $c0cc

lC375:
		jsr lC3CA
		jsr lC3DF
		sta $c0ce
		jsr lC3D8
		sta $c0cd
		jsr lC3BB
		ldy $c0cd
		clc 
		bcc lC32A

lC38D:
		dec $c0cc
		bne lC375

lC392:
		jsr lC3CA
		clc 
		bcc lC327

lC398:
		cmp #$7f
		beq lC3B0
		tax 
		lda $c000, x
		sta $d40f
		lda $c050, x
		sta $d40e
		ldx $c0b2
		inx 
		stx $d412

lC3B0:
		jsr lC3DF
		asl 
		sta $c0ca
		jmp lC323
*=$c3bb

lC3BB:
		lda $c0ce
		clc 
		adc #$b0
		sta $c3dd
		adc #$08
		sta $c3e4
		rts 

lC3CA:
		inc $c0cd
		ldy $c0cd
		bne lC3D7
		inc $c0ce
		bne lC3BB

lC3D7:
		rts 

lC3D8:
		ldy $c0cd
		lda $b000, y
		rts 

lC3DF:
		ldy $c0cd
		lda $b800, y
dC3E4 = $c3e4
		rts 

lC3E6:
		lda $c0cf
		and #$fb
		sta $c0cf
		lda #$00
		sta $b7e0
		sta $c0cc
		sta $c0ca
		sta $c0cb
		sta $c0cd
		rts 
*=$c48d

lC48D:
		lda $01
		and #$fd
		sta $01
		rts 

lC494:
		lda $01
		ora #$03
		sta $01
		rts 
*=$c543

; the IRQ handler the vector points to
irq:
		jsr lC48D
		lda $c0cf
		beq lC566
		lsr 
		pha 

; where the CPU was when the snapshot was taken
snapshot_pc:
		bcc lC555
		jsr lC100
		nop 
		nop 
		nop 

lC555:
		pla 
		lsr 
		pha 
		bcc lC55D
		jsr lC200

lC55D:
		pla 
		lsr 
		bcc lC566
		nop 
		nop 
		jsr lC300

lC566:
		jsr lC494
		jmp lEA31
*=$ea31

lEA31:
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($01, x)
		ora ($0c, x)
		isc @w $0000, x
		brk 