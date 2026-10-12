
.virtual $009d
; ---- KERNAL variables ----
; written by: lC158, load_highscore
kernal_msgflag:		.byte	?
.endv

.virtual $00ba
; read by: lC158, lC172, load_highscore, lC1F7
; written by: lC1D3
kernal_device:		.byte	?
.endv

.virtual $00c1
; written by: lC191
kernal_save_start:		.word	?
.endv

.virtual $0286
; written by: start
kernal_text_color:		.byte	?
.endv

.virtual $0291
; bit 7 set disables switching the character set with shift+commodore
; written by: crack_intro
kernal_case_lock:		.byte	?
.endv

.virtual $0314
; written by: crack_intro
irq_vector:		.word	?
.endv

.virtual $0328
; written by: crack_intro
stop_vector:		.word	?
.endv

.virtual $0400
; ---- screen ----
; read by: l504F, l5068, l507A, l5086
; written by: l40BF, l4106, l4113, l4123, l413C, countdown, l4281, l42EF, l4333, l4917, l4A10, draw_status, l4BDC, show_game_over, number_rows, l504F, l5068, l507A, l5086, lC026, lC0A5
screen:
		.fill	1000
.endv

.virtual $07f8
; written by: l4018, l445F, l446C, l44AE, l44C7, l44D4, l4516, l4521, l4592, move_shots, l4677
sprite_pointers:
		.fill	8
.endv

.virtual $2000
; ---- built at run time by build_charset and build_sprites ----
; written by: l4FE2
charset:
		.fill	2048
.endv

.virtual $3200
; written by: l5022
sprites:
		.fill	256
.endv

*=$4000

; ---- game: code ----
; the game's start, where the decruncher jumps to
; jumped to by: lC026
start:
		lda #$93
		jsr chrout
		lda #$00
		sta border_color
		lda #$00
		sta background_color
		lda #$01
		sta kernal_text_color
		lda #$01
		ldx #$00

l4018:
		sta color_ram, x
		sta color_ram + $c8, x
		sta color_ram + $190, x
		sta color_ram + $258, x
		sta color_ram + $320, x
		inx 
		cpx #$c8
		bne l4018
		jsr build_charset
		jsr build_sprites
		sei 
		lda #$c8
		sta sprite_pointers
		lda #$c9
		sta sprite_pointers + $1
		sta sprite_pointers + $2
		lda #$ca
		sta sprite_pointers + $3
		sta sprite_pointers + $4
		jsr draw_ground

; shows the title screen; also where the game returns to after game over
; jumped to by: show_game_over
; written by: lC0DB
title_screen:
		jsr save_highscore
		lda #$94
		sta p1_x
		lda #$c4
		sta p2_x
		lda #$f2
		sta p1_y
		sta p2_y
		lda #$a0
		sta invader_x
		lda #$92
		sta invader_y
		lda #$0b
		sta invader_row
		lda #$01
		sta sprite_expand_x
		sta sprite_expand_y
		sta scores_changed
		jsr draw_scores
		lda #$07
		sta sprite_enable
		jsr position_p1
		jsr position_p2
		lda invader_x
		sta sprite0_x
		lda invader_y
		sta sprite0_y
		lda invader_color
		sta sprite0_color
		jsr stripe_title_colors
		jsr draw_title
		jsr clear_status
		lda #$00
		sta scroll_offset

; jumped to by: l40EB
title_loop:
		jsr wait_frame
		inc scroll_timer
		lda scroll_timer
		cmp #$04
		bne l40CE
		lda #$00
		sta scroll_timer
		ldx scroll_offset
		ldy #$00

l40BF:
		lda scroll_text, x
		sta screen + $258, y
		inx 
		iny 
		cpy #$28
		bne l40BF
		inc scroll_offset

; jumped to by: title_loop
l40CE:
		jsr cycle_title_colors
		jsr read_p1_fire
		lda p1_fire
		cmp #$01
		bne l40EB
		lda #$01
		sta p1_playing
		lda #$ea
		sta p1_y
		jsr position_p1
		jmp start_game

; jumped to by: l40CE
l40EB:
		jsr read_p2_fire
		lda p2_fire
		cmp #$01
		bne title_loop
		lda #$01
		sta p2_playing
		lda #$ea
		sta p2_y
		jsr position_p2

; jumped to by: l40CE
start_game:
		lda #$20
		ldy #$00

l4106:
		sta screen + $258, y
		iny 
		cpy #$28
		bne l4106
		jmp play

; called by: title_screen
draw_title:
		ldx #$00

l4113:
		lda title_chars, x
		sta screen + $f0, x
		inx 
		cpx #$f0
		bne l4113
		rts 

; called by: l4333
clear_title:
		ldx #$00
		lda #$20

l4123:
		sta screen + $f0, x
		inx 
		cpx #$f0
		bne l4123
		rts 

; unreferenced: fills the title's colour RAM with title_color
fill_title_color:
		ldx #$00
		lda title_color

l4131:
		sta color_ram + $f0, x
		inx 
		cpx #$f0
		bne l4131
		rts 

; called by: l4018
draw_ground:
		ldx #$00

; jumped to by: l4153
l413C:
		lda ground_chars, x
		sta screen + $2f8, x
		lda #$0b
		sta color_ram + $2f8, x
		lda ground_chars, x
		cmp #$5d
		bne l4153
		lda #$0f
		sta color_ram + $2f8, x

; jumped to by: l413C
l4153:
		inx 
		cpx #$f0
		bne l413C
		ldx #$a0
		lda #$09

l415C:
		sta color_ram + $2f8, x
		inx 
		cpx #$c8
		bne l415C
		lda #$08

l4166:
		sta color_ram + $2f8, x
		inx 
		cpx #$f0
		bne l4166
		lda #$05
		ldx #$a0
		sta color_ram + $2f8, x
		ldx #$c7
		sta color_ram + $2f8, x
		lda #$03
		ldx #$d7

l417E:
		sta color_ram + $2f8, x
		inx 
		cpx #$e1
		bne l417E
		rts 

; called by: title_screen, show_game_over
stripe_title_colors:
		ldx #$00
		ldy #$00

; jumped to by: l41C4
l418B:
		cpy #$00
		bne l4194
		lda #$06
		jmp l41BA

; jumped to by: l418B
l4194:
		cpy #$01
		bne l419D
		lda #$0b
		jmp l41BA

; jumped to by: l4194
l419D:
		cpy #$02
		bne l41A6
		lda #$0c
		jmp l41BA

; jumped to by: l419D
l41A6:
		cpy #$03
		bne l41AF
		lda #$0f
		jmp l41BA

; jumped to by: l41A6
l41AF:
		cpy #$04
		bne l41B8
		lda #$01
		jmp l41BA

; jumped to by: l41AF
l41B8:
		lda #$04

; jumped to by: l418B, l4194, l419D, l41A6, l41AF
l41BA:
		sta color_ram + $f0, x
		iny 
		cpy #$06
		bne l41C4
		ldy #$00

; jumped to by: l41BA
l41C4:
		inx 
		cpx #$a0
		bne l418B
		rts 

; called by: l40CE, l4281, l42F9
cycle_title_colors:
		ldx #$00

l41CC:
		inc color_ram + $f0, x
		inx 
		cpx #$f0
		bne l41CC
		rts 

; jumped to by: lC1B4
reset_game:
		lda #$00
		sta game_over_flag
		sta p1_direction
		sta p1_fire
		sta p2_fire
		sta p1_playing
		sta p2_playing
		sta invader_x + $1
		sta p1_x + $1
		sta p2_x + $1
		sta invader_row
		lda #$01
		sta p2_direction
		sta invader_direction
		sta p1_fire_held
		sta p2_fire_held
		sta scores_changed
		lda #$02
		sta invader_color
		lda #$0d
		sta p1_color
		lda #$0e
		sta p2_color
		lda #$94
		sta p1_x
		lda #$ac
		sta invader_x
		lda #$c4
		sta p2_x
		lda #$f2
		sta p1_y
		sta p2_y
		rts 

; called by: play
reset_scores:
		sed 
		lda #$00
		sta p1_score
		sta p1_score + $1
		sta p1_score + $2
		sta p2_score
		sta p2_score + $1
		sta p2_score + $2
		cld 
		sed 
		lda #$80
		sta hit_counter
		lda #$00
		sta hit_counter + $1
		cld 
		lda #$00
		sta p1_turned
		sta p2_turned
		lda #$01
		sta scores_changed
		jsr draw_scores
		lda #$02
		sta invader_speed
		lda #$0a
		sta speedup_interval
		sta speedup_counter
		rts 

; counts down 3-2-1, then GO while the 1nvader rises into place
; called by: play
countdown:
		lda #$33
		sta countdown_digit
		sbc #$0f
		sta screen + $b3
		adc #$02
		sta screen + $b4
		lda #$1d
		sta countdown_timer

; jumped to by: l42EC
l4281:
		jsr cycle_title_colors
		dec countdown_timer
		lda countdown_timer
		cmp #$00
		bne l42A7
		lda #$1d
		sta countdown_timer
		dec countdown_digit
		lda countdown_digit
		cmp #$30
		beq l42EF
		sbc #$10
		sta screen + $b3
		adc #$02
		sta screen + $b4

; jumped to by: l4281
l42A7:
		jsr wait_frame
		lda p1_playing
		cmp #$01
		beq l42CB
		jsr read_p1_fire
		inc sprite1_color
		lda p1_fire
		cmp #$01
		bne l42CB
		lda #$01
		sta p1_playing
		lda #$ea
		sta p1_y
		jsr position_p1

; jumped to by: l42A7
l42CB:
		lda p2_playing
		cmp #$01
		beq l42EC
		jsr read_p2_fire
		inc sprite2_color
		lda p2_fire
		cmp #$01
		bne l42EC
		lda #$01
		sta p2_playing
		lda #$ea
		sta p2_y
		jsr position_p2

; jumped to by: l42CB
l42EC:
		jmp l4281

; jumped to by: l4281
l42EF:
		lda #$47
		sta screen + $b3
		lda #$4f
		sta screen + $b4

; jumped to by: l4333
l42F9:
		jsr cycle_title_colors
		jsr wait_frame
		dec invader_y
		dec invader_y
		lda invader_y
		sta sprite0_y
		lda p1_playing
		cmp #$01
		beq l431F
		lda p1_y
		cmp #$fa
		beq l431F
		inc p1_y
		jsr position_p1

; jumped to by: l42F9
l431F:
		lda p2_playing
		cmp #$01
		beq l4333
		lda p2_y
		cmp #$fa
		beq l4333
		inc p2_y
		jsr position_p2

; jumped to by: l431F
l4333:
		lda invader_y
		cmp #$20
		bne l42F9
		lda #$00
		sta sprite_expand_x
		sta sprite_expand_y
		sta invader_x
		sta p1_fire
		sta p2_fire
		sta p1_shot_state
		sta p2_shot_state
		sta invader_row
		ldx invader_row
		lda row_y, x
		sta invader_y
		lda #$02
		sta invader_color
		jsr set_hit_points
		lda #$01
		sta scores_changed
		jsr draw_scores
		lda #$20
		sta screen + $b3
		sta screen + $b4
		jsr clear_title
		rts 

; jumped to by: l4106
play:
		jsr reset_scores
		jsr countdown

game_loop:
		jsr wait_frame
		jsr read_fire_buttons
		jsr update_game
		jsr update_screen
		lda game_over_flag
		cmp #$01
		bne game_loop
		jmp game_over

; the snapshot's PC was here, and the return address on the stack was
; game_loop's next instruction
; called by: title_loop, l42A7, l42F9, game_loop, l4BEA, l4CB3
wait_frame:
		lda raster
		cmp #$fb
		bne wait_frame
		lda sprite_sprite_collision
		sta collisions
		rts 

; called by: game_loop
read_fire_buttons:
		lda p1_playing
		cmp #$01
		bne l43BE
		lda p1_shot_state
		cmp #$00
		beq l43BB
		lda p1_shot_y
		sbc #$97
		bcc l43BB
		jmp l43BE

; jumped to by: read_fire_buttons
l43BB:
		jsr read_p1_fire

; jumped to by: read_fire_buttons
l43BE:
		lda p2_playing
		cmp #$01
		bne l43D9
		lda p2_shot_state
		cmp #$00
		beq l43D6
		lda p2_shot_y
		sbc #$97
		bcc l43D6
		jmp l43D9

; jumped to by: l43BE
l43D6:
		jsr read_p2_fire

; jumped to by: l43BE
l43D9:
		rts 

; called by: l40CE, l42A7, l43BB
read_p1_fire:
		lda cia1_port_b
		and #$10
		cmp #$00
		beq l43E9
		lda #$00
		sta p1_fire_held
		rts 

; jumped to by: read_p1_fire
l43E9:
		lda p1_fire_held
		cmp #$00
		bne l43FC
		lda #$01
		sta p1_fire
		sta p1_fire_held
		jsr p1_shot_sound
		rts 

; jumped to by: l43E9
l43FC:
		lda #$00
		sta p1_fire
		rts 

; called by: l40EB, l42CB, l43D6
read_p2_fire:
		lda cia1_port_a
		and #$10
		cmp #$00
		beq l4411
		lda #$00
		sta p2_fire_held
		rts 

; jumped to by: read_p2_fire
l4411:
		lda p2_fire_held
		cmp #$00
		bne l4424
		lda #$01
		sta p2_fire
		sta p2_fire_held
		jsr p2_shot_sound
		rts 

; jumped to by: l4411
l4424:
		lda #$00
		sta p2_fire
		rts 

; called by: game_loop
update_game:
		jsr check_shot_hits
		jsr move_shots
		jsr move_invader
		jsr bounce_cannons
		jsr check_cannon_edges
		lda p1_playing
		cmp #$01
		bne l4443
		jsr move_p1

; jumped to by: update_game
l4443:
		lda p2_playing
		cmp #$01
		bne l444D
		jsr move_p2

; jumped to by: l4443
l444D:
		jsr clear_fire_flags
		rts 

; called by: update_game
check_shot_hits:
		lda p1_shot_state
		cmp #$00
		beq l445F
		cmp #$0c
		beq l446C
		jmp l44AE

; jumped to by: check_shot_hits
l445F:
		lda #$00
		sta p1_shot_state
		lda #$ca
		sta sprite_pointers + $3
		jmp l44B9

; jumped to by: check_shot_hits
l446C:
		lda #$ca
		sta sprite_pointers + $3
		lda collisions
		and #$09
		cmp #$09
		bne l44B9
		dec p1_shot_state
		sed 
		clc 
		lda p1_score
		adc hit_points
		sta p1_score
		lda p1_score + $1
		adc hit_points + $1
		sta p1_score + $1
		lda p1_score + $2
		adc #$00
		sta p1_score + $2
		sec 
		lda hit_counter
		sbc #$01
		sta hit_counter
		lda hit_counter + $1
		sbc #$00
		sta hit_counter + $1
		cld 
		jmp invader_hit

; jumped to by: check_shot_hits
l44AE:
		dec p1_shot_state
		lda #$cb
		sta sprite_pointers + $3
		jmp l44B9

; jumped to by: l445F, l446C, l44AE
l44B9:
		lda p2_shot_state
		cmp #$00
		beq l44C7
		cmp #$0c
		beq l44D4
		jmp l4516

; jumped to by: l44B9
l44C7:
		lda #$00
		sta p2_shot_state
		lda #$ca
		sta sprite_pointers + $4
		jmp l4521

; jumped to by: l44B9
l44D4:
		lda #$ca
		sta sprite_pointers + $4
		lda collisions
		and #$11
		cmp #$11
		bne l4521
		dec p2_shot_state
		sed 
		clc 
		lda p2_score
		adc hit_points
		sta p2_score
		lda p2_score + $1
		adc hit_points + $1
		sta p2_score + $1
		lda p2_score + $2
		adc #$00
		sta p2_score + $2
		sec 
		lda hit_counter
		sbc #$01
		sta hit_counter
		lda hit_counter + $1
		sbc #$00
		sta hit_counter + $1
		cld 
		jmp invader_hit

; jumped to by: l44B9
l4516:
		dec p2_shot_state
		lda #$cb
		sta sprite_pointers + $4
		jmp l4521

; jumped to by: l44C7, l44D4, l4516
l4521:
		rts 

; unreferenced: an older version of check_shot_hits

		lda p1_shot_state
		cmp #$00
		beq l4588
		cmp #$01
		beq l4549
		lda #$cb
		sta sprite_pointers + $3
		dec p1_shot_state
		lda p1_shot_state
		cmp #$01
		bne l4546
		lda #$00
		sta p1_shot_state
		lda #$ca
		sta sprite_pointers + $3

; jumped to by: l4521
l4546:
		jmp l4588

; jumped to by: l4521
l4549:
		lda collisions
		and #$09
		cmp #$09
		bne l4588
		sed 
		clc 
		lda p1_score
		adc hit_points
		sta p1_score
		lda p1_score + $1
		adc hit_points + $1
		sta p1_score + $1
		lda p1_score + $2
		adc #$00
		sta p1_score + $2
		sec 
		lda hit_counter
		sbc #$01
		sta hit_counter
		lda hit_counter + $1
		sbc #$00
		sta hit_counter + $1
		cld 
		lda #$0c
		sta p1_shot_state
		jmp invader_hit

; jumped to by: l4521, l4546, l4549
l4588:
		lda p2_shot_state
		cmp #$00
		bne l4592
		jmp l4659

; jumped to by: l4588
l4592:
		cmp #$01
		beq l45B2
		lda #$cb
		sta sprite_pointers + $4
		dec p2_shot_state
		lda p2_shot_state
		cmp #$01
		bne l45AF
		lda #$00
		sta p2_shot_state
		lda #$ca
		sta sprite_pointers + $4

; jumped to by: l4592
l45AF:
		jmp l4659

; jumped to by: l4592
l45B2:
		lda collisions
		and #$11
		cmp #$11
		beq l45BE
		jmp l4659

; jumped to by: l45B2
l45BE:
		sed 
		clc 
		lda p2_score
		adc hit_points
		sta p2_score
		lda p2_score + $1
		adc hit_points + $1
		sta p2_score + $1
		lda p2_score + $2
		adc #$00
		sta p2_score + $2
		sec 
		lda hit_counter
		sbc #$01
		sta hit_counter
		lda hit_counter + $1
		sbc #$00
		sta hit_counter + $1
		cld 
		lda #$0c
		sta p2_shot_state

; jumped to by: l446C, l44D4, l4549
invader_hit:
		jsr hit_sound
		dec speedup_counter
		lda speedup_counter
		cmp #$00
		bne l4618
		inc invader_speed
		lda invader_speed
		cmp #$0a
		bne l4612
		lda #$02
		sta invader_speed
		lda #$80
		sta hit_counter

; jumped to by: invader_hit
l4612:
		lda speedup_interval
		sta speedup_counter

; jumped to by: invader_hit
l4618:
		lda #$01
		sta scores_changed
		sed 
		clc 
		lda invader_row
		sbc #$01
		sta invader_row
		cld 
		lda #$1e
		cmp invader_row
		bcs l4634
		lda #$00
		sta invader_row

; jumped to by: l4618
l4634:
		jsr set_hit_points
		lda invader_direction
		bne l464A
		sta invader_x
		sta invader_x + $1
		lda #$01
		sta invader_direction
		jmp l4659

; jumped to by: l4634
l464A:
		lda #$01
		sta invader_x + $1
		lda #$59
		sta invader_x
		lda #$00
		sta invader_direction

; jumped to by: l4588, l45AF, l45B2, l4634
l4659:
		rts 

; called by: update_game, l4BEA
move_shots:
		lda p1_shot_state
		cmp #$0c
		bne l4677
		lda p1_shot_y
		sbc #$04
		sta p1_shot_y
		cmp #$32
		bne l4677
		lda #$00
		sta p1_shot_state
		lda #$ca
		sta sprite_pointers + $3

; jumped to by: move_shots
l4677:
		lda p2_shot_state
		cmp #$0c
		bne l4697
		lda p2_shot_y
		sbc #$04
		sta p2_shot_y
		lda p2_shot_y
		cmp #$32
		bne l4697
		lda #$00
		sta p2_shot_state
		lda #$ca
		sta sprite_pointers + $4

; jumped to by: l4677
l4697:
		rts 

; called by: update_game
move_invader:
		lda invader_speed
		sta invader_steps

l469E:
		lda invader_steps
		cmp #$00
		beq l46AE
		jsr step_invader
		dec invader_steps
		jmp l469E

; jumped to by: l469E
l46AE:
		rts 

; called by: l469E, l4C0B
step_invader:
		lda invader_direction
		cmp #$00
		beq l46C1
		inc invader_x
		bne l46DF
		inc invader_x + $1
		jmp l46DF

; jumped to by: step_invader
l46C1:
		lda invader_x + $1
		bne l46CC
		dec invader_x
		jmp l46DF

; jumped to by: l46C1
l46CC:
		dec invader_x
		lda invader_x
		cmp #$ff
		beq l46D9
		jmp l46DF

; jumped to by: l46CC
l46D9:
		dec invader_x + $1
		jmp l46DF

; jumped to by: step_invader, l46C1, l46CC, l46D9
l46DF:
		lda invader_direction
		cmp #$00
		beq l470A
		lda invader_x + $1
		cmp #$00
		beq l473D
		lda invader_x
		cmp #$59
		bne l473D
		lda #$00
		sta invader_direction
		sed 
		clc 
		lda invader_row

; apply_trainer patches these two "adc #1 / sta invader_row" pairs
; written by: apply_trainer
row_add_right:
		adc #$01

; written by: apply_trainer
row_store_right:
		sta invader_row
		cld 
		jsr set_hit_points
		jmp l472E

; jumped to by: l46DF
l470A:
		lda invader_x + $1
		cmp #$00
		bne l473D
		lda invader_x
		cmp #$00
		bne l473D
		lda #$01
		sta invader_direction
		sed 
		clc 
		lda invader_row

; written by: apply_trainer
row_add_left:
		adc #$01

; written by: apply_trainer
row_store_left:
		sta invader_row
		cld 
		jsr set_hit_points
		jmp l472E

; jumped to by: row_store_right, row_store_left
l472E:
		lda invader_row
		cmp #$22
		bcs l4738
		jmp l473D

; jumped to by: l472E
l4738:
		lda #$01
		sta game_over_flag

; jumped to by: l46DF, l470A, l472E
l473D:
		rts 

; called by: update_game
bounce_cannons:
		lda p1_playing
		cmp #$01
		bne l477D
		lda p2_playing
		cmp #$01
		bne l477D
		lda collisions
		and #$06
		cmp #$06
		bne l477D
		lda p1_direction
		cmp #$00
		bne l476D
		sta p2_direction
		lda #$01
		sta p1_direction
		sta p1_turned
		sta p2_turned
		jmp l477D

; jumped to by: bounce_cannons
l476D:
		sta p2_direction
		lda #$00
		sta p1_direction
		lda #$01
		sta p1_turned
		sta p2_turned

; jumped to by: bounce_cannons
l477D:
		rts 

; called by: update_game
check_cannon_edges:
		lda p1_direction
		cmp #$00
		beq l47A0
		lda p1_x + $1
		cmp #$00
		beq l47B6
		lda p1_x
		cmp #$41
		bne l47B6
		lda #$00
		sta p1_direction
		lda #$01
		sta p1_turned
		jmp l47B6

; jumped to by: check_cannon_edges
l47A0:
		lda p1_x + $1
		cmp #$00
		bne l47B6
		lda p1_x
		cmp #$18
		bne l47B6
		lda #$01
		sta p1_direction
		sta p1_turned

; jumped to by: check_cannon_edges, l47A0
l47B6:
		lda p2_direction
		cmp #$00
		beq l47D8
		lda p2_x + $1
		cmp #$00
		beq l47EE
		lda p2_x
		cmp #$41
		bne l47EE
		lda #$00
		sta p2_direction
		lda #$01
		sta p2_turned
		jmp l47EE

; jumped to by: l47B6
l47D8:
		lda p2_x + $1
		cmp #$00
		bne l47EE
		lda p2_x
		cmp #$18
		bne l47EE
		lda #$01
		sta p2_direction
		sta p2_turned

; jumped to by: l47B6, l47D8
l47EE:
		rts 

; called by: update_game, l4BEA, check_invader_collision
move_p1:
		lda p1_fire
		cmp #$01
		beq l47F9
		jmp l4830

; jumped to by: move_p1
l47F9:
		lda p1_turned
		cmp #$01
		beq l4817
		lda p1_direction
		cmp #$00
		beq l480F
		lda #$00
		sta p1_direction
		jmp l4817

; jumped to by: l47F9
l480F:
		lda #$01
		sta p1_direction
		jmp l4817

; jumped to by: l47F9, l480F
l4817:
		lda #$0c
		sta p1_shot_state
		lda p1_x
		sta p1_shot_x
		lda p1_x + $1
		sta p1_shot_x + $1
		lda #$e2
		sta p1_shot_y
		jmp l4830

; jumped to by: move_p1, l4817
l4830:
		lda p1_direction
		cmp #$00
		beq l4842
		inc p1_x
		bne l4860
		inc p1_x + $1
		jmp l4860

; jumped to by: l4830
l4842:
		lda p1_x + $1
		bne l484D
		dec p1_x
		jmp l4860

; jumped to by: l4842
l484D:
		dec p1_x
		lda p1_x
		cmp #$ff
		beq l485A
		jmp l4860

; jumped to by: l484D
l485A:
		dec p1_x + $1
		jmp l4860

; jumped to by: l4830, l4842, l484D, l485A
l4860:
		jmp l4863

; jumped to by: l4860
l4863:
		rts 

; called by: l4443, l4BEA, l4CF0
move_p2:
		lda p2_fire
		cmp #$01
		beq l486E
		jmp l48A5

; jumped to by: move_p2
l486E:
		lda p2_turned
		cmp #$01
		beq l488C
		lda p2_direction
		cmp #$00
		beq l4884
		lda #$00
		sta p2_direction
		jmp l488C

; jumped to by: l486E
l4884:
		lda #$01
		sta p2_direction
		jmp l488C

; jumped to by: l486E, l4884
l488C:
		lda #$0c
		sta p2_shot_state
		lda p2_x
		sta p2_shot_x
		lda p2_x + $1
		sta p2_shot_x + $1
		lda #$e2
		sta p2_shot_y
		jmp l48A5

; jumped to by: move_p2, l488C
l48A5:
		lda p2_direction
		cmp #$00
		beq l48B7
		inc p2_x
		bne l48D5
		inc p2_x + $1
		jmp l48D5

; jumped to by: l48A5
l48B7:
		lda p2_x + $1
		bne l48C2
		dec p2_x
		jmp l48D5

; jumped to by: l48B7
l48C2:
		dec p2_x
		lda p2_x
		cmp #$ff
		beq l48CF
		jmp l48D5

; jumped to by: l48C2
l48CF:
		dec p2_x + $1
		jmp l48D5

; jumped to by: l48A5, l48B7, l48C2, l48CF
l48D5:
		jmp l48D8

; jumped to by: l48D5
l48D8:
		rts 

; called by: l444D
clear_fire_flags:
		lda #$00
		sta p1_fire
		sta p2_fire
		sta p1_turned
		sta p2_turned
		rts 

; called by: game_loop
update_screen:
		jsr draw_scores
		jsr draw_status
		jsr position_invader
		lda p1_playing
		cmp #$01
		bne l48FE
		jsr position_p1
		jsr position_p1_shot

; jumped to by: update_screen
l48FE:
		lda p2_playing
		cmp #$01
		bne l490B
		jsr position_p2
		jsr position_p2_shot

; jumped to by: l48FE
l490B:
		jsr twinkle_stars
		rts 

; called by: title_screen, reset_scores, l4333, update_screen
draw_scores:
		lda scores_changed
		bne l4917
		jmp l4A58

; jumped to by: draw_scores
l4917:
		lda #$00
		sta scores_changed
		lda #$20
		sta screen + $f
		sta screen + $18
		lda p1_score
		and #$0f
		clc 
		adc #$30
		sta screen + $6
		lda p1_score
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $5
		lda p1_score + $1
		and #$0f
		clc 
		adc #$30
		sta screen + $4
		lda p1_score + $1
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $3
		lda p1_score + $2
		and #$0f
		clc 
		adc #$30
		sta screen + $2
		lda p1_score + $2
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $1
		lda p2_score
		and #$0f
		clc 
		adc #$30
		sta screen + $26
		lda p2_score
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $25
		lda p2_score + $1
		and #$0f
		clc 
		adc #$30
		sta screen + $24
		lda p2_score + $1
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $23
		lda p2_score + $2
		and #$0f
		clc 
		adc #$30
		sta screen + $22
		lda p2_score + $2
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $21
		lda p1_score + $2
		cmp high_score + $2
		bcc l49E2
		bne l49D0
		lda p1_score + $1
		cmp high_score + $1
		bcc l49E2
		bne l49D0
		lda p1_score
		cmp high_score
		bcc l49E2

; jumped to by: l4917
l49D0:
		lda p1_score
		sta high_score
		lda p1_score + $1
		sta high_score + $1
		lda p1_score + $2
		sta high_score + $2

; jumped to by: l4917
l49E2:
		lda p2_score + $2
		cmp high_score + $2
		bcc l4A10
		bne l49FE
		lda p2_score + $1
		cmp high_score + $1
		bcc l4A10
		bne l49FE
		lda p2_score
		cmp high_score
		bcc l4A10

; jumped to by: l49E2
l49FE:
		lda p2_score
		sta high_score
		lda p2_score + $1
		sta high_score + $1
		lda p2_score + $2
		sta high_score + $2

; jumped to by: l49E2
l4A10:
		lda high_score
		and #$0f
		clc 
		adc #$30
		sta screen + $16
		lda high_score
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $15
		lda high_score + $1
		and #$0f
		clc 
		adc #$30
		sta screen + $14
		lda high_score + $1
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $13
		lda high_score + $2
		and #$0f
		clc 
		adc #$30
		sta screen + $12
		lda high_score + $2
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $11

; jumped to by: draw_scores
l4A58:
		rts 

; called by: update_screen, l4C0B
position_invader:
		lda invader_color
		sta sprite0_color
		ldy invader_row
		lda row_y, y
		sta sprite0_y
		lda invader_x + $1
		bne l4A7C
		lda invader_x
		sta sprite0_x
		lda sprites_x_msb
		and #$fe
		sta sprites_x_msb
		rts 

; jumped to by: position_invader
l4A7C:
		lda invader_x
		sta sprite0_x
		lda sprites_x_msb
		ora #$01
		sta sprites_x_msb
		rts 

; called by: title_screen, l40CE, l42A7, l42F9, update_screen, l4BEA, l4C0B
position_p1:
		lda p1_color
		sta sprite1_color
		lda p1_y
		sta sprite1_y
		lda p1_x + $1
		bne l4AAB
		lda p1_x
		sta sprite1_x
		lda sprites_x_msb
		and #$fd
		sta sprites_x_msb
		rts 

; jumped to by: position_p1
l4AAB:
		lda p1_x
		sta sprite1_x
		lda sprites_x_msb
		ora #$02
		sta sprites_x_msb
		rts 

; called by: title_screen, l40EB, l42CB, l431F, l48FE, l4BEA, l4C0B
position_p2:
		lda p2_color
		sta sprite2_color
		lda p2_y
		sta sprite2_y
		lda p2_x + $1
		bne l4ADA
		lda p2_x
		sta sprite2_x
		lda sprites_x_msb
		and #$fb
		sta sprites_x_msb
		rts 

; jumped to by: position_p2
l4ADA:
		lda p2_x
		sta sprite2_x
		lda sprites_x_msb
		ora #$04
		sta sprites_x_msb
		rts 

; called by: update_screen, l4BEA
position_p1_shot:
		lda p1_shot_state
		cmp #$00
		beq l4B27
		lda sprite_enable
		ora #$08
		sta sprite_enable
		lda p1_color
		sta sprite3_color
		lda p1_shot_y
		sta sprite3_y
		lda p1_shot_x + $1
		bne l4B18
		lda p1_shot_x
		sta sprite3_x
		lda sprites_x_msb
		and #$f7
		sta sprites_x_msb
		rts 

; jumped to by: position_p1_shot
l4B18:
		lda p1_shot_x
		sta sprite3_x
		lda sprites_x_msb
		ora #$08
		sta sprites_x_msb
		rts 

; jumped to by: position_p1_shot
l4B27:
		lda sprite_enable
		and #$f7
		sta sprite_enable
		rts 

; called by: l48FE, l4BEA
position_p2_shot:
		lda p2_shot_state
		cmp #$00
		beq l4B6E
		lda sprite_enable
		ora #$10
		sta sprite_enable
		lda p2_color
		sta sprite4_color
		lda p2_shot_y
		sta sprite4_y
		lda p2_shot_x + $1
		bne l4B5F
		lda p2_shot_x
		sta sprite4_x
		lda sprites_x_msb
		and #$ef
		sta sprites_x_msb
		rts 

; jumped to by: position_p2_shot
l4B5F:
		lda p2_shot_x
		sta sprite4_x
		lda sprites_x_msb
		ora #$10
		sta sprites_x_msb
		rts 

; jumped to by: position_p2_shot
l4B6E:
		lda sprite_enable
		and #$ef
		sta sprite_enable
		rts 

; called by: update_screen
draw_status:
		lda invader_row
		and #$0f
		clc 
		adc #$30
		sta screen + $3d0
		lda invader_row
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $3cf
		lda hit_points
		and #$0f
		clc 
		adc #$30
		sta screen + $3d5
		lda hit_points
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $3d4
		lda hit_points + $1
		and #$0f
		clc 
		adc #$30
		sta screen + $3d3
		lda hit_points + $1
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $3d2
		lda hit_counter
		and #$0f
		clc 
		adc #$30
		sta screen + $3d8
		lda hit_counter
		lsr 
		lsr 
		lsr 
		lsr 
		clc 
		adc #$30
		sta screen + $3d7
		rts 

; called by: title_screen
clear_status:
		lda #$20
		ldx #$0f

l4BDC:
		sta screen + $3c0, x
		inx 
		cpx #$19
		bne l4BDC
		rts 

; jumped to by: game_loop
game_over:
		lda #$00
		sta game_over_flag

; jumped to by: l4C0B
l4BEA:
		jsr wait_frame
		jsr twinkle_stars
		jsr move_p1
		jsr move_p2
		jsr position_p1
		jsr position_p2
		jsr move_shots
		jsr position_p1_shot
		jsr position_p2_shot
		lda invader_speed
		sta invader_steps

l4C0B:
		lda game_over_flag
		cmp #$01
		beq show_game_over
		lda invader_steps
		cmp #$00
		beq l4BEA
		jsr step_invader
		dec invader_steps
		jsr check_invader_collision
		jsr position_invader
		jsr position_p1
		jsr position_p2
		jmp l4C0B

; jumped to by: l4C0B
show_game_over:
		jsr stripe_title_colors
		lda #$45
		sta screen + $12a
		lda #$4f
		sta screen + $12d
		jsr wait_6_frames
		lda #$4d
		sta screen + $129
		lda #$56
		sta screen + $12e
		jsr wait_6_frames
		lda #$41
		sta screen + $128
		lda #$45
		sta screen + $12f
		jsr wait_6_frames
		lda #$47
		sta screen + $127
		lda #$52
		sta screen + $130
		jsr wait_6_frames
		jsr wait_6_frames
		jsr wait_6_frames
		jsr wait_6_frames
		jsr wait_6_frames
		lda #$20
		sta screen + $12a
		sta screen + $12d
		jsr wait_6_frames
		lda #$20
		sta screen + $129
		sta screen + $12e
		jsr wait_6_frames
		lda #$20
		sta screen + $128
		sta screen + $12f
		jsr wait_6_frames
		lda #$20
		sta screen + $127
		sta screen + $130
		jsr wait_6_frames
		jsr wait_6_frames
		jsr wait_6_frames
		lda #$00
		sta game_over_flag
		sta p1_playing
		sta p2_playing
		jmp title_screen

; called by: show_game_over
wait_6_frames:
		ldy #$06

l4CB3:
		jsr wait_frame
		cpy #$00
		beq l4CBE
		dey 
		jmp l4CB3

; jumped to by: l4CB3
l4CBE:
		rts 

; called by: l4C0B
check_invader_collision:
		lda collisions
		and #$03
		cmp #$03
		bne l4CF0
		lda invader_direction
		sta p1_direction
		jsr move_p1
		cmp #$00
		bne l4CF0
		lda p1_x + $1
		cmp #$01
		beq l4CF0
		lda p1_x
		cmp #$0c
		bcc l4CE6
		jmp l4CF0

; jumped to by: check_invader_collision
l4CE6:
		lda #$01
		sta p1_x + $1
		lda #$49
		sta p1_x

; jumped to by: check_invader_collision
l4CF0:
		lda collisions
		and #$05
		cmp #$05
		bne l4D06
		lda invader_direction
		sta p2_direction
		jsr move_p2
		cmp #$00
		bne l4D06

; jumped to by: l4CF0
l4D06:
		rts 

; unreferenced: numbers the screen rows down the left edge, a debugging aid
number_rows:
		ldx #$30
		stx screen + $28
		inx 
		stx screen + $50
		inx 
		stx screen + $78
		inx 
		stx screen + $a0
		inx 
		stx screen + $c8
		inx 
		stx screen + $f0
		inx 
		stx screen + $118
		inx 
		stx screen + $140
		inx 
		stx screen + $168
		inx 
		stx screen + $190
		ldx #$30
		stx screen + $1b9
		inx 
		stx screen + $1e0
		inx 
		stx screen + $208
		inx 
		stx screen + $230
		inx 
		stx screen + $258
		inx 
		stx screen + $280
		inx 
		stx screen + $2a8
		inx 
		stx screen + $2d0
		inx 
		stx screen + $2f8
		inx 
		stx screen + $320
		ldx #$30
		stx screen + $349
		inx 
		stx screen + $370
		rts 

; sets hit_points from invader_row: the higher the 1nvader, the more points
; called by: l4333, l4634, row_store_right, row_store_left
set_hit_points:
		lda #$00
		sta hit_points
		sta hit_points + $1
		lda invader_row
		cmp #$00
		bne l4D7F
		lda #$00
		sta hit_points
		lda #$10
		sta hit_points + $1
		jmp l4EDD

; jumped to by: set_hit_points
l4D7F:
		cmp #$01
		bne l4D90
		lda #$00
		sta hit_points
		lda #$05
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4D7F
l4D90:
		cmp #$02
		bne l4DA1
		lda #$75
		sta hit_points
		lda #$04
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4D90
l4DA1:
		cmp #$03
		bne l4DB2
		lda #$50
		sta hit_points
		lda #$04
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4DA1
l4DB2:
		cmp #$04
		bne l4DC3
		lda #$25
		sta hit_points
		lda #$04
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4DB2
l4DC3:
		cmp #$05
		bne l4DD4
		lda #$00
		sta hit_points
		lda #$04
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4DC3
l4DD4:
		cmp #$06
		bne l4DE5
		lda #$75
		sta hit_points
		lda #$03
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4DD4
l4DE5:
		cmp #$07
		bne l4DF6
		lda #$50
		sta hit_points
		lda #$03
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4DE5
l4DF6:
		cmp #$08
		bne l4E07
		lda #$25
		sta hit_points
		lda #$03
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4DF6
l4E07:
		cmp #$09
		bne l4E18
		lda #$00
		sta hit_points
		lda #$03
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E07
l4E18:
		cmp #$10
		bne l4E29
		lda #$75
		sta hit_points
		lda #$02
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E18
l4E29:
		cmp #$11
		bne l4E3A
		lda #$50
		sta hit_points
		lda #$02
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E29
l4E3A:
		cmp #$12
		bne l4E4B
		lda #$25
		sta hit_points
		lda #$02
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E3A
l4E4B:
		cmp #$13
		bne l4E5C
		lda #$00
		sta hit_points
		lda #$02
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E4B
l4E5C:
		cmp #$14
		bne l4E6D
		lda #$75
		sta hit_points
		lda #$01
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E5C
l4E6D:
		cmp #$15
		bne l4E7E
		lda #$50
		sta hit_points
		lda #$01
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E6D
l4E7E:
		cmp #$16
		bne l4E8F
		lda #$25
		sta hit_points
		lda #$01
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E7E
l4E8F:
		cmp #$17
		bne l4EA0
		lda #$00
		sta hit_points
		lda #$01
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4E8F
l4EA0:
		cmp #$18
		bne l4EB1
		lda #$75
		sta hit_points
		lda #$00
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4EA0
l4EB1:
		cmp #$19
		bne l4EC2
		lda #$50
		sta hit_points
		lda #$00
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4EB1
l4EC2:
		cmp #$20
		bne l4ED3
		lda #$25
		sta hit_points
		lda #$00
		sta hit_points + $1
		jmp l4EDD

; jumped to by: l4EC2
l4ED3:
		lda #$01
		sta hit_points
		lda #$00
		sta hit_points + $1

; jumped to by: set_hit_points, l4D7F, l4D90, l4DA1, l4DB2, l4DC3, l4DD4, l4DE5, l4DF6, l4E07, l4E18, l4E29, l4E3A, l4E4B, l4E5C, l4E6D, l4E7E, l4E8F, l4EA0, l4EB1, l4EC2
l4EDD:
		rts 

; called by: p1_shot_sound
play_voice1:
		lda sound_attack_decay
		sta voice1_attack_decay
		lda sound_sustain_release
		sta voice1_sustain_release
		lda sound_volume
		sta volume_filter_mode
		lda sound_frequency
		sta voice1_frequency
		lda sound_frequency + $1
		sta voice1_frequency + $1
		ldx sound_waveform
		inx 
		txa 
		sta voice1_control
		rts 

; called by: p2_shot_sound
play_voice2:
		lda sound_attack_decay
		sta voice2_attack_decay
		lda sound_sustain_release
		sta voice2_sustain_release
		lda sound_volume
		sta volume_filter_mode
		lda sound_frequency
		sta voice2_frequency
		lda sound_frequency + $1
		sta voice2_frequency + $1
		ldx sound_waveform
		inx 
		txa 
		sta voice2_control
		rts 

; called by: hit_sound
play_voice3:
		lda sound_attack_decay
		sta voice3_attack_decay
		lda sound_sustain_release
		sta voice3_sustain_release
		lda sound_volume
		sta volume_filter_mode
		lda sound_frequency
		sta voice3_frequency
		lda sound_frequency + $1
		sta voice3_frequency + $1
		ldx sound_waveform
		inx 
		txa 
		sta voice3_control
		rts 

; called by: p1_shot_sound
stop_voice1:
		lda #$00
		sta voice1_control
		rts 

; called by: p2_shot_sound
stop_voice2:
		lda #$00
		sta voice2_control
		rts 

; called by: hit_sound
stop_voice3:
		lda #$00
		sta voice3_control
		rts 

; called by: l43E9
p1_shot_sound:
		jsr stop_voice1
		lda #$09
		sta sound_attack_decay
		lda #$00
		sta sound_sustain_release
		lda #$0f
		sta sound_volume
		lda #$0c
		sta sound_frequency
		lda #$08
		sta sound_frequency + $1
		lda #$20
		sta sound_waveform
		jsr play_voice1
		rts 

; called by: l4411
p2_shot_sound:
		jsr stop_voice2
		lda #$09
		sta sound_attack_decay
		lda #$00
		sta sound_sustain_release
		lda #$0f
		sta sound_volume
		lda #$0d
		sta sound_frequency
		lda #$09
		sta sound_frequency + $1
		lda #$20
		sta sound_waveform
		jsr play_voice2
		rts 

; called by: invader_hit
hit_sound:
		jsr stop_voice3
		lda #$19
		sta sound_attack_decay
		lda #$00
		sta sound_sustain_release
		lda #$0f
		sta sound_volume
		lda #$01
		sta sound_frequency
		lda #$10
		sta sound_frequency + $1
		lda #$80
		sta sound_waveform
		jsr play_voice3
		rts 

; copies the ROM font to charset, with custom_chars as characters $20-$5f
; called by: l4018
build_charset:
		sei 
		lda #$18
		sta vic_memory
		lda $01
		and #$fb
		sta $01
		ldx #$00

l4FE2:
		lda sprite0_x, x
		sta charset, x
		lda custom_chars, x
		sta charset + $100, x
		lda custom_chars + $100, x
		sta charset + $200, x
		lda $d300, x
		sta charset + $300, x
		lda voice1_frequency, x
		sta charset + $400, x
		lda $d500, x
		sta charset + $500, x
		lda $d600, x
		sta charset + $600, x
		lda $d700, x
		sta charset + $700, x
		inx 
		beq l5018
		jmp l4FE2

; jumped to by: l4FE2
l5018:
		lda $01
		ora #$04
		sta $01
		cli 
		rts 

; called by: l4018
build_sprites:
		ldx #$00

l5022:
		lda sprite_shapes, x
		sta sprites, x
		lda sprite_shapes + $40, x
		sta sprites + $40, x
		lda sprite_shapes + $80, x
		sta sprites + $80, x
		lda sprite_shapes + $c0, x
		sta sprites + $c0, x
		inx 
		cpx #$40
		bne l5022
		rts 

; called by: l490B, l4BEA
twinkle_stars:
		inc star_index
		lda star_index
		cmp #$06
		bne l504F
		lda #$00
		sta star_index

; jumped to by: twinkle_stars
l504F:
		ldx star_index
		ldy star_positions, x
		txa 
		and #$01
		cmp #$00
		bne l507A
		lda screen + $28, y
		cmp #$2a
		bne l5068
		lda #$20
		sta screen + $28, y

; jumped to by: l504F
l5068:
		jsr next_star_position
		lda screen + $28, y
		cmp #$20
		bne l5095
		lda #$2a
		sta screen + $28, y
		jmp l5095

; jumped to by: l504F
l507A:
		lda screen + $130, y
		cmp #$2a
		bne l5086
		lda #$20
		sta screen + $130, y

; jumped to by: l507A
l5086:
		jsr next_star_position
		lda screen + $130, y
		cmp #$20
		bne l5095
		lda #$2a
		sta screen + $130, y

; jumped to by: l5068, l5086
l5095:
		tya 
		sta star_positions, x
		jmp l509C

; jumped to by: l5095
l509C:
		rts 

; called by: l5068, l5086
next_star_position:
		tya 
		beq l50A5
		asl 
		beq l50A5
		bcc l50A7

; jumped to by: next_star_position
l50A5:
		eor #$1d

; jumped to by: next_star_position
l50A7:
		tay 
		rts 

; ---- game: data ----
; BCD, low byte first
; read by: l4917, l49E2, l4A10, lC14A, lC1EE
; written by: l49D0, l49FE
high_score:
		.byte	$00, $00, $00

; BCD points for a hit, set by set_hit_points
; read by: l446C, l44D4, l4549, l45BE, draw_status
; written by: set_hit_points, l4D7F, l4D90, l4DA1, l4DB2, l4DC3, l4DD4, l4DE5, l4DF6, l4E07, l4E18, l4E29, l4E3A, l4E4B, l4E5C, l4E6D, l4E7E, l4E8F, l4EA0, l4EB1, l4EC2, l4ED3
hit_points:
		.word	$1000

; read by: game_loop, l4C0B
; written by: reset_game, l4738, game_over, show_game_over
game_over_flag:
		.byte	$00
; set to make draw_scores redraw
; read by: draw_scores
; written by: title_screen, reset_game, reset_scores, l4333, l4618, l4917
scores_changed:		.byte	$00
; read by: l446C, l44D4, l4549, l45B2, bounce_cannons, check_invader_collision, l4CF0
; written by: wait_frame
collisions:		.byte	$00
; read by: fill_title_color
title_color:		.byte	$00
unused_50b2:		.byte	$00
; read by: title_loop
; written by: title_screen
; modified by: l40BF
scroll_offset:		.byte	$1e
unused_50b4:		.byte	$00
; read by: l4281
; written by: countdown
; modified by: l4281
countdown_digit:		.byte	$30
; read by: l4281
; written by: countdown, l4281
; modified by: l4281
countdown_timer:		.byte	$1d
; read by: title_loop
; written by: title_loop
; modified by: title_loop
scroll_timer:		.byte	$01

; BCD, shown on the status line
; read by: l446C, l44D4, l4549, l45BE, draw_status
; written by: reset_scores, l446C, l44D4, l4549, l45BE, invader_hit
hit_counter:
		.word	$0080

; the sound play_voice1/2/3 start
; read by: play_voice1, play_voice2, play_voice3
; written by: p1_shot_sound, p2_shot_sound, hit_sound
sound_attack_decay:
		.byte	$09
; read by: play_voice1, play_voice2, play_voice3
; written by: p1_shot_sound, p2_shot_sound, hit_sound
sound_sustain_release:		.byte	$00
; read by: play_voice1, play_voice2, play_voice3
; written by: p1_shot_sound, p2_shot_sound, hit_sound
sound_volume:		.byte	$0f

; read by: play_voice1, play_voice2, play_voice3
; written by: p1_shot_sound, p2_shot_sound, hit_sound
sound_frequency:
		.word	$090d

; read by: play_voice1, play_voice2, play_voice3
; written by: p1_shot_sound, p2_shot_sound, hit_sound
sound_waveform:
		.byte	$20

; ---- player 1 ----
; read by: check_cannon_edges, l47A0, l4817, l4842, l484D, position_p1, l4AAB, check_invader_collision
; written by: title_screen, reset_game, l4CE6
; modified by: l4830, l4842, l484D, l485A
p1_x:
		.word	$0094

; read by: l42F9, position_p1
; written by: title_screen, l40CE, reset_game, l42A7
; modified by: l42F9
p1_y:
		.byte	$fa
; 0 = moving left, 1 = moving right
; read by: bounce_cannons, check_cannon_edges, l47F9, l4830
; written by: reset_game, bounce_cannons, l476D, check_cannon_edges, l47A0, l47F9, l480F, check_invader_collision
p1_direction:		.byte	$00
; 1 for the frame the fire button went down
; read by: l40CE, l42A7, move_p1
; written by: reset_game, l4333, l43E9, l43FC, clear_fire_flags
p1_fire:		.byte	$00
; BCD, low byte first
; read by: l446C, l4549, l4917, l49D0
; written by: reset_scores, l446C, l4549
p1_score:
		.byte	$00, $00, $00
; read by: position_p1, position_p1_shot
; written by: reset_game
p1_color:		.byte	$0d
; read by: l42A7, l42F9, read_fire_buttons, update_game, bounce_cannons, update_screen
; written by: l40CE, reset_game, l42A7, show_game_over
p1_playing:		.byte	$00
; set when the cannon turned this frame
; read by: l47F9
; written by: reset_scores, bounce_cannons, l476D, check_cannon_edges, l47A0, clear_fire_flags
p1_turned:		.byte	$00

; read by: position_p1_shot, l4B18
; written by: l4817
p1_shot_x:
		.word	$0000

; read by: read_fire_buttons, move_shots, position_p1_shot
; written by: move_shots, l4817
p1_shot_y:
		.byte	$00
; 0 = no shot, $0c = flying, counting down from $0b = explosion
; read by: read_fire_buttons, check_shot_hits, l4521, move_shots, position_p1_shot
; written by: l4333, l445F, l4521, l4549, move_shots, l4817
; modified by: l446C, l44AE, l4521
p1_shot_state:		.byte	$00

; ---- player 2 ----
; read by: l47B6, l47D8, l488C, l48B7, l48C2, position_p2, l4ADA
; written by: title_screen, reset_game
; modified by: l48A5, l48B7, l48C2, l48CF
p2_x:
		.word	$011b

; read by: l431F, position_p2
; written by: title_screen, l40EB, reset_game, l42CB
; modified by: l431F
p2_y:
		.byte	$ea
; 0 = moving left, 1 = moving right
; read by: l47B6, l486E, l48A5
; written by: reset_game, bounce_cannons, l476D, l47B6, l47D8, l486E, l4884, l4CF0
p2_direction:		.byte	$00
; 1 for the frame the fire button went down
; read by: l40EB, l42CB, move_p2
; written by: reset_game, l4333, l4411, l4424, clear_fire_flags
p2_fire:		.byte	$00
; BCD, low byte first
; read by: l44D4, l45BE, l4917, l49E2, l49FE
; written by: reset_scores, l44D4, l45BE
p2_score:
		.byte	$00, $00, $00
; read by: position_p2, position_p2_shot
; written by: reset_game
p2_color:		.byte	$0e
; read by: l42CB, l431F, l43BE, l4443, bounce_cannons, l48FE
; written by: l40EB, reset_game, l42CB, show_game_over
p2_playing:		.byte	$01
; set when the cannon turned this frame
; read by: l486E
; written by: reset_scores, bounce_cannons, l476D, l47B6, l47D8, clear_fire_flags
p2_turned:		.byte	$00

; read by: position_p2_shot, l4B5F
; written by: l488C
p2_shot_x:
		.word	$0000

; read by: l43BE, l4677, position_p2_shot
; written by: l4677, l488C
p2_shot_y:
		.byte	$00
; 0 = no shot, $0c = flying, counting down from $0b = explosion
; read by: l43BE, l44B9, l4588, l4592, l4677, position_p2_shot
; written by: l4333, l44C7, l4592, l45BE, l4677, l488C
; modified by: l44D4, l4516, l4592
p2_shot_state:		.byte	$00

; read by: title_screen, l46C1, l46CC, l46DF, l470A, position_invader, l4A7C
; written by: title_screen, reset_game, l4333, l4634, l464A
; modified by: step_invader, l46C1, l46CC, l46D9
invader_x:
		.word	$0146

; read by: title_screen, l42F9, l4333
; written by: title_screen, l4333
; modified by: l42F9
invader_y:
		.byte	$3a
; 0 = moving left, 1 = moving right
; read by: l4634, step_invader, l46DF, check_invader_collision, l4CF0
; written by: reset_game, l4634, l464A, l46DF, l470A
invader_direction:		.byte	$01
; read by: title_screen, position_invader
; written by: reset_game, l4333
invader_color:		.byte	$02
; steps per frame
; read by: invader_hit, move_invader, l4BEA
; written by: reset_scores, invader_hit
; modified by: invader_hit
invader_speed:		.byte	$02
; read by: l469E, l4C0B
; written by: move_invader, l4BEA
; modified by: l469E, l4C0B
invader_steps:		.byte	$00
; read by: l4612
; written by: reset_scores
speedup_interval:		.byte	$0a
; read by: invader_hit
; written by: reset_scores, l4612
; modified by: invader_hit
speedup_counter:		.byte	$0a
; BCD; the game is over when it reaches $22
; read by: l4333, l4618, l46DF, l470A, l472E, position_invader, draw_status, set_hit_points, trainer_next_row
; written by: title_screen, reset_game, l4333, l4618, row_store_right, row_store_left, lC0F4
invader_row:		.byte	$00
unused_50e8:		.byte	$00
; read by: l43E9
; written by: reset_game, read_p1_fire, l43E9
p1_fire_held:		.byte	$00
unused_50ea:		.byte	$00
; read by: l4411
; written by: reset_game, read_p2_fire, l4411
p2_fire_held:		.byte	$00
; read by: l504F
; written by: l5095
star_positions:
		.byte	$4e, $27, $27, $ba, $4e, $d3
unused_50f2:
		.byte	$c0, $e0
; read by: twinkle_stars, l504F
; written by: twinkle_stars
; modified by: twinkle_stars
star_index:		.byte	$01
; sprite y per invader_row, indexed by the BCD value, so $0a-$0f and $1a-$1f are unused
; read by: l4333, position_invader
row_y:
		.byte	$3a, $42, $4a, $52, $5a, $62, $6a, $72, $7a, $82, $00, $00, $00, $00, $00, $00
		.byte	$8a, $92, $9a, $a2, $aa, $b2, $ba, $c2, $ca, $d2, $00, $00, $00, $00, $00, $00
		.byte	$da, $e2, $ea

; read by: l40BF
scroll_text:
		.text	"                                "
		.text	"      PRESS FIRE TO PLAY     FIR"
		.text	"E SHOOTS AND CHANGES CANNON DIRE"
		.text	"CTION     MORE POINTS WHEN 1NVAD"
		.text	"ER IS HIGH UP     1NVADER SLOWS "
		.text	"DOWN AFTER EIGHTY HITS     'DARR"
		.text	"ENTHEFOULDS     THX 'BEDFORDLVLE"
		.text	"XP     HI NATE AND TBONE/       "

; the title screen: the end of scroll_text, the logo and the copyright line
; read by: l4113
title_chars:
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $ff, $e1, $7b, $e1, $e1
		.byte	$20, $e1, $20, $fe, $e1, $e2, $7b, $e1, $e2, $e2, $e1, $e2, $7f, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $e1, $e1, $7c, $fe, $e1, $6c, $7e, $ff, $e1, $e1, $20, $e1, $e1
		.byte	$7c, $7e, $e1, $6c, $ff, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $e1, $e1, $20, $e1, $e1
		.byte	$7e, $e1, $7c, $fb, $e1, $6c, $fe, $e1, $62, $62, $e1, $20, $e1, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $32, $30, $31, $39, $20
		.byte	$44, $41, $52, $52, $45, $4e, $20, $46, $4f, $55, $4c, $44, $53, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
; read by: l413C
ground_chars:
		.byte	$20, $5d, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$5d, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $5d, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $5d, $20, $5b, $5e, $5c, $5d, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $5d, $20, $20, $5b, $5e, $5c, $20, $20, $20, $20, $20, $20
		.byte	$20, $5b, $5c, $5b, $5e, $5c, $5d, $20, $20, $20, $20, $20, $5d, $5b, $5e, $5c
		.byte	$5d, $20, $20, $5c, $5c, $20, $20, $20, $20, $5b, $5c, $5b, $5e, $5c, $5b, $20
		.byte	$20, $20, $5c, $20, $20, $20, $20, $20, $5b, $20, $20, $5c, $20, $5b, $5e, $5c
		.byte	$20, $20, $20, $5b, $5e, $5c, $20, $5d, $5f, $5c, $20, $20, $20, $5c, $20, $20
		.byte	$5b, $20, $20, $5c, $20, $5b, $20, $20, $20, $20, $20, $5c, $20, $20, $20, $5b
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $5c, $20, $5b, $20, $20, $20, $5b, $5f
		.byte	$40, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f
		.byte	$5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f
		.byte	$5f, $5f, $5f, $5f, $5f, $5f, $5f, $40, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e
		.byte	$5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e
		.byte	$5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e, $5e
; read by: l4FE2
custom_chars:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $06, $01, $01, $01, $01, $00
		.byte	$00, $1f, $00, $07, $18, $18, $1f, $00, $00, $1f, $00, $01, $00, $00, $1f, $00
		.byte	$00, $80, $00, $80, $80, $80, $80, $00, $00, $e0, $18, $e0, $00, $00, $f8, $00
		.byte	$00, $e0, $18, $e0, $18, $18, $e0, $00, $00, $38, $44, $54, $5c, $40, $3c, $00
		.byte	$ff, $38, $44, $38, $44, $44, $38, $ff, $ff, $38, $44, $44, $34, $04, $04, $ff
		.byte	$10, $00, $10, $ba, $10, $00, $10, $00, $00, $01, $02, $03, $04, $05, $06, $07
		.byte	$00, $00, $00, $00, $00, $00, $10, $20, $00, $00, $00, $7c, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $10, $00, $00, $10, $10, $10, $10, $00, $10, $00
		.byte	$00, $38, $44, $54, $54, $44, $38, $00, $00, $10, $20, $10, $10, $10, $10, $00
		.byte	$00, $78, $04, $38, $40, $40, $7c, $00, $00, $78, $04, $18, $04, $04, $78, $00
		.byte	$00, $44, $44, $44, $74, $04, $04, $00, $00, $7c, $40, $78, $04, $04, $78, $00
		.byte	$00, $30, $40, $78, $44, $44, $38, $00, $00, $7c, $00, $08, $10, $10, $10, $00
		.byte	$00, $38, $44, $38, $44, $44, $38, $00, $00, $38, $44, $44, $34, $04, $04, $00
		.byte	$00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06, $07
		.byte	$00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06, $07
		.byte	$00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06, $07
		.byte	$ff, $76, $2c, $34, $2c, $76, $ff, $00, $00, $04, $0c, $14, $24, $5c, $44, $00
		.byte	$00, $78, $44, $58, $44, $44, $5c, $00, $00, $3c, $40, $40, $40, $40, $7c, $00
		.byte	$00, $70, $48, $44, $44, $44, $5c, $00, $00, $7c, $40, $58, $40, $40, $7c, $00
		.byte	$00, $7c, $40, $58, $40, $40, $40, $00, $00, $3c, $40, $40, $44, $44, $7c, $00
		.byte	$00, $44, $44, $5c, $44, $44, $44, $00, $00, $10, $10, $10, $10, $10, $10, $00
		.byte	$00, $08, $08, $08, $08, $08, $08, $30, $00, $44, $44, $58, $44, $44, $44, $00
		.byte	$00, $40, $40, $40, $40, $40, $7c, $00, $00, $44, $2c, $54, $44, $44, $44, $00
		.byte	$00, $44, $64, $54, $4c, $44, $44, $00, $00, $38, $44, $44, $44, $44, $38, $00
		.byte	$00, $78, $44, $44, $58, $40, $40, $00, $00, $38, $44, $44, $44, $40, $3c, $00
		.byte	$00, $78, $44, $44, $58, $44, $44, $00, $00, $3c, $40, $38, $04, $04, $78, $00
		.byte	$00, $7c, $00, $10, $10, $10, $10, $00, $00, $44, $44, $44, $44, $44, $38, $00
		.byte	$00, $44, $44, $48, $50, $60, $40, $00, $00, $44, $44, $44, $54, $2c, $44, $00
		.byte	$00, $44, $44, $18, $44, $44, $44, $00, $00, $44, $44, $44, $3c, $04, $38, $00
		.byte	$00, $7c, $00, $08, $10, $20, $7c, $00, $01, $02, $06, $0a, $18, $2a, $40, $a0
		.byte	$80, $40, $a0, $30, $28, $04, $26, $05, $00, $00, $00, $00, $18, $3c, $6e, $ab
		.byte	$ff, $11, $44, $00, $00, $00, $00, $00, $99, $42, $99, $40, $aa, $55, $ff, $00
; read by: l5022
sprite_shapes:
		.byte	$00, $7e, $00, $01, $ff, $80, $03, $ff, $c0, $06, $db, $60, $0f, $ff, $f0, $0f
		.byte	$ff, $f0, $03, $99, $c0, $01, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
		.byte	$00, $08, $00, $00, $1c, $00, $00, $1c, $00, $03, $ff, $e0, $07, $ff, $f0, $07
		.byte	$ff, $f0, $07, $ff, $f0, $07, $ff, $f0, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
		.byte	$00, $08, $00, $00, $04, $00, $00, $08, $00, $00, $10, $00, $00, $08, $00, $00
		.byte	$04, $00, $00, $08, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
		.byte	$00, $42, $00, $01, $24, $80, $00, $81, $00, $06, $00, $60, $00, $81, $00, $01
		.byte	$24, $80, $00, $42, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
*=$c000

; ---- crack intro and high-score code ----
; the cracker's intro: asks whether to enable the trainer
crack_intro:
		cli 
		lda #$fc
		sta stop_vector
		lsr 
		sta irq_vector
		lda #$80
		sta kernal_case_lock
		asl 
		sta border_color
		sta background_color
		tax 

lC017:
		sta color_ram, x
		sta color_ram + $100, x
		sta color_ram + $200, x
		sta color_ram + $300, x
		inx 
		bne lC017

lC026:
		lda title_line, x
		sta screen, x
		lda question_line, x
		sta screen + $c8, x
		lda #$0f
		sta color_ram, x
		sta color_ram + $c8, x
		inx 
		cpx #$28
		bne lC026
		jsr ask_trainer
		sty cia1_port_a
		jsr load_highscore
		jsr apply_trainer
		jmp start

; called by: lC026
; modified by: lC09A
ask_trainer:
		lda #$00
		bne lC09D

; jumped to by: lC055
lC052:
		ldy #$80

; jumped to by: lC055
lC054:
		tax 

lC055:
		inx 
		bne lC055
		dey 
		bne lC054
		clc 
		lda #$e7
		sta cia1_port_a
		lda cia1_port_b
		cmp #$ff
		bne lC052
		ldy #$7f
		sty cia1_port_a
		cpy cia1_port_a
		bne lC052

lC072:
		sty cia1_port_a
		lda cia1_port_a
		lsr 
		lsr 
		lsr 
		bcc lC09D
		lsr 
		bcc lC0A2
		lsr 
		bcc lC09A
		lda #$f7
		sta cia1_port_a
		lda cia1_port_b
		lsr 
		lsr 
		bcc lC09D
		asl cia1_port_a
		lda cia1_port_b
		asl 
		bcc lC0A2
		bne lC072

; jumped to by: lC072
lC09A:
		inc ask_trainer + 1

; jumped to by: ask_trainer, lC072
lC09D:
		sec 
		lda #$19
		bne lC0A5

; jumped to by: lC072
lC0A2:
		clc 
		lda #$0e

; jumped to by: lC09D
lC0A5:
		rol trainer_flag
		sta screen + $ef
		rts 

; modified by: lC0A5, apply_trainer
trainer_flag:
		.byte	$00
unused_c0ad:
		.byte	$00, $01

; patches the game: with the trainer, invader_row's increment calls trainer_next_row;
; without it, title_screen calls save_highscore
; called by: lC026
apply_trainer:
		ror trainer_flag
		bcc lC0DB
		lda #$ea
		sta row_add_right
		sta row_add_right + 1
		sta row_add_left
		sta row_add_left + 1
		lda #$20
		sta row_store_right
		sta row_store_left
		lda #$eb
		sta row_store_right + 1
		sta row_store_left + 1
		lda #$c0
		sta row_store_right + 2
		sta row_store_left + 2
		rts 

; jumped to by: apply_trainer
lC0DB:
		lda #$20
		sta title_screen
		lda #$48
		sta title_screen + 1
		lda #$c1
		sta title_screen + 2
		rts 

; invader_row + 1, but never past $21
trainer_next_row:
		lda invader_row
		cmp #$21
		beq lC0F4
		adc #$01

; jumped to by: trainer_next_row
lC0F4:
		sta invader_row
		rts 

; read by: lC026
title_line:
		.enc	"screen"
		.text	"1NVADER +1               BY FAAY"
		.text	"D/EXCESS"
; read by: lC026
question_line:
		.text	"ALIEN CAN'T KILL YOU?           "
		.text	" (Y/N)  "

; saves high_score to disk if it changed since load_highscore read it
; called by: title_screen
save_highscore:
		ldx #$02

lC14A:
		lda loaded_highscore, x
		cmp high_score, x
		bne lC158
		dex 
		bpl lC14A
		jmp lC1B4

; jumped to by: lC14A
lC158:
		lda #$00
		sta kernal_msgflag
		lda volume_filter_mode
		sta saved_volume
		lda #$00
		sta volume_filter_mode
		lda #$0f
		tay 
		ldx kernal_device
		cpx #$08
		bpl lC172
		ldx #$08

; jumped to by: lC158
lC172:
		jsr setlfs
		lda #$0b
		ldx #$b8
		ldy #$c1
		jsr setnam
		jsr open
		lda #$0f
		jsr close
		ldy #$00
		tya 
		ldx kernal_device
		cpx #$08
		bpl lC191
		ldx #$08

; jumped to by: lC172
lC191:
		jsr setlfs
		lda #$09
		ldx #$ba
		ldy #$c1
		jsr setnam
		ldx #$a9
		ldy #$50
		stx kernal_save_start
		sty kernal_save_start + $1
		lda #$c1
		ldx #$ac
		ldy #$50
		jsr save
		lda saved_volume
		sta volume_filter_mode

; jumped to by: lC14A
lC1B4:
		jmp reset_game

; read by: lC191
; written by: lC158
saved_volume:
		.byte	$00

; SETNAM is given "S:HIGHSCORE" to scratch the old file, then "HIGHSCORE" to save it
scratch_command:
		.enc	"none"
		.text	"S:"
highscore_filename:
		.text	"HIGHSCORE"

; called by: lC026
load_highscore:
		lda #$00
		sta kernal_msgflag
		lda #$01
		ldy #$00
		ldx kernal_device
		cpx #$08
		bpl lC1D3
		ldx #$08

; jumped to by: load_highscore
lC1D3:
		stx kernal_device
		jsr setlfs
		lda #$09
		ldx #$ba
		ldy #$c1
		jsr setnam
		ldx #$a9
		ldy #$50
		lda #$00
		jsr load
		bcs lC1F7
		ldx #$02

lC1EE:
		lda high_score, x
		sta loaded_highscore, x
		dex 
		bpl lC1EE

; jumped to by: lC1D3
lC1F7:
		lda kernal_device
		jsr talk
		lda #$6f
		jsr tksa
		ldy #$00
		sty $90

lC205:
		jsr acptr
		bit $90
		bvs lC20F
		iny 
		bne lC205

; jumped to by: lC205
lC20F:
		jsr untlk
		rts 

; read by: lC14A
; written by: lC1EE
loaded_highscore:
		.byte	$00, $00, $00

.virtual $d000
; ---- VIC-II ----
; read by: l4FE2
; written by: title_screen, position_invader, l4A7C
sprite0_x:		.byte	?
; written by: title_screen, l42F9, position_invader
sprite0_y:		.byte	?
; written by: position_p1, l4AAB
sprite1_x:		.byte	?
; written by: position_p1
sprite1_y:		.byte	?
; written by: position_p2, l4ADA
sprite2_x:		.byte	?
; written by: position_p2
sprite2_y:		.byte	?
; written by: position_p1_shot, l4B18
sprite3_x:		.byte	?
; written by: position_p1_shot
sprite3_y:		.byte	?
; written by: position_p2_shot, l4B5F
sprite4_x:		.byte	?
; written by: position_p2_shot
sprite4_y:		.byte	?
sprite5_x:		.byte	?
sprite5_y:		.byte	?
sprite6_x:		.byte	?
sprite6_y:		.byte	?
sprite7_x:		.byte	?
sprite7_y:		.byte	?
; read by: position_invader, l4A7C, position_p1, l4AAB, position_p2, l4ADA, position_p1_shot, l4B18, position_p2_shot, l4B5F
; written by: position_invader, l4A7C, position_p1, l4AAB, position_p2, l4ADA, position_p1_shot, l4B18, position_p2_shot, l4B5F
sprites_x_msb:		.byte	?
vic_control1:		.byte	?
; read by: wait_frame
raster:		.byte	?
light_pen_x:		.byte	?
light_pen_y:		.byte	?
; read by: position_p1_shot, l4B27, position_p2_shot, l4B6E
; written by: title_screen, position_p1_shot, l4B27, position_p2_shot, l4B6E
sprite_enable:		.byte	?
vic_control2:		.byte	?
; written by: title_screen, l4333
sprite_expand_y:		.byte	?
; written by: build_charset
vic_memory:		.byte	?
vic_irq_status:		.byte	?
vic_irq_enable:		.byte	?
sprite_priority:		.byte	?
sprite_multicolor:		.byte	?
; written by: title_screen, l4333
sprite_expand_x:		.byte	?
; read by: wait_frame
sprite_sprite_collision:		.byte	?
sprite_background_collision:		.byte	?
; written by: start, crack_intro
border_color:		.byte	?
; written by: start, crack_intro
background_color:		.byte	?
background_color1:		.byte	?
background_color2:		.byte	?
background_color3:		.byte	?
sprite_multicolor0:		.byte	?
sprite_multicolor1:		.byte	?
; written by: title_screen, position_invader
sprite0_color:		.byte	?
; written by: position_p1
; modified by: l42A7
sprite1_color:		.byte	?
; written by: position_p2
; modified by: l42CB
sprite2_color:		.byte	?
; written by: position_p1_shot
sprite3_color:		.byte	?
; written by: position_p2_shot
sprite4_color:		.byte	?
sprite5_color:		.byte	?
sprite6_color:		.byte	?
sprite7_color:		.byte	?
.endv

.virtual $d400
; ---- SID ----
; read by: l4FE2
; written by: play_voice1
voice1_frequency:		.word	?
voice1_pulse_width:		.word	?
; written by: play_voice1, stop_voice1
voice1_control:		.byte	?
; written by: play_voice1
voice1_attack_decay:		.byte	?
; written by: play_voice1
voice1_sustain_release:		.byte	?
; written by: play_voice2
voice2_frequency:		.word	?
voice2_pulse_width:		.word	?
; written by: play_voice2, stop_voice2
voice2_control:		.byte	?
; written by: play_voice2
voice2_attack_decay:		.byte	?
; written by: play_voice2
voice2_sustain_release:		.byte	?
; written by: play_voice3
voice3_frequency:		.word	?
voice3_pulse_width:		.word	?
; written by: play_voice3, stop_voice3
voice3_control:		.byte	?
; written by: play_voice3
voice3_attack_decay:		.byte	?
; written by: play_voice3
voice3_sustain_release:		.byte	?
filter_cutoff:		.word	?
filter_control:		.byte	?
; read by: lC158
; written by: play_voice1, play_voice2, play_voice3, lC158, lC191
volume_filter_mode:		.byte	?
.endv

.virtual $d800
; ---- color RAM ----
; written by: l4018, l4131, l413C, l415C, l4166, l417E, l41BA, lC017, lC026
; modified by: l41CC
color_ram:
		.fill	1000
.endv

.virtual $dc00
; ---- CIA 1 ----
; read by: read_p2_fire, lC055, lC072
; written by: lC026, lC055, lC072
; modified by: lC072
cia1_port_a:		.byte	?
; read by: read_p1_fire, lC055, lC072
cia1_port_b:		.byte	?
.endv
; ---- KERNAL jump table ----

.virtual $ff81
cint:
		.fill	3
ioinit:
		.fill	3
ramtas:
		.fill	3
restor:
		.fill	3
vector:
		.fill	3
setmsg:
		.fill	3
second:
		.fill	3
; called by: lC1F7
tksa:
		.fill	3
memtop:
		.fill	3
membot:
		.fill	3
scnkey:
		.fill	3
settmo:
		.fill	3
; called by: lC205
acptr:
		.fill	3
ciout:
		.fill	3
; called by: lC20F
untlk:
		.fill	3
unlsn:
		.fill	3
listen:
		.fill	3
; called by: lC1F7
talk:
		.fill	3
readst:
		.fill	3
; called by: lC172, lC191, lC1D3
setlfs:
		.fill	3
; called by: lC172, lC191, lC1D3
setnam:
		.fill	3
; called by: lC172
open:
		.fill	3
; called by: lC172
close:
		.fill	3
chkin:
		.fill	3
chkout:
		.fill	3
clrchn:
		.fill	3
chrin:
		.fill	3
; called by: start
chrout:
		.fill	3
; called by: lC1D3
load:
		.fill	3
; called by: lC191
save:
		.fill	3
settim:
		.fill	3
rdtim:
		.fill	3
stop:
		.fill	3
getin:
		.fill	3
clall:
		.fill	3
udtim:
		.fill	3
screen_size:
		.fill	3
plot:
		.fill	3
iobase:
		.fill	3
.endv
