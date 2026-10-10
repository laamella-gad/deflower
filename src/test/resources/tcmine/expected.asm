
.virtual $008e
stray_8e:		.byte	?
.endv

.virtual $00da
voice1_music:		.word	?
voice2_duration:		.byte	?
voice1_duration:		.byte	?
voice2_music:		.word	?
.endv

.virtual $00e4
air_pointer:		.word	?
.endv

.virtual $00fa
; TC Mine by Anthony Crowther, a Manic Miner like game. This is its machine code part,
; loaded at $c000 and driven by a BASIC program through SYS calls. The level data
; ($4000, $159 bytes per level), the enemy table ($2580, $12 bytes per level), the jump
; table ($8407) and the music ($8500 and $8b84) are loaded separately, so they are not
; in this file.
; ---- zero page ----
; the level data while drawing, the screen cell of the player otherwise
level_pointer:		.word	?
; the screen address while drawing; $fc is also the player's row
screen_pointer:		.word	?
draw_column:		.byte	?
draw_row:		.byte	?
.endv

.virtual $0314
irq_vector:		.addr	?
.endv

.virtual $033f
; set by the BASIC program
level:		.byte	?
.endv

.virtual $0341
; the enemy table entry of the level: per enemy x, y, direction, first frame, steps
enemies:
		.fill	10
unused_034b:		.byte	?
enemy_steps:
		.fill	4
.endv

.virtual $0400
screen:
		.fill	1000
unused_07e8:
		.fill	16
sprite_pointers:
		.fill	8
.endv

.virtual $3238
; the animated characters of the character set
animated_chars:
		.fill	16
conveyor_char_1:
		.fill	8
conveyor_char_2:
		.fill	8
.endv

.virtual $8407
; pairs of a flag and a height change, one pair per step of a jump
jump_table:
		.fill	90
.endv

*=$c000

; ---- draws the level from the level data onto the screen ----
; each level byte holds two tiles, each nibble indexing tile_chars_left/right
draw_level:
		lda #$40
		sta level_pointer + $1
		lda #$04
		sta screen_pointer + $1
		lda #$00
		jsr init_draw_pointers
		nop 
		sta draw_column
		sta draw_row
		ldx level

lC015:
		beq lC028
		lda level_pointer
		clc 
		adc #$59
		sta level_pointer
		lda level_pointer + $1
		adc #$01
		sta level_pointer + $1
		dex 
		jmp lC015

lC028:
		ldx #$00

lC02A:
		ldy #$00
		lda (level_pointer), y
		lsr 
		lsr 
		lsr 
		lsr 
		tay 
		lda tile_chars_left, y
		ldy draw_column
		sta (screen_pointer), y
		ldy #$00
		lda (level_pointer), y
		and #$0f
		tay 
		lda tile_chars_right, y
		inc draw_column
		ldy draw_column
		sta (screen_pointer), y
		inc draw_column
		inx 
		lda level_pointer
		clc 
		adc #$01
		sta level_pointer
		bcc lC058
		inc level_pointer + $1

lC058:
		cpx #$0e
		bcc lC02A
		inc draw_row
		lda screen_pointer
		clc 
		adc #$28
		sta screen_pointer
		bcc lC069
		inc screen_pointer + $1

lC069:
		ldx #$00
		stx draw_column
		ldx draw_row
		cpx #$18
		bcc lC028
		rts 

unused_c074:
		.byte	$00, $00

tile_chars_left:
		.text	" ACEIKGHMU"
tile_chars_right:
		.text	" BDFJLGHMU"

; an older copy of draw_level's start that was patched over; nothing calls it
unused_c08a:
		lda #$00
		sta level_pointer
		lda #$40
		sta level_pointer + $1
		ldx level

lC095:
		beq lC0A8
		lda level_pointer
		clc 
		adc #$59
		sta level_pointer
		lda level_pointer + $1
		adc #$01
		sta level_pointer + $1
		dex 
		jmp lC095

lC0A8:
		adc #$01

lC0AA:
		sta level_pointer + $1
		dex 

lC0AD:
		jmp lC095

unused_c0b0:
		cpy #$0e
		bne lC0AD
		inx 
		lda level_pointer
		clc 
		adc #$0e
		sta level_pointer
		bcc lC0C0
		inc level_pointer + $1

lC0C0:
		cpx #$19
		bne lC0AA
		rts 

install_irq:
		lda #$00
		sta cia1_timer_a_control
		sei 
		lda #$01
		sta vic_irq_status
		sta vic_irq_enable
		lda #$00
		sta vic_raster
		sta vic_control
		lda #$e7
		sta irq_vector
		lda #$c0
		sta irq_vector + $1
		cli 
		rts 

; animates the characters and the enemies, then continues in the KERNAL
irq:
		lda #$01
		sta vic_irq_status
		lda #$00
		sta vic_raster
		lda #$1b
		sta vic_control
		dec frame_counter
		lda frame_counter
		and #$07
		sta frame_counter
		tax 
		lda #$ea
		sta conveyor_char_1, x
		lda #$aa
		sta conveyor_char_2, x
		txa 
		clc 
		adc #$01
		and #$07
		tax 
		lda #$e0
		sta conveyor_char_1, x
		lda #$0e
		sta conveyor_char_2, x
		lda frame_counter
		lsr 
		nop 
		bcc lC14F
		lda frame_counter
		lsr 
		tax 
		lda char_animation_bits, x
		sta animated_chars
		sta animated_chars + $1
		sta animated_chars + $f
		sta animated_chars + $e
		lda #$07
		sec 
		sbc frame_counter
		lsr 
		tax 
		lda char_animation_bits, x
		sta animated_chars + $6
		sta animated_chars + $7
		sta animated_chars + $8
		sta animated_chars + $9

lC14F:
		jmp move_enemies

char_animation_bits:
		.byte	$80, $20, $08, $02
unused_c156:
		.byte	$ff, $bf, $ff, $00, $ff, $00

init_player:
		lda #$d4
		sta vic_sprite_coords
		lda #$55
		sta vic_sprite_coords + $1
		lda #$ff
		sta vic_sprite_multicolor
		sta vic_sprite_enable
		lda #$80
		sta sprite_pointers
		rts 

; joystick port 2, or Z for left, X for right and right shift for jump
controls:
		.byte	$0b

read_controls:
		lda #$ff
		sta cia1_port_a
		lda cia1_port_a
		sta controls
		lda #$fd
		sta cia1_port_a
		lda cia1_port_b
		and #$10
		bne lC19C
		lda controls
		and #$04
		beq lC1B8
		lda controls
		sec 
		sbc #$04
		jmp lC1B5

lC19C:
		lda #$fb
		sta cia1_port_a
		lda cia1_port_b
		and #$80
		bne lC1B8
		lda controls
		and #$08
		beq lC1B8
		lda controls
		sec 
		sbc #$08

lC1B5:
		sta controls

lC1B8:
		lda #$bf
		sta cia1_port_a
		lda cia1_port_b
		and #$10
		bne lC1CD
		lda controls
		clc 
		adc #$10
		sta controls

lC1CD:
		rts 

unused_c1ce:
		.byte	$ea

; points level_pointer at the screen cell of the player
find_player_cell:
		lda #$00
		sta level_pointer
		lda #$04
		sta level_pointer + $1
		lda vic_sprite_coords
		sec 
		sbc #$14
		lsr 
		lsr 
		lsr 
		sta level_pointer
		lda vic_sprite_coords + $1
		sec 
		sbc #$35
		lsr 
		lsr 
		lsr 
		sta screen_pointer
		ldx screen_pointer

lC1EF:
		beq lC200
		lda level_pointer
		clc 
		adc #$28
		sta level_pointer
		bcc lC1FC
		inc level_pointer + $1

lC1FC:
		dex 
		jmp lC1EF

lC200:
		rts 

; C set when the character at (level_pointer),y is a wall
is_wall:
		lda (level_pointer), y
		cmp #$41
		beq lC20D
		cmp #$42
		beq lC20D
		clc 
		rts 

lC20D:
		sec 
		rts 

unused_c20f:
		.byte	$ea

walk:
		lda controls
		and #$04
		bne lC220
		dec vic_sprite_coords
		jsr check_walls
		inc vic_sprite_coords

lC220:
		lda controls
		and #$08
		bne lC230
		inc vic_sprite_coords
		jsr check_walls
		dec vic_sprite_coords

lC230:
		jmp continue_walk

check_walls:
		jsr find_player_cell
		ldy #$29
		jsr is_wall
		bcs lC245
		ldy #$51
		jsr is_wall
		bcs lC245
		rts 

lC245:
		lda #$ff
		sta controls
		rts 

continue_walk:
		jmp check_slope

check_floor:
		ldy #$79
		lda (level_pointer), y
		cmp #$20
		bne lC25F
		lda #$ff
		sta controls
		jmp fall

unused_c25e:
		rts 

lC25F:
		cmp #$4d
		bcc lC26E
		cmp #$54
		beq lC271
		bcs lC26E
		clc 
		adc #$01

lC26C:
		sta (level_pointer), y

lC26E:
		jmp not_falling

lC271:
		lda #$20
		jmp lC26C

animate_player:
		lda frame_counter
		lsr 
		bcc lC2B6
		lda controls
		and #$04
		bne lC299
		inc sprite_pointers
		lda sprite_pointers
		cmp #$80
		bcc lC294
		cmp #$84
		bcs lC294
		jmp lC299

lC294:
		lda #$80
		sta sprite_pointers

lC299:
		lda controls
		and #$08
		bne lC2B6
		dec sprite_pointers
		lda sprite_pointers
		cmp #$84
		bcc lC2B1
		cmp #$88
		bcs lC2B1
		jmp lC2B6

lC2B1:
		lda #$87
		sta sprite_pointers

lC2B6:
		lda vic_sprite_coords + $1
		and #$07
		cmp #$05
		beq lC2C7
		lda #$ff
		sta controls
		inc vic_sprite_coords + $1

lC2C7:
		rts 

jump_direction:
		.byte	$0b
; 0 when not jumping, otherwise the index into jump_table
jump_step:		.byte	$35

start_jump:
		lda controls
		and #$10
		bne lC2DC
		lda #$01
		sta jump_step
		lda controls
		sta jump_direction

lC2DC:
		rts 

jump:
		ldx jump_step
		jsr jump_height
		sec 
		sbc jump_table + $1, x
		sta vic_sprite_coords + $1
		jmp check_landing

next_jump_step:
		lda #$00
		sta controls
		lda jump_table, x
		beq lC2FA
		jsr jump_sideways

lC2FA:
		inc jump_step
		inc jump_step
		lda jump_step
		cmp #$59
		bcc lC30C
		lda #$00
		sta jump_step

lC30C:
		rts 

jump_sideways:
		jsr jump_direction_controls
		and #$08
		bne lC317
		inc vic_sprite_coords

lC317:
		lda controls
		and #$04
		bne lC321
		dec vic_sprite_coords

lC321:
		rts 

check_landing:
		jsr find_player_cell
		ldy #$79
		lda (level_pointer), y
		cmp #$20
		beq lC343
		lda vic_sprite_coords + $1
		and #$07
		cmp #$05
		bne lC343
		lda jump_step
		cmp #$26
		bcc lC343
		lda #$00
		sta jump_step
		rts 

lC343:
		ldx jump_step
		jmp next_jump_step

unused_c349:
		.byte	$00, $ff, $00, $ff, $00, $ff, $00

; plays the level until the player dies, the air runs out, or the level is done
main_loop:
		jsr read_controls

lC353:
		lda vic_raster
		cmp #$ff
		bne lC353
		lda jump_step
		bne lC368
		jsr walk
		jsr check_jump
		jmp lC36E

lC368:
		jsr jump
		jmp lC382

lC36E:
		jsr conveyor
		and #$08
		bne lC378
		inc vic_sprite_coords

lC378:
		lda controls
		and #$04
		bne lC382
		dec vic_sprite_coords

lC382:
		jmp tick_music

fall:
		inc vic_sprite_coords + $1
		lda #$01
		sta @w stray_8e
		rts 

; never set: fall stores into $008e instead of here
falling:
		.byte	$00

not_falling:
		lda #$00
		sta falling
		jmp animate_player

check_jump:
		lda falling
		bne lC39F
		jmp start_jump

lC39F:
		rts 

jump_sideways_checked:
		lda controls
		and #$04
		bne lC3B0
		dec vic_sprite_coords
		jsr check_walls
		inc vic_sprite_coords

lC3B0:
		lda controls
		and #$08
		bne lC3C0
		inc vic_sprite_coords
		jsr check_walls
		dec vic_sprite_coords

lC3C0:
		rts 

jump_direction_controls:
		lda jump_direction
		sta controls
		jsr jump_sideways_checked
		lda controls
		rts 

jump_height:
		lda vic_sprite_coords + $1
		and #$07
		cmp #$05
		bne lC40A
		lda vic_sprite_coords + $1
		sec 
		sbc jump_table + $1, x
		sta vic_sprite_coords + $1
		jsr find_player_cell
		ldx jump_step
		lda vic_sprite_coords + $1
		clc 
		adc jump_table + $1, x
		sta vic_sprite_coords + $1
		ldy #$29
		lda (level_pointer), y
		cmp #$41
		beq lC400
		cmp #$42
		beq lC400
		jmp lC40A

lC400:
		lda vic_sprite_coords + $1
		clc 
		adc jump_table + $1, x
		sta vic_sprite_coords + $1

lC40A:
		lda vic_sprite_coords + $1
		rts 

init_draw_pointers:
		lda #$29
		sta screen_pointer
		lda #$00
		sta level_pointer
		rts 

unused_c417:
		.byte	$ea

conveyor:
		jsr check_conveyor
		lda controls
		rts 

check_conveyor:
		lda vic_sprite_coords + $1
		and #$07
		cmp #$05
		bne lC43A
		ldy #$79
		lda (level_pointer), y
		cmp #$47
		bne lC433
		dec vic_sprite_coords

lC433:
		cmp #$48
		bne lC43A
		inc vic_sprite_coords

lC43A:
		rts 

check_slope:
		jsr find_player_cell
		ldy #$51
		lda (level_pointer), y
		cmp #$49
		beq lC44D
		cmp #$4a
		beq lC44D
		jmp check_floor

lC44D:
		dec vic_sprite_coords + $1
		rts 

unused_c451:
		cmp #$05
		beq lC458
		dec vic_sprite_coords + $1

lC458:
		rts 

unused_c459:
		.byte	$ea, $ea
music_divider:		.byte	$03

tick_music:
		inc music_divider
		lda music_divider
		cmp #$04
		bcc lC46E
		lda #$00
		sta music_divider
		jsr play_music

lC46E:
		jmp check_pickups

play_music:
		dec voice2_duration
		lda voice2_duration
		bne lC4B4
		ldy #$00
		sty voice2_control
		sty voice3_control
		lda #$3a
		sta voice2_attack_decay
		lda #$1d
		sta voice3_attack_decay
		lda (voice2_music), y
		sta voice2_frequency + $1
		sta voice3_frequency + $1
		iny 
		lda (voice2_music), y
		sta voice2_frequency
		sta voice3_frequency
		iny 
		lda (voice2_music), y
		sta voice2_duration
		lda #$41
		sta voice3_control
		lda #$47
		sta voice2_control
		lda voice2_music
		clc 
		adc #$03
		sta voice2_music
		bcc lC4B4
		inc voice2_music + $1

lC4B4:
		dec voice1_duration
		lda voice1_duration
		bne lC4E4
		ldy #$00
		sty voice1_control
		lda #$28
		sta voice1_attack_decay
		lda (voice1_music), y
		sta voice1_frequency + $1
		iny 
		lda (voice1_music), y
		sta voice1_frequency
		lda #$25
		sta voice1_control
		iny 
		lda (voice1_music), y
		sta voice1_duration
		lda voice1_music
		clc 
		adc #$03
		sta voice1_music
		bcc lC4E4
		inc voice1_music + $1

lC4E4:
		lda voice2_music + $1
		cmp #$8b
		bne lC4F3
		lda voice2_music
		cmp #$84
		bne lC4F3
		jsr init_music

lC4F3:
		rts 

init_music:
		lda #$00
		sta voice2_music
		lda #$85
		sta voice2_music + $1
		lda #$84
		sta voice1_music
		lda #$8b
		sta voice1_music + $1
		lda #$01
		sta voice2_duration
		sta voice1_duration
		lda sid_vol_filter
		lda #$01
		sta voice3_pulse_width + $1
		lda #$07
		sta voice1_pulse_width + $1
		lda #$07
		sta voice2_pulse_width + $1
		rts 

items_collected:
		.byte	$00

check_pickups:
		ldy #$29
		jsr check_pickup
		ldy #$29
		jsr check_pickup
		ldy #$51
		jsr check_pickup
		ldy #$79
		jsr check_pickup
		jmp drain_air

check_pickup:
		lda (level_pointer), y
		cmp #$4b
		beq collect_item
		cmp #$4c
		beq collect_item
		cmp #$45
		beq die
		cmp #$46
		beq die
		rts 

collect_item:
		lda #$20
		sta (level_pointer), y
		jsr add_score
		rts 

; leaves main_loop: the player touched something deadly
die:
		pla 
		pla 
		rts 

; draws the air bar and starts the level
play_level:
		lda #$46
		sta air_pointer
		lda #$04
		sta air_pointer + $1
		ldy #$00
		lda #$60
		sta (air_pointer), y
		ldx #$00

lC563:
		lda air_pointer
		clc 
		adc #$28
		sta air_pointer
		bcc lC56E
		inc air_pointer + $1

lC56E:
		lda #$56
		sta (air_pointer), y
		inx 
		cpx #$17
		bne lC563
		lda #$61
		sta (air_pointer), y
		lda #$6e
		sta air_pointer
		lda #$04
		sta air_pointer + $1
		jmp main_loop

air_divider:
		.byte	$09

drain_air:
		inc air_divider
		lda air_divider
		cmp #$14
		bcc animate_portal

; loads itself, but does nothing with it
drain_air_step:
		ldy #$00
		sty air_divider
		lda (air_pointer), y
		clc 
		adc #$01
		sta (air_pointer), y
		cmp #$5f
		bcc lC5AF
		lda air_pointer
		clc 
		adc #$28
		sta air_pointer
		bcc lC5AC
		inc air_pointer + $1

lC5AC:
		lda drain_air_step

lC5AF:
		lda air_pointer + $1
		cmp #$07
		bne animate_portal
		lda air_pointer
		cmp #$b4
		bcc animate_portal
		lda (air_pointer), y
		cmp #$61
		bne animate_portal
		rts 

animate_portal:
		lda frame_counter
		nop 
		bne lC5D7
		lda sprite_pointers + $1
		clc 
		sbc #$00
		cmp #$88
		bcs lC5D4
		lda #$8b

lC5D4:
		sta sprite_pointers + $1

lC5D7:
		jmp check_collisions

sprite_collisions:
		.byte	$05

add_score:
		ldy #$00

lC5DD:
		ldx #$04

lC5DF:
		lda screen + $6f, x
		clc 
		adc #$01
		sta screen + $6f, x
		cmp #$3a
		bcc lC5F4
		lda #$30
		sta screen + $6f, x
		dex 
		bne lC5DF

lC5F4:
		iny 
		cpy #$02
		bne lC5DD
		inc items_collected
		rts 

check_collisions:
		lda vic_sprite_coll
		sta sprite_collisions
		and #$02
		beq lC611
		lda items_collected
		cmp #$07
		bne lC611
		jmp level_done

lC611:
		jmp check_enemy_collision

level_done:
		lda #$ff
		sta items_collected
		rts 

move_enemies:
		ldx #$00
		ldy #$00

lC61E:
		lda enemies + $2, y
		cmp #$01
		bne lC628
		inc vic_sprite_coords + $4, x

lC628:
		cmp #$02
		bne lC62F
		dec vic_sprite_coords + $5, x

lC62F:
		cmp #$03
		bne lC636
		dec vic_sprite_coords + $4, x

lC636:
		cmp #$00
		bne lC63D
		inc vic_sprite_coords + $5, x

lC63D:
		inc enemy_steps, x
		lda enemy_steps, x
		cmp enemies + $4, y
		bcc lC658
		lda enemies + $2, y
		clc 
		adc #$02
		and #$03
		sta enemies + $2, y
		lda #$00
		sta enemy_steps, x

lC658:
		inx 
		inx 
		tya 
		clc 
		adc #$05
		tay 
		cpx #$04
		bcc lC61E
		jmp animate_enemies

; sets up the enemies of the level from the enemy table
init_enemies:
		lda #$80
		sta level_pointer
		lda #$25
		sta level_pointer + $1
		ldx level

lC671:
		beq lC67E
		lda level_pointer
		clc 
		adc #$12
		jsr add_to_level_pointer
		jmp lC671

lC67E:
		sei 
		ldy #$00

lC681:
		lda (level_pointer), y
		sta enemies, y
		iny 
		cpy #$0a
		bne lC681
		lda enemies
		sta vic_sprite_coords + $4
		lda enemies + $1
		sta vic_sprite_coords + $5
		lda enemies + $3
		sta sprite_pointers + $2
		lda enemies + $8
		sta sprite_pointers + $3
		lda enemies + $5
		sta vic_sprite_coords + $6
		lda enemies + $6
		sta vic_sprite_coords + $7
		ldy #$0a

lC6B1:
		lda (level_pointer), y
		sta sprite4_coords_base, y
		iny 
		cpy #$12
		bne lC6B1
		ldy #$00

lC6BD:
		lda #$95
		sta sprite_pointers + $4, y
		iny 
		cpy #$04
		bne lC6BD
		lda #$01
		sta enemy_steps
		sta enemy_steps + $2
		cli 
		rts 

animation_divider:
		.byte	$06

animate_enemies:
		inc animation_divider
		lda animation_divider
		cmp #$08
		bcc lC704
		lda #$00
		sta animation_divider
		ldx #$00
		ldy #$00

lC6E5:
		inc sprite_pointers + $2, x
		lda enemies + $3, y
		clc 
		adc #$03
		cmp sprite_pointers + $2, x
		bcs lC6F9
		lda enemies + $3, y
		sta sprite_pointers + $2, x

lC6F9:
		inx 
		nop 
		tya 
		clc 
		adc #$05
		tay 
		cpx #$02
		bcc lC6E5

lC704:
		jmp kernal_irq

check_enemy_collision:
		lda sprite_collisions
		and #$02
		bne lC716
		lda sprite_collisions
		and #$01
		beq lC716
		rts 

lC716:
		jmp main_loop

air_empty:
		.byte	$01

drain_air_once:
		ldy #$00
		sty air_divider
		lda (air_pointer), y
		clc 
		adc #$01
		sta (air_pointer), y
		cmp #$5f
		bcc lC738
		lda air_pointer
		clc 
		adc #$28
		sta air_pointer
		bcc lC735
		inc air_pointer + $1

lC735:
		lda drain_air_step

lC738:
		lda air_pointer + $1
		cmp #$07
		bne lC74F
		lda air_pointer
		cmp #$b4
		bcc lC74F
		lda (air_pointer), y
		cmp #$61
		bne lC74F
		lda #$01
		sta air_empty

lC74F:
		rts 

; turns the air left into score at the end of a level
count_air_bonus:
		lda #$00
		sta air_empty

lC755:
		jsr drain_air_once
		ldx #$05

lC75A:
		lda screen + $6f, x
		clc 
		adc #$01
		sta screen + $6f, x
		cmp #$3a
		bcc lC76F
		lda #$30
		sta screen + $6f, x
		dex 
		bne lC75A

lC76F:
		lda vic_raster
		cmp #$ff
		bne lC76F
		inc bonus_sound_frequency
		lda #$00
		sta voice1_control
		lda bonus_sound_frequency
		sta voice1_frequency + $1
		lda #$04
		sta voice1_attack_decay
		lda #$21
		sta voice1_control
		lda air_empty
		beq lC755
		rts 

bonus_sound_frequency:
		.byte	$f5

remove_irq:
		sei 
		lda #$31
		sta irq_vector
		lda #$ea
		sta irq_vector + $1
		lda #$01
		sta cia1_timer_a_control
		lda #$79
		sta vic_irq_status
		lda #$f0
		sta vic_irq_enable
		cli 
		rts 

add_to_level_pointer:
		sta level_pointer
		bcc lC7B7
		inc level_pointer + $1

lC7B7:
		dex 
		rts 

unused_c7b9:
		.byte	$ff, $00, $ff, $00, $ff, $00, $ff
; the sprite 4-7 coordinates, read through init_enemies' $cffe + $0a, y
sprite4_coords_base = $cffe

.virtual $cfff
frame_counter:		.byte	?
vic_sprite_coords:
		.fill	16
vic_sprite_x_high_bits:		.byte	?
vic_control:		.byte	?
vic_raster:		.byte	?
vic_light_pen:
		.fill	2
vic_sprite_enable:		.byte	?
vic_registers:
		.fill	3
vic_irq_status:		.byte	?
vic_irq_enable:		.byte	?
vic_sprite_priority:		.byte	?
vic_sprite_multicolor:		.byte	?
vic_sprite_double_width:		.byte	?
vic_sprite_coll:		.byte	?
vic_rest:
		.fill	993
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
sid_vol_filter:		.byte	?
sid_mirrors:
		.fill	999
.endv

.virtual $dc00
cia1_port_a:		.byte	?
cia1_port_b:		.byte	?
cia1_registers:
		.fill	12
cia1_timer_a_control:		.byte	?
cia1_timer_b_control:		.byte	?
.endv

.virtual $ea31
; in the KERNAL ROM
kernal_irq:		.byte	?
.endv
