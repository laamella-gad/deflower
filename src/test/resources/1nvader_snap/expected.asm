
*=$404b

l404B:
		jsr lC148
		lda #$94
		sta $50c0
		lda #$c4
		sta $50cf
		lda #$f2
		sta $50c2
		sta $50d1
		lda #$a0
		sta $50de
		lda #$92
		sta $50e0
		lda #$0b
		sta $50e7
		lda #$01
		sta $d01d
		sta $d017
		sta $50af
		jsr l490F
		lda #$07
		sta $d015
		jsr l4A8B
		jsr l4ABA
		lda $50de
		sta $d000
		lda $50e0
		sta $d001
		lda $50e2
		sta $d027
		jsr l4187
		jsr l4111
		jsr l4BD8
		lda #$00
		sta $50b3

l40A8:
		jsr snapshot_pc
		inc $50b7
		lda $50b7
		cmp #$04
		bne l40CE
		lda #$00
		sta $50b7
		ldx $50b3
		ldy #$00

l40BF:
		lda $5118, x
		sta $0658, y
		inx 
		iny 
		cpy #$28
		bne l40BF
		inc $50b3

l40CE:
		jsr l41CA
		jsr l43DA
		lda $50c4
		cmp #$01
		bne l40EB
		lda #$01
		sta $50c9
		lda #$ea
		sta $50c2
		jsr l4A8B
		jmp l4102

l40EB:
		jsr l4402
		lda $50d3
		cmp #$01
		bne l40A8
		lda #$01
		sta $50d8
		lda #$ea
		sta $50d1
		jsr l4ABA

l4102:
		lda #$20
		ldy #$00

l4106:
		sta $0658, y
		iny 
		cpy #$28
		bne l4106
		jmp l4379

l4111:
		ldx #$00

l4113:
		lda $5218, x
		sta $04f0, x
		inx 
		cpx #$f0
		bne l4113
		rts 

l411F:
		ldx #$00
		lda #$20

l4123:
		sta $04f0, x
		inx 
		cpx #$f0
		bne l4123
		rts 
*=$4187

l4187:
		ldx #$00
		ldy #$00

l418B:
		cpy #$00
		bne l4194
		lda #$06
		jmp l41BA

l4194:
		cpy #$01
		bne l419D
		lda #$0b
		jmp l41BA

l419D:
		cpy #$02
		bne l41A6
		lda #$0c
		jmp l41BA

l41A6:
		cpy #$03
		bne l41AF
		lda #$0f
		jmp l41BA

l41AF:
		cpy #$04
		bne l41B8
		lda #$01
		jmp l41BA

l41B8:
		lda #$04

l41BA:
		sta $d8f0, x
		iny 
		cpy #$06
		bne l41C4
		ldy #$00

l41C4:
		inx 
		cpx #$a0
		bne l418B
		rts 

l41CA:
		ldx #$00

l41CC:
		inc $d8f0, x
		inx 
		cpx #$f0
		bne l41CC
		rts 

l41D5:
		lda #$00
		sta $50ae
		sta $50c3
		sta $50c4
		sta $50d3
		sta $50c9
		sta $50d8
		sta $50df
		sta $50c1
		sta $50d0
		sta $50e7
		lda #$01
		sta $50d2
		sta $50e1
		sta $50e9
		sta $50eb
		sta $50af
		lda #$02
		sta $50e2
		lda #$0d
		sta $50c8
		lda #$0e
		sta $50d7
		lda #$94
		sta $50c0
		lda #$ac
		sta $50de
		lda #$c4
		sta $50cf
		lda #$f2
		sta $50c2
		sta $50d1
		rts 

l422D:
		sed 
		lda #$00
		sta $50c5
		sta $50c6
		sta $50c7
		sta $50d4
		sta $50d5
		sta $50d6
		cld 
		sed 
		lda #$80
		sta $50b8
		lda #$00
		sta $50b9
		cld 
		lda #$00
		sta $50ca
		sta $50d9
		lda #$01
		sta $50af
		jsr l490F
		lda #$02
		sta $50e3
		lda #$0a
		sta $50e5
		sta $50e6
		rts 

l426D:
		lda #$33
		sta $50b5
		sbc #$0f
		sta $04b3
		adc #$02
		sta $04b4
		lda #$1d
		sta $50b6

l4281:
		jsr l41CA
		dec $50b6
		lda $50b6
		cmp #$00
		bne l42A7
		lda #$1d
		sta $50b6
		dec $50b5
		lda $50b5
		cmp #$30
		beq l42EF
		sbc #$10
		sta $04b3
		adc #$02
		sta $04b4

l42A7:
		jsr snapshot_pc
		lda $50c9
		cmp #$01
		beq l42CB
		jsr l43DA
		inc $d028
		lda $50c4
		cmp #$01
		bne l42CB
		lda #$01
		sta $50c9
		lda #$ea
		sta $50c2
		jsr l4A8B

l42CB:
		lda $50d8
		cmp #$01
		beq l42EC
		jsr l4402
		inc $d029
		lda $50d3
		cmp #$01
		bne l42EC
		lda #$01
		sta $50d8
		lda #$ea
		sta $50d1
		jsr l4ABA

l42EC:
		jmp l4281

l42EF:
		lda #$47
		sta $04b3
		lda #$4f
		sta $04b4

l42F9:
		jsr l41CA
		jsr snapshot_pc
		dec $50e0
		dec $50e0
		lda $50e0
		sta $d001
		lda $50c9
		cmp #$01
		beq l431F
		lda $50c2
		cmp #$fa
		beq l431F
		inc $50c2
		jsr l4A8B

l431F:
		lda $50d8
		cmp #$01
		beq l4333
		lda $50d1
		cmp #$fa
		beq l4333
		inc $50d1
		jsr l4ABA

l4333:
		lda $50e0
		cmp #$20
		bne l42F9
		lda #$00
		sta $d01d
		sta $d017
		sta $50de
		sta $50c4
		sta $50d3
		sta $50ce
		sta $50dd
		sta $50e7
		ldx $50e7
		lda $50f5, x
		sta $50e0
		lda #$02
		sta $50e2
		jsr l4D63
		lda #$01
		sta $50af
		jsr l490F
		lda #$20
		sta $04b3
		sta $04b4
		jsr l411F
		rts 

l4379:
		jsr l422D
		jsr l426D

l437F:
		jsr snapshot_pc

; the return address on the stack, after the jsr to snapshot_pc's routine
caller:
		jsr l43A3
		jsr l442A
		jsr l48E8
		lda $50ae
		cmp #$01
		bne l437F
		jmp l4BE5

; where the CPU was when the snapshot was taken
snapshot_pc:
		lda $d012
		cmp #$fb
		bne snapshot_pc
		lda $d01e
		sta $50b0
		rts 

l43A3:
		lda $50c9
		cmp #$01
		bne l43BE
		lda $50ce
		cmp #$00
		beq l43BB
		lda $50cd
		sbc #$97
		bcc l43BB
		jmp l43BE

l43BB:
		jsr l43DA

l43BE:
		lda $50d8
		cmp #$01
		bne l43D9
		lda $50dd
		cmp #$00
		beq l43D6
		lda $50dc
		sbc #$97
		bcc l43D6
		jmp l43D9

l43D6:
		jsr l4402

l43D9:
		rts 

l43DA:
		lda $dc01
		and #$10
		cmp #$00
		beq l43E9
		lda #$00
		sta $50e9
		rts 

l43E9:
		lda $50e9
		cmp #$00
		bne l43FC
		lda #$01
		sta $50c4
		sta $50e9
		jsr l4F65
		rts 

l43FC:
		lda #$00
		sta $50c4
		rts 

l4402:
		lda $dc00
		and #$10
		cmp #$00
		beq l4411
		lda #$00
		sta $50eb
		rts 

l4411:
		lda $50eb
		cmp #$00
		bne l4424
		lda #$01
		sta $50d3
		sta $50eb
		jsr l4F8A
		rts 

l4424:
		lda #$00
		sta $50d3
		rts 

l442A:
		jsr l4451
		jsr l465A
		jsr l4698
		jsr l473E
		jsr l477E
		lda $50c9
		cmp #$01
		bne l4443
		jsr l47EF

l4443:
		lda $50d8
		cmp #$01
		bne l444D
		jsr l4864

l444D:
		jsr l48D9
		rts 

l4451:
		lda $50ce
		cmp #$00
		beq l445F
		cmp #$0c
		beq l446C
		jmp l44AE

l445F:
		lda #$00
		sta $50ce
		lda #$ca
		sta $07fb
		jmp l44B9

l446C:
		lda #$ca
		sta $07fb
		lda $50b0
		and #$09
		cmp #$09
		bne l44B9
		dec $50ce
		sed 
		clc 
		lda $50c5
		adc $50ac
		sta $50c5
		lda $50c6
		adc $50ad
		sta $50c6
		lda $50c7
		adc #$00
		sta $50c7
		sec 
		lda $50b8
		sbc #$01
		sta $50b8
		lda $50b9
		sbc #$00
		sta $50b9
		cld 
		jmp l45F1

l44AE:
		dec $50ce
		lda #$cb
		sta $07fb
		jmp l44B9

l44B9:
		lda $50dd
		cmp #$00
		beq l44C7
		cmp #$0c
		beq l44D4
		jmp l4516

l44C7:
		lda #$00
		sta $50dd
		lda #$ca
		sta $07fc
		jmp l4521

l44D4:
		lda #$ca
		sta $07fc
		lda $50b0
		and #$11
		cmp #$11
		bne l4521
		dec $50dd
		sed 
		clc 
		lda $50d4
		adc $50ac
		sta $50d4
		lda $50d5
		adc $50ad
		sta $50d5
		lda $50d6
		adc #$00
		sta $50d6
		sec 
		lda $50b8
		sbc #$01
		sta $50b8
		lda $50b9
		sbc #$00
		sta $50b9
		cld 
		jmp l45F1

l4516:
		dec $50dd
		lda #$cb
		sta $07fc
		jmp l4521

l4521:
		rts 
*=$45f1

l45F1:
		jsr l4FAF
		dec $50e6
		lda $50e6
		cmp #$00
		bne l4618
		inc $50e3
		lda $50e3
		cmp #$0a
		bne l4612
		lda #$02
		sta $50e3
		lda #$80
		sta $50b8

l4612:
		lda $50e5
		sta $50e6

l4618:
		lda #$01
		sta $50af
		sed 
		clc 
		lda $50e7
		sbc #$01
		sta $50e7
		cld 
		lda #$1e
		cmp $50e7
		bcs l4634
		lda #$00
		sta $50e7

l4634:
		jsr l4D63
		lda $50e1
		bne l464A
		sta $50de
		sta $50df
		lda #$01
		sta $50e1
		jmp l4659

l464A:
		lda #$01
		sta $50df
		lda #$59
		sta $50de
		lda #$00
		sta $50e1

l4659:
		rts 

l465A:
		lda $50ce
		cmp #$0c
		bne l4677
		lda $50cd
		sbc #$04
		sta $50cd
		cmp #$32
		bne l4677
		lda #$00
		sta $50ce
		lda #$ca
		sta $07fb

l4677:
		lda $50dd
		cmp #$0c
		bne l4697
		lda $50dc
		sbc #$04
		sta $50dc
		lda $50dc
		cmp #$32
		bne l4697
		lda #$00
		sta $50dd
		lda #$ca
		sta $07fc

l4697:
		rts 

l4698:
		lda $50e3
		sta $50e4

l469E:
		lda $50e4
		cmp #$00
		beq l46AE
		jsr l46AF
		dec $50e4
		jmp l469E

l46AE:
		rts 

l46AF:
		lda $50e1
		cmp #$00
		beq l46C1
		inc $50de
		bne l46DF
		inc $50df
		jmp l46DF

l46C1:
		lda $50df
		bne l46CC
		dec $50de
		jmp l46DF

l46CC:
		dec $50de
		lda $50de
		cmp #$ff
		beq l46D9
		jmp l46DF

l46D9:
		dec $50df
		jmp l46DF

l46DF:
		lda $50e1
		cmp #$00
		beq l470A
		lda $50df
		cmp #$00
		beq l473D
		lda $50de
		cmp #$59
		bne l473D
		lda #$00
		sta $50e1
		sed 
		clc 
		lda $50e7
		adc #$01
		sta $50e7
		cld 
		jsr l4D63
		jmp l472E

l470A:
		lda $50df
		cmp #$00
		bne l473D
		lda $50de
		cmp #$00
		bne l473D
		lda #$01
		sta $50e1
		sed 
		clc 
		lda $50e7
		adc #$01
		sta $50e7
		cld 
		jsr l4D63
		jmp l472E

l472E:
		lda $50e7
		cmp #$22
		bcs l4738
		jmp l473D

l4738:
		lda #$01
		sta $50ae

l473D:
		rts 

l473E:
		lda $50c9
		cmp #$01
		bne l477D
		lda $50d8
		cmp #$01
		bne l477D
		lda $50b0
		and #$06
		cmp #$06
		bne l477D
		lda $50c3
		cmp #$00
		bne l476D
		sta $50d2
		lda #$01
		sta $50c3
		sta $50ca
		sta $50d9
		jmp l477D

l476D:
		sta $50d2
		lda #$00
		sta $50c3
		lda #$01
		sta $50ca
		sta $50d9

l477D:
		rts 

l477E:
		lda $50c3
		cmp #$00
		beq l47A0
		lda $50c1
		cmp #$00
		beq l47B6
		lda $50c0
		cmp #$41
		bne l47B6
		lda #$00
		sta $50c3
		lda #$01
		sta $50ca
		jmp l47B6

l47A0:
		lda $50c1
		cmp #$00
		bne l47B6
		lda $50c0
		cmp #$18
		bne l47B6
		lda #$01
		sta $50c3
		sta $50ca

l47B6:
		lda $50d2
		cmp #$00
		beq l47D8
		lda $50d0
		cmp #$00
		beq l47EE
		lda $50cf
		cmp #$41
		bne l47EE
		lda #$00
		sta $50d2
		lda #$01
		sta $50d9
		jmp l47EE

l47D8:
		lda $50d0
		cmp #$00
		bne l47EE
		lda $50cf
		cmp #$18
		bne l47EE
		lda #$01
		sta $50d2
		sta $50d9

l47EE:
		rts 

l47EF:
		lda $50c4
		cmp #$01
		beq l47F9
		jmp l4830

l47F9:
		lda $50ca
		cmp #$01
		beq l4817
		lda $50c3
		cmp #$00
		beq l480F
		lda #$00
		sta $50c3
		jmp l4817

l480F:
		lda #$01
		sta $50c3
		jmp l4817

l4817:
		lda #$0c
		sta $50ce
		lda $50c0
		sta $50cb
		lda $50c1
		sta $50cc
		lda #$e2
		sta $50cd
		jmp l4830

l4830:
		lda $50c3
		cmp #$00
		beq l4842
		inc $50c0
		bne l4860
		inc $50c1
		jmp l4860

l4842:
		lda $50c1
		bne l484D
		dec $50c0
		jmp l4860

l484D:
		dec $50c0
		lda $50c0
		cmp #$ff
		beq l485A
		jmp l4860

l485A:
		dec $50c1
		jmp l4860

l4860:
		jmp l4863

l4863:
		rts 

l4864:
		lda $50d3
		cmp #$01
		beq l486E
		jmp l48A5

l486E:
		lda $50d9
		cmp #$01
		beq l488C
		lda $50d2
		cmp #$00
		beq l4884
		lda #$00
		sta $50d2
		jmp l488C

l4884:
		lda #$01
		sta $50d2
		jmp l488C

l488C:
		lda #$0c
		sta $50dd
		lda $50cf
		sta $50da
		lda $50d0
		sta $50db
		lda #$e2
		sta $50dc
		jmp l48A5

l48A5:
		lda $50d2
		cmp #$00
		beq l48B7
		inc $50cf
		bne l48D5
		inc $50d0
		jmp l48D5

l48B7:
		lda $50d0
		bne l48C2
		dec $50cf
		jmp l48D5

l48C2:
		dec $50cf
		lda $50cf
		cmp #$ff
		beq l48CF
		jmp l48D5

l48CF:
		dec $50d0
		jmp l48D5

l48D5:
		jmp l48D8

l48D8:
		rts 

l48D9:
		lda #$00
		sta $50c4
		sta $50d3
		sta $50ca
		sta $50d9
		rts 

l48E8:
		jsr l490F
		jsr l4B77
		jsr l4A59
		lda $50c9
		cmp #$01
		bne l48FE
		jsr l4A8B
		jsr l4AE9

l48FE:
		lda $50d8
		cmp #$01
		bne l490B
		jsr l4ABA
		jsr l4B30

l490B:
		jsr l5040
		rts 

l490F:
		lda $50af
		bne l4917
		jmp l4A58

l4917:
		lda #$00
		sta $50af
		lda #$20
		sta $040f
		sta $0418
		lda $50c5
		and #$0f
		clc 
		adc #$30
		sta $0406
		lda $50c5
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0405
		lda $50c6
		and #$0f
		clc 
		adc #$30
		sta $0404
		lda $50c6
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0403
		lda $50c7
		and #$0f
		clc 
		adc #$30
		sta $0402
		lda $50c7
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0401
		lda $50d4
		and #$0f
		clc 
		adc #$30
		sta $0426
		lda $50d4
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0425
		lda $50d5
		and #$0f
		clc 
		adc #$30
		sta $0424
		lda $50d5
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0423
		lda $50d6
		and #$0f
		clc 
		adc #$30
		sta $0422
		lda $50d6
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0421
		lda $50c7
		cmp $50ab
		bcc l49E2
		bne l49D0
		lda $50c6
		cmp $50aa
		bcc l49E2
		bne l49D0
		lda $50c5
		cmp $50a9
		bcc l49E2

l49D0:
		lda $50c5
		sta $50a9
		lda $50c6
		sta $50aa
		lda $50c7
		sta $50ab

l49E2:
		lda $50d6
		cmp $50ab
		bcc l4A10
		bne l49FE
		lda $50d5
		cmp $50aa
		bcc l4A10
		bne l49FE
		lda $50d4
		cmp $50a9
		bcc l4A10

l49FE:
		lda $50d4
		sta $50a9
		lda $50d5
		sta $50aa
		lda $50d6
		sta $50ab

l4A10:
		lda $50a9
		and #$0f
		clc 
		adc #$30
		sta $0416
		lda $50a9
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0415
		lda $50aa
		and #$0f
		clc 
		adc #$30
		sta $0414
		lda $50aa
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0413
		lda $50ab
		and #$0f
		clc 
		adc #$30
		sta $0412
		lda $50ab
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $0411

l4A58:
		rts 

l4A59:
		lda $50e2
		sta $d027
		ldy $50e7
		lda $50f5, y
		sta $d001
		lda $50df
		bne l4A7C
		lda $50de
		sta $d000
		lda $d010
		and #$fe
		sta $d010
		rts 

l4A7C:
		lda $50de
		sta $d000
		lda $d010
		ora #$01
		sta $d010
		rts 

l4A8B:
		lda $50c8
		sta $d028
		lda $50c2
		sta $d003
		lda $50c1
		bne l4AAB
		lda $50c0
		sta $d002
		lda $d010
		and #$fd
		sta $d010
		rts 

l4AAB:
		lda $50c0
		sta $d002
		lda $d010
		ora #$02
		sta $d010
		rts 

l4ABA:
		lda $50d7
		sta $d029
		lda $50d1
		sta $d005
		lda $50d0
		bne l4ADA
		lda $50cf
		sta $d004
		lda $d010
		and #$fb
		sta $d010
		rts 

l4ADA:
		lda $50cf
		sta $d004
		lda $d010
		ora #$04
		sta $d010
		rts 

l4AE9:
		lda $50ce
		cmp #$00
		beq l4B27
		lda $d015
		ora #$08
		sta $d015
		lda $50c8
		sta $d02a
		lda $50cd
		sta $d007
		lda $50cc
		bne l4B18
		lda $50cb
		sta $d006
		lda $d010
		and #$f7
		sta $d010
		rts 

l4B18:
		lda $50cb
		sta $d006
		lda $d010
		ora #$08
		sta $d010
		rts 

l4B27:
		lda $d015
		and #$f7
		sta $d015
		rts 

l4B30:
		lda $50dd
		cmp #$00
		beq l4B6E
		lda $d015
		ora #$10
		sta $d015
		lda $50d7
		sta $d02b
		lda $50dc
		sta $d009
		lda $50db
		bne l4B5F
		lda $50da
		sta $d008
		lda $d010
		and #$ef
		sta $d010
		rts 

l4B5F:
		lda $50da
		sta $d008
		lda $d010
		ora #$10
		sta $d010
		rts 

l4B6E:
		lda $d015
		and #$ef
		sta $d015
		rts 

l4B77:
		lda $50e7
		and #$0f
		clc 
		adc #$30
		sta $07d0
		lda $50e7
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $07cf
		lda $50ac
		and #$0f
		clc 
		adc #$30
		sta $07d5
		lda $50ac
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $07d4
		lda $50ad
		and #$0f
		clc 
		adc #$30
		sta $07d3
		lda $50ad
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $07d2
		lda $50b8
		and #$0f
		clc 
		adc #$30
		sta $07d8
		lda $50b8
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta $07d7
		rts 

l4BD8:
		lda #$20
		ldx #$0f

l4BDC:
		sta $07c0, x
		inx 
		cpx #$19
		bne l4BDC
		rts 

l4BE5:
		lda #$00
		sta $50ae

l4BEA:
		jsr snapshot_pc
		jsr l5040
		jsr l47EF
		jsr l4864
		jsr l4A8B
		jsr l4ABA
		jsr l465A
		jsr l4AE9
		jsr l4B30
		lda $50e3
		sta $50e4

l4C0B:
		lda $50ae
		cmp #$01
		beq l4C2E
		lda $50e4
		cmp #$00
		beq l4BEA
		jsr l46AF
		dec $50e4
		jsr l4CBF
		jsr l4A59
		jsr l4A8B
		jsr l4ABA
		jmp l4C0B

l4C2E:
		jsr l4187
		lda #$45
		sta $052a
		lda #$4f
		sta $052d
		jsr l4CB1
		lda #$4d
		sta $0529
		lda #$56
		sta $052e
		jsr l4CB1
		lda #$41
		sta $0528
		lda #$45
		sta $052f
		jsr l4CB1
		lda #$47
		sta $0527
		lda #$52
		sta $0530
		jsr l4CB1
		jsr l4CB1
		jsr l4CB1
		jsr l4CB1
		jsr l4CB1
		lda #$20
		sta $052a
		sta $052d
		jsr l4CB1
		lda #$20
		sta $0529
		sta $052e
		jsr l4CB1
		lda #$20
		sta $0528
		sta $052f
		jsr l4CB1
		lda #$20
		sta $0527
		sta $0530
		jsr l4CB1
		jsr l4CB1
		jsr l4CB1
		lda #$00
		sta $50ae
		sta $50c9
		sta $50d8
		jmp l404B

l4CB1:
		ldy #$06

l4CB3:
		jsr snapshot_pc
		cpy #$00
		beq l4CBE
		dey 
		jmp l4CB3

l4CBE:
		rts 

l4CBF:
		lda $50b0
		and #$03
		cmp #$03
		bne l4CF0
		lda $50e1
		sta $50c3
		jsr l47EF
		cmp #$00
		bne l4CF0
		lda $50c1
		cmp #$01
		beq l4CF0
		lda $50c0
		cmp #$0c
		bcc l4CE6
		jmp l4CF0

l4CE6:
		lda #$01
		sta $50c1
		lda #$49
		sta $50c0

l4CF0:
		lda $50b0
		and #$05
		cmp #$05
		bne l4D06
		lda $50e1
		sta $50d2
		jsr l4864
		cmp #$00
		bne l4D06

l4D06:
		rts 
*=$4d63

l4D63:
		lda #$00
		sta $50ac
		sta $50ad
		lda $50e7
		cmp #$00
		bne l4D7F
		lda #$00
		sta $50ac
		lda #$10
		sta $50ad
		jmp l4EDD

l4D7F:
		cmp #$01
		bne l4D90
		lda #$00
		sta $50ac
		lda #$05
		sta $50ad
		jmp l4EDD

l4D90:
		cmp #$02
		bne l4DA1
		lda #$75
		sta $50ac
		lda #$04
		sta $50ad
		jmp l4EDD

l4DA1:
		cmp #$03
		bne l4DB2
		lda #$50
		sta $50ac
		lda #$04
		sta $50ad
		jmp l4EDD

l4DB2:
		cmp #$04
		bne l4DC3
		lda #$25
		sta $50ac
		lda #$04
		sta $50ad
		jmp l4EDD

l4DC3:
		cmp #$05
		bne l4DD4
		lda #$00
		sta $50ac
		lda #$04
		sta $50ad
		jmp l4EDD

l4DD4:
		cmp #$06
		bne l4DE5
		lda #$75
		sta $50ac
		lda #$03
		sta $50ad
		jmp l4EDD

l4DE5:
		cmp #$07
		bne l4DF6
		lda #$50
		sta $50ac
		lda #$03
		sta $50ad
		jmp l4EDD

l4DF6:
		cmp #$08
		bne l4E07
		lda #$25
		sta $50ac
		lda #$03
		sta $50ad
		jmp l4EDD

l4E07:
		cmp #$09
		bne l4E18
		lda #$00
		sta $50ac
		lda #$03
		sta $50ad
		jmp l4EDD

l4E18:
		cmp #$10
		bne l4E29
		lda #$75
		sta $50ac
		lda #$02
		sta $50ad
		jmp l4EDD

l4E29:
		cmp #$11
		bne l4E3A
		lda #$50
		sta $50ac
		lda #$02
		sta $50ad
		jmp l4EDD

l4E3A:
		cmp #$12
		bne l4E4B
		lda #$25
		sta $50ac
		lda #$02
		sta $50ad
		jmp l4EDD

l4E4B:
		cmp #$13
		bne l4E5C
		lda #$00
		sta $50ac
		lda #$02
		sta $50ad
		jmp l4EDD

l4E5C:
		cmp #$14
		bne l4E6D
		lda #$75
		sta $50ac
		lda #$01
		sta $50ad
		jmp l4EDD

l4E6D:
		cmp #$15
		bne l4E7E
		lda #$50
		sta $50ac
		lda #$01
		sta $50ad
		jmp l4EDD

l4E7E:
		cmp #$16
		bne l4E8F
		lda #$25
		sta $50ac
		lda #$01
		sta $50ad
		jmp l4EDD

l4E8F:
		cmp #$17
		bne l4EA0
		lda #$00
		sta $50ac
		lda #$01
		sta $50ad
		jmp l4EDD

l4EA0:
		cmp #$18
		bne l4EB1
		lda #$75
		sta $50ac
		lda #$00
		sta $50ad
		jmp l4EDD

l4EB1:
		cmp #$19
		bne l4EC2
		lda #$50
		sta $50ac
		lda #$00
		sta $50ad
		jmp l4EDD

l4EC2:
		cmp #$20
		bne l4ED3
		lda #$25
		sta $50ac
		lda #$00
		sta $50ad
		jmp l4EDD

l4ED3:
		lda #$01
		sta $50ac
		lda #$00
		sta $50ad

l4EDD:
		rts 

l4EDE:
		lda $50ba
		sta $d405
		lda $50bb
		sta $d406
		lda $50bc
		sta $d418
		lda $50bd
		sta $d400
		lda $50be
		sta $d401
		ldx $50bf
		inx 
		txa 
		sta $d404
		rts 

l4F05:
		lda $50ba
		sta $d40c
		lda $50bb
		sta $d40d
		lda $50bc
		sta $d418
		lda $50bd
		sta $d407
		lda $50be
		sta $d408
		ldx $50bf
		inx 
		txa 
		sta $d40b
		rts 

l4F2C:
		lda $50ba
		sta $d413
		lda $50bb
		sta $d414
		lda $50bc
		sta $d418
		lda $50bd
		sta $d40e
		lda $50be
		sta $d40f
		ldx $50bf
		inx 
		txa 
		sta $d412
		rts 

l4F53:
		lda #$00
		sta $d404
		rts 

l4F59:
		lda #$00
		sta $d40b
		rts 

l4F5F:
		lda #$00
		sta $d412
		rts 

l4F65:
		jsr l4F53
		lda #$09
		sta $50ba
		lda #$00
		sta $50bb
		lda #$0f
		sta $50bc
		lda #$0c
		sta $50bd
		lda #$08
		sta $50be
		lda #$20
		sta $50bf
		jsr l4EDE
		rts 

l4F8A:
		jsr l4F59
		lda #$09
		sta $50ba
		lda #$00
		sta $50bb
		lda #$0f
		sta $50bc
		lda #$0d
		sta $50bd
		lda #$09
		sta $50be
		lda #$20
		sta $50bf
		jsr l4F05
		rts 

l4FAF:
		jsr l4F5F
		lda #$19
		sta $50ba
		lda #$00
		sta $50bb
		lda #$0f
		sta $50bc
		lda #$01
		sta $50bd
		lda #$10
		sta $50be
		lda #$80
		sta $50bf
		jsr l4F2C
		rts 
*=$5040

l5040:
		inc $50f4
		lda $50f4
		cmp #$06
		bne l504F
		lda #$00
		sta $50f4

l504F:
		ldx $50f4
		ldy $50ec, x
		txa 
		and #$01
		cmp #$00
		bne l507A
		lda $0428, y
		cmp #$2a
		bne l5068
		lda #$20
		sta $0428, y

l5068:
		jsr l509D
		lda $0428, y
		cmp #$20
		bne l5095
		lda #$2a
		sta $0428, y
		jmp l5095

l507A:
		lda $0530, y
		cmp #$2a
		bne l5086
		lda #$20
		sta $0530, y

l5086:
		jsr l509D
		lda $0530, y
		cmp #$20
		bne l5095
		lda #$2a
		sta $0530, y

l5095:
		tya 
		sta $50ec, x
		jmp l509C

l509C:
		rts 

l509D:
		tya 
		beq l50A5
		asl 
		beq l50A5
		bcc l50A7

l50A5:
		eor #$1d

l50A7:
		tay 
		rts 
*=$c148

lC148:
		ldx #$02

lC14A:
		lda $c213, x
		cmp $50a9, x
		bne lC158
		dex 
		bpl lC14A
		jmp lC1B4

lC158:
		lda #$00
		sta $9d
		lda $d418
		sta $c1b7
		lda #$00
		sta $d418
		lda #$0f
		tay 
		ldx $ba
		cpx #$08
		bpl lC172
		ldx #$08

lC172:
		jsr lFFBA
		lda #$0b
		ldx #$b8
		ldy #$c1
		jsr lFFBD
		jsr lFFC0
		lda #$0f
		jsr lFFC3
		ldy #$00
		tya 
		ldx $ba
		cpx #$08
		bpl lC191
		ldx #$08

lC191:
		jsr lFFBA
		lda #$09
		ldx #$ba
		ldy #$c1
		jsr lFFBD
		ldx #$a9
		ldy #$50
		stx $c1
		sty $c2
		lda #$c1
		ldx #$ac
		ldy #$50
		jsr lFFD8
		lda $c1b7
		sta $d418

lC1B4:
		jmp l41D5
*=$ffba

lFFBA:
		brk 
*=$ffbd

lFFBD:
		brk 
*=$ffc0

lFFC0:
		isc @w $00ff, x

lFFC3:
		brk 
*=$ffd8

lFFD8:
		isc @w $00ff, x
		brk 