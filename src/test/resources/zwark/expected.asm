
*=$0400

vic_screen:
		.BYTE	$10, $0C, $01, $19, $05, $12, $2E, $0F, $0E, $05, $2E, $2E, $2E, $2E, $2E, $08
		.BYTE	$09, $07, $08, $2E, $13, $03, $0F, $12, $05, $2E, $2E, $2E, $2E, $2E, $10, $0C
		.BYTE	$01, $19, $05, $12, $2E, $14, $17, $0F, $20, $20, $20, $20, $30, $30, $30, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $30, $30, $30, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $30, $30, $30, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $14, $15, $12, $0E, $13, $3D, $34, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $5F, $A0, $A0, $A0, $A0, $69, $20, $A0
		.BYTE	$20, $20, $20, $20, $A0, $20, $20, $DF, $20, $20, $A0, $DF, $20, $20, $20, $A0
		.BYTE	$20, $E9, $69, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $E9, $69, $20, $20, $A0, $20, $20, $20, $20, $A0, $20, $E9, $5F
		.BYTE	$DF, $20, $A0, $5F, $DF, $20, $20, $A0, $E9, $69, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $E9, $69, $20, $20, $20, $A0
		.BYTE	$20, $20, $20, $20, $A0, $20, $A0, $20, $A0, $20, $A0, $E9, $69, $20, $20, $A0
		.BYTE	$A0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $E9, $69, $20, $20, $20, $20, $5F, $DF, $E9, $DF, $E9, $69, $20, $A0, $A0
		.BYTE	$A0, $20, $A0, $5F, $DF, $20, $20, $A0, $5F, $DF, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $E9, $A0, $A0, $A0, $A0, $DF, $20, $20
		.BYTE	$5F, $69, $5F, $69, $20, $20, $A0, $20, $A0, $20, $A0, $20, $5F, $DF, $20, $A0
		.BYTE	$20, $5F, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $06, $31, $20, $2D, $20, $13, $09, $0E, $07, $0C, $05
		.BYTE	$20, $10, $0C, $01, $19, $05, $12, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $06, $33, $20, $2D, $20, $14, $17, $0F, $20, $10, $0C
		.BYTE	$01, $19, $05, $12, $20, $07, $01, $0D, $05, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.BYTE	$1A, $17, $01, $12, $0B, $20, $20, $28, $03, $29, $20, $31, $39, $38, $32, $20
		.BYTE	$20, $12, $0F, $02, $05, $12, $14, $20, $17, $05, $0E, $14, $17, $0F, $12, $14
		.BYTE	$08, $20, $20, $20, $20, $20, $20, $20
*=$07F8

sprite_pointers:		.BYTE	$0D, $0E, $0F, $20, $21, $22, $23, $0F
*=$0805

_0805_DATA:
*=$9000

start_game:
		JMP actual_start_game
*=$9009

actual_start_game:
		JSR _9CD5_CODE
		LDA #$FE
		BNE _901A_CODE

main_loop:
		JSR _FFE1_CODE
		BNE _901D_CODE
		BEQ actual_start_game
		JSR _9541_CODE

_901A_CODE:
		JSR _999A_CODE

_901D_CODE:
		LDA vic_joystick1
		STA joystick_state
		LDA vic_sprite_coll
		STA sprite_coll_state
		JSR _9773_CODE
		JSR _91C4_CODE
		STA _9049_DATA
		JSR _9226_CODE
		JSR _9570_CODE
		JSR update_vic_sprite_positions
		JSR _978B_CODE
		JSR _9563_CODE
		LDA _9049_DATA
		BNE _901A_CODE
		CLC 
		BCC main_loop

_9049_DATA:
		BRK 

player_sprite:
		.BYTE	$00, $30, $00, $00, $30, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00
		.BYTE	$FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC
		.BYTE	$00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00, $00, $FC, $00
		.BYTE	$15, $55, $50, $55, $55, $54, $00, $A8, $00, $00, $A8, $00, $02, $AA, $00

bullet_sprite:		.BYTE	$00, $00, $00, $00, $30, $00, $00, $FC, $00, $00, $30, $00, $00, $48, $00, $00
		.BYTE	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.BYTE	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.BYTE	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

enemy_sprite:		.BYTE	$02, $00, $20, $00, $80, $80, $00, $2A, $00, $08, $B3, $88, $22, $88, $A2, $2F
		.BYTE	$EA, $FE, $2F, $E2, $FE, $2F, $80, $BE, $08, $80, $88, $08, $80, $88, $08, $22
		.BYTE	$08, $08, $22, $08, $02, $22, $20, $02, $22, $20, $08, $22, $08, $08, $80, $88
		.BYTE	$20, $00, $02, $20, $00, $02, $20, $00, $02, $20, $00, $02, $20, $00, $02

explosion_sprite_1:		.BYTE	$00, $00, $00, $00, $00, $00, $00, $8C, $00, $03, $00, $88, $08, $10, $50, $80
		.BYTE	$0D, $00, $03, $10, $20, $00, $A6, $00, $04, $52, $00, $10, $66, $D0, $02, $4C
		.BYTE	$26, $00, $23, $20, $00, $24, $10, $20, $6C, $40, $08, $00, $00, $01, $02, $00
		.BYTE	$00, $41, $40, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00

explosion_sprite_2:		.BYTE	$00, $04, $00, $04, $00, $00, $30, $8C, $02, $0B, $00, $88, $04, $10, $50, $80
		.BYTE	$0D, $00, $03, $10, $20, $00, $84, $04, $04, $52, $00, $10, $44, $D0, $02, $40
		.BYTE	$26, $0B, $02, $28, $00, $24, $10, $20, $0C, $40, $08, $00, $04, $01, $12, $10
		.BYTE	$10, $41, $42, $00, $22, $04, $10, $10, $00, $04, $41, $00, $00, $04, $00

explosion_sprite_3:		.BYTE	$04, $08, $20, $30, $83, $01, $00, $00, $40, $0B, $00, $04, $20, $10, $50, $80
		.BYTE	$0D, $00, $08, $10, $04, $00, $84, $01, $48, $00, $00, $20, $00, $34, $02, $00
		.BYTE	$43, $8B, $02, $0A, $00, $44, $08, $20, $0C, $00, $08, $00, $44, $01, $12, $00
		.BYTE	$10, $41, $09, $00, $22, $20, $10, $10, $02, $04, $41, $00, $00, $04, $00

_91C4_CODE:
		LDA #$01
		JSR _94FD_CODE
		LDA $9D98
		JSR _93D8_CODE
		BNE check_joystick
		LDA $9D98
		JSR _92FA_CODE
		BNE _9223_CODE
		LDX $9D8C
		DEC $9D8A, X
		BMI _91FD_CODE
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
		BCC _9225_CODE

_91FD_CODE:
		LDA #$FF
		BNE _9225_CODE

check_joystick:
		LDX #$01
		LDY #$00

check_right:
		LDA #$08
		BIT joystick_state
		BNE check_left
		LDA $9D98
		JSR _93F9_CODE
		LDX #$01
		LDY #$00

check_left:
		LDA #$04
		BIT joystick_state
		BNE _9223_CODE
		LDA $9D98
		JSR _944D_CODE

_9223_CODE:
		LDA #$00

_9225_CODE:
		RTS 

_9226_CODE:
		LDA #$02
		JSR _94FD_CODE
		LDA $9D98
		JSR _93D8_CODE
		BNE _9240_CODE
		LDA #$01
		EOR #$FF
		AND $9D87
		STA $9D87
		CLC 
		BCC _92B6_CODE

_9240_CODE:
		LDA #$01
		BIT $9D87
		BNE _9286_CODE
		LDA #$10
		BIT joystick_state
		BNE _92AE_CODE

fire_pressed:
		LDA #$02
		BIT $9D87
		BEQ _92B6_CODE
		LDA #$01
		JSR _94FD_CODE
		LDA #$01
		JSR _93D8_CODE
		STA $92F9
		LDA #$02
		JSR _94FD_CODE
		LDA $92F9
		BEQ _92B6_CODE
		ORA $9D87
		LDA #$01
		ORA $9D87
		STA $9D87
		LDA #$02
		EOR #$FF
		AND $9D87
		STA $9D87
		LDA #$01
		JSR _989C_CODE

_9286_CODE:
		LDA #$02
		ORA $9D5B
		STA $9D5B
		LDA $9D98
		LDX #$FF
		LDY #$02
		JSR _9486_CODE
		LDA #$02
		JSR _989C_CODE
		CPY #$0A
		BCS _92F8_CODE
		LDA #$01
		EOR #$FF
		AND $9D87
		STA $9D87
		CLC 
		BCC _92F8_CODE

_92AE_CODE:
		LDA #$02
		ORA $9D87
		STA $9D87

_92B6_CODE:
		LDA #$FD
		AND $9D5B
		STA $9D5B
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
		JSR _989C_CODE
		LDA #$01
		BIT sprite_x_high_bits
		BNE _92EA_CODE
		LDA #$FD
		AND sprite_x_high_bits
		CLC 
		BCC _92EF_CODE

_92EA_CODE:
		LDA #$02
		ORA sprite_x_high_bits

_92EF_CODE:
		STA sprite_x_high_bits
		CLC 
		BCC _92F8_CODE
		INC $9D9D

_92F8_CODE:
		RTS 

_92F9_DATA:
*=$92FA

_92FA_CODE:
		LDX $9D99
		LDA $9D98
		BIT $9D86
		BNE _9345_CODE
		ORA $9D86
		STA $9D86
		LDA #$00
		STA $9D7E, X
		LDA #$01
		STA init_sprite_ptrs + $8, X
		LDX #$01
		LDA #$01
		BIT $9D98
		BNE _9345_CODE

_931E_CODE:
		LDY $9D8C
		LDA $9D8D, Y
		CLC 
		SED 
		ADC #$01
		STA $9D8D, Y
		BCC _9338_CODE
		LDA $9D8F, Y
		CLC 
		ADC #$01
		STA $9D8F, Y
		BCC _9338_CODE

_9338_CODE:
		CLD 
		CPX #$01
		BNE _9345_CODE
		INX 
		LDA #$F8
		BIT $9D86
		BNE _931E_CODE

_9345_CODE:
		LDA #$05
		JSR _989C_CODE
		DEC init_sprite_ptrs + $8, X
		BEQ _9352_CODE
		JMP _93D5_CODE

_9352_CODE:
		INC $9D7E, X
		LDA $9D7E, X
		CMP #$01
		BNE _9365_CODE
		LDA sprite_pointers, X
		LDX #$07
		LDY #$91
		BNE _93CA_CODE

_9365_CODE:
		CMP #$02
		BNE _9372_CODE
		LDA sprite_pointers, X
		LDX #$46
		LDY #$91
		BNE _93CA_CODE

_9372_CODE:
		CMP #$03
		BNE _937F_CODE
		LDA sprite_pointers, X
		LDX #$85
		LDY #$91
		BNE _93CA_CODE

_937F_CODE:
		LDA $9D98
		EOR $9D86
		STA $9D86
		LDX $9D99
		LDA $9D2A, X
		STA $9D97
		LDY $9D32, X
		LDA sprite_pointers, X
		LDX $9D97
		JSR _94DE_CODE
		LDA #$FE
		JSR _989C_CODE
		LDA #$03
		AND $9D98
		BNE _93C0_CODE
		LDY $9D8C
		LDA #$0F
		AND $9D8D, Y
		BNE _93C0_CODE
		LDX $9D99

flash_sprite:
		INC vic_sprite_colors, X
		LDA vic_sprite_colors, X
		AND #$0F
		BEQ flash_sprite

_93C0_CODE:
		LDA vic_sprite_coll
		LDA #$00
		STA vic_sprite_coll
		BEQ _93D7_CODE

_93CA_CODE:
		JSR _94DE_CODE
		LDX $9D99
		LDA #$1E
		STA init_sprite_ptrs + $8, X

_93D5_CODE:
		LDA #$01

_93D7_CODE:
		RTS 

_93D8_CODE:
		BIT $9D86
		BNE _93F6_CODE
		BIT sprite_coll_state
		BEQ _93F2_CODE
		LDA #$FC
		BIT sprite_coll_state
		BEQ _93F2_CODE
		LDA #$03
		BIT sprite_coll_state
		BNE _93F6_CODE
		BEQ _93F2_CODE

_93F2_CODE:
		LDA #$FF
		BNE _93F8_CODE

_93F6_CODE:
		LDA #$00

_93F8_CODE:
		RTS 

_93F9_CODE:
		CPX #$00
		BEQ _942F_CODE
		DEX 
		STX $9D9C
		LDX $9D9A
		LDA sprite_ptrs, X
		CPY #$FF
		BEQ _9417_CODE
		CMP #$3C
		BCC _9417_CODE
		LDA $9D98
		BIT sprite_x_high_bits
		BNE _942B_CODE

_9417_CODE:
		INC sprite_ptrs, X
		BNE _9425_CODE
		LDA $9D98
		ORA sprite_x_high_bits
		STA sprite_x_high_bits

_9425_CODE:
		LDX $9D9C
		CLC 
		BCC _93F9_CODE

_942B_CODE:
		LDA #$01
		BNE _9431_CODE

_942F_CODE:
		LDA #$00

_9431_CODE:
		STA $9D9B
		LDA $9D98
		BIT sprite_x_high_bits
		BEQ _9440_CODE
		LDY #$01
		BNE _9442_CODE

_9440_CODE:
		LDY #$00

_9442_CODE:
		LDX $9D9A
		LDA sprite_ptrs, X
		TAX 
		LDA $9D9B
		RTS 

_944D_CODE:
		CPX #$00
		BEQ _942F_CODE
		DEX 
		STX $9D9C
		LDX $9D9A
		LDA sprite_ptrs, X
		CPY #$FF
		BEQ _946B_CODE
		CMP #$17
		BCS _946B_CODE
		LDA $9D98
		BIT sprite_x_high_bits
		BEQ _942B_CODE

_946B_CODE:
		DEC sprite_ptrs, X
		LDA #$FF
		CMP sprite_ptrs, X
		BNE _9480_CODE
		LDA $9D98
		EOR #$FF
		AND sprite_x_high_bits
		STA sprite_x_high_bits

_9480_CODE:
		LDX $9D9C
		CLC 
		BCC _944D_CODE

_9486_CODE:
		CPY #$00
		BEQ _94AB_CODE
		DEY 
		STX $9D9C
		TXA 
		LDX $9D9A
		INX 
		CMP #$FF
		BEQ _949E_CODE
		LDA sprite_ptrs, X
		CMP #$32
		BCC _94A7_CODE

_949E_CODE:
		DEC sprite_ptrs, X
		LDX $9D9C
		CLC 
		BCC _9486_CODE

_94A7_CODE:
		LDA #$01
		BNE _94AD_CODE

_94AB_CODE:
		LDA #$00

_94AD_CODE:
		STA $9D9B
		LDX $9D9A
		INX 
		LDY sprite_ptrs, X
		LDX #$00
		LDA $9D9B
		RTS 

_94BD_CODE:
		CPY #$00
		BEQ _94AB_CODE
		DEY 
		STX $9D9C
		TXA 
		LDX $9D9A
		INX 
		CMP #$FF
		BEQ _94D5_CODE
		LDA sprite_ptrs, X
		CMP #$FA
		BCS _94A7_CODE

_94D5_CODE:
		INC sprite_ptrs, X
		LDX $9D9C
		CLC 
		BCC _94BD_CODE

_94DE_CODE:
		STX $57
		STY $58
		STA $59
		LDA #$00
		STA $5A
		LDX #$06

_94EA_CODE:
		ASL $59
		ROL $5A
		DEX 
		BNE _94EA_CODE
		LDY #$00

_94F3_CODE:
		LDA ($57), Y
		STA ($59), Y
		INY 
		CPY #$40
		BCC _94F3_CODE
		RTS 

_94FD_CODE:
		CMP #$00
		BEQ _951B_CODE
		STA $9D98
		LDX #$00

_9506_CODE:
		LSR 
		BCS _9510_CODE
		INX 
		CPX #$08
		BCC _9506_CODE
		BCS _951B_CODE

_9510_CODE:
		STX $9D99
		TXA 
		ASL 
		STA $9D9A
		CLC 
		BCC _9526_CODE

_951B_CODE:
		LDA #$00
		STA $9D99
		STA $9D9A
		STA $9D98

_9526_CODE:
		LDA $9D98
		LDX $9D99
		LDY $9D9A
		RTS 
*=$9541

_9541_CODE:
		PHA 
		LDA #$00
		STA sid_vol_filter
		PLA 
		RTS 

update_vic_sprite_positions:
		LDA sprite_x_high_bits
		STA vic_sprite_x_high_bits
		LDX #$00

_9551_CODE:
		LDA sprite_ptrs, X
		STA vic_sprite_coords, X
		INX 
		CPX #$10
		BCC _9551_CODE
		LDA $9D5B
		STA vic_sprite_enable
		RTS 

_9563_CODE:
		LDY $9D94

_9566_CODE:
		LDX $9D95

_9569_CODE:
		DEX 
		BNE _9569_CODE
		DEY 
		BNE _9566_CODE
		RTS 

_9570_CODE:
		LDA #$04

_9572_CODE:
		JSR _94FD_CODE
		LDA $9D98
		JSR _93D8_CODE
		BNE _95B8_CODE
		LDA $9D98
		JSR _92FA_CODE
		BEQ _9588_CODE
		JMP _960F_CODE

_9588_CODE:
		LDX $9D9A
		INX 
		LDA #$28
		STA sprite_ptrs, X
		LDX $9D99
		LDA table_with_timed_stuff, X
		LDX $9D9A
		STA sprite_ptrs, X
		CMP #$17
		BCC _95AF_CODE
		LDA $9D98
		EOR #$FF
		AND sprite_x_high_bits
		STA sprite_x_high_bits
		JMP _95B8_CODE

_95AF_CODE:
		LDA $9D98
		ORA sprite_x_high_bits
		STA sprite_x_high_bits

_95B8_CODE:
		LDX $9D99
		CPX #$02
		BNE _95D9_CODE
		LDA #$80
		AND table_with_timed_stuff, X
		BEQ _95D1_CODE
		LDA #$7F
		AND table_with_timed_stuff, X
		STA table_with_timed_stuff, X
		CLC 
		BCC _960F_CODE

_95D1_CODE:
		LDA #$80
		ORA table_with_timed_stuff, X
		STA table_with_timed_stuff, X

_95D9_CODE:
		LDA #$02
		AND table_with_timed_stuff, X
		BEQ _95EA_CODE
		LDA $9D98
		LDY #$01
		LDX #$FF
		JSR _94BD_CODE

_95EA_CODE:
		LDA #$08
		AND table_with_timed_stuff, X
		BEQ _95FB_CODE
		LDA $9D98
		LDX #$01
		LDY #$00
		JSR _93F9_CODE

_95FB_CODE:
		LDX $9D99
		LDA #$04
		AND table_with_timed_stuff, X
		BEQ _960F_CODE
		LDA $9D98
		LDX #$01
		LDY #$00
		JSR _944D_CODE

_960F_CODE:
		LDA #$04
		CMP $9D98
		BCC _963A_CODE
		ASL 
		BIT $9D5B
		BNE _9635_CODE
		LDY $9D8C
		LDA $9D8F, Y
		CMP #$01
		BCS _962D_CODE
		LDA $9D8D, Y
		CMP #$15
		BCC _963A_CODE

_962D_CODE:
		LDA #$08
		ORA $9D5B
		STA $9D5B

_9635_CODE:
		LDA #$08
		JMP _9572_CODE

_963A_CODE:
		LDA #$08
		CMP $9D98
		BCC _9665_CODE
		ASL 
		BIT $9D5B
		BNE _9660_CODE
		LDY $9D8C
		LDA $9D8F, Y
		CMP #$01
		BCS _9658_CODE
		LDA $9D8D, Y
		CMP #$40
		BCC _96B4_CODE

_9658_CODE:
		LDA #$10
		ORA $9D5B
		STA $9D5B

_9660_CODE:
		LDA #$10
		JMP _9572_CODE

_9665_CODE:
		LDA #$10
		CMP $9D98
		BCC _9690_CODE
		ASL 
		BIT $9D5B
		BNE _968B_CODE
		LDY $9D8C
		LDA $9D8F, Y
		CMP #$01
		BCS _9683_CODE
		LDA $9D8D, Y
		CMP #$80
		BCC _96B4_CODE

_9683_CODE:
		LDA #$20
		ORA $9D5B
		STA $9D5B

_968B_CODE:
		LDA #$20
		JMP _9572_CODE

_9690_CODE:
		LDA #$20
		CMP $9D98
		BCC _96B4_CODE
		ASL 
		BIT $9D5B
		BNE _96AF_CODE
		LDY $9D8C
		LDA $9D8F, Y
		CMP #$01
		BCC _96B4_CODE
		LDA #$40
		ORA $9D5B
		STA $9D5B

_96AF_CODE:
		LDA #$40
		JMP _9572_CODE

_96B4_CODE:
		RTS 

_96B5_CODE:
		JSR _E544_CODE
		LDA #$4C
		STA $73
		LDA #$09
		STA $74
		LDA #$90
		STA $75
		LDX #$00

_96C6_CODE:
		LDA init_sprite_ptrs, X
		STA sprite_pointers, X
		INX 
		CPX #$08
		BCC _96C6_CODE
		LDX #$00

_96D3_CODE:
		LDA $9D2A, X
		STA $9D96
		LDY $9D32, X
		LDA init_sprite_ptrs, X
		STX $9D97
		LDX $9D96
		JSR _94DE_CODE
		LDX $9D97
		INX 
		CPX #$07
		BCC _96D3_CODE
		LDX #$00

_96F2_CODE:
		LDA init_sprite_coords, X
		STA vic_sprite_coords, X
		CPX #$10
		BCS _96FF_CODE
		STA sprite_ptrs, X

_96FF_CODE:
		INX 
		CPX #$2F
		BCC _96F2_CODE
		LDA #$32
		STA $9D94
		LDA #$0A
		STA $9D95
		LDA #$00
		LDX #$00

_9712_CODE:
		STA init_sprite_ptrs + $8, X
		INX 
		CPX #$08
		BCC _9712_CODE
		STA $9D8D
		STA $9D8E
		STA $9D8F
		STA $9D90
		STA $9D8C
		STA $9D87
		STA $9D86
		STA sprite_x_high_bits
		LDA #$04
		STA $9D8A
		STA $9D8B
		JSR draw_turns
		JSR _978B_CODE
		LDA $9DB9
		STA $9D5B
		LDX #$00
		STA $9D6C, X
		INX 
		STA $9D6C, X
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

_9762_CODE:
		LDA $9DCB, X
		STA $9D5C, Y
		INY 
		STA $9D5C, Y
		INY 
		INX 
		CPX #$08
		BCC _9762_CODE
		RTS 

_9773_CODE:
		LDX #$00

_9775_CODE:
		DEC table_with_timers, X
		BNE _9785_CODE
		LDA vic_timer_a
		STA table_with_timed_stuff, X
		LDA #$32
		STA table_with_timers, X

_9785_CODE:
		INX 
		CPX #$08
		BCC _9775_CODE
		RTS 

_978B_CODE:
		LDA #$00
		STA $9D9F
		LDA #$02
		STA $9DA0

_9795_CODE:
		LDY $9D9F
		LDA $9D8F, Y
		JSR _9D0D_CODE
		TXA 
		CMP #$30
		BNE _97A5_CODE
		LDA #$20

_97A5_CODE:
		LDY $9DA0
		STA vic_screen + $28, Y
		LDY $9D9F
		LDA $9D8D, Y
		JSR _9D0D_CODE
		STX $9D9E
		TYA 
		CMP #$30
		BNE _97C8_CODE
		LDX $9D9F
		LDY $9D8F, X
		CPY #$00
		BNE _97C8_CODE
		LDA #$20

_97C8_CODE:
		LDY $9DA0
		INY 
		STA vic_screen + $28, Y
		INY 
		LDA $9D9E
		STA vic_screen + $28, Y
		INY 
		LDA #$30
		STA vic_screen + $28, Y
		INY 
		STA vic_screen + $28, Y
		LDX $9D8C
		LDA $9D8A, X
		CLC 
		ADC #$30
		LDX #$06
		STA vic_screen + $96, X
		LDA $9D9F
		BNE _97FF_CODE
		LDA #$01
		STA $9D9F
		LDA #$20
		STA $9DA0
		BNE _9795_CODE

_97FF_CODE:
		JSR _993C_CODE
		RTS 

draw_turns:
		LDX #$00

_9805_CODE:
		LDA $9894, X
		AND #$BF
		STA vic_screen + $96, X
		LDA #$06
		STA vic_color_ram + $96, X
		INX 
		CPX #$07
		BCC _9805_CODE
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
		.BYTE	$1A
*=$986C

top_score_line:		.BYTE	$50
*=$989C

_989C_CODE:
		CMP #$FF
		BEQ _98F6_CODE
		CMP #$01
		BNE _98DA_CODE
		LDA $9DD5
		STA $9DD7
		STA $D401
		STA $D408
		LDA $9DD6
		STA $9DD8
		STA sid_base
		STA $D407
		LDA $9DD3
		STA $D405
		STA $D40C
		LDA $9DD4
		STA $D406
		STA $D40D
		LDA #$81
		STA $D404
		LDA #$11
		STA $D40B
		BNE _993B_CODE

_98DA_CODE:
		CMP #$02
		BNE _98FE_CODE
		DEC $9DD7
		LDA $9DD7
		STA $D401
		STA $D408
		LDA $9DD8
		STA sid_base
		STA $D407
		CLC 
		BCC _993B_CODE

_98F6_CODE:
		LDA #$00
		STA $D40B
		STA $D404

_98FE_CODE:
		CMP #$05
		BNE _9932_CODE
		LDA vic_timer_a
		LSR 
		STA $D410
		STA $D401
		LSR 
		STA $D40F
		STA $D401
		LDA $9DD9
		STA $D413
		STA $D405
		LDA $9DDA
		STA $D414
		STA $D406
		LDA #$11
		STA $D412
		LDA #$81
		STA $D404
		CLC 
		BCC _993B_CODE

_9932_CODE:
		CMP #$FE
		BNE _993B_CODE
		LDA #$00
		STA $D412

_993B_CODE:
		RTS 

_993C_CODE:
		LDX $9D8C
		LDA $9D8F, X
		CMP $9D92
		BCC _995F_CODE
		BNE _9953_CODE
		LDA $9D8D, X
		CMP $9D91
		BCC _995F_CODE
		BEQ _995F_CODE

_9953_CODE:
		LDA $9D8D, X
		STA $9D91
		LDA $9D8F, X
		STA $9D92

_995F_CODE:
		LDA $9D92
		JSR _9D0D_CODE
		TXA 
		CMP #$30
		BNE _996C_CODE
		LDA #$20

_996C_CODE:
		LDY #$11
		STA vic_screen + $28, Y
		LDA $9D91
		JSR _9D0D_CODE
		TYA 
		CMP #$30
		BNE hi_score_draw
		LDY $9D92
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

_999A_CODE:
		LDX #$00
		STX sid_vol_filter
		CMP #$FE
		BCC _99F7_CODE
		BNE _99AB_CODE
		JSR _96B5_CODE
		JMP _99BA_CODE

_99AB_CODE:
		JSR _9ADF_CODE
		LDA $9D93
		BEQ _99BA_CODE
		LDA $9D8C
		CMP #$00
		BEQ _99EB_CODE

_99BA_CODE:
		JSR draw_logo

_99BD_CODE:
		LDX #$00
		STX $9DA2
		LDX #$0A
		STX $9DA3
		BNE _99CC_CODE

_99C9_CODE:
		JSR _FFE4_CODE

_99CC_CODE:
		CMP #$0D
		BEQ _9A47_CODE
		CMP #$85
		BEQ _9A3B_CODE
		CMP #$86
		BEQ _9A42_CODE
		JSR _9563_CODE
		DEC $9DA2
		BNE _99C9_CODE
		DEC $9DA3
		BNE _99C9_CODE
		JSR _9A4B_CODE
		JMP _99BD_CODE

_99EB_CODE:
		LDX #$00
		LDA #$20

_99EF_CODE:
		STA vic_screen + $1E0, X
		INX 
		CPX #$28
		BCC _99EF_CODE

_99F7_CODE:
		JSR _9B4D_CODE
		JSR _978B_CODE
		JSR _9AF7_CODE
		LDA #$F0
		STA $9D94
		STA $9D95
		JSR _9563_CODE
		LDA #$32
		STA $9D94
		LDA #$0A
		STA $9D95
		LDA #$20
		LDX #$00

_9A19_CODE:
		STA vic_screen + $1E0, X
		STA vic_screen + $230, X
		INX 
		CPX #$28
		BCC _9A19_CODE
		LDX #$0F
		STX sid_vol_filter
		LDA vic_sprite_coll
		LDA #$00
		STA sprite_coll_state
		STA $D404
		STA $D40B
		STA $D412
		RTS 

_9A3B_CODE:
		LDA #$00
		STA $9D93
		BEQ _9A47_CODE

_9A42_CODE:
		LDA #$01
		STA $9D93

_9A47_CODE:
		JSR _96B5_CODE
		RTS 

_9A4B_CODE:
		JSR _96B5_CODE
		JSR draw_logo
		LDA #$1D
		STA $9D5B
		LDA #$06
		STA vic_sprite_colors + $3
		LDA #$0C
		STA vic_sprite_colors + $4
		LDA #$0E
		STA $9D95

_9A65_CODE:
		JSR _FFE1_CODE
		BEQ _9AA4_CODE
		JSR _FFE4_CODE
		CMP #$0D
		BEQ _9AA4_CODE
		CMP #$85
		BEQ _9AA4_CODE
		CMP #$86
		BEQ _9AA4_CODE
		LDA table_with_timed_stuff
		EOR #$08
		STA joystick_state
		LDA vic_sprite_coll
		STA sprite_coll_state
		JSR _9773_CODE
		JSR _91C4_CODE
		STA _9049_DATA
		JSR _9226_CODE
		JSR _9570_CODE
		JSR update_vic_sprite_positions
		JSR _9563_CODE
		LDA _9049_DATA
		BNE _9AA4_CODE
		CLC 
		BCC _9A65_CODE

_9AA4_CODE:
		LDX #$00
		STX sid_vol_filter
		LDX #$1D
		STX vic_sprite_enable
		STX $9D5B
		LDX #$0A
		STX $9D95
		RTS 

f1_1_player_text:
		.BYTE	$06
*=$9ACB

f3_2_player_text:		.BYTE	$06
*=$9ADF

_9ADF_CODE:
		LDX #$00
		LDY #$0F

_9AE3_CODE:
		LDA game_over_text, X
		LDA game_over_text, X
		STA vic_screen + $1E0, Y
		LDA #$08
		STA vic_color_ram + $1E0, Y
		INX 
		INY 
		CPX #$09
		BCC _9AE3_CODE

_9AF7_CODE:
		LDX #$00
		LDY #$0F
		LDA $9D8C
		BEQ show_top_score_line
		LDX #$1E

show_top_score_line:
		LDA top_score_line, X
		AND #$BF
		STA vic_screen + $230, Y
		LDA #$08
		STA vic_color_ram + $230, Y
		INY 
		INX 
		CPY #$19
		BCC show_top_score_line
		LDA #$FF
		STA $9B41
		STA $9D94

_9B1D_CODE:
		JSR _9563_CODE
		JSR _FFE1_CODE
		BEQ _9B40_CODE
		JSR _FFE4_CODE
		CMP #$0D
		BEQ _9B40_CODE
		CMP #$85
		BEQ _9B40_CODE
		CMP #$86
		BEQ _9B40_CODE
		DEC $9B41
		BNE _9B1D_CODE
		LDA #$32
		STA $9D94
		LDA #$01

_9B40_CODE:
		RTS 
*=$9B42

game_over_text:
		.BYTE	$07
*=$9B4D

_9B4D_CODE:
		LDA $9D93
		BEQ _9B89_CODE
		LDX $9D8C
		LDA $9D5B
		STA $9D6C, X
		LDY #$00

_9B5D_CODE:
		LDA vic_sprite_colors, Y
		STA $9D5C, X
		INX 
		INX 
		INY 
		CPY #$08
		BCC _9B5D_CODE
		LDA #$01
		SEC 
		SBC $9D8C
		STA $9D8C
		TAX 
		LDA $9D6C, X
		STA $9D5B
		LDY #$00

_9B7C_CODE:
		LDA $9D5C, X
		STA vic_sprite_colors, Y
		INX 
		INX 
		INY 
		CPY #$08
		BCC _9B7C_CODE

_9B89_CODE:
		LDX #$00

_9B8B_CODE:
		LDA init_sprite_coords, X
		STA sprite_ptrs, X
		INX 
		CPX #$10
		BCC _9B8B_CODE
		LDA #$00
		STA sprite_x_high_bits
		STA $9D86
		STA $9D87
		LDX #$00

_9BA3_CODE:
		LDA $9D2A, X
		STA $9D96
		LDY $9D32, X
		LDA init_sprite_ptrs, X
		STX $9D97
		LDX $9D96
		JSR _94DE_CODE
		LDX $9D97
		INX 
		CPX #$07
		BCC _9BA3_CODE
		LDA $9D5B
		AND #$FD
		STA $9D5B
		JSR update_vic_sprite_positions
		RTS 

draw_logo:
		.BYTE	$A2
*=$9C45

logo0:		.BYTE	$5F
*=$9C61

logo1:		.BYTE	$20
*=$9C7D

logo2:		.BYTE	$20
*=$9C98

logo3:		.BYTE	$20
*=$9CB7

logo4:		.BYTE	$E9
*=$9CD5

_9CD5_CODE:
		LDA $0805
		CMP #$9E
		BEQ nothing_just_rts
		LDA $73
		CMP #$4C
		BNE _9CF4_CODE
		LDA $74
		CMP #$09
		BNE _9CF4_CODE
		LDA $2D
		CMP #$44
		BNE _9CF4_CODE
		LDA $2E
		CMP #$08
		BEQ nothing_just_rts

_9CF4_CODE:
		LDA #$00
		STA $50
		LDA #$08
		STA $51
		LDA #$00
		LDY #$00

_9D00_CODE:
		STA ($50), Y
		INC $50
		BNE _9D00_CODE
		INC $51
		BNE _9D00_CODE
		BEQ nothing_just_rts

nothing_just_rts:
		RTS 

_9D0D_CODE:
		TAY 
		AND #$0F
		CMP #$0A
		BCC _9D16_CODE
		ADC #$06

_9D16_CODE:
		ADC #$30
		TAX 
		TYA 
		LSR 
		LSR 
		LSR 
		LSR 
		CMP #$0A
		BCC _9D24_CODE
		ADC #$06

_9D24_CODE:
		ADC #$30
		TAY 
		LDA #$00
		RTS 
*=$9D3A

init_sprite_ptrs:
		.BYTE	$0D, $0E, $0F, $20, $21, $22, $23, $0F, $00, $00, $00, $00, $00, $00, $00, $00

sprite_ptrs:		.BYTE	$16, $D8, $16, $D4, $16, $8B, $52, $4E, $EC, $A6, $70, $10, $F0, $10, $80, $10

sprite_x_high_bits:		.BYTE	$00

_9D5B_DATA:
*=$9D6E

table_with_timed_stuff:		.BYTE	$76, $FA, $EA, $92, $01, $C8, $C8, $A3

table_with_timers:		.BYTE	$2A, $12, $32, $20, $0E, $2E, $2A, $2A
*=$9D88

joystick_state:		.BYTE	$7E

sprite_coll_state:		.BYTE	$00
*=$9D8C

_9D8C_DATA:
*=$9D91

_9D91_DATA:
*=$9D92

_9D92_DATA:
*=$9D93

_9D93_DATA:
*=$9D98

_9D98_DATA:
*=$9D9B

_9D9B_DATA:
*=$9D9E

_9D9E_DATA:
*=$9D9F

_9D9F_DATA:
*=$9DA4

init_sprite_coords:		.BYTE	$A0
*=$9DB9

_9DB9_DATA:
*=$9DD3

_9DD3_DATA:
*=$9DD4

_9DD4_DATA:
*=$9DD5

_9DD5_DATA:
*=$9DD6

_9DD6_DATA:
*=$9DD7

_9DD7_DATA:
*=$9DD8

_9DD8_DATA:
*=$9DD9

_9DD9_DATA:
*=$9DDA

_9DDA_DATA:
*=$9E00

start:
		LDA #$00
		STA $D020
		STA $D021
		JSR _E544_CODE
		LDX #$68

_9E0D_CODE:
		LDA crack_trainer_msg, X
		STA vic_screen, X
		LDA #$0F
		STA vic_color_ram, X
		DEX 
		BPL _9E0D_CODE
		CLI 

_9E1C_CODE:
		JSR _FFE4_CODE
		CMP #$4E
		BEQ no_trainer
		CMP #$59
		BNE _9E1C_CODE
		LDA #$2C
		STA $91DC

no_trainer:
		LDA #$9E
		STA $0805
		JMP start_game
*=$9E40

crack_trainer_msg:
		.BYTE	$03
*=$9F1C

install_trainer:
		ISC $00FF, X
		BRK 
*=$D000

vic_sprite_coords:
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF

vic_sprite_x_high_bits:		.BYTE	$FF
*=$D015

vic_sprite_enable:		.BYTE	$00
*=$D01E

vic_sprite_coll:		.BYTE	$FF
*=$D027

vic_sprite_colors:		.BYTE	$FF, $FF, $FF, $00, $00, $00, $00, $FF
*=$D400

sid_base:		.BYTE	$FF
*=$D418

sid_vol_filter:		.BYTE	$FF
*=$D800

vic_color_ram:		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $BF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FD, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $04, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $04, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $04, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FE
		.BYTE	$FF, $FF, $02, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FD, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $7F, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $80, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FD, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $DF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $02, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF
		.BYTE	$FF, $FF, $00, $00, $00, $00, $FF, $FF
*=$DC01

vic_joystick1:		.BYTE	$FF
*=$DC04

vic_timer_a:		.BYTE	$00
*=$E544

_E544_CODE:
		BRK 
*=$FFE1

_FFE1_CODE:
		ISC $0000, X

_FFE4_CODE:
		BRK 