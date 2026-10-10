
.virtual $0002
; ---- zero page ----
; the road map row at the top of the screen; counts down as the road scrolls
road_row:		.byte	?
.endv

.virtual $0004
; the screen's fine scroll, 0-7
fine_scroll:		.byte	?
; scroll speed in eighths of a row per frame
speed:		.byte	?
max_speed:		.byte	?
; 0 = in the left lane, 1 = in the right lane, 2 = moving left, 3 = moving right
car_state:		.byte	?
; index into car_x while the car changes lanes
car_step:		.byte	?
; the current stage's index into the wall tables
difficulty:		.byte	?
.endv

.virtual $00d0
music_pointer:		.word	?
.endv

.virtual $00fb
draw_pointer:		.word	?
draw_pointer2:		.word	?
.endv

*=$0801

; ---- start-up ----
; BASIC stub: SYS 2061
basic_stub:
		.byte	$0b, $08, $14, $00, $9e, $32, $30, $36, $31, $00, $00, $00
; the decruncher's start, still in memory but no longer used
decruncher_leftover:
		.byte	$a0, $00, $ba, $bd, $75, $11, $9d, $fc, $00, $ca, $d0, $f7, $4c, $40, $11, $80
		.byte	$00, $78, $2d

; where the decruncher jumps to
start:
		sei 
		lda #$35
		sta $01
		lda #$7f
		sta cia1_interrupt_control
		sta cia2_interrupt_control
		lda cia1_interrupt_control
		lda cia2_interrupt_control
		lda #$01
		sta vic_irq_enable
		lsr vic_irq_status
		lda #$f9
		sta raster
		lda #$db
		sta irq_vector
		lda #$09
		sta irq_vector + $1
		lda #$1b
		sta vic_control1
		cli 

; ---- game ----
new_game:
		jsr clear_screen
		jsr wait_frame
		jsr init_video
		jsr init_road
		jsr init_walls
		jsr reset_score
		lda #$00
		sta game_loop + 1
		sta car_step
		lda #$03
		sta car_state
		lda #$01
		sta stage
		jsr music_init
		lda sprite_background_collision
		jsr title

; waits until irq_bottom sets the operand of the lda to 1
game_loop:
		lda #$01
		beq game_loop
		lda speed
		clc 
		adc fine_scroll
		tax 
		and #$07
		sta fine_scroll
		txa 
		lsr 
		lsr 
		lsr 
		sta score_add + $4
		beq l08BE

l0892:
		pha 
		dec road_row
		ldx difficulty
		jsr next_row
		ldx road_row
		lda #$00
		ldy left_wall
		cpy #$01
		bmi l08A7
		lda #$01

l08A7:
		sta left_road, x
		lda #$00
		ldy right_wall
		cpy #$01
		bmi l08B5
		lda #$01

l08B5:
		sta right_road, x
		pla 
		sec 
		sbc #$01
		bne l0892

l08BE:
		lda #$82
		inc l08BE + 1
		and #$3f
		bne l08CF
		lda speed
		cmp max_speed
		bcs l08CF
		inc speed

l08CF:
		lda fine_scroll
		clc 
		adc #$05
		sta $0a0b
		lda fine_scroll
		clc 
		adc #$f6
		sta $0a32
		lda road_row
		sta l0B93 + 1
		lda #$80
		sta l0B93 + 2
		lda #$43
		sta draw_pointer
		lda #$40
		sta draw_pointer + $1
		jsr draw_road_sprite
		lda road_row
		sta l0B93 + 1
		lda #$81
		sta l0B93 + 2
		lda #$85
		sta draw_pointer
		lda #$40
		sta draw_pointer + $1
		jsr draw_road_sprite
		lda road_row
		clc 
		adc #$05
		sta l0926 + 1
		sta $092c
		lda #$08
		sta draw_pointer
		lda #$44

; where the CPU was when the snapshot was taken
snapshot_pc:
		sta draw_pointer + $1
		sta draw_pointer2 + $1
		lda #$1f
		sta draw_pointer2
		ldx #$19
		ldy #$00

l0926:
		lda left_road + $fd
; operands the game loop changes to step down the road map
left_road_source = $0927
		sta (draw_pointer), y
		lda right_road + $fd
right_road_source = $092c
		sta (draw_pointer2), y
		tya 
		clc 
		adc #$28
		tay 
		bcc l093B
		inc draw_pointer + $1
		inc draw_pointer2 + $1

l093B:
		inc l0926 + 1
		inc $092c
		dex 
		bne l0926
		lda road_row
		clc 
		adc #$1e
		sta l0B93 + 1
		lda #$80
		sta l0B93 + 2
		lda #$c0
		sta draw_pointer
		lda #$40
		sta draw_pointer + $1
		jsr draw_road_sprite
		lda road_row
		clc 
		adc #$1e
		sta l0B93 + 1
		lda #$81
		sta l0B93 + 2
		lda #$02
		sta draw_pointer
		lda #$41
		sta draw_pointer + $1
		jsr draw_road_sprite
		lda sprite_background_collision
		and #$01
		bne steer
		lda car_state
		cmp #$02
		bcs steer
		lda #$00
		sta volume_filter_mode
		ldy #$04

l0988:
		ldx #$1f

l098A:
		lda flash_colors, x
		sta sprite0_color
		jsr wait_frame
		dex 
		bpl l098A
		dey 
		bpl l0988
		jsr update_high_score
		jmp new_game

steer:
		jsr read_joystick
		ldx car_step
		lda car_state
		cmp #$02
		bcc position_car
		bne l09B9
		dec car_step
		bne position_car
		ldx #$00
		stx car_step
		stx car_state
		jmp position_car

l09B9:
		inx 
		stx car_step
		cpx #$0f
		bne position_car
		lda #$01
		sta car_state

position_car:
		lda car_x, x
		sta sprite0_x
		jsr add_score
		jsr check_stage
		jsr music_play
		lda #$00
		sta game_loop + 1
		jmp game_loop

irq_bottom:
		pha 
		lda vic_control1
		and #$77
		sta vic_control1
		lda #$01
		sta game_loop + 1
		lsr vic_irq_status
		lda #$02
		sta raster
		lda #$fd
		sta irq_vector
		lda #$09
		sta irq_vector + $1
		pla 
		rti 

irq:
		pha 
		lda vic_control1
		and #$78
		ora fine_scroll
		ora #$08
		sta vic_control1
		lda #$07
; the road sprites' y in each half of the screen, set from fine_scroll
upper_road_y = $0a0b
		sta sprite1_y
		sta sprite2_y
		lda #$01
		sta sprite_pointers + $1
		lda #$02
		sta sprite_pointers + $2
		lda #$c0
		sta raster
		lda #$30
		sta irq_vector
		lda #$0a
		sta irq_vector + $1
		lsr vic_irq_status
		pla 
		rti 

irq_lower:
		pha 
		lda #$f8
lower_road_y = $0a32
		sta sprite1_y
		sta sprite2_y
		lda #$03
		sta sprite_pointers + $1
		lda #$04
		sta sprite_pointers + $2
		lda #$f9
		sta raster
		lda #$db
		sta irq_vector
		lda #$09
		sta irq_vector + $1
		lsr vic_irq_status
		pla 
		rti 

init_road:
		ldx #$00
		stx road_row
		stx fine_scroll
		lda #$01

l0A5F:
		sta left_road, x
		sta right_road, x
		inx 
		bne l0A5F
		stx speed
		lda #$05
		sta max_speed
		lda #$00
		sta difficulty
		rts 

wait_frame:
		bit vic_control1
		bmi wait_frame

l0A78:
		bit vic_control1
		bpl l0A78
		rts 

init_video:
		lda #$00
		sta idle_byte
		lda #$06
		sta border_color
		sta background_color
		lda #$01
		sta sprite0_color
		sta sprite3_color
		sta sprite4_color
		sta sprite5_color
		sta sprite6_color
		sta sprite7_color
		ldx #$00
		lda #$0f
		sta sprite1_color
		sta sprite2_color

l0AA9:
		sta color_ram, x
		sta color_ram + $100, x
		sta color_ram + $200, x
		sta color_ram + $300, x
		dex 
		bne l0AA9
		lda #$02
		sta cia2_port_a
		lda #$1e
		sta vic_memory
		lda #$1b
		sta vic_control1
		lda #$ff
		sta sprite_enable
		lda #$01
		sta sprite_priority
		lda #$06
		sta sprite_expand_y
		lda #$08
		sta sprite_pointers
		lda #$d2
		ldx #$08

l0ADF:
		sta sprite3_x, x
		sec 
		sbc #$10
		dex 
		dex 
		bpl l0ADF
		lda #$ff
		sta sprite3_y
		sta sprite4_y
		sta sprite5_y
		sta sprite6_y
		sta sprite7_y
		lda #$04
		sta sprites_x_msb
		lda #$58
		sta sprite1_x
		lda #$00
		sta sprite2_x
		lda #$e0
		sta sprite0_y
		rts 

read_joystick:
		ldx car_state
		cpx #$02
		bcc l0B16
		rts 

l0B16:
		lda cia1_port_a
		and #$0c
		cmp #$04
		bne l0B2D
		cpx #$00
		beq l0B24
		rts 

l0B24:
		ldx #$03
		stx car_state
		lda #$00
		sta car_step

l0B2C:
		rts 

l0B2D:
		cmp #$08
		bne l0B2C
		cpx #$01
		bne l0B2C
		inc car_state
		lda #$0f
		sta car_step
		rts 

; moves to the next stage when the score is high enough
check_stage:
		lda score + $1
		lsr 
		cmp stage
		bcc l0B65
		ldx stage
		inc stage
		dex 
		lda stage_color, x
		sta background_color
		sta border_color
		lda stage_max_speed, x
		sta max_speed
		lda stage_difficulty, x
		sta difficulty
		lda stage_car_sprite, x
		sta sprite_pointers

l0B65:
		rts 

stage:
		.byte	$01
stage_color:
		.byte	$02, $04, $0b, $00
stage_max_speed:
		.byte	$06, $07, $08, $08
stage_difficulty:
		.byte	$00, $00, $00, $01
stage_car_sprite:
		.byte	$07, $06, $05, $05

clear_screen:
		lax #$00

l0B79:
		sta screen, x
		sta screen + $100, x
		sta screen + $200, x
		sta screen + $2e8, x
		sta road_sprites, x
		dex 
		bne l0B79
		sta sprite0_x
		rts 

; draws one road sprite's column of walls from the road map
draw_road_sprite:
		ldy #$00
		ldx #$04

l0B93:
		lda right_road + $fd
d0B94 = $0b94
		beq l0B9A
		lda #$ff

l0B9A:
		sta (draw_pointer), y
		iny 
		iny 
		iny 
		sta (draw_pointer), y
		iny 
		iny 
		iny 
		sta (draw_pointer), y
		iny 
		iny 
		iny 
		sta (draw_pointer), y
		iny 
		iny 
		iny 
		inc l0B93 + 1
		dex 
		bpl l0B93
		rts 

reset_score:
		lda #$00
		sta score
		sta score + $1
		sta score + $2
		sta score + $3
		sta score + $4
		rts 

; adds score_add to score, one decimal digit per byte
add_score:
		ldx #$04
		lda #$00

l0BCB:
		sta score_carry, x
		dex 
		bpl l0BCB
		ldx #$04

l0BD3:
		lda score, x
		clc 
		adc score_add, x
		adc score_carry, x
		and #$0f
		cmp #$0a
		bcc l0BE9
		inc score_add + $4, x
		sec 
		sbc #$0a

l0BE9:
		sta score, x
		dex 
		bpl l0BD3
		ldx #$04

l0BF1:
		lda score, x
		ora #$20
		sta sprite_pointers + $3, x
		dex 
		bpl l0BF1
		rts 

score:
		.byte	$00, $00, $00, $00, $08
; the last digit is the number of rows scrolled this frame
score_add:
		.byte	$00, $00, $00, $00, $00
score_carry:
		.byte	$00, $00, $00, $00, $00
high_score:
		.byte	$00, $00, $00, $00, $00

update_high_score:
		ldx #$00

l0C13:
		lda high_score, x
		cmp score, x
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
		lda score, x
		sta high_score, x
		dex 
		bpl l0C2A

l0C33:
		ldx #$04

l0C35:
		lda high_score, x
		ora #$20
		sta sprite_pointers + $3, x
		dex 
		bpl l0C35
		rts 

flash_colors:
		.byte	$00, $09, $0b, $08, $0c, $0c, $0f, $0f, $0f, $07, $07, $07, $07, $01, $01, $01
		.byte	$01, $01, $01, $01, $07, $07, $07, $07, $0f, $0f, $0f, $0c, $0c, $08, $0b, $09

; the title: shows the logo and flashes it until fire is pressed
title:
		ldx #$0b

l0C63:
		txa 
		sta screen + $1ed, x
		clc 
		adc #$0a
		sta screen + $215, x
		dex 
		cpx #$01
		bne l0C63
		jsr update_high_score
		ldx #$1f

l0C77:
		jsr wait_frame
		ldy #$09
		lda flash_colors, x

l0C7F:
		sta color_ram + $1ef, y
		sta color_ram + $217, y
		dey 
		bpl l0C7F
		dex 
		txa 
		and #$1f
		tax 
		lda cia1_port_a
		and #$10
		bne l0C77
		jsr clear_screen
		rts 

; the length of the current wall on each side; 0 = no wall
left_wall:
		.byte	$09
right_wall:		.byte	$09
; per difficulty
wall_switch_length:
		.byte	$03, $03, $04, $04, $04, $04, $05, $05, $05, $06
wall_max_length:
		.byte	$10, $0f, $0f, $0e, $0e, $0d, $0d, $0c, $0c, $0c
wall_end_chance:
		.byte	$19, $23, $2d, $38, $42, $4c, $56, $60, $6b, $75
wall_start_chance:
		.byte	$0c, $11, $16, $1c, $21, $26, $2b, $30, $35, $3a

init_walls:
		lda #$01
		sta left_wall
		sta right_wall
		lda #$ff
		sta random_seed
		sta random_seed + $1
		sta random_seed + $2
		sta random_seed + $3
		rts 

; builds the next row of the road map
next_row:
		lda left_wall
		beq l0CE1
		inc left_wall

l0CE1:
		lda right_wall
		beq l0CE9
		inc right_wall

l0CE9:
		jsr random
		lda left_wall
		cmp wall_max_length, x
		bcc l0D0A
		lda random_seed
		cmp wall_end_chance, x
		bcs l0D1C
		lda #$fe
		sta left_wall
		lda wall_switch_length, x
		sta right_wall
		jmp l0D1C

l0D0A:
		lda left_wall
		bne l0D1C
		lda random_seed + $2
		cmp wall_start_chance, x
		bcs l0D1C
		lda #$01
		sta left_wall

l0D1C:
		lda right_wall
		cmp wall_max_length, x
		bcc l0D3A
		lda random_seed + $1
		cmp wall_end_chance, x
		bcs l0D4C
		lda #$fe
		sta right_wall
		lda wall_switch_length, x
		sta left_wall
		jmp l0D4C

l0D3A:
		lda right_wall
		bne l0D4C
		lda random_seed + $3
		cmp wall_start_chance, x
		bcs l0D4C
		lda #$01
		sta right_wall

l0D4C:
		rts 

; a 32-bit Galois LFSR; returns its low byte
random:
		asl random_seed
		rol random_seed + $1
		rol random_seed + $2
		rol random_seed + $3
		bcc l0D7B
		lda random_seed
		eor #$b7
		sta random_seed
		lda random_seed + $1
		eor #$1d
		sta random_seed + $1
		lda random_seed + $2
		eor #$c1
		sta random_seed + $2
		lda random_seed + $3
		eor #$04
		sta random_seed + $3

l0D7B:
		lda random_seed
		rts 

random_seed:
		.dword	$4e08bfb4

unused_0d83:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
; sprite 0's x for each car_step, easing between the lanes
car_x:
		.byte	$56, $57, $5d, $66, $71, $80, $90, $a1, $b2, $c3, $d4, $e2, $ed, $f6, $fc, $fe
*=$1000

; ---- music player ----
music_init:
		jmp l100C

music_play:
		jmp l1014

music_set_volume:
		jmp l1010

; unused jump table entry

		jmp l1173

l100C:
		sta $1017
		rts 

l1010:
		sta $10a0
		rts 

l1014:
		ldx #$00
		ldy #$ff
; operands the player changes
init_flag = $1017
		bmi l104A
		txa 
		ldx #$29

l101D:
		sta order_position, x
		dex 
		bpl l101D
		sta filter_cutoff
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
		sta tempo, x
		lda #$01
		sta tick, x
		sta instrument, x
		jmp l123E

l104A:
		ldy #$01
		beq l1093
		lda #$00
filter_steps = $104f
		bne l1075
		lda filter_left, y
		beq l1069
		bpl l1072
		asl 
		sta $109e
		lda filter_right, y
		sta $1099
		lda filter_left + $1, y
		bne l1087
		iny 

l1069:
		lda filter_right, y
		sta l1093 + 1
		jmp l1084

l1072:
		sta $104f

l1075:
		lda filter_right, y
		clc 
		adc l1093 + 1
		sta l1093 + 1
		dec $104f
		bne l1095

l1084:
		lda filter_left + $1, y

l1087:
		cmp #$ff
		iny 
		tya 
		bcc l1090
		lda filter_right, y

l1090:
		sta l104A + 1

l1093:
		lda #$05

l1095:
		sta filter_cutoff + $1
		lda #$f1
filter_resonance = $1099
		sta filter_control
		lda #$10
filter_type = $109e
		ora #$0f
master_volume = $10a0
		sta volume_filter_mode
		jsr l10AE
		ldx #$07
		jsr l10AE
		ldx #$0e

l10AE:
		dec tick, x
		beq l10BE
		bpl l10BB
		lda tempo, x
		sta tick, x

l10BB:
		jmp l113D

l10BE:
		lda pattern_position, x
		bne l10F3
		ldy order_list_index, x
		lda order_list_lo, y
		sta music_pointer
		lda order_list_hi, y
		sta music_pointer + $1
		ldy order_position, x
		lda (music_pointer), y
		cmp #$ff
		bcc l10DF
		iny 
		lda (music_pointer), y
		tay 
		lda (music_pointer), y

l10DF:
		cmp #$e0
		bcc l10EB
		sbc #$f0
		sta transpose, x
		iny 
		lda (music_pointer), y

l10EB:
		sta pattern_number, x
		iny 
		tya 
		sta order_position, x

l10F3:
		ldy instrument, x
		lda new_note, x
		beq l113D
		sec 
		sbc #$60
		sta note, x
		lda #$00
		sta new_note, x
		lda #$09
		sta waveform, x
		inc gate, x
		lda instrument_pulse, y
		beq l111B
		sta pulse_position, x
		lda #$00
		sta pulse_timer, x

l111B:
		lda instrument_filter, y
		beq l1128
		sta l104A + 1
		lda #$00
		sta $104f

l1128:
		lda instrument_wave, y
		sta wave_position, x
		lda instrument_sustain_release, y
		sta sustain_release, x
		lda instrument_attack_decay, y
		sta attack_decay, x
		jmp l121A

l113D:
		ldy wave_position, x
		beq l1173
		lda wave_left, y
		beq l114A
		sta waveform, x

l114A:
		lda wave_left + $1, y
		cmp #$ff
		iny 
		tya 
		bcc l1157
		clc 
		lda wave_right + $1, y

l1157:
		sta wave_position, x
		lda wave_right, y
		beq l1173
		bpl l1166
		adc note, x
		and #$7f

l1166:
		tay 
		lda frequency_lo, y
		sta frequency, x
		lda frequency_hi, y
		sta frequency + $1, x

l1173:
		lda tick, x
		cmp #$02
		beq l11C8
		ldy pulse_position, x
		beq l11C5
		ora pattern_position, x
		beq l11C5
		lda pulse_timer, x
		bne l119D
		lda pulse_left, y
		bpl l119A
		sta pulse_width + $1, x
		lda pulse_right, y
		sta pulse_width, x
		jmp l11B6

l119A:
		sta pulse_timer, x

l119D:
		lda pulse_right, y
		clc 
		bpl l11A6
		dec pulse_width + $1, x

l11A6:
		adc pulse_width, x
		sta pulse_width, x
		bcc l11B1
		inc pulse_width + $1, x

l11B1:
		dec pulse_timer, x
		bne l11C5

l11B6:
		lda pulse_left + $1, y
		cmp #$ff
		iny 
		tya 
		bcc l11C2
		lda pulse_right, y

l11C2:
		sta pulse_position, x

l11C5:
		jmp l121A

l11C8:
		ldy pattern_number, x
		lda pattern_lo, y
		sta music_pointer
		lda pattern_hi, y
		sta music_pointer + $1
		ldy pattern_position, x
		lda (music_pointer), y
		cmp #$40
		bcc l11F2
		cmp #$c0
		bcc l11F8
		lda note_delay, x
		bne l11E9
		lda (music_pointer), y

l11E9:
		adc #$00
		sta note_delay, x
		beq l1211
		bne l121A

l11F2:
		sta instrument, x
		iny 
		lda (music_pointer), y

l11F8:
		cmp #$bd
		beq l1211
		adc transpose, x
		sta new_note, x
		lda #$00
		sta sustain_release, x
		lda #$0f
		sta attack_decay, x
		lda #$fe
		sta gate, x

l1211:
		iny 
		lda (music_pointer), y
		beq l1217
		tya 

l1217:
		sta pattern_position, x

l121A:
		lda attack_decay, x
		sta voice1_attack_decay, x
		lda sustain_release, x
		sta voice1_sustain_release, x
		lda pulse_width, x
		sta voice1_pulse_width, x
		lda pulse_width + $1, x
		sta voice1_pulse_width + $1, x
		lda frequency, x
		sta voice1_frequency, x
		lda frequency + $1, x
		sta voice1_frequency + $1, x

l123E:
		lda waveform, x
		and gate, x
		sta voice1_control, x
		rts 

; per-channel state, 7 bytes apart for channels 1, 2 and 3
order_position:
		.byte	$02
transpose:		.byte	$00
		.byte	$00

pattern_position:
		.byte	$16
note_delay:		.byte	$00
		.byte	$00, $00, $02, $00, $00, $01, $fd, $00, $00, $02, $00, $00, $01, $fd, $00, $00
		.byte	$00, $00

new_note:
		.byte	$00
wave_position:		.byte	$01
waveform:		.byte	$09
pulse_position:		.byte	$01
pulse_timer:		.byte	$00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

order_list_index:
		.byte	$00
pattern_number:		.byte	$00
tempo:		.byte	$05
tick:		.byte	$00
note:		.byte	$13
instrument:		.byte	$01
gate:		.byte	$ff
		.byte	$01, $02, $05, $00, $00, $01, $fe, $02, $02, $05, $00, $00, $01, $fe, $00, $00
		.byte	$00

frequency:
		.word	$0343
pulse_width:		.word	$8d00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

attack_decay:
		.byte	$00
sustain_release:		.byte	$fa
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00

frequency_lo:
		.byte	$17, $27, $39, $4b, $5f, $74, $8a, $a1, $ba, $d4, $f0, $0e, $2d, $4e, $71, $96
		.byte	$be, $e8, $14, $43, $74, $a9, $e1, $1c, $5a, $9c, $e2, $2d, $7c, $cf, $28, $85
		.byte	$e8, $52, $c1, $37, $b4, $39, $c5, $5a, $f7, $9e, $4f, $0a, $d1, $a3, $82, $6e
		.byte	$68, $71, $8a, $b3, $ee, $3c, $9e, $15, $a2, $46, $04, $dc, $d0, $e2, $14, $67
		.byte	$dd, $79, $3c, $29, $44, $8d, $08, $b8, $a1, $c5, $28, $cd, $ba, $f1, $78, $53
		.byte	$87, $1a, $10, $71, $42, $89, $4f, $9b, $74, $e2, $f0, $a6, $0e, $33, $20, $ff
frequency_hi:
		.byte	$01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02
		.byte	$02, $02, $03, $03, $03, $03, $03, $04, $04, $04, $04, $05, $05, $05, $06, $06
		.byte	$06, $07, $07, $08, $08, $09, $09, $0a, $0a, $0b, $0c, $0d, $0d, $0e, $0f, $10
		.byte	$11, $12, $13, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20, $22, $24, $27, $29
		.byte	$2b, $2e, $31, $34, $37, $3a, $3e, $41, $45, $49, $4e, $52, $57, $5c, $62, $68
		.byte	$6e, $75, $7c, $83, $8b, $93, $9c, $a5, $af, $b9, $c4, $d0, $dd, $ea, $f8, $ff
order_list_lo:
		.byte	$46, $57, $68
order_list_hi:
		.byte	$14, $14, $14
pattern_lo:
		.byte	$79, $93, $bf, $c2, $d5, $ef, $04, $1e, $4a, $5f, $78
pattern_hi:
		.byte	$14, $14, $14, $14, $14, $14, $15, $15, $15, $15
; the tables below are indexed from 1: entry n is at label + n
instrument_attack_decay:
		.byte	$15, $00, $00, $00, $70, $00, $50, $00, $00, $00, $00
instrument_sustain_release:
		.byte	$00, $fa, $f7, $f7, $f4, $f9, $fa, $f9, $f9, $f9, $f9
instrument_wave:
		.byte	$f9, $01, $03, $08, $0c, $0e, $01, $15, $1c, $23, $2a
instrument_pulse:
		.byte	$32, $01, $00, $00, $00, $00, $03, $00, $00, $00, $00
instrument_filter:
		.byte	$00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
wave_left:
		.byte	$00, $40, $ff, $81, $10, $10, $10, $ff, $81, $10, $10, $10, $80, $ff, $20, $20
		.byte	$20, $20, $20, $20, $ff, $20, $20, $20, $20, $20, $20, $ff, $20, $20, $20, $20
		.byte	$20, $20, $ff, $20, $20, $20, $20, $20, $20, $ff, $81, $10, $10, $10, $10, $10
		.byte	$10, $ff, $20, $20, $20, $20, $20
wave_right:
		.byte	$20, $ff, $80, $00, $5f, $21, $20, $1f, $00, $5f, $2d, $2c, $2b, $5f, $00, $80
		.byte	$80, $83, $83, $87, $87, $0e, $f8, $f8, $fb, $fb, $80, $80, $15, $fb, $fb, $80
		.byte	$80, $84, $84, $1c, $fb, $fb, $80, $80, $85, $85, $23, $5f, $80, $fe, $fc, $f9
		.byte	$f5, $f0, $00, $80, $80, $84, $84, $87, $87
pulse_left:
		.byte	$32, $8d, $ff, $8e, $20, $20
pulse_right:
		.byte	$ff, $00, $00, $00, $fa, $06
filter_left:
		.byte	$04, $88, $00
filter_right:
		.byte	$ff, $f1, $05, $00
order_list1:
		.byte	$f0, $00, $00, $00, $00, $f0, $00, $00, $04, $06, $f4, $00, $00, $04, $0a, $ff
		.byte	$05
order_list2:
		.byte	$f0, $02, $02, $01, $01, $f0, $01, $01, $01, $07, $f4, $01, $01, $01, $07, $ff
		.byte	$05
order_list3:
		.byte	$f0, $02, $02, $02, $02, $f0, $03, $03, $05, $08, $f4, $03, $03, $05, $09, $ff
		.byte	$05
pattern0:
		.byte	$01, $75, $75, $75, $73, $75, $75, $75, $75, $75, $73, $75, $75, $75, $75, $75
		.byte	$73, $75, $75, $73, $73, $73, $70, $70, $73, $00
pattern1:
		.byte	$02, $84, $04, $bb, $02, $84, $03, $87, $02, $b4, $04, $bb, $02, $84, $84, $04
		.byte	$bb, $03, $87, $04, $bb, $bb, $02, $84, $04, $bb, $02, $84, $03, $87, $87, $04
		.byte	$bb, $02, $84, $04, $bb, $02, $84, $03, $87, $87, $87, $00
pattern2:
		.byte	$bd, $e9, $00
pattern3:
		.byte	$05, $99, $fb, $06, $aa, $ac, $fc, $aa, $a8, $aa, $a8, $a7, $a3, $a5, $bd, $0b
		.byte	$97, $fd, $00
pattern4:
		.byte	$01, $7d, $7d, $7d, $7c, $7d, $7d, $7d, $7d, $7d, $7c, $7d, $7d, $7c, $7c, $7c
		.byte	$7a, $7c, $7c, $7c, $7c, $7c, $7a, $7c, $7c, $00
pattern5:
		.byte	$07, $a1, $fb, $06, $ad, $ac, $ad, $ac, $aa, $a8, $07, $a0, $fb, $06, $ac, $aa
		.byte	$ac, $aa, $ac, $ad, $00
pattern6:
		.byte	$01, $7d, $7d, $7d, $7c, $7d, $7d, $7d, $7d, $7d, $7c, $7d, $7d, $77, $77, $77
		.byte	$72, $77, $77, $77, $77, $77, $72, $77, $77, $00
pattern7:
		.byte	$02, $84, $04, $bb, $02, $84, $03, $87, $02, $b4, $04, $bb, $02, $84, $84, $04
		.byte	$bb, $03, $87, $04, $bb, $bb, $0a, $8d, $04, $bb, $0a, $8d, $03, $87, $0a, $8b
		.byte	$04, $bb, $0a, $8b, $04, $bb, $0a, $8b, $89, $89, $89, $00
pattern8:
		.byte	$07, $a1, $fb, $06, $ad, $ac, $ad, $ac, $aa, $a8, $09, $9b, $bd, $9b, $bd, $9b
		.byte	$bd, $08, $9b, $fb, $00
pattern9:
		.byte	$07, $a1, $fb, $06, $ad, $ac, $ad, $ac, $aa, $a8, $09, $9b, $bd, $9b, $bd, $9b
		.byte	$bd, $07, $9f, $bd, $9f, $bd, $9f, $bd, $00
pattern10:
		.byte	$01, $7d, $7d, $7d, $7c, $7d, $7d, $7d, $7d, $7d, $7c, $7d, $7d, $77, $77, $77
		.byte	$72, $77, $77, $7b, $7b, $7b, $76, $7b, $7b, $00

.virtual $4040
; ---- video bank 1 ($4000-$7fff) ----
; four sprites the game draws the road walls into
road_sprites:
		.fill	256
.endv

*=$4140

car_sprites:
		.byte	$00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00
		.byte	$7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00
		.byte	$7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f
		.byte	$e0, $00, $7f, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00
		.byte	$7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f
		.byte	$e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00
		.byte	$7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f
		.byte	$e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0
		.byte	$00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $7f, $e0, $00, $00, $00, $00

.virtual $4400
screen:
		.fill	1000
.endv

.virtual $47f8
sprite_pointers:
		.fill	8
.endv

*=$4800

; the score's digits, one sprite each
digit_sprites:
		.byte	$0f, $e0, $00, $3f, $f8, $00, $7f, $fc, $00, $7c, $7c, $00, $f8, $3e, $00, $f8
		.byte	$3e, $00, $f8, $3e, $00, $f8, $3e, $00, $f8, $3e, $00, $f8, $3e, $00, $f8, $3e
		.byte	$00, $7c, $7c, $00, $7f, $fc, $00, $3f, $f8, $00, $0f, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$1f, $80, $00, $3f, $80, $00, $7f, $80, $00, $7f, $80, $00, $7f, $80, $00, $6f
		.byte	$80, $00, $4f, $80, $00, $0f, $80, $00, $0f, $80, $00, $0f, $80, $00, $0f, $80
		.byte	$00, $0f, $80, $00, $3f, $e0, $00, $3f, $e0, $00, $3f, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$1f, $e0, $00, $1f, $f8, $00, $1f, $fc, $00, $00, $7e, $00, $00, $3e, $00, $00
		.byte	$7e, $00, $0f, $fc, $00, $3f, $f8, $00, $7f, $e0, $00, $7c, $00, $00, $f8, $00
		.byte	$00, $f8, $00, $00, $ff, $fe, $00, $ff, $fe, $00, $ff, $fe, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$1f, $e0, $00, $1f, $f8, $00, $1f, $fc, $00, $00, $7e, $00, $00, $3e, $00, $00
		.byte	$7c, $00, $1f, $fc, $00, $1f, $f8, $00, $1f, $fc, $00, $00, $7c, $00, $00, $3e
		.byte	$00, $00, $7e, $00, $ff, $fc, $00, $ff, $f8, $00, $ff, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$f8, $3e, $00, $f8, $3e, $00, $f8, $3e, $00, $f8, $3e, $00, $f8, $3e, $00, $7c
		.byte	$3e, $00, $7f, $fe, $00, $3f, $fe, $00, $0f, $fe, $00, $00, $3e, $00, $00, $3e
		.byte	$00, $00, $3e, $00, $00, $3e, $00, $00, $3e, $00, $00, $3e, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$ff, $f0, $00, $ff, $f0, $00, $ff, $f0, $00, $f8, $00, $00, $f8, $00, $00, $7c
		.byte	$00, $00, $7f, $e0, $00, $3f, $f8, $00, $0f, $fc, $00, $00, $7e, $00, $00, $3e
		.byte	$00, $00, $7e, $00, $ff, $fc, $00, $ff, $f8, $00, $ff, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$0f, $f0, $00, $3f, $f0, $00, $7f, $f0, $00, $7c, $00, $00, $f8, $00, $00, $f8
		.byte	$00, $00, $ff, $e0, $00, $ff, $f8, $00, $ff, $fc, $00, $f8, $7e, $00, $f8, $3e
		.byte	$00, $7c, $7e, $00, $7f, $fc, $00, $3f, $f8, $00, $0f, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$ff, $e0, $00, $ff, $f8, $00, $ff, $fc, $00, $00, $7c, $00, $00, $3e, $00, $00
		.byte	$3e, $00, $1f, $fe, $00, $1f, $fe, $00, $1f, $fe, $00, $00, $3e, $00, $00, $3e
		.byte	$00, $00, $3e, $00, $00, $3e, $00, $00, $3e, $00, $00, $3e, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$0f, $e0, $00, $3f, $f8, $00, $7f, $fc, $00, $fc, $7e, $00, $f8, $3e, $00, $fc
		.byte	$7e, $00, $7f, $fc, $00, $3f, $f8, $00, $7f, $fc, $00, $fc, $7e, $00, $f8, $3e
		.byte	$00, $fc, $7e, $00, $7f, $fc, $00, $3f, $f8, $00, $0f, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$0f, $e0, $00, $3f, $f8, $00, $7f, $fc, $00, $fc, $7c, $00, $f8, $3e, $00, $fc
		.byte	$3e, $00, $7f, $fe, $00, $3f, $fe, $00, $0f, $fe, $00, $00, $3e, $00, $00, $3e
		.byte	$00, $00, $7c, $00, $1f, $fc, $00, $1f, $f8, $00, $1f, $e0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
*=$7800

charset:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$00, $0f, $3f, $3f, $7f, $79, $79, $7b, $00, $07, $c7, $c7, $e7, $e7, $e7, $e7
		.byte	$00, $87, $8f, $8f, $9f, $9e, $bc, $bc, $00, $c0, $80, $00, $00, $00, $00, $00
		.byte	$00, $ff, $ff, $ff, $ff, $f1, $f1, $f7, $00, $00, $c0, $c0, $e0, $e0, $e3, $e3
		.byte	$00, $00, $00, $00, $00, $f0, $fc, $fc, $00, $00, $00, $00, $00, $0f, $3f, $3f
		.byte	$00, $00, $00, $00, $00, $00, $c3, $e3, $00, $00, $00, $00, $00, $f0, $fc, $fc
		.byte	$33, $17, $07, $0f, $1f, $1f, $3f, $00, $c7, $c7, $87, $e7, $e7, $e7, $e7, $00
		.byte	$bc, $9e, $9e, $9f, $8f, $8f, $87, $00, $00, $00, $00, $00, $00, $80, $c0, $00
		.byte	$f7, $f7, $f7, $f7, $f3, $f3, $f1, $00, $c7, $87, $87, $c7, $c3, $e3, $e0, $00
		.byte	$fe, $9e, $9e, $fe, $fe, $fe, $fe, $00, $7f, $78, $79, $7f, $3f, $3f, $0f, $00
		.byte	$e7, $07, $e7, $e7, $e3, $c3, $00, $00, $9e, $fe, $fe, $e0, $f0, $f8, $f8, $00

.virtual $7fff
; the VIC shows the bank's last byte in the open border
idle_byte:		.byte	?
; ---- road map, built at run time ----
; one byte per row: 1 = wall
left_road:
		.fill	256
right_road:
		.fill	256
.endv

.virtual $d000
; ---- VIC-II ----
sprite0_x:		.byte	?
sprite0_y:		.byte	?
sprite1_x:		.byte	?
sprite1_y:		.byte	?
sprite2_x:		.byte	?
sprite2_y:		.byte	?
sprite3_x:		.byte	?
sprite3_y:		.byte	?
sprite4_x:		.byte	?
sprite4_y:		.byte	?
sprite5_x:		.byte	?
sprite5_y:		.byte	?
sprite6_x:		.byte	?
sprite6_y:		.byte	?
sprite7_x:		.byte	?
sprite7_y:		.byte	?
sprites_x_msb:		.byte	?
vic_control1:		.byte	?
raster:		.byte	?
light_pen_x:		.byte	?
light_pen_y:		.byte	?
sprite_enable:		.byte	?
vic_control2:		.byte	?
sprite_expand_y:		.byte	?
vic_memory:		.byte	?
vic_irq_status:		.byte	?
vic_irq_enable:		.byte	?
sprite_priority:		.byte	?
sprite_multicolor:		.byte	?
sprite_expand_x:		.byte	?
sprite_sprite_collision:		.byte	?
sprite_background_collision:		.byte	?
border_color:		.byte	?
background_color:		.byte	?
background_color1:		.byte	?
background_color2:		.byte	?
background_color3:		.byte	?
sprite_multicolor0:		.byte	?
sprite_multicolor1:		.byte	?
sprite0_color:		.byte	?
sprite1_color:		.byte	?
sprite2_color:		.byte	?
sprite3_color:		.byte	?
sprite4_color:		.byte	?
sprite5_color:		.byte	?
sprite6_color:		.byte	?
sprite7_color:		.byte	?
.endv

.virtual $d400
; ---- SID ----
voice1_frequency:		.word	?
voice1_pulse_width:		.word	?
voice1_control:		.byte	?
voice1_attack_decay:		.byte	?
voice1_sustain_release:		.byte	?
voice2_frequency:		.word	?
voice2_pulse_width:		.word	?
voice2_control:		.byte	?
voice2_attack_decay:		.byte	?
voice2_sustain_release:		.byte	?
voice3_frequency:		.word	?
voice3_pulse_width:		.word	?
voice3_control:		.byte	?
voice3_attack_decay:		.byte	?
voice3_sustain_release:		.byte	?
filter_cutoff:		.word	?
filter_control:		.byte	?
volume_filter_mode:		.byte	?
.endv

.virtual $d800
; ---- color RAM ----
color_ram:
		.fill	1000
.endv

.virtual $dc00
; ---- CIAs ----
cia1_port_a:		.byte	?
cia1_port_b:		.byte	?
.endv

.virtual $dc0d
cia1_interrupt_control:		.byte	?
.endv

.virtual $dd00
cia2_port_a:		.byte	?
.endv

.virtual $dd0d
cia2_interrupt_control:		.byte	?
.endv

*=$fffe

; the hardware IRQ vector ($01 = $35: KERNAL banked out, so it's RAM)
irq_vector:
		.addr	irq