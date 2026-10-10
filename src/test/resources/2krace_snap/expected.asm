
*=$0850

l0850:
		jsr l0B77
		jsr l0A73
		jsr l0A7E
		jsr l0A57
		jsr l0CC2
		jsr l0BB5
		lda #$00
		sta l087B + 1
		sta $08
		lda #$03
		sta $07
		lda #$01
		sta $0b66
		jsr l1000
		lda $d01f
		jsr l0C61

l087B:
		lda #$01
		beq l087B
		lda $05
		clc 
		adc $04
		tax 
		and #$07
		sta $04
		txa 
		lsr 
		lsr 
		lsr 
		sta $0c06
		beq l08BE

l0892:
		pha 
		dec $02
		ldx $09
		jsr l0CD9
		ldx $02
		lda #$00
		ldy $0c98
		cpy #$01
		bmi l08A7
		lda #$01

l08A7:
		sta $8000, x
		lda #$00
		ldy $0c99
		cpy #$01
		bmi l08B5
		lda #$01

l08B5:
		sta $8100, x
		pla 
		sec 
		sbc #$01
		bne l0892

l08BE:
		lda #$82
		inc l08BE + 1
		and #$3f
		bne l08CF
		lda $05
		cmp $06
		bcs l08CF
		inc $05

l08CF:
		lda $04
		clc 
		adc #$05
		sta $0a0b
		lda $04
		clc 
		adc #$f6
		sta $0a32
		lda $02
		sta l0B93 + 1
		lda #$80
		sta l0B93 + 2
		lda #$43
		sta $fb
		lda #$40
		sta $fc
		jsr l0B8F
		lda $02
		sta l0B93 + 1
		lda #$81
		sta l0B93 + 2
		lda #$85
		sta $fb
		lda #$40
		sta $fc
		jsr l0B8F
		lda $02
		clc 
		adc #$05
		sta l0926 + 1
		sta $092c
		lda #$08
		sta $fb
		lda #$44

; where the CPU was when the snapshot was taken
snapshot_pc:
		sta $fc
		sta $fe
		lda #$1f
		sta $fd
		ldx #$19
		ldy #$00

l0926:
		lda $80fd
d0927 = $0927
		sta ($fb), y
		lda $81fd
d092C = $092c
		sta ($fd), y
		tya 
		clc 
		adc #$28
		tay 
		bcc l093B
		inc $fc
		inc $fe

l093B:
		inc l0926 + 1
		inc $092c
		dex 
		bne l0926
		lda $02
		clc 
		adc #$1e
		sta l0B93 + 1
		lda #$80
		sta l0B93 + 2
		lda #$c0
		sta $fb
		lda #$40
		sta $fc
		jsr l0B8F
		lda $02
		clc 
		adc #$1e
		sta l0B93 + 1
		lda #$81
		sta l0B93 + 2
		lda #$02
		sta $fb
		lda #$41
		sta $fc
		jsr l0B8F
		lda $d01f
		and #$01
		bne l099F
		lda $07
		cmp #$02
		bcs l099F
		lda #$00
		sta $d418
		ldy #$04

l0988:
		ldx #$1f

l098A:
		lda $0c41, x
		sta $d027
		jsr l0A73
		dex 
		bpl l098A
		dey 
		bpl l0988
		jsr l0C11
		jmp l0850

l099F:
		jsr l0B0F
		ldx $08
		lda $07
		cmp #$02
		bcc l09C4
		bne l09B9
		dec $08
		bne l09C4
		ldx #$00
		stx $08
		stx $07
		jmp l09C4

l09B9:
		inx 
		stx $08
		cpx #$0f
		bne l09C4
		lda #$01
		sta $07

l09C4:
		lda $0d90, x
		sta $d000
		jsr l0BC7
		jsr l0B3C
		jsr l1003
		lda #$00
		sta l087B + 1
		jmp l087B
*=$09fd

irq:
		pha 
		lda $d011
		and #$78
		ora $04
		ora #$08
		sta $d011
		lda #$07
		sta $d003
		sta $d005
		lda #$01
		sta $47f9
		lda #$02
		sta $47fa
		lda #$c0
		sta $d012
		lda #$30
		sta irq_vector
		lda #$0a
		sta irq_vector + $1
		lsr $d019
		pla 
		rti 
		pha 
		lda #$f8
		sta $d003
		sta $d005
		lda #$03
		sta $47f9
		lda #$04
		sta $47fa
		lda #$f9
		sta $d012
		lda #$db
		sta irq_vector
		lda #$09
		sta irq_vector + $1
		lsr $d019
		pla 
		rti 

l0A57:
		ldx #$00
		stx $02
		stx $04
		lda #$01

l0A5F:
		sta $8000, x
		sta $8100, x
		inx 
		bne l0A5F
		stx $05
		lda #$05
		sta $06
		lda #$00
		sta $09
		rts 

l0A73:
		bit $d011
		bmi l0A73

l0A78:
		bit $d011
		bpl l0A78
		rts 

l0A7E:
		lda #$00
		sta $7fff
		lda #$06
		sta $d020
		sta $d021
		lda #$01
		sta $d027
		sta $d02a
		sta $d02b
		sta $d02c
		sta $d02d
		sta $d02e
		ldx #$00
		lda #$0f
		sta $d028
		sta $d029

l0AA9:
		sta $d800, x
		sta $d900, x
		sta $da00, x
		sta $db00, x
		dex 
		bne l0AA9
		lda #$02
		sta $dd00
		lda #$1e
		sta $d018
		lda #$1b
		sta $d011
		lda #$ff
		sta $d015
		lda #$01
		sta $d01b
		lda #$06
		sta $d017
		lda #$08
		sta $47f8
		lda #$d2
		ldx #$08

l0ADF:
		sta $d006, x
		sec 
		sbc #$10
		dex 
		dex 
		bpl l0ADF
		lda #$ff
		sta $d007
		sta $d009
		sta $d00b
		sta $d00d
		sta $d00f
		lda #$04
		sta $d010
		lda #$58
		sta $d002
		lda #$00
		sta $d004
		lda #$e0
		sta $d001
		rts 

l0B0F:
		ldx $07
		cpx #$02
		bcc l0B16
		rts 

l0B16:
		lda $dc00
		and #$0c
		cmp #$04
		bne l0B2D
		cpx #$00
		beq l0B24
		rts 

l0B24:
		ldx #$03
		stx $07
		lda #$00
		sta $08

l0B2C:
		rts 

l0B2D:
		cmp #$08
		bne l0B2C
		cpx #$01
		bne l0B2C
		inc $07
		lda #$0f
		sta $08
		rts 

l0B3C:
		lda $0bfe
		lsr 
		cmp $0b66
		bcc l0B65
		ldx $0b66
		inc $0b66
		dex 
		lda $0b67, x
		sta $d021
		sta $d020
		lda $0b6b, x
		sta $06
		lda $0b6f, x
		sta $09
		lda $0b73, x
		sta $47f8

l0B65:
		rts 
*=$0b77

l0B77:
		lax #$00

l0B79:
		sta $4400, x
		sta $4500, x
		sta $4600, x
		sta $46e8, x
		sta $4040, x
		dex 
		bne l0B79
		sta $d000
		rts 

l0B8F:
		ldy #$00
		ldx #$04

l0B93:
		lda $81fd
d0B94 = $0b94
		beq l0B9A
		lda #$ff

l0B9A:
		sta ($fb), y
		iny 
		iny 
		iny 
		sta ($fb), y
		iny 
		iny 
		iny 
		sta ($fb), y
		iny 
		iny 
		iny 
		sta ($fb), y
		iny 
		iny 
		iny 
		inc l0B93 + 1
		dex 
		bpl l0B93
		rts 

l0BB5:
		lda #$00
		sta $0bfd
		sta $0bfe
		sta $0bff
		sta $0c00
		sta $0c01
		rts 

l0BC7:
		ldx #$04
		lda #$00

l0BCB:
		sta $0c07, x
		dex 
		bpl l0BCB
		ldx #$04

l0BD3:
		lda $0bfd, x
		clc 
		adc $0c02, x
		adc $0c07, x
		and #$0f
		cmp #$0a
		bcc l0BE9
		inc $0c06, x
		sec 
		sbc #$0a

l0BE9:
		sta $0bfd, x
		dex 
		bpl l0BD3
		ldx #$04

l0BF1:
		lda $0bfd, x
		ora #$20
		sta $47fb, x
		dex 
		bpl l0BF1
		rts 
*=$0c11

l0C11:
		ldx #$00

l0C13:
		lda $0c0c, x
		cmp $0bfd, x
		bcc l0C28
		beq l0C20
		jmp l0C33

l0C20:
		inx 
		cpx #$05
		bne l0C13
		jmp l0C33

l0C28:
		ldx #$04

l0C2A:
		lda $0bfd, x
		sta $0c0c, x
		dex 
		bpl l0C2A

l0C33:
		ldx #$04

l0C35:
		lda $0c0c, x
		ora #$20
		sta $47fb, x
		dex 
		bpl l0C35
		rts 
*=$0c61

l0C61:
		ldx #$0b

l0C63:
		txa 
		sta $45ed, x
		clc 
		adc #$0a
		sta $4615, x
		dex 
		cpx #$01
		bne l0C63
		jsr l0C11
		ldx #$1f

l0C77:
		jsr l0A73
		ldy #$09
		lda $0c41, x

l0C7F:
		sta $d9ef, y
		sta $da17, y
		dey 
		bpl l0C7F
		dex 
		txa 
		and #$1f
		tax 
		lda $dc00
		and #$10
		bne l0C77
		jsr l0B77
		rts 
*=$0cc2

l0CC2:
		lda #$01
		sta $0c98
		sta $0c99
		lda #$ff
		sta $0d7f
		sta $0d80
		sta $0d81
		sta $0d82
		rts 

l0CD9:
		lda $0c98
		beq l0CE1
		inc $0c98

l0CE1:
		lda $0c99
		beq l0CE9
		inc $0c99

l0CE9:
		jsr l0D4D
		lda $0c98
		cmp $0ca4, x
		bcc l0D0A
		lda $0d7f
		cmp $0cae, x
		bcs l0D1C
		lda #$fe
		sta $0c98
		lda $0c9a, x
		sta $0c99
		jmp l0D1C

l0D0A:
		lda $0c98
		bne l0D1C
		lda $0d81
		cmp $0cb8, x
		bcs l0D1C
		lda #$01
		sta $0c98

l0D1C:
		lda $0c99
		cmp $0ca4, x
		bcc l0D3A
		lda $0d80
		cmp $0cae, x
		bcs l0D4C
		lda #$fe
		sta $0c99
		lda $0c9a, x
		sta $0c98
		jmp l0D4C

l0D3A:
		lda $0c99
		bne l0D4C
		lda $0d82
		cmp $0cb8, x
		bcs l0D4C
		lda #$01
		sta $0c99

l0D4C:
		rts 

l0D4D:
		asl $0d7f
		rol $0d80
		rol $0d81
		rol $0d82
		bcc l0D7B
		lda $0d7f
		eor #$b7
		sta $0d7f
		lda $0d80
		eor #$1d
		sta $0d80
		lda $0d81
		eor #$c1
		sta $0d81
		lda $0d82
		eor #$04
		sta $0d82

l0D7B:
		lda $0d7f
		rts 
*=$1000

l1000:
		jmp l100C

l1003:
		jmp l1014
*=$100c

l100C:
		sta $1017
		rts 
*=$1014

l1014:
		ldx #$00
		ldy #$ff
d1017 = $1017
		bmi l104A
		txa 
		ldx #$29

l101D:
		sta $1248, x
		dex 
		bpl l101D
		sta $d415
		sta $1099
		sta l104A + 1
		stx $1017
		tax 
		jsr l103A
		ldx #$07
		jsr l103A
		ldx #$0e

l103A:
		lda #$05
		sta $1274, x
		lda #$01
		sta $1275, x
		sta $1277, x
		jmp l123E

l104A:
		ldy #$01
		beq l1093
		lda #$00
d104F = $104f
		bne l1075
		lda $143f, y
		beq l1069
		bpl l1072
		asl 
		sta $109e
		lda $1442, y
		sta $1099
		lda $1440, y
		bne l1087
		iny 

l1069:
		lda $1442, y
		sta l1093 + 1
		jmp l1084

l1072:
		sta $104f

l1075:
		lda $1442, y
		clc 
		adc l1093 + 1
		sta l1093 + 1
		dec $104f
		bne l1095

l1084:
		lda $1440, y

l1087:
		cmp #$ff
		iny 
		tya 
		bcc l1090
		lda $1442, y

l1090:
		sta l104A + 1

l1093:
		lda #$05

l1095:
		sta $d416
		lda #$f1
		sta $d417
		lda #$10
		ora #$0f
		sta $d418
		jsr l10AE
		ldx #$07
		jsr l10AE
		ldx #$0e

l10AE:
		dec $1275, x
		beq l10BE
		bpl l10BB
		lda $1274, x
		sta $1275, x

l10BB:
		jmp l113D

l10BE:
		lda $124b, x
		bne l10F3
		ldy $1272, x
		lda $1371, y
		sta $d0
		lda $1374, y
		sta $d1
		ldy $1248, x
		lda ($d0), y
		cmp #$ff
		bcc l10DF
		iny 
		lda ($d0), y
		tay 
		lda ($d0), y

l10DF:
		cmp #$e0
		bcc l10EB
		sbc #$f0
		sta $1249, x
		iny 
		lda ($d0), y

l10EB:
		sta $1273, x
		iny 
		tya 
		sta $1248, x

l10F3:
		ldy $1277, x
		lda $125f, x
		beq l113D
		sec 
		sbc #$60
		sta $1276, x
		lda #$00
		sta $125f, x
		lda #$09
		sta $1261, x
		inc $1278, x
		lda $13ad, y
		beq l111B
		sta $1262, x
		lda #$00
		sta $1263, x

l111B:
		lda $13b8, y
		beq l1128
		sta l104A + 1
		lda #$00
		sta $104f

l1128:
		lda $13a2, y
		sta $1260, x
		lda $1397, y
		sta $129d, x
		lda $138c, y
		sta $129c, x
		jmp l121A

l113D:
		ldy $1260, x
		beq l1173
		lda $13c3, y
		beq l114A
		sta $1261, x

l114A:
		lda $13c4, y
		cmp #$ff
		iny 
		tya 
		bcc l1157
		clc 
		lda $13fb, y

l1157:
		sta $1260, x
		lda $13fa, y
		beq l1173
		bpl l1166
		adc $1276, x
		and #$7f

l1166:
		tay 
		lda $12b1, y
		sta $128a, x
		lda $1311, y
		sta $128b, x

l1173:
		lda $1275, x
		cmp #$02
		beq l11C8
		ldy $1262, x
		beq l11C5
		ora $124b, x
		beq l11C5
		lda $1263, x
		bne l119D
		lda $1433, y
		bpl l119A
		sta $128d, x
		lda $1439, y
		sta $128c, x
		jmp l11B6

l119A:
		sta $1263, x

l119D:
		lda $1439, y
		clc 
		bpl l11A6
		dec $128d, x

l11A6:
		adc $128c, x
		sta $128c, x
		bcc l11B1
		inc $128d, x

l11B1:
		dec $1263, x
		bne l11C5

l11B6:
		lda $1434, y
		cmp #$ff
		iny 
		tya 
		bcc l11C2
		lda $1439, y

l11C2:
		sta $1262, x

l11C5:
		jmp l121A

l11C8:
		ldy $1273, x
		lda $1377, y
		sta $d0
		lda $1382, y
		sta $d1
		ldy $124b, x
		lda ($d0), y
		cmp #$40
		bcc l11F2
		cmp #$c0
		bcc l11F8
		lda $124c, x
		bne l11E9
		lda ($d0), y

l11E9:
		adc #$00
		sta $124c, x
		beq l1211
		bne l121A

l11F2:
		sta $1277, x
		iny 
		lda ($d0), y

l11F8:
		cmp #$bd
		beq l1211
		adc $1249, x
		sta $125f, x
		lda #$00
		sta $129d, x
		lda #$0f
		sta $129c, x
		lda #$fe
		sta $1278, x

l1211:
		iny 
		lda ($d0), y
		beq l1217
		tya 

l1217:
		sta $124b, x

l121A:
		lda $129c, x
		sta $d405, x
		lda $129d, x
		sta $d406, x
		lda $128c, x
		sta $d402, x
		lda $128d, x
		sta $d403, x
		lda $128a, x
		sta $d400, x
		lda $128b, x
		sta $d401, x

l123E:
		lda $1261, x
		and $1278, x
		sta $d404, x
		rts 
*=$fffe

; the hardware IRQ vector ($01 = $35: KERNAL banked out, so it's RAM)
irq_vector:
		.addr	irq