
*=$0000

d0000:
*=$00FF

d00FF:

.virtual $0400
vic_screen:
		.fill	1000
.endv

.virtual $07F8
sprite_pointers:
		.fill	8
.endv

*=$0805

d0805:
*=$9000

start_game:
		JMP actual_start_game
*=$9009

actual_start_game:
		JSR l9CD5
		LDA #$FE
		BNE l901A

main_loop:
		JSR lFFE1
		BNE l901D
		BEQ actual_start_game
		JSR l9541

l901A:
		JSR l999A

l901D:
		LDA vic_joystick1
		STA joystick_state
		LDA vic_sprite_coll
		STA sprite_coll_state
		JSR l9773
		JSR l91C4
		STA d9049
		JSR l9226
		JSR l9570
		JSR update_vic_sprite_positions
		JSR l978B
		JSR l9563
		LDA d9049
		BNE l901A
		CLC 
		BCC main_loop

d9049:
		BRK 

player_sprite:
		.byte	$00, $30, $00, $00, $30, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00
		.byte	$FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC
		.byte	$00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00
		.byte	$15, $55, $50, $55, $55, $54, $00, $A8, $00, $00, $A8, $00, $02, $AA, $00
bullet_sprite:
		.byte	$00, $00, $00, $00, $30, $00, $00, $FC, $00, $00, $30, $00, $00, $48, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
enemy_sprite:
		.byte	$02, $00, $20, $00, $80, $80, $00, $2A, $00, $08, $B3, $88, $22, $88, $A2, $2F
		.byte	$EA, $FE, $2F, $E2, $FE, $2F, $80, $BE, $08, $80, $88, $08, $80, $88, $08, $22
		.byte	$08, $08, $22, $08, $02, $22, $20, $02, $22, $20, $08, $22, $08, $08, $80, $88
		.byte	$20, $00, $02, $20, $00, $02, $20, $00, $02, $20, $00, $02, $20, $00, $02
explosion_sprite_1:
		.byte	$00, $00, $00, $00, $00, $00, $00, $8C, $00, $03, $00, $88, $08, $10, $50, $80
		.byte	$0D, $00, $03, $10, $20, $00, $A6, $00, $04, $52, $00, $10, $66, $D0, $02, $4C
		.byte	$26, $00, $23, $20, $00, $24, $10, $20, $6C, $40, $08, $00, $00, $01, $02, $00
		.byte	$00, $41, $40, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00
explosion_sprite_2:
		.byte	$00, $04, $00, $04, $00, $00, $30, $8C, $02, $0B, $00, $88, $04, $10, $50, $80
		.byte	$0D, $00, $03, $10, $20, $00, $84, $04, $04, $52, $00, $10, $44, $D0, $02, $40
		.byte	$26, $0B, $02, $28, $00, $24, $10, $20, $0C, $40, $08, $00, $04, $01, $12, $10
		.byte	$10, $41, $42, $00, $22, $04, $10, $10, $00, $04, $41, $00, $00, $04, $00
explosion_sprite_3:
		.byte	$04, $08, $20, $30, $83, $01, $00, $00, $40, $0B, $00, $04, $20, $10, $50, $80
		.byte	$0D, $00, $08, $10, $04, $00, $84, $01, $48, $00, $00, $20, $00, $34, $02, $00
		.byte	$43, $8B, $02, $0A, $00, $44, $08, $20, $0C, $00, $08, $00, $44, $01, $12, $00
		.byte	$10, $41, $09, $00, $22, $20, $10, $10, $02, $04, $41, $00, $00, $04, $00

l91C4:
		LDA #$01
		JSR l94FD
		LDA d9D98
		JSR l93D8
		BNE check_joystick
		LDA d9D98
		JSR l92FA
		BNE l9223
		LDX d9D8C

d91DC:
		DEC d9D8A, X
		BMI l91FD
		LDX #$00
		LDA init_sprite_coords, X
		STA sprite_ptrs, X
		INX 
		LDA init_sprite_coords, X
		STA sprite_ptrs, X
		LDA #$FE
		AND sprite_x_high_bits
		STA sprite_x_high_bits
		LDA #$01
		CLC 
		BCC l9225

l91FD:
		LDA #$FF
		BNE l9225

check_joystick:
		LDX #$01
		LDY #$00

check_right:
		LDA #$08
		BIT joystick_state
		BNE check_left
		LDA d9D98
		JSR l93F9
		LDX #$01
		LDY #$00

check_left:
		LDA #$04
		BIT joystick_state
		BNE l9223
		LDA d9D98
		JSR l944D

l9223:
		LDA #$00

l9225:
		RTS 

l9226:
		LDA #$02
		JSR l94FD
		LDA d9D98
		JSR l93D8
		BNE l9240
		LDA #$01
		EOR #$FF
		AND d9D87
		STA d9D87
		CLC 
		BCC l92B6

l9240:
		LDA #$01
		BIT d9D87
		BNE l9286
		LDA #$10
		BIT joystick_state
		BNE l92AE

fire_pressed:
		LDA #$02
		BIT d9D87
		BEQ l92B6
		LDA #$01
		JSR l94FD
		LDA #$01
		JSR l93D8
		STA d92F9
		LDA #$02
		JSR l94FD
		LDA d92F9
		BEQ l92B6
		ORA d9D87
		LDA #$01
		ORA d9D87
		STA d9D87
		LDA #$02
		EOR #$FF
		AND d9D87
		STA d9D87
		LDA #$01
		JSR l989C

l9286:
		LDA #$02
		ORA d9D5B
		STA d9D5B
		LDA d9D98
		LDX #$FF
		LDY #$02
		JSR l9486
		LDA #$02
		JSR l989C
		CPY #$0A
		BCS l92F8
		LDA #$01
		EOR #$FF
		AND d9D87
		STA d9D87
		CLC 
		BCC l92F8

l92AE:
		LDA #$02
		ORA d9D87
		STA d9D87

l92B6:
		LDA #$FD
		AND d9D5B
		STA d9D5B
		LDX #$00
		LDA sprite_ptrs, X
		LDX #$02
		STA sprite_ptrs, X
		DEX 
		LDY sprite_ptrs, X
		DEY 
		DEY 
		DEY 
		DEY 
		TYA 
		LDX #$03
		STA sprite_ptrs, X
		LDA #$FF
		JSR l989C
		LDA #$01
		BIT sprite_x_high_bits
		BNE l92EA
		LDA #$FD
		AND sprite_x_high_bits
		CLC 
		BCC l92EF

l92EA:
		LDA #$02
		ORA sprite_x_high_bits

l92EF:
		STA sprite_x_high_bits
		CLC 
		BCC l92F8
		INC d9D9D

l92F8:
		RTS 

d92F9:
*=$92FA

l92FA:
		LDX d9D99
		LDA d9D98
		BIT d9D86
		BNE l9345
		ORA d9D86
		STA d9D86
		LDA #$00
		STA d9D7E, X
		LDA #$01
		STA init_sprite_ptrs + $8, X
		LDX #$01
		LDA #$01
		BIT d9D98
		BNE l9345

l931E:
		LDY d9D8C
		LDA d9D8D, Y
		CLC 
		SED 
		ADC #$01
		STA d9D8D, Y
		BCC l9338
		LDA d9D8F, Y
		CLC 
		ADC #$01
		STA d9D8F, Y
		BCC l9338

l9338:
		CLD 
		CPX #$01
		BNE l9345
		INX 
		LDA #$F8
		BIT d9D86
		BNE l931E

l9345:
		LDA #$05
		JSR l989C
		DEC init_sprite_ptrs + $8, X
		BEQ l9352
		JMP l93D5

l9352:
		INC d9D7E, X
		LDA d9D7E, X
		CMP #$01
		BNE l9365
		LDA sprite_pointers, X
		LDX #$07
		LDY #$91
		BNE l93CA

l9365:
		CMP #$02
		BNE l9372
		LDA sprite_pointers, X
		LDX #$46
		LDY #$91
		BNE l93CA

l9372:
		CMP #$03
		BNE l937F
		LDA sprite_pointers, X
		LDX #$85
		LDY #$91
		BNE l93CA

l937F:
		LDA d9D98
		EOR d9D86
		STA d9D86
		LDX d9D99
		LDA d9D2A, X
		STA d9D97
		LDY d9D32, X
		LDA sprite_pointers, X
		LDX d9D97
		JSR l94DE
		LDA #$FE
		JSR l989C
		LDA #$03
		AND d9D98
		BNE l93C0
		LDY d9D8C
		LDA #$0F
		AND d9D8D, Y
		BNE l93C0
		LDX d9D99

flash_sprite:
		INC vic_sprite_colors, X
		LDA vic_sprite_colors, X
		AND #$0F
		BEQ flash_sprite

l93C0:
		LDA vic_sprite_coll
		LDA #$00
		STA vic_sprite_coll
		BEQ l93D7

l93CA:
		JSR l94DE
		LDX d9D99
		LDA #$1E
		STA init_sprite_ptrs + $8, X

l93D5:
		LDA #$01

l93D7:
		RTS 

l93D8:
		BIT d9D86
		BNE l93F6
		BIT sprite_coll_state
		BEQ l93F2
		LDA #$FC
		BIT sprite_coll_state
		BEQ l93F2
		LDA #$03
		BIT sprite_coll_state
		BNE l93F6
		BEQ l93F2

l93F2:
		LDA #$FF
		BNE l93F8

l93F6:
		LDA #$00

l93F8:
		RTS 

l93F9:
		CPX #$00
		BEQ l942F
		DEX 
		STX d9D9C
		LDX d9D9A
		LDA sprite_ptrs, X
		CPY #$FF
		BEQ l9417
		CMP #$3C
		BCC l9417
		LDA d9D98
		BIT sprite_x_high_bits
		BNE l942B

l9417:
		INC sprite_ptrs, X
		BNE l9425
		LDA d9D98
		ORA sprite_x_high_bits
		STA sprite_x_high_bits

l9425:
		LDX d9D9C
		CLC 
		BCC l93F9

l942B:
		LDA #$01
		BNE l9431

l942F:
		LDA #$00

l9431:
		STA d9D9B
		LDA d9D98
		BIT sprite_x_high_bits
		BEQ l9440
		LDY #$01
		BNE l9442

l9440:
		LDY #$00

l9442:
		LDX d9D9A
		LDA sprite_ptrs, X
		TAX 
		LDA d9D9B
		RTS 

l944D:
		CPX #$00
		BEQ l942F
		DEX 
		STX d9D9C
		LDX d9D9A
		LDA sprite_ptrs, X
		CPY #$FF
		BEQ l946B
		CMP #$17
		BCS l946B
		LDA d9D98
		BIT sprite_x_high_bits
		BEQ l942B

l946B:
		DEC sprite_ptrs, X
		LDA #$FF
		CMP sprite_ptrs, X
		BNE l9480
		LDA d9D98
		EOR #$FF
		AND sprite_x_high_bits
		STA sprite_x_high_bits

l9480:
		LDX d9D9C
		CLC 
		BCC l944D

l9486:
		CPY #$00
		BEQ l94AB
		DEY 
		STX d9D9C
		TXA 
		LDX d9D9A
		INX 
		CMP #$FF
		BEQ l949E
		LDA sprite_ptrs, X
		CMP #$32
		BCC l94A7

l949E:
		DEC sprite_ptrs, X
		LDX d9D9C
		CLC 
		BCC l9486

l94A7:
		LDA #$01
		BNE l94AD

l94AB:
		LDA #$00

l94AD:
		STA d9D9B
		LDX d9D9A
		INX 
		LDY sprite_ptrs, X
		LDX #$00
		LDA d9D9B
		RTS 

l94BD:
		CPY #$00
		BEQ l94AB
		DEY 
		STX d9D9C
		TXA 
		LDX d9D9A
		INX 
		CMP #$FF
		BEQ l94D5
		LDA sprite_ptrs, X
		CMP #$FA
		BCS l94A7

l94D5:
		INC sprite_ptrs, X
		LDX d9D9C
		CLC 
		BCC l94BD

l94DE:
		STX $57
		STY $58
		STA $59
		LDA #$00
		STA $5A
		LDX #$06

l94EA:
		ASL $59
		ROL $5A
		DEX 
		BNE l94EA
		LDY #$00

l94F3:
		LDA ($57), Y
		STA ($59), Y
		INY 
		CPY #$40
		BCC l94F3
		RTS 

l94FD:
		CMP #$00
		BEQ l951B
		STA d9D98
		LDX #$00

l9506:
		LSR 
		BCS l9510
		INX 
		CPX #$08
		BCC l9506
		BCS l951B

l9510:
		STX d9D99
		TXA 
		ASL 
		STA d9D9A
		CLC 
		BCC l9526

l951B:
		LDA #$00
		STA d9D99
		STA d9D9A
		STA d9D98

l9526:
		LDA d9D98
		LDX d9D99
		LDY d9D9A
		RTS 
*=$9541

l9541:
		PHA 
		LDA #$00
		STA sid_vol_filter
		PLA 
		RTS 

update_vic_sprite_positions:
		LDA sprite_x_high_bits
		STA vic_sprite_x_high_bits
		LDX #$00

l9551:
		LDA sprite_ptrs, X
		STA vic_sprite_coords, X
		INX 
		CPX #$10
		BCC l9551
		LDA d9D5B
		STA vic_sprite_enable
		RTS 

l9563:
		LDY d9D94

l9566:
		LDX d9D95

l9569:
		DEX 
		BNE l9569
		DEY 
		BNE l9566
		RTS 

l9570:
		LDA #$04

l9572:
		JSR l94FD
		LDA d9D98
		JSR l93D8
		BNE l95B8
		LDA d9D98
		JSR l92FA
		BEQ l9588
		JMP l960F

l9588:
		LDX d9D9A
		INX 
		LDA #$28
		STA sprite_ptrs, X
		LDX d9D99
		LDA table_with_timed_stuff, X
		LDX d9D9A
		STA sprite_ptrs, X
		CMP #$17
		BCC l95AF
		LDA d9D98
		EOR #$FF
		AND sprite_x_high_bits
		STA sprite_x_high_bits
		JMP l95B8

l95AF:
		LDA d9D98
		ORA sprite_x_high_bits
		STA sprite_x_high_bits

l95B8:
		LDX d9D99
		CPX #$02
		BNE l95D9
		LDA #$80
		AND table_with_timed_stuff, X
		BEQ l95D1
		LDA #$7F
		AND table_with_timed_stuff, X
		STA table_with_timed_stuff, X
		CLC 
		BCC l960F

l95D1:
		LDA #$80
		ORA table_with_timed_stuff, X
		STA table_with_timed_stuff, X

l95D9:
		LDA #$02
		AND table_with_timed_stuff, X
		BEQ l95EA
		LDA d9D98
		LDY #$01
		LDX #$FF
		JSR l94BD

l95EA:
		LDA #$08
		AND table_with_timed_stuff, X
		BEQ l95FB
		LDA d9D98
		LDX #$01
		LDY #$00
		JSR l93F9

l95FB:
		LDX d9D99
		LDA #$04
		AND table_with_timed_stuff, X
		BEQ l960F
		LDA d9D98
		LDX #$01
		LDY #$00
		JSR l944D

l960F:
		LDA #$04
		CMP d9D98
		BCC l963A
		ASL 
		BIT d9D5B
		BNE l9635
		LDY d9D8C
		LDA d9D8F, Y
		CMP #$01
		BCS l962D
		LDA d9D8D, Y
		CMP #$15
		BCC l963A

l962D:
		LDA #$08
		ORA d9D5B
		STA d9D5B

l9635:
		LDA #$08
		JMP l9572

l963A:
		LDA #$08
		CMP d9D98
		BCC l9665
		ASL 
		BIT d9D5B
		BNE l9660
		LDY d9D8C
		LDA d9D8F, Y
		CMP #$01
		BCS l9658
		LDA d9D8D, Y
		CMP #$40
		BCC l96B4

l9658:
		LDA #$10
		ORA d9D5B
		STA d9D5B

l9660:
		LDA #$10
		JMP l9572

l9665:
		LDA #$10
		CMP d9D98
		BCC l9690
		ASL 
		BIT d9D5B
		BNE l968B
		LDY d9D8C
		LDA d9D8F, Y
		CMP #$01
		BCS l9683
		LDA d9D8D, Y
		CMP #$80
		BCC l96B4

l9683:
		LDA #$20
		ORA d9D5B
		STA d9D5B

l968B:
		LDA #$20
		JMP l9572

l9690:
		LDA #$20
		CMP d9D98
		BCC l96B4
		ASL 
		BIT d9D5B
		BNE l96AF
		LDY d9D8C
		LDA d9D8F, Y
		CMP #$01
		BCC l96B4
		LDA #$40
		ORA d9D5B
		STA d9D5B

l96AF:
		LDA #$40
		JMP l9572

l96B4:
		RTS 

l96B5:
		JSR lE544
		LDA #$4C
		STA $73
		LDA #$09
		STA $74
		LDA #$90
		STA $75
		LDX #$00

l96C6:
		LDA init_sprite_ptrs, X
		STA sprite_pointers, X
		INX 
		CPX #$08
		BCC l96C6
		LDX #$00

l96D3:
		LDA d9D2A, X
		STA d9D96
		LDY d9D32, X
		LDA init_sprite_ptrs, X
		STX d9D97
		LDX d9D96
		JSR l94DE
		LDX d9D97
		INX 
		CPX #$07
		BCC l96D3
		LDX #$00

l96F2:
		LDA init_sprite_coords, X
		STA vic_sprite_coords, X
		CPX #$10
		BCS l96FF
		STA sprite_ptrs, X

l96FF:
		INX 
		CPX #$2F
		BCC l96F2
		LDA #$32
		STA d9D94
		LDA #$0A
		STA d9D95
		LDA #$00
		LDX #$00

l9712:
		STA init_sprite_ptrs + $8, X
		INX 
		CPX #$08
		BCC l9712
		STA d9D8D
		STA d9D8E
		STA d9D8F
		STA d9D90
		STA d9D8C
		STA d9D87
		STA d9D86
		STA sprite_x_high_bits
		LDA #$04
		STA d9D8A
		STA d9D8B
		JSR draw_turns
		JSR l978B
		LDA d9DB9
		STA d9D5B
		LDX #$00
		STA d9D6C, X
		INX 
		STA d9D6C, X
		LDA #$00
		LDX #$15

sid_clear_loop:
		DEX 
		STA sid_base, X
		BNE sid_clear_loop
		LDA #$0F
		STA sid_vol_filter
		LDX #$00
		LDY #$00

l9762:
		LDA d9DCB, X
		STA d9D5C, Y
		INY 
		STA d9D5C, Y
		INY 
		INX 
		CPX #$08
		BCC l9762
		RTS 

l9773:
		LDX #$00

l9775:
		DEC table_with_timers, X
		BNE l9785
		LDA vic_timer_a
		STA table_with_timed_stuff, X
		LDA #$32
		STA table_with_timers, X

l9785:
		INX 
		CPX #$08
		BCC l9775
		RTS 

l978B:
		LDA #$00
		STA d9D9F
		LDA #$02
		STA d9DA0

l9795:
		LDY d9D9F
		LDA d9D8F, Y
		JSR l9D0D
		TXA 
		CMP #$30
		BNE l97A5
		LDA #$20

l97A5:
		LDY d9DA0
		STA vic_screen + $28, Y
		LDY d9D9F
		LDA d9D8D, Y
		JSR l9D0D
		STX d9D9E
		TYA 
		CMP #$30
		BNE l97C8
		LDX d9D9F
		LDY d9D8F, X
		CPY #$00
		BNE l97C8
		LDA #$20

l97C8:
		LDY d9DA0
		INY 
		STA vic_screen + $28, Y
		INY 
		LDA d9D9E
		STA vic_screen + $28, Y
		INY 
		LDA #$30
		STA vic_screen + $28, Y
		INY 
		STA vic_screen + $28, Y
		LDX d9D8C
		LDA d9D8A, X
		CLC 
		ADC #$30
		LDX #$06
		STA vic_screen + $96, X
		LDA d9D9F
		BNE l97FF
		LDA #$01
		STA d9D9F
		LDA #$20
		STA d9DA0
		BNE l9795

l97FF:
		JSR l993C
		RTS 

draw_turns:
		LDX #$00

l9805:
		LDA turns_text, X
		AND #$BF
		STA vic_screen + $96, X
		LDA #$06
		STA vic_color_ram + $96, X
		INX 
		CPX #$07
		BCC l9805
		LDX #$00

show_top_score_line:
		LDA top_score_line, X
		AND #$BF
		STA vic_screen, X
		LDA #$08
		STA vic_color_ram, X
		INX 
		CPX #$28
		BCC show_top_score_line
		LDX #$00

show_copyright:
		LDA robert_copyright, X
		STA vic_screen + $3C0, X
		LDA #$06
		STA vic_color_ram + $3C0, X
		INX 
		CPX #$21
		BCC show_copyright
		LDX #$00
		LDA #$02

make_scores_red:
		STA vic_color_ram + $28, X
		INX 
		CPX #$28
		BCC make_scores_red
		RTS 

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
		CMP #$FF
		BEQ l98F6
		CMP #$01
		BNE l98DA
		LDA d9DD5
		STA d9DD7
		STA dD401
		STA dD408
		LDA d9DD6
		STA d9DD8
		STA sid_base
		STA dD407
		LDA d9DD3
		STA dD405
		STA dD40C
		LDA d9DD4
		STA dD406
		STA dD40D
		LDA #$81
		STA dD404
		LDA #$11
		STA dD40B
		BNE l993B

l98DA:
		CMP #$02
		BNE l98FE
		DEC d9DD7
		LDA d9DD7
		STA dD401
		STA dD408
		LDA d9DD8
		STA sid_base
		STA dD407
		CLC 
		BCC l993B

l98F6:
		LDA #$00
		STA dD40B
		STA dD404

l98FE:
		CMP #$05
		BNE l9932
		LDA vic_timer_a
		LSR 
		STA dD410
		STA dD401
		LSR 
		STA dD40F
		STA dD401
		LDA d9DD9
		STA dD413
		STA dD405
		LDA d9DDA
		STA dD414
		STA dD406
		LDA #$11
		STA dD412
		LDA #$81
		STA dD404
		CLC 
		BCC l993B

l9932:
		CMP #$FE
		BNE l993B
		LDA #$00
		STA dD412

l993B:
		RTS 

l993C:
		LDX d9D8C
		LDA d9D8F, X
		CMP d9D92
		BCC l995F
		BNE l9953
		LDA d9D8D, X
		CMP d9D91
		BCC l995F
		BEQ l995F

l9953:
		LDA d9D8D, X
		STA d9D91
		LDA d9D8F, X
		STA d9D92

l995F:
		LDA d9D92
		JSR l9D0D
		TXA 
		CMP #$30
		BNE l996C
		LDA #$20

l996C:
		LDY #$11
		STA vic_screen + $28, Y
		LDA d9D91
		JSR l9D0D
		TYA 
		CMP #$30
		BNE hi_score_draw
		LDY d9D92
		CPY #$00
		BNE hi_score_draw
		LDA #$20

hi_score_draw:
		LDY #$12
		STA vic_screen + $28, Y
		INY 
		TXA 
		STA vic_screen + $28, Y
		INY 
		LDA #$30
		STA vic_screen + $28, Y
		INY 
		STA vic_screen + $28, Y
		RTS 

l999A:
		LDX #$00
		STX sid_vol_filter
		CMP #$FE
		BCC l99F7
		BNE l99AB
		JSR l96B5
		JMP l99BA

l99AB:
		JSR l9ADF
		LDA d9D93
		BEQ l99BA
		LDA d9D8C
		CMP #$00
		BEQ l99EB

l99BA:
		JSR draw_logo

l99BD:
		LDX #$00
		STX d9DA2
		LDX #$0A
		STX d9DA3
		BNE l99CC

l99C9:
		JSR lFFE4

l99CC:
		CMP #$0D
		BEQ l9A47
		CMP #$85
		BEQ l9A3B
		CMP #$86
		BEQ l9A42
		JSR l9563
		DEC d9DA2
		BNE l99C9
		DEC d9DA3
		BNE l99C9
		JSR l9A4B
		JMP l99BD

l99EB:
		LDX #$00
		LDA #$20

l99EF:
		STA vic_screen + $1E0, X
		INX 
		CPX #$28
		BCC l99EF

l99F7:
		JSR l9B4D
		JSR l978B
		JSR l9AF7
		LDA #$F0
		STA d9D94
		STA d9D95
		JSR l9563
		LDA #$32
		STA d9D94
		LDA #$0A
		STA d9D95
		LDA #$20
		LDX #$00

l9A19:
		STA vic_screen + $1E0, X
		STA vic_screen + $230, X
		INX 
		CPX #$28
		BCC l9A19
		LDX #$0F
		STX sid_vol_filter
		LDA vic_sprite_coll
		LDA #$00
		STA sprite_coll_state
		STA dD404
		STA dD40B
		STA dD412
		RTS 

l9A3B:
		LDA #$00
		STA d9D93
		BEQ l9A47

l9A42:
		LDA #$01
		STA d9D93

l9A47:
		JSR l96B5
		RTS 

l9A4B:
		JSR l96B5
		JSR draw_logo
		LDA #$1D
		STA d9D5B
		LDA #$06
		STA vic_sprite_colors + $3
		LDA #$0C
		STA vic_sprite_colors + $4
		LDA #$0E
		STA d9D95

l9A65:
		JSR lFFE1
		BEQ l9AA4
		JSR lFFE4
		CMP #$0D
		BEQ l9AA4
		CMP #$85
		BEQ l9AA4
		CMP #$86
		BEQ l9AA4
		LDA table_with_timed_stuff
		EOR #$08
		STA joystick_state
		LDA vic_sprite_coll
		STA sprite_coll_state
		JSR l9773
		JSR l91C4
		STA d9049
		JSR l9226
		JSR l9570
		JSR update_vic_sprite_positions
		JSR l9563
		LDA d9049
		BNE l9AA4
		CLC 
		BCC l9A65

l9AA4:
		LDX #$00
		STX sid_vol_filter
		LDX #$1D
		STX vic_sprite_enable
		STX d9D5B
		LDX #$0A
		STX d9D95
		RTS 

f1_1_player_text:
		.enc	"screen"
		.text	"F1 - SINGLE PLAYER  "
f3_2_player_text:
		.text	"F3 - TWO PLAYER GAME"

l9ADF:
		LDX #$00
		LDY #$0F

l9AE3:
		LDA game_over_text, X
		LDA game_over_text, X
		STA vic_screen + $1E0, Y
		LDA #$08
		STA vic_color_ram + $1E0, Y
		INX 
		INY 
		CPX #$09
		BCC l9AE3

l9AF7:
		LDX #$00
		LDY #$0F
		LDA d9D8C
		BEQ show_top_score_row_14
		LDX #$1E

show_top_score_row_14:
		LDA top_score_line, X
		AND #$BF
		STA vic_screen + $230, Y
		LDA #$08
		STA vic_color_ram + $230, Y
		INY 
		INX 
		CPY #$19
		BCC show_top_score_row_14
		LDA #$FF
		STA d9B41
		STA d9D94

l9B1D:
		JSR l9563
		JSR lFFE1
		BEQ l9B40
		JSR lFFE4
		CMP #$0D
		BEQ l9B40
		CMP #$85
		BEQ l9B40
		CMP #$86
		BEQ l9B40
		DEC d9B41
		BNE l9B1D
		LDA #$32
		STA d9D94
		LDA #$01

l9B40:
		RTS 

d9B41:
*=$9B42

game_over_text:
		.text	"GAME OVER  "

l9B4D:
		LDA d9D93
		BEQ l9B89
		LDX d9D8C
		LDA d9D5B
		STA d9D6C, X
		LDY #$00

l9B5D:
		LDA vic_sprite_colors, Y
		STA d9D5C, X
		INX 
		INX 
		INY 
		CPY #$08
		BCC l9B5D
		LDA #$01
		SEC 
		SBC d9D8C
		STA d9D8C
		TAX 
		LDA d9D6C, X
		STA d9D5B
		LDY #$00

l9B7C:
		LDA d9D5C, X
		STA vic_sprite_colors, Y
		INX 
		INX 
		INY 
		CPY #$08
		BCC l9B7C

l9B89:
		LDX #$00

l9B8B:
		LDA init_sprite_coords, X
		STA sprite_ptrs, X
		INX 
		CPX #$10
		BCC l9B8B
		LDA #$00
		STA sprite_x_high_bits
		STA d9D86
		STA d9D87
		LDX #$00

l9BA3:
		LDA d9D2A, X
		STA d9D96
		LDY d9D32, X
		LDA init_sprite_ptrs, X
		STX d9D97
		LDX d9D96
		JSR l94DE
		LDX d9D97
		INX 
		CPX #$07
		BCC l9BA3
		LDA d9D5B
		AND #$FD
		STA d9D5B
		JSR update_vic_sprite_positions
		RTS 

draw_logo:
		.byte	$A2
*=$9C45

logo0:		.byte	$5F
*=$9C61

logo1:		.byte	$20
*=$9C7D

logo2:		.byte	$20
*=$9C98

logo3:		.byte	$20
*=$9CB7

logo4:		.byte	$E9
*=$9CD5

l9CD5:
		LDA d0805
		CMP #$9E
		BEQ nothing_just_rts
		LDA $73
		CMP #$4C
		BNE l9CF4
		LDA $74
		CMP #$09
		BNE l9CF4
		LDA $2D
		CMP #$44
		BNE l9CF4
		LDA $2E
		CMP #$08
		BEQ nothing_just_rts

l9CF4:
		LDA #$00
		STA $50
		LDA #$08
		STA $51
		LDA #$00
		LDY #$00

l9D00:
		STA ($50), Y
		INC $50
		BNE l9D00
		INC $51
		BNE l9D00
		BEQ nothing_just_rts

nothing_just_rts:
		RTS 

l9D0D:
		TAY 
		AND #$0F
		CMP #$0A
		BCC l9D16
		ADC #$06

l9D16:
		ADC #$30
		TAX 
		TYA 
		LSR 
		LSR 
		LSR 
		LSR 
		CMP #$0A
		BCC l9D24
		ADC #$06

l9D24:
		ADC #$30
		TAY 
		LDA #$00
		RTS 

d9D2A:
*=$9D32

d9D32:
*=$9D3A

init_sprite_ptrs:
		.byte	$0D, $0E, $0F, $20, $21, $22, $23, $0F, $00, $00, $00, $00, $00, $00, $00, $00
sprite_ptrs:
		.byte	$16, $D8, $16, $D4, $16, $8B, $52, $4E, $EC, $A6, $70, $10, $F0, $10, $80, $10
sprite_x_high_bits:		.byte	$00

d9D5B:
*=$9D5C

d9D5C:
*=$9D6C

d9D6C:
*=$9D6E

table_with_timed_stuff:
		.byte	$76, $FA, $EA, $92, $01, $C8, $C8, $A3
table_with_timers:
		.byte	$2A, $12, $32, $20, $0E, $2E, $2A, $2A

d9D7E:
*=$9D86

d9D86:
*=$9D87

d9D87:
*=$9D88

joystick_state:
		.byte	$7E
sprite_coll_state:		.byte	$00

d9D8A:
*=$9D8B

d9D8B:
*=$9D8C

d9D8C:
*=$9D8D

d9D8D:
*=$9D8E

d9D8E:
*=$9D8F

d9D8F:
*=$9D90

d9D90:
*=$9D91

d9D91:
*=$9D92

d9D92:
*=$9D93

d9D93:
*=$9D94

d9D94:
*=$9D95

d9D95:
*=$9D96

d9D96:
*=$9D97

d9D97:
*=$9D98

d9D98:
*=$9D99

d9D99:
*=$9D9A

d9D9A:
*=$9D9B

d9D9B:
*=$9D9C

d9D9C:
*=$9D9D

d9D9D:
*=$9D9E

d9D9E:
*=$9D9F

d9D9F:
*=$9DA0

d9DA0:
*=$9DA2

d9DA2:
*=$9DA3

d9DA3:
*=$9DA4

init_sprite_coords:		.byte	$A0
*=$9DB9

d9DB9:
*=$9DCB

d9DCB:
*=$9DD3

d9DD3:
*=$9DD4

d9DD4:
*=$9DD5

d9DD5:
*=$9DD6

d9DD6:
*=$9DD7

d9DD7:
*=$9DD8

d9DD8:
*=$9DD9

d9DD9:
*=$9DDA

d9DDA:
*=$9E00

start:
		LDA #$00
		STA dD020
		STA dD021
		JSR lE544
		LDX #$68

l9E0D:
		LDA crack_trainer_msg, X
		STA vic_screen, X
		LDA #$0F
		STA vic_color_ram, X
		DEX 
		BPL l9E0D
		CLI 

l9E1C:
		JSR lFFE4
		CMP #$4E
		BEQ no_trainer
		CMP #$59
		BNE l9E1C
		LDA #$2C
		STA d91DC

no_trainer:
		LDA #$9E
		STA d0805
		JMP start_game
*=$9E40

crack_trainer_msg:
		.text	"CRACKED BY MANIK                "
		.text	"        ", $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, "        "
		.text	"                UNLIMITED LIVES."
		.text	"....[Y/N]"
*=$9F1C

install_trainer:
		ISC d00FF, X
		BRK 

.virtual $D000
vic_sprite_coords:
		.fill	16
vic_sprite_x_high_bits:		.byte	?
.endv

.virtual $D015
vic_sprite_enable:		.byte	?
.endv

.virtual $D01E
vic_sprite_coll:		.byte	?
.endv

*=$D020

dD020:
*=$D021

dD021:

.virtual $D027
vic_sprite_colors:
		.fill	8
.endv

.virtual $D400
sid_base:		.byte	?
.endv

*=$D401

dD401:
*=$D404

dD404:
*=$D405

dD405:
*=$D406

dD406:
*=$D407

dD407:
*=$D408

dD408:
*=$D40B

dD40B:
*=$D40C

dD40C:
*=$D40D

dD40D:
*=$D40F

dD40F:
*=$D410

dD410:
*=$D412

dD412:
*=$D413

dD413:
*=$D414

dD414:

.virtual $D418
sid_vol_filter:		.byte	?
.endv

.virtual $D800
vic_color_ram:
		.fill	1000
.endv

.virtual $DC01
vic_joystick1:		.byte	?
.endv

.virtual $DC04
vic_timer_a:		.byte	?
.endv

*=$E544

lE544:
		BRK 
*=$FFE1

lFFE1:
		ISC d0000, X

lFFE4:
		BRK 