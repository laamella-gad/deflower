
*=$0314

; the KERNAL's IRQ and NMI vectors, pointing into RAM under BASIC
irq_vector:
		.addr	irq
*=$0318

nmi_vector:		.addr	nmi
*=$0900

l0900:
		stx $06
		ldx #$00
		cmp #$00
		beq l0910

l0908:
		inx 
		lsr 
		php 
		ror $06
		plp 
		bne l0908

l0910:
		ldy $06
		lda $0986, y
		cpy #$00
		beq l091B
		clc 
		rts 

l091B:
		ldx #$c0
		sec 
		rts 

l091F:
		cmp #$80
		bcc l0927
		and #$7f
		bpl l092B

l0927:
		dex 
		dex 
		dex 
		dex 

l092B:
		tay 
		lda $0a86, y
		sta $06
		lda #$00
		cpx #$00
		beq l0941
		bmi l0945

l0939:
		asl $06
		rol 
		bcs l0942
		dex 
		bne l0939

l0941:
		clc 

l0942:
		ldx $06
		rts 

l0945:
		lsr $06
		inx 
		bne l0945
		beq l0941

l094C:
		jsr l0960

l094F:
		clc 
		adc $0e
		sta $0e
		php 
		txa 
		adc $0f
		plp 
		bcc l095D
		adc #$06

l095D:
		sta $0f
		rts 

l0960:
		clc 
		eor #$ff
		adc #$01
		pha 
		php 
		txa 
		clc 
		eor #$ff
		adc #$01
		plp 
		bcs l0972
		sbc #$07

l0972:
		tax 
		pla 
		rts 

l0975:
		sec 
		sbc $0e
		sta $0e
		php 
		txa 
		sbc $0f
		plp 
		bcs l0983
		sbc #$06

l0983:
		sta $0f
		rts 
*=$0b06

l0B06:
		lda $2c5e
		ldx $2c5d
		jsr l0900
		sta $0e
		stx $0f
		sta $0ba2
		stx $0ba3
		lda $0b9c
		ldx $0b9d
		jsr l0975
		lda $0e
		ldx $0f
		jsr l091F
		sta $1f27
		stx $1f26
		lda $2c5c
		php 
		bpl l0B46
		lda #$00
		sec 
		sbc $2c5b
		sta $2c5b
		lda #$00
		sbc $2c5c
		sta $2c5c

l0B46:
		ldx $2c5b
		jsr l0900
		sta $0e
		stx $0f
		lda $0b9a
		ldx $0b9b
		jsr l094F
		lda $0ba2
		ldx $0ba3
		jsr l094C
		lda $0e
		ldx $0f
		jsr l091F
		sta $1f25
		stx $1f24
		lda #$80
		plp 
		bmi l0B85
		clc 
		adc $1f24
		sta $1f24
		lda $1f25
		adc #$00
		sta $1f25
		bcc l0B94

l0B85:
		sec 
		sbc $1f24
		sta $1f24
		lda #$00
		sbc $1f25
		sta $1f25

l0B94:
		rts 

l0B95:
		rts 
*=$0ba4

l0BA4:
		lda #$00
		sta $22
		lda $12
		sec 
		sbc $1d
		sta $12
		lda $13
		sbc $1e
		sta $13
		asl 
		rol $22
		lda $12
		ldx $13
		bpl l0BC3
		clc 
		eor #$ff
		adc #$01

l0BC3:
		sta $21
		lda $10
		sec 
		sbc $1b
		sta $10
		lda $11
		sbc $1c
		sta $11
		asl 
		rol $22
		lda $10
		ldx $11
		bpl l0BE0
		clc 
		eor #$ff
		adc #$01

l0BE0:
		cmp $21
		rol $22
		ora $21
		bmi l0BFC
		ldx $22
		lda $0c08, x
		sec 
		sbc $0db8
		beq l0BF9
		and #$07
		cmp #$07
		bne l0BFC

l0BF9:
		jmp l0C2A

l0BFC:
		lda #$ff
		cmp $0c07
		beq l0BF9
		sta $2c5e
		rts 
*=$0c2a

l0C2A:
		lda $10
		sta $2c5b
		lda $11
		sta $2c5c
		lda $12
		sta $2c5d
		lda $13
		sta $2c5e
		rts 
*=$0d73

l0D73:
		lda $0db8
		sec 
		sbc #$01

l0D79:
		and #$07
		sta $0db8
		asl 
		tax 
		and #$02
		bne l0D91
		lda $0da8, x
		sta l0BF9 + 1
		lda $0da9, x
		sta l0BF9 + 2
		rts 

l0D91:
		lda #$73
		sta l0BF9 + 1
		lda #$0c
		sta l0BF9 + 2
		lda $0da8, x
		sta $0d02
		lda $0da9, x
		sta $0d03
		rts 
*=$0db9

l0DB9:
		lda $0db8
		clc 
		adc #$01
		bpl l0D79

l0DC1:
		pha 
		jsr l0DC7
		pla 
		rts 

l0DC7:
		and #$7f
		cmp #$20
		bcs l0DD0
		jmp l0E4B

l0DD0:
		sec 
		sbc #$20
		sta $04
		lda #$00
		asl $04
		rol 
		asl $04
		rol 
		asl $04
		rol 
		sta $05
		lda $04
		clc 
		adc $0eee
		sta $04
		lda $05
		adc $0eef
		sta $05
		lda $1f
		cmp #$a0
		bcc l0E08
		lda $05
		pha 
		lda $04
		pha 
		jsr l0E4F
		pla 
		sta $04
		pla 
		sta $05
		lda $1f

l0E08:
		ldx $20
		jsr l12F0
		tya 
		clc 
		adc $0a
		sta $0a
		lda $0b
		adc #$00
		sta $0b
		ldy #$00

l0E1B:
		lda ($04), y
		lsr 
		lsr 
		lsr 
		lsr 
		jsr l0EC7
		iny 
		cpy #$08
		bcc l0E1B
		tya 
		clc 
		adc $0a
		sta $0a
		lda $0b
		adc #$00
		sta $0b
		ldy #$00

l0E37:
		lda ($04), y
		and #$0f
		jsr l0EC7
		iny 
		cpy #$08
		bcc l0E37
		lda $1f
		clc 
		adc #$08
		sta $1f

l0E4A:
		rts 

l0E4B:
		cmp #$0d
		bne l0E65

l0E4F:
		lda #$00
		sta $1f

l0E53:
		lda $20
		sec 
		sbc #$08
		bcs l0E60
		jsr l0E79
		jmp l0E4A

l0E60:
		sta $20
		jmp l0E4A

l0E65:
		cmp #$0a
		beq l0E53
		cmp #$0c
		bne l0E78
		jsr l1010
		lda #$00
		sta $1f
		lda #$c7
		sta $20

l0E78:
		rts 

l0E79:
		lda #$ff
		sta $04
		lda #$5f
		sta $05
		lda #$3f
		sta $0a
		lda #$61
		sta $0b
		ldx #$30

l0E8B:
		ldy #$a0

l0E8D:
		lda ($0a), y
		sta ($04), y
		dey 
		bne l0E8D
		lda #$a0
		clc 
		adc $0a
		sta $0a
		lda $0b
		adc #$00
		sta $0b
		lda #$a0
		clc 
		adc $04
		sta $04
		lda $05
		adc #$00
		sta $05
		dex 
		bne l0E8B
		lda #$00
		ldy #$a0

l0EB5:
		sta $7dff, y
		sta $7e9f, y
		dey 
		bne l0EB5
		lda #$00
		sta $1f
		lda #$07
		sta $20
		rts 

l0EC7:
		tax 
		lda $0edd, x
		pha 
		eor #$ff
		and ($0a), y
		sta $0eed
		pla 
		and $1368
		ora $0eed
		sta ($0a), y
		rts 
*=$0ffb

l0FFB:
		jmp l0DC1
*=$1010

l1010:
		lda #$00
		sta $06
		lda #$60
		sta $07
		lda #$c0
		sta $08
		lda #$e0
		sta $09
		ldy #$00

l1022:
		lda #$00
		sta ($06), y
		iny 
		bne l102B
		inc $07

l102B:
		inc $08
		bne l1022
		inc $09
		bne l1022
		rts 

l1034:
		lda #$c1
		sta l0FFB + 1
		lda #$0d
		sta l0FFB + 2
		lda #$08
		ora $d018
		sta $d018
		lda #$20
		ora $d011
		sta $d011
		lda #$10
		ora $d016
		sta $d016
		rts 
*=$127d

l127D:
		tsx 
		lda $0103, x
		tay 
		ldx $18
		lda $127c
		beq l12AC
		lda $17ad
		bne l12AC
		stx $12ed
		sty $12ec
		lda $10
		cmp $11
		bcs l129E

d129A:
		dey 
		jmp l129F

l129E:
		dex 

l129F:
		txa 
		pha 
		tya 
		pha 
		jsr l1306
		beq l12AD

l12A8:
		pla 
		pla 
		lda #$ff

l12AC:
		rts 

l12AD:
		lda $12ef
		php 
		ldx #$00
		stx $12ef
		plp 
		bne l12A8
		dex 
		stx $12ef
		ldx $127c
		pla 
		sta $107c, x
		lda $12ec
		sta $117c, x
		inx 
		pla 
		sta $107c, x
		lda $12ed
		sta $117c, x
		inx 
		stx $127c
		lda $12ec
		ldx $12ed
		jsr l12F0
		lda ($0a), y
		and $1369, x
		sta ($0a), y
		lda #$00
		rts 
*=$12f0

l12F0:
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		rts 

l1306:
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		and $136d, x
		rts 

l1321:
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		sta $06
		and $136d, x
		bne l1354
		lda $136d, x
		and $1368
		ora $06
		sta ($0a), y
		lda $107b
		beq l1357
		jsr l127D
		jmp l1357

l1354:
		sta $12ef

l1357:
		sta $107b
		dec $107a
		bne l1367
		inc $107b
		lda #$0a
		sta $107a

l1367:
		rts 
*=$1501

l1501:
		txa 
		pha 
		ldx $18
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		sta $06
		and $136d, x
		bne l1538
		lda $136d, x
		and $1368
		ora $06
		sta ($0a), y
		lda $107b
		beq l153B
		jsr l127D
		jmp l153B

l1538:
		sta $12ef

l153B:
		sta $107b
		dec $107a
		bne l154B
		inc $107b
		lda #$0a
		sta $107a

l154B:
		pla 
		tax 
		rts 

l154E:
		lda #$ea
		sta d129A
		sty $18
		ldx $14
		cpx $13
		bcc l1562
		lda #$ca
		sta l1567
		bne l1567

l1562:
		lda #$e8
		sta l1567

l1567:
		dex 
		cpx #$a0
		bcs l15C1
		txa 
		pha 
		ldx $18
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		sta $06
		and $136d, x
		bne l15A3
		lda $136d, x
		and $1368
		ora $06
		sta ($0a), y
		lda $107b
		beq l15A6
		jsr l127D
		jmp l15A6

l15A3:
		sta $12ef

l15A6:
		sta $107b
		dec $107a
		bne l15B6
		inc $107b
		lda #$0a
		sta $107a

l15B6:
		pla 
		tax 
		cpx $13
		bne l1567
		lda $17ac
		bne l1567

l15C1:
		lda #$00
		sta $17ac
		stx $14
		rts 

l15C9:
		lda #$ea
		sta l129E
		cpy $16
		bne l15DF
		txa 
		pha 
		lda #$00
		sta $17ac
		tya 
		tax 
		pla 
		jmp l1321

l15DF:
		bcc l15EB
		lda #$c8
		sta d129A
		sta l15F5
		bne l15F3

l15EB:
		lda #$88
		sta d129A
		sta l15F5

l15F3:
		ldy $16

l15F5:
		dey 
		cpy $29
		bcc l1657
		cpy $67
		bcs l1657
		sty $18
		txa 
		pha 
		ldx $18
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		sta $06
		and $136d, x
		bne l1637
		lda $136d, x
		and $1368
		ora $06
		sta ($0a), y
		lda $107b
		beq l163A
		jsr l127D
		jmp l163A

l1637:
		sta $12ef

l163A:
		sta $107b
		dec $107a
		bne l164A
		inc $107b
		lda #$0a
		sta $107a

l164A:
		pla 
		tax 
		ldy $18
		cpy $12
		bne l15F5
		lda $17ac
		bne l15F5

l1657:
		lda #$00
		sta $17ac
		sty $16
		rts 

l165F:
		stx $13
		lda #$ff
		sta $1368
		sty $12
		txa 
		pha 
		tya 
		pha 
		ldx $14
		ldy $16
		sty $18
		lda $107b
		pha 
		lda #$00
		sta $107b
		jsr l1501
		pla 
		sta $107b
		pla 
		tay 
		pla 
		tax 
		lda #$ff
		sta $0f
		txa 
		sec 
		sbc $14
		bne l1693
		jmp l15C9

l1693:
		bcs l1698
		jmp l176B

l1698:
		ldx #$ca
		stx l129E
		ldx #$e8
		stx l16EC

l16A2:
		sta $10
		tya 
		sec 
		sbc $16
		bne l16AD
		jmp l154E

l16AD:
		bcs l16B2
		jmp l1785

l16B2:
		ldy #$c8
		sty d129A
		sty l16FA

l16BA:
		sta $11
		ora $10
		bmi l16CA

l16C0:
		asl $10
		asl $11
		lda $10
		ora $11
		bpl l16C0

l16CA:
		ldx $14
		ldy $16
		sty $18
		lda $10
		sta $16e5
		ldy $11
		sty $17a1
		sty $16f5
		ldy $18
		lda #$80
		pha 

l16E2:
		pla 
		clc 
		adc #$c0
		pha 
		bcs l16EC
		jmp l179D

l16EC:
		inx 
		cpx #$a0
		bcs l1760
		lda $0f
		clc 
		adc #$a0
		sta $0f
		bcc l1703

l16FA:
		dey 
		cpy $29
		bcc l1760
		cpy $67
		bcs l1760

l1703:
		sty $18
		txa 
		pha 
		ldx $18
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		sta $06
		and $136d, x
		bne l173C
		lda $136d, x
		and $1368
		ora $06
		sta ($0a), y
		lda $107b
		beq l173F
		jsr l127D
		jmp l173F

l173C:
		sta $12ef

l173F:
		sta $107b
		dec $107a
		bne l174F
		inc $107b
		lda #$0a
		sta $107a

l174F:
		pla 
		tax 
		ldy $18
		cpx $13
		bne l16E2
		cpy $12
		bne l16E2
		lda $17ac
		bne l16E2

l1760:
		lda #$00
		sta $17ac
		stx $14
		sty $16
		pla 
		rts 

l176B:
		pha 
		lda $0f
		eor #$ff
		sta $0f
		pla 
		ldx #$e8
		stx l129E
		clc 
		eor #$ff
		adc #$01
		ldx #$ca
		stx l16EC
		jmp l16A2

l1785:
		pha 
		lda $0f
		eor #$ff
		sta $0f
		pla 
		clc 
		eor #$ff
		adc #$01
		ldx #$88
		stx d129A
		stx l16FA
		jmp l16BA

l179D:
		lda $0f
		clc 
		adc #$a0
		sta $0f
		bcs l17A9
		jmp l16E2

l17A9:
		jmp l16FA
*=$17ae

l17AE:
		tya 
		pha 
		ldy $18
		lda $28
		cmp ($64), y
		bcs l17BA
		sta ($64), y

l17BA:
		lda ($08), y
		and #$0f
		cmp #$0f
		beq l17C9
		cmp $1bb2
		beq l17CE
		bne l17D6

l17C9:
		lda $1bb2
		sta ($08), y

l17CE:
		lda #$aa
		sta $1368
		pla 
		tay 
		rts 

l17D6:
		ora $1bb3
		sta ($08), y
		lda #$55
		sta $1368
		pla 
		tay 
		rts 
*=$18ab

l18AB:
		cpy #$c8
		bcc l18B0
		rts 

l18B0:
		sta $1bb2
		asl 
		asl 
		asl 
		asl 
		sta $1bb3
		stx $0e
		stx $10
		sty $0d
		txa 
		ldx $0d
		jsr l18EF
		beq l18C9
		rts 

l18C9:
		ldx $10
		ldy $0d
		lda #$ff
		sta $12
		ldy #$00
		txa 
		sta $0ef0, y
		iny 
		sta $0ef0, y
		iny 
		lda $0d
		clc 
		adc #$01
		sta $0ef0, y
		iny 
		lda #$01
		sta $0ef0, y
		iny 
		sty $13
		bne l1929

l18EF:
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		and $136d, x
		rts 

l190A:
		ldy $13
		bne l190F
		rts 

l190F:
		dey 
		lda $0ef0, y
		sta $12
		dey 
		lda $0ef0, y
		sta $0d
		dey 
		lda $0ef0, y
		sta $10
		dey 
		lda $0ef0, y
		sta $0e
		sty $13

l1929:
		lda $0e
		clc 
		adc $10
		ror 
		cmp #$a0
		bcs l190A
		sta $0c
		sta $06
		ldx $0d
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		lda ($0a), y
		and $136d, x
		beq l19A7
		lda $10
		cmp $0c
		beq l1994
		sbc #$01
		cmp $0c
		beq l1994
		ldx $0c
		ldy $13
		txa 
		adc #$00
		sta $0ef0, y
		iny 
		lda $10
		sta $0ef0, y
		iny 
		lda $0d
		sta $0ef0, y
		iny 
		lda $12
		sta $0ef0, y
		iny 
		sty $13
		bne l1989
		lda $13
		sec 
		sbc #$04
		sta $13

l1989:
		stx $10
		cpx $0e
		bne l1992
		jmp l190A

l1992:
		bne l1929

l1994:
		lda $0e
		sta $10
		ldx $0d
		jsr l18EF
		bne l19A2
		jmp l1929

l19A2:
		beq l19A7
		jmp l190A

l19A7:
		tya 
		pha 
		lda $0d
		and #$fe
		tay 
		lda $17e3, y
		sta $08
		lda $17e4, y
		sta $09
		lda $08
		sta $64
		lda $09
		clc 
		adc #$87
		sta $65
		lda $0c
		lsr 
		lsr 
		sta $18
		pla 
		tay 
		jsr l17AE

l19CE:
		lda ($0a), y

l19D0:
		and $136d, x
		bne l1A1F
		lda $136d, x
		and $1368
		ora ($0a), y
		sta ($0a), y
		dex 
		dec $06
		lda $06
		cmp #$ff
		beq l1A1F
		cpx #$ff
		bne l19CE

l19EC:
		lda #$08
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $0a
		sta $0a
		lda $0b
		sbc #$00
		sta $0b
		ldx #$03
		lda ($0a), y
		and #$03
		bne l1A1F
		dec $18
		jsr l17AE
		lda ($0a), y
		bne l19D0
		lda $1368
		sta ($0a), y
		lda $06
		sec 
		sbc #$04
		sta $06
		bcs l19EC
		bcc l1A1F

l1A1F:
		inc $06
		lda $0e
		sta $0f
		ldx $06
		stx $0e
		tya 
		pha 
		lda $0d
		and #$fe
		tay 
		lda $17e3, y
		sta $08
		lda $17e4, y
		sta $09
		lda $08
		sta $64
		lda $09
		clc 
		adc #$87
		sta $65
		lda $0c
		lsr 
		lsr 
		sta $18
		pla 
		tay 
		jsr l17AE
		lda $0c
		sta $06
		ldx $0d
		pha 
		and #$fc
		asl 
		tay 
		lda $1371, x
		sta $0a
		lda $1439, x
		adc #$00
		sta $0b
		pla 
		and #$03
		tax 
		bcc l1A7E

l1A6D:
		lda ($0a), y

l1A6F:
		and $136d, x
		bne l1AB9
		lda $136d, x
		and $1368
		ora ($0a), y
		sta ($0a), y

l1A7E:
		inx 
		inc $06
		lda $06
		cmp #$a0
		bcs l1AB9
		cpx #$04
		bne l1A6D

l1A8B:
		lda #$08
		clc 
		adc $0a
		sta $0a
		lda $0b
		adc #$00
		sta $0b
		ldx #$00
		lda ($0a), y
		and #$c0
		bne l1AB9
		inc $18
		jsr l17AE
		lda ($0a), y
		bne l1A6F
		lda $1368
		sta ($0a), y
		lda $06
		clc 
		adc #$04
		sta $06
		cmp #$a0
		bcc l1A8B

l1AB9:
		dec $06
		lda $10
		sta $11
		ldx $06
		stx $10
		cpx $0e
		bcs l1ACA
		jmp l1BE3

l1ACA:
		lda $0e
		sec 
		sbc $0f
		bcs l1B04
		cmp #$fe
		bcs l1B2D
		ldy $13
		lda $0e
		sta $0ef0, y
		iny 
		lda $0f
		sta $0ef0, y
		iny 
		lda $0d
		sec 
		sbc $12
		sta $0ef0, y
		iny 
		lda $12
		clc 
		eor #$ff
		adc #$01
		sta $0ef0, y
		iny 
		sty $13
		bne l1B2D
		lda $13
		sec 
		sbc #$04
		sta $13
		bne l1B2D

l1B04:
		cmp #$03
		bcc l1B2D
		ldy $13
		lda $0f
		sta $0ef0, y
		iny 
		lda $0e
		sta $0ef0, y
		iny 
		lda $0d
		sta $0ef0, y
		iny 
		lda $12
		sta $0ef0, y
		iny 
		sty $13
		bne l1B2D
		lda $13
		sec 
		sbc #$04
		sta $13

l1B2D:
		lda $10
		sec 
		sbc $11
		bcs l1B5F
		cmp #$fe
		bcs l1B90
		ldy $13
		lda $10
		sta $0ef0, y
		iny 
		lda $11
		sta $0ef0, y
		iny 
		lda $0d
		sta $0ef0, y
		iny 
		lda $12
		sta $0ef0, y
		iny 
		sty $13
		bne l1B90
		lda $13
		sec 
		sbc #$04
		sta $13
		bne l1B90

l1B5F:
		cmp #$03
		bcc l1B90
		ldy $13
		lda $11
		sta $0ef0, y
		iny 
		lda $10
		sta $0ef0, y
		iny 
		lda $0d
		sec 
		sbc $12
		sta $0ef0, y
		iny 
		lda $12
		clc 
		eor #$ff
		adc #$01
		sta $0ef0, y
		iny 
		sty $13
		bne l1B90
		lda $13
		sec 
		sbc #$04
		sta $13

l1B90:
		ldy $13
		beq l1BA1
		dey 
		dey 
		dey 
		lda #$ff
		sta $12ef
		lda #$0a
		sta $107a

l1BA1:
		lda $0d
		clc 
		adc $12
		sta $0d
		cmp $67
		bcc l1BAF
		jmp l190A

l1BAF:
		jmp l1929
*=$1bb4

l1BB4:
		ldy #$02

l1BB6:
		cpy $127c
		beq l1BE2
		lda $117c, y
		iny 
		ldx $117c, y
		sty $18
		jsr lA026
		bne l1BD5
		lda $136d, x
		and $1368
		ora ($0a), y
		sta ($0a), y
		bne l1BDC

l1BD5:
		lda #$ff
		ldy $18
		sta $107c, y

l1BDC:
		ldy $18
		iny 
		jmp l1BB6

l1BE2:
		rts 

l1BE3:
		jmp l1BE3

l1BE6:
		lda $1f26
		sta $28
		lda #$02
		sta $127c
		lda #$ff
		sta $12ee
		jsr lA020
		jmp l1D13
*=$1bfc

l1BFC:
		ldy #$00
		sty $107b
		lda ($04), y
		iny 
		jsr l1D59
		lda $1f24
		clc 
		adc $1f20
		sta $1f20
		lda $1f25
		adc $1f21
		sta $1f21
		lda ($04), y
		iny 
		jsr l1D75
		lda $1f26
		clc 
		adc $1f22
		sta $1f22
		lda $1f27
		adc $1f23
		sta $1f23
		lda $1f20
		sta $14
		lda $1f21
		sta $15
		lda $1f20
		sta $1f18
		lda $1f21
		sta $1f19
		lda $1f22
		sta $16
		lda $1f23
		sta $17
		lda $1f22
		sta $1f1e
		lda $1f23
		sta $1f1f

l1C5F:
		lda ($04), y
		iny 
		cmp #$80
		beq l1CA0
		jsr l1D59
		lda $1f24
		clc 
		adc $1f20
		sta $1f20
		lda $1f25
		adc $1f21
		sta $1f21
		lda ($04), y
		iny 
		sty $1f16
		jsr l1D75
		lda $1f26
		clc 
		adc $1f22
		sta $1f22
		lda $1f27
		adc $1f23
		sta $1f23
		jsr l1DFF
		ldy $1f16
		bne l1C5F

l1CA0:
		sty $1f16
		lda $1f18
		sta $1f20
		lda $1f19
		sta $1f21
		lda $1f1e
		sta $1f22
		lda $1f1f
		sta $1f23
		jsr l1DFF
		ldy $1f16
		lda ($04), y
		iny 
		sty $1f16
		pha 
		jsr l1BB4
		lda $1f24
		sta $1f20
		lda $1f25
		sta $1f21
		lda $1f26
		sta $1f22
		lda $1f27
		sta $1f23
		jsr l1DE4
		bcs l1CF3
		ldx $1f24
		ldy $1f26
		pla 
		pha 
		jsr l18AB

l1CF3:
		ldx $127c
		dex 
		cpx #$02
		bcc l1D0F
		lda $107c, x
		tay 
		dex 
		lda $107c, x
		stx $127c
		tax 
		pla 
		pha 
		jsr l18AB
		jmp l1CF3

l1D0F:
		pla 
		ldy $1f16

l1D13:
		lda ($04), y
		iny 
		cmp #$80
		bne l1D1B
		rts 

l1D1B:
		jsr l1D59
		lda $1f20
		clc 
		adc $1f24
		sta $1f24
		lda $1f21
		adc $1f25
		sta $1f25
		lda ($04), y
		iny 
		jsr l1D75
		lda $1f22
		clc 
		adc $1f26
		sta $1f26
		lda $1f23
		adc $1f27
		sta $1f27
		tya 
		clc 
		adc $04
		sta $04
		lda $05
		adc #$00
		sta $05
		jmp lA023

l1D59:
		stx $1f17
		sty $1f16
		ldx $1f14
		stx $1f15
		jsr l1D90
		sta $1f21
		stx $1f20
		ldx $1f17
		ldy $1f16
		rts 

l1D75:
		stx $1f17
		sty $1f16
		ldy #$ff
		sty $1f15
		jsr l1D90
		stx $1f22
		sta $1f23
		ldx $1f17
		ldy $1f16
		rts 

l1D90:
		cmp #$80
		php 
		bcc l1D9A
		clc 
		eor #$ff
		adc #$01

l1D9A:
		tax 
		lda #$00
		jsr l0900
		sta $0e
		lda $1f15
		bne l1DA8
		dex 

l1DA8:
		stx $0f
		lda $0ba0
		ldx $0ba1
		jsr l094F
		lda $0e
		ldx $0f
		jsr l091F
		plp 
		bcc l1DCA
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00

l1DCA:
		rts 
*=$1dcd

l1DCD:
		lda $15
		ora $17
		bne l1DE2
		lda $14
		cmp #$a0
		bcs l1DE2
		lda $16
		cmp $29
		bcc l1DE2
		cmp $67
		rts 

l1DE2:
		sec 
		rts 

l1DE4:
		lda $1f21
		ora $1f23
		bne l1DFD
		lda $1f20
		cmp #$a0
		bcs l1DFD
		lda $1f22
		cmp $29
		bcc l1DFD
		cmp $67
		rts 

l1DFD:
		sec 
		rts 

l1DFF:
		lda $1f21
		pha 
		lda $1f20
		pha 
		lda $1f23
		pha 
		lda $1f22
		pha 
		lda #$00
		sta $17ad
		jsr l1DCD
		bcc l1E1C
		jmp l1ED2

l1E1C:
		jsr l1DE4
		bcs l1E41

l1E21:
		ldx $1f20
		ldy $1f22
		jsr l165F

l1E2A:
		lda #$ff
		sta $107b
		lda #$00
		sta $17ad
		pla 
		sta $16
		pla 
		sta $17
		pla 
		sta $14
		pla 
		sta $15
		rts 

l1E41:
		lda $1f20
		sta $1f1a
		lda $1f21
		sta $1f1b
		lda $1f22
		sta $1f1c
		lda $1f23
		sta $1f1d
		lda $1f20
		clc 
		adc $14
		sta $1f20
		lda $1f21
		adc $15
		asl 
		php 
		ror 
		plp 
		ror 
		sta $1f21
		ror $1f20
		lda $1f22
		clc 
		adc $16
		sta $1f22
		lda $1f23
		adc $17
		asl 
		php 
		ror 
		plp 
		ror 
		sta $1f23
		ror $1f22
		lda $1f20
		cmp $1f1a
		bne l1E99
		lda $1f21
		cmp $1f1b

l1E99:
		bne l1EC2
		lda $1f22
		cmp $1f1c
		bne l1EA9
		lda $1f23
		cmp $1f1d

l1EA9:
		bne l1EC2
		lda $14
		sta $1f20
		lda $15
		sta $1f21
		lda $16
		sta $1f22
		lda $17
		sta $1f23
		jmp l1E21

l1EC2:
		jsr l1DE4
		bcc l1ECA
		jmp l1E41

l1ECA:
		lda #$ff
		sta $17ac
		jmp l1E21

l1ED2:
		jsr l1DE4
		bcc l1EDA
		jmp l1E2A

l1EDA:
		lda $1f21
		pha 
		lda $1f20
		pha 
		lda $1f23
		pha 
		lda $1f22
		pha 
		lda $14
		sta $1f20
		lda $15
		sta $1f21
		lda $16
		sta $1f22
		lda $17
		sta $1f23
		pla 
		sta $16
		pla 
		sta $17
		pla 
		sta $14
		pla 
		sta $15
		lda #$ff
		sta $17ad
		jmp l1E41
*=$1f2a

l1F2A:
		ldy #$00
		cpy $27
		bne l1F33
		jmp l1FC4

l1F33:
		lda $22db, y
		sec 
		sbc #$30
		sta $1f24
		lda #$00
		sbc #$00
		sta $1f25
		lda $2c5f
		sec 
		sbc $23db, y
		sta $1f26
		lda #$00
		sbc #$00
		sta $1f27
		lda $23db, y
		cmp #$50
		bcs l1FB3
		and #$fe
		cmp #$10
		bcs l1F71
		tax 
		lda $1fc7, x
		sta $0ba0
		lda $1fc8, x
		sta $0ba1
		jmp l1F83

l1F71:
		lsr 
		lsr 
		lsr 
		and #$fe
		tax 
		lda $1fe7, x
		sta $0ba0
		lda $1fe8, x
		sta $0ba1

l1F83:
		lda $21db, y
		sty $2007
		ldx #$00
		stx $1f14
		cmp #$10
		bcc l1F97
		sec 
		sbc #$07
		bcs l1FA1

l1F97:
		cmp #$09
		bcc l1FA1
		sta $1f14
		sec 
		sbc #$09

l1FA1:
		asl 
		tax 
		lda $e000, x
d1FA5 = $1fa5
		sta $04
		lda $e001, x
		sta $05
		jsr l1BE6
		ldy $2007

l1FB3:
		iny 
		cpy #$30
		beq l1FC4
		cpy $27
		bcs l1FBF
		jmp l1F33

l1FBF:
		bcs l1FC4
		jmp l1F33

l1FC4:
		jmp l2539
*=$2008

l2008:
		lda #$00
		sta $2c3e
		ldx #$1d

l200F:
		sta $2bfc, x
		dex 
		bne l200F
		sta $27
		lda $1b
		sta $10
		lda $1c
		sta $11
		lda $1d
l2020 = $2020
		sta $12
		lda $1e
		sta $13
		jsr l24DB
		jsr l2121
		lda #$df
		sta $211f
		lda #$20
		sta $2120
		ldy #$09
		lda $0db8
		asl 
		asl 
		asl 

l203F:
		tax 
		and #$08
		beq l204B
		ldy #$05
l2045 = $2045
		txa 
		clc 
		adc #$02
		tax 

l204B:
		txa 
		clc 
		adc $211f
		sta $211f
		lda $2120
		adc #$00
		sta $2120

l205B:
		sty $20de
		lda $1b
		sta $10
		lda $1c
		sta $11
		lda $1d
		sta $12
		lda $1e
		sta $13
		lda $211f
		sta $08
		lda $2120
		sta $09
		lda ($08), y
		bmi l2089
		clc 
		adc $10
		sta $10
		lda $11
		adc #$00
		sta $11
		bcc l209E

l2089:
		clc 
		eor #$ff
		adc #$01
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $10
		sta $10
		lda $11
		sbc #$00
		sta $11

l209E:
		dey 
		lda ($08), y
		bmi l20B0
		clc 
		adc $12
		sta $12
		lda $13
		adc #$00
		sta $13
		bcc l20C5

l20B0:
		clc 
		eor #$ff
		adc #$01
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $12
		sta $12
		lda $13
		sbc #$00
		sta $13

l20C5:
		dey 
		sty $20de
		jsr l24DB
		jsr l2121
		ldy $20de
		bmi l20D7
		jmp l205B

l20D7:
		jsr l2193
		jsr l1F2A
		rts 
*=$2121

l2121:
		lda #$10
		sta $2538
		inc $08
		bne l212C
		inc $09

l212C:
		ldy #$00

l212E:
		iny 
		lda ($08), y
		cmp #$80
		beq l2184
		clc 
		adc $23
		sta $10
		lda #$00
		adc $24
		sta $11
		iny 
		lda ($08), y
		clc 
		adc $25
		sta $12
		lda #$00
		adc $26
		sta $13
		iny 
		tya 
		clc 
		adc $08
		sta $08
		lda $09
		adc #$00
		sta $09
		jsr l0BA4
		lda $2c5e
		bmi l212C
		jsr l0B06
		ldy #$00
		lda ($08), y
		ora $2538
		ldy $27
		sta $21db, y
		lda $1f24
		sta $22db, y
		lda $1f26
		sta $23db, y
		inc $27
		bne l212C
		dec $27

l2184:
		lda $2538
		beq l2190
		lda #$00
		sta $2538
		beq l212E

l2190:
		jmp l2B87

l2193:
		lda $27
		dec $27

l2197:
		ldy #$00
		sty $0e

l219B:
		lda $23db, y
		cmp $23dc, y
		bcs l21CF
		lda $23db, y
		pha 
		lda $22db, y
		pha 
		lda $21db, y
		pha 
		lda $22dc, y
		sta $22db, y
		lda $23dc, y
		sta $23db, y
		lda $21dc, y
		sta $21db, y
		pla 
		sta $21dc, y
		pla 
		sta $22dc, y
		pla 
		sta $23dc, y
		inc $0e

l21CF:
		iny 
		cpy $27
		bcc l219B
		lda $0e
		bne l2197
		inc $27
		rts 
*=$24db

l24DB:
		lda $10
		and #$c0
		sta $23
		lda $11
		sta $24
		asl $10
		rol 
		asl $10
		rol 
		cmp #$07
		bcs l251D
		sta $2536
		lda $12
		and #$c0
		sta $25
		lda $13
		sta $26
		asl $12
		rol 
		asl $12
		rol 
		cmp #$07
		bcs l251D
		sta $2537
		asl 
		asl 
		asl 
		clc 
		adc $2536
		asl 
		tax 
		lda $824e, x
		sta $08
		lda $824f, x
		sta $09
		rts 

l251D:
		lda #$ff
		sta $2536
		sta $2537
		lda #$2e
		sta $08
		lda #$25
		sta $09
		rts 
*=$2539

l2539:
		lda $2c5f
		clc 
		adc #$01
		sta $67
		nop 
		lda #$07
		sta $2c4f

l2547:
		ldx $2c3e
		beq l25C1
		dex 
		dex 
		stx $2c3e
		lda $2c1a, x
		sta $08
		lda $2c1b, x
		sta $09
		lda $2c26, x
		sta $23
		lda $2c27, x
		sta $24
		lda $2c32, x
		sta $25
		lda $2c33, x
		sta $26
		ldy #$00

l2571:
		lda ($08), y
		cmp #$80
		beq l2547
		lda $23
		and #$c0
		ora ($08), y
		sta $23
		lda $25
		and #$c0
		iny 
		ora ($08), y
		sta $25
		iny 
		lda ($08), y
		iny 
		asl 
		tax 
		lda $09
		pha 
		lda $08
		pha 
		tya 
		pha 
		lda $eb35, x
		sta $08
		lda $eb36, x
		sta $09
		ldy #$06
		tya 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $08
		sta $08
		lda $09
		sbc #$00
		sta $09
		jsr l2703
		pla 
		tay 
		pla 
		sta $08
		pla 
		sta $09
		jmp l2571

l25C1:
		ldx #$1e

l25C3:
		dex 
		bne l25C9
		jmp l28C0

l25C9:
		lda $2bfc, x
		beq l25C3
		txa 
		pha 
		asl 
		tax 
		lda $93f3, x
		sta $08
		lda $93f4, x
		sta $09
		lda #$0d
		cpx #$25
		bcc l25EA
		lda #$0e
		cpx #$2d
		bcs l25EA
		lda #$0c

l25EA:
		sta $2c4f
		jsr l25F4
		pla 
		tax 
		bne l25C3

l25F4:
		ldy #$00
		sty $23
		sty $25
		lda ($08), y
		lsr 
		ror $23
		lsr 
		ror $23
		sta $24
		iny 
		lda ($08), y
		lsr 
		ror $25
		lsr 
		ror $25
		sta $26
		iny 
		lda $2c4f
		cmp #$0d
		beq l262D
		lda #$02
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $08
		sta $08
		lda $09
		sbc #$00
		sta $09
		ldy #$04
		bne l263B

l262D:
		lda ($08), y
		ora $23
		sta $23
		iny 
		lda ($08), y
		ora $25
		sta $25
		iny 

l263B:
		lda ($08), y
		bmi l264C
		clc 
		adc $23
		sta $23
		lda #$00
		adc $24
		sta $24
		bcc l2657

l264C:
		clc 
		adc $23
		sta $23
		lda $24
		sbc #$00
		sta $24

l2657:
		iny 
		lda ($08), y
		bmi l2669
		clc 
		adc $25
		sta $25
		lda #$00
		adc $26
		sta $26
		bcc l2674

l2669:
		clc 
		adc $25
		sta $25
		lda $26
		sbc #$00
		sta $26

l2674:
		iny 
		lda $2c4f
		cmp #$0d
		beq l267F
		jmp l2703

l267F:
		lda $09
		pha 
		lda $08
		pha 
		lda $26
		pha 
		lda $25
		pha 
		lda $24
		pha 
		lda $23
		pha 

l2691:
		lda ($08), y
		iny 
		cmp #$80
		bne l2691
		lda ($08), y
		bmi l26A9
		clc 
		adc $23
		sta $23
		lda #$00
		adc $24
		sta $24
		bcc l26B4

l26A9:
		clc 
		adc $23
		sta $23
		lda $24
		sbc #$00
		sta $24

l26B4:
		iny 
		lda ($08), y
		bmi l26C6
		clc 
		adc $25
		sta $25
		lda #$00
		adc $26
		sta $26
		bcc l26D1

l26C6:
		clc 
		adc $25
		sta $25
		lda $26
		sbc #$00
		sta $26

l26D1:
		tya 
		sec 
		sbc #$05
		clc 
		adc $08
		sta $08
		lda $09
		adc #$00
		sta $09
		ldy #$06
		lda #$05
		sta $2c4f
		jsr l2703
		pla 
		sta $23
		pla 
		sta $24
		pla 
		sta $25
		pla 
		sta $26
		lda #$0d
		sta $2c4f
		pla 
		sta $08
		pla 
		sta $09
		ldy #$06

l2703:
		lda #$00
		sta $2c4d
		sta $107b
		lda #$02
		sta $127c
		jsr l2AC5
		beq l2718
		jmp l2775

l2718:
		lda $1f24
		sta $14
		lda $1f25
		sta $15
		lda $1f26
		sta $16
		lda $1f27
		sta $17
		jsr l1DCD
		bcc l2734
		jmp l2804

l2734:
		lda $2c44
		pha 
		lda $2c43
		pha 
		lda $2c48
		pha 
		lda $2c47
		pha 
		lda $2c43
		sta $2c45
		lda $2c44
		sta $2c46
		lda $2c47
		sta $2c49
		lda $2c48
		sta $2c4a
		jsr l286B
		jsr l28E9
		pla 
		sta $2c47
		pla 
		sta $2c48
		pla 
		sta $2c43
		pla 
		sta $2c44
		jmp l2804

l2775:
		lda $2c4d
		beq l277D
		jmp l283E

l277D:
		lda ($08), y
		cmp #$80
		bne l2786
		jsr l2862

l2786:
		jsr l2AC5
		bne l2775
		lda $1f24
		sta $14
		lda $1f25
		sta $15
		lda $1f26
		sta $16
		lda $1f27
		sta $17
		jsr l1DCD
		bcs l2804
		lda $2c44
		pha 
		lda $2c43
		pha 
		lda $2c48
		pha 
		lda $2c47
		pha 
		lda $2c44
		pha 
		lda $2c43
		pha 
		lda $2c45
		sta $2c43
		lda $2c46
		sta $2c44
		pla 
		sta $2c45
		pla 
		sta $2c46
		lda $2c48
		pha 
		lda $2c47
		pha 
		lda $2c49
		sta $2c47
		lda $2c4a
		sta $2c48
		pla 
		sta $2c49
		pla 
		sta $2c4a
		lda #$ff
		sta $2c4e
		jsr l2920
		pla 
		sta $2c47
		pla 
		sta $2c48
		pla 
		sta $2c43
		pla 
		sta $2c44

l2804:
		lda $2c4d
		bne l283E
		lda ($08), y
		cmp #$80
		bne l2812
		jsr l2862

l2812:
		jsr l2AC5
		beq l281A
		jmp l28C6

l281A:
		lda $1f24
		sta $1f20
		lda $1f25
		sta $1f21
		lda $1f26
		sta $1f22
		lda $1f27
		sta $1f23
		sty $2c4b
		jsr l1DFF
		ldy $2c4b
		jmp l2804

l283E:
		ldy $2c4c
		jsr l1BB4

l2844:
		ldx $127c
		dex 
		cpx #$02
		bcc l2861
		lda $107c, x
		tay 
		dex 
		lda $107c, x
		stx $127c
		tax 
		lda $2c4f
		jsr l18AB
		jmp l2844

l2861:
		rts 

l2862:
		sty $2c4c
		ldy #$06
		sty $2c4d
		rts 

l286B:
		sty $2c4b

l286E:
		lda ($08), y
		iny 
		iny 
		cmp #$80
		bne l286E
		tya 
		sec 
		sbc #$04
		tay 
		lda ($08), y
		bmi l288E
		clc 
		adc $23
		sta $2c43
		lda #$00
		adc $24
		sta $2c44
		bcc l289B

l288E:
		clc 
		adc $23
		sta $2c43
		lda $24
		sbc #$00
		sta $2c44

l289B:
		iny 
		lda ($08), y
		bmi l28AF
		clc 
		adc $25
		sta $2c47
		lda #$00
		adc $26
		sta $2c48
		bcc l28BC

l28AF:
		clc 
		adc $25
		sta $2c47
		lda $26
		sbc #$00
		sta $2c48

l28BC:
		ldy $2c4b
		rts 

l28C0:
		lda #$c8
		sta $67
		rts 
*=$28c6

l28C6:
		jsr l1DCD
		bcc l28CE
		jmp l2775

l28CE:
		lda $2c44
		pha 
		lda $2c43
		pha 
		lda #$00
		sta $2c4e
		jsr l2920
		pla 
		sta $2c43
		pla 
		sta $2c44
		jmp l2775

l28E9:
		lda $2c43
		sta $10
		lda $2c44
		sta $11
		lda $2c47
		sta $12
		lda $2c48
		sta $13
		lda #$ff
		sta $0c07
		jsr l0BA4
		lda #$00
		sta $0c07
		lda $2c5e
		bne l2914
		lda $2c5d
		bne l291C

l2914:
		lda #$ff
		sta $2c4e
		jsr l2920

l291C:
		ldy $2c4b
		rts 

l2920:
		lda $2c43
		clc 
		adc $2c45
		sta $2c3f
		lda $2c44
		adc $2c46
		ror 
		sta $2c40
		ror $2c3f
		lda $2c47
		clc 
		adc $2c49
		sta $2c41
		lda $2c48
		adc $2c4a
		ror 
		sta $2c42
		ror $2c41
		lda $2c3f
		sta $10
		lda $2c40
		sta $11
		lda $2c41
		sta $12
		lda $2c42
		sta $13
		lda #$ff
		sta $0c07
		jsr l0BA4
		lda #$00
		sta $0c07
		lda $2c5e
		beq l2977
		jmp l2A06

l2977:
		lda $2c5d
		bne l297F
		jmp l2A06

l297F:
		jsr l0B06
		lda #$30
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $1f24
		sta $1f24
		lda $1f25
		sbc #$00
		sta $1f25
		lda $2c5f
		sec 
		sbc $1f26
		sta $1f26
		lda #$00
		sbc $1f27
		sta $1f27
		lda $1f24
		sta $1f20
		lda $1f25
		sta $1f21
		lda $1f26
		sta $1f22
		lda $1f27
		sta $1f23
		jsr l1DE4
		bcs l29CA
		jmp l2A44

l29CA:
		lda $2c4e
		beq l29FF
		lda $15
		pha 
		lda $14
		pha 
		lda $1f20
		sta $14
		lda $1f21
		sta $15
		pla 
		sta $1f20
		pla 
		sta $1f21
		lda $17
		pha 
		lda $16
		pha 
		lda $1f22
		sta $16
		lda $1f23
		sta $17
		pla 
		sta $1f22
		pla 
		sta $1f23

l29FF:
		jsr l1DFF
		ldy $2c4b
		rts 

l2A06:
		lda $2c3f
		cmp $2c43
		bne l2A14
		lda $2c40
		cmp $2c44

l2A14:
		bne l2A29
		lda $2c41
		cmp $2c47
		bne l2A24
		lda $2c42
		cmp $2c48

l2A24:
		bne l2A29
		jmp l2A7C

l2A29:
		lda $2c3f
		sta $2c43
		lda $2c40
		sta $2c44
		lda $2c41
		sta $2c47
		lda $2c42
		sta $2c48
		jmp l2920

l2A44:
		lda $2c3f
		cmp $2c45
		bne l2A52
		lda $2c40
		cmp $2c46

l2A52:
		bne l2AAA
		lda $2c41
		cmp $2c49
		bne l2A62
		lda $2c42
		cmp $2c4a

l2A62:
		bne l2AAA
		lda $2c3f
		sta $1f20
		lda $2c40
		sta $1f21
		lda $2c41
		sta $1f22
		lda $2c42
		sta $1f23

l2A7C:
		lda $2c3f
		sta $10
		lda $2c40
		sta $11
		lda $2c41
		sta $12
		lda $2c42
		sta $13
		lda #$ff
		sta $0c07
		jsr l0BA4
		lda #$00
		sta $0c07
		lda #$01
		sta $2c5d
		lda #$00
		sta $2c5e
		jmp l297F

l2AAA:
		lda $2c41
		sta $2c49
		lda $2c42
		sta $2c4a
		lda $2c3f
		sta $2c45
		lda $2c40
		sta $2c46
		jmp l2920

l2AC5:
		lda ($08), y
		bmi l2AD6
		clc 
		adc $23
		sta $10
		lda #$00
		adc $24
		sta $11
		bcc l2AE1

l2AD6:
		clc 
		adc $23
		sta $10
		lda $24
		sbc #$00
		sta $11

l2AE1:
		iny 
		lda ($08), y
		bmi l2AF3
		clc 
		adc $25
		sta $12
		lda #$00
		adc $26
		sta $13
		bcc l2AFE

l2AF3:
		clc 
		adc $25
		sta $12
		lda $26
		sbc #$00
		sta $13

l2AFE:
		lda $2c43
		sta $2c45
		lda $2c44
		sta $2c46
		lda $2c47
		sta $2c49
		lda $2c48
		sta $2c4a
		lda $10
		sta $2c43
		lda $11
		sta $2c44
		lda $12
		sta $2c47
		lda $13
		sta $2c48
		iny 
		sty $2c4b
		lda #$ff
		sta $0c07
		jsr l0BA4
		lda #$00
		sta $0c07
		lda $2c5e
		bmi l2B81
		beq l2B4B
		ldy #$00
		sty $2c5e
		dey 
		sty $2c5d

l2B4B:
		lda $2c5d
		bne l2B54
		lda #$ff
		bne l2B81

l2B54:
		jsr l0B06
		lda #$30
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $1f24
		sta $1f24
		lda $1f25
		sbc #$00
		sta $1f25
		lda $2c5f
		sec 
		sbc $1f26
		sta $1f26
		lda #$00
		sbc $1f27
		sta $1f27
		lda #$00

l2B81:
		php 
		ldy $2c4b
		plp 
		rts 

l2B87:
		iny 
		lda ($08), y
		cmp #$80
		beq l2BC2
		tya 
		clc 
		adc $08
		sta $08
		lda $09
		adc #$00
		sta $09
		ldx $2c3e
		lda $08
		sta $2c1a, x
		lda $09
		sta $2c1b, x
		lda $23
		sta $2c26, x
		lda $24
		sta $2c27, x
		lda $25
		sta $2c32, x
		lda $26
		sta $2c33, x
		inx 
		inx 
		stx $2c3e
		ldy #$00

l2BC2:
		lda ($08), y
		iny 
		cmp #$80
		bne l2BC2
		bne l2BC2
		lda #$16
		sta $2bfc

l2BD0:
		lda ($08), y
		iny 
		cmp #$80
		beq l2BE2
		clc 
		adc $2bfc
		tax 
		inc $2bfc, x
		jmp l2BD0

l2BE2:
		lda $2bfc
		beq l2BFB
		cmp #$16
		beq l2BF3
		lda #$00
		sta $2bfc
		jmp l2BD0

l2BF3:
		lda #$12
		sta $2bfc
		jmp l2BD0

l2BFB:
		rts 
*=$2c60

l2C60:
		ldy #$00
		lda ($02), y
		cmp #$ff
		bne l2C69
		rts 

l2C69:
		jsr l0FFB
		inc $02
		bne l2C72
		inc $03

l2C72:
		jmp l2C60

l2C75:
		pla 
		sta $02
		pla 
		sta $03
		inc $02
		bne l2C81
		inc $03

l2C81:
		jsr l2C60
		lda $03
		pha 
		lda $02
		pha 
		rts 
*=$2c93

l2C93:
		jsr l2CBB
		jmp l0FFB
*=$2cbb

l2CBB:
		and #$0f
		cmp #$0a
		bcc l2CC7
		sbc #$0a
		clc 
		adc #$41
		rts 

l2CC7:
		adc #$30
		rts 
*=$2ce5

a2CE5:
		.addr	l398B
a2CE7:		.addr	l30AF
a2CE9:		.addr	l4180
a2CEB:		.addr	l378C
*=$2cef

a2CEF:		.addr	l3209

l2CF1:
		pha 
		lda $483f
		sta $487f
		bne l2D04
		txa 
		sec 
		sbc #$33
		tax 
		lda #$05
		sta $483f

l2D04:
		ldy #$91
		stx $0464
		sty $0466
		lda #$e0
		and $d010
		sta $d010
		lda $044f
		beq l2D1B
		lda #$08

l2D1B:
		jsr l2D21
		jmp l2D3E

l2D21:
		ldx $d012
		cpx #$14
		bcc l2D21
		cpx #$32
		bcs l2D21
		ldy #$ff
		and #$08
		tax 

l2D31:
		lda $2f11, x
		iny 
		sta $d027, y
		inx 
		cpy #$07
		bcc l2D31
		rts 

l2D3E:
		pla 
		sta $046a
		lda #$17
		ldx #$34
		jsr l32DD
		lda #$00
		ldx #$59
		ldy $046a
		dey 
		jsr l3375
		lda $487f
		bne l2D61
		jsr l303C
		lda #$05
		sta $483f

l2D61:
		rts 
*=$2ef7

; where the CPU was when the snapshot was taken
snapshot_pc:
		lda $d012
		cmp #$c8
		bcc snapshot_pc
		dec $045d
		lda $3294
		beq l2F09
		jsr l3EF4

l2F09:
		pla 
		tax 
		lda $c5
		jsr l32B0
		rts 
*=$2f6d

l2F6D:
		ldx #$81
		stx $d40b
		dex 
		stx $d40b
		rts 
*=$303c

l303C:
		ldx #$2f

l303E:
		jsr l305E
		inx 
		cpx #$37
		bcc l303E
		ldx #$4d

l3048:
		jsr l305E
		inx 
		cpx #$57
		bcc l3048
		ldx #$25
		jsr l305E
		lda $483f
		eor #$05
		sta $483f
		rts 

l305E:
		lda #$00
		sta $61
		txa 
		pha 
		lsr 
		ror $61
		lsr 
		ror $61
		ora #$40
		sta $62
		ldy #$3f
		lda ($61), y
		sta $30ae
		ldy #$00

l3077:
		jsr l3096
		pha 
		iny 
		jsr l3096
		sta ($61), y
		iny 
		jsr l3096
		dey 
		dey 
		sta ($61), y
		iny 
		iny 
		pla 
		sta ($61), y
		iny 
		cpy #$3f
		bcc l3077
		pla 
		tax 
		rts 

l3096:
		lda ($61), y
		sta $63
		ldx #$08

l309C:
		lsr $63
		php 
		bit $30ae
		bpl l30A8
		lsr $63
		rol 
		dex 

l30A8:
		plp 
		rol 
		dex 
		bne l309C
		rts 
*=$30af

l30AF:
		lda $483f
		bne l30B7
		jsr l303C

l30B7:
		lda #$fd
		sta $d00f
		lda #$00
		sta $3294
		lda $0404
		bne l30CD
		ldx #$32
		lda #$26
		jsr l2CF1

l30CD:
		lda #$ff
		sta $d015
		jsr l3209
		bne l3113
		jsr l3295
		jsr l2C75
		eor #$4e
		jsr l4854
		eor $20
		sre $41, x
		nop $45, x
*=$30f9

l30F9:
		tax 
		lda $0405, x
		sta @w $001b
		lda $0406, x
		sta @w $001c
		lda $0409, x
		sta @w $001d
		lda $040a, x
		sta @w $001e
		rts 

l3113:
		lda $0404
		bne $314f
		lda @w $001c
		beq l3128
		cmp #$02
		bcs l3138
		lda @w $001b
		cmp #$c0
		bcs l3138

l3128:
		lda @w $001e
		beq $314f
		cmp #$02
		bcs l3138
		lda @w $001d
		cmp #$c0
		bcc $314f

l3138:
		jsr l3295
		jsr l2C75
		sre $5455
		jsr l464F
		jsr l4F42
		eor $4e, x
		nop $53
		isc $ea4c, x
		bmi l30F9
l314F = $314f
		brk 
*=$3209

l3209:
		lda $0404
		bne l321D
		lda #$21
		sta $47fe
		lda #$bb
		sta $d00c
		lda #$ad
		sta $d00d

l321D:
		lda $d015
		ora #$40
		sta $d015
		ldx #$04

l3227:
		lda $74aa, x
		sta $328e, x
		dex 
		bne l3227
		ldx #$a8
		ldy #$15
		lda $74ab, x
		jsr l3253
		sta $327d
		ldy #$00
		lda $3290
		jsr l3253
		beq l324F
		lda $327d
		bne l324F
		jmp l32B6

l324F:
		lda $3598
		rts 

l3253:
		and #$0c
		lsr 
		tax 
		lda $3275, x
		sta $61
		lda $3276, x
		sta $62
		lda ($61), y
		cpx #$02
		bne l326B
		lsr 
		lsr 
		lsr 
		lsr 

l326B:
		and #$0f
		tax 
		lda $327e, x
		sta $3598
		rts 
*=$3295

l3295:
		lda #$00
		sta @w $001f
		lda #$07
		sta @w $0020
		lda @w $001f
		clc 
		adc #$04
		sta @w $001f
		lda #$0d
		jmp l4180
*=$32b0

l32B0:
		jmp (aA012)
*=$32b6

l32B6:
		jmp (aA01A)
*=$32dd

l32DD:
		stx $fe
		sta $fd
		ldy #$00
		lda ($fd), y
		iny 
		sta $336b
		lda ($fd), y
		iny 
		sta $336a
		tya 
		clc 
		adc $fd
		sta $fd
		lda $fe
		adc #$00
		sta $fe
		ldy #$00
		jsr l33C0

l3300:
		lda ($fd), y
		sta $336c, y
		sta $3368
		and #$07
		tax 
		lda $3360, x
		sta $3369
		lda $3369
		asl $3368
		bcs l3323
		eor #$ff
		and $d01c
		sta $d01c
		lda #$00

l3323:
		ora $d01c
		sta $d01c
		lda $3369
		asl $3368
		bcs l333B
		eor #$ff
		and $d017
		sta $d017
		lda #$00

l333B:
		ora $d017
		sta $d017
		lda $3369
*=$3346

l3346:
		rla ($b0), y
		asl 
		eor #$ff
		and $d01d
		sta $d01d
		lda #$00
		ora $d01d
		sta $d01d
		iny 
		cpy $336b
		bcc l3300
		rts 
*=$3375

l3375:
		stx $fe
		sta $fd
		lda $336b
		clc 
		adc $336b
		adc $336b
		adc #$01

l3385:
		cpy #$00
		beq l3399
		dey 
		pha 
		clc 
		adc $fd
		sta $fd
		lda $fe
		adc #$00
		sta $fe
		pla 
		bne l3385

l3399:
		ldx #$00
		lda ($fd), y
		iny 
		cmp #$80
		bne l33A5
		ora #$00
		rts 

l33A5:
		pha 
		lda $483f
		bne l33B2
		pla 
		clc 
		eor #$ff
		adc #$01
		pha 

l33B2:
		pla 
		clc 
		adc $0464
		sta $0464
		jsr l33C0
		jmp l33CC

l33C0:
		lda $d012
		cmp #$1e
		bcc l33C0
		cmp #$32
		bcs l33C0
		rts 

l33CC:
		txa 
		pha 
		lda $336c, x
		and #$07
		asl 
		tax 
		lda ($fd), y
		iny 
		pha 
		lda $483f
		bne l33E5
		pla 
		clc 
		eor #$ff
		adc #$01
		pha 

l33E5:
		pla 
		clc 
		adc $0464
		sta $d000, x
		lda ($fd), y
		iny 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $0466
		sta $d001, x
		txa 
		lsr 
		tax 
		lda ($fd), y
		iny 
		clc 
		adc $336a
		sta d47F8, x
		pla 
		tax 
		inx 
		cpx $336b
		bcs l3414
		jmp l33CC

l3414:
		lda #$00
		rts 
*=$35a1

l35A1:
		bpl l35A8
		clc 
		eor #$ff
		adc #$01

l35A8:
		tax 
		lda #$00
		jsr l0900
		sta $0e
		stx $0f
		jsr l094F
		lda $0e
		ldx $0f
		jmp l091F

l35BC:
		pha 
		jsr l366E
		stx $359d
		sty $359f
		stx $378a
		sty $378b
		pla 
		jsr l35A1
		sta $3785
		stx $3784
		lda #$00
		sta $3788
		sta $3789

l35DE:
		lda $359d
		bmi l35F5
		clc 
		adc $378a
		sta $378a
		lda #$00
		adc $3788
		sta $3788
		jmp l3604

l35F5:
		clc 
		adc $378a
		sta $378a
		lda $3788
		sbc #$00
		sta $3788

l3604:
		lda $359f
		bmi l361B
		clc 
		adc $378b
		sta $378b
		lda #$00
		adc $3789
		sta $3789
		jmp l362A

l361B:
		clc 
		adc $378b
		sta $378b
		lda $3789
		sbc #$00
		sta $3789

l362A:
		lda $3788
		jsr l35A1
		sta $3787
		stx $3786
		lda $3789
		jsr l35A1
		pha 
		txa 
		clc 
		adc $3786
		sta $3786
		pla 
		adc $3787
		sta $3787
		lda $3787
		cmp $3785
		bcs l3657
		jmp l35DE

l3657:
		beq l365C
		jmp l3667

l365C:
		lda $3786
		cmp $3784
		bcs l3667
		jmp l35DE

l3667:
		ldx $3788
		ldy $3789
		rts 

l366E:
		txa 
		jsr l368B
		bcs l3699
		tya 
		jsr l368B
		bcs l3699
		txa 
		asl 
		php 
		asl 
		plp 
		ror 
		tax 
		tya 
		asl 
		php 
		asl 
		plp 
		ror 
		tay 
		jmp l366E

l368B:
		asl 
		bcs l3693
		asl 
		bcs l3698
		bcc l3696

l3693:
		asl 
		bcc l3698

l3696:
		clc 
		rts 

l3698:
		sec 

l3699:
		rts 

l369A:
		lda $3780
		ldx $377e
		ldy $377f
		jsr l35BC
		stx $3782
		sty $3783
		ldx $377f
		lda $377e
		clc 
		eor #$ff
		adc #$01
		tay 
		lda $3781
		bpl l36D2
		clc 
		eor #$ff
		adc #$01
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		tya 
		clc 
		eor #$ff
		adc #$01
		tay 
		pla 

l36D2:
		jsr l35BC
		txa 
		clc 
		adc $3782
		sta $3782
		tya 
		clc 
		adc $3783
		sta $3783
		rts 

l36E6:
		lda $0db8
		tax 
		lda $3b35, x
		sta $377e
		lda $3b3d, x
		sta $377f
		lda #$58
		sta $3780
		lda $0476
		sta $3781
		jsr l369A
		lda $3782
		sta $377e
		lda $3783
		sta $377f
		rts 

l3711:
		lda $3595
		sta $3780
		lda $3596
		sta $3781
		jsr l369A
		lda @w $001b
		sta $10
		lda @w $001c
		sta $11
		lda @w $001d
		sta $12
		lda @w $001e
		sta $13
		lda $3782
		bmi l3747
		clc 
		adc $10
		sta $10
		lda #$00
		adc $11
		sta $11
		jmp l3750

l3747:
		clc 
		adc $10
		sta $10
		bcs l3750
		dec $11

l3750:
		lda $3783
		bmi l3763
		clc 
		adc $12
		sta $12
		lda #$00
		adc $13
		sta $13
		jmp l376C

l3763:
		clc 
		adc $12
		sta $12
		bcs l376C
		dec $13

l376C:
		jsr l0BA4
		lda $2c5b
		sta $3596
		lda $2c5d
		sta $3595
		rts 
*=$378c

l378C:
		lda $044f
		beq l3793
		lda #$08

l3793:
		jsr l2D21
		lda $66
		bne l379D
		jsr l382B

l379D:
		jsr l38B6
		jsr l3AB8
		jsr l3AC4
		lda @w $001c
		pha 
		lda @w $001b
		pha 
		lda @w $001e
		pha 
		lda @w $001d
		pha 
		lda $0400
		sta @w $001b
		lda $0401
		sta @w $001c
		lda $0402
		sta @w $001d
		lda $0403
		sta @w $001e
		jsr l3AC4
		jsr l3AC4
		lda @w $001d
		sta $046e
		lda @w $001e
		sta $046f
		lda @w $001b
		sta $046c
		lda @w $001c
		sta $046d
		pla 
		sta @w $001d
		pla 
		sta @w $001e
		pla 
		sta @w $001b
		pla 
		sta @w $001c
		jmp l3AB8
*=$382b

l382B:
		tax 
		pla 
		pla 
		cpx #$22
		bne l3835
		jmp l3A94

l3835:
		cpx #$25
		bne l383C
		jmp l3AA6

l383C:
		cpx #$01
		bne l3843
		jmp l3B45

l3843:
		rts 
*=$38b6

l38B6:
		lda #$00
		sta $3982
		lda $0402
		sec 
		sbc @w $001d
		sta $0454
		lda $0403
		sbc @w $001e
		sta $0455
		asl 
		php 
		rol $3982
		plp 
		bpl l38E7
		lda #$00
		sec 
		sbc $0454
		sta $0454
		lda #$00
		sbc $0455
		sta $0455

l38E7:
		lda $0400
		sec 
		sbc @w $001b
		sta $0452
		lda $0401
		sbc @w $001c
		sta $0453
		asl 
		php 
		rol $3982
		plp 
		bpl l3913
		lda #$00
		sec 
		sbc $0452
		sta $0452
		lda #$00
		sbc $0453
		sta $0453

l3913:
		jsr l3956
		php 
		rol $3982
		ldx $3982
		lda $3983, x
		sta $3982
		plp 
		bcc l3929
		jsr l3965

l3929:
		asl $0452
		rol $0453
		jsr l3956
		bcc l393E
		lda $3982
		ora #$01
		sta $3982
		bne l3950

l393E:
		lda $3982
		and #$01
		beq l3950
		lda $3982
		clc 
		adc #$01
		and #$07
		sta $3982

l3950:
		lda $3982
		jmp l0D79

l3956:
		lda $0453
		cmp $0455
		bne l3964
		lda $0452
		cmp $0454

l3964:
		rts 

l3965:
		lda $0452
		pha 
		lda $0454
		sta $0452
		pla 
		sta $0454
		lda $0453
		pha 
		lda $0455
		sta $0453
		pla 
		sta $0455
		rts 
*=$398b

l398B:
		sta $0451
		asl 
		asl 
		adc $0451
		adc $0451
		sec 
		sbc #$06
		sta $3a93
		lda #$30
		sta $1f
		lda #$1f
		sta $20
		lda #$02
		jsr l4180
		ldy #$02
		jsr l3A73
		lda #$28
		sta $1f
		lda #$17
		sta $20
		lda #$03
		jsr l4180
		ldy #$03
		jsr l3A73
		lda #$38
		sta $1f
		lda #$0f
		sta $20
		lda #$01
		jsr l4180
		ldy #$01
		jsr l3A73
		sec 
		sbc #$30
		sta $0450
		ldx #$ff
		stx $66
		inx 
		stx $0404
		lda $0451
		cmp #$13
		bne l39EA
		jmp l3A4A

l39EA:
		asl 
		asl 
		tax 
		lda $942b, x
		sta $0400
		lda $942c, x
		sta $0401
		lda $942d, x
		sta $0402
		lda $942e, x
		sta $0403
		lda $0451
		asl 
		tax 
		lda $93f3, x
		sta $61
		lda $93f4, x
		sta $62
		ldy #$00
		sty @w $001b
		sty @w $001d
		lda ($61), y
		lsr 
		ror @w $001b
		lsr 
		ror @w $001b
		sta @w $001c
		iny 
		lda ($61), y
		lsr 
		ror @w $001d
		lsr 
		ror @w $001d
		sta @w $001e
		iny 
		lda ($61), y
		ora @w $001b
		sta @w $001b
		iny 
		lda ($61), y
		ora @w $001d
		sta @w $001d
		rts 

l3A4A:
		lda #$1a
		sta @w $001b
		lda #$00
		sta @w $001c
		lda #$b0
		sta @w $001d
		lda #$00
		sta @w $001e
		lda #$12
		sta $0400
		lda #$00
		sta $0401
		lda #$b8
		sta $0402
		lda #$00
		sta $0403
		rts 

l3A73:
		ldx $3a93

l3A76:
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda $a02b, x
		jsr l0FFB
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		lda $a02b, x
		inx 
		dey 
		bne l3A76
		stx $3a93
		rts 
*=$3a94

l3A94:
		jsr l3AC4
		jsr l0DB9
		jsr l0DB9
		jsr l0DB9
		jsr l3AC4
		jmp l3AB8

l3AA6:
		jsr l3AC4
		jsr l0D73
		jsr l0D73
		jsr l0D73
		jsr l3AC4
		jmp l3AB8

l3AB8:
		jsr l0DB9
		jsr l0DB9
		jsr l0DB9
		jmp l0DB9

l3AC4:
		jsr l3AC7

l3AC7:
		ldy $0db8
		lda $3b35, y
		bmi l3AE4
		lsr 
		lsr 
		lsr 
		clc 
		adc @w $001b
		sta @w $001b
		lda @w $001c
		adc #$00
		sta @w $001c
		jmp l3B00

l3AE4:
		clc 
		eor #$ff
		adc #$01
		lsr 
		lsr 
		lsr 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc @w $001b
		sta @w $001b
		lda @w $001c
		sbc #$00
		sta @w $001c

l3B00:
		lda $3b3d, y
		bmi l3B18
		lsr 
		lsr 
		lsr 
		clc 
		adc @w $001d
		sta @w $001d
		lda @w $001e
		adc #$00
		sta @w $001e
		rts 

l3B18:
		clc 
		eor #$ff
		adc #$01
		lsr 
		lsr 
		lsr 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc @w $001d
		sta @w $001d
		lda @w $001e
		sbc #$00
		sta @w $001e
		rts 
*=$3b45

l3B45:
		rts 
*=$3b87

l3B87:
		lda #$00
		sta $417e
		lda $417f
		cmp #$fd
		bcs l3B99
		jsr l3BEE
		jmp l3B9C

l3B99:
		jsr l3E04

l3B9C:
		jsr l3C3F
		lda $d01d
		and #$40
		bne l3BC0
		lda #$0c
		clc 
		adc $1f24
		sta $1f24
		lda $1f25
		adc #$00
		sta $1f25
		lda $1f26
		clc 
		adc #$0a
		sta $1f26

l3BC0:
		lda $1f24
		sta $d00c
		sta $d00e
		lda $1f25
		beq l3BD8
		lda $d010
		ora #$c0
		sta $d010
		bne l3BE0

l3BD8:
		lda $d010
		and #$3f
		sta $d010

l3BE0:
		lda $1f26
		sta $d00d
		clc 
		adc $3cf8
		sta $d00f
		rts 

l3BEE:
		lda $4205
		clc 
		adc $4209
		sta $4209
		lda $4206
		adc $420a
		sta $420a
		bcc l3C0E
		lda $4206
		bmi l3C16
		inc $420b
		jmp l3C16

l3C0E:
		lda $4206
		bpl l3C16
		dec $420b

l3C16:
		lda $4207
		clc 
		adc $420c
		sta $420c
		lda $4208
		adc $420d
		sta $420d
		lda $420a
		sta $1f24
		lda $420b
		sta $1f25
		lda $420d
		sta $1f26
		rts 
*=$3c3f

l3C3F:
		lda $0404
		beq l3C8E
		lda $1f26
		pha 
		lda $1f25
		pha 
		lda $1f24
		pha 
		lda #$e6
		sec 
		sbc $1f26
		cmp #$30
		bcc l3C86
		tax 
		lda #$0c
		lda $1f25
		lsr 
		php 
		lda $1f24
		plp 
		ror 
		jsr l1306
		beq l3C6F
		jmp l3D54

l3C6F:
		lda $d015
		ora #$40

l3C74:
		and #$7f
		sta $d015
		pla 
		sta $1f24
		pla 
		sta $1f25
		pla 
		sta $1f26
		rts 

l3C86:
		lda $d015
		and #$bf
		jmp l3C74

l3C8E:
		lda $1f26
		pha 
		sta $1f26
		lda $1f25
		pha 
		lda $1f24
		pha 
		lda $3c3c
		sta $3c3d
		lda $1f26
		sec 
		sbc #$e5
		clc 
		eor #$ff
		adc #$01
		sta $3cf8
		jsr l3CB7
		jmp l3CFA

l3CB7:
		and #$fe
		cmp #$31
		bcc l3CC1
		cmp #$c0
		bcc l3CC7

l3CC1:
		ldy #$ff
		lda #$00
		beq l3CF7

l3CC7:
		tay 
		lda $17e3, y
		sta $3cf5
		lda $17e4, y
		clc 
		adc #$87
		sta $3cf6
		lda $1f24
		lsr $1f25
		ror 
		ldx $0404
		beq l3CF1
		cmp #$9f
		bcs l3CEB
		cmp #$65
		bcs l3CF1

l3CEB:
		lda #$00
		ldy #$ff
		beq l3CF7

l3CF1:
		lsr 
		lsr 
		tax 
		lda $ffff, x

l3CF7:
		rts 
*=$3cfa

l3CFA:
		sta $3c3c
		tya 
		ldx $0404
		bne l3D17
		jsr l3D9F
		lda $2c5f
		sec 
		sbc $1f26
		ldx $417f
		cpx #$40
		bcs l3D17
		sec 
		sbc #$10

l3D17:
		sta $1f26
		pla 
		sta $1f24
		pla 
		sta $1f25
		lda $1f25
		pha 
		lda $1f24
		pha 
		lda $1f26
		jsr l3CB7
		sta $3cf9
		lda $3c3c
		cmp $1f26
		bcc l3D45
		lda $d015
		ora #$40
		sta $d015
		bne l3D61

l3D45:
		lda $d015
		and #$40
		beq l3D59
		lda $3c3d
		cmp $3c3c
		bne l3D59

l3D54:
		lda #$ff
		sta $3c3e

l3D59:
		lda $d015
		and #$bf
		sta $d015

l3D61:
		lda $3cf9
		cmp $1f26
		bcc l3D8A
		lda $3597
		cmp #$0c
		bcs l3D8A
		lda $d015
		ora #$80
		sta $d015
		lda $3cf8
		sec 
		sbc $1f26
		bcc l3D8A
		sta $3cf8
		cmp #$03
		bcs l3D92
		bcc l3D92

l3D8A:
		lda $d015
		and #$7f
		sta $d015

l3D92:
		pla 
		sta $1f24
		pla 
		sta $1f25
		pla 
		sta $1f26
		rts 

l3D9F:
		lda $359e
		sta $2c5b
		bmi l3DAB
		lda #$00
		beq l3DAD

l3DAB:
		lda #$ff

l3DAD:
		sta $2c5c
		lda $35a0
		sta $2c5d
		lda #$00
		sta $2c5e
		lda $0404
		bne l3DC3
		jmp l0B06

l3DC3:
		lda $2c5b
		jsr l4354
		sta $2c5b
		lda $2c5d
		sec 
		sbc #$02
		jsr l4354
		sta $2c5d
		lda $0471
		clc 
		adc $2c5d
		sta $1f26
		lda #$00
		sta $1f27
		sta $1f25
		lda $0470
		clc 
		adc $2c5b
		asl 
		rol $1f25
		sta $1f24
		lda #$e6
		sec 
		sbc $1f26
		sta $1f26
		pla 
		pla 
		rts 

l3E04:
		jsr l3D9F
		lda $1f24
		sec 
		sbc #$30
		asl 
		sta $1f24
		lda #$00
		rol 
		sta $1f25
		lda $1f26
		and #$fe
		cmp #$10
		bcs l3E30
		tax 
		lda $1fc7, x
		sta $0ba0
		lda $1fc8, x
		sta $0ba1
		jmp l3E42

l3E30:
		lsr 
		lsr 
		lsr 
		and #$fe
		tax 
		lda $1fe7, x
		sta $0ba0
		lda $1fe8, x
		sta $0ba1

l3E42:
		lda #$e5
		sec 
		sbc $2c5f
		clc 
		adc $1f26
		sta $1f26
		lda $417e
		ldy #$ff
		sty $1f15
		jsr l1D90
		jsr l0900
		sta $0e
		stx $0f
		lda #$00
		ldx $3595
		jsr l0900
		jsr l094F
		lda #$00
		ldx #$40
		jsr l0900
		jsr l094C
		lda $0e
		ldx $0f
		jsr l091F
		txa 
		asl 
		asl 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $1f26
		sta $1f26
		rts 
*=$3ef4

l3EF4:
		lda $417f
		and #$10
		bne l3F01
		jsr l423D
		lda $417f

l3F01:
		cmp #$80
		bne l3F11
		lda $3597
		cmp #$0b
		bcs l3F11
		lda #$20
		sta $47fe

l3F11:
		lda $417f
		and #$01
		bne l3F1B
		jsr l3B87

l3F1B:
		lda $3595
		clc 
		adc $359f
		sta $359f
		lda $35a0
		adc #$00
		sta $35a0
		lda $3596
		bmi l3F44
		clc 
		adc $359d
		sta $359d
		lda #$00
		adc $359e
		sta $359e
		jmp l3F50

l3F44:
		clc 
		adc $359d
		sta $359d
		bcs l3F50
		dec $359e

l3F50:
		lda $417f
		tax 
		lda $3c3e
		bne l3F76
		inx 
		stx $417f
		stx $3294
		beq l3FA4
		txa 
		and #$01
		beq l3F6A
		jmp l3EF4

l3F6A:
		lda $4205
		ora $4207
		bne l3F75
		jmp l3EF4

l3F75:
		rts 

l3F76:
		ldx #$00
		stx $417e
		stx $3294
		dex 
		stx $417f
		lda $0404
		bne l3F8D
		jsr l2F6D
		jsr l3B87

l3F8D:
		lda #$00
		sta $0476
		jsr l36E6
		lda $35a0
		sta $3595
		lda $359e
		sta $3596
		jsr l3711

l3FA4:
		jsr l3AC4
		lda $044f
		and #$01
		asl 
		tax 
		lda @w $001b
		sta $0405, x
		lda @w $001c
		sta $0406, x
		lda @w $001d
		sta $0409, x
		lda @w $001e
		sta $040a, x
		lda $3782
		bmi l3FDD
		clc 
		adc @w $001b
		sta @w $001b
		lda #$00
		adc @w $001c
		sta @w $001c
		jmp l3FE9

l3FDD:
		clc 
		adc @w $001b
		sta @w $001b
		bcs l3FE9
		dec @w $001c

l3FE9:
		lda $3783
		bmi l4000
		clc 
		adc @w $001d
		sta @w $001d
		lda #$00
		adc @w $001e
		sta @w $001e
		jmp l400C

l4000:
		clc 
		adc @w $001d
		sta @w $001d
		bcs l400C
		dec @w $001e

l400C:
		lda @w $001b
		sec 
		sbc $0400
		sta $0452
		lda @w $001c
		sbc $0401
		sta $0453
		lda @w $001d
		sec 
		sbc $0402
		sta $0454
		lda @w $001e
		sbc $0403
		sta $0455
		lda $66
		cmp #$40
		bcc l404E
		ldx #$04

l403A:
		asl $0452
		rol $0453
		dex 
		bne l403A
		ldx #$04

l4045:
		asl $0454
		rol $0455
		dex 
		bne l4045

l404E:
		lda $0400
		sta @w $001b
		lda $0401
		sta @w $001c
		lda $0402
		sta @w $001d
		lda $0403
		sta @w $001e
		lda $0452
		clc 
		adc @w $001b
		sta @w $001b
		lda $0453
		adc @w $001c
		sta @w $001c
		lda $0454
		clc 
		adc @w $001d
		sta @w $001d
		lda $0455
		adc @w $001e
		sta @w $001e
		lda #$00
		sta $66
		lda $0453
		php 
		bpl l4098
		eor #$ff

l4098:
		cmp #$00
		beq l40A1
		plp 
		lda #$ff
		bne l40AC

l40A1:
		lda $0452
		plp 
		bpl l40AC
		clc 
		eor #$ff
		adc #$01

l40AC:
		pha 
		ora $66
		sta $66
		pla 
		cmp #$40
		bcs l40E0
		lda $0455
		php 
		bpl l40BE
		eor #$ff

l40BE:
		cmp #$00
		beq l40C7
		plp 
		lda #$ff
		bne l40D2

l40C7:
		lda $0454
		plp 
		bpl l40D2
		clc 
		eor #$ff
		adc #$01

l40D2:
		pha 
		ora $66
		sta $66
		pla 
		cmp #$40
		bcs l40E0
		lda #$00
		beq l40E2

l40E0:
		lda #$01

l40E2:
		sta $0456
		asl $0453
		php 
		ror $0453
		ldx #$04

l40EE:
		plp 
		php 
		ror $0453
		ror $0452
		dex 
		bne l40EE
		plp 
		asl $0455
		php 
		ror $0455
		ldx #$04

l4103:
		plp 
		php 
		ror $0455
		ror $0454
		dex 
		bne l4103
		plp 
		lda $0400
		sta $046c
		lda $0401
		sta $046d
		lda $0402
		sta $046e
		lda $0403
		sta $046f
		lda $0452
		clc 
		adc $046c
		sta $046c
		lda $0453
		adc $046d
		sta $046d
		lda $0454
		clc 
		adc $046e
		sta $046e
		lda $0455
		adc $046f
		sta $046f
		lda $0456
		beq l416A
		lda $046c
		sta @w $001b
		lda $046d
		sta @w $001c
		lda $046e
		sta @w $001d
		lda $046f
		sta @w $001e

l416A:
		lda $0404
		beq l417C
		lda $3c3e
		beq l417C
		lda $66
		and #$f0
		bne l417C
		sta $66

l417C:
		rts 
*=$4180

l4180:
		pha 
		lda $20
		pha 
		lda $1f
		pha 
		lda #$20
		jsr l0FFB
		pla 
		sta $1f
		pla 
		sta $20
		lda #$09
		clc 
		eor #$ff
		adc #$01
		clc 
		adc $0a
		sta $0a
		lda $0b
		sbc #$00
		sta $0b
		pla 
		asl 
		tay 
		lda $05
		pha 
		lda $04
		pha 
		tya 
		asl 
		asl 
		asl 
		pha 
		lda $0a
		sec 
		sbc #$00
		sta $04
		lda $0b
		sbc #$60
		sta $05
		inc $04
		bne l41C5
		inc $05

l41C5:
		ldx #$03

l41C7:
		lsr $05
		ror $04
		dex 
		bne l41C7
		lda $04
		clc 
		adc #$00
		sta $04
		lda $05
		adc #$d8
		sta $05
		lda $04
		bne l41E1
		dec $05

l41E1:
		dec $04
		lda $0478

l41E6:
		sta ($04), y
		dey 
		bne l41E6
		pla 
		tay 
		lda ($0a), y

l41EF:
		sta ($0a), y
		dey 
		bne l41EF
		lda #$ff
		sta $1368
		pla 
		sta $04
		pla 
		sta $05
		rts 
*=$4210

l4210:
		lda #$00
		jsr l0900
		sta $0e
		stx $0f
		lda #$00
		ldx $3597
		inx 
		cpx #$0d
		bcc l4225
		ldx #$00

l4225:
		jsr l0900
		jsr l094F
		lda #$00
		ldx #$10
		jsr l0900
		jsr l094C
		lda $0e
		ldx $0f
		jsr l091F
		rts 

l423D:
		lda $359e
		pha 
		lda $359d
		pha 
		lda $35a0
		pha 
		lda $359f
		pha 
		lda $417f
		bne l428D
		lda #$00
		sta $4342
		lda $3595
		asl 
		rol $4342
		asl 
		rol $4342
		asl 
		rol $4342
		asl 
		rol $4342
		sta $4341
		lda #$00
		sta $4344
		lda $3596
		bpl l427A
		dec $4344

l427A:
		asl 
		rol $4344
		asl 
		rol $4344
		asl 
		rol $4344
		asl 
		rol $4344
		sta $4343

l428D:
		lda $4341
		clc 
		adc $359f
		sta $359f
		lda $4342
		adc $35a0
		sta $35a0
		lda $4343
		clc 
		adc $359d
		sta $359d
		lda $4344
		adc $359e
		sta $359e
		lda $417f
		clc 
		adc #$10
		bpl l42C0
		clc 
		eor #$ff
		adc #$01

l42C0:
		tax 
		jsr l4210
		stx $417e
		jsr l3E04
		lda $1f25
		sec 
		sbc $420b
		lda $1f24
		sbc $420a
		sta $4205
		lda $1f26
		sec 
		sbc $420d
		bmi l42ED
		ldx $417f
		bmi l42ED
		lda #$00
		sta $4205

l42ED:
		sta $4207
		lda #$00
		sta $4208
		lda $4207
		bpl l42FD
		dec $4208

l42FD:
		asl 
		rol $4208
		asl 
		rol $4208
		asl 
		rol $4208
		asl 
		rol $4208
		sta $4207
		lda #$00
		sta $4206
		lda $4205
		bpl l431D
		dec $4206

l431D:
		asl 
		rol $4206
		asl 
		rol $4206
		asl 
		rol $4206
		asl 
		rol $4206
		sta $4205
		pla 
		sta $359f
		pla 
		sta $35a0
		pla 
		sta $359d
		pla 
		sta $359e
		rts 
*=$4354

l4354:
		jmp (aA029)
*=$464f

l464F:
		ora $0d0d
		ora $0d0d
		ora $0d0d
		slo $0d0f
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $0d0d
		ora $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $ccbb, y
		cpy $cccc
		cpy $cccc
		cpy $cccc
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $bbbb
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $cccc, y
		cpy $cccc
		cpy $cccc
		cpy $bbcc
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		cpy $cccc
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $bbbb, y
		las $eaea, y
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 
		nop 

d47F8:
		rol $2e
		rol $2e4b
d47FB = $47fb
		and $ea21
		brk 
*=$4854

l4854:
		brk 
*=$4f42

l4F42:
		brk 
*=$4f48

l4F48:
		brk 
*=$5645

l5645:
		brk 
*=$5928

l5928:
		bit @w $0034
		brk 
*=$a012

aA012:
		.addr	lB41D
*=$a01a

aA01A:		.addr	lB5FC
*=$a020

lA020:
		jmp lB79F

lA023:
		jmp lB7D2

lA026:
		jmp lB805

aA029:
		.addr	lAE18
*=$a09d

lA09D:
		jsr lA5AF
		lda #$ff
		sta $044e
		tax 
		txs 
		lda #$01
		sta $0478
		lda #$00
		sta $1f
		lda #$c7
		sta $20
		lda #$30
		sta $29
		lda #$c8
		sta $67
		lda #$0f
		sta $d020
		lda $dd02
		ora #$03
		sta $dd02
		lda $dd00
		and #$fc
		ora #$02
		sta $dd00
		lda #$02
		sta $d025
		lda #$0f
		sta $d026
		jsr lB5BC
		jsr lA927
		jsr lB5C3
		lda #$20
		sta $abf4
		lda #$90
		sta $2c5f
		jsr l0B95
		jsr lB061
		jsr lA6AA
		lda $d026
		jsr lA688

lA0FF:
		lda #$00
		sta $af2e
		sta $d015
		jsr lA2E9
		jsr l1034
		lda #$13
		jsr lA95B
		jsr lB00D
		jsr lA964
		jsr lA688
		jsr lB5B0
		jsr lB24D
		jsr lA6AA
		jsr lA2E9
		ldx #$0a
		lda #$00

lA12B:
		sta $ad47, x
		dex 
		bne lA12B
		lda #$00
		sta $0450
		jsr lAC2B
		jsr lB061
		lda #$0c
		sta $1b
		lda #$00
		sta $1c
		lda #$30
		sta $1d
		lda #$01
		sta $1e

lA14C:
		lda $0451
		jsr lA95B
		jsr lB00D
		lda #$ff
		sta $0452
		lda #$7f
		sta $0453
		lda #$00
		sta $044f
		jsr lAF65
		lda #$01
		sta $044f
		jsr lAF65
		jsr lAE92
		jsr lAF2F

lA175:
		jmp lA212

lA178:
		lda #$ff
		sta $1368
		lda #$00
		sta $1f
		lda #$2f
		sta $20
		lda $1f
		clc 
		adc #$04
		sta $1f
		jsr l2C75
		bvc lA1DD
		eor ($59, x)
		eor $52
		isc $1fa5, x
		clc 
		adc #$04
		sta $1f
		jsr l2C75
		and ($ff), y
		jsr l2C75
		ora dA5FF
		slo $6918, x
		nop $85
		slo $7520, x
		bit $4c50
		eor ($59, x)
		eor $52
		isc $1fa5, x
		clc 
		adc #$04
		sta $1f
		jsr l2C75
*=$a1dd

lA1DD:
		slo $6918, x
		nop $85
		slo $7520, x
		bit $4c43
		eor $42, x
		isc $7520, x
		bit $ff0d
		lda $1f
		clc 
		adc #$04
		sta $1f
		jsr l2C75
		eor $5344, y
		isc $7520, x
		bit $ff0d
		lda $1f
		clc 
		adc #$04
		sta $1f
		jsr l2C75
		bvc lA250
*=$a212

lA212:
		jsr lA178
		jsr lA688
		jsr lAE92
		jsr lAF2F
		jsr lA964
		jsr lB075
		lda $66
		pha 
		lda #$00
		sta $0404
		lda #$00
		sta $0470
		sta $0471
		pla 
		cmp #$40
		bcs lA299
		lda $1c
		pha 
		lda $1b
		pha 
		lda $1e
		pha 
		lda $1d
		pha 
		lda $046c
		sta $1b
		lda $046d
		sta $1c
*=$a250

lA250:
		ror $8504
		ora $6fad, x
		nop $85
		asl $bc20, x
		lda $ad, x
		bit $e0
		sta $e01e
		lda $e025
		sta $e01f
		jsr lB5B0
		jsr lB5BC
		lda $e024
		sta $e01e
		lda $e025
		sta $e01f
		jsr lB5C3
		pla 
		sta $1d
		pla 
		sta $1e
		pla 
		sta $1b
		pla 
		sta $1c
		jsr lAD54
		lda #$01
		sta $0404
		ldx #$04
		jsr lB458
		jmp lA2A1

lA299:
		jsr lB5B0
		ldx #$00
		jsr lB458

lA2A1:
		jsr lA95E
		lda $d026
		jsr lAF65
		jsr lA2E9
		lda $0443
		pha 
		lda $044e
		and #$01
		tax 
		pla 
		cpx #$00
		beq lA2BF
		ora $044d

lA2BF:
		ora #$00
		beq lA2C6
		jmp lA175

lA2C6:
		jsr lAC2B
		lda #$00
		sta $d015
		ldx $0451
		inx 
		cpx #$13
		bne lA2D9
		jmp lA0FF

lA2D9:
		stx $0451
		lda $044e
		and #$02
		bne lA2E6
		jmp lA14C

lA2E6:
		jmp lA0FF

lA2E9:
		lda #$00
		sta $06
		lda #$60
		sta $07
		lda #$40
		sta $08
		lda #$e8
		sta $09
		ldy #$00

lA2FB:
		lda #$00
		sta ($06), y
		iny 
		bne lA304
		inc $07

lA304:
		inc $08
		bne lA2FB
		inc $09
		bne lA2FB
		lda #$00
		sta $06
		lda #$44
		sta $07
		lda #$08
		sta $08
		lda #$fd
		sta $09
		ldy #$00

lA31E:
		lda #$0f
		sta ($06), y
		iny 
		bne lA327
		inc $07

lA327:
		inc $08
		bne lA31E
		inc $09
		bne lA31E
		lda #$00
		sta $06
		lda #$d8
		sta $07
		lda #$08
		sta $08
		lda #$fd
		sta $09
		ldy #$00

lA341:
		lda #$00
		sta ($06), y
		iny 
		bne lA34A
		inc $07

lA34A:
		inc $08
		bne lA341
		inc $09
		bne lA341
		lda #$00
		sta $06
		lda #$cb
		sta $07
		lda #$08
		sta $08
		lda #$fd
		sta $09
		ldy #$00

lA364:
		lda #$ff
		sta ($06), y
		iny 
		bne lA36D
		inc $07

lA36D:
		inc $08
		bne lA364
		inc $09
		bne lA364
		jsr lA901
		rts 

lA379:
		lda #$01
		sta $d021
		lda $a42c
		beq lA3F7
		ldx #$08
		lda $a533, x
		sta $47fb
		inx 
		lda $a533, x
		sta $d006
		inx 
		lda $a533, x
		sta $d007
		inx 
		lda $a533, x
		sta $d01c
		inx 
		lda $a533, x
		sta $d017
		inx 
		lda $a533, x
		sta $d02a
		inx 
		lda $a533, x
		sta $d025
		inx 
		lda $a533, x
		sta $d026
		inx 
		ldx #$00
		lda $a533, x
		sta d47F8
		inx 
		lda $a533, x
		sta $d000
		inx 
		lda $a533, x
		sta $d001
		inx 
		lda $a533, x
		sta $d01c
		inx 
		lda $a533, x
		sta $d017
		inx 
		lda $a533, x
		sta $d027
		inx 
		lda $a533, x
		sta $d025
		inx 
		lda $a533, x
		sta $d026
		inx 

lA3F7:
		lda #$00
		sta $d02d
		lda #$5f
		sta $d012
		jmp lA57B

lA404:
		ldy #$05
		lda $d012
		lda #$69

lA40B:
		cmp $d012
		bcs lA40B
		sty $d021
		lda #$01
		sta $d02d
		lda #$82
		ldx #$00
		stx $a42c
		ldx $0477
		bne lA426
		lda #$cb

lA426:
		sta $d012
		jmp lA57B
*=$a42d

lA42D:
		ldx #$00
		lda d47F8
		sta $a533, x
		lda $a55b, x
		sta d47F8
		inx 
		lda $d000
		sta $a533, x
		lda $a55b, x
		sta $d000
		inx 
		lda $d001
		sta $a533, x
		lda $a55b, x
		sta $d001
		inx 
		lda $d01c
		sta $a533, x
		lda $a55b, x
		sta $d01c
		inx 
		lda $d017
		sta $a533, x
		lda $a55b, x
		and $d017
		sta $d017
		inx 
		lda $d027
		sta $a533, x
		lda $a55b, x
		sta $d027
		inx 
		lda $d025
		sta $a533, x
		lda #$02
		ldy $044f
		beq lA48F
		lda #$0b

lA48F:
		sta $d025
		inx 
		lda $d026
		sta $a533, x
		lda $a55b, x
		sta $d026
		inx 
		lda #$9b
		sta $d012
		jmp lA57B

lA4A8:
		lda #$cb
		sta $d012
		ldx #$08
		stx $a42c
		lda $47fb
		sta $a533, x
		lda $a55b, x
		sta $47fb
		inx 
		lda $d006
		sta $a533, x
		lda $a55b, x
		sta $d006
		inx 
		lda $d007
		sta $a533, x
		lda $a55b, x
		sta $d007
		inx 
		lda $d01c
		sta $a533, x
		lda $a55b, x
		sta $d01c
		inx 
		lda $d017
		sta $a533, x
		lda $a55b, x
		and $d017
		sta $d017
		inx 
		lda $d02a
		sta $a533, x
		lda $a55b, x
		sta $d02a
		inx 
		lda $d025
		sta $a533, x
		lda #$02
		ldy $044f
		beq lA512
		lda #$0b

lA512:
		sta $d025
		inx 
		lda $d026
		sta $a533, x
		lda $a55b, x
		sta $d026
		inx 
		jmp lA57B

lA526:
		lda #$fc
		sta $d012
		lda #$0b
		sta $d021
		jmp lA57B
*=$a56b

irq:
		lda $01
		pha 
		jsr lB5C3
		lda $d019
		and #$01
		and $d01a
		bne lA58A

lA57B:
		lda $dc0d
		pla 
		sta $01
		pla 
		tay 
		pla 
		tax 
		pla 
		rti 
		jmp lEA31

lA58A:
		sta $d019
		lda $d012
		cmp #$82
		bcs lA597
		jmp lA404

lA597:
		cmp #$9b
		bcs lA59E
		jmp lA42D

lA59E:
		cmp #$cb
		bcs lA5A5
		jmp lA4A8

lA5A5:
		cmp #$fc
		bcs lA5AC
		jmp lA526

lA5AC:
		jmp lA379

lA5AF:
		ldx #$00

lA5B1:
		lda $ff00, x
		sta $ff00, x
		lda $fe00, x
		sta $fe00, x
		inx 
		bne lA5B1
		php 
		lda irq_vector
		sta $a588
		lda irq_vector + $1
		sta $a589
		sei 
		lda #$6b
		sta irq_vector
		lda #$a5
		sta irq_vector + $1
		lda #$e9
		sta nmi_vector
		lda #$a5
		sta nmi_vector + $1
		lda #$00
		sta dA687
		plp 
		rts 

nmi:
		cli 
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda #$ff
		cmp dA687
		bne lA5FA
		jmp lA680

lA5FA:
		sta dA687
		lda $01

dA5FF:
		pha 
		jsr lB5C3
		lda $d418
		pha 
		lda #$00
		sta $d418
		lda $03
		pha 
		lda $02
		pha 
		lda $05
		pha 
		lda $04
		pha 
		lda $07
		pha 
		lda $06
		pha 
		lda $20
		pha 
		lda $1f
		pha 
		lda $0b
		pha 
		lda $0a
		pha 
		jsr lB5EE
		jsr l2C75
		eor ($55), y
		eor #$54
		jsr l5928
		rla $294e
		jsr l203F
		isc $9f20, x
lA63E = $a63e
		isc $c5a5, x
		cmp #$19
		bne lA64A
		jmp lA09D

lA64A:
		cmp #$17
		bne lA64F
		brk 

lA64F:
		cmp #$27
		bne $a63e
		jsr lB5EE
		pla 
		sta $0a
		pla 
		sta $0b
		pla 
		sta $1f
		pla 
		sta $20
		pla 
		sta $06
		pla 
		sta $07
		pla 
		sta $04
		pla 
		sta $05
		pla 
		sta $02
		pla 
		sta $03
		pla 
		sta $d418
		pla 
		sta $01
		lda #$00
		sta dA687

lA680:
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		rti 

dA687:
		brk 

lA688:
		lda $d012
		cmp #$14
		bcc lA688
		cmp #$32
		bcs lA688
		lda #$5f
		sta $d012
		lda #$7f
		and $d011
		sta $d011
		lda #$01
		ora $d01a
		sta $d01a
		cli 
		rts 

lA6AA:
		lda #$c0
		sta $06
		lda #$77
		sta $07
		lda #$80
		sta $08
		lda #$f8
		sta $09
		ldy #$00

lA6BC:
		lda #$aa
		sta ($06), y
		iny 
		bne lA6C5
		inc $07

lA6C5:
		inc $08
		bne lA6BC
		inc $09
		bne lA6BC
		lda #$f8
		sta $06
		lda #$da
		sta $07
		lda #$10
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA6DF:
		lda #$0f
		sta ($06), y
		iny 
		bne lA6E8
		inc $07

lA6E8:
		inc $08
		bne lA6DF
		inc $09
		bne lA6DF
		lda #$f8
		sta $06
		lda #$46
		sta $07
		lda #$10
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA702:
		lda #$cc
		sta ($06), y
		iny 
		bne lA70B
		inc $07

lA70B:
		inc $08
		bne lA702
		inc $09
		bne lA702
		lda $044e
		cmp #$ff
		bne lA71D
		jmp lA8C8

lA71D:
		lda #$48
		sta $06
		lda #$47
		sta $07
		lda #$ef
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA72F:
		lda #$bb
		sta ($06), y
		iny 
		bne lA738
		inc $07

lA738:
		inc $08
		bne lA72F
		inc $09
		bne lA72F
		lda #$70
		sta $06
		lda #$47
		sta $07
		lda #$ef
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA752:
		lda #$bb
		sta ($06), y
		iny 
		bne lA75B
		inc $07

lA75B:
		inc $08
		bne lA752
		inc $09
		bne lA752
		lda #$98
		sta $06
		lda #$47
		sta $07
		lda #$ef
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA775:
		lda #$bb
		sta ($06), y
		iny 
		bne lA77E
		inc $07

lA77E:
		inc $08
		bne lA775
		inc $09
		bne lA775
		lda #$63
		sta $06
		lda #$47
		sta $07
		lda #$f3
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA798:
		lda #$bb
		sta ($06), y
		iny 
		bne lA7A1
		inc $07

lA7A1:
		inc $08
		bne lA798
		inc $09
		bne lA798
		lda #$8b
		sta $06
		lda #$47
		sta $07
		lda #$f3
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA7BB:
		lda #$bb
		sta ($06), y
		iny 
		bne lA7C4
		inc $07

lA7C4:
		inc $08
		bne lA7BB
		inc $09
		bne lA7BB
		lda #$b3
		sta $06
		lda #$47
		sta $07
		lda #$f3
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA7DE:
		lda #$bb
		sta ($06), y
		iny 
		bne lA7E7
		inc $07

lA7E7:
		inc $08
		bne lA7DE
		inc $09
		bne lA7DE
		lda #$db
		sta $06
		lda #$47
		sta $07
		lda #$f3
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA801:
		lda #$bb
		sta ($06), y
		iny 
		bne lA80A
		inc $07

lA80A:
		inc $08
		bne lA801
		inc $09
		bne lA801
		lda #$66
		sta $06
		lda #$db
		sta $07
		lda #$f6
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA824:
		lda #$01
		sta ($06), y
		iny 
		bne lA82D
		inc $07

lA82D:
		inc $08
		bne lA824
		inc $09
		bne lA824
		lda #$8e
		sta $06
		lda #$db
		sta $07
		lda #$f6
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA847:
		lda #$01
		sta ($06), y
		iny 
		bne lA850
		inc $07

lA850:
		inc $08
		bne lA847
		inc $09
		bne lA847
		lda #$b6
		sta $06
		lda #$db
		sta $07
		lda #$f6
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA86A:
		lda #$01
		sta ($06), y
		iny 
		bne lA873
		inc $07

lA873:
		inc $08
		bne lA86A
		inc $09
		bne lA86A
		lda #$de
		sta $06
		lda #$db
		sta $07
		lda #$f6
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA88D:
		lda #$01
		sta ($06), y
		iny 
		bne lA896
		inc $07

lA896:
		inc $08
		bne lA88D
		inc $09
		bne lA88D
		lda $044e
		and #$01
		bne lA8C8
		lda #$20
		sta $06
		lda #$db
		sta $07
		lda #$d8
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lA8B7:
		lda #$0c
		sta ($06), y
		iny 
		bne lA8C0
		inc $07

lA8C0:
		inc $08
		bne lA8B7
		inc $09
		bne lA8B7

lA8C8:
		jmp lA901

lA8CB:
		lda #$1f
		sta $04
		lda #$7b
		sta $05
		ldx #$04

lA8D5:
		lda $05
		pha 
		lda $04
		pha 
		ldy #$50
		lda #$00

lA8DF:
		sta ($04), y
		cpy #$12
		bcs lA8E7
		lda #$aa

lA8E7:
		dey 
		bne lA8DF
		pla 
		sta $04
		pla 
		sta $05
		lda #$40
		clc 
		adc $04
		sta $04
		lda #$01
		adc $05
		sta $05
		dex 
		bne lA8D5
		rts 

lA901:
		ldx #$00
		stx $127c
		stx $14
		ldy #$30
		sty $16
		ldx #$9f
		jsr l165F
		ldx #$9f
		ldy #$c7
		jsr l165F
		ldx #$00
		ldy #$c7
		jsr l165F
		ldx #$00
		ldy #$30
		jsr l165F
		rts 

lA927:
		ldx #$2c
		lda $eb37, x
		cmp #$02
		bne lA95A

lA930:
		lda $eb35, x
		sta $08
		lda $eb36, x
		sta $09
		ldy #$00

lA93C:
		lda ($08), y
		cmp #$80
		beq lA956
		asl 
		php 
		ror 
		plp 
		ror 
		sta ($08), y
		iny 
		lda ($08), y
		asl 
		php 
		ror 
		plp 
		ror 
		sta ($08), y
		iny 
		bne lA93C

lA956:
		dex 
		dex 
		bne lA930

lA95A:
		rts 

lA95B:
		jmp (a2CE5)

lA95E:
		jmp (a2CE7)

lA961:
		jmp (a2CE9)

lA964:
		jmp (a2CEB)
*=$ac2b

lAC2B:
		lda #$00
		sta $044f
		ldx #$00
		lda $ad48
		cmp $ad49
		beq lAC41
		bcc lAC3E
		ldx #$01

lAC3E:
		stx $af2e

lAC41:
		lda $044e
		and #$01
		beq lAC4E
		jsr lAC4E
		inc $044f

lAC4E:
		ldx $044f
		txa 
		asl 
		tay 
		sed 
		lda $ad48, x
		clc 
		adc $ad4e, y
		sta $ad4e, y
		lda $ad4f, y
		adc #$00
		sta $ad4f, y
		lda $ad48, x
		sec 
		sbc $0450
		bcc lAC82
		clc 
		adc $ad4a, y
		sta $ad4a, y
		lda $ad4b, y
		adc #$00
		sta $ad4b, y
		jmp lAC91

lAC82:
		clc 
		adc $ad4a
		sta $ad4a, y
		lda $ad4b, y
		adc #$99
		sta $ad4b, y

lAC91:
		lda #$00
		sta $ad48, x
		cld 
		stx $ad46
		sty $ad47
		lda #$48
		sta $1f
		lda #$2f
		sta $20
		lda $044f
		beq lACB2
		lda #$48
		sta $1f
		lda #$27
		sta $20

lACB2:
		lda #$0b
		jsr lA961
		ldy $ad47
		ldx $ad4f, y
		lda $ad4e, y
		ldy #$00
		sty $ad45
		jsr lAD21
		lda #$68
		sta $1f
		ldy $ad47
		lda $ad4a, y
		sta $ad52
		lda $ad4b, y
		sta $ad53
		lda #$2b
		pha 
		lda $ad53
		cmp #$50
		bcc lACFC
		pla 
		lda #$2d
		pha 
		lda #$00
		sed 
		sec 
		sbc $ad52
		sta $ad52
		lda #$00
		sbc $ad53
		sta $ad53
		cld 

lACFC:
		pla 
		jsr l0FFB
		lda $ad52
		ldx $ad53
		ldy #$00
		sty $ad45
		jsr lAD21
		lda #$90
		sta $1f
		ldx $ad46
		lda $ad48, x
		ldy #$00
		sty $ad45
		jsr lAD27
		rts 

lAD21:
		pha 
		txa 
		jsr lAD35
		pla 

lAD27:
		pha 
		lsr 
		lsr 
		lsr 
		lsr 
		jsr lAD35
		ldx #$01
		stx $ad45
		pla 

lAD35:
		and #$0f
		bne lAD3F
		ldx $ad45
		bne lAD3F
		rts 

lAD3F:
		sta $ad45
		jmp l2C93
*=$ad54

lAD54:
		lda #$82
		sta $0470
		lda #$6c
		sta $0471
		jsr lB396
		lda $0400
		sta $10
		lda $0401
		sta $11
		lda $0402
		sta $12
		lda $0403
		sta $13
		jsr l0BA4
		lda $2c5b
		jsr lAE18
		sta $2c5b
		lda $2c5d
		sec 
		sbc #$02
		jsr lAE18
		sta $2c5d
		lda #$ff
		sta $1368
		lda $2c5b
		clc 
		adc $0470
		tax 
		ldy $0471
		dex 
		dex 
		stx $14
		dey 
		dey 
		sty $16
		ldy $16
		tya 
		clc 
		adc #$04
		sta $16
		ldx $14
		jsr l165F
		inc $14
		dec $16
		ldy $16
		tya 
		clc 
		adc #$06
		sta $16
		ldx $14
		jsr l165F
		inc $14
		ldy $16
		tya 
		clc 
		adc #$06
		sta $16
		ldx $14
		jsr l165F
		inc $14
		inc $16
		ldy $16
		tya 
		clc 
		adc #$04
		sta $16
		ldx $14
		jsr l165F
		inc $14
		lda $0471
		sec 
		sbc $2c5d
		tay 
		sta $0471
		ldx $0470
		stx $14
		sty $16
		lda $14
		clc 
		adc #$06
		asl 
		sta $d00c
		bcc lAE0A
		lda $d010
		ora #$40
		sta $d010

lAE0A:
		lda #$f0
		sec 
		sbc $16
		sta $d00d
		lda #$21
		sta $47fe
		rts 

lAE18:
		ora #$00
		php 
		bpl lAE22
		clc 
		eor #$ff
		adc #$01

lAE22:
		tax 
		lda #$00
		jsr l0900
		sta $0e
		stx $0f
		lda #$00
		ldx #$03
		jsr l0900
		dex 
		jsr l094C
		lda $0e
		ldx $0f
		jsr l091F
		txa 
		plp 
		bpl lAE47
		clc 
		eor #$ff
		adc #$01

lAE47:
		rts 
*=$ae92

lAE92:
		lda $044e
		and #$01
		bne lAE9C
		jmp lAF26

lAE9C:
		lda $043f
		bpl lAEB7
		ldx $043e
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta $043f
		stx $043e

lAEB7:
		lda $0441
		bpl lAED2
		ldx $0440
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta $0441
		stx $0440

lAED2:
		lda $0449
		bpl lAEED
		ldx $0448
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta $0449
		stx $0448

lAEED:
		lda $044b
		bpl lAF08
		ldx $044a
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta $044b
		stx $044a

lAF08:
		ldx #$01

lAF0A:
		lda $043e, x
		ora $0440, x
		sta $0439
		lda $0448, x
		ora $044a, x
		cmp $0439
		beq lAF27
		bcs lAF24
		lda #$00
		beq lAF26

lAF24:
		lda #$01

lAF26:
		rts 

lAF27:
		dex 
		beq lAF0A
		lda $af2e
		rts 
*=$af2f

lAF2F:
		sta $044f
		ora #$00
		bne lAF39
		tax 
		beq lAF3B

lAF39:
		ldx #$0a

lAF3B:
		lda $0442, x
		sta $0456
		lda $0443, x
		beq lAF5D
		sta $66
		lda $043a, x
		sta $1b
		lda $043b, x
		sta $1c
		lda $043c, x
		sta $1d
		lda $043d, x
		sta $1e
		rts 

lAF5D:
		lda $044f
		eor #$01
		jmp lAF2F

lAF65:
		lda $66
		bne lAF75
		sta $0452
		sta $0453
		sta $0454
		sta $0455

lAF75:
		ldx $044f
		beq lAF7C
		ldx #$0a

lAF7C:
		lda $1b
		sta $043a, x
		lda $1c
		sta $043b, x
		lda $1d
		sta $043c, x
		lda $1e
		sta $043d, x
		lda $0452
		sta $043e, x
		lda $0453
		sta $043f, x
		lda $0454
		sta $0440, x
		lda $0455
		sta $0441, x
		lda $0456
		sta $0442, x
		lda $66
		sta $0443, x
		beq lAFB6
		rts 

lAFB6:
		lda #$00
		sta $1f
		lda #$07
		sta $20
		lda $1f
		clc 
		adc #$04
		sta $1f
		lda #$0c
		jsr lA961
		ldx $044f
		lda $ad48, x
		sec 
		sbc $0450
		bcc lAFE9
		beq lAFFB
		jsr l2C75
		sre $4556
*=$afe9

lAFE9:
		jsr l2C75
		eor $4e, x
		nop $45
*=$affb

lAFFB:
		jsr l2C75
		jmp l5645
*=$b00d

lB00D:
		ldx $0451
		lda $b103, x
		pha 
		and #$0f
		sta $b0fa
		pla 
		lsr 
		lsr 
		lsr 
		lsr 
		sta $b0f9
		jsr lB116
		and #$03
		cmp #$02
		bcs lB044
		cmp #$01
		beq lB03B
		ldx $045b
		inx 
		cpx #$0a
		bcs lB044
		stx $045b
		bcc lB044

lB03B:
		ldx $045b
		dex 
		beq lB044
		stx $045b

lB044:
		jsr lB116
		and #$03
		cmp #$02
		bcs lB060
		cmp #$01
		beq lB055
		lda #$01
		bne lB057

lB055:
		lda #$ff

lB057:
		clc 
		adc $045a
		and #$07
		sta $045a

lB060:
		rts 

lB061:
		jsr lB116
		and #$07
		sta $045a
		jsr lB116
		and #$07
		clc 
		adc #$01
		sta $045b
		rts 

lB075:
		lda $66
		cmp #$40
		bcc lB08B
		lda $045a
		sta $b0f8
		lda $045b
		sta $b0f7
		lda #$01
		bne lB099

lB08B:
		lda $b0fa
		sta $b0f8
		lda $b0f9
		sta $b0f7
		lda #$05

lB099:
		sta $b0fb
		lda $b0f8
		sec 
		sbc $0db8
		and #$07
		sta $0459
		tax 
		lda $b0dd, x
		jsr lB0BE
		sta $0458
		lda $b0e5, x
		jsr lB0BE
		sta $0457
		jmp lB135

lB0BE:
		tay 
		beq lB0CE
		bmi lB0CF
		lda $b0f7
		cpy #$0a
		beq lB0CE
		tay 
		lda $b0ed, y

lB0CE:
		rts 

lB0CF:
		clc 
		eor #$ff
		adc #$01
		jsr lB0BE
		clc 
		eor #$ff
		adc #$01
		rts 
*=$b116

lB116:
		lda $a00c
		pha 
		inc lB116 + 1
		bne lB122
		inc lB116 + 2

lB122:
		lda lB116 + 2
		cmp #$b1
		bcc lB133
		lda #$00
		sta lB116 + 1
		lda #$a0
		sta lB116 + 2

lB133:
		pla 
		rts 

lB135:
		jsr lA8CB
		lda #$ff
		sta $1368
		lda #$78
		sta $1f
		lda #$27
		sta $20
		ldx #$04
		ldy $b0fb

lB14A:
		lda $1f
		sec 
		sbc #$08
		sta $1f
		lda $20
		sec 
		sbc #$08
		sta $20
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda $b0fb, y
		jsr l0FFB
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		iny 
		dex 
		bne lB14A
		lda #$90
		sta $1f
		lda #$17
		sta $20
		lda #$01
		sta $ad45
		lda $b0f7
		jsr lAD35
		lda $29
		pha 
		lda #$00
		sta $127c
		sta $29
		lda $0459
		asl 
		asl 
		tax 
		pha 
		lda $b203, x
		jsr lB23A
		stx $14
		sty $16
		pla 
		pha 
		tax 
		lda $b202, x
		jsr lB23A
		jsr l165F
		pla 
		pha 
		tax 
		lda $15
		pha 
		lda $14
		pha 
		lda $17
		pha 
		lda $16
		pha 
		lda $b204, x
		jsr lB23A
		jsr l165F
		pla 
		sta $16
		pla 
		sta $17
		pla 
		sta $14
		pla 
		sta $15
		pla 
		tax 
		lda $b205, x
		jsr lB23A
		jsr l165F
		pla 
		sta $29
		lda #$2f
		sta $04
		lda #$7b
		sta $05
		ldx #$04

lB1E4:
		ldy #$40

lB1E6:
		lda ($04), y
		ora #$aa
		sta ($04), y
		dey 
		bne lB1E6
		lda #$40
		clc 
		adc $04
		sta $04
		lda #$01
		adc $05
		sta $05
		dex 
		bne lB1E4
		rts 
*=$b23a

lB23A:
		asl 
		tax 
		lda $b223, x
		clc 
		adc $b201
		tay 
		lda $b222, x
		clc 
		adc $b200
		tax 
		rts 

lB24D:
		lda #$48
		sta $06
		lda #$47
		sta $07
		lda #$60
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lB25F:
		lda #$cc
		sta ($06), y
		iny 
		bne lB268
		inc $07

lB268:
		inc $08
		bne lB25F
		inc $09
		bne lB25F
		lda #$48
		sta $06
		lda #$db
		sta $07
		lda #$60
		sta $08
		lda #$ff
		sta $09
		ldy #$00

lB282:
		lda #$01
		sta ($06), y
		iny 
		bne lB28B
		inc $07

lB28B:
		inc $08
		bne lB282
		inc $09
		bne lB282
		lda #$40
		sta $06
		lda #$7a
		sta $07
		lda #$00
		sta $08
		lda #$fb
		sta $09
		ldy #$00

lB2A5:
		lda #$aa
		sta ($06), y
		iny 
		bne lB2AE
		inc $07

lB2AE:
		inc $08
		bne lB2A5
		inc $09
		bne lB2A5
		lda #$ff
		sta $1368
		lda #$20
		sta $1f
		lda #$1f
		sta $20
		jsr l2C75
		lsr $31
		and #$20
		and ($20), y
		bvc lB31A
		eor ($59, x)
		eor $52
		isc $7520, x
		bit $ff0d
		jsr l2C75
		jsr $2020
		jsr l3346
		and #$20
*=$b31a

lB31A:
		stx $044e
		jsr l2C75
		ora $20ff
		adc $2c, x
		jsr $2020
		jsr l4F48
		jmp $2045
*=$b396

lB396:
		lda #$c7
		sta $04
		lda #$6a
		sta $05
		lda #$58
		sta $06
		lda #$45
		sta $07
		lda #$58
		sta $08
		lda #$cc
		sta $09
		ldx #$78
		ldy #$0b

lB3B2:
		tya 
		pha 
		txa 
		tay 
		lda #$00

lB3B8:
		sta ($04), y
		dey 
		bne lB3B8
		ldy #$0f

lB3BF:
		lda #$0f
		sta ($06), y
		lda #$ff
		sta ($08), y
		dey 
		bne lB3BF
		lda #$40
		clc 
		adc $04
		sta $04
		lda #$01
		adc $05
		sta $05
		lda #$28
		clc 
		adc $06
		sta $06
		lda $07
		adc #$00
		sta $07
		lda #$28
		clc 
		adc $08
		sta $08
		lda $09
		adc #$00
		sta $09
		pla 
		tay 
		dey 
		bne lB3B2
		ldx #$9f
		stx $14
		ldy #$30
		sty $16
		ldy #$87
		lda #$00
		sta $127c
		jsr l165F
		ldx #$64
		ldy #$87
		jsr l165F
		ldx #$64
		ldy #$30
		jsr l165F
		ldx #$9f
		ldy #$30
		jmp l165F

lB41D:
		pha 
		txa 
		pha 
		lda $044e
		and #$01
		beq lB430
		ldx $044f
		lda $dc00, x
		jmp lB436

lB430:
		lda $dc00
		and $dc01

lB436:
		tax 
		ldy #$3c
		and #$10
		beq lB453
		ldy #$29
		txa 
		and #$09
		cmp #$09
		bne lB453
		ldy #$2a
		txa 
		and #$06
		cmp #$06
		bne lB453
		pla 
		tax 
		pla 
		rts 

lB453:
		pla 
		tax 
		pla 
		tya 
		rts 

lB458:
		ldy #$00

lB45A:
		lda $b467, x
		sta $0472, y
		inx 
		iny 
		cpy #$04
		bcc lB45A
		rts 
*=$b5b0

lB5B0:
		jsr lBC01
		jsr lB5BC
		jsr l2008
		jmp lB5C3

lB5BC:
		lda $01
		and #$fd
		sta $01
		rts 

lB5C3:
		lda $01
		ora #$02
		sta $01
		rts 
*=$b5ee

lB5EE:
		lda #$00
		sta $1f
		lda #$07
		sta $20
		lda #$0d
		jmp lA961
*=$b5fc

lB5FC:
		ldx #$06
		lda #$ff
		sta $04
		lda #$73
		sta $05

lB606:
		lda #$00
		ldy #$a0

lB60A:
		sta ($04), y
		dey 
		bne lB60A
		lda #$a0
		clc 
		adc $04
		sta $04
		lda $05
		adc #$00
		sta $05
		dex 
		bne lB606
		ldy #$20
		ldx #$00

lB623:
		lda $b660, y
		and $72c0, x
		sta $72c0, x
		lda $b678, y
		and $7360, x
		sta $7360, x
		iny 
		tya 
		and #$7f
		tay 
		inx 
		cpx #$a0
		bcc lB623
		lda #$ff
		sta $1368
		ldx #$00
		stx $127c
		stx $14
		ldy #$30
		sty $16
		ldy #$50
		jsr l165F
		ldx #$9f
		stx $14
		ldy #$30
		jsr l165F
		jmp (a2CEF)
*=$b79f

lB79F:
		ldx #$14
		stx $b800
		lda $e000, x
		cmp $04
		bne lB7CF
		lda $e001, x
		cmp $05
		bne lB7CF
		lda #$00
		sta $b800
		lda $1f24
		sta $b801
		lda $1f25
		sta $b802
		lda $1f26
		sta $b803
		lda $1f27
		sta $b804

lB7CF:
		ldy #$00
		rts 

lB7D2:
		lda $b800
		bne lB7FD
		lda $1f20
		clc 
		adc $b801
		sta $1f24
		lda $1f21
		adc $b802
		sta $1f25
		lda $1f22
		clc 
		adc $b803
		sta $1f26
		lda $1f23
		adc $b804
		sta $1f27

lB7FD:
		jmp l1BFC
*=$b805

lB805:
		jsr l1306
		bne lB852
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda #$ff
		sta $b853
		ldy $18
		lda $117c, y
		sta $b854
		ldx $117b, y
		ldy #$00

lB822:
		iny 
		iny 
		cpy $127c
		bcs lB83D
		txa 
		cmp $117c, y
		bne lB822
		lda $b854
		cmp $117d, y
		bne lB822
		inc $b853
		jmp lB822

lB83D:
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		lda $b853
		beq lB852
		lda $136d, x
		and $1368
		ora ($0a), y
		sta ($0a), y

lB852:
		rts 
*=$bc01

lBC01:
		ldx #$19
		lda #$00

lBC05:
		sta $d400, x
		dex 
		bne lBC05
		rts 
*=$ea31

lEA31:
		brk 