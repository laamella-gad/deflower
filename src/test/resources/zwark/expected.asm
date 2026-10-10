
.virtual $0400
vic_screen:
		.fill	1000
.endv

.virtual $07f8
sprite_pointers:
		.fill	8
.endv

*=$9000

start_game:
		jmp actual_start_game
*=$9009

actual_start_game:
		jsr l9CD5
		lda #$fe
		bne l901A

main_loop:
		jsr lFFE1
		bne l901D
		beq actual_start_game
		jsr l9541

l901A:
		jsr l999A

l901D:
		lda vic_joystick1
		sta joystick_state
		lda vic_sprite_coll
		sta sprite_coll_state
		jsr l9773
		jsr l91C4
		sta $9049
		jsr l9226
		jsr l9570
		jsr update_vic_sprite_positions
		jsr l978B
		jsr l9563
		lda $9049
		bne l901A
		clc 
		bcc main_loop
		brk 

player_sprite:
		.byte	$00, $30, $00, $00, $30, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00
		.byte	$fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc
		.byte	$00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00
		.byte	$15, $55, $50, $55, $55, $54, $00, $a8, $00, $00, $a8, $00, $02, $aa, $00
bullet_sprite:
		.byte	$00, $00, $00, $00, $30, $00, $00, $fc, $00, $00, $30, $00, $00, $48, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
enemy_sprite:
		.byte	$02, $00, $20, $00, $80, $80, $00, $2a, $00, $08, $b3, $88, $22, $88, $a2, $2f
		.byte	$ea, $fe, $2f, $e2, $fe, $2f, $80, $be, $08, $80, $88, $08, $80, $88, $08, $22
		.byte	$08, $08, $22, $08, $02, $22, $20, $02, $22, $20, $08, $22, $08, $08, $80, $88
		.byte	$20, $00, $02, $20, $00, $02, $20, $00, $02, $20, $00, $02, $20, $00, $02
explosion_sprite_1:
		.byte	$00, $00, $00, $00, $00, $00, $00, $8c, $00, $03, $00, $88, $08, $10, $50, $80
		.byte	$0d, $00, $03, $10, $20, $00, $a6, $00, $04, $52, $00, $10, $66, $d0, $02, $4c
		.byte	$26, $00, $23, $20, $00, $24, $10, $20, $6c, $40, $08, $00, $00, $01, $02, $00
		.byte	$00, $41, $40, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00
explosion_sprite_2:
		.byte	$00, $04, $00, $04, $00, $00, $30, $8c, $02, $0b, $00, $88, $04, $10, $50, $80
		.byte	$0d, $00, $03, $10, $20, $00, $84, $04, $04, $52, $00, $10, $44, $d0, $02, $40
		.byte	$26, $0b, $02, $28, $00, $24, $10, $20, $0c, $40, $08, $00, $04, $01, $12, $10
		.byte	$10, $41, $42, $00, $22, $04, $10, $10, $00, $04, $41, $00, $00, $04, $00
explosion_sprite_3:
		.byte	$04, $08, $20, $30, $83, $01, $00, $00, $40, $0b, $00, $04, $20, $10, $50, $80
		.byte	$0d, $00, $08, $10, $04, $00, $84, $01, $48, $00, $00, $20, $00, $34, $02, $00
		.byte	$43, $8b, $02, $0a, $00, $44, $08, $20, $0c, $00, $08, $00, $44, $01, $12, $00
		.byte	$10, $41, $09, $00, $22, $20, $10, $10, $02, $04, $41, $00, $00, $04, $00

l91C4:
		lda #$01
		jsr l94FD
		lda $9d98
		jsr l93D8
		bne check_joystick
		lda $9d98
		jsr l92FA
		bne l9223
		ldx $9d8c

d91DC:
		dec $9d8a, x
		bmi l91FD
		ldx #$00
		lda init_sprite_coords, x
		sta sprite_ptrs, x
		inx 
		lda init_sprite_coords, x
		sta sprite_ptrs, x
		lda #$fe
		and sprite_x_high_bits
		sta sprite_x_high_bits
		lda #$01
		clc 
		bcc l9225

l91FD:
		lda #$ff
		bne l9225

check_joystick:
		ldx #$01
		ldy #$00

check_right:
		lda #$08
		bit joystick_state
		bne check_left
		lda $9d98
		jsr l93F9
		ldx #$01
		ldy #$00

check_left:
		lda #$04
		bit joystick_state
		bne l9223
		lda $9d98
		jsr l944D

l9223:
		lda #$00

l9225:
		rts 

l9226:
		lda #$02
		jsr l94FD
		lda $9d98
		jsr l93D8
		bne l9240
		lda #$01
		eor #$ff
		and $9d87
		sta $9d87
		clc 
		bcc l92B6

l9240:
		lda #$01
		bit $9d87
		bne l9286
		lda #$10
		bit joystick_state
		bne l92AE

fire_pressed:
		lda #$02
		bit $9d87
		beq l92B6
		lda #$01
		jsr l94FD
		lda #$01
		jsr l93D8
		sta $92f9
		lda #$02
		jsr l94FD
		lda $92f9
		beq l92B6
		ora $9d87
		lda #$01
		ora $9d87
		sta $9d87
		lda #$02
		eor #$ff
		and $9d87
		sta $9d87
		lda #$01
		jsr l989C

l9286:
		lda #$02
		ora $9d5b
		sta $9d5b
		lda $9d98
		ldx #$ff
		ldy #$02
		jsr l9486
		lda #$02
		jsr l989C
		cpy #$0a
		bcs l92F8
		lda #$01
		eor #$ff
		and $9d87
		sta $9d87
		clc 
		bcc l92F8

l92AE:
		lda #$02
		ora $9d87
		sta $9d87

l92B6:
		lda #$fd
		and $9d5b
		sta $9d5b
		ldx #$00
		lda sprite_ptrs, x
		ldx #$02
		sta sprite_ptrs, x
		dex 
		ldy sprite_ptrs, x
		dey 
		dey 
		dey 
		dey 
		tya 
		ldx #$03
		sta sprite_ptrs, x
		lda #$ff
		jsr l989C
		lda #$01
		bit sprite_x_high_bits
		bne l92EA
		lda #$fd
		and sprite_x_high_bits
		clc 
		bcc l92EF

l92EA:
		lda #$02
		ora sprite_x_high_bits

l92EF:
		sta sprite_x_high_bits
		clc 
		bcc l92F8
		inc $9d9d

l92F8:
		rts 
*=$92fa

l92FA:
		ldx $9d99
		lda $9d98
		bit $9d86
		bne l9345
		ora $9d86
		sta $9d86
		lda #$00
		sta $9d7e, x
		lda #$01
		sta init_sprite_ptrs + $8, x
		ldx #$01
		lda #$01
		bit $9d98
		bne l9345

l931E:
		ldy $9d8c
		lda $9d8d, y
		clc 
		sed 
		adc #$01
		sta $9d8d, y
		bcc l9338
		lda $9d8f, y
		clc 
		adc #$01
		sta $9d8f, y
		bcc l9338

l9338:
		cld 
		cpx #$01
		bne l9345
		inx 
		lda #$f8
		bit $9d86
		bne l931E

l9345:
		lda #$05
		jsr l989C
		dec init_sprite_ptrs + $8, x
		beq l9352
		jmp l93D5

l9352:
		inc $9d7e, x
		lda $9d7e, x
		cmp #$01
		bne l9365
		lda sprite_pointers, x
		ldx #$07
		ldy #$91
		bne l93CA

l9365:
		cmp #$02
		bne l9372
		lda sprite_pointers, x
		ldx #$46
		ldy #$91
		bne l93CA

l9372:
		cmp #$03
		bne l937F
		lda sprite_pointers, x
		ldx #$85
		ldy #$91
		bne l93CA

l937F:
		lda $9d98
		eor $9d86
		sta $9d86
		ldx $9d99
		lda $9d2a, x
		sta $9d97
		ldy $9d32, x
		lda sprite_pointers, x
		ldx $9d97
		jsr l94DE
		lda #$fe
		jsr l989C
		lda #$03
		and $9d98
		bne l93C0
		ldy $9d8c
		lda #$0f
		and $9d8d, y
		bne l93C0
		ldx $9d99

flash_sprite:
		inc vic_sprite_colors, x
		lda vic_sprite_colors, x
		and #$0f
		beq flash_sprite

l93C0:
		lda vic_sprite_coll
		lda #$00
		sta vic_sprite_coll
		beq l93D7

l93CA:
		jsr l94DE
		ldx $9d99
		lda #$1e
		sta init_sprite_ptrs + $8, x

l93D5:
		lda #$01

l93D7:
		rts 

l93D8:
		bit $9d86
		bne l93F6
		bit sprite_coll_state
		beq l93F2
		lda #$fc
		bit sprite_coll_state
		beq l93F2
		lda #$03
		bit sprite_coll_state
		bne l93F6
		beq l93F2

l93F2:
		lda #$ff
		bne l93F8

l93F6:
		lda #$00

l93F8:
		rts 

l93F9:
		cpx #$00
		beq l942F
		dex 
		stx $9d9c
		ldx $9d9a
		lda sprite_ptrs, x
		cpy #$ff
		beq l9417
		cmp #$3c
		bcc l9417
		lda $9d98
		bit sprite_x_high_bits
		bne l942B

l9417:
		inc sprite_ptrs, x
		bne l9425
		lda $9d98
		ora sprite_x_high_bits
		sta sprite_x_high_bits

l9425:
		ldx $9d9c
		clc 
		bcc l93F9

l942B:
		lda #$01
		bne l9431

l942F:
		lda #$00

l9431:
		sta $9d9b
		lda $9d98
		bit sprite_x_high_bits
		beq l9440
		ldy #$01
		bne l9442

l9440:
		ldy #$00

l9442:
		ldx $9d9a
		lda sprite_ptrs, x
		tax 
		lda $9d9b
		rts 

l944D:
		cpx #$00
		beq l942F
		dex 
		stx $9d9c
		ldx $9d9a
		lda sprite_ptrs, x
		cpy #$ff
		beq l946B
		cmp #$17
		bcs l946B
		lda $9d98
		bit sprite_x_high_bits
		beq l942B

l946B:
		dec sprite_ptrs, x
		lda #$ff
		cmp sprite_ptrs, x
		bne l9480
		lda $9d98
		eor #$ff
		and sprite_x_high_bits
		sta sprite_x_high_bits

l9480:
		ldx $9d9c
		clc 
		bcc l944D

l9486:
		cpy #$00
		beq l94AB
		dey 
		stx $9d9c
		txa 
		ldx $9d9a
		inx 
		cmp #$ff
		beq l949E
		lda sprite_ptrs, x
		cmp #$32
		bcc l94A7

l949E:
		dec sprite_ptrs, x
		ldx $9d9c
		clc 
		bcc l9486

l94A7:
		lda #$01
		bne l94AD

l94AB:
		lda #$00

l94AD:
		sta $9d9b
		ldx $9d9a
		inx 
		ldy sprite_ptrs, x
		ldx #$00
		lda $9d9b
		rts 

l94BD:
		cpy #$00
		beq l94AB
		dey 
		stx $9d9c
		txa 
		ldx $9d9a
		inx 
		cmp #$ff
		beq l94D5
		lda sprite_ptrs, x
		cmp #$fa
		bcs l94A7

l94D5:
		inc sprite_ptrs, x
		ldx $9d9c
		clc 
		bcc l94BD

l94DE:
		stx $57
		sty $58
		sta $59
		lda #$00
		sta $5a
		ldx #$06

l94EA:
		asl $59
		rol $5a
		dex 
		bne l94EA
		ldy #$00

l94F3:
		lda ($57), y
		sta ($59), y
		iny 
		cpy #$40
		bcc l94F3
		rts 

l94FD:
		cmp #$00
		beq l951B
		sta $9d98
		ldx #$00

l9506:
		lsr 
		bcs l9510
		inx 
		cpx #$08
		bcc l9506
		bcs l951B

l9510:
		stx $9d99
		txa 
		asl 
		sta $9d9a
		clc 
		bcc l9526

l951B:
		lda #$00
		sta $9d99
		sta $9d9a
		sta $9d98

l9526:
		lda $9d98
		ldx $9d99
		ldy $9d9a
		rts 
*=$9541

l9541:
		pha 
		lda #$00
		sta sid_vol_filter
		pla 
		rts 

update_vic_sprite_positions:
		lda sprite_x_high_bits
		sta vic_sprite_x_high_bits
		ldx #$00

l9551:
		lda sprite_ptrs, x
		sta vic_sprite_coords, x
		inx 
		cpx #$10
		bcc l9551
		lda $9d5b
		sta vic_sprite_enable
		rts 

l9563:
		ldy $9d94

l9566:
		ldx $9d95

l9569:
		dex 
		bne l9569
		dey 
		bne l9566
		rts 

l9570:
		lda #$04

l9572:
		jsr l94FD
		lda $9d98
		jsr l93D8
		bne l95B8
		lda $9d98
		jsr l92FA
		beq l9588
		jmp l960F

l9588:
		ldx $9d9a
		inx 
		lda #$28
		sta sprite_ptrs, x
		ldx $9d99
		lda table_with_timed_stuff, x
		ldx $9d9a
		sta sprite_ptrs, x
		cmp #$17
		bcc l95AF
		lda $9d98
		eor #$ff
		and sprite_x_high_bits
		sta sprite_x_high_bits
		jmp l95B8

l95AF:
		lda $9d98
		ora sprite_x_high_bits
		sta sprite_x_high_bits

l95B8:
		ldx $9d99
		cpx #$02
		bne l95D9
		lda #$80
		and table_with_timed_stuff, x
		beq l95D1
		lda #$7f
		and table_with_timed_stuff, x
		sta table_with_timed_stuff, x
		clc 
		bcc l960F

l95D1:
		lda #$80
		ora table_with_timed_stuff, x
		sta table_with_timed_stuff, x

l95D9:
		lda #$02
		and table_with_timed_stuff, x
		beq l95EA
		lda $9d98
		ldy #$01
		ldx #$ff
		jsr l94BD

l95EA:
		lda #$08
		and table_with_timed_stuff, x
		beq l95FB
		lda $9d98
		ldx #$01
		ldy #$00
		jsr l93F9

l95FB:
		ldx $9d99
		lda #$04
		and table_with_timed_stuff, x
		beq l960F
		lda $9d98
		ldx #$01
		ldy #$00
		jsr l944D

l960F:
		lda #$04
		cmp $9d98
		bcc l963A
		asl 
		bit $9d5b
		bne l9635
		ldy $9d8c
		lda $9d8f, y
		cmp #$01
		bcs l962D
		lda $9d8d, y
		cmp #$15
		bcc l963A

l962D:
		lda #$08
		ora $9d5b
		sta $9d5b

l9635:
		lda #$08
		jmp l9572

l963A:
		lda #$08
		cmp $9d98
		bcc l9665
		asl 
		bit $9d5b
		bne l9660
		ldy $9d8c
		lda $9d8f, y
		cmp #$01
		bcs l9658
		lda $9d8d, y
		cmp #$40
		bcc l96B4

l9658:
		lda #$10
		ora $9d5b
		sta $9d5b

l9660:
		lda #$10
		jmp l9572

l9665:
		lda #$10
		cmp $9d98
		bcc l9690
		asl 
		bit $9d5b
		bne l968B
		ldy $9d8c
		lda $9d8f, y
		cmp #$01
		bcs l9683
		lda $9d8d, y
		cmp #$80
		bcc l96B4

l9683:
		lda #$20
		ora $9d5b
		sta $9d5b

l968B:
		lda #$20
		jmp l9572

l9690:
		lda #$20
		cmp $9d98
		bcc l96B4
		asl 
		bit $9d5b
		bne l96AF
		ldy $9d8c
		lda $9d8f, y
		cmp #$01
		bcc l96B4
		lda #$40
		ora $9d5b
		sta $9d5b

l96AF:
		lda #$40
		jmp l9572

l96B4:
		rts 

l96B5:
		jsr lE544
		lda #$4c
		sta $73
		lda #$09
		sta $74
		lda #$90
		sta $75
		ldx #$00

l96C6:
		lda init_sprite_ptrs, x
		sta sprite_pointers, x
		inx 
		cpx #$08
		bcc l96C6
		ldx #$00

l96D3:
		lda $9d2a, x
		sta $9d96
		ldy $9d32, x
		lda init_sprite_ptrs, x
		stx $9d97
		ldx $9d96
		jsr l94DE
		ldx $9d97
		inx 
		cpx #$07
		bcc l96D3
		ldx #$00

l96F2:
		lda init_sprite_coords, x
		sta vic_sprite_coords, x
		cpx #$10
		bcs l96FF
		sta sprite_ptrs, x

l96FF:
		inx 
		cpx #$2f
		bcc l96F2
		lda #$32
		sta $9d94
		lda #$0a
		sta $9d95
		lda #$00
		ldx #$00

l9712:
		sta init_sprite_ptrs + $8, x
		inx 
		cpx #$08
		bcc l9712
		sta $9d8d
		sta $9d8e
		sta $9d8f
		sta $9d90
		sta $9d8c
		sta $9d87
		sta $9d86
		sta sprite_x_high_bits
		lda #$04
		sta $9d8a
		sta $9d8b
		jsr draw_turns
		jsr l978B
		lda $9db9
		sta $9d5b
		ldx #$00
		sta $9d6c, x
		inx 
		sta $9d6c, x
		lda #$00
		ldx #$15

sid_clear_loop:
		dex 
		sta sid_base, x
		bne sid_clear_loop
		lda #$0f
		sta sid_vol_filter
		ldx #$00
		ldy #$00

l9762:
		lda $9dcb, x
		sta $9d5c, y
		iny 
		sta $9d5c, y
		iny 
		inx 
		cpx #$08
		bcc l9762
		rts 

l9773:
		ldx #$00

l9775:
		dec table_with_timers, x
		bne l9785
		lda vic_timer_a
		sta table_with_timed_stuff, x
		lda #$32
		sta table_with_timers, x

l9785:
		inx 
		cpx #$08
		bcc l9775
		rts 

l978B:
		lda #$00
		sta $9d9f
		lda #$02
		sta $9da0

l9795:
		ldy $9d9f
		lda $9d8f, y
		jsr l9D0D
		txa 
		cmp #$30
		bne l97A5
		lda #$20

l97A5:
		ldy $9da0
		sta vic_screen + $28, y
		ldy $9d9f
		lda $9d8d, y
		jsr l9D0D
		stx $9d9e
		tya 
		cmp #$30
		bne l97C8
		ldx $9d9f
		ldy $9d8f, x
		cpy #$00
		bne l97C8
		lda #$20

l97C8:
		ldy $9da0
		iny 
		sta vic_screen + $28, y
		iny 
		lda $9d9e
		sta vic_screen + $28, y
		iny 
		lda #$30
		sta vic_screen + $28, y
		iny 
		sta vic_screen + $28, y
		ldx $9d8c
		lda $9d8a, x
		clc 
		adc #$30
		ldx #$06
		sta vic_screen + $96, x
		lda $9d9f
		bne l97FF
		lda #$01
		sta $9d9f
		lda #$20
		sta $9da0
		bne l9795

l97FF:
		jsr l993C
		rts 

draw_turns:
		ldx #$00

l9805:
		lda turns_text, x
		and #$bf
		sta vic_screen + $96, x
		lda #$06
		sta vic_color_ram + $96, x
		inx 
		cpx #$07
		bcc l9805
		ldx #$00

show_top_score_line:
		lda top_score_line, x
		and #$bf
		sta vic_screen, x
		lda #$08
		sta vic_color_ram, x
		inx 
		cpx #$28
		bcc show_top_score_line
		ldx #$00

show_copyright:
		lda robert_copyright, x
		sta vic_screen + $3c0, x
		lda #$06
		sta vic_color_ram + $3c0, x
		inx 
		cpx #$21
		bcc show_copyright
		ldx #$00
		lda #$02

make_scores_red:
		sta vic_color_ram + $28, x
		inx 
		cpx #$28
		bcc make_scores_red
		rts 

robert_copyright:
		.enc	"screen"
		.text	"ZWARK  (C) 1982  ROBERT WENTWORT"
		.text	"H "
top_score_line:
		.enc	"none"
		.text	"PLAYER.ONE.....HIGH.SCORE.....PL"
		.text	"AYER.TWO"
turns_text:
		.text	"TURNS=  "

l989C:
		cmp #$ff
		beq l98F6
		cmp #$01
		bne l98DA
		lda $9dd5
		sta $9dd7
		sta $d401
		sta $d408
		lda $9dd6
		sta $9dd8
		sta sid_base
		sta $d407
		lda $9dd3
		sta $d405
		sta $d40c
		lda $9dd4
		sta $d406
		sta $d40d
		lda #$81
		sta $d404
		lda #$11
		sta $d40b
		bne l993B

l98DA:
		cmp #$02
		bne l98FE
		dec $9dd7
		lda $9dd7
		sta $d401
		sta $d408
		lda $9dd8
		sta sid_base
		sta $d407
		clc 
		bcc l993B

l98F6:
		lda #$00
		sta $d40b
		sta $d404

l98FE:
		cmp #$05
		bne l9932
		lda vic_timer_a
		lsr 
		sta $d410
		sta $d401
		lsr 
		sta $d40f
		sta $d401
		lda $9dd9
		sta $d413
		sta $d405
		lda $9dda
		sta $d414
		sta $d406
		lda #$11
		sta $d412
		lda #$81
		sta $d404
		clc 
		bcc l993B

l9932:
		cmp #$fe
		bne l993B
		lda #$00
		sta $d412

l993B:
		rts 

l993C:
		ldx $9d8c
		lda $9d8f, x
		cmp $9d92
		bcc l995F
		bne l9953
		lda $9d8d, x
		cmp $9d91
		bcc l995F
		beq l995F

l9953:
		lda $9d8d, x
		sta $9d91
		lda $9d8f, x
		sta $9d92

l995F:
		lda $9d92
		jsr l9D0D
		txa 
		cmp #$30
		bne l996C
		lda #$20

l996C:
		ldy #$11
		sta vic_screen + $28, y
		lda $9d91
		jsr l9D0D
		tya 
		cmp #$30
		bne hi_score_draw
		ldy $9d92
		cpy #$00
		bne hi_score_draw
		lda #$20

hi_score_draw:
		ldy #$12
		sta vic_screen + $28, y
		iny 
		txa 
		sta vic_screen + $28, y
		iny 
		lda #$30
		sta vic_screen + $28, y
		iny 
		sta vic_screen + $28, y
		rts 

l999A:
		ldx #$00
		stx sid_vol_filter
		cmp #$fe
		bcc l99F7
		bne l99AB
		jsr l96B5
		jmp l99BA

l99AB:
		jsr l9ADF
		lda $9d93
		beq l99BA
		lda $9d8c
		cmp #$00
		beq l99EB

l99BA:
		jsr draw_logo

l99BD:
		ldx #$00
		stx $9da2
		ldx #$0a
		stx $9da3
		bne l99CC

l99C9:
		jsr lFFE4

l99CC:
		cmp #$0d
		beq l9A47
		cmp #$85
		beq l9A3B
		cmp #$86
		beq l9A42
		jsr l9563
		dec $9da2
		bne l99C9
		dec $9da3
		bne l99C9
		jsr l9A4B
		jmp l99BD

l99EB:
		ldx #$00
		lda #$20

l99EF:
		sta vic_screen + $1e0, x
		inx 
		cpx #$28
		bcc l99EF

l99F7:
		jsr l9B4D
		jsr l978B
		jsr l9AF7
		lda #$f0
		sta $9d94
		sta $9d95
		jsr l9563
		lda #$32
		sta $9d94
		lda #$0a
		sta $9d95
		lda #$20
		ldx #$00

l9A19:
		sta vic_screen + $1e0, x
		sta vic_screen + $230, x
		inx 
		cpx #$28
		bcc l9A19
		ldx #$0f
		stx sid_vol_filter
		lda vic_sprite_coll
		lda #$00
		sta sprite_coll_state
		sta $d404
		sta $d40b
		sta $d412
		rts 

l9A3B:
		lda #$00
		sta $9d93
		beq l9A47

l9A42:
		lda #$01
		sta $9d93

l9A47:
		jsr l96B5
		rts 

l9A4B:
		jsr l96B5
		jsr draw_logo
		lda #$1d
		sta $9d5b
		lda #$06
		sta vic_sprite_colors + $3
		lda #$0c
		sta vic_sprite_colors + $4
		lda #$0e
		sta $9d95

l9A65:
		jsr lFFE1
		beq l9AA4
		jsr lFFE4
		cmp #$0d
		beq l9AA4
		cmp #$85
		beq l9AA4
		cmp #$86
		beq l9AA4
		lda table_with_timed_stuff
		eor #$08
		sta joystick_state
		lda vic_sprite_coll
		sta sprite_coll_state
		jsr l9773
		jsr l91C4
		sta $9049
		jsr l9226
		jsr l9570
		jsr update_vic_sprite_positions
		jsr l9563
		lda $9049
		bne l9AA4
		clc 
		bcc l9A65

l9AA4:
		ldx #$00
		stx sid_vol_filter
		ldx #$1d
		stx vic_sprite_enable
		stx $9d5b
		ldx #$0a
		stx $9d95
		rts 

f1_1_player_text:
		.enc	"screen"
		.text	"F1 - SINGLE PLAYER  "
f3_2_player_text:
		.text	"F3 - TWO PLAYER GAME"

l9ADF:
		ldx #$00
		ldy #$0f

l9AE3:
		lda game_over_text, x
		lda game_over_text, x
		sta vic_screen + $1e0, y
		lda #$08
		sta vic_color_ram + $1e0, y
		inx 
		iny 
		cpx #$09
		bcc l9AE3

l9AF7:
		ldx #$00
		ldy #$0f
		lda $9d8c
		beq show_top_score_row_14
		ldx #$1e

show_top_score_row_14:
		lda top_score_line, x
		and #$bf
		sta vic_screen + $230, y
		lda #$08
		sta vic_color_ram + $230, y
		iny 
		inx 
		cpy #$19
		bcc show_top_score_row_14
		lda #$ff
		sta $9b41
		sta $9d94

l9B1D:
		jsr l9563
		jsr lFFE1
		beq l9B40
		jsr lFFE4
		cmp #$0d
		beq l9B40
		cmp #$85
		beq l9B40
		cmp #$86
		beq l9B40
		dec $9b41
		bne l9B1D
		lda #$32
		sta $9d94
		lda #$01

l9B40:
		rts 
*=$9b42

game_over_text:
		.text	"GAME OVER  "

l9B4D:
		lda $9d93
		beq l9B89
		ldx $9d8c
		lda $9d5b
		sta $9d6c, x
		ldy #$00

l9B5D:
		lda vic_sprite_colors, y
		sta $9d5c, x
		inx 
		inx 
		iny 
		cpy #$08
		bcc l9B5D
		lda #$01
		sec 
		sbc $9d8c
		sta $9d8c
		tax 
		lda $9d6c, x
		sta $9d5b
		ldy #$00

l9B7C:
		lda $9d5c, x
		sta vic_sprite_colors, y
		inx 
		inx 
		iny 
		cpy #$08
		bcc l9B7C

l9B89:
		ldx #$00

l9B8B:
		lda init_sprite_coords, x
		sta sprite_ptrs, x
		inx 
		cpx #$10
		bcc l9B8B
		lda #$00
		sta sprite_x_high_bits
		sta $9d86
		sta $9d87
		ldx #$00

l9BA3:
		lda $9d2a, x
		sta $9d96
		ldy $9d32, x
		lda init_sprite_ptrs, x
		stx $9d97
		ldx $9d96
		jsr l94DE
		ldx $9d97
		inx 
		cpx #$07
		bcc l9BA3
		lda $9d5b
		and #$fd
		sta $9d5b
		jsr update_vic_sprite_positions
		rts 

draw_logo:
		ldx #$00

l9BCE:
		lda logo0, x
		sta vic_screen + $c8, x
		lda #$06
		sta vic_color_ram + $c8, x
		inx 
		cpx #$1c
		bcc l9BCE
		ldx #$00

l9BE0:
		lda logo1, x
		sta vic_screen + $f0, x
		lda #$06
		sta vic_color_ram + $f0, x
		inx 
		cpx #$1c
		bcc l9BE0
		ldx #$00

l9BF2:
		lda logo2, x
		sta vic_screen + $118, x
		lda #$06
		sta vic_color_ram + $118, x
		inx 
		cpx #$1c
		bcc l9BF2
		ldx #$00

l9C04:
		lda logo3, x
		sta vic_screen + $140, x
		lda #$06
		sta vic_color_ram + $140, x
		inx 
		cpx #$1c
		bcc l9C04
		ldx #$00

l9C16:
		lda logo4, x
		sta vic_screen + $168, x
		lda #$06
		sta vic_color_ram + $168, x
		inx 
		cpx #$1c
		bcc l9C16
		ldx #$00
		ldy #$05

l9C2A:
		lda f1_1_player_text, x
		sta vic_screen + $1e0, y
		lda f3_2_player_text, x
		sta vic_screen + $230, y
		lda #$04
		sta vic_color_ram + $1e0, y
		sta vic_color_ram + $230, y
		iny 
		inx 
		cpx #$14
		bcc l9C2A
		rts 
logo0 = $9c45
logo1 = $9c61
logo2 = $9c7d
logo3 = $9c98
logo4 = $9cb7
*=$9cd5

l9CD5:
		lda $0805
		cmp #$9e
		beq nothing_just_rts
		lda $73
		cmp #$4c
		bne l9CF4
		lda $74
		cmp #$09
		bne l9CF4
		lda $2d
		cmp #$44
		bne l9CF4
		lda $2e
		cmp #$08
		beq nothing_just_rts

l9CF4:
		lda #$00
		sta $50
		lda #$08
		sta $51
		lda #$00
		ldy #$00

l9D00:
		sta ($50), y
		inc $50
		bne l9D00
		inc $51
		bne l9D00
		beq nothing_just_rts

nothing_just_rts:
		rts 

l9D0D:
		tay 
		and #$0f
		cmp #$0a
		bcc l9D16
		adc #$06

l9D16:
		adc #$30
		tax 
		tya 
		lsr 
		lsr 
		lsr 
		lsr 
		cmp #$0a
		bcc l9D24
		adc #$06

l9D24:
		adc #$30
		tay 
		lda #$00
		rts 
*=$9d3a

init_sprite_ptrs:
		.byte	$0d, $0e, $0f, $20, $21, $22, $23, $0f, $00, $00, $00, $00, $00, $00, $00, $00
sprite_ptrs:
		.byte	$16, $d8, $16, $d4, $16, $8b, $52, $4e, $ec, $a6, $70, $10, $f0, $10, $80, $10
sprite_x_high_bits:		.byte	$00
*=$9d6e

table_with_timed_stuff:
		.byte	$76, $fa, $ea, $92, $01, $c8, $c8, $a3
table_with_timers:
		.byte	$2a, $12, $32, $20, $0e, $2e, $2a, $2a
joystick_state = $9d88
sprite_coll_state = $9d89
init_sprite_coords = $9da4
*=$9e00

start:
		lda #$00
		sta $d020
		sta $d021
		jsr lE544
		ldx #$68

l9E0D:
		lda crack_trainer_msg, x
		sta vic_screen, x
		lda #$0f
		sta vic_color_ram, x
		dex 
		bpl l9E0D
		cli 

l9E1C:
		jsr lFFE4
		cmp #$4e
		beq no_trainer
		cmp #$59
		bne l9E1C
		lda #$2c
		sta d91DC

no_trainer:
		lda #$9e
		sta $0805
		jmp start_game
*=$9e40

crack_trainer_msg:
		.text	"CRACKED BY MANIK                "
		.text	"        ", $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, "        "
		.text	"                UNLIMITED LIVES."
		.text	"....[Y/N]"
*=$9f1c

install_trainer:
		isc @w $00ff, x
		brk 

.virtual $d000
vic_sprite_coords:
		.fill	16
vic_sprite_x_high_bits:		.byte	?
.endv

.virtual $d015
vic_sprite_enable:		.byte	?
.endv

.virtual $d01e
vic_sprite_coll:		.byte	?
.endv

.virtual $d027
vic_sprite_colors:
		.fill	8
.endv

.virtual $d400
sid_base:		.byte	?
.endv

.virtual $d418
sid_vol_filter:		.byte	?
.endv

.virtual $d800
vic_color_ram:
		.fill	1000
.endv

.virtual $dc01
vic_joystick1:		.byte	?
.endv

.virtual $dc04
vic_timer_a:		.byte	?
.endv

*=$e544

lE544:
		brk 
*=$ffe1

lFFE1:
		isc @w $0000, x

lFFE4:
		brk 