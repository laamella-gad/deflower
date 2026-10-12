
.virtual $0000
; ---- zero page ----
cpu_port_direction:		.byte	?
; read by: start2, $a003, irq, nmi, bank_out_io, bank_in_io, $c041, $c06a, lC0F3
; written by: d0103, decrunch, start2, $a007, irq, $a679, bank_out_io, bank_in_io, $c045, $c06e, lC0F3
cpu_port:		.byte	?
; read by: l2C60, print_inline, store_hex, nmi
; written by: print_inline, $a66f, $a672, lC13B
; modified by: l2C60, print_inline, store_hex
text_pointer:		.word	?
; read by: l0DC7, scroll_text, draw_shape, color_text, nmi, lA8CB, draw_wind, lB396, $b60a, $b612, $b616, lB78E
; written by: l0DC7, scroll_text, draw_shape, draw_objects, color_text, $a669, $a66c, lA8CB, draw_wind, lB396, $b600, $b604, $b614, $b61a
; modified by: l0DC7, color_text
pointer_04:		.word	?
; read by: to_log, from_log, clear_bitmap, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF, clear_screen, nmi, fill_colors, title_screen, lB396, next_music_byte, lB8A8, $b9fa, $b9ff, $ba19, $ba1e, $bbe8, $bbed
; written by: to_log, from_log, clear_bitmap, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF, read_hex_word, clear_screen, $a663, $a666, fill_colors, title_screen, lB396, lB8A8, $ba29, $ba2e, $ba43, $ba48, $bbd5, $bbda
; modified by: to_log, from_log, clear_bitmap, l18EF, clear_screen, fill_colors, title_screen, next_music_byte, music_step
pointer_06:		.word	?
; read by: set_cell_color, l18EF, draw_view, collect_objects, draw_terrain, draw_hole_shape, draw_polygon, l286B, project_vertex, collect_features, lA927, lB396
; written by: clear_bitmap, l18EF, draw_view, collect_objects, find_cell, draw_terrain, draw_hole_shape, collect_features, clear_screen, fill_colors, lA927, title_screen, lB396
; modified by: clear_bitmap, collect_objects, clear_screen, fill_colors, title_screen
pointer_08:		.word	?
; read by: l0DC7, scroll_text, l0EC7, d129A, test_pixel, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF, replot_seeds, color_text, nmi, $b84e, $b850
; written by: l0DC7, scroll_text, pixel_address, test_pixel, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF, color_text, $a657, $a65a
bitmap_pointer:		.word	?
; read by: l18EF
; written by: l18EF
v0c:		.byte	?
; read by: flood_fill, l18EF
; written by: flood_fill, l18EF
v0d:		.byte	?
; read by: log_multiply, log_divide_into, project, rotate_45, draw_line, l18EF, scale_step, sort_objects, compute_shot, l34C1, l35A1, l3E04, l4210, lAE18, $b548, $b54a
; written by: log_multiply, log_divide_into, project, rotate_45, draw_line, flood_fill, l18EF, scale_step, sort_objects, compute_shot, l34C1, l35A1, l3E04, l4210, lAE18, $b52b, $b52d
; modified by: sort_objects
log_value:		.word	?
; read by: to_view, rotate_0, rotate_1, rotate_2, rotate_3, rotate_45, add_fill_seed, draw_line, flood_fill, l18EF, draw_view, find_cell, project_vertex, l3711
; written by: to_view, rotate_0, draw_line, flood_fill, l18EF, draw_view, collect_objects, l28E9, clip_edge, project_vertex, l3711, draw_flag, $b703, $b708
; modified by: draw_line, find_cell, l3711
point_x:		.word	?
; read by: to_view, rotate_0, rotate_1, rotate_2, rotate_3, rotate_45, rotate_6, rotate_7, horizontal_line, vertical_line, draw_line, l18EF, draw_view, find_cell, project_vertex, l3711
; written by: to_view, rotate_0, rotate_6, rotate_7, draw_line, flood_fill, l18EF, draw_view, collect_objects, l28E9, clip_edge, project_vertex, l3711, draw_flag, $b70d, $b712
; modified by: find_cell, l3711
point_y:		.word	?
; the start of the line being drawn
; read by: horizontal_line, draw_line, line_start_on_screen, draw_clipped_line, clip_edge, draw_flag, draw_wind
; written by: horizontal_line, draw_line, draw_shape, draw_clipped_line, draw_polygon, clip_edge, lA901, draw_flag, draw_wind, lB396, $b649, $b656
; modified by: draw_flag
line_x:		.word	?
; read by: vertical_line, draw_line, line_start_on_screen, draw_clipped_line, clip_edge, draw_flag, draw_wind
; written by: vertical_line, draw_line, draw_shape, draw_clipped_line, draw_polygon, clip_edge, lA901, draw_flag, draw_wind, lB396, $b64d
; modified by: draw_flag
line_y:		.word	?
; read by: add_fill_seed, l1501, horizontal_line, vertical_line, draw_line, set_cell_color, replot_seeds, $b815
; written by: horizontal_line, vertical_line, draw_line, l18EF, replot_seeds
; modified by: l18EF
plot_y:		.byte	?
unused_19:
		.fill	2
; read by: to_view, draw_view, check_out_of_bounds, l3711, $37a6, $37aa, $37e0, $37e6, face_hole, setup_hole, l3AC7, l3EF4, shot_loop, lA99D, save_player
; written by: $30fd, $3103, $37b9, $37bf, $37f5, $37f9, setup_hole, setup_practice_hole, l3AC7, l3EF4, new_game, shot_loop, lA99D, select_player
; modified by: setup_hole, l3EF4
ball_x:		.word	?
; read by: to_view, draw_view, check_out_of_bounds, l3711, $37ae, $37b2, $37d4, $37da, face_hole, setup_hole, l3AC7, l3EF4, shot_loop, lA99D, save_player
; written by: $3109, $310f, $37c5, $37cb, $37ed, $37f1, setup_hole, setup_practice_hole, l3AC7, l3EF4, new_game, shot_loop, lA99D, select_player
; modified by: setup_hole, l3EF4
ball_y:		.word	?
; read by: l0DC7, message_line, color_text, print_score_labels, $a196, $a1a7, $a1b8, $a1c9, $a1dc, $a1f0, $a203, nmi, print_par_result, draw_wind, aim
; written by: l0DC7, l0E4F, scroll_text, message_line, print_club_name, setup_hole, color_text, main, print_score_labels, $a19b, $a1ac, $a1bd, $a1ce, $a1e1, $a1f5, $a208, $a65d, add_stroke, update_scores, print_par_result, draw_wind, title_screen, $b338, aim, lB5EE
text_x:		.byte	?
; read by: l0DC7, l0E4F, color_text, nmi, draw_wind
; written by: l0E4F, scroll_text, message_line, print_club_name, setup_hole, color_text, main, print_score_labels, $a660, add_stroke, update_scores, print_par_result, draw_wind, title_screen, $b33c, aim, lB5EE
text_y:		.byte	?
; read by: to_view
; written by: to_view
v21:		.byte	?
; read by: to_view
; written by: to_view
; modified by: to_view
octant:		.byte	?
; the world position that a shape's relative points start from
; read by: collect_objects, draw_terrain, draw_hole_shape, l286B, project_vertex, collect_features
; written by: find_cell, draw_terrain, draw_hole_shape
; modified by: draw_hole_shape
base_x:		.word	?
; read by: collect_objects, draw_terrain, draw_hole_shape, l286B, project_vertex, collect_features
; written by: find_cell, draw_terrain, draw_hole_shape
; modified by: draw_hole_shape
base_y:		.word	?
; read by: draw_objects, collect_objects, sort_objects
; written by: draw_view
; modified by: collect_objects, sort_objects
object_count:		.byte	?
; read by: set_cell_color
; written by: draw_object
object_depth:		.byte	?
; read by: vertical_line, draw_line, line_start_on_screen, pen_on_screen, draw_wind
; written by: main, draw_wind
clip_top:		.byte	?
unused_2a:
		.fill	3
; read by: d0103
; written by: d0103
decrunch_pointer:		.word	?
unused_2f:
		.fill	50
; read by: mirror_sprite, reverse_bits, l3253, setup_hole
; written by: mirror_sprite, l3253, setup_hole
; modified by: mirror_sprite
pointer_61:		.word	?
; written by: reverse_bits
; modified by: reverse_bits
v63:		.byte	?
; read by: set_cell_color
; written by: l18EF
pointer_64:		.word	?
; read by: $2ea8, $2fb9, $2fc8, $3796, l3EF4, shot_loop, save_player, compute_drift
; written by: $2eba, setup_hole, l3EF4, select_player
hole_distance:		.byte	?
; read by: vertical_line, draw_line, l18EF, line_start_on_screen, pen_on_screen
; written by: draw_terrain, reset_clip, main
clip_bottom:		.byte	?
unused_68:
		.fill	93
; the KERNAL's last key pressed
; read by: snapshot_pc, $a641
kernal_lstx:		.byte	?
; written by: decrunch
unused_c6:
		.fill	49
; written by: decrunch_get_byte
; modified by: l0211, l0226
vf7:		.byte	?
; read by: d0103
; written by: d0103
vf8:		.byte	?
; called by: d0103
vf9:		.byte	?
; read by: d0103
vfa:		.byte	?
; read by: d0103, old_loader, $c059
; written by: old_loader, $c049
; modified by: $0100
vfb:		.byte	?
; read by: old_loader, $c064
; written by: old_loader, $c04d
; modified by: old_loader, $c060
vfc:		.byte	?
; read by: old_loader, load_animation, draw_animation_frame, l33C0, $c05b
; written by: old_loader, load_animation, draw_animation_frame, $c051, $c055
; modified by: old_loader, $c062
pointer_fd:		.word	?
unused_ff:		.byte	?
.endv

*=$0100
		inc vfb
		dex 
; read by: add_fill_seed
d0103:
		rts 

; jumped to by: d0103
l0104:
		ldy vf8
		ldx #$02
		jsr l022F
		sta vf8
		tya 
; jumped to by: d0103
l010E:
		ldx #$06
		jsr l022F
		jsr @w vf9
; jumped to by: d0103, decrunch
l0116:
		ldy #$00
		tya 
		ldx #$02
		jsr l022F
		cmp vf8
		bne l010E
		jsr l0211
		sta decrunch_pointer
		lsr 
		bne l0169
		jsr l0225
		lsr 
		bcc l0177
		jsr l0225
		lsr 
		bcc l0104
		iny 
		jsr l0211
		sta decrunch_pointer
		cmp #$80
		bcc l014B
		ldx #$01
		jsr l0226
		sta decrunch_pointer
		jsr l0211
		tay 
; jumped to by: d0103
l014B:
		jsr l0211
		tax 
		lda $01a5, x
		cpx #$20
		bcc l015C
		txa 
		ldx #$03
		jsr l0226
; jumped to by: d0103
l015C:
		ldx decrunch_pointer
		inx 
; jumped to by: d0103
l015F:
		jsr @w vf9
		bne l015F
		dey 
		bne l015F
; jumped to by: d0103
l0167:
		beq l0116
; jumped to by: d0103
l0169:
		jsr l0211
		cmp #$ff
		beq l0193
		sbc #$00
		ldx #$00
		jsr l022F
; jumped to by: d0103
l0177:
		sta decrunch_pointer + $1
		jsr l0223
		adc vfa
		ldx decrunch_pointer
		sta decrunch_pointer
		lda vfb
		sbc decrunch_pointer + $1
		sta decrunch_pointer + $1
		inx 
; jumped to by: d0103
l0189:
		lda (decrunch_pointer), y
		iny 
		jsr @w vf9
		bne l0189
		beq l0167
; jumped to by: d0103
l0193:
		lda #$37
		sta cpu_port
		dec c128_clock
		lda vfa
		sta decrunch_pointer
		lda vfb
		sta decrunch_pointer + $1
		cli 
		jmp start

decrunch_table:
		.byte	$00, $ff, $04, $fe, $01, $fc, $0a, $4a, $80, $02, $03, $06, $08, $20, $0d, $60
		.byte	$ea, $f8, $fa, $fd, $05, $0c, $10, $38, $c0, $ca, $cc, $d0, $09, $21, $30, $a2
unused_stack:
		.byte	$00, $00, $00, $00, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $ff, $ff, $ff, $ff
		.byte	$00, $00, $00, $70, $70, $a5, $70, $a5, $70, $a5, $6f, $70, $a5, $70, $70, $a5
		.byte	$06, $04, $70, $a5, $06, $00, $70, $70, $a5, $06, $70, $a5, $06, $2a, $05, $fc
		.byte	$a1, $f6, $2e
; written by: decrunch
stack:
		.byte	$05, $0f, $38, $9f, $31, $a3, $a2

; called by: l0211, l0226
decrunch_get_byte:
		pha 
		lda unused_ed07 + $c
; modified by: decrunch_get_byte
d0202 = $0202
; modified by: decrunch_get_byte
d0203 = $0203
		rol 
		sta vf7
		inc d0202
		bne l020F
		inc d0203
; jumped to by: decrunch_get_byte
l020F:
		pla 
		rts 

; called by: d0103
l0211:
		inx 
		txa 
; jumped to by: l0211
l0213:
		asl vf7
		bne l021A
		jsr decrunch_get_byte
; jumped to by: l0211
l021A:
		bcc l022E
		inx 
		cpx #$08
		bne l0213
		beq l022E
; called by: d0103
l0223:
		ldx #$07
; called by: d0103
l0225:
		inx 
; called by: d0103
; jumped to by: l022F
l0226:
		asl vf7
		bne l022D
		jsr decrunch_get_byte
; jumped to by: l0226
l022D:
		rol 
; jumped to by: l0211
l022E:
		dex 
; called by: d0103
l022F:
		bne l0226
		clc 
		rts 

.virtual $0233
; ---- KERNAL workspace ----
kernal_workspace:
		.fill	225
.endv

*=$0314

; the KERNAL's IRQ and NMI vectors, pointing into RAM under BASIC
; read by: install_interrupts
; written by: install_interrupts
irq_vector:
		.addr	irq

.virtual $0316
brk_vector:		.addr	?
.endv

*=$0318

; written by: install_interrupts
nmi_vector:
		.addr	nmi

.virtual $031a
kernal_vectors:
		.fill	34
.endv

*=$033c

; called by: l08D0
tape_header:
		.byte	$03, $01, $08, $7b, $71

tape_name:
		.text	"3D GOLF         "

.virtual $0351
tape_buffer_rest:
		.fill	175
; ---- game variables, in the old text screen ----
; the hole (flag) position
; read by: $37b6, $37bc, face_hole, l3EF4, draw_flag, $b700, $b705
; written by: setup_hole, setup_practice_hole
hole_x:		.word	?
; read by: $37c2, $37c8, face_hole, l3EF4, draw_flag, $b70a, $b70f
; written by: setup_hole, setup_practice_hole
hole_y:		.word	?
; read by: $2eac, check_landing, check_out_of_bounds, $3187, check_terrain, l3C3F, l3CB7, $3cfe, l3D9F, ball_flight, l3EF4, $b515, $b6f8
; written by: setup_hole, shot_loop
green_view:		.byte	?
; per player: where the ball was before the shot, put back after water
; read by: $30fa, $3100
; written by: l3EF4
safe_ball_x:
		.fill	4
; read by: $3106, $310c
; written by: l3EF4
safe_ball_y:
		.fill	4
; read by: $b9cd, $ba26, $ba7a, $bbc6, $bbf2
; written by: $ba0a, $ba6e, $baad, $bbc9, $bbf5
v040d:		.byte	?
; read by: $b9d3, $ba2b, $ba80
; written by: $ba10, $ba74, $bab3
v040e:		.byte	?
; read by: next_music_byte, lB8A8, $b9dc, $ba89, $bac5
; written by: lB8A8, $b9fc, $ba5f, $babc
; modified by: $bacd
v040f:		.byte	?
; read by: next_music_byte, lB8A8, $b9e2, $ba8f
; written by: lB8A8, $ba01, $ba65, $bac2
; modified by: $baca
v0410:		.byte	?
; read by: $b9eb, $ba33, $ba98
; written by: $ba16, $ba50, $bad2
; modified by: $ba38
v0411:		.byte	?
; read by: $b9f1, $ba9e, $bbd2
; written by: $ba56, $bbea
v0412:		.byte	?
; read by: $bbd7
; written by: $bbef
v0413:		.byte	?
unused_0414:
		.fill	2
; read by: music_start
; written by: music_start, select_tune
v0416:		.byte	?
; read by: music_start
; written by: music_start, select_tune
v0417:		.byte	?
unused_0418:		.byte	?
; written by: music_start, select_tune
v0419:		.byte	?
; written by: music_start, select_tune
v041a:		.byte	?
unused_041b:
		.fill	2
; written by: music_start, select_tune
v041d:		.byte	?
; written by: music_start, select_tune
v041e:		.byte	?
unused_041f:		.byte	?
; written by: music_start, select_tune
v0420:		.byte	?
; written by: music_start, select_tune
v0421:		.byte	?
unused_0422:
		.fill	2
; written by: music_start, select_tune
v0424:		.byte	?
; written by: music_start, select_tune
v0425:		.byte	?
unused_0426:		.byte	?
; written by: music_start, select_tune
v0427:		.byte	?
; written by: music_start, select_tune
v0428:		.byte	?
; read by: lB8A8, $ba07, $baaa, $bab9
; written by: lB8A8
v0429:		.byte	?
; read by: $ba0d, $bab0, $babf
; written by: lB8A8
v042a:		.byte	?
; read by: music_step, $bafa, $bb4f
; written by: music_step
music_note:		.byte	?
; read by: $bb11, $bb6e
; written by: music_step
music_duration:		.byte	?
; read by: $bb14, $bb8b
; written by: init_sid
music_tempo:		.byte	?
; read by: music_push, music_pop, $bb34, $bb43, $bb63, $bb71, $bb7a, $bbbd, $bbdf
; written by: $bb31
; modified by: $bb77
music_voice:		.byte	?
; read by: $bb54
; written by: $bb3f
v042f:		.byte	?
; read by: $bb46, $bb66
v0430:		.byte	?
; written by: init_sid
v0431:		.byte	?
; written by: $bae2, $baf4, init_sid
v0432:		.byte	?
; written by: init_sid
v0433:		.byte	?
; written by: $bb74
; modified by: $bb37
v0434:		.byte	?
; written by: music_start
v0435:		.byte	?
; written by: music_start
v0436:		.byte	?
; written by: music_start
v0437:		.byte	?
; read by: $bbb3
; written by: music_start
music_saved_stack:		.byte	?
; read by: lAE92, music_push, lB8A8, $ba40, $ba4d, $ba5c, $ba6b
; written by: lAE92, music_pop, lB8A8, $b9d0, $b9df, $b9ee, $ba1b, $ba7d, $ba8c, $ba9b
v0439:		.byte	?
; read by: select_player, music_push, lB8A8, $ba45, $ba53, $ba62, $ba71
; written by: save_player, music_pop, lB8A8, $b9d6, $b9e5, $b9f4, $ba20, $ba83, $ba92, $baa1
v043a:		.byte	?
; read by: select_player
; written by: save_player
v043b:		.byte	?
; read by: select_player
; written by: save_player
v043c:		.byte	?
; read by: select_player
; written by: save_player
v043d:		.byte	?
; read by: lAE92
; written by: lAE92, save_player
v043e:		.byte	?
; read by: lAE92
; written by: lAE92, save_player
v043f:		.byte	?
; read by: lAE92
; written by: lAE92, save_player
v0440:		.byte	?
; read by: lAE92
; written by: lAE92, save_player
v0441:		.byte	?
; read by: select_player
; written by: save_player
v0442:		.byte	?
; read by: $2fc5, shot_loop, select_player
; written by: save_player
v0443:		.byte	?
unused_0444:
		.fill	4
; read by: lAE92
; written by: lAE92
v0448:		.byte	?
; read by: lAE92
; written by: lAE92
v0449:		.byte	?
; read by: lAE92
; written by: lAE92
v044a:		.byte	?
; read by: lAE92
; written by: lAE92
v044b:		.byte	?
unused_044c:		.byte	?
; read by: shot_loop
v044d:		.byte	?
; read by: $2fb3, shot_loop, fill_colors, lAC2B, lAE92, read_joystick
; written by: main, $b31a, $b34b
game_mode:		.byte	?
; read by: draw_golfer, $2fbe, $30f3, $378c, l3EF4, $a488, $a50b, add_stroke, update_scores, select_player, save_player, print_par_result, read_joystick
; written by: hole_loop, lAC2B, select_player
; modified by: lAC2B
current_player:		.byte	?
; read by: l382B, update_scores, print_par_result
; written by: setup_hole, new_game
par:		.byte	?
; read by: l382B, setup_hole, hole_loop, shot_loop, change_wind, read_hole_number
; written by: l382B, setup_hole, shot_loop, read_hole_number
hole_number:		.byte	?
; read by: face_hole, l3956, l3965, l3EF4, save_player
; written by: face_hole, l3965, l3EF4, hole_loop, save_player
; modified by: face_hole, l3EF4
v0452:		.byte	?
; read by: face_hole, l3956, l3965, l3EF4, save_player
; written by: face_hole, l3965, l3EF4, hole_loop, save_player
; modified by: face_hole, l3EF4
v0453:		.byte	?
; read by: face_hole, l3956, l3965, l3EF4, save_player
; written by: face_hole, l3965, l3EF4, save_player
; modified by: l3EF4
v0454:		.byte	?
; read by: face_hole, l3956, l3965, l3EF4, save_player
; written by: face_hole, l3965, l3EF4, save_player
; modified by: l3EF4
v0455:		.byte	?
; read by: l3EF4, save_player
; written by: l3EF4, select_player
v0456:		.byte	?
; read by: l34C1
; written by: compute_drift
v0457:		.byte	?
; read by: compute_shot
; written by: compute_drift
v0458:		.byte	?
; read by: draw_wind
; written by: compute_drift
v0459:		.byte	?
; read by: change_wind, compute_drift
; written by: change_wind, random_wind
wind_direction:		.byte	?
; read by: change_wind, compute_drift
; written by: change_wind, random_wind
wind_strength:		.byte	?
; read by: $2dd3, $2e30, $2e68, $2e7d
; written by: $2dc2, $2e0e, $2e46, $2e6f
frame_timer_reload:		.byte	?
; read by: $2dcb, $2e21, $2e75
; written by: $2dc5, $2dd6, $2e11, $2e43, $2e6b, $2e80
; modified by: snapshot_pc
frame_timer:		.byte	?
; read by: l34C1
; written by: $2dbd
; modified by: $2dc8
v045e:		.byte	?
; read by: $2e5b, $2e83
; written by: $2df0, $2e89
; modified by: $2df8
v045f:		.byte	?
; written by: $2df5
; modified by: $2dfd
v0460:		.byte	?
; read by: l34C1
; written by: $2e5f
v0461:		.byte	?
unused_0462:		.byte	?
; read by: $2e37, l34C1
; written by: $2e09
; modified by: $2e1e
v0463:		.byte	?
; read by: swing, $31d0, draw_animation_frame, l33C0
; written by: draw_golfer, $31d6, draw_animation_frame
golfer_x:		.byte	?
unused_0465:		.byte	?
; read by: l33C0
; written by: draw_golfer
golfer_y:		.byte	?
unused_0467:
		.fill	3
; read by: set_golfer_colors, raise_meter, lower_meter, $2dd9, $2de7, $2e29
; written by: set_golfer_colors, raise_meter, lower_meter
power_level:		.byte	?
unused_046b:		.byte	?
; read by: l3EF4, shot_loop
; written by: $37e3, l3EF4
v046c:		.byte	?
; read by: l3EF4, shot_loop
; written by: $37e9, l3EF4
v046d:		.byte	?
; read by: l3EF4, shot_loop
; written by: $37d7, l3EF4
v046e:		.byte	?
; read by: l3EF4, shot_loop
; written by: $37dd, l3EF4
v046f:		.byte	?
; read by: l3D9F, ball_flight, draw_flag
; written by: shot_loop, draw_flag
green_flag_x:		.byte	?
; read by: l3D9F, ball_flight, draw_flag, $b532
; written by: shot_loop, draw_flag
green_flag_y:		.byte	?
; read by: $b4e4
; written by: lB458
aim_x:		.byte	?
; read by: $b4de
aim_y:		.byte	?
; read by: $b56b
aim_max:		.byte	?
; read by: $b58f
aim_min:		.byte	?
; read by: l36E6, $b50c, $b51a, $b568, $b58c
; written by: l3EF4, $b4f7, $b512, $b558
; modified by: $b573, $b597
aim_offset:		.byte	?
; read by: clear_screen
; written by: l31FC, l3202
v0477:		.byte	?
; read by: color_text
; written by: main
text_color:		.byte	?
; read by: music_push, music_pop
; written by: music_push, music_pop
v0479:		.byte	?
; written by: music_start
v047a:		.byte	?
; written by: music_start
v047b:		.byte	?
; written by: music_start
v047c:		.byte	?
; read by: music_pop
; written by: music_push
v047d:		.byte	?
; what the KERNAL printed while loading, under the game variables
; read by: decrunch
old_screen:
		.fill	837
; called by: tamper_crash2
l07C3:
		.fill	3
; called by: tamper_crash
l07C6:
		.fill	34
unused_07e8:
		.fill	24
.endv

*=$0800

basic_start:
		.byte	$00
basic_stub:
		.byte	$0b, $08, $ef, $00, $9e, $32, $30, $36, $31, $00, $00, $00

decrunch:
		sei 
		inc c128_clock
		lda #$38
		sta cpu_port
		ldx #$34
; jumped to by: decrunch
l0817:
		lda $0842, x
		sta stack + $6, x
		dex 
		bne l0817
		ldx #$cf
; jumped to by: decrunch
l0822:
		lda decruncher_leftover + $32, x
		sta @w unused_c6 + $30, x
		dex 
		bne l0822
		ldy #$69
; jumped to by: decrunch
l082D:
		dex 
		lda old_screen + $2fd, x
; modified by: decrunch
d0830 = $0830
		sta terrain_82bc + $57, x
; modified by: decrunch
d0833 = $0833
		txa 
		bne l082D
		dec d0833
		dec d0830
		dey 
		bne l082D
		jmp l0116

; read by: decrunch
decruncher_leftover:
		.byte	$48, $ad, $dc, $84, $2a, $85, $f7, $ee, $02, $02, $d0, $03, $ee, $a2, $01, $20
		.byte	$3c, $03, $4c, $80, $08, $4c, $80, $08, $69, $a0, $08, $20, $bd, $ff, $a9, $00
		.byte	$20, $d5, $ff, $4c, $80, $08, $42, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00

old_loader:
		lda #$00
		sta background_color
		sta vfb
		lda #$20
		bne l088B
		jsr l08D0
		jsr l08D0
		jsr l08D0
; jumped to by: old_loader
l088B = $088b
		lda #$06
		sta background_color
		lda cia2_port_a
		ora #$03
		sta cia2_port_a
		lda #$15
		sta vic_memory
		lda vic_control1
		and #$df
		sta vic_control1
		lda vic_control2
		and #$ef
		sta vic_control2
		ldy #$00
		sty vfb
		sty pointer_fd
		lda #$60
		sta vfc
		lda #$e0
		sta pointer_fd + $1
; jumped to by: old_loader
l08BC:
		lda (vfb), y
		sta (pointer_fd), y
		iny 
		bne l08BC
		inc vfc
		inc pointer_fd + $1
		lda vfc
		cmp #$70
		bne l08BC
		jmp start

; called by: old_loader
; read by: tamper_check
l08D0:
		ldx loader_part
		jsr tape_header
		inc loader_part
		rts 

; read by: l08D0, tamper_check
; modified by: l08D0
loader_part:
		.byte	$06, $ea
		ldy #$08
		jsr setnam
		lda #$00
		jsr load
		inc loader_part2
		rts 

; modified by: $08e6
loader_part2:
		.byte	$43
unused_08eb:
		.byte	$f9, $d0, $04, $a4, $ff, $d0, $f3, $c6, $fc, $a5, $fb, $18, $65, $ff, $90, $02
		.byte	$e6, $fc, $85, $fb, $60

; ---- routine names ----
; converts the 16-bit A:X to a log: A the fraction (in 32nds of an octave), X the exponent
; called by: project, rotate_45, scale_step, compute_shot, l34C1, l35A1, l3E04, l4210, lAE18, $b528, $b538, $b542
to_log:
		stx pointer_06
		ldx #$00
		cmp #$00
		beq l0910
; jumped to by: to_log
l0908:
		inx 
		lsr 
		php 
		ror pointer_06
		plp 
		bne l0908
; jumped to by: to_log
l0910:
		ldy pointer_06
		lda log_table, y
		cpy #$00
		beq l091B
		clc 
		rts 

; jumped to by: to_log
l091B:
		ldx #$c0
		sec 
		rts 

; ---- 3D engine ----
; back from a log in A:X to a 16-bit value
; called by: project, rotate_45, scale_step, l34C1, l3E04, l4210, lAE18, $b54c
; jumped to by: l35A1
from_log:
		cmp #$80
		bcc l0927
		and #$7f
		bpl l092B
; jumped to by: from_log
l0927:
		dex 
		dex 
		dex 
		dex 
; jumped to by: from_log
l092B:
		tay 
		lda exp_table, y
		sta pointer_06
		lda #$00
		cpx #$00
		beq l0941
		bmi l0945
; jumped to by: from_log
l0939:
		asl pointer_06
		rol 
		bcs l0942
		dex 
		bne l0939
; jumped to by: from_log
l0941:
		clc 
; jumped to by: from_log
l0942:
		ldx pointer_06
		rts 

; jumped to by: from_log
l0945:
		lsr pointer_06
		inx 
		bne l0945
		beq l0941
; log_value -= A:X, i.e. divides
; called by: project, compute_shot, l34C1, l3E04, l4210, lAE18, $b53b
log_divide:
		jsr log_negate
; log_value += A:X, i.e. multiplies
; called by: project, scale_step, compute_shot, l34C1, l35A1, l3E04, l4210, $b545
log_multiply:
		clc 
		adc log_value
		sta log_value
		php 
		txa 
		adc log_value + $1
		plp 
		bcc l095D
		adc #$06
; jumped to by: log_multiply
l095D:
		sta log_value + $1
		rts 

; called by: log_divide
log_negate:
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
; jumped to by: log_negate
l0972:
		tax 
		pla 
		rts 

; log_value = A:X - log_value
; called by: project, rotate_45
log_divide_into:
		sec 
		sbc log_value
		sta log_value
		php 
		txa 
		sbc log_value + $1
		plp 
		bcs l0983
		sbc #$06
; jumped to by: log_divide_into
l0983:
		sta log_value + $1
		rts 

; read by: to_log
log_table:
		.byte	$00, $00, $20, $33, $40, $4a, $53, $5a, $60, $65, $6a, $6f, $73, $76, $7a, $7d
		.byte	$80, $83, $85, $88, $8a, $8d, $8f, $91, $93, $95, $96, $98, $9a, $9b, $9d, $9f
		.byte	$a0, $a1, $a3, $a4, $a5, $a7, $a8, $a9, $aa, $ab, $ad, $ae, $af, $b0, $b1, $b2
		.byte	$b3, $b4, $b5, $b6, $b6, $b7, $b8, $b9, $ba, $bb, $bb, $bc, $bd, $be, $bf, $bf
		.byte	$c0, $c1, $c1, $c2, $c3, $c3, $c4, $c5, $c5, $c6, $c7, $c7, $c8, $c9, $c9, $ca
		.byte	$ca, $cb, $cb, $cc, $cd, $cd, $ce, $ce, $cf, $cf, $d0, $d0, $d1, $d1, $d2, $d2
		.byte	$d3, $d3, $d4, $d4, $d5, $d5, $d6, $d6, $d6, $d7, $d7, $d8, $d8, $d9, $d9, $d9
		.byte	$da, $da, $db, $db, $db, $dc, $dc, $dd, $dd, $dd, $de, $de, $df, $df, $df, $e0
		.byte	$e0, $e0, $e1, $e1, $e1, $e2, $e2, $e2, $e3, $e3, $e3, $e4, $e4, $e4, $e5, $e5
		.byte	$e5, $e6, $e6, $e6, $e7, $e7, $e7, $e8, $e8, $e8, $e9, $e9, $e9, $e9, $ea, $ea
		.byte	$ea, $eb, $eb, $eb, $eb, $ec, $ec, $ec, $ed, $ed, $ed, $ed, $ee, $ee, $ee, $ee
		.byte	$ef, $ef, $ef, $ef, $f0, $f0, $f0, $f1, $f1, $f1, $f1, $f2, $f2, $f2, $f2, $f2
		.byte	$f3, $f3, $f3, $f3, $f4, $f4, $f4, $f4, $f5, $f5, $f5, $f5, $f6, $f6, $f6, $f6
		.byte	$f6, $f7, $f7, $f7, $f7, $f8, $f8, $f8, $f8, $f8, $f9, $f9, $f9, $f9, $f9, $fa
		.byte	$fa, $fa, $fa, $fa, $fb, $fb, $fb, $fb, $fb, $fc, $fc, $fc, $fc, $fc, $fd, $fd
		.byte	$fd, $fd, $fd, $fe, $fe, $fe, $fe, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
; read by: from_log
exp_table:
		.byte	$10, $10, $11, $11, $11, $12, $12, $13, $13, $13, $14, $14, $15, $15, $16, $16
		.byte	$17, $17, $18, $18, $19, $19, $1a, $1a, $1b, $1b, $1c, $1d, $1d, $1e, $1f, $1f
		.byte	$20, $21, $21, $22, $23, $24, $24, $25, $26, $27, $28, $29, $29, $2a, $2b, $2c
		.byte	$2d, $2e, $2f, $30, $31, $32, $34, $35, $36, $37, $38, $39, $3b, $3c, $3d, $3f
		.byte	$40, $41, $43, $44, $46, $47, $49, $4a, $4c, $4e, $4f, $51, $53, $55, $57, $59
		.byte	$5b, $5c, $5f, $61, $63, $65, $67, $69, $6c, $6e, $70, $73, $75, $78, $7b, $7d
		.byte	$80, $83, $86, $89, $8c, $8f, $92, $95, $98, $9c, $9f, $a2, $a6, $aa, $ad, $b1
		.byte	$b5, $b9, $bd, $c1, $c5, $ca, $ce, $d3, $d7, $dc, $e1, $e6, $eb, $f0, $f5, $fb

; projects view_x/view_y to proj_x/proj_y: x scaled by 1/depth around the middle, y = scale/depth
; called by: collect_objects, clip_edge, project_vertex, $b724
; jumped to by: l3D9F
project:
		lda view_y + $1
		ldx view_y
		jsr to_log
		sta log_value
		stx log_value + $1
		sta math_words + $c
		stx math_words + $d
		lda math_words + $6
		ldx math_words + $7
		jsr log_divide_into
		lda log_value
		ldx log_value + $1
		jsr from_log
		sta proj_y + $1
		stx proj_y
		lda view_x + $1
		php 
		bpl l0B46
		lda #$00
		sec 
		sbc view_x
		sta view_x
		lda #$00
		sbc view_x + $1
		sta view_x + $1
; jumped to by: project
l0B46:
		ldx view_x
		jsr to_log
		sta log_value
		stx log_value + $1
		lda math_words + $4
		ldx math_words + $5
		jsr log_multiply
		lda math_words + $c
		ldx math_words + $d
		jsr log_divide
		lda log_value
		ldx log_value + $1
		jsr from_log
		sta proj_x + $1
		stx proj_x
		lda #$80
		plp 
		bmi l0B85
		clc 
		adc proj_x
		sta proj_x
		lda proj_x + $1
		adc #$00
		sta proj_x + $1
		bcc l0B94
; jumped to by: project
l0B85:
		sec 
		sbc proj_x
		sta proj_x
		lda #$00
		sbc proj_x + $1
		sta proj_x + $1
; jumped to by: project
l0B94:
		rts 

; called by: main
l0B95:
		rts 

; log-domain constants: +0 is 1/sqrt(2), +4 and +6 the projection scales, +$a the
; current shape scale, +$c the log of the depth being projected
; read by: project, rotate_45, scale_step
; written by: project, draw_objects, l3E04
math_words:
		.word	$0010, $00f0, $00d0, $00f0, $0065, $fd00, $0000

; makes point_x/point_y relative to the ball and turns it to the view, or culls it when it's
; outside the view's octants
; called by: collect_objects, l28E9, clip_edge, project_vertex, l3711, draw_flag, $b71d
to_view:
		lda #$00
		sta octant
		lda point_y
		sec 
		sbc ball_y
		sta point_y
		lda point_y + $1
		sbc ball_y + $1
		sta point_y + $1
		asl 
		rol octant
		lda point_y
		ldx point_y + $1
		bpl l0BC3
		clc 
		eor #$ff
		adc #$01
; jumped to by: to_view
l0BC3:
		sta v21
		lda point_x
		sec 
		sbc ball_x
		sta point_x
		lda point_x + $1
		sbc ball_x + $1
		sta point_x + $1
		asl 
		rol octant
		lda point_x
		ldx point_x + $1
		bpl l0BE0
		clc 
		eor #$ff
		adc #$01
; jumped to by: to_view
l0BE0:
		cmp v21
		rol octant
		ora v21
		bmi l0BFC
		ldx octant
		lda direction_order, x
		sec 
		sbc direction
		beq l0BF9
		and #$07
		cmp #$07
		bne l0BFC
; jumped to by: to_view
; written by: set_direction
l0BF9:
		jmp rotate_1

; jumped to by: to_view
l0BFC:
		lda #$ff
		cmp direction_flag
		beq l0BF9
		sta view_y + $1
		rts 

; read by: to_view, $b714
; written by: l28E9, clip_edge, project_vertex, $b71a, $b721
direction_flag:
		.byte	$00
; read by: to_view
direction_order:
		.byte	$00, $01, $07, $06, $03, $02, $04, $05

rotate_0:
		lda #$00
		sec 
		sbc point_x
		sta point_x
		lda #$00
		sbc point_x + $1
		sta point_x + $1
		lda #$00
		sec 
		sbc point_y
		sta point_y
		lda #$00
		sbc point_y + $1
		sta point_y + $1
; jumped to by: to_view
rotate_1:
		lda point_x
		sta view_x
		lda point_x + $1
		sta view_x + $1
		lda point_y
		sta view_y
		lda point_y + $1
		sta view_y + $1
		rts 

rotate_2:
		lda point_y
		sta view_x
		lda point_y + $1
		sta view_x + $1
		lda #$00
		sec 
		sbc point_x
		sta view_y
		lda #$00
		sbc point_x + $1
		sta view_y + $1
		rts 

rotate_3:
		lda point_x
		sta view_y
		lda point_x + $1
		sta view_y + $1
		lda #$00
		sec 
		sbc point_y
		sta view_x
		lda #$00
		sbc point_y + $1
		sta view_x + $1
		rts 

; turns 45 degrees with (x-y)/sqrt(2), (x+y)/sqrt(2), then the 90-degree turn
; reached through the jmp at $0bf9, which $0d91 points here; it then jumps on to
; the rotation $0d91 stores in the jmp at $0d01
rotate_45:
		lda math_words
		sta log_value
		lda math_words + $1
		sta log_value + $1
		lda point_x
		clc 
		adc point_y
		tax 
		lda point_x + $1
		adc point_y + $1
		php 
		bpl l0C97
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
; jumped to by: rotate_45
l0C97:
		jsr to_log
		jsr log_divide_into
		lda log_value
		ldx log_value + $1
		jsr from_log
		plp 
		bpl l0CB4
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
; jumped to by: rotate_45
l0CB4:
		sta view_y + $1
		stx view_y
		lda math_words
		sta log_value
		lda math_words + $1
		sta log_value + $1
		lda point_x
		sec 
		sbc point_y
		tax 
		lda point_x + $1
		sbc point_y + $1
		php 
		bpl l0CDE
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
; jumped to by: rotate_45
l0CDE:
		jsr to_log
		jsr log_divide_into
		lda log_value
		ldx log_value + $1
		jsr from_log
		plp 
		bpl l0CFB
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
; jumped to by: rotate_45
l0CFB:
		sta view_x + $1
		stx view_x
		jmp rotate_7
; written by: set_direction
rotate_45_next = $0d02

rotate_4:
		lda #$00
		sec 
		sbc view_x
		sta view_x
		lda #$00
		sbc view_x + $1
		sta view_x + $1
		lda #$00
		sec 
		sbc view_y
		sta view_y
		lda #$00
		sbc view_y + $1
		sta view_y + $1
rotate_5:
		rts 

rotate_6:
		lda view_y
		sta point_y
		lda view_y + $1
		sta point_y + $1
		lda view_x
		sta view_y
		lda view_x + $1
		sta view_y + $1
		lda #$00
		sec 
		sbc point_y
		sta view_x
		lda #$00
		sbc point_y + $1
		sta view_x + $1
		rts 

; jumped to by: rotate_45
rotate_7:
		lda view_x
		sta point_y
		lda view_x + $1
		sta point_y + $1
		lda view_y
		sta view_x
		lda view_y + $1
		sta view_x + $1
		lda #$00
		sec 
		sbc point_y
		sta view_y
		lda #$00
		sbc point_y + $1
		sta view_y + $1
		rts 

; called by: turn_right, lA967
direction_down:
		lda direction
		sec 
		sbc #$01
; jumped to by: direction_up, face_hole
set_direction:
		and #$07
		sta direction
		asl 
		tax 
		and #$02
		bne l0D91
		lda rotations, x
		sta l0BF9 + 1
		lda rotations + $1, x
		sta l0BF9 + 2
		rts 

; jumped to by: set_direction
l0D91:
		lda #$73
		sta l0BF9 + 1
		lda #$0c
		sta l0BF9 + 2
		lda rotations, x
		sta rotate_45_next
		lda rotations + $1, x
		sta $0d03
		rts 

; read by: set_direction
rotations:
		.addr	rotate_1, rotate_5, rotate_3, rotate_6, rotate_0, rotate_4, rotate_2, rotate_7

; read by: to_view, direction_down, direction_up, draw_view, l36E6, l3AC7, lA99D, compute_drift
; written by: set_direction
direction:
		.byte	$00

; called by: turn_left, l3AB8, lA967
; jumped to by: l3AB8, lA967
direction_up:
		lda direction
		clc 
		adc #$01
		bpl set_direction
; jumped to by: print_char
draw_char:
		pha 
		jsr l0DC7
		pla 
		rts 

; called by: draw_char
l0DC7:
		and #$7f
		cmp #$20
		bcs l0DD0
		jmp l0E4B

; jumped to by: l0DC7
l0DD0:
		sec 
		sbc #$20
		sta pointer_04
		lda #$00
		asl pointer_04
		rol 
		asl pointer_04
		rol 
		asl pointer_04
		rol 
		sta pointer_04 + $1
		lda pointer_04
		clc 
		adc font_pointer
		sta pointer_04
		lda pointer_04 + $1
		adc font_pointer + $1
		sta pointer_04 + $1
		lda text_x
		cmp #$a0
		bcc l0E08
		lda pointer_04 + $1
		pha 
		lda pointer_04
		pha 
		jsr l0E4F
		pla 
		sta pointer_04
		pla 
		sta pointer_04 + $1
		lda text_x
; jumped to by: l0DC7
l0E08:
		ldx text_y
		jsr pixel_address
		tya 
		clc 
		adc bitmap_pointer
		sta bitmap_pointer
		lda bitmap_pointer + $1
		adc #$00
		sta bitmap_pointer + $1
		ldy #$00
; jumped to by: l0DC7
l0E1B:
		lda (pointer_04), y
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
		adc bitmap_pointer
		sta bitmap_pointer
		lda bitmap_pointer + $1
		adc #$00
		sta bitmap_pointer + $1
		ldy #$00
; jumped to by: l0DC7
l0E37:
		lda (pointer_04), y
		and #$0f
		jsr l0EC7
		iny 
		cpy #$08
		bcc l0E37
		lda text_x
		clc 
		adc #$08
		sta text_x
; jumped to by: l0E4F
l0E4A:
		rts 

; jumped to by: l0DC7
l0E4B:
		cmp #$0d
		bne l0E65
; called by: l0DC7
l0E4F:
		lda #$00
		sta text_x
; jumped to by: l0E4F
l0E53:
		lda text_y
		sec 
		sbc #$08
		bcs l0E60
		jsr scroll_text
		jmp l0E4A

; jumped to by: l0E4F
l0E60:
		sta text_y
		jmp l0E4A

; jumped to by: l0DC7
l0E65:
		cmp #$0a
		beq l0E53
		cmp #$0c
		bne l0E78
		jsr clear_bitmap
		lda #$00
		sta text_x
		lda #$c7
		sta text_y
; jumped to by: l0E4F
l0E78:
		rts 

; called by: l0E4F
scroll_text:
		lda #$ff
		sta pointer_04
		lda #$5f
		sta pointer_04 + $1
		lda #$3f
		sta bitmap_pointer
		lda #$61
		sta bitmap_pointer + $1
		ldx #$30
; jumped to by: scroll_text
l0E8B:
		ldy #$a0
; jumped to by: scroll_text
l0E8D:
		lda (bitmap_pointer), y
		sta (pointer_04), y
		dey 
		bne l0E8D
		lda #$a0
		clc 
		adc bitmap_pointer
		sta bitmap_pointer
		lda bitmap_pointer + $1
		adc #$00
		sta bitmap_pointer + $1
		lda #$a0
		clc 
		adc pointer_04
		sta pointer_04
		lda pointer_04 + $1
		adc #$00
		sta pointer_04 + $1
		dex 
		bne l0E8B
		lda #$00
		ldy #$a0
; jumped to by: scroll_text
l0EB5:
		sta bitmap + $1dff, y
		sta bitmap + $1e9f, y
		dey 
		bne l0EB5
		lda #$00
		sta text_x
		lda #$07
		sta text_y
		rts 

; called by: l0DC7
l0EC7:
		tax 
		lda double_bits, x
		pha 
		eor #$ff
		and (bitmap_pointer), y
		sta v0eed
		pla 
		and pixel_pattern
		ora v0eed
		sta (bitmap_pointer), y
		rts 

; read by: l0EC7
double_bits:
		.byte	$00, $03, $0c, $0f, $30, $33, $3c, $3f, $c0, $c3, $cc, $cf, $f0, $f3, $fc, $ff
; read by: l0EC7
; written by: l0EC7
v0eed:		.byte	$aa

; read by: l0DC7
font_pointer:
		.word	$7f4e

; read by: l18EF
; written by: flood_fill, l18EF
fill_stack:
		.byte	$98, $98, $76, $01, $88, $8a, $87, $01, $84, $85, $88, $01, $7f, $81, $89, $01
		.byte	$7d, $7e, $89, $01, $74, $76, $8b, $01, $70, $71, $8c, $01, $51, $52, $8d, $01
		.byte	$4b, $4d, $8d, $01, $6c, $6d, $8e, $01, $68, $6a, $8f, $01, $66, $67, $8f, $01
		.byte	$31, $32, $84, $01
unused_z80_junk:
		.byte	$41, $e1, $cd, $b2, $10, $20, $19, $3a, $de, $41, $b7, $20, $04, $78, $b1, $20
		.byte	$0f, $2a, $e3, $41, $23, $23, $7e, $fe, $08, $23, $30, $fa, $2b, $c3, $f8, $36
		.byte	$eb, $d5, $cd, $65, $3c, $b7, $28, $1d, $11, $28, $3f, $cd, $65, $3c, $b7, $fc
		.byte	$4c, $34, $cd, $de, $3c, $cd, $17, $36, $fe, $0d, $20, $ef, $e5, $2a, $e3, $41
		.byte	$e5, $c5, $c3, $22, $37, $0b, $62, $6b, $d1, $18, $bc, $cd, $03, $0f, $fe, $0d
		.byte	$ca, $9c, $04, $4f, $cd, $93, $4c, $cd, $6b, $0e, $fe, $0d, $28, $06, $cd, $93
		.byte	$4c, $b9, $20, $f3, $3e, $0d, $cd, $93, $4c, $3e, $0a, $cd, $93, $4c, $3a, $f1
		.byte	$3f, $fe, $20, $c0, $c3, $82, $0e, $cd, $03, $0f, $fe, $0d, $ca, $9c, $04, $32
		.byte	$e5, $41, $4f, $cd, $34, $0e, $fe, $0d, $28, $06, $b9, $ca, $82, $0e, $18, $f3
		.byte	$e1, $d1, $c1, $01, $99, $39, $c3, $98, $36, $c1, $01, $9a, $36, $c5, $21, $28
		.byte	$3f, $3a, $e5, $41, $4f, $7e, $b9, $28, $06, $fe, $0d, $c8, $23, $18, $f6, $c1
		.byte	$d1, $e1, $21, $bb, $02, $e5, $d5, $c5, $c9, $b7, $cd, $f7, $10, $23, $22, $ce
		.byte	$41, $7e, $f6, $28, $77, $cd, $86, $32, $22, $df, $41, $0e, $00, $c5, $cd

; called by: $c01f
; jumped to by: bank_in_io
l0FF3:
		jsr scnkey
		jsr getin
		beq l0FF3
; called by: l2C60, print_hex, print_club_name, l3A73, read_hex_digit, color_text, update_scores, draw_wind, read_hole_number
; jumped to by: print_nibble, print_club_name
; written by: bitmap_mode, text_mode
print_char:
		jmp draw_char

screen_off:
		lda #$ef
		and vic_control1
		sta vic_control1
		rts 

screen_on:
		lda #$10
		ora vic_control1
		sta vic_control1
		rts 

; called by: l0E4F
clear_bitmap:
		lda #$00
		sta pointer_06
		lda #$60
		sta pointer_06 + $1
		lda #$c0
		sta pointer_08
		lda #$e0
		sta pointer_08 + $1
		ldy #$00
; jumped to by: clear_bitmap
l1022:
		lda #$00
		sta (pointer_06), y
		iny 
		bne l102B
		inc pointer_06 + $1
; jumped to by: clear_bitmap
l102B:
		inc pointer_08
		bne l1022
		inc pointer_08 + $1
		bne l1022
		rts 

; called by: new_game
bitmap_mode:
		lda #$c1
		sta print_char + 1
		lda #$0d
		sta print_char + 2
		lda #$08
		ora vic_memory
		sta vic_memory
		lda #$20
		ora vic_control1
		sta vic_control1
		lda #$10
		ora vic_control2
		sta vic_control2
		rts 

; sets the char output vector to CHROUT and turns the bitmap off
text_mode:
		lda #$d2
		sta print_char + 1
		lda #$ff
		sta print_char + 2
		lda #$f7
		and vic_memory
		sta vic_memory
		lda #$df
		and vic_control1
		sta vic_control1
		lda #$ef
		and vic_control2
		sta vic_control2
		rts 

; written by: plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF
; modified by: plot_pixel, l1501, horizontal_line, vertical_line, draw_line
seed_countdown:
		.byte	$0a
; read by: plot_pixel, l1501, horizontal_line, vertical_line, draw_line
; written by: plot_pixel, l1501, horizontal_line, vertical_line, draw_line, draw_shape, draw_clipped_line, draw_polygon
; modified by: plot_pixel, l1501, horizontal_line, vertical_line, draw_line
seed_enable:		.byte	$ff
; read by: draw_shape, draw_polygon, $b81d
; written by: d129A, replot_seeds
fill_seeds:
		.byte	$41, $cd, $41, $86, $45, $88, $49, $8c, $4d, $8c, $51, $ff, $53, $8d, $5f, $8d
		.byte	$62, $8d, $65, $8e, $6a, $8e, $74, $8a, $78, $89, $82, $87, $8b, $ff, $8c, $84
		.byte	$90, $7e, $96, $77, $98, $75, $32, $99, $2d, $96, $30, $94, $2f, $93, $29, $99
		.byte	$2a, $9b, $27, $9d, $26, $9f, $28, $a5, $2b, $a9, $28, $ad, $29, $af, $30, $b8
		.byte	$33, $b8, $10, $cd, $86, $32, $36, $00, $2b, $36, $01, $22, $e3, $41, $2b, $0e
		.byte	$00, $cd, $e0, $34, $47, $0c, $cd, $78, $0e, $cd, $03, $0f, $fe, $0d, $28, $14
		.byte	$fe, $3b, $28, $10, $fe, $2c, $28, $e9, $78, $fe, $20, $28, $e4, $fe, $09, $c4
		.byte	$c4, $04, $18, $dd, $e3, $23, $23, $5e, $23, $56, $eb, $cd, $7a, $3c, $e3, $b7
		.byte	$28, $0b, $b9, $28, $08, $38, $06, $36, $00, $2b, $0c, $18, $f5, $36, $00, $2b
		.byte	$cd, $b5, $32, $e1, $c1, $cd, $7a, $3c, $e5, $2a, $ee, $41, $e5, $c5, $4f, $06
		.byte	$00, $09, $22, $ee, $41, $c1, $2a, $e3, $41, $e5, $21, $bb, $02, $e5, $11, $0c
		.byte	$3b, $d5, $c5, $c9, $cd, $2e, $37, $e1, $22, $e3, $41, $e1, $22, $f0, $41, $e1
		.byte	$af, $32, $e8, $41, $cd, $65, $3c, $b7, $28, $20, $11, $28, $3f, $cd, $65, $3c
		.byte	$b7, $fc, $4c, $34, $cd, $de, $3c, $cd, $17, $36, $fe, $0d, $20, $ef, $e5, $2a
		.byte	$f0, $41, $e5, $2a, $e3, $41, $e5, $c3, $22, $37, $2a, $e3, $41, $23, $af, $32
		.byte	$de, $41, $c3, $fd, $36, $7d, $93, $5f, $7c, $9a, $57, $c9, $3a, $c4, $3f, $b7
; read by: replot_seeds, $b817, $b82a, $b832
; written by: d129A
seed_edges:
		.byte	$c2, $bf, $41, $87, $45, $89, $49, $8d, $4d, $8d, $51, $8d, $53, $8e, $5f, $8e
		.byte	$62, $8e, $65, $8f, $6a, $8f, $74, $8b, $78, $8a, $82, $88, $8b, $86, $8d, $84
		.byte	$91, $7e, $96, $78, $98, $76, $33, $99, $2e, $96, $30, $95, $2f, $92, $28, $99
		.byte	$29, $9b, $27, $9c, $25, $9f, $28, $a6, $2b, $a8, $27, $ad, $28, $af, $30, $b9
		.byte	$33, $b9, $3b, $71, $23, $70, $c9, $2a, $f5, $41, $19, $5e, $23, $56, $2b, $c9
		.byte	$2a, $f5, $41, $19, $23, $23, $5e, $23, $56, $2b, $c9, $2a, $f9, $41, $7d, $b4
		.byte	$28, $0c, $eb, $d5, $cd, $a8, $3b, $eb, $22, $f9, $41, $d1, $18, $2c, $2a, $f7
		.byte	$41, $11, $20, $00, $eb, $19, $22, $f7, $41, $d5, $eb, $2a, $01, $42, $cd, $b2
		.byte	$10, $d1, $da, $36, $3d, $2a, $d0, $41, $25, $3a, $d2, $41, $b7, $cd, $b2, $10
		.byte	$da, $36, $3d, $2a, $f5, $41, $eb, $cd, $4d, $3b, $d5, $cd, $9f, $3b, $eb, $2a
		.byte	$fd, $41, $eb, $7b, $e6, $e0, $5f, $7b, $b2, $20, $02, $d1, $d5, $73, $23, $72
		.byte	$23, $3e, $00, $77, $23, $77, $cd, $a8, $3b, $d1, $28, $05, $73, $23, $72, $18
		.byte	$05, $eb, $22, $fb, $41, $eb, $2a, $fb, $41, $d5, $eb, $cd, $9f, $3b, $d1, $73
		.byte	$23, $72, $7b, $f6, $04, $5f, $c9, $d5, $f5, $2a, $fd, $41, $eb, $7b, $e6, $1f
		.byte	$cc, $b3, $3b, $2a, $f5, $41, $19, $f1, $f5, $77, $7b, $e6, $1f, $fe, $1f, $28
		.byte	$01, $13, $cc, $54, $3c, $eb, $22, $fd, $41, $f1, $d1, $c9, $7b, $e6, $e0, $5f
; read by: add_fill_seed, d129A, replot_seeds, draw_shape, draw_polygon, $b824
; written by: d129A, draw_object, draw_shape, draw_polygon, lA901, draw_wind, lB396, $b646
seed_count:		.byte	$02

; every 10 pixels of an outline, remembers a point next to it to fill from
; called by: plot_pixel, l1501, horizontal_line, vertical_line, draw_line
add_fill_seed:
		tsx 
		lda d0103, x
		tay 
		ldx plot_y
		lda seed_count
		beq l12AC
		lda v17ad
		bne l12AC
		stx v12ed
		sty v12ec
		lda point_x
		cmp point_x + $1
		bcs l129E
; written by: horizontal_line, vertical_line, draw_line
d129A:
		dey 
		jmp l129F

; jumped to by: add_fill_seed
; written by: vertical_line, draw_line
l129E:
		dex 
; jumped to by: d129A
l129F:
		txa 
		pha 
		tya 
		pha 
		jsr test_pixel
		beq l12AD
; jumped to by: d129A
l12A8:
		pla 
		pla 
		lda #$ff
; jumped to by: add_fill_seed
l12AC:
		rts 

; jumped to by: d129A
l12AD:
		lda pixel_hit
		php 
		ldx #$00
		stx pixel_hit
		plp 
		bne l12A8
		dex 
		stx pixel_hit
		ldx seed_count
		pla 
		sta fill_seeds, x
		lda v12ec
		sta seed_edges, x
		inx 
		pla 
		sta fill_seeds, x
		lda v12ed
		sta seed_edges, x
		inx 
		stx seed_count
		lda v12ec
		ldx v12ed
		jsr pixel_address
		lda (bitmap_pointer), y
		and pixel_clear_masks, x
		sta (bitmap_pointer), y
		lda #$00
		rts 

; read by: d129A
; written by: add_fill_seed
v12ec:
		.byte	$98
; read by: d129A
; written by: add_fill_seed
v12ed:		.byte	$76
; written by: draw_object
v12ee:		.byte	$ff
; read by: d129A
; written by: d129A, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF
pixel_hit:		.byte	$ff

; called by: l0DC7, d129A
pixel_address:
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		rts 

; called by: d129A, l3C3F, read_aim_cursor, $b805
test_pixel:
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		and pixel_bits, x
		rts 

; jumped to by: vertical_line
plot_pixel:
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		sta pointer_06
		and pixel_bits, x
		bne l1354
		lda pixel_bits, x
		and pixel_pattern
		ora pointer_06
		sta (bitmap_pointer), y
		lda seed_enable
		beq l1357
		jsr add_fill_seed
		jmp l1357

; jumped to by: plot_pixel
l1354:
		sta pixel_hit
; jumped to by: plot_pixel
l1357:
		sta seed_enable
		dec seed_countdown
		bne l1367
		inc seed_enable
		lda #$0a
		sta seed_countdown
; jumped to by: plot_pixel
l1367:
		rts 

; read by: l0EC7, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF, replot_seeds, $b84b
; written by: draw_line, set_cell_color, color_text, print_score_labels, draw_flag, draw_wind, title_screen, $b641
pixel_pattern:
		.byte	$ff
; masks that clear one multicolor pixel, and its bits
; read by: d129A
pixel_clear_masks:
		.byte	$3f, $cf, $f3, $fc
; read by: test_pixel, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF, replot_seeds, $b848
pixel_bits:
		.byte	$c0, $30, $0c, $03
; bitmap row addresses, bottom row first
; read by: pixel_address, test_pixel, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF
bitmap_row_lo:
		.byte	$07, $06, $05, $04, $03, $02, $01, $00, $c7, $c6, $c5, $c4, $c3, $c2, $c1, $c0
		.byte	$87, $86, $85, $84, $83, $82, $81, $80, $47, $46, $45, $44, $43, $42, $41, $40
		.byte	$07, $06, $05, $04, $03, $02, $01, $00, $c7, $c6, $c5, $c4, $c3, $c2, $c1, $c0
		.byte	$87, $86, $85, $84, $83, $82, $81, $80, $47, $46, $45, $44, $43, $42, $41, $40
		.byte	$07, $06, $05, $04, $03, $02, $01, $00, $c7, $c6, $c5, $c4, $c3, $c2, $c1, $c0
		.byte	$87, $86, $85, $84, $83, $82, $81, $80, $47, $46, $45, $44, $43, $42, $41, $40
		.byte	$07, $06, $05, $04, $03, $02, $01, $00, $c7, $c6, $c5, $c4, $c3, $c2, $c1, $c0
		.byte	$87, $86, $85, $84, $83, $82, $81, $80, $47, $46, $45, $44, $43, $42, $41, $40
		.byte	$07, $06, $05, $04, $03, $02, $01, $00, $c7, $c6, $c5, $c4, $c3, $c2, $c1, $c0
		.byte	$87, $86, $85, $84, $83, $82, $81, $80, $47, $46, $45, $44, $43, $42, $41, $40
		.byte	$07, $06, $05, $04, $03, $02, $01, $00, $c7, $c6, $c5, $c4, $c3, $c2, $c1, $c0
		.byte	$87, $86, $85, $84, $83, $82, $81, $80, $47, $46, $45, $44, $43, $42, $41, $40
		.byte	$07, $06, $05, $04, $03, $02, $01, $00
; read by: pixel_address, test_pixel, plot_pixel, l1501, horizontal_line, vertical_line, draw_line, l18EF
bitmap_row_hi:
		.byte	$7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
		.byte	$7b, $7b, $7b, $7b, $7b, $7b, $7b, $7b, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7a
		.byte	$79, $79, $79, $79, $79, $79, $79, $79, $77, $77, $77, $77, $77, $77, $77, $77
		.byte	$76, $76, $76, $76, $76, $76, $76, $76, $75, $75, $75, $75, $75, $75, $75, $75
		.byte	$74, $74, $74, $74, $74, $74, $74, $74, $72, $72, $72, $72, $72, $72, $72, $72
		.byte	$71, $71, $71, $71, $71, $71, $71, $71, $70, $70, $70, $70, $70, $70, $70, $70
		.byte	$6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6d, $6d, $6d, $6d, $6d, $6d, $6d, $6d
		.byte	$6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
		.byte	$6a, $6a, $6a, $6a, $6a, $6a, $6a, $6a, $68, $68, $68, $68, $68, $68, $68, $68
		.byte	$67, $67, $67, $67, $67, $67, $67, $67, $66, $66, $66, $66, $66, $66, $66, $66
		.byte	$65, $65, $65, $65, $65, $65, $65, $65, $63, $63, $63, $63, $63, $63, $63, $63
		.byte	$62, $62, $62, $62, $62, $62, $62, $62, $61, $61, $61, $61, $61, $61, $61, $61
		.byte	$60, $60, $60, $60, $60, $60, $60, $60

; called by: draw_line
l1501:
		txa 
		pha 
		ldx plot_y
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		sta pointer_06
		and pixel_bits, x
		bne l1538
		lda pixel_bits, x
		and pixel_pattern
		ora pointer_06
		sta (bitmap_pointer), y
		lda seed_enable
		beq l153B
		jsr add_fill_seed
		jmp l153B

; jumped to by: l1501
l1538:
		sta pixel_hit
; jumped to by: l1501
l153B:
		sta seed_enable
		dec seed_countdown
		bne l154B
		inc seed_enable
		lda #$0a
		sta seed_countdown
; jumped to by: l1501
l154B:
		pla 
		tax 
		rts 

; jumped to by: draw_line
horizontal_line:
		lda #$ea
		sta d129A
		sty plot_y
		ldx line_x
		cpx point_y + $1
		bcc l1562
		lda #$ca
		sta l1567
		bne l1567
; jumped to by: horizontal_line
l1562:
		lda #$e8
		sta l1567
; jumped to by: horizontal_line
; written by: horizontal_line
l1567:
		dex 
		cpx #$a0
		bcs l15C1
		txa 
		pha 
		ldx plot_y
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		sta pointer_06
		and pixel_bits, x
		bne l15A3
		lda pixel_bits, x
		and pixel_pattern
		ora pointer_06
		sta (bitmap_pointer), y
		lda seed_enable
		beq l15A6
		jsr add_fill_seed
		jmp l15A6

; jumped to by: horizontal_line
l15A3:
		sta pixel_hit
; jumped to by: horizontal_line
l15A6:
		sta seed_enable
		dec seed_countdown
		bne l15B6
		inc seed_enable
		lda #$0a
		sta seed_countdown
; jumped to by: horizontal_line
l15B6:
		pla 
		tax 
		cpx point_y + $1
		bne l1567
		lda v17ac
		bne l1567
; jumped to by: horizontal_line
l15C1:
		lda #$00
		sta v17ac
		stx line_x
		rts 

; jumped to by: draw_line
vertical_line:
		lda #$ea
		sta l129E
		cpy line_y
		bne l15DF
		txa 
		pha 
		lda #$00
		sta v17ac
		tya 
		tax 
		pla 
		jmp plot_pixel

; jumped to by: vertical_line
l15DF:
		bcc l15EB
		lda #$c8
		sta d129A
		sta l15F5
		bne l15F3
; jumped to by: vertical_line
l15EB:
		lda #$88
		sta d129A
		sta l15F5
; jumped to by: vertical_line
l15F3:
		ldy line_y
; jumped to by: vertical_line
; written by: vertical_line
l15F5:
		dey 
		cpy clip_top
		bcc l1657
		cpy clip_bottom
		bcs l1657
		sty plot_y
		txa 
		pha 
		ldx plot_y
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		sta pointer_06
		and pixel_bits, x
		bne l1637
		lda pixel_bits, x
		and pixel_pattern
		ora pointer_06
		sta (bitmap_pointer), y
		lda seed_enable
		beq l163A
		jsr add_fill_seed
		jmp l163A

; jumped to by: vertical_line
l1637:
		sta pixel_hit
; jumped to by: vertical_line
l163A:
		sta seed_enable
		dec seed_countdown
		bne l164A
		inc seed_enable
		lda #$0a
		sta seed_countdown
; jumped to by: vertical_line
l164A:
		pla 
		tax 
		ldy plot_y
		cpy point_y
		bne l15F5
		lda v17ac
		bne l15F5
; jumped to by: vertical_line
l1657:
		lda #$00
		sta v17ac
		sty line_y
		rts 

; draws a line from line_x/line_y to X/Y
; called by: draw_clipped_line, lA901, draw_flag, draw_wind, lB396, $b651, $b65a
; jumped to by: lB396
draw_line:
		stx point_y + $1
		lda #$ff
		sta pixel_pattern
		sty point_y
		txa 
		pha 
		tya 
		pha 
		ldx line_x
		ldy line_y
		sty plot_y
		lda seed_enable
		pha 
		lda #$00
		sta seed_enable
		jsr l1501
		pla 
		sta seed_enable
		pla 
		tay 
		pla 
		tax 
		lda #$ff
		sta log_value + $1
		txa 
		sec 
		sbc line_x
		bne l1693
		jmp vertical_line

; jumped to by: draw_line
l1693:
		bcs l1698
		jmp l176B

; jumped to by: draw_line
l1698:
		ldx #$ca
		stx l129E
		ldx #$e8
		stx l16EC
; jumped to by: draw_line
l16A2:
		sta point_x
		tya 
		sec 
		sbc line_y
		bne l16AD
		jmp horizontal_line

; jumped to by: draw_line
l16AD:
		bcs l16B2
		jmp l1785

; jumped to by: draw_line
l16B2:
		ldy #$c8
		sty d129A
		sty l16FA
; jumped to by: draw_line
l16BA:
		sta point_x + $1
		ora point_x
		bmi l16CA
; jumped to by: draw_line
l16C0:
		asl point_x
		asl point_x + $1
		lda point_x
		ora point_x + $1
		bpl l16C0
; jumped to by: draw_line
l16CA:
		ldx line_x
		ldy line_y
		sty plot_y
		lda point_x
		sta $16e5
		ldy point_x + $1
		sty $17a1
		sty $16f5
		ldy plot_y
		lda #$80
		pha 
; jumped to by: draw_line
l16E2:
		pla 
		clc 
		adc #$c0
		pha 
		bcs l16EC
		jmp l179D

; jumped to by: draw_line
; written by: draw_line
l16EC:
		inx 
		cpx #$a0
		bcs l1760
		lda log_value + $1
		clc 
		adc #$a0
		sta log_value + $1
		bcc l1703
; jumped to by: draw_line
; written by: draw_line
l16FA:
		dey 
		cpy clip_top
		bcc l1760
		cpy clip_bottom
		bcs l1760
; jumped to by: draw_line
l1703:
		sty plot_y
		txa 
		pha 
		ldx plot_y
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		sta pointer_06
		and pixel_bits, x
		bne l173C
		lda pixel_bits, x
		and pixel_pattern
		ora pointer_06
		sta (bitmap_pointer), y
		lda seed_enable
		beq l173F
		jsr add_fill_seed
		jmp l173F

; jumped to by: draw_line
l173C:
		sta pixel_hit
; jumped to by: draw_line
l173F:
		sta seed_enable
		dec seed_countdown
		bne l174F
		inc seed_enable
		lda #$0a
		sta seed_countdown
; jumped to by: draw_line
l174F:
		pla 
		tax 
		ldy plot_y
		cpx point_y + $1
		bne l16E2
		cpy point_y
		bne l16E2
		lda v17ac
		bne l16E2
; jumped to by: draw_line
l1760:
		lda #$00
		sta v17ac
		stx line_x
		sty line_y
		pla 
		rts 

; jumped to by: draw_line
l176B:
		pha 
		lda log_value + $1
		eor #$ff
		sta log_value + $1
		pla 
		ldx #$e8
		stx l129E
		clc 
		eor #$ff
		adc #$01
		ldx #$ca
		stx l16EC
		jmp l16A2

; jumped to by: draw_line
l1785:
		pha 
		lda log_value + $1
		eor #$ff
		sta log_value + $1
		pla 
		clc 
		eor #$ff
		adc #$01
		ldx #$88
		stx d129A
		stx l16FA
		jmp l16BA

; jumped to by: draw_line
l179D:
		lda log_value + $1
		clc 
		adc #$a0
		sta log_value + $1
		bcs l17A9
		jmp l16E2

; jumped to by: draw_line
l17A9:
		jmp l16FA

; read by: horizontal_line, vertical_line, draw_line
; written by: horizontal_line, vertical_line, draw_line, draw_clipped_line
v17ac:
		.byte	$00
; read by: add_fill_seed
; written by: draw_clipped_line
v17ad:		.byte	$00

; colors the screen cell under a filled pixel, and keeps the nearest depth in cell_depths
; called by: l18EF
set_cell_color:
		tya 
		pha 
		ldy plot_y
		lda object_depth
		cmp (pointer_64), y
		bcs l17BA
		sta (pointer_64), y
; jumped to by: set_cell_color
l17BA:
		lda (pointer_08), y
		and #$0f
		cmp #$0f
		beq l17C9
		cmp fill_color
		beq l17CE
		bne l17D6
; jumped to by: set_cell_color
l17C9:
		lda fill_color
		sta (pointer_08), y
; jumped to by: set_cell_color
l17CE:
		lda #$aa
		sta pixel_pattern
		pla 
		tay 
		rts 

; jumped to by: set_cell_color
l17D6:
		ora fill_color_high
		sta (pointer_08), y
		lda #$55
		sta pixel_pattern
		pla 
		tay 
		rts 

; screen row addresses, bottom row first, each repeated for 4 pixel rows
; read by: l18EF, l3CB7
screen_rows:
		.word	$47c0, $47c0, $47c0, $47c0, $4798, $4798, $4798, $4798, $4770, $4770, $4770, $4770, $4748, $4748, $4748, $4748
		.word	$4720, $4720, $4720, $4720, $46f8, $46f8, $46f8, $46f8, $46d0, $46d0, $46d0, $46d0, $46a8, $46a8, $46a8, $46a8
		.word	$4680, $4680, $4680, $4680, $4658, $4658, $4658, $4658, $4630, $4630, $4630, $4630, $4608, $4608, $4608, $4608
		.word	$45e0, $45e0, $45e0, $45e0, $45b8, $45b8, $45b8, $45b8, $4590, $4590, $4590, $4590, $4568, $4568, $4568, $4568
		.word	$4540, $4540, $4540, $4540, $4518, $4518, $4518, $4518, $44f0, $44f0, $44f0, $44f0, $44c8, $44c8, $44c8, $44c8
		.word	$44a0, $44a0, $44a0, $44a0, $4478, $4478, $4478, $4478, $4450, $4450, $4450, $4450, $4428, $4428, $4428, $4428
		.word	$4400, $4400, $4400, $4400

; fills the area around X/Y with color A, scanline by scanline through fill_stack
; called by: draw_shape, draw_polygon
flood_fill:
		cpy #$c8
		bcc l18B0
		rts 

; jumped to by: flood_fill
l18B0:
		sta fill_color
		asl 
		asl 
		asl 
		asl 
		sta fill_color_high
		stx log_value
		stx point_x
		sty v0d
		txa 
		ldx v0d
		jsr l18EF
		beq l18C9
		rts 

; jumped to by: flood_fill
l18C9:
		ldx point_x
		ldy v0d
		lda #$ff
		sta point_y
		ldy #$00
		txa 
		sta fill_stack, y
		iny 
		sta fill_stack, y
		iny 
		lda v0d
		clc 
		adc #$01
		sta fill_stack, y
		iny 
		lda #$01
		sta fill_stack, y
		iny 
		sty point_y + $1
		bne l1929
; called by: flood_fill
l18EF:
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		and pixel_bits, x
		rts 

; jumped to by: l18EF
l190A:
		ldy point_y + $1
		bne l190F
		rts 

; jumped to by: l18EF
l190F:
		dey 
		lda fill_stack, y
		sta point_y
		dey 
		lda fill_stack, y
		sta v0d
		dey 
		lda fill_stack, y
		sta point_x
		dey 
		lda fill_stack, y
		sta log_value
		sty point_y + $1
; jumped to by: flood_fill, l18EF
l1929:
		lda log_value
		clc 
		adc point_x
		ror 
		cmp #$a0
		bcs l190A
		sta v0c
		sta pointer_06
		ldx v0d
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		lda (bitmap_pointer), y
		and pixel_bits, x
		beq l19A7
		lda point_x
		cmp v0c
		beq l1994
		sbc #$01
		cmp v0c
		beq l1994
		ldx v0c
		ldy point_y + $1
		txa 
		adc #$00
		sta fill_stack, y
		iny 
		lda point_x
		sta fill_stack, y
		iny 
		lda v0d
		sta fill_stack, y
		iny 
		lda point_y
		sta fill_stack, y
		iny 
		sty point_y + $1
		bne l1989
		lda point_y + $1
		sec 
		sbc #$04
		sta point_y + $1
; jumped to by: l18EF
l1989:
		stx point_x
		cpx log_value
		bne l1992
		jmp l190A

; jumped to by: l18EF
l1992:
		bne l1929
; jumped to by: l18EF
l1994:
		lda log_value
		sta point_x
		ldx v0d
		jsr l18EF
		bne l19A2
		jmp l1929

; jumped to by: l18EF
l19A2:
		beq l19A7
		jmp l190A

; jumped to by: l18EF
l19A7:
		tya 
		pha 
		lda v0d
		and #$fe
		tay 
		lda screen_rows, y
		sta pointer_08
		lda screen_rows + $1, y
		sta pointer_08 + $1
		lda pointer_08
		sta pointer_64
		lda pointer_08 + $1
		clc 
		adc #$87
		sta pointer_64 + $1
		lda v0c
		lsr 
		lsr 
		sta plot_y
		pla 
		tay 
		jsr set_cell_color
; jumped to by: l18EF
l19CE:
		lda (bitmap_pointer), y
; jumped to by: l18EF
l19D0:
		and pixel_bits, x
		bne l1A1F
		lda pixel_bits, x
		and pixel_pattern
		ora (bitmap_pointer), y
		sta (bitmap_pointer), y
		dex 
		dec pointer_06
		lda pointer_06
		cmp #$ff
		beq l1A1F
		cpx #$ff
		bne l19CE
; jumped to by: l18EF
l19EC:
		lda #$08
		clc 
		eor #$ff
		adc #$01
		clc 
		adc bitmap_pointer
		sta bitmap_pointer
		lda bitmap_pointer + $1
		sbc #$00
		sta bitmap_pointer + $1
		ldx #$03
		lda (bitmap_pointer), y
		and #$03
		bne l1A1F
		dec plot_y
		jsr set_cell_color
		lda (bitmap_pointer), y
		bne l19D0
		lda pixel_pattern
		sta (bitmap_pointer), y
		lda pointer_06
		sec 
		sbc #$04
		sta pointer_06
		bcs l19EC
		bcc l1A1F
; jumped to by: l18EF
l1A1F:
		inc pointer_06
		lda log_value
		sta log_value + $1
		ldx pointer_06
		stx log_value
		tya 
		pha 
		lda v0d
		and #$fe
		tay 
		lda screen_rows, y
		sta pointer_08
		lda screen_rows + $1, y
		sta pointer_08 + $1
		lda pointer_08
		sta pointer_64
		lda pointer_08 + $1
		clc 
		adc #$87
		sta pointer_64 + $1
		lda v0c
		lsr 
		lsr 
		sta plot_y
		pla 
		tay 
		jsr set_cell_color
		lda v0c
		sta pointer_06
		ldx v0d
		pha 
		and #$fc
		asl 
		tay 
		lda bitmap_row_lo, x
		sta bitmap_pointer
		lda bitmap_row_hi, x
		adc #$00
		sta bitmap_pointer + $1
		pla 
		and #$03
		tax 
		bcc l1A7E
; jumped to by: l18EF
l1A6D:
		lda (bitmap_pointer), y
; jumped to by: l18EF
l1A6F:
		and pixel_bits, x
		bne l1AB9
		lda pixel_bits, x
		and pixel_pattern
		ora (bitmap_pointer), y
		sta (bitmap_pointer), y
; jumped to by: l18EF
l1A7E:
		inx 
		inc pointer_06
		lda pointer_06
		cmp #$a0
		bcs l1AB9
		cpx #$04
		bne l1A6D
; jumped to by: l18EF
l1A8B:
		lda #$08
		clc 
		adc bitmap_pointer
		sta bitmap_pointer
		lda bitmap_pointer + $1
		adc #$00
		sta bitmap_pointer + $1
		ldx #$00
		lda (bitmap_pointer), y
		and #$c0
		bne l1AB9
		inc plot_y
		jsr set_cell_color
		lda (bitmap_pointer), y
		bne l1A6F
		lda pixel_pattern
		sta (bitmap_pointer), y
		lda pointer_06
		clc 
		adc #$04
		sta pointer_06
		cmp #$a0
		bcc l1A8B
; jumped to by: l18EF
l1AB9:
		dec pointer_06
		lda point_x
		sta point_x + $1
		ldx pointer_06
		stx point_x
		cpx log_value
		bcs l1ACA
		jmp l1BE3

; jumped to by: l18EF
l1ACA:
		lda log_value
		sec 
		sbc log_value + $1
		bcs l1B04
		cmp #$fe
		bcs l1B2D
		ldy point_y + $1
		lda log_value
		sta fill_stack, y
		iny 
		lda log_value + $1
		sta fill_stack, y
		iny 
		lda v0d
		sec 
		sbc point_y
		sta fill_stack, y
		iny 
		lda point_y
		clc 
		eor #$ff
		adc #$01
		sta fill_stack, y
		iny 
		sty point_y + $1
		bne l1B2D
		lda point_y + $1
		sec 
		sbc #$04
		sta point_y + $1
		bne l1B2D
; jumped to by: l18EF
l1B04:
		cmp #$03
		bcc l1B2D
		ldy point_y + $1
		lda log_value + $1
		sta fill_stack, y
		iny 
		lda log_value
		sta fill_stack, y
		iny 
		lda v0d
		sta fill_stack, y
		iny 
		lda point_y
		sta fill_stack, y
		iny 
		sty point_y + $1
		bne l1B2D
		lda point_y + $1
		sec 
		sbc #$04
		sta point_y + $1
; jumped to by: l18EF
l1B2D:
		lda point_x
		sec 
		sbc point_x + $1
		bcs l1B5F
		cmp #$fe
		bcs l1B90
		ldy point_y + $1
		lda point_x
		sta fill_stack, y
		iny 
		lda point_x + $1
		sta fill_stack, y
		iny 
		lda v0d
		sta fill_stack, y
		iny 
		lda point_y
		sta fill_stack, y
		iny 
		sty point_y + $1
		bne l1B90
		lda point_y + $1
		sec 
		sbc #$04
		sta point_y + $1
		bne l1B90
; jumped to by: l18EF
l1B5F:
		cmp #$03
		bcc l1B90
		ldy point_y + $1
		lda point_x + $1
		sta fill_stack, y
		iny 
		lda point_x
		sta fill_stack, y
		iny 
		lda v0d
		sec 
		sbc point_y
		sta fill_stack, y
		iny 
		lda point_y
		clc 
		eor #$ff
		adc #$01
		sta fill_stack, y
		iny 
		sty point_y + $1
		bne l1B90
		lda point_y + $1
		sec 
		sbc #$04
		sta point_y + $1
; jumped to by: l18EF
l1B90:
		ldy point_y + $1
		beq l1BA1
		dey 
		dey 
		dey 
		lda #$ff
		sta pixel_hit
		lda #$0a
		sta seed_countdown
; jumped to by: l18EF
l1BA1:
		lda v0d
		clc 
		adc point_y
		sta v0d
		cmp clip_bottom
		bcc l1BAF
		jmp l190A

; jumped to by: l18EF
l1BAF:
		jmp l1929

; read by: set_cell_color
; written by: flood_fill
fill_color:
		.byte	$0d
; read by: set_cell_color
; written by: flood_fill
fill_color_high:		.byte	$d0

; called by: draw_shape, draw_polygon
replot_seeds:
		ldy #$02
; jumped to by: replot_seeds
l1BB6:
		cpy seed_count
		beq l1BE2
		lda seed_edges, y
		iny 
		ldx seed_edges, y
		sty plot_y
		jsr lA026
		bne l1BD5
		lda pixel_bits, x
		and pixel_pattern
		ora (bitmap_pointer), y
		sta (bitmap_pointer), y
		bne l1BDC
; jumped to by: replot_seeds
l1BD5:
		lda #$ff
		ldy plot_y
		sta fill_seeds, y
; jumped to by: replot_seeds
l1BDC:
		ldy plot_y
		iny 
		jmp l1BB6

; jumped to by: replot_seeds
l1BE2:
		rts 

; jumped to by: l18EF, replot_seeds
l1BE3:
		jmp l1BE3

; called by: draw_objects
draw_object:
		lda proj_y
		sta object_depth
		lda #$02
		sta seed_count
		lda #$ff
		sta v12ee
		jsr lA020
		jmp l1D13

unused_1bfb:
		.byte	$ea

; draws a list of polygons from pointer_04, scaled by math_words+$a, each outlined and filled
; jumped to by: lB78E
draw_shape:
		ldy #$00
		sty seed_enable
		lda (pointer_04), y
		iny 
		jsr scale_x
		lda proj_x
		clc 
		adc pen_x
		sta pen_x
		lda proj_x + $1
		adc pen_x + $1
		sta pen_x + $1
		lda (pointer_04), y
		iny 
		jsr scale_y
		lda proj_y
		clc 
		adc pen_y
		sta pen_y
		lda proj_y + $1
		adc pen_y + $1
		sta pen_y + $1
		lda pen_x
		sta line_x
		lda pen_x + $1
		sta line_x + $1
		lda pen_x
		sta v1f18
		lda pen_x + $1
		sta v1f19
		lda pen_y
		sta line_y
		lda pen_y + $1
		sta line_y + $1
		lda pen_y
		sta v1f1e
		lda pen_y + $1
		sta v1f1f
; jumped to by: draw_shape
l1C5F:
		lda (pointer_04), y
		iny 
		cmp #$80
		beq l1CA0
		jsr scale_x
		lda proj_x
		clc 
		adc pen_x
		sta pen_x
		lda proj_x + $1
		adc pen_x + $1
		sta pen_x + $1
		lda (pointer_04), y
		iny 
		sty v1f16
		jsr scale_y
		lda proj_y
		clc 
		adc pen_y
		sta pen_y
		lda proj_y + $1
		adc pen_y + $1
		sta pen_y + $1
		jsr draw_clipped_line
		ldy v1f16
		bne l1C5F
; jumped to by: draw_shape
l1CA0:
		sty v1f16
		lda v1f18
		sta pen_x
		lda v1f19
		sta pen_x + $1
		lda v1f1e
		sta pen_y
		lda v1f1f
		sta pen_y + $1
		jsr draw_clipped_line
		ldy v1f16
		lda (pointer_04), y
		iny 
		sty v1f16
		pha 
		jsr replot_seeds
		lda proj_x
		sta pen_x
		lda proj_x + $1
		sta pen_x + $1
		lda proj_y
		sta pen_y
		lda proj_y + $1
		sta pen_y + $1
		jsr pen_on_screen
		bcs l1CF3
		ldx proj_x
		ldy proj_y
		pla 
		pha 
		jsr flood_fill
; jumped to by: draw_shape
l1CF3:
		ldx seed_count
		dex 
		cpx #$02
		bcc l1D0F
		lda fill_seeds, x
		tay 
		dex 
		lda fill_seeds, x
		stx seed_count
		tax 
		pla 
		pha 
		jsr flood_fill
		jmp l1CF3

; jumped to by: draw_shape
l1D0F:
		pla 
		ldy v1f16
; jumped to by: draw_object
l1D13:
		lda (pointer_04), y
		iny 
		cmp #$80
		bne l1D1B
		rts 

; jumped to by: draw_shape
l1D1B:
		jsr scale_x
		lda pen_x
		clc 
		adc proj_x
		sta proj_x
		lda pen_x + $1
		adc proj_x + $1
		sta proj_x + $1
		lda (pointer_04), y
		iny 
		jsr scale_y
		lda pen_y
		clc 
		adc proj_y
		sta proj_y
		lda pen_y + $1
		adc proj_y + $1
		sta proj_y + $1
		tya 
		clc 
		adc pointer_04
		sta pointer_04
		lda pointer_04 + $1
		adc #$00
		sta pointer_04 + $1
		jmp lA023

; called by: draw_shape
scale_x:
		stx v1f17
		sty v1f16
		ldx v1f14
		stx v1f15
		jsr scale_step
		sta pen_x + $1
		stx pen_x
		ldx v1f17
		ldy v1f16
		rts 

; called by: draw_shape
scale_y:
		stx v1f17
		sty v1f16
		ldy #$ff
		sty v1f15
		jsr scale_step
		stx pen_y
		sta pen_y + $1
		ldx v1f17
		ldy v1f16
		rts 

; called by: scale_x, scale_y, l3E04
scale_step:
		cmp #$80
		php 
		bcc l1D9A
		clc 
		eor #$ff
		adc #$01
; jumped to by: scale_step
l1D9A:
		tax 
		lda #$00
		jsr to_log
		sta log_value
		lda v1f15
		bne l1DA8
		dex 
; jumped to by: scale_step
l1DA8:
		stx log_value + $1
		lda math_words + $a
		ldx math_words + $b
		jsr log_multiply
		lda log_value
		ldx log_value + $1
		jsr from_log
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
; jumped to by: scale_step
l1DCA:
		rts 

unused_1dcb:
		.byte	$00, $00

; called by: draw_clipped_line, draw_polygon, $28c6
line_start_on_screen:
		lda line_x + $1
		ora line_y + $1
		bne l1DE2
		lda line_x
		cmp #$a0
		bcs l1DE2
		lda line_y
		cmp clip_top
		bcc l1DE2
		cmp clip_bottom
		rts 

; jumped to by: line_start_on_screen
l1DE2:
		sec 
		rts 

; called by: draw_shape, draw_clipped_line, clip_edge
pen_on_screen:
		lda pen_x + $1
		ora pen_y + $1
		bne l1DFD
		lda pen_x
		cmp #$a0
		bcs l1DFD
		lda pen_y
		cmp clip_top
		bcc l1DFD
		cmp clip_bottom
		rts 

; jumped to by: pen_on_screen
l1DFD:
		sec 
		rts 

; draws from line_x/line_y to pen_x/pen_y, finding the screen's edge by halving the line
; called by: draw_shape, draw_polygon, clip_edge
draw_clipped_line:
		lda pen_x + $1
		pha 
		lda pen_x
		pha 
		lda pen_y + $1
		pha 
		lda pen_y
		pha 
		lda #$00
		sta v17ad
		jsr line_start_on_screen
		bcc l1E1C
		jmp l1ED2

; jumped to by: draw_clipped_line
l1E1C:
		jsr pen_on_screen
		bcs l1E41
; jumped to by: draw_clipped_line
l1E21:
		ldx pen_x
		ldy pen_y
		jsr draw_line
; jumped to by: draw_clipped_line
l1E2A:
		lda #$ff
		sta seed_enable
		lda #$00
		sta v17ad
		pla 
		sta line_y
		pla 
		sta line_y + $1
		pla 
		sta line_x
		pla 
		sta line_x + $1
		rts 

; jumped to by: draw_clipped_line
l1E41:
		lda pen_x
		sta v1f1a
		lda pen_x + $1
		sta v1f1b
		lda pen_y
		sta v1f1c
		lda pen_y + $1
		sta v1f1d
		lda pen_x
		clc 
		adc line_x
		sta pen_x
		lda pen_x + $1
		adc line_x + $1
		asl 
		php 
		ror 
		plp 
		ror 
		sta pen_x + $1
		ror pen_x
		lda pen_y
		clc 
		adc line_y
		sta pen_y
		lda pen_y + $1
		adc line_y + $1
		asl 
		php 
		ror 
		plp 
		ror 
		sta pen_y + $1
		ror pen_y
		lda pen_x
		cmp v1f1a
		bne l1E99
		lda pen_x + $1
		cmp v1f1b
; jumped to by: draw_clipped_line
l1E99:
		bne l1EC2
		lda pen_y
		cmp v1f1c
		bne l1EA9
		lda pen_y + $1
		cmp v1f1d
; jumped to by: draw_clipped_line
l1EA9:
		bne l1EC2
		lda line_x
		sta pen_x
		lda line_x + $1
		sta pen_x + $1
		lda line_y
		sta pen_y
		lda line_y + $1
		sta pen_y + $1
		jmp l1E21

; jumped to by: draw_clipped_line
l1EC2:
		jsr pen_on_screen
		bcc l1ECA
		jmp l1E41

; jumped to by: draw_clipped_line
l1ECA:
		lda #$ff
		sta v17ac
		jmp l1E21

; jumped to by: draw_clipped_line
l1ED2:
		jsr pen_on_screen
		bcc l1EDA
		jmp l1E2A

; jumped to by: draw_clipped_line
l1EDA:
		lda pen_x + $1
		pha 
		lda pen_x
		pha 
		lda pen_y + $1
		pha 
		lda pen_y
		pha 
		lda line_x
		sta pen_x
		lda line_x + $1
		sta pen_x + $1
		lda line_y
		sta pen_y
		lda line_y + $1
		sta pen_y + $1
		pla 
		sta line_y
		pla 
		sta line_y + $1
		pla 
		sta line_x
		pla 
		sta line_x + $1
		lda #$ff
		sta v17ad
		jmp l1E41

unused_1f12:
		.byte	$af, $32
; read by: scale_x
; written by: draw_objects
v1f14:		.byte	$0a
; read by: scale_step
; written by: scale_x, scale_y, l3E04
v1f15:		.byte	$ff
; read by: draw_shape, scale_x, scale_y
; written by: draw_shape, scale_x, scale_y
v1f16:		.byte	$10
; read by: scale_x, scale_y
; written by: scale_x, scale_y
v1f17:		.byte	$01
; read by: draw_shape
; written by: draw_shape
v1f18:		.byte	$a9
; read by: draw_shape
; written by: draw_shape
v1f19:		.byte	$00
; read by: draw_clipped_line
; written by: draw_clipped_line
v1f1a:		.byte	$a0
; read by: draw_clipped_line
; written by: draw_clipped_line
v1f1b:		.byte	$00
; read by: draw_clipped_line
; written by: draw_clipped_line
v1f1c:		.byte	$6f
; read by: draw_clipped_line
; written by: draw_clipped_line
v1f1d:		.byte	$00
; read by: draw_shape
; written by: draw_shape
v1f1e:		.byte	$97
; read by: draw_shape
; written by: draw_shape
v1f1f:		.byte	$00

; read by: draw_shape, pen_on_screen, draw_clipped_line, clip_edge, lB78E
; written by: draw_shape, scale_x, draw_clipped_line, draw_polygon, clip_edge
; modified by: draw_clipped_line
pen_x:
		.word	$009a
; read by: draw_shape, pen_on_screen, draw_clipped_line, clip_edge, lB78E
; written by: draw_shape, scale_y, draw_clipped_line, draw_polygon, clip_edge
; modified by: draw_clipped_line
pen_y:		.word	$0074
; a projected point on the screen
; read by: project, draw_shape, collect_objects, draw_polygon, clip_edge, project_vertex, position_ball_sprite, l3C3F, l3CB7, $3d22, $3d26, l3E04, l423D, read_aim_cursor, $b72f, $b735, $b747, lB78E
; written by: project, draw_shape, draw_objects, clip_edge, project_vertex, position_ball_sprite, l3BEE, l3C3F, $3d1b, $3d1f, $3d93, $3d97, l3D9F, l3E04, read_aim_cursor, $b732, $b73a, lB78E
; modified by: l3CB7, l3D9F, read_aim_cursor
proj_x:		.word	$0160
; read by: draw_object, draw_shape, collect_objects, draw_polygon, clip_edge, project_vertex, position_ball_sprite, l3C3F, $3d0a, $3d2a, $3d36, $3d64, $3d7c, l3D9F, l3E04, l423D, read_aim_cursor, $b741, $b762, lB78E
; written by: project, draw_shape, draw_objects, clip_edge, project_vertex, position_ball_sprite, l3BEE, l3C3F, $3d17, $3d9b, l3D9F, l3E04, read_aim_cursor, $b744, lB78E
proj_y:		.word	$ffdb

unused_1f28:
		.byte	$32, $63

; called by: draw_view
draw_objects:
		ldy #$00
		cpy object_count
		bne l1F33
		jmp l1FC4

; jumped to by: draw_objects
l1F33:
		lda object_x, y
		sec 
		sbc #$30
		sta proj_x
		lda #$00
		sbc #$00
		sta proj_x + $1
		lda horizon
		sec 
		sbc object_y, y
		sta proj_y
		lda #$00
		sbc #$00
		sta proj_y + $1
		lda object_y, y
		cmp #$50
		bcs l1FB3
		and #$fe
		cmp #$10
		bcs l1F71
		tax 
		lda near_scales, x
		sta math_words + $a
		lda near_scales + $1, x
		sta math_words + $b
		jmp l1F83

; jumped to by: draw_objects
l1F71:
		lsr 
		lsr 
		lsr 
		and #$fe
		tax 
		lda far_scales, x
		sta math_words + $a
		lda far_scales + $1, x
		sta math_words + $b
; jumped to by: draw_objects
l1F83:
		lda object_types, y
		sty v2007
		ldx #$00
		stx v1f14
		cmp #$10
		bcc l1F97
		sec 
		sbc #$07
		bcs l1FA1
; jumped to by: draw_objects
l1F97:
		cmp #$09
		bcc l1FA1
		sta v1f14
		sec 
		sbc #$09
; jumped to by: draw_objects
l1FA1:
		asl 
		tax 
		lda shapes, x
		sta pointer_04
		lda shapes + $1, x
		sta pointer_04 + $1
		jsr draw_object
		ldy v2007
; jumped to by: draw_objects
l1FB3:
		iny 
		cpy #$30
		beq l1FC4
		cpy object_count
		bcs l1FBF
		jmp l1F33

; jumped to by: draw_objects
l1FBF:
		bcs l1FC4
		jmp l1F33

; jumped to by: draw_objects
l1FC4:
		jmp draw_terrain

; read by: draw_objects, l3E04
near_scales:
		.word	$fc00, $fd00, $fe00, $fe00, $ff00, $ff00, $ff00, $ff00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0100
; read by: draw_objects, l3E04
far_scales:
		.word	$fc00, $0000, $0100, $0100, $0200, $0200, $0200, $0200, $0300, $0300, $0300, $0300, $0300, $0400, $0400, $0400

; read by: draw_objects
; written by: draw_objects
v2007:
		.byte	$25

; draws the 3D view from the ball: collects the objects and features of the ball's map cell
; and the cells ahead, then draws them nearest first; fills never cover what is already drawn
; called by: lB5B0
draw_view:
		lda #$00
		sta feature_count
		ldx #$1d
; jumped to by: draw_view
l200F:
		sta shape_visible, x
		dex 
		bne l200F
		sta object_count
		lda ball_x
		sta point_x
		lda ball_x + $1
		sta point_x + $1
		lda ball_y
		sta point_y
		lda ball_y + $1
		sta point_y + $1
		jsr find_cell
		jsr collect_objects
		lda #$df
		sta step_pointer
		lda #$20
		sta step_pointer + $1
		ldy #$09
		lda direction
		asl 
		asl 
		asl 
		tax 
		and #$08
		beq l204B
		ldy #$05
		txa 
		clc 
		adc #$02
		tax 
; jumped to by: draw_view
l204B:
		txa 
		clc 
		adc step_pointer
		sta step_pointer
		lda step_pointer + $1
		adc #$00
		sta step_pointer + $1
; jumped to by: draw_view
l205B:
		sty v20de
		lda ball_x
		sta point_x
		lda ball_x + $1
		sta point_x + $1
		lda ball_y
		sta point_y
		lda ball_y + $1
		sta point_y + $1
		lda step_pointer
		sta pointer_08
		lda step_pointer + $1
		sta pointer_08 + $1
		lda (pointer_08), y
		bmi l2089
		clc 
		adc point_x
		sta point_x
		lda point_x + $1
		adc #$00
		sta point_x + $1
		bcc l209E
; jumped to by: draw_view
l2089:
		clc 
		eor #$ff
		adc #$01
		clc 
		eor #$ff
		adc #$01
		clc 
		adc point_x
		sta point_x
		lda point_x + $1
		sbc #$00
		sta point_x + $1
; jumped to by: draw_view
l209E:
		dey 
		lda (pointer_08), y
		bmi l20B0
		clc 
		adc point_y
		sta point_y
		lda point_y + $1
		adc #$00
		sta point_y + $1
		bcc l20C5
; jumped to by: draw_view
l20B0:
		clc 
		eor #$ff
		adc #$01
		clc 
		eor #$ff
		adc #$01
		clc 
		adc point_y
		sta point_y
		lda point_y + $1
		sbc #$00
		sta point_y + $1
; jumped to by: draw_view
l20C5:
		dey 
		sty v20de
		jsr find_cell
		jsr collect_objects
		ldy v20de
		bmi l20D7
		jmp l205B

; jumped to by: draw_view
l20D7:
		jsr sort_objects
		jsr draw_objects
		rts 

; read by: draw_view
; written by: draw_view
v20de:
		.byte	$ff

; 8 steps of +-64 per direction, read through step_pointer
direction_steps:
		.char	64, 64, 64, -64, 64, 0, 0, 64, 0, -64, 64, 64, 0, 64, 64, 0
		.char	-64, 64, 64, 64, 0, 64, -64, 0, 64, 0, -64, 64, -64, 0, 0, 64
		.char	-64, -64, -64, 64, -64, 0, 0, -64, 0, 64, -64, -64, 0, -64, -64, 0
		.char	64, -64, -64, -64, 0, -64, 64, 0, -64, 0, 64, -64, 64, 0, 0, -64

; read by: draw_view
; written by: draw_view
step_pointer:
		.word	$20df

; called by: draw_view
collect_objects:
		lda #$10
		sta object_pass
		inc pointer_08
		bne l212C
		inc pointer_08 + $1
; jumped to by: collect_objects
l212C:
		ldy #$00
; jumped to by: collect_objects
l212E:
		iny 
		lda (pointer_08), y
		cmp #$80
		beq l2184
		clc 
		adc base_x
		sta point_x
		lda #$00
		adc base_x + $1
		sta point_x + $1
		iny 
		lda (pointer_08), y
		clc 
		adc base_y
		sta point_y
		lda #$00
		adc base_y + $1
		sta point_y + $1
		iny 
		tya 
		clc 
		adc pointer_08
		sta pointer_08
		lda pointer_08 + $1
		adc #$00
		sta pointer_08 + $1
		jsr to_view
		lda view_y + $1
		bmi l212C
		jsr project
		ldy #$00
		lda (pointer_08), y
		ora object_pass
		ldy object_count
		sta object_types, y
		lda proj_x
		sta object_x, y
		lda proj_y
		sta object_y, y
		inc object_count
		bne l212C
		dec object_count
; jumped to by: collect_objects
l2184:
		lda object_pass
		beq l2190
		lda #$00
		sta object_pass
		beq l212E
; jumped to by: collect_objects
l2190:
		jmp collect_features

; sorts the objects by screen row, nearest first
; called by: draw_view
sort_objects:
		lda object_count
		dec object_count
; jumped to by: sort_objects
l2197:
		ldy #$00
		sty log_value
; jumped to by: sort_objects
l219B:
		lda object_y, y
		cmp object_y + $1, y
		bcs l21CF
		lda object_y, y
		pha 
		lda object_x, y
		pha 
		lda object_types, y
		pha 
		lda object_x + $1, y
		sta object_x, y
		lda object_y + $1, y
		sta object_y, y
		lda object_types + $1, y
		sta object_types, y
		pla 
		sta object_types + $1, y
		pla 
		sta object_x + $1, y
		pla 
		sta object_y + $1, y
		inc log_value
; jumped to by: sort_objects
l21CF:
		iny 
		cpy object_count
		bcc l219B
		lda log_value
		bne l2197
		inc object_count
		rts 

; read by: draw_objects, sort_objects
; written by: collect_objects, sort_objects
object_types:
		.byte	$00, $07, $09, $01, $01, $0a, $0b, $0b, $04, $01, $0b, $05, $0c, $0a, $04, $09
		.byte	$04, $03, $07, $0e, $00, $06, $01, $06, $00, $06, $00, $09, $05, $05, $05, $0c
		.byte	$05, $0e, $05, $05, $0c, $0a, $ed, $4b, $fe, $41, $d2, $e9, $4b, $fe, $3a, $d2
		.byte	$ed, $4b, $04, $c3, $d2, $4b, $4f, $d1, $c9, $c5, $d5, $21, $80, $00, $7e, $36
		.byte	$00, $b7, $47, $ca, $1f, $4c, $23, $7e, $fe, $20, $c2, $08, $4c, $05, $c3, $fa
		.byte	$4b, $11, $20, $48, $78, $2b, $04, $12, $13, $23, $05, $ca, $19, $4c, $7e, $c3
		.byte	$0e, $4c, $32, $66, $42, $c3, $3f, $4c, $af, $32, $66, $42, $3a, $5d, $42, $b7
		.byte	$c2, $32, $4c, $cd, $c0, $4c, $3e, $2a, $cd, $93, $4c, $0e, $0a, $11, $1f, $48
		.byte	$cd, $05, $00, $3e, $0a, $cd, $93, $4c, $d1, $c1, $3a, $20, $48, $21, $21, $48
		.byte	$e5, $22, $71, $48, $85, $6f, $3e, $00, $8c, $67, $36, $0d, $23, $3e, $0a, $77
		.byte	$e1, $3a, $5d, $42, $b7, $c2, $7b, $4c, $e5, $21, $21, $48, $7e, $fe, $0d, $ca
		.byte	$7a, $4c, $d6, $61, $da, $76, $4c, $fe, $1a, $d2, $76, $4c, $c6, $41, $77, $23
		.byte	$c3, $63, $4c, $e1, $c9, $7e, $23, $fe, $20, $ca, $7c, $4c, $fe, $0a, $ca, $7c
		.byte	$4c, $fe, $0d, $c2, $ba, $4c, $23, $22, $71, $48, $c9, $f1, $e5, $d5, $c5, $f5
		.byte	$0e, $02, $e6, $7f, $5f, $cd, $05, $00, $f1, $c1, $d1, $e1, $b7, $c9, $e5, $2a
		.byte	$71, $48, $2b, $7e, $e6, $7f, $fe, $0a, $23, $cc, $f0, $4b, $23, $22, $71, $48
; read by: draw_objects, sort_objects
; written by: collect_objects, sort_objects
object_x:
		.byte	$2f, $d3, $67, $c4, $c7, $b0, $ad, $b7, $a7, $a4, $b0, $d9, $d5, $78, $a8, $a6
		.byte	$aa, $ca, $c4, $ca, $76, $7c, $7f, $9f, $a9, $aa, $b2, $c0, $b9, $c4, $c0, $bc
		.byte	$c3, $c7, $c1, $c0, $c9, $d9, $c3, $f3, $4c, $f5, $c5, $d5, $e5, $11, $1b, $43
		.byte	$21, $00, $00, $22, $19, $43, $21, $6b, $42, $3a, $63, $42, $b7, $ca, $24, $4d
		.byte	$e5, $0e, $1a, $cd, $05, $00, $e1, $7e, $b7, $fa, $24, $4d, $cd, $46, $4d, $d5
		.byte	$0e, $13, $cd, $05, $00, $d1, $d5, $0e, $16, $cd, $05, $00, $3c, $ca, $bb, $48
		.byte	$e1, $cd, $46, $4d, $0e, $0f, $cd, $05, $00, $3c, $ca, $b5, $48, $e1, $d1, $c1
		.byte	$f1, $c9, $f5, $c5, $d5, $e5, $21, $00, $02, $22, $1d, $46, $11, $1f, $46, $0e
		.byte	$1a, $cd, $05, $00, $21, $ad, $42, $7e, $b7, $fa, $24, $4d, $c3, $18, $4d, $e5
		.byte	$d5, $11, $0c, $00, $19, $af, $16, $04, $77, $23, $15, $c2, $4f, $4d, $11, $10
		.byte	$00, $19, $77, $e1, $d1, $c9, $f5, $d5, $11, $ad, $42, $1a, $b7, $fa, $7d, $4d
		.byte	$c5, $e5, $d5, $11, $1f, $46, $0e, $1a, $cd, $05, $00, $d1, $01, $c5, $e5, $0e
		.byte	$10, $cd, $05, $00, $e1, $c1, $d1, $f1, $c9, $f5, $3a, $61, $42, $b7, $ca, $55
		.byte	$4a, $d5, $3a, $8c, $42, $3c, $ca, $7d, $4d, $fa, $09, $4e, $3e, $0d, $cd, $1b
		.byte	$4e, $3e, $0a, $cd, $1b, $4e, $3e, $1a, $cd, $1b, $4e, $e5, $2a, $1b, $44, $11
		.byte	$1d, $44, $c5, $01, $8c, $42, $cd, $f3, $4d, $11, $1d, $44, $0e, $1a, $cd, $05
; read by: draw_objects, sort_objects
; written by: collect_objects, sort_objects
object_y:
		.byte	$12, $0f, $0a, $09, $07, $06, $05, $05, $04, $04, $04, $04, $04, $03, $03, $03
		.byte	$03, $03, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
		.byte	$02, $02, $02, $02, $02, $02, $01, $6b, $42, $cd, $f3, $4d, $11, $1b, $43, $0e
		.byte	$1a, $cd, $05, $00, $c1, $e1, $11, $6b, $42, $c3, $74, $4d, $7c, $b5, $c8, $7d
		.byte	$e6, $7f, $ca, $fe, $4d, $c6, $80, $17, $17, $e6, $03, $29, $84, $60, $69, $c3
		.byte	$52, $4e, $3e, $0d, $cd, $1b, $4e, $3e, $0a, $cd, $1b, $4e, $3e, $0c, $cd, $1b
		.byte	$4e, $d1, $f1, $c9, $f5, $3a, $61, $42, $b7, $ca, $55, $4a, $3a, $8c, $42, $3c
		.byte	$ca, $92, $4c, $fa, $fa, $4e, $e3, $e5, $d5, $2a, $1b, $44, $7c, $fe, $02, $cc
		.byte	$4a, $4e, $23, $22, $1b, $44, $11, $1c, $44, $19, $d1, $f1, $f5, $e6, $7f, $77
		.byte	$f1, $e1, $c9, $11, $1d, $44, $21, $8c, $42, $3e, $04, $f5, $c5, $d5, $e5, $0e
		.byte	$1a, $cd, $05, $00, $d1, $d5, $0e, $15, $cd, $05, $00, $b7, $c2, $46, $4f, $d1
		.byte	$e1, $01, $80, $00, $09, $eb, $c1, $f1, $3d, $c2, $52, $4e, $21, $00, $00, $c9
		.byte	$11, $1b, $43, $3e, $02, $21, $6b, $42, $c3, $52, $4e, $f5, $3a, $63, $42, $b7
		.byte	$ca, $55, $4a, $3a, $6b, $42, $b7, $fa, $92, $4c, $e3, $e5, $d5, $2a, $19, $43
		.byte	$7c, $3d, $cc, $77, $4e, $23, $22, $19, $43, $11, $1a, $43, $19, $d1, $f1, $77
		.byte	$e1, $c9, $3a, $ad, $42, $3c, $ca, $a5, $4c, $fa, $35, $4f, $e5, $d5, $2a, $1d

; finds the map cell (7 by 7) for point_x/point_y
; called by: draw_view
find_cell:
		lda point_x
		and #$c0
		sta base_x
		lda point_x + $1
		sta base_x + $1
		asl point_x
		rol 
		asl point_x
		rol 
		cmp #$07
		bcs l251D
		sta cell_x
		lda point_y
		and #$c0
		sta base_y
		lda point_y + $1
		sta base_y + $1
		asl point_y
		rol 
		asl point_y
		rol 
		cmp #$07
		bcs l251D
		sta cell_y
		asl 
		asl 
		asl 
		clc 
		adc cell_x
		asl 
		tax 
		lda terrain_pointers, x
		sta pointer_08
		lda terrain_pointers + $1, x
		sta pointer_08 + $1
		rts 

; jumped to by: find_cell
l251D:
		lda #$ff
		sta cell_x
		sta cell_y
		lda #$2e
		sta pointer_08
		lda #$25
		sta pointer_08 + $1
		rts 

empty_cell:
		.byte	$80, $80, $80, $80, $80, $80, $80, $80
; read by: find_cell
; written by: find_cell
cell_x:		.byte	$01
; written by: find_cell
cell_y:		.byte	$05
; read by: collect_objects
; written by: collect_objects
object_pass:		.byte	$00

; jumped to by: draw_objects
draw_terrain:
		lda horizon
		clc 
		adc #$01
		sta clip_bottom
		nop 
		lda #$07
		sta polygon_color
; jumped to by: draw_terrain
l2547:
		ldx feature_count
		beq l25C1
		dex 
		dex 
		stx feature_count
		lda feature_pointers, x
		sta pointer_08
		lda feature_pointers + $1, x
		sta pointer_08 + $1
		lda feature_x, x
		sta base_x
		lda feature_x + $1, x
		sta base_x + $1
		lda feature_y, x
		sta base_y
		lda feature_y + $1, x
		sta base_y + $1
		ldy #$00
; jumped to by: draw_terrain
l2571:
		lda (pointer_08), y
		cmp #$80
		beq l2547
		lda base_x
		and #$c0
		ora (pointer_08), y
		sta base_x
		lda base_y
		and #$c0
		iny 
		ora (pointer_08), y
		sta base_y
		iny 
		lda (pointer_08), y
		iny 
		asl 
		tax 
		lda pointer_08 + $1
		pha 
		lda pointer_08
		pha 
		tya 
		pha 
		lda shape_eb26 + $f, x
		sta pointer_08
		lda shape_eb36, x
		sta pointer_08 + $1
		ldy #$06
		tya 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc pointer_08
		sta pointer_08
		lda pointer_08 + $1
		sbc #$00
		sta pointer_08 + $1
		jsr draw_polygon
		pla 
		tay 
		pla 
		sta pointer_08
		pla 
		sta pointer_08 + $1
		jmp l2571

; jumped to by: draw_terrain
l25C1:
		ldx #$1e
; jumped to by: draw_terrain
l25C3:
		dex 
		bne l25C9
		jmp reset_clip

; jumped to by: draw_terrain
l25C9:
		lda shape_visible, x
		beq l25C3
		txa 
		pha 
		asl 
		tax 
		lda hole_shapes_base, x
		sta pointer_08
		lda terrain_93bd + $37, x
		sta pointer_08 + $1
		lda #$0d
		cpx #$25
		bcc l25EA
		lda #$0e
		cpx #$2d
		bcs l25EA
		lda #$0c
; jumped to by: draw_terrain
l25EA:
		sta polygon_color
		jsr draw_hole_shape
		pla 
		tax 
		bne l25C3
; called by: draw_terrain
draw_hole_shape:
		ldy #$00
		sty base_x
		sty base_y
		lda (pointer_08), y
		lsr 
		ror base_x
		lsr 
		ror base_x
		sta base_x + $1
		iny 
		lda (pointer_08), y
		lsr 
		ror base_y
		lsr 
		ror base_y
		sta base_y + $1
		iny 
		lda polygon_color
		cmp #$0d
		beq l262D
		lda #$02
		clc 
		eor #$ff
		adc #$01
		clc 
		adc pointer_08
		sta pointer_08
		lda pointer_08 + $1
		sbc #$00
		sta pointer_08 + $1
		ldy #$04
		bne l263B
; jumped to by: draw_hole_shape
l262D:
		lda (pointer_08), y
		ora base_x
		sta base_x
		iny 
		lda (pointer_08), y
		ora base_y
		sta base_y
		iny 
; jumped to by: draw_hole_shape
l263B:
		lda (pointer_08), y
		bmi l264C
		clc 
		adc base_x
		sta base_x
		lda #$00
		adc base_x + $1
		sta base_x + $1
		bcc l2657
; jumped to by: draw_hole_shape
l264C:
		clc 
		adc base_x
		sta base_x
		lda base_x + $1
		sbc #$00
		sta base_x + $1
; jumped to by: draw_hole_shape
l2657:
		iny 
		lda (pointer_08), y
		bmi l2669
		clc 
		adc base_y
		sta base_y
		lda #$00
		adc base_y + $1
		sta base_y + $1
		bcc l2674
; jumped to by: draw_hole_shape
l2669:
		clc 
		adc base_y
		sta base_y
		lda base_y + $1
		sbc #$00
		sta base_y + $1
; jumped to by: draw_hole_shape
l2674:
		iny 
		lda polygon_color
		cmp #$0d
		beq l267F
		jmp draw_polygon

; jumped to by: draw_hole_shape
l267F:
		lda pointer_08 + $1
		pha 
		lda pointer_08
		pha 
		lda base_y + $1
		pha 
		lda base_y
		pha 
		lda base_x + $1
		pha 
		lda base_x
		pha 
; jumped to by: draw_hole_shape
l2691:
		lda (pointer_08), y
		iny 
		cmp #$80
		bne l2691
		lda (pointer_08), y
		bmi l26A9
		clc 
		adc base_x
		sta base_x
		lda #$00
		adc base_x + $1
		sta base_x + $1
		bcc l26B4
; jumped to by: draw_hole_shape
l26A9:
		clc 
		adc base_x
		sta base_x
		lda base_x + $1
		sbc #$00
		sta base_x + $1
; jumped to by: draw_hole_shape
l26B4:
		iny 
		lda (pointer_08), y
		bmi l26C6
		clc 
		adc base_y
		sta base_y
		lda #$00
		adc base_y + $1
		sta base_y + $1
		bcc l26D1
; jumped to by: draw_hole_shape
l26C6:
		clc 
		adc base_y
		sta base_y
		lda base_y + $1
		sbc #$00
		sta base_y + $1
; jumped to by: draw_hole_shape
l26D1:
		tya 
		sec 
		sbc #$05
		clc 
		adc pointer_08
		sta pointer_08
		lda pointer_08 + $1
		adc #$00
		sta pointer_08 + $1
		ldy #$06
		lda #$05
		sta polygon_color
		jsr draw_polygon
		pla 
		sta base_x
		pla 
		sta base_x + $1
		pla 
		sta base_y
		pla 
		sta base_y + $1
		lda #$0d
		sta polygon_color
		pla 
		sta pointer_08
		pla 
		sta pointer_08 + $1
		ldy #$06
; draws a polygon of world points, cut where it crosses behind the view, and fills it
; called by: draw_terrain, draw_hole_shape
; jumped to by: draw_hole_shape
draw_polygon:
		lda #$00
		sta v2c4d
		sta seed_enable
		lda #$02
		sta seed_count
		jsr project_vertex
		beq l2718
		jmp l2775

; jumped to by: draw_polygon
l2718:
		lda proj_x
		sta line_x
		lda proj_x + $1
		sta line_x + $1
		lda proj_y
		sta line_y
		lda proj_y + $1
		sta line_y + $1
		jsr line_start_on_screen
		bcc l2734
		jmp l2804

; jumped to by: draw_polygon
l2734:
		lda v2c44
		pha 
		lda v2c43
		pha 
		lda v2c48
		pha 
		lda v2c47
		pha 
		lda v2c43
		sta v2c45
		lda v2c44
		sta v2c46
		lda v2c47
		sta v2c49
		lda v2c48
		sta v2c4a
		jsr l286B
		jsr l28E9
		pla 
		sta v2c47
		pla 
		sta v2c48
		pla 
		sta v2c43
		pla 
		sta v2c44
		jmp l2804

; jumped to by: draw_polygon, $28cb, $28e6
l2775:
		lda v2c4d
		beq l277D
		jmp l283E

; jumped to by: draw_polygon
l277D:
		lda (pointer_08), y
		cmp #$80
		bne l2786
		jsr l2862
; jumped to by: draw_polygon
l2786:
		jsr project_vertex
		bne l2775
		lda proj_x
		sta line_x
		lda proj_x + $1
		sta line_x + $1
		lda proj_y
		sta line_y
		lda proj_y + $1
		sta line_y + $1
		jsr line_start_on_screen
		bcs l2804
		lda v2c44
		pha 
		lda v2c43
		pha 
		lda v2c48
		pha 
		lda v2c47
		pha 
		lda v2c44
		pha 
		lda v2c43
		pha 
		lda v2c45
		sta v2c43
		lda v2c46
		sta v2c44
		pla 
		sta v2c45
		pla 
		sta v2c46
		lda v2c48
		pha 
		lda v2c47
		pha 
		lda v2c49
		sta v2c47
		lda v2c4a
		sta v2c48
		pla 
		sta v2c49
		pla 
		sta v2c4a
		lda #$ff
		sta v2c4e
		jsr clip_edge
		pla 
		sta v2c47
		pla 
		sta v2c48
		pla 
		sta v2c43
		pla 
		sta v2c44
; jumped to by: draw_polygon
l2804:
		lda v2c4d
		bne l283E
		lda (pointer_08), y
		cmp #$80
		bne l2812
		jsr l2862
; jumped to by: draw_polygon
l2812:
		jsr project_vertex
		beq l281A
		jmp l28C6

; jumped to by: draw_polygon
l281A:
		lda proj_x
		sta pen_x
		lda proj_x + $1
		sta pen_x + $1
		lda proj_y
		sta pen_y
		lda proj_y + $1
		sta pen_y + $1
		sty v2c4b
		jsr draw_clipped_line
		ldy v2c4b
		jmp l2804

; jumped to by: draw_polygon
l283E:
		ldy v2c4c
		jsr replot_seeds
; jumped to by: draw_polygon
l2844:
		ldx seed_count
		dex 
		cpx #$02
		bcc l2861
		lda fill_seeds, x
		tay 
		dex 
		lda fill_seeds, x
		stx seed_count
		tax 
		lda polygon_color
		jsr flood_fill
		jmp l2844

; jumped to by: draw_polygon
l2861:
		rts 

; called by: draw_polygon
l2862:
		sty v2c4c
		ldy #$06
		sty v2c4d
		rts 

; called by: draw_polygon
l286B:
		sty v2c4b
; jumped to by: l286B
l286E:
		lda (pointer_08), y
		iny 
		iny 
		cmp #$80
		bne l286E
		tya 
		sec 
		sbc #$04
		tay 
		lda (pointer_08), y
		bmi l288E
		clc 
		adc base_x
		sta v2c43
		lda #$00
		adc base_x + $1
		sta v2c44
		bcc l289B
; jumped to by: l286B
l288E:
		clc 
		adc base_x
		sta v2c43
		lda base_x + $1
		sbc #$00
		sta v2c44
; jumped to by: l286B
l289B:
		iny 
		lda (pointer_08), y
		bmi l28AF
		clc 
		adc base_y
		sta v2c47
		lda #$00
		adc base_y + $1
		sta v2c48
		bcc l28BC
; jumped to by: l286B
l28AF:
		clc 
		adc base_y
		sta v2c47
		lda base_y + $1
		sbc #$00
		sta v2c48
; jumped to by: l286B
l28BC:
		ldy v2c4b
		rts 

; jumped to by: draw_terrain
reset_clip:
		lda #$c8
		sta clip_bottom
		rts 

unused_28c5:
		.byte	$ea

; jumped to by: draw_polygon
l28C6:
		jsr line_start_on_screen
		bcc l28CE
		jmp l2775

; jumped to by: $28c9
l28CE:
		lda v2c44
		pha 
		lda v2c43
		pha 
		lda #$00
		sta v2c4e
		jsr clip_edge
		pla 
		sta v2c43
		pla 
		sta v2c44
		jmp l2775

; called by: draw_polygon
l28E9:
		lda v2c43
		sta point_x
		lda v2c44
		sta point_x + $1
		lda v2c47
		sta point_y
		lda v2c48
		sta point_y + $1
		lda #$ff
		sta direction_flag
		jsr to_view
		lda #$00
		sta direction_flag
		lda view_y + $1
		bne l2914
		lda view_y
		bne l291C
; jumped to by: l28E9
l2914:
		lda #$ff
		sta v2c4e
		jsr clip_edge
; jumped to by: l28E9
l291C:
		ldy v2c4b
		rts 

; halves an edge until its end is in front of the view
; called by: draw_polygon, $28db, l28E9
clip_edge:
		lda v2c43
		clc 
		adc v2c45
		sta v2c3f
		lda v2c44
		adc v2c46
		ror 
		sta v2c40
		ror v2c3f
		lda v2c47
		clc 
		adc v2c49
		sta v2c41
		lda v2c48
		adc v2c4a
		ror 
		sta v2c42
		ror v2c41
		lda v2c3f
		sta point_x
		lda v2c40
		sta point_x + $1
		lda v2c41
		sta point_y
		lda v2c42
		sta point_y + $1
		lda #$ff
		sta direction_flag
		jsr to_view
		lda #$00
		sta direction_flag
		lda view_y + $1
		beq l2977
		jmp l2A06

; jumped to by: clip_edge
l2977:
		lda view_y
		bne l297F
		jmp l2A06

; jumped to by: clip_edge
l297F:
		jsr project
		lda #$30
		clc 
		eor #$ff
		adc #$01
		clc 
		adc proj_x
		sta proj_x
		lda proj_x + $1
		sbc #$00
		sta proj_x + $1
		lda horizon
		sec 
		sbc proj_y
		sta proj_y
		lda #$00
		sbc proj_y + $1
		sta proj_y + $1
		lda proj_x
		sta pen_x
		lda proj_x + $1
		sta pen_x + $1
		lda proj_y
		sta pen_y
		lda proj_y + $1
		sta pen_y + $1
		jsr pen_on_screen
		bcs l29CA
		jmp l2A44

; jumped to by: clip_edge
l29CA:
		lda v2c4e
		beq l29FF
		lda line_x + $1
		pha 
		lda line_x
		pha 
		lda pen_x
		sta line_x
		lda pen_x + $1
		sta line_x + $1
		pla 
		sta pen_x
		pla 
		sta pen_x + $1
		lda line_y + $1
		pha 
		lda line_y
		pha 
		lda pen_y
		sta line_y
		lda pen_y + $1
		sta line_y + $1
		pla 
		sta pen_y
		pla 
		sta pen_y + $1
; jumped to by: clip_edge
l29FF:
		jsr draw_clipped_line
		ldy v2c4b
		rts 

; jumped to by: clip_edge
l2A06:
		lda v2c3f
		cmp v2c43
		bne l2A14
		lda v2c40
		cmp v2c44
; jumped to by: clip_edge
l2A14:
		bne l2A29
		lda v2c41
		cmp v2c47
		bne l2A24
		lda v2c42
		cmp v2c48
; jumped to by: clip_edge
l2A24:
		bne l2A29
		jmp l2A7C

; jumped to by: clip_edge
l2A29:
		lda v2c3f
		sta v2c43
		lda v2c40
		sta v2c44
		lda v2c41
		sta v2c47
		lda v2c42
		sta v2c48
		jmp clip_edge

; jumped to by: clip_edge
l2A44:
		lda v2c3f
		cmp v2c45
		bne l2A52
		lda v2c40
		cmp v2c46
; jumped to by: clip_edge
l2A52:
		bne l2AAA
		lda v2c41
		cmp v2c49
		bne l2A62
		lda v2c42
		cmp v2c4a
; jumped to by: clip_edge
l2A62:
		bne l2AAA
		lda v2c3f
		sta pen_x
		lda v2c40
		sta pen_x + $1
		lda v2c41
		sta pen_y
		lda v2c42
		sta pen_y + $1
; jumped to by: clip_edge
l2A7C:
		lda v2c3f
		sta point_x
		lda v2c40
		sta point_x + $1
		lda v2c41
		sta point_y
		lda v2c42
		sta point_y + $1
		lda #$ff
		sta direction_flag
		jsr to_view
		lda #$00
		sta direction_flag
		lda #$01
		sta view_y
		lda #$00
		sta view_y + $1
		jmp l297F

; jumped to by: clip_edge
l2AAA:
		lda v2c41
		sta v2c49
		lda v2c42
		sta v2c4a
		lda v2c3f
		sta v2c45
		lda v2c40
		sta v2c46
		jmp clip_edge

; called by: draw_polygon
project_vertex:
		lda (pointer_08), y
		bmi l2AD6
		clc 
		adc base_x
		sta point_x
		lda #$00
		adc base_x + $1
		sta point_x + $1
		bcc l2AE1
; jumped to by: project_vertex
l2AD6:
		clc 
		adc base_x
		sta point_x
		lda base_x + $1
		sbc #$00
		sta point_x + $1
; jumped to by: project_vertex
l2AE1:
		iny 
		lda (pointer_08), y
		bmi l2AF3
		clc 
		adc base_y
		sta point_y
		lda #$00
		adc base_y + $1
		sta point_y + $1
		bcc l2AFE
; jumped to by: project_vertex
l2AF3:
		clc 
		adc base_y
		sta point_y
		lda base_y + $1
		sbc #$00
		sta point_y + $1
; jumped to by: project_vertex
l2AFE:
		lda v2c43
		sta v2c45
		lda v2c44
		sta v2c46
		lda v2c47
		sta v2c49
		lda v2c48
		sta v2c4a
		lda point_x
		sta v2c43
		lda point_x + $1
		sta v2c44
		lda point_y
		sta v2c47
		lda point_y + $1
		sta v2c48
		iny 
		sty v2c4b
		lda #$ff
		sta direction_flag
		jsr to_view
		lda #$00
		sta direction_flag
		lda view_y + $1
		bmi l2B81
		beq l2B4B
		ldy #$00
		sty view_y + $1
		dey 
		sty view_y
; jumped to by: project_vertex
l2B4B:
		lda view_y
		bne l2B54
		lda #$ff
		bne l2B81
; jumped to by: project_vertex
l2B54:
		jsr project
		lda #$30
		clc 
		eor #$ff
		adc #$01
		clc 
		adc proj_x
		sta proj_x
		lda proj_x + $1
		sbc #$00
		sta proj_x + $1
		lda horizon
		sec 
		sbc proj_y
		sta proj_y
		lda #$00
		sbc proj_y + $1
		sta proj_y + $1
		lda #$00
; jumped to by: project_vertex
l2B81:
		php 
		ldy v2c4b
		plp 
		rts 

; jumped to by: collect_objects
collect_features:
		iny 
		lda (pointer_08), y
		cmp #$80
		beq l2BC2
		tya 
		clc 
		adc pointer_08
		sta pointer_08
		lda pointer_08 + $1
		adc #$00
		sta pointer_08 + $1
		ldx feature_count
		lda pointer_08
		sta feature_pointers, x
		lda pointer_08 + $1
		sta feature_pointers + $1, x
		lda base_x
		sta feature_x, x
		lda base_x + $1
		sta feature_x + $1, x
		lda base_y
		sta feature_y, x
		lda base_y + $1
		sta feature_y + $1, x
		inx 
		inx 
		stx feature_count
		ldy #$00
; jumped to by: collect_features
l2BC2:
		lda (pointer_08), y
		iny 
		cmp #$80
		bne l2BC2
		bne l2BC2
		lda #$16
		sta shape_visible
; jumped to by: collect_features
l2BD0:
		lda (pointer_08), y
		iny 
		cmp #$80
		beq l2BE2
		clc 
		adc shape_visible
		tax 
		inc shape_visible, x
		jmp l2BD0

; jumped to by: collect_features
l2BE2:
		lda shape_visible
		beq l2BFB
		cmp #$16
		beq l2BF3
		lda #$00
		sta shape_visible
		jmp l2BD0

; jumped to by: collect_features
l2BF3:
		lda #$12
		sta shape_visible
		jmp l2BD0

; jumped to by: collect_features
l2BFB:
		rts 

; read by: draw_terrain, collect_features
; written by: draw_view, collect_features
; modified by: collect_features
shape_visible:
		.byte	$00, $02, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $01, $01, $00, $02, $00, $00, $00, $00, $00, $00

; read by: draw_terrain
; written by: collect_features
feature_pointers:
		.word	$86ae, $8723, $ffff, $ffff, $ffff, $0000
; read by: draw_terrain
; written by: collect_features
feature_x:
		.word	$0000, $0040, $0000, $0000, $0000, $0000
; read by: draw_terrain
; written by: collect_features
feature_y:
		.word	$0140, $0140, $0000, $0000, $0000, $0000

; read by: draw_terrain, collect_features
; written by: draw_view, draw_terrain, collect_features
feature_count:
		.byte	$00
; read by: clip_edge
; written by: clip_edge
; modified by: clip_edge
v2c3f:		.byte	$00
; read by: clip_edge
; written by: clip_edge
v2c40:		.byte	$00
; read by: clip_edge
; written by: clip_edge
; modified by: clip_edge
v2c41:		.byte	$00
; read by: clip_edge
; written by: clip_edge
v2c42:		.byte	$00
; read by: draw_polygon, $28d2, l28E9, clip_edge, project_vertex
; written by: draw_polygon, l286B, $28df, clip_edge, project_vertex
v2c43:		.byte	$0d
; read by: draw_polygon, $28ce, l28E9, clip_edge, project_vertex
; written by: draw_polygon, l286B, $28e3, clip_edge, project_vertex
v2c44:		.byte	$00
; read by: draw_polygon, clip_edge
; written by: draw_polygon, clip_edge, project_vertex
v2c45:		.byte	$10
; read by: draw_polygon, clip_edge
; written by: draw_polygon, clip_edge, project_vertex
v2c46:		.byte	$00
; read by: draw_polygon, l28E9, clip_edge, project_vertex
; written by: draw_polygon, l286B, clip_edge, project_vertex
v2c47:		.byte	$30
; read by: draw_polygon, l28E9, clip_edge, project_vertex
; written by: draw_polygon, l286B, clip_edge, project_vertex
v2c48:		.byte	$01
; read by: draw_polygon, clip_edge
; written by: draw_polygon, clip_edge, project_vertex
v2c49:		.byte	$31
; read by: draw_polygon, clip_edge
; written by: draw_polygon, clip_edge, project_vertex
v2c4a:		.byte	$01
; read by: draw_polygon, l286B, l28E9, clip_edge, project_vertex
; written by: draw_polygon, l286B, project_vertex
v2c4b:		.byte	$08
; read by: draw_polygon
; written by: l2862
v2c4c:		.byte	$3c
; read by: draw_polygon
; written by: draw_polygon, l2862
v2c4d:		.byte	$06
; read by: clip_edge
; written by: draw_polygon, $28d8, l28E9
v2c4e:		.byte	$00
; read by: draw_hole_shape, draw_polygon
; written by: draw_terrain, draw_hole_shape
polygon_color:
		.byte	$0d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; a point turned to the view: x across, y the depth ($ff in the high byte when culled)
; read by: project, rotate_4, rotate_6, rotate_7, l3711, l3D9F, draw_flag
; written by: project, rotate_1, rotate_2, rotate_3, rotate_45, rotate_4, rotate_6, rotate_7, l3D9F, draw_flag
view_x:
		.word	$0000
; read by: project, rotate_4, rotate_6, rotate_7, collect_objects, l28E9, clip_edge, project_vertex, l3711, l3D9F, draw_flag
; written by: to_view, rotate_1, rotate_2, rotate_3, rotate_45, rotate_4, rotate_6, rotate_7, clip_edge, project_vertex, l3D9F, draw_flag
view_y:		.word	$0000

; the screen row of the horizon (rows count up from the bottom)
; read by: draw_objects, draw_terrain, clip_edge, project_vertex, $3d06, l3E04, $b73d
; written by: main
horizon:
		.byte	$90

; called by: print_inline
l2C60:
		ldy #$00
		lda (text_pointer), y
		cmp #$ff
		bne l2C69
		rts 

; jumped to by: l2C60
l2C69:
		jsr print_char
		inc text_pointer
		bne l2C72
		inc text_pointer + $1
; jumped to by: l2C60
l2C72:
		jmp l2C60

; prints the $ff-terminated text after the jsr
; called by: swing, $2e52, $2ec7, check_landing, check_out_of_bounds, $3164, $31a6, print_score_labels, $a19d, $a1a2, $a1ae, $a1bf, $a1c4, $a1d0, $a1e3, $a1eb, $a1f7, $a1fe, $a20a, nmi, print_par_result, $afe9, $affb, title_screen, $b2d3, $b2d8, $b2ec, $b2f1, $b31d, $b322, aim, music_step, lC0F3, lC13B
print_inline:
		pla 
		sta text_pointer
		pla 
		sta text_pointer + $1
		inc text_pointer
		bne l2C81
		inc text_pointer + $1
; jumped to by: print_inline
l2C81:
		jsr l2C60
		lda text_pointer + $1
		pha 
		lda text_pointer
		pha 
		rts 

; called by: bank_in_io, lC0F3, lC13B
print_hex:
		pha 
		jsr l2CB4
		jsr print_char
		pla 
; jumped to by: lAD35
print_nibble:
		jsr l2CBB
		jmp print_char

store_hex:
		pha 
		jsr l2CB4
		ldy #$00
		sta (text_pointer), y
		inc text_pointer
		bne l2CA7
		inc text_pointer + $1
; jumped to by: store_hex
l2CA7:
		pla 
		jsr l2CBB
		sta (text_pointer), y
		inc text_pointer
		bne l2CB3
		inc text_pointer + $1
; jumped to by: store_hex
l2CB3:
		rts 

; called by: print_hex, store_hex
l2CB4:
		lsr 
		lsr 
		lsr 
		lsr 
		jmp l2CBD

; called by: print_nibble, store_hex
l2CBB:
		and #$0f
; jumped to by: l2CB4
l2CBD:
		cmp #$0a
		bcc l2CC7
		sbc #$0a
		clc 
		adc #$41
		rts 

; jumped to by: l2CBB
l2CC7:
		adc #$30
		rts 

unused_2cca:
		.byte	$00, $00, $00, $00, $00, $00

; jumped to by: d0103, old_loader, $c0f0
start:
		jmp l2CDC

start2:
		lda cpu_port
		and #$fe
		sta cpu_port
		jmp lA003

; jumped to by: start
l2CDC:
		lda cpu_port
		and #$fe
		sta cpu_port
		jmp lA000

; read by: lA95B
a2CE5:
		.addr	setup_hole
; read by: lA95E
a2CE7:		.addr	check_landing
; read by: lA961
a2CE9:		.addr	color_text
; read by: lA964
a2CEB:		.addr	l378C
; read by: lA967
a2CED:		.addr	get_key
; read by: $b65d
a2CEF:		.addr	check_terrain

; called by: swing, check_landing
draw_golfer:
		pha 
		lda sprites + $3f
		sta sprites + $7f
		bne l2D04
		txa 
		sec 
		sbc #$33
		tax 
		lda #$05
		sta sprites + $3f
; jumped to by: draw_golfer
l2D04:
		ldy #$91
		stx golfer_x
		sty golfer_y
		lda #$e0
		and sprites_x_msb
		sta sprites_x_msb
		lda current_player
		beq l2D1B
		lda #$08
; jumped to by: draw_golfer
l2D1B:
		jsr set_golfer_colors
		jmp l2D3E

; called by: draw_golfer, $3793
set_golfer_colors:
		ldx raster
		cpx #$14
		bcc set_golfer_colors
		cpx #$32
		bcs set_golfer_colors
		ldy #$ff
		and #$08
		tax 
; jumped to by: set_golfer_colors
l2D31:
		lda golfer_colors, x
		iny 
		sta sprite0_color, y
		inx 
		cpy #$07
		bcc l2D31
		rts 

; jumped to by: draw_golfer
l2D3E:
		pla 
		sta power_level
		lda #$17
		ldx #$34
		jsr load_animation
		lda #$00
		ldx #$59
		ldy power_level
		dey 
		jsr draw_animation_frame
		lda sprites + $7f
		bne l2D61
		jsr mirror_golfer
		lda #$05
		sta sprites + $3f
; jumped to by: set_golfer_colors
l2D61:
		rts 

; shifts A right one bit, keeping its sign
; jumped to by: l2F9B
shift_right_signed:
		asl 
		php 
		asl 
		plp 
		ror 
		rts 

; called by: $2e26, $2e7a, $32c2
raise_meter:
		ldy power_level
		cpy #$10
		bcs l2D76
		iny 
		sty power_level
		jsr l2F60
; jumped to by: raise_meter
l2D76:
		dey 
		lda #$00
		ldx #$59
		jmp draw_animation_frame

; called by: $2dd0
lower_meter:
		ldy power_level
		cpy #$02
		bcc l2D89
		dey 
		sty power_level
; jumped to by: lower_meter
l2D89:
		dey 
		lda #$00
		ldx #$59
		jmp draw_animation_frame

unused_2d91:
		.byte	$60

; jumped to by: $31eb
swing:
		jsr get_key
		ldx golfer_x
		lda #$0a
		jsr draw_golfer
		jsr l32B3
		jsr compute_shot
		jsr message_line
		jsr print_inline

text_swing_club:
		.text	"SWING CLUB", $ff

; jumped to by: $2db9
l2DB4:
		jsr get_key
		cmp #$2a
		bne l2DB4
		lda #$00
		sta v045e
		lda #$04
		sta frame_timer_reload
		sta frame_timer
; jumped to by: $2de5, $2dec
l2DC8:
		inc v045e
		lda frame_timer
		bne l2DE0
		jsr lower_meter
		lda frame_timer_reload
		sta frame_timer
		lda power_level
		cmp #$01
		beq l2DEE
; jumped to by: $2dce
l2DE0:
		jsr get_key
		cmp #$2a
		beq l2DC8
		lda power_level
		cmp #$0a
		bcs l2DC8
; jumped to by: $2dde
l2DEE:
		lda #$00
		sta v045f
		lda #$00
		sta v0460
; jumped to by: $2e05
l2DF8:
		inc v045f
		bne l2E00
		inc v0460
; jumped to by: $2dfb
l2E00:
		jsr get_key
		cmp #$29
		bne l2DF8
		lda #$00
		sta v0463
		lda #$03
		sta frame_timer_reload
		sta frame_timer
		jsr swing_sound
; jumped to by: $2e49
l2E17:
		jsr get_key
		cmp #$29
		bne l2E21
		inc v0463
; jumped to by: $2e1c
l2E21:
		lda frame_timer
		bne l2E49
		jsr raise_meter
		lda power_level
		cmp #$0a
		beq l2E4C
		lda frame_timer_reload
		cmp #$01
		beq l2E43
		lda v0463
		lsr 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc #$05
; jumped to by: $2e35
l2E43:
		sta frame_timer
		sta frame_timer_reload
; jumped to by: $2e24
l2E49:
		jmp l2E17

; jumped to by: $2e2e
l2E4C:
		jsr click_sound
		jsr message_line
		jsr print_inline
		.byte	$ff
		lda #$ff
		sta v3294
		lda v045f
		lsr 
		sta v0461
		jsr l3293
		jsr l34C1
		lda frame_timer_reload
		sta frame_timer
		asl 
		sta frame_timer_reload
; jumped to by: $2e78, $2e8c
l2E72:
		jsr get_key
		lda frame_timer
		bne l2E72
		jsr raise_meter
		lda frame_timer_reload
		sta frame_timer
		lda v045f
		sec 
		sbc #$0e
		sta v045f
		bcs l2E72
		jsr l2F5A
; jumped to by: $2e97
l2E91:
		jsr get_key
		lda v3294
		bne l2E91
		lda #$0a
		sta frame_delay
		lda #$02
		sta anim_frame_count
		ldy #$10
		jsr play_animation
		lda hole_distance
		beq l2EBC
		lda green_view
		bne l2EB3
		beq l2ED2
; jumped to by: $2eaf
l2EB3:
		jsr l32AD
		beq l2ED2
		lda #$00
		sta hole_distance
; jumped to by: $2eaa
l2EBC:
		jsr l434E
		lda #$3f
		sta sprite_enable
		jsr message_line
		jsr print_inline

text_down:
		.text	"DOWN !!", $ff

; jumped to by: $2eb1, $2eb6, $2ed7
l2ED2:
		jsr get_key
		cmp #$3c
		bne l2ED2
		jsr l434B
		jmp silence_voices

; jumped to by: $2edc
silence_voices:
		lda #$00
		sta voice1_control
		sta voice2_control
		sta voice3_control
		jmp l2FB1

; waits a frame and returns the key or joystick direction
; called by: swing, $2db4, $2de0, $2e00, $2e17, $2e72, $2e91, $2ed2, wait_16_frames, play_animation, select_club
get_key:
		txa 
		pha 
; jumped to by: get_key
l2EEF:
		lda raster
		bmi l2EEF
		jsr scnkey
; where the CPU was when the snapshot was taken
snapshot_pc:
		lda raster
		cmp #$c8
		bcc snapshot_pc
		dec frame_timer
		lda v3294
		beq l2F09
		jsr l3EF4
; jumped to by: snapshot_pc
l2F09:
		pla 
		tax 
		lda kernal_lstx
		jsr l32B0
		rts 

; read by: set_golfer_colors
golfer_colors:
		.byte	$09, $01, $02, $02, $00, $00, $01, $01, $00, $01, $01, $01, $09, $09, $01, $01

; called by: $2e14, play_animation
swing_sound:
		lda #$00
		sta voice1_control
		sta voice2_control
		lda #$2f
		sta volume_filter_mode
		lda #$0b
		sta voice1_attack_decay
		lda #$07
		sta voice1_sustain_release
		lda #$03
		sta voice2_attack_decay
		sta voice2_sustain_release
		lda #$1e
		sta voice1_frequency + $1
		lda #$46
		sta voice2_frequency + $1
		lda #$01
		sta filter_control
		lda #$00
		sta swing_cutoff
		lda #$81
		sta voice1_control
		rts 

; called by: $2e8e
l2F5A:
		lda #$80
		sta voice1_control
		rts 

; called by: raise_meter
l2F60:
		lda swing_cutoff
		clc 
		adc #$0d
		sta swing_cutoff
		sta filter_cutoff + $1
		rts 

; called by: $2e4c, play_animation, l3EF4
click_sound:
		ldx #$81
		stx voice2_control
		dex 
		stx voice2_control
		rts 

; read by: l2F60
; written by: swing_sound, l2F60
swing_cutoff:
		.byte	$42

; called by: $3154
l2F78:
		rts 

; called by: play_animation
l2F79:
		lda #$00
		sta voice1_attack_decay
		lda #$80
		sta voice1_sustain_release
		lda #$2f
		sta volume_filter_mode
		lda #$01
		sta filter_control
		lda #$50
		sta voice1_frequency + $1
		sta filter_cutoff + $1
		lda #$81
		sta voice1_control
		rts 

; called by: play_animation
l2F9B:
		lda #$80
		sta voice1_control
		rts 

; unreferenced
		ldy sprites + $3f
		bne l2FAB
		clc 
		eor #$ff
		adc #$01
; jumped to by: l2F9B
l2FAB:
		jmp shift_right_signed

unused_2fae:
		.byte	$79, $fe, $3d

; jumped to by: silence_voices
l2FB1:
		ldx #$00
		lda game_mode
		and #$01
		php 
		lda hole_distance
		plp 
		beq l2FCA
		lda current_player
		bne l2FC5
		ldx #$0a
; jumped to by: $2fc1
l2FC5:
		lda v0443, x
		ora hole_distance
; jumped to by: $2fbc
l2FCA:
		cmp #$40
		bcs l2FD4
		jsr l31FC
		jmp l3011

; jumped to by: $2fcc
l2FD4:
		lda sprites + $3f
		bne l2FDC
		jsr mirror_golfer
; jumped to by: $2fd7
l2FDC:
		lda #$0a
		sta frame_delay
		lda #$02
		sta anim_frame_count
		ldy #$12
		jsr play_animation
		lda #$03
		jsr l3027
		jsr wait_16_frames
		lda #$0a
		sta frame_delay
		lda #$02
		sta anim_frame_count
		ldy #$21
		jsr play_animation
		lda #$02
		sta anim_frame_count
		lda #$0a
		sta frame_delay
		ldy #$24
		jsr play_animation
; jumped to by: $2fd1
l3011:
		lda #$00
		sta sprite6_y
		sta sprite7_y
		sta sprites_x_msb
		rts 

; called by: $31e8
l301D:
		lda sprites + $3f
		beq l3025
		jsr mirror_golfer
; jumped to by: l301D
l3025:
		lda #$03
; called by: $2fed
l3027:
		pha 
		lda #$05
		sta frame_delay
		lda #$0c
		sta anim_frame_count
		ldy #$14
		jsr play_animation
		pla 
		lsr 
		bne l3027
		rts 

; called by: set_golfer_colors, $2fd9, l301D, check_landing, $31cd
mirror_golfer:
		ldx #$2f
; jumped to by: mirror_golfer
l303E:
		jsr mirror_sprite
		inx 
		cpx #$37
		bcc l303E
		ldx #$4d
; jumped to by: mirror_golfer
l3048:
		jsr mirror_sprite
		inx 
		cpx #$57
		bcc l3048
		ldx #$25
		jsr mirror_sprite
		lda sprites + $3f
		eor #$05
		sta sprites + $3f
		rts 

; called by: mirror_golfer
mirror_sprite:
		lda #$00
		sta pointer_61
		txa 
		pha 
		lsr 
		ror pointer_61
		lsr 
		ror pointer_61
		ora #$40
		sta pointer_61 + $1
		ldy #$3f
		lda (pointer_61), y
		sta sprite_mode
		ldy #$00
; jumped to by: mirror_sprite
l3077:
		jsr reverse_bits
		pha 
		iny 
		jsr reverse_bits
		sta (pointer_61), y
		iny 
		jsr reverse_bits
		dey 
		dey 
		sta (pointer_61), y
		iny 
		iny 
		pla 
		sta (pointer_61), y
		iny 
		cpy #$3f
		bcc l3077
		pla 
		tax 
		rts 

; called by: mirror_sprite
reverse_bits:
		lda (pointer_61), y
		sta v63
		ldx #$08
; jumped to by: reverse_bits
l309C:
		lsr v63
		php 
		bit sprite_mode
		bpl l30A8
		lsr v63
		rol 
		dex 
; jumped to by: reverse_bits
l30A8:
		plp 
		rol 
		dex 
		bne l309C
		rts 

; read by: reverse_bits
; written by: mirror_sprite
sprite_mode:
		.byte	$3a

check_landing:
		lda sprites + $3f
		bne l30B7
		jsr mirror_golfer
; jumped to by: check_landing
l30B7:
		lda #$fd
		sta sprite7_y
		lda #$00
		sta v3294
		lda green_view
		bne l30CD
		ldx #$32
		lda #$26
		jsr draw_golfer
; jumped to by: check_landing
l30CD:
		lda #$ff
		sta sprite_enable
		jsr check_terrain
		bne check_out_of_bounds
		jsr message_line
		jsr print_inline

text_in_the_water:
		.text	"IN THE WATER", $ff

; jumped to by: $314c
l30EA:
		jsr l434B
		jsr l434E
		jsr l4345
		lda current_player
		and #$01
		asl 
		tax 
		lda safe_ball_x, x
		sta @w ball_x
		lda safe_ball_x + $1, x
		sta @w ball_x + $1
		lda safe_ball_y, x
		sta @w ball_y
		lda safe_ball_y + $1, x
		sta @w ball_y + $1
		rts 

; jumped to by: check_landing
check_out_of_bounds:
		lda green_view
		bne l314F
		lda @w ball_x + $1
		beq l3128
		cmp #$02
		bcs l3138
		lda @w ball_x
		cmp #$c0
		bcs l3138
; jumped to by: check_out_of_bounds
l3128:
		lda @w ball_y + $1
		beq l314F
		cmp #$02
		bcs l3138
		lda @w ball_y
		cmp #$c0
		bcc l314F
; jumped to by: check_out_of_bounds
l3138:
		jsr message_line
		jsr print_inline

text_out_of_bounds:
		.text	"OUT OF BOUNDS", $ff
		jmp l30EA

; jumped to by: check_out_of_bounds
l314F:
		lda #$00
		sta v32bc
		jsr l2F78
		lda #$ff
		sta sprite_enable
		lda #$01
		sta v32bc
		jsr message_line
		jsr print_inline

text_select_club:
		.text	"SELECT CLUB", $ff
		lda terrain_type
		ldx #$00
		cmp #$09
		bne l3181
		jsr l32B9
		ldx #$0c
; jumped to by: $317a
l3181:
		cmp #$06
		bne l3187
		ldx #$0b
; jumped to by: $3183
l3187:
		lda green_view
		beq l3197
		ldx #$0d
		stx club
		jsr select_club
		jmp l31EB

; jumped to by: $318a
l3197:
		stx club
		jsr l3202
		jsr select_club
		jsr wait_16_frames
		jsr message_line
		jsr print_inline
		.byte	$ff
		lda #$04
		sta anim_frame_count
		lda #$0a
		sta frame_delay
		ldy #$25
		jsr play_animation
		lda #$0a
		sta frame_delay
		lda #$04
		sta anim_frame_count
		ldy #$29
		jsr play_animation
		lda sprites + $3f
		beq l31D9
		jsr mirror_golfer
		lda golfer_x
		clc 
		adc #$2d
		sta golfer_x
; jumped to by: $31cb
l31D9:
		lda #$02
		sta anim_frame_count
		lda #$0a
		sta frame_delay
		ldy #$12
		jsr play_animation
		jsr l301D
; jumped to by: $3194
l31EB:
		jmp swing

; called by: $2ff0, $31a0
wait_16_frames:
		ldx #$10
; jumped to by: wait_16_frames
l31F0:
		jsr get_key
		dex 
		bne l31F0
		rts 

		rts 

unused_31f8:
		.byte	$60, $4c, $3c, $30

; called by: $2fce
l31FC:
		lda #$00
		sta v0477
		rts 

; called by: $319a
l3202:
		lda #$ff
		sta v0477
		rts 

unused_3208:
		.byte	$00

; called by: check_landing
check_terrain:
		lda green_view
		bne l321D
		lda #$21
		sta sprite_pointers + $6
		lda #$bb
		sta sprite6_x
		lda #$ad
		sta sprite6_y
; jumped to by: check_terrain
l321D:
		lda sprite_enable
		ora #$40
		sta sprite_enable
		ldx #$04
; jumped to by: check_terrain
l3227:
		lda bitmap + $14aa, x
		sta buffer_328e, x
		dex 
		bne l3227
		ldx #$a8
		ldy #$15
		lda bitmap + $14ab, x
		jsr l3253
		sta v327d
		ldy #$00
		lda buffer_328e + $2
		jsr l3253
		beq l324F
		lda v327d
		bne l324F
		jmp l32B6

; jumped to by: check_terrain
l324F:
		lda terrain_type
		rts 

; called by: check_terrain
l3253:
		and #$0c
		lsr 
		tax 
		lda pointers_3275, x
		sta pointer_61
		lda pointers_3275 + $1, x
		sta pointer_61 + $1
		lda (pointer_61), y
		cpx #$02
		bne l326B
		lsr 
		lsr 
		lsr 
		lsr 
; jumped to by: l3253
l326B:
		and #$0f
		tax 
		lda table_327e, x
		sta terrain_type
		rts 

; read by: l3253
pointers_3275:
		.addr	buffer_328e, bitmap_colors + $295, bitmap_colors + $295, color_ram + $295

; read by: check_terrain
; written by: check_terrain
v327d:
		.byte	$0a
; read by: l3253
table_327e:
		.byte	$08, $08, $08, $08, $08, $09, $00, $06, $08, $08, $08, $08, $07, $0a, $00, $08
; read by: check_terrain
; written by: check_terrain
buffer_328e:
		.byte	$01, $aa, $aa, $aa, $aa

; called by: $2e62
l3293:
		rts 

; read by: $2e94, snapshot_pc
; written by: $2e58, check_landing, l3EF4
v3294:
		.byte	$00

; called by: swing, $2e4f, $2ec4, check_landing, check_out_of_bounds, $3161, $31a3
message_line:
		lda #$00
		sta @w text_x
		lda #$07
		sta @w text_y
		lda @w text_x
		clc 
		adc #$04
		sta @w text_x
		lda #$0d
		jmp color_text

; called by: $2eb3
l32AD:
		jmp (aA010)

; called by: snapshot_pc
l32B0:
		jmp (aA012)

; called by: swing
l32B3:
		jmp (aA018)

; jumped to by: check_terrain
l32B6:
		jmp (aA01A)

; called by: $317c
l32B9:
		jmp (aA01C)

; written by: $3151, $315e
v32bc:
		.byte	$01

; unreferenced
		lda #$00
		sta anim_sprite_flags + $8
; jumped to by: $32c8
l32C2:
		jsr raise_meter
		jsr wait_frames
		jmp l32C2

; called by: $32c5, play_animation
wait_frames:
		ldx frame_delay
; jumped to by: wait_frames
l32CE:
		lda raster
		bpl l32CE
; jumped to by: wait_frames
l32D3:
		lda raster
		bmi l32D3
		dex 
		bne l32CE
		rts 

; read by: wait_frames
; written by: $2e9b, $2fde, $2ff5, $3009, l3027, $31b1, $31bb, $31e0
frame_delay:
		.byte	$7e

; called by: set_golfer_colors
load_animation:
		stx pointer_fd + $1
		sta pointer_fd
		ldy #$00
		lda (pointer_fd), y
		iny 
		sta anim_sprite_count
		lda (pointer_fd), y
		iny 
		sta anim_pointer_base
		tya 
		clc 
		adc pointer_fd
		sta pointer_fd
		lda pointer_fd + $1
		adc #$00
		sta pointer_fd + $1
		ldy #$00
		jsr l33C0
; jumped to by: load_animation
l3300:
		lda (pointer_fd), y
		sta anim_sprite_flags, y
		sta v3368
		and #$07
		tax 
		lda bit_values, x
		sta v3369
		lda v3369
		asl v3368
		bcs l3323
		eor #$ff
		and sprite_multicolor
		sta sprite_multicolor
		lda #$00
; jumped to by: load_animation
l3323:
		ora sprite_multicolor
		sta sprite_multicolor
		lda v3369
		asl v3368
		bcs l333B
		eor #$ff
		and sprite_expand_y
		sta sprite_expand_y
		lda #$00
; jumped to by: load_animation
l333B:
		ora sprite_expand_y
		sta sprite_expand_y
		lda v3369
		asl v3368
		bcs l3353
		eor #$ff
		and sprite_expand_x
		sta sprite_expand_x
		lda #$00
; jumped to by: load_animation
l3353:
		ora sprite_expand_x
		sta sprite_expand_x
		iny 
		cpy anim_sprite_count
		bcc l3300
		rts 

; read by: load_animation
bit_values:
		.byte	$01, $02, $04, $08, $10, $20, $40, $80
; written by: load_animation
; modified by: load_animation
v3368:		.byte	$28
; read by: load_animation
; written by: load_animation
v3369:		.byte	$20
; read by: l33C0
; written by: load_animation
anim_pointer_base:		.byte	$25
; read by: load_animation, draw_animation_frame, l33C0
; written by: load_animation
anim_sprite_count:		.byte	$06
; read by: l33C0
; written by: $32bf, load_animation
anim_sprite_flags:
		.byte	$41, $42, $43, $80, $44, $45, $04, $77, $23

; called by: set_golfer_colors, play_animation
; jumped to by: raise_meter, lower_meter
draw_animation_frame:
		stx pointer_fd + $1
		sta pointer_fd
		lda anim_sprite_count
		clc 
		adc anim_sprite_count
		adc anim_sprite_count
		adc #$01
; jumped to by: draw_animation_frame
l3385:
		cpy #$00
		beq l3399
		dey 
		pha 
		clc 
		adc pointer_fd
		sta pointer_fd
		lda pointer_fd + $1
		adc #$00
		sta pointer_fd + $1
		pla 
		bne l3385
; jumped to by: draw_animation_frame
l3399:
		ldx #$00
		lda (pointer_fd), y
		iny 
		cmp #$80
		bne l33A5
		ora #$00
		rts 

; jumped to by: draw_animation_frame
l33A5:
		pha 
		lda sprites + $3f
		bne l33B2
		pla 
		clc 
		eor #$ff
		adc #$01
		pha 
; jumped to by: draw_animation_frame
l33B2:
		pla 
		clc 
		adc golfer_x
		sta golfer_x
		jsr l33C0
		jmp l33CC

; called by: load_animation, draw_animation_frame
l33C0:
		lda raster
		cmp #$1e
		bcc l33C0
		cmp #$32
		bcs l33C0
		rts 

; jumped to by: draw_animation_frame, l33C0
l33CC:
		txa 
		pha 
		lda anim_sprite_flags, x
		and #$07
		asl 
		tax 
		lda (pointer_fd), y
		iny 
		pha 
		lda sprites + $3f
		bne l33E5
		pla 
		clc 
		eor #$ff
		adc #$01
		pha 
; jumped to by: l33C0
l33E5:
		pla 
		clc 
		adc golfer_x
		sta sprite0_x, x
		lda (pointer_fd), y
		iny 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc golfer_y
		sta sprite0_y, x
		txa 
		lsr 
		tax 
		lda (pointer_fd), y
		iny 
		clc 
		adc anim_pointer_base
		sta sprite_pointers, x
		pla 
		tax 
		inx 
		cpx anim_sprite_count
		bcs l3414
		jmp l33CC

; jumped to by: l33C0
l3414:
		lda #$00
		rts 

; an older copy of the start of buffer_336c
unused_3417:
		.byte	$06, $25, $41, $42, $43, $80, $44, $45

; called by: $2ea5, $2fe8, $2fff, $300e, l3027, $31b6, $31c5, $31e5
play_animation:
		tya 
		pha 
		lda #$00
		ldx #$59
		jsr draw_animation_frame
		jsr wait_frames
		pla 
		tay 
		cpy #$17
		beq l3435
		cpy #$1d
		bne l3447
; jumped to by: play_animation
l3435:
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		jsr l2F79
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		jmp l3469

; jumped to by: play_animation
l3447:
		cpy #$22
		bne l3466
		jsr swing_sound
		jsr click_sound
		jsr get_key
		jsr get_key
		jsr get_key
		jsr click_sound
		jsr get_key
		jsr get_key
		jsr get_key
; jumped to by: play_animation
l3466:
		jsr l2F9B
; jumped to by: play_animation
l3469:
		iny 
		dec anim_frame_count
		bne play_animation
		rts 

; written by: $2ea0, $2fe3, $2ffa, $3004, l3027, $31ac, $31c0, $31db
; modified by: play_animation
anim_frame_count:
		.byte	$44
; read by: compute_shot
club_power:
		.byte	$c0, $b0, $a0, $90, $80, $e8, $d8, $c8, $b8, $a8, $90, $87, $c8, $c8

; called by: swing
compute_shot:
		ldx terrain_type
		lda #$00
		jsr to_log
		sta log_value
		stx log_value + $1
		lda v0458
		clc 
		adc #$5b
		tax 
		lda #$00
		jsr to_log
		jsr log_multiply
		lda #$bd
		ldx #$74
		jsr to_log
		inx 
		jsr log_divide
		ldx club
		lda club_power, x
		tax 
		lda #$00
		jsr to_log
		jsr log_multiply
		lda log_value
		sta v377c
		lda log_value + $1
		sta v377d
		jmp l36E6

; called by: $2e65
l34C1:
		lda v377c
		sta log_value
		lda v377d
		sta log_value + $1
		lda v0463
		asl 
		asl 
		clc 
		adc v045e
		tax 
		lda #$00
		jsr to_log
		sta v3599
		stx v359a
		jsr log_multiply
		lda log_value
		ldx log_value + $1
		jsr from_log
		txa 
		sta shot_speed
		lda v3599
		ldx v359a
		jsr log_multiply
		lda v045e
		sec 
		sbc v0461
		clc 
		adc v0457
		clc 
		adc v0457
		beq l354B
		php 
		bpl l3510
		clc 
		eor #$ff
		adc #$01
; jumped to by: l34C1
l3510:
		cmp #$26
		bcc l3516
		lda #$25
; jumped to by: l34C1
l3516:
		tax 
		lda #$00
		jsr to_log
		jsr log_multiply
		lda #$29
		ldx #$ae
		jsr to_log
		jsr log_divide
		lda log_value
		ldx log_value + $1
		jsr from_log
		txa 
		clc 
		eor #$ff
		adc #$01
		sta shot_sideways
		clc 
		adc shot_speed
		sta shot_speed
		lda shot_sideways
		plp 
		bmi l354B
		clc 
		eor #$ff
		adc #$01
; jumped to by: l34C1
l354B:
		sta shot_sideways
		ldx #$01
		lda club
		cmp #$05
		bcc l3562
		cmp #$0d
		beq l3562
		inx 
		cmp #$0c
		bne l3562
		inx 
		inx 
; jumped to by: l34C1
l3562:
		lda shot_speed
		jsr l3589
		sta shot_speed
		lda shot_sideways
		jsr l357A
		sta shot_sideways
		jsr l3711
		jmp ball_flight

; called by: l34C1
l357A:
		stx v3594
; jumped to by: l357A
l357D:
		asl 
		php 
		ror 
		plp 
		ror 
		dex 
		bne l357D
		ldx v3594
		rts 

; called by: l34C1
l3589:
		stx v3594
; jumped to by: l3589
l358C:
		lsr 
		dex 
		bne l358C
		ldx v3594
		rts 

; read by: l357A, l3589
; written by: l357A, l3589
v3594:
		.byte	$4c
; read by: l34C1, l3711, l3E04, l3EF4, l423D
; written by: l34C1, l3711, l3EF4
shot_speed:		.byte	$00
; read by: l34C1, l3711, ball_flight, l3EF4, l423D
; written by: l34C1, l3711, l3EF4
shot_sideways:		.byte	$00
; read by: compute_shot, l34C1, select_club, l382B, print_club_name, $3d69, l3EF4, l4210
; written by: $318e, $3197
; modified by: l382B
club:		.byte	$00
; read by: $3173, check_terrain, compute_shot
; written by: l3253
terrain_type:		.byte	$0a
; read by: l34C1
; written by: l34C1
v3599:		.byte	$41
; read by: l34C1
; written by: l34C1
v359a:		.byte	$43
; old text "ROS" under the variables
unused_359b:
		.byte	$52, $4f
; read by: l35BC, l3EF4, l423D
; written by: l35BC, ball_flight, l3EF4, l423D
v359d:		.byte	$53
; read by: l3D9F, l3EF4, l423D
; written by: ball_flight, l3EF4, l423D
; modified by: l3EF4
v359e:		.byte	$20
; read by: l35BC, l3EF4, l423D
; written by: l35BC, ball_flight, l3EF4, l423D
v359f:		.byte	$4d
; read by: l3D9F, l3EF4, l423D
; written by: ball_flight, l3EF4, l423D
v35a0:		.byte	$41

; called by: l35BC
l35A1:
		bpl l35A8
		clc 
		eor #$ff
		adc #$01
; jumped to by: l35A1
l35A8:
		tax 
		lda #$00
		jsr to_log
		sta log_value
		stx log_value + $1
		jsr log_multiply
		lda log_value
		ldx log_value + $1
		jmp from_log

; called by: l369A
l35BC:
		pha 
		jsr l366E
		stx v359d
		sty v359f
		stx v378a
		sty v378b
		pla 
		jsr l35A1
		sta v3785
		stx v3784
		lda #$00
		sta v3788
		sta v3789
; jumped to by: l35BC
l35DE:
		lda v359d
		bmi l35F5
		clc 
		adc v378a
		sta v378a
		lda #$00
		adc v3788
		sta v3788
		jmp l3604

; jumped to by: l35BC
l35F5:
		clc 
		adc v378a
		sta v378a
		lda v3788
		sbc #$00
		sta v3788
; jumped to by: l35BC
l3604:
		lda v359f
		bmi l361B
		clc 
		adc v378b
		sta v378b
		lda #$00
		adc v3789
		sta v3789
		jmp l362A

; jumped to by: l35BC
l361B:
		clc 
		adc v378b
		sta v378b
		lda v3789
		sbc #$00
		sta v3789
; jumped to by: l35BC
l362A:
		lda v3788
		jsr l35A1
		sta v3787
		stx v3786
		lda v3789
		jsr l35A1
		pha 
		txa 
		clc 
		adc v3786
		sta v3786
		pla 
		adc v3787
		sta v3787
		lda v3787
		cmp v3785
		bcs l3657
		jmp l35DE

; jumped to by: l35BC
l3657:
		beq l365C
		jmp l3667

; jumped to by: l35BC
l365C:
		lda v3786
		cmp v3784
		bcs l3667
		jmp l35DE

; jumped to by: l35BC
l3667:
		ldx v3788
		ldy v3789
		rts 

; called by: l35BC
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

; called by: l366E
l368B:
		asl 
		bcs l3693
		asl 
		bcs l3698
		bcc l3696
; jumped to by: l368B
l3693:
		asl 
		bcc l3698
; jumped to by: l368B
l3696:
		clc 
		rts 

; jumped to by: l368B
l3698:
		sec 
; jumped to by: l366E
l3699:
		rts 

; called by: l36E6, l3711
l369A:
		lda v3780
		ldx v377e
		ldy v377f
		jsr l35BC
		stx v3782
		sty v3783
		ldx v377f
		lda v377e
		clc 
		eor #$ff
		adc #$01
		tay 
		lda v3781
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
; jumped to by: l369A
l36D2:
		jsr l35BC
		txa 
		clc 
		adc v3782
		sta v3782
		tya 
		clc 
		adc v3783
		sta v3783
		rts 

; called by: l3EF4
; jumped to by: compute_shot
l36E6:
		lda direction
		tax 
		lda steps_x, x
		sta v377e
		lda steps_y, x
		sta v377f
		lda #$58
		sta v3780
		lda aim_offset
		sta v3781
		jsr l369A
		lda v3782
		sta v377e
		lda v3783
		sta v377f
		rts 

; called by: l34C1, l3EF4
l3711:
		lda shot_speed
		sta v3780
		lda shot_sideways
		sta v3781
		jsr l369A
		lda @w ball_x
		sta point_x
		lda @w ball_x + $1
		sta point_x + $1
		lda @w ball_y
		sta point_y
		lda @w ball_y + $1
		sta point_y + $1
		lda v3782
		bmi l3747
		clc 
		adc point_x
		sta point_x
		lda #$00
		adc point_x + $1
		sta point_x + $1
		jmp l3750

; jumped to by: l3711
l3747:
		clc 
		adc point_x
		sta point_x
		bcs l3750
		dec point_x + $1
; jumped to by: l3711
l3750:
		lda v3783
		bmi l3763
		clc 
		adc point_y
		sta point_y
		lda #$00
		adc point_y + $1
		sta point_y + $1
		jmp l376C

; jumped to by: l3711
l3763:
		clc 
		adc point_y
		sta point_y
		bcs l376C
		dec point_y + $1
; jumped to by: l3711
l376C:
		jsr to_view
		lda view_x
		sta shot_sideways
		lda view_y
		sta shot_speed
		rts 

; read by: l34C1
; written by: compute_shot
v377c:
		.byte	$00
; read by: l34C1
; written by: compute_shot
v377d:		.byte	$01
; read by: l369A
; written by: l36E6
v377e:		.byte	$50
; read by: l369A
; written by: l36E6
v377f:		.byte	$20
; read by: l369A
; written by: l36E6, l3711
v3780:		.byte	$08
; read by: l369A
; written by: l36E6, l3711
v3781:		.byte	$00
; read by: l369A, l36E6, l3711, l3EF4
; written by: l369A
v3782:		.byte	$20
; read by: l369A, l36E6, l3711, l3EF4
; written by: l369A
v3783:		.byte	$8e
; read by: l35BC
; written by: l35BC
v3784:		.byte	$49
; read by: l35BC
; written by: l35BC
v3785:		.byte	$00
; read by: l35BC
; written by: l35BC
v3786:		.byte	$00
; read by: l35BC
; written by: l35BC
v3787:		.byte	$00
; read by: l35BC
; written by: l35BC
v3788:		.byte	$00
; read by: l35BC
; written by: l35BC
v3789:		.byte	$01
; read by: l35BC
; written by: l35BC
v378a:		.byte	$50
; read by: l35BC
; written by: l35BC
v378b:		.byte	$20

l378C:
		lda current_player
		beq l3793
		lda #$08
; jumped to by: $378f
l3793:
		jsr set_golfer_colors
		lda hole_distance
		bne l379D
		jsr l382B
; jumped to by: $3798
l379D:
		jsr face_hole
		jsr l3AB8
		jsr l3AC4
		lda @w ball_x + $1
		pha 
		lda @w ball_x
		pha 
		lda @w ball_y + $1
		pha 
		lda @w ball_y
		pha 
		lda hole_x
		sta @w ball_x
		lda hole_x + $1
		sta @w ball_x + $1
		lda hole_y
		sta @w ball_y
		lda hole_y + $1
		sta @w ball_y + $1
		jsr l3AC4
		jsr l3AC4
		lda @w ball_y
		sta v046e
		lda @w ball_y + $1
		sta v046f
		lda @w ball_x
		sta v046c
		lda @w ball_x + $1
		sta v046d
		pla 
		sta @w ball_y
		pla 
		sta @w ball_y + $1
		pla 
		sta @w ball_x
		pla 
		sta @w ball_x + $1
		jmp l3AB8

; called by: $3191, $319d
select_club:
		jsr print_club_name
		lda club
		beq l3808
		rts 

; jumped to by: select_club, l382B
l3808:
		jsr print_club_name
; jumped to by: select_club
l380B:
		ldx #$0a
; jumped to by: select_club
l380D:
		jsr get_key
		cmp #$03
		bne l3819
		jsr l4351
		ldx #$01
; jumped to by: select_club
l3819:
		dex 
		bne l380D
		cmp #$29
		beq l385B
		cmp #$2a
		beq l386A
		cmp #$3c
		bne l380B
		jmp l434B

; called by: $379a
l382B:
		tax 
		pla 
		pla 
		cpx #$22
		bne l3835
		jmp turn_left

; jumped to by: l382B
l3835:
		cpx #$25
		bne l383C
		jmp turn_right

; jumped to by: l382B
l383C:
		cpx #$01
		bne l3843
		jmp l3B45

; jumped to by: l382B
l3843:
		rts 

; unreferenced
		lda par
		jsr l4348
		ldx hole_number
		inx 
		cpx #$13
		bne l3854
		ldx #$01
; jumped to by: l382B
l3854:
		stx hole_number
		txa 
		jmp setup_hole

; jumped to by: select_club, l382B
l385B:
		jsr l434E
		inc club
		lda club
		cmp #$0d
		beq l386A
		bne l3808
; jumped to by: select_club, l382B
l386A:
		jsr l434E
		dec club
		lda club
		cmp #$ff
		beq l385B
		bne l3808
; called by: select_club
print_club_name:
		lda #$50
		sta text_x
		lda #$17
		sta text_y
		lda #$02
		jsr color_text
		lda club
		asl 
		pha 
		tax 
		lda club_names, x
		jsr print_char
		pla 
		tax 
		lda club_names + $1, x
		jmp print_char

; two letters per club: 1W 3W 1I 3I ... 9I PW SW PT
; read by: print_club_name
club_names:
		.text	"1W3W1I3I4I5I6I7I8I9IPWSWPTPT"

; called by: $379d
face_hole:
		lda #$00
		sta v3982
		lda hole_y
		sec 
		sbc @w ball_y
		sta v0454
		lda hole_y + $1
		sbc @w ball_y + $1
		sta v0455
		asl 
		php 
		rol v3982
		plp 
		bpl l38E7
		lda #$00
		sec 
		sbc v0454
		sta v0454
		lda #$00
		sbc v0455
		sta v0455
; jumped to by: face_hole
l38E7:
		lda hole_x
		sec 
		sbc @w ball_x
		sta v0452
		lda hole_x + $1
		sbc @w ball_x + $1
		sta v0453
		asl 
		php 
		rol v3982
		plp 
		bpl l3913
		lda #$00
		sec 
		sbc v0452
		sta v0452
		lda #$00
		sbc v0453
		sta v0453
; jumped to by: face_hole
l3913:
		jsr l3956
		php 
		rol v3982
		ldx v3982
		lda octant_directions, x
		sta v3982
		plp 
		bcc l3929
		jsr l3965
; jumped to by: face_hole
l3929:
		asl v0452
		rol v0453
		jsr l3956
		bcc l393E
		lda v3982
		ora #$01
		sta v3982
		bne l3950
; jumped to by: face_hole
l393E:
		lda v3982
		and #$01
		beq l3950
		lda v3982
		clc 
		adc #$01
		and #$07
		sta v3982
; jumped to by: face_hole
l3950:
		lda v3982
		jmp set_direction

; called by: face_hole
l3956:
		lda v0453
		cmp v0455
		bne l3964
		lda v0452
		cmp v0454
; jumped to by: l3956
l3964:
		rts 

; called by: face_hole
l3965:
		lda v0452
		pha 
		lda v0454
		sta v0452
		pla 
		sta v0454
		lda v0453
		pha 
		lda v0455
		sta v0453
		pla 
		sta v0455
		rts 

; read by: face_hole
; written by: face_hole
; modified by: face_hole
v3982:
		.byte	$00
; read by: face_hole
octant_directions:
		.byte	$00, $01, $07, $06, $03, $02, $04, $05

; jumped to by: l382B
setup_hole:
		sta hole_number
		asl 
		asl 
		adc hole_number
		adc hole_number
		sec 
		sbc #$06
		sta digit_text_index
		lda #$30
		sta text_x
		lda #$1f
		sta text_y
		lda #$02
		jsr color_text
		ldy #$02
		jsr l3A73
		lda #$28
		sta text_x
		lda #$17
		sta text_y
		lda #$03
		jsr color_text
		ldy #$03
		jsr l3A73
		lda #$38
		sta text_x
		lda #$0f
		sta text_y
		lda #$01
		jsr color_text
		ldy #$01
		jsr l3A73
		sec 
		sbc #$30
		sta par
		ldx #$ff
		stx hole_distance
		inx 
		stx green_view
		lda hole_number
		cmp #$13
		bne l39EA
		jmp setup_practice_hole

; jumped to by: setup_hole
l39EA:
		asl 
		asl 
		tax 
		lda hole_positions_base, x
		sta hole_x
		lda pointers_9421 + $b, x
		sta hole_x + $1
		lda pointers_9421 + $c, x
		sta hole_y
		lda pointers_9421 + $d, x
		sta hole_y + $1
		lda hole_number
		asl 
		tax 
		lda hole_shapes_base, x
		sta pointer_61
		lda terrain_93bd + $37, x
		sta pointer_61 + $1
		ldy #$00
		sty @w ball_x
		sty @w ball_y
		lda (pointer_61), y
		lsr 
		ror @w ball_x
		lsr 
		ror @w ball_x
		sta @w ball_x + $1
		iny 
		lda (pointer_61), y
		lsr 
		ror @w ball_y
		lsr 
		ror @w ball_y
		sta @w ball_y + $1
		iny 
		lda (pointer_61), y
		ora @w ball_x
		sta @w ball_x
		iny 
		lda (pointer_61), y
		ora @w ball_y
		sta @w ball_y
		rts 

; jumped to by: setup_hole
setup_practice_hole:
		lda #$1a
		sta @w ball_x
		lda #$00
		sta @w ball_x + $1
		lda #$b0
		sta @w ball_y
		lda #$00
		sta @w ball_y + $1
		lda #$12
		sta hole_x
		lda #$00
		sta hole_x + $1
		lda #$b8
		sta hole_y
		lda #$00
		sta hole_y + $1
		rts 

; called by: setup_hole
l3A73:
		ldx digit_text_index
; jumped to by: l3A73
l3A76:
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda digit_text, x
		jsr print_char
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		lda digit_text, x
		inx 
		dey 
		bne l3A76
		stx digit_text_index
		rts 

; read by: l3A73
; written by: setup_hole, l3A73
digit_text_index:
		.byte	$06

; jumped to by: l382B
turn_left:
		jsr l3AC4
		jsr direction_up
		jsr direction_up
		jsr direction_up
		jsr l3AC4
		jmp l3AB8

; jumped to by: l382B
turn_right:
		jsr l3AC4
		jsr direction_down
		jsr direction_down
		jsr direction_down
		jsr l3AC4
		jmp l3AB8

; called by: $37a0
; jumped to by: $37fc, turn_left, turn_right
l3AB8:
		jsr direction_up
		jsr direction_up
		jsr direction_up
		jmp direction_up

; called by: $37a3, $37ce, $37d1, turn_left, turn_right, l3EF4
l3AC4:
		jsr l3AC7
; called by: l3AC4
l3AC7:
		ldy direction
		lda steps_x, y
		bmi l3AE4
		lsr 
		lsr 
		lsr 
		clc 
		adc @w ball_x
		sta @w ball_x
		lda @w ball_x + $1
		adc #$00
		sta @w ball_x + $1
		jmp l3B00

; jumped to by: l3AC7
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
		adc @w ball_x
		sta @w ball_x
		lda @w ball_x + $1
		sbc #$00
		sta @w ball_x + $1
; jumped to by: l3AC7
l3B00:
		lda steps_y, y
		bmi l3B18
		lsr 
		lsr 
		lsr 
		clc 
		adc @w ball_y
		sta @w ball_y
		lda @w ball_y + $1
		adc #$00
		sta @w ball_y + $1
		rts 

; jumped to by: l3AC7
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
		adc @w ball_y
		sta @w ball_y
		lda @w ball_y + $1
		sbc #$00
		sta @w ball_y + $1
		rts 

; read by: l36E6, l3AC7
steps_x:
		.char	0, 8, 8, 8, 0, -8, -8, -8
; read by: l36E6, l3AC7
steps_y:
		.char	8, 8, 0, -8, -8, -8, 0, 8

; unreferenced
; jumped to by: l382B
l3B45:
		rts 

; unreferenced: reads a hex word from the keyboard into $06/$07
read_hex_word:
		jsr read_hex_byte
		sta pointer_06 + $1
		jsr read_hex_byte
		sta pointer_06
		rts 

; called by: read_hex_word
read_hex_byte:
		jsr read_hex_digit
		asl 
		asl 
		asl 
		asl 
		sta hex_high_nibble
		jsr read_hex_digit
		ora hex_high_nibble
		rts 

; read by: read_hex_byte
; written by: read_hex_byte
hex_high_nibble:
		.byte	$81

; waits for a key 0-9 or A-F, echoes it and returns its value
; called by: read_hex_byte
read_hex_digit:
		jsr scnkey
		jsr getin
		cmp #$30
		bcc l3B78
		cmp #$3a
		bcs l3B78
		jsr print_char
		sec 
		sbc #$30
		rts 

; jumped to by: read_hex_digit
l3B78:
		cmp #$41
		bcc read_hex_digit
		cmp #$47
		bcs read_hex_digit
		jsr print_char
		sec 
		sbc #$37
		rts 

; called by: l3EF4
position_ball_sprite:
		lda #$00
		sta v417e
		lda flight_time
		cmp #$fd
		bcs l3B99
		jsr l3BEE
		jmp l3B9C

; jumped to by: position_ball_sprite
l3B99:
		jsr l3E04
; jumped to by: position_ball_sprite
l3B9C:
		jsr l3C3F
		lda sprite_expand_x
		and #$40
		bne l3BC0
		lda #$0c
		clc 
		adc proj_x
		sta proj_x
		lda proj_x + $1
		adc #$00
		sta proj_x + $1
		lda proj_y
		clc 
		adc #$0a
		sta proj_y
; jumped to by: position_ball_sprite
l3BC0:
		lda proj_x
		sta sprite6_x
		sta sprite7_x
		lda proj_x + $1
		beq l3BD8
		lda sprites_x_msb
		ora #$c0
		sta sprites_x_msb
		bne l3BE0
; jumped to by: position_ball_sprite
l3BD8:
		lda sprites_x_msb
		and #$3f
		sta sprites_x_msb
; jumped to by: position_ball_sprite
l3BE0:
		lda proj_y
		sta sprite6_y
		clc 
		adc shadow_offset
		sta sprite7_y
		rts 

; called by: position_ball_sprite
l3BEE:
		lda v4205
		clc 
		adc v4209
		sta v4209
		lda v4206
		adc v420a
		sta v420a
		bcc l3C0E
		lda v4206
		bmi l3C16
		inc v420b
		jmp l3C16

; jumped to by: l3BEE
l3C0E:
		lda v4206
		bpl l3C16
		dec v420b
; jumped to by: l3BEE
l3C16:
		lda v4207
		clc 
		adc v420c
		sta v420c
		lda v4208
		adc v420d
		sta v420d
		lda v420a
		sta proj_x
		lda v420b
		sta proj_x + $1
		lda v420d
		sta proj_y
		rts 

; read by: l3C3F, $3d33, $3d4f
; written by: $3cfa
v3c3c:
		.byte	$29
; read by: $3d4c
; written by: l3C3F
v3c3d:		.byte	$56
; read by: l3EF4
; written by: $3d56, ball_flight
ball_landed:		.byte	$00

; called by: position_ball_sprite
l3C3F:
		lda green_view
		beq l3C8E
		lda proj_y
		pha 
		lda proj_x + $1
		pha 
		lda proj_x
		pha 
		lda #$e6
		sec 
		sbc proj_y
		cmp #$30
		bcc l3C86
		tax 
		lda #$0c
		lda proj_x + $1
		lsr 
		php 
		lda proj_x
		plp 
		ror 
		jsr test_pixel
		beq l3C6F
		jmp l3D54

; jumped to by: l3C3F
l3C6F:
		lda sprite_enable
		ora #$40
; jumped to by: l3C3F
l3C74:
		and #$7f
		sta sprite_enable
		pla 
		sta proj_x
		pla 
		sta proj_x + $1
		pla 
		sta proj_y
		rts 

; jumped to by: l3C3F
l3C86:
		lda sprite_enable
		and #$bf
		jmp l3C74

; jumped to by: l3C3F
l3C8E:
		lda proj_y
		pha 
		sta proj_y
		lda proj_x + $1
		pha 
		lda proj_x
		pha 
		lda v3c3c
		sta v3c3d
		lda proj_y
		sec 
		sbc #$e5
		clc 
		eor #$ff
		adc #$01
		sta shadow_offset
		jsr l3CB7
		jmp l3CFA

; called by: l3C3F, $3d2d
l3CB7:
		and #$fe
		cmp #$31
		bcc l3CC1
		cmp #$c0
		bcc l3CC7
; jumped to by: l3CB7
l3CC1:
		ldy #$ff
		lda #$00
		beq l3CF7
; jumped to by: l3CB7
l3CC7:
		tay 
		lda screen_rows, y
		sta $3cf5
		lda screen_rows + $1, y
		clc 
		adc #$87
		sta $3cf6
		lda proj_x
		lsr proj_x + $1
		ror 
		ldx green_view
		beq l3CF1
		cmp #$9f
		bcs l3CEB
		cmp #$65
		bcs l3CF1
; jumped to by: l3CB7
l3CEB:
		lda #$00
		ldy #$ff
		beq l3CF7
; jumped to by: l3CB7
l3CF1:
		lsr 
		lsr 
		tax 
		lda irq_hw_vector + $1, x
; jumped to by: l3CB7
l3CF7:
		rts 

; read by: position_ball_sprite, $3d78
; written by: l3C3F, $3d81
shadow_offset:
		.byte	$43
; read by: $3d61
; written by: $3d30
v3cf9:		.byte	$41

; jumped to by: l3C3F
l3CFA:
		sta v3c3c
		tya 
		ldx green_view
		bne l3D17
		jsr l3D9F
		lda horizon
		sec 
		sbc proj_y
		ldx flight_time
		cpx #$40
		bcs l3D17
		sec 
		sbc #$10
; jumped to by: $3d01, $3d12
l3D17:
		sta proj_y
		pla 
		sta proj_x
		pla 
		sta proj_x + $1
		lda proj_x + $1
		pha 
		lda proj_x
		pha 
		lda proj_y
		jsr l3CB7
		sta v3cf9
		lda v3c3c
		cmp proj_y
		bcc l3D45
		lda sprite_enable
		ora #$40
		sta sprite_enable
		bne l3D61
; jumped to by: $3d39
l3D45:
		lda sprite_enable
		and #$40
		beq l3D59
		lda v3c3d
		cmp v3c3c
		bne l3D59
; jumped to by: l3C3F
l3D54:
		lda #$ff
		sta ball_landed
; jumped to by: $3d4a, $3d52
l3D59:
		lda sprite_enable
		and #$bf
		sta sprite_enable
; jumped to by: $3d43
l3D61:
		lda v3cf9
		cmp proj_y
		bcc l3D8A
		lda club
		cmp #$0c
		bcs l3D8A
		lda sprite_enable
		ora #$80
		sta sprite_enable
		lda shadow_offset
		sec 
		sbc proj_y
		bcc l3D8A
		sta shadow_offset
		cmp #$03
		bcs l3D92
		bcc l3D92
; jumped to by: $3d67, $3d6e, $3d7f
l3D8A:
		lda sprite_enable
		and #$7f
		sta sprite_enable
; jumped to by: $3d86, $3d88
l3D92:
		pla 
		sta proj_x
		pla 
		sta proj_x + $1
		pla 
		sta proj_y
		rts 

; called by: $3d03, l3E04
l3D9F:
		lda v359e
		sta view_x
		bmi l3DAB
		lda #$00
		beq l3DAD
; jumped to by: l3D9F
l3DAB:
		lda #$ff
; jumped to by: l3D9F
l3DAD:
		sta view_x + $1
		lda v35a0
		sta view_y
		lda #$00
		sta view_y + $1
		lda green_view
		bne l3DC3
		jmp project

; jumped to by: l3D9F
l3DC3:
		lda view_x
		jsr l4354
		sta view_x
		lda view_y
		sec 
		sbc #$02
		jsr l4354
		sta view_y
		lda green_flag_y
		clc 
		adc view_y
		sta proj_y
		lda #$00
		sta proj_y + $1
		sta proj_x + $1
		lda green_flag_x
		clc 
		adc view_x
		asl 
		rol proj_x + $1
		sta proj_x
		lda #$e6
		sec 
		sbc proj_y
		sta proj_y
		pla 
		pla 
		rts 

; called by: position_ball_sprite, l423D
l3E04:
		jsr l3D9F
		lda proj_x
		sec 
		sbc #$30
		asl 
		sta proj_x
		lda #$00
		rol 
		sta proj_x + $1
		lda proj_y
		and #$fe
		cmp #$10
		bcs l3E30
		tax 
		lda near_scales, x
		sta math_words + $a
		lda near_scales + $1, x
		sta math_words + $b
		jmp l3E42

; jumped to by: l3E04
l3E30:
		lsr 
		lsr 
		lsr 
		and #$fe
		tax 
		lda far_scales, x
		sta math_words + $a
		lda far_scales + $1, x
		sta math_words + $b
; jumped to by: l3E04
l3E42:
		lda #$e5
		sec 
		sbc horizon
		clc 
		adc proj_y
		sta proj_y
		lda v417e
		ldy #$ff
		sty v1f15
		jsr scale_step
		jsr to_log
		sta log_value
		stx log_value + $1
		lda #$00
		ldx shot_speed
		jsr to_log
		jsr log_multiply
		lda #$00
		ldx #$40
		jsr to_log
		jsr log_divide
		lda log_value
		ldx log_value + $1
		jsr from_log
		txa 
		asl 
		asl 
		clc 
		eor #$ff
		adc #$01
		clc 
		adc proj_y
		sta proj_y
		rts 

; jumped to by: l34C1
ball_flight:
		jsr l4345
		lda #$00
		lda #$80
		sta v359f
		lda #$02
		sta v35a0
		lda #$00
		sta v359d
		lda #$00
		sta v359e
		lda shot_sideways
		bpl l3EB0
		lda #$ff
		sta v359d
; jumped to by: ball_flight
l3EB0:
		ldx #$00
		stx ball_landed
		stx v4209
		stx v420b
		stx v420c
		lda v4203
		sta v420a
		lda v4204
		sta v420d
		lda green_view
		beq l3EEC
		lda green_flag_x
		asl 
		sta v420a
		rol v420b
		lda #$e6
		sec 
		sbc green_flag_y
		sta v420d
		lda #$00
		sta v359f
		lda #$02
		sta v35a0
; jumped to by: ball_flight
l3EEC:
		stx flight_time
		lda #$21
		sta sprite_pointers + $6
; called by: snapshot_pc
l3EF4:
		lda flight_time
		and #$10
		bne l3F01
		jsr l423D
		lda flight_time
; jumped to by: l3EF4
l3F01:
		cmp #$80
		bne l3F11
		lda club
		cmp #$0b
		bcs l3F11
		lda #$20
		sta sprite_pointers + $6
; jumped to by: l3EF4
l3F11:
		lda flight_time
		and #$01
		bne l3F1B
		jsr position_ball_sprite
; jumped to by: l3EF4
l3F1B:
		lda shot_speed
		clc 
		adc v359f
		sta v359f
		lda v35a0
		adc #$00
		sta v35a0
		lda shot_sideways
		bmi l3F44
		clc 
		adc v359d
		sta v359d
		lda #$00
		adc v359e
		sta v359e
		jmp l3F50

; jumped to by: l3EF4
l3F44:
		clc 
		adc v359d
		sta v359d
		bcs l3F50
		dec v359e
; jumped to by: l3EF4
l3F50:
		lda flight_time
		tax 
		lda ball_landed
		bne l3F76
		inx 
		stx flight_time
		stx v3294
		beq l3FA4
		txa 
		and #$01
		beq l3F6A
		jmp l3EF4

; jumped to by: l3EF4
l3F6A:
		lda v4205
		ora v4207
		bne l3F75
		jmp l3EF4

; jumped to by: l3EF4
l3F75:
		rts 

; jumped to by: l3EF4
l3F76:
		ldx #$00
		stx v417e
		stx v3294
		dex 
		stx flight_time
		lda green_view
		bne l3F8D
		jsr click_sound
		jsr position_ball_sprite
; jumped to by: l3EF4
l3F8D:
		lda #$00
		sta aim_offset
		jsr l36E6
		lda v35a0
		sta shot_speed
		lda v359e
		sta shot_sideways
		jsr l3711
; jumped to by: l3EF4
l3FA4:
		jsr l3AC4
		lda current_player
		and #$01
		asl 
		tax 
		lda @w ball_x
		sta safe_ball_x, x
		lda @w ball_x + $1
		sta safe_ball_x + $1, x
		lda @w ball_y
		sta safe_ball_y, x
		lda @w ball_y + $1
		sta safe_ball_y + $1, x
		lda v3782
		bmi l3FDD
		clc 
		adc @w ball_x
		sta @w ball_x
		lda #$00
		adc @w ball_x + $1
		sta @w ball_x + $1
		jmp l3FE9

; jumped to by: l3EF4
l3FDD:
		clc 
		adc @w ball_x
		sta @w ball_x
		bcs l3FE9
		dec @w ball_x + $1
; jumped to by: l3EF4
l3FE9:
		lda v3783
		bmi l4000
		clc 
		adc @w ball_y
		sta @w ball_y
		lda #$00
		adc @w ball_y + $1
		sta @w ball_y + $1
		jmp l400C

; jumped to by: l3EF4
l4000:
		clc 
		adc @w ball_y
		sta @w ball_y
		bcs l400C
		dec @w ball_y + $1
; jumped to by: l3EF4
l400C:
		lda @w ball_x
		sec 
		sbc hole_x
		sta v0452
		lda @w ball_x + $1
		sbc hole_x + $1
		sta v0453
		lda @w ball_y
		sec 
		sbc hole_y
		sta v0454
		lda @w ball_y + $1
		sbc hole_y + $1
		sta v0455
		lda hole_distance
		cmp #$40
		bcc l404E
		ldx #$04
; jumped to by: l3EF4
l403A:
		asl v0452
		rol v0453
		dex 
		bne l403A
		ldx #$04
; jumped to by: l3EF4
l4045:
		asl v0454
		rol v0455
		dex 
		bne l4045
; jumped to by: l3EF4
l404E:
		lda hole_x
		sta @w ball_x
		lda hole_x + $1
		sta @w ball_x + $1
		lda hole_y
		sta @w ball_y
		lda hole_y + $1
		sta @w ball_y + $1
		lda v0452
		clc 
		adc @w ball_x
		sta @w ball_x
		lda v0453
		adc @w ball_x + $1
		sta @w ball_x + $1
		lda v0454
		clc 
		adc @w ball_y
		sta @w ball_y
		lda v0455
		adc @w ball_y + $1
		sta @w ball_y + $1
		lda #$00
		sta hole_distance
		lda v0453
		php 
		bpl l4098
		eor #$ff
; jumped to by: l3EF4
l4098:
		cmp #$00
		beq l40A1
		plp 
		lda #$ff
		bne l40AC
; jumped to by: l3EF4
l40A1:
		lda v0452
		plp 
		bpl l40AC
		clc 
		eor #$ff
		adc #$01
; jumped to by: l3EF4
l40AC:
		pha 
		ora hole_distance
		sta hole_distance
		pla 
		cmp #$40
		bcs l40E0
		lda v0455
		php 
		bpl l40BE
		eor #$ff
; jumped to by: l3EF4
l40BE:
		cmp #$00
		beq l40C7
		plp 
		lda #$ff
		bne l40D2
; jumped to by: l3EF4
l40C7:
		lda v0454
		plp 
		bpl l40D2
		clc 
		eor #$ff
		adc #$01
; jumped to by: l3EF4
l40D2:
		pha 
		ora hole_distance
		sta hole_distance
		pla 
		cmp #$40
		bcs l40E0
		lda #$00
		beq l40E2
; jumped to by: l3EF4
l40E0:
		lda #$01
; jumped to by: l3EF4
l40E2:
		sta v0456
		asl v0453
		php 
		ror v0453
		ldx #$04
; jumped to by: l3EF4
l40EE:
		plp 
		php 
		ror v0453
		ror v0452
		dex 
		bne l40EE
		plp 
		asl v0455
		php 
		ror v0455
		ldx #$04
; jumped to by: l3EF4
l4103:
		plp 
		php 
		ror v0455
		ror v0454
		dex 
		bne l4103
		plp 
		lda hole_x
		sta v046c
		lda hole_x + $1
		sta v046d
		lda hole_y
		sta v046e
		lda hole_y + $1
		sta v046f
		lda v0452
		clc 
		adc v046c
		sta v046c
		lda v0453
		adc v046d
		sta v046d
		lda v0454
		clc 
		adc v046e
		sta v046e
		lda v0455
		adc v046f
		sta v046f
		lda v0456
		beq l416A
		lda v046c
		sta @w ball_x
		lda v046d
		sta @w ball_x + $1
		lda v046e
		sta @w ball_y
		lda v046f
		sta @w ball_y + $1
; jumped to by: l3EF4
l416A:
		lda green_view
		beq l417C
		lda ball_landed
		beq l417C
		lda hole_distance
		and #$f0
		bne l417C
		sta hole_distance
; jumped to by: l3EF4
l417C:
		rts 

; old text "CAL" under the variables
unused_417d:
		.byte	$43
; read by: l3E04
; written by: position_ball_sprite, l3EF4, l423D
v417e:		.byte	$41
; read by: position_ball_sprite, $3d0d, l3EF4, l423D
; written by: ball_flight, l3EF4
flight_time:		.byte	$4c

; colors A characters at text_x/text_y with text_color
; called by: print_club_name, setup_hole
; jumped to by: message_line
color_text:
		pha 
		lda text_y
		pha 
		lda text_x
		pha 
		lda #$20
		jsr print_char
		pla 
		sta text_x
		pla 
		sta text_y
		lda #$09
		clc 
		eor #$ff
		adc #$01
		clc 
		adc bitmap_pointer
		sta bitmap_pointer
		lda bitmap_pointer + $1
		sbc #$00
		sta bitmap_pointer + $1
		pla 
		asl 
		tay 
		lda pointer_04 + $1
		pha 
		lda pointer_04
		pha 
		tya 
		asl 
		asl 
		asl 
		pha 
		lda bitmap_pointer
		sec 
		sbc #$00
		sta pointer_04
		lda bitmap_pointer + $1
		sbc #$60
		sta pointer_04 + $1
		inc pointer_04
		bne l41C5
		inc pointer_04 + $1
; jumped to by: color_text
l41C5:
		ldx #$03
; jumped to by: color_text
l41C7:
		lsr pointer_04 + $1
		ror pointer_04
		dex 
		bne l41C7
		lda pointer_04
		clc 
		adc #$00
		sta pointer_04
		lda pointer_04 + $1
		adc #$d8
		sta pointer_04 + $1
		lda pointer_04
		bne l41E1
		dec pointer_04 + $1
; jumped to by: color_text
l41E1:
		dec pointer_04
		lda text_color
; jumped to by: color_text
l41E6:
		sta (pointer_04), y
		dey 
		bne l41E6
		pla 
		tay 
		lda (bitmap_pointer), y
; jumped to by: color_text
l41EF:
		sta (bitmap_pointer), y
		dey 
		bne l41EF
		lda #$ff
		sta pixel_pattern
		pla 
		sta pointer_04
		pla 
		sta pointer_04 + $1
		rts 

unused_4200:
		.byte	$00, $00, $00
; read by: ball_flight
v4203:		.byte	$ad
; read by: ball_flight
v4204:		.byte	$a3
; read by: l3BEE, l3EF4, l423D
; written by: l423D
v4205:		.byte	$21
; read by: l3BEE
; written by: l423D
; modified by: l423D
v4206:		.byte	$7d
; read by: l3BEE, l3EF4, l423D
; written by: l423D
v4207:		.byte	$10
; read by: l3BEE
; written by: l423D
; modified by: l423D
v4208:		.byte	$00
; read by: l3BEE
; written by: l3BEE, ball_flight
v4209:		.byte	$00
; read by: l3BEE, l423D
; written by: l3BEE, ball_flight
v420a:		.byte	$43
; read by: l3BEE, l423D
; written by: ball_flight
; modified by: l3BEE, ball_flight
v420b:		.byte	$41
; read by: l3BEE
; written by: l3BEE, ball_flight
v420c:		.byte	$4c
; read by: l3BEE, l423D
; written by: l3BEE, ball_flight
v420d:		.byte	$43
unused_420e:
		.byte	$44, $45

; called by: l423D
l4210:
		lda #$00
		jsr to_log
		sta log_value
		stx log_value + $1
		lda #$00
		ldx club
		inx 
		cpx #$0d
		bcc l4225
		ldx #$00
; jumped to by: l4210
l4225:
		jsr to_log
		jsr log_multiply
		lda #$00
		ldx #$10
		jsr to_log
		jsr log_divide
		lda log_value
		ldx log_value + $1
		jsr from_log
		rts 

; called by: l3EF4
l423D:
		lda v359e
		pha 
		lda v359d
		pha 
		lda v35a0
		pha 
		lda v359f
		pha 
		lda flight_time
		bne l428D
		lda #$00
		sta v4342
		lda shot_speed
		asl 
		rol v4342
		asl 
		rol v4342
		asl 
		rol v4342
		asl 
		rol v4342
		sta v4341
		lda #$00
		sta v4344
		lda shot_sideways
		bpl l427A
		dec v4344
; jumped to by: l423D
l427A:
		asl 
		rol v4344
		asl 
		rol v4344
		asl 
		rol v4344
		asl 
		rol v4344
		sta v4343
; jumped to by: l423D
l428D:
		lda v4341
		clc 
		adc v359f
		sta v359f
		lda v4342
		adc v35a0
		sta v35a0
		lda v4343
		clc 
		adc v359d
		sta v359d
		lda v4344
		adc v359e
		sta v359e
		lda flight_time
		clc 
		adc #$10
		bpl l42C0
		clc 
		eor #$ff
		adc #$01
; jumped to by: l423D
l42C0:
		tax 
		jsr l4210
		stx v417e
		jsr l3E04
		lda proj_x + $1
		sec 
		sbc v420b
		lda proj_x
		sbc v420a
		sta v4205
		lda proj_y
		sec 
		sbc v420d
		bmi l42ED
		ldx flight_time
		bmi l42ED
		lda #$00
		sta v4205
; jumped to by: l423D
l42ED:
		sta v4207
		lda #$00
		sta v4208
		lda v4207
		bpl l42FD
		dec v4208
; jumped to by: l423D
l42FD:
		asl 
		rol v4208
		asl 
		rol v4208
		asl 
		rol v4208
		asl 
		rol v4208
		sta v4207
		lda #$00
		sta v4206
		lda v4205
		bpl l431D
		dec v4206
; jumped to by: l423D
l431D:
		asl 
		rol v4206
		asl 
		rol v4206
		asl 
		rol v4206
		asl 
		rol v4206
		sta v4205
		pla 
		sta v359f
		pla 
		sta v35a0
		pla 
		sta v359d
		pla 
		sta v359e
		rts 

; read by: l423D
; written by: l423D
v4341:
		.byte	$53
; read by: l423D
; written by: l423D
; modified by: l423D
v4342:		.byte	$51
; read by: l423D
; written by: l423D
v4343:		.byte	$55
; read by: l423D
; written by: l423D
; modified by: l423D
v4344:		.byte	$41

; called by: $30f0, ball_flight
l4345:
		jmp (vectors)

; called by: l382B
l4348:
		jmp (aA00E)

; called by: $2ed9, $30ea
; jumped to by: select_club
l434B:
		jmp (aA014)

; called by: $2ebc, $30ed, l382B
l434E:
		jmp (aA016)

; called by: select_club
l4351:
		jmp (aA01E)

; called by: l3D9F
l4354:
		jmp (aA029)

; ---- video bank 1 ($4000-$7fff) ----
; never written: still the RAM's power-on pattern
unused_4357:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00

.virtual $4400
; the bitmap's colors, drawn at run time
bitmap_colors:
		.fill	1000
.endv

*=$47e8

unused_47e8:
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea

.virtual $47f8
; read by: $a42f, $a4b2
; written by: check_terrain, l33C0, ball_flight, l3EF4, clear_screen, $a438, $a4bb, draw_flag, $b4d6, $b562, $b76a
sprite_pointers:
		.fill	8
.endv

*=$4800

; read by: draw_golfer, set_golfer_colors, l2F9B, $2fd4, l301D, mirror_golfer, check_landing, $31c8, draw_animation_frame, l33C0
; written by: draw_golfer, set_golfer_colors, mirror_golfer
sprites:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $00, $00, $18
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $05
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $00, $00, $3c, $00, $00, $3c
		.byte	$00, $00, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $05
		.byte	$00, $00, $00, $00, $00, $00, $00, $18, $00, $00, $18, $00, $00, $18, $00, $00
		.byte	$18, $00, $00, $18, $00, $00, $18, $00, $00, $18, $00, $00, $18, $00, $00, $18
		.byte	$00, $00, $18, $00, $00, $18, $00, $06, $18, $60, $07, $18, $e0, $03, $99, $c0
		.byte	$01, $db, $80, $00, $ff, $00, $00, $7e, $00, $00, $3c, $00, $00, $18, $00, $00
		.byte	$00, $02, $00, $02, $08, $00, $0a, $28, $00, $02, $08, $00, $02, $8a, $00, $0a
		.byte	$a8, $00, $02, $a8, $00, $02, $a8, $00, $01, $54, $00, $05, $55, $00, $05, $55
		.byte	$00, $05, $55, $00, $05, $55, $00, $05, $55, $00, $05, $a5, $00, $05, $a5, $00
		.byte	$05, $a5, $00, $05, $a5, $00, $05, $a5, $00, $05, $a5, $00, $05, $a5, $00, $00
		.byte	$05, $a5, $00, $05, $a5, $00, $05, $a5, $00, $05, $a5, $00, $05, $a5, $00, $05
		.byte	$a5, $00, $05, $a5, $00, $05, $55, $00, $05, $55, $00, $05, $55, $00, $05, $55
		.byte	$00, $01, $54, $00, $f1, $54, $f0, $f1, $54, $f0, $f1, $54, $f0, $f1, $54, $f0
		.byte	$fd, $57, $f0, $f1, $54, $f0, $f1, $54, $f0, $f0, $50, $f0, $f0, $00, $f0, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $28, $00, $00, $a8, $00, $00, $aa, $00, $00, $fa
		.byte	$00, $00, $fa, $00, $00, $ba, $00, $00, $fe, $00, $03, $fe, $00, $00, $fe, $00
		.byte	$00, $7e, $00, $00, $fe, $00, $00, $fe, $00, $00, $3f, $00, $00, $3f, $00, $ff
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $08, $00, $00, $2a, $00, $00, $2a, $00, $00, $aa
		.byte	$80, $00, $aa, $80, $00, $aa, $80, $00, $aa, $80, $00, $aa, $80, $00, $aa, $80
		.byte	$00, $aa, $80, $00, $2a, $00, $00, $2a, $00, $00, $3f, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $a0, $00, $02, $a8, $00, $02, $aa, $00, $0a
		.byte	$aa, $00, $0a, $bc, $00, $0a, $f4, $00, $0b, $fc, $00, $2b, $fc, $00, $2f, $f0
		.byte	$00, $2f, $d0, $00, $3f, $f0, $00, $3f, $00, $00, $03, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $0a, $00, $00, $2a, $80, $00, $2a, $80, $00, $2a, $80, $00, $aa
		.byte	$c0, $00, $aa, $c0, $00, $ab, $c0, $00, $ab, $c0, $00, $af, $00, $00, $af, $00
		.byte	$00, $bf, $00, $00, $fc, $00, $00, $fc, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $3e, $00, $00, $3f, $fe, $00, $1f, $ff, $00, $0f, $ff, $80, $07
		.byte	$ff, $c0, $03, $ff, $e0, $00, $ff, $f0, $00, $3f, $f8, $00, $1f, $fc, $00, $0f
		.byte	$fe, $00, $07, $fe, $00, $07, $fc, $00, $07, $f8, $00, $0f, $f8, $00, $0f, $f0
		.byte	$00, $1f, $f0, $00, $1f, $f0, $00, $3f, $f0, $00, $3f, $f8, $00, $03, $ff, $00
		.byte	$00, $00, $00, $3e, $00, $00, $3f, $ff, $00, $3f, $ff, $80, $1f, $ff, $80, $0f
		.byte	$ff, $c0, $07, $ff, $e0, $03, $ff, $e0, $01, $ff, $f0, $00, $ff, $f8, $00, $7f
		.byte	$f8, $00, $7f, $f8, $00, $3f, $f8, $00, $3f, $f0, $00, $3f, $f0, $00, $3f, $f0
		.byte	$00, $3f, $f0, $00, $3f, $f0, $00, $3f, $f0, $00, $3f, $f0, $00, $03, $fc, $00
		.byte	$00, $00, $00, $3e, $00, $00, $3f, $ff, $80, $3f, $ff, $80, $1f, $ff, $80, $1f
		.byte	$ff, $c0, $0f, $ff, $c0, $0f, $ff, $c0, $07, $ff, $c0, $07, $ff, $c0, $07, $ef
		.byte	$c0, $03, $ef, $c0, $03, $e7, $c0, $03, $e7, $c0, $03, $e7, $c0, $03, $e7, $c0
		.byte	$01, $e7, $c0, $01, $e3, $c0, $01, $f3, $c0, $01, $c3, $e0, $00, $01, $c0, $00
		.byte	$00, $00, $00, $3f, $ff, $c0, $3f, $ff, $c0, $3f, $ff, $c0, $3f, $ff, $c0, $3f
		.byte	$ff, $c0, $1f, $ff, $c0, $1f, $ef, $c0, $1f, $cf, $c0, $1f, $cf, $c0, $0f, $cf
		.byte	$c0, $0f, $cf, $c0, $0f, $8f, $c0, $0f, $87, $c0, $0f, $87, $c0, $0f, $07, $c0
		.byte	$0f, $03, $c0, $0f, $03, $c0, $0f, $03, $c0, $0f, $01, $c0, $06, $00, $c0, $00
		.byte	$3f, $ff, $c0, $3f, $ff, $c0, $3f, $ff, $c0, $3f, $ff, $c0, $3f, $ff, $c0, $3f
		.byte	$df, $c0, $3f, $9f, $c0, $3f, $0f, $c0, $3f, $0f, $c0, $3f, $0f, $c0, $3f, $0f
		.byte	$c0, $3f, $0f, $c0, $3f, $0f, $c0, $3e, $07, $c0, $3e, $07, $c0, $3e, $07, $c0
		.byte	$3e, $07, $c0, $3e, $07, $c0, $3e, $03, $c0, $3c, $03, $c0, $18, $01, $80, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $0f, $ff, $00, $0f, $ff, $00, $0f, $ff, $00, $07, $fe, $00, $07, $fe, $00
		.byte	$07, $fe, $00, $03, $fe, $00, $03, $fc, $00, $03, $fc, $00, $01, $fc, $00, $01
		.byte	$fc, $00, $01, $fc, $00, $01, $fc, $00, $01, $fc, $00, $01, $fc, $00, $01, $fc
		.byte	$00, $01, $fc, $00, $01, $fc, $00, $01, $fc, $00, $01, $fc, $00, $07, $fc, $00
		.byte	$00, $7f, $f8, $00, $7f, $f8, $00, $7f, $f8, $00, $ff, $f0, $00, $ff, $f0, $00
		.byte	$ff, $f0, $00, $fd, $f0, $01, $f9, $f0, $01, $f9, $f0, $01, $f1, $f0, $01, $f1
		.byte	$f8, $01, $f9, $f8, $00, $f8, $f8, $00, $f8, $f8, $00, $f8, $f8, $00, $7c, $f8
		.byte	$00, $7c, $fc, $00, $3e, $fc, $00, $3e, $7c, $00, $fe, $fc, $00, $03, $fc, $00
		.byte	$01, $ff, $e0, $01, $ff, $e0, $01, $ff, $e0, $03, $ff, $e0, $03, $ff, $e0, $03
		.byte	$f7, $e0, $07, $f7, $f0, $07, $e3, $f0, $07, $c3, $f0, $0f, $c1, $f0, $0f, $81
		.byte	$f8, $0f, $80, $f8, $0f, $80, $f8, $1f, $00, $7c, $1f, $00, $7c, $1f, $00, $7c
		.byte	$3f, $00, $7c, $3e, $00, $3e, $fe, $00, $3e, $3c, $00, $3c, $00, $00, $70, $00
		.byte	$00, $00, $3f, $00, $00, $3f, $00, $00, $3f, $00, $00, $7f, $00, $00, $7f, $00
		.byte	$00, $7f, $00, $00, $7f, $00, $00, $7e, $00, $00, $fc, $00, $00, $fc, $00, $00
		.byte	$f8, $00, $01, $f8, $00, $01, $f0, $00, $01, $f0, $00, $01, $f0, $00, $03, $e0
		.byte	$00, $03, $e0, $00, $07, $e0, $00, $1f, $c0, $00, $01, $c0, $00, $00, $00, $00
		.byte	$fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fc
		.byte	$00, $00, $fc, $00, $00, $fc, $00, $00, $fc, $00, $00, $fe, $00, $00, $3f, $00
		.byte	$00, $1f, $80, $00, $0f, $c0, $00, $07, $e0, $00, $03, $f0, $00, $01, $f8, $00
		.byte	$00, $fc, $00, $00, $7e, $00, $00, $3e, $00, $00, $38, $00, $00, $60, $00, $00
		.byte	$00, $00, $7f, $00, $00, $7f, $00, $00, $7f, $00, $00, $7f, $00, $00, $ff, $00
		.byte	$00, $ff, $00, $00, $fe, $00, $00, $fc, $00, $00, $fc, $00, $01, $f8, $00, $01
		.byte	$f8, $00, $01, $f8, $00, $01, $f8, $00, $01, $f0, $00, $03, $f0, $00, $03, $f0
		.byte	$00, $03, $f0, $00, $03, $e0, $00, $03, $e0, $00, $03, $e0, $00, $1f, $e0, $00
		.byte	$07, $c0, $00, $07, $c0, $00, $07, $c0, $00, $07, $c0, $00, $07, $c0, $00, $07
		.byte	$e0, $00, $07, $e0, $00, $03, $e0, $00, $03, $e0, $00, $01, $f0, $00, $01, $f0
		.byte	$00, $00, $f8, $00, $00, $fc, $00, $00, $7e, $00, $00, $3f, $00, $00, $0f, $c0
		.byte	$00, $07, $f0, $00, $01, $fe, $00, $00, $7e, $00, $00, $1c, $00, $00, $18, $00
		.byte	$03, $ff, $80, $03, $ff, $80, $03, $ff, $80, $03, $ff, $00, $03, $ff, $00, $03
		.byte	$ff, $00, $03, $fe, $00, $03, $fe, $00, $03, $fe, $00, $03, $fe, $00, $03, $ff
		.byte	$00, $03, $ff, $80, $03, $ef, $c0, $03, $e7, $e0, $03, $e3, $f0, $03, $e1, $f8
		.byte	$03, $e0, $fc, $03, $e0, $7e, $03, $e0, $3f, $03, $e0, $70, $1f, $e0, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $f0, $00
		.byte	$0f, $f8, $00, $1f, $fc, $00, $1f, $fe, $00, $1f, $fe, $00, $1f, $fe, $00, $3f
		.byte	$fc, $00, $7f, $fc, $01, $ff, $fc, $07, $ff, $fc, $1f, $1f, $fc, $70, $1f, $fe
		.byte	$00, $1f, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $f0, $00
		.byte	$0f, $f8, $00, $1f, $fc, $40, $1f, $fe, $30, $1f, $fe, $1c, $3f, $fe, $0f, $ff
		.byte	$fc, $07, $ff, $fc, $03, $ff, $fc, $00, $1f, $fc, $00, $1f, $fc, $00, $1f, $fe
		.byte	$00, $1f, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60, $00, $00, $f8, $00, $01
		.byte	$fe, $00, $00, $ff, $c0, $00, $7f, $fc, $00, $3f, $ff, $00, $1f, $ff, $00, $3f
		.byte	$fe, $00, $7f, $fc, $00, $ff, $fc, $01, $ff, $f8, $03, $ff, $f8, $03, $ff, $f0
		.byte	$07, $ff, $f0, $07, $ff, $e0, $00, $3f, $c0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $00, $00, $07
		.byte	$e0, $00, $07, $fe, $00, $07, $ff, $fc, $07, $ff, $ff, $00, $ff, $ff, $00, $3f
		.byte	$fe, $00, $7f, $fc, $00, $ff, $fc, $01, $ff, $f8, $03, $ff, $f8, $03, $ff, $f0
		.byte	$07, $ff, $f0, $07, $ff, $e0, $00, $3f, $c0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $3f, $ff, $fc, $1f, $ff, $ff, $0f, $ff, $ff, $01, $ff
		.byte	$fe, $00, $7f, $fe, $00, $ff, $fc, $01, $ff, $f8, $03, $ff, $f8, $03, $ff, $f0
		.byte	$07, $ff, $f0, $07, $ff, $e0, $00, $3f, $c0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $fc, $00, $1f, $ff, $03, $ff, $ff, $1f, $ff
		.byte	$ff, $7f, $ff, $fe, $01, $ff, $fc, $01, $ff, $f8, $03, $ff, $f8, $03, $ff, $f0
		.byte	$07, $ff, $f0, $07, $ff, $e0, $00, $3f, $c0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $fc, $00, $07, $ff, $00, $1f, $ff, $00, $7f
		.byte	$ff, $01, $ff, $fe, $03, $ff, $fe, $07, $ff, $fc, $0f, $ff, $f8, $1f, $ff, $f0
		.byte	$3f, $ff, $f0, $07, $ff, $e0, $00, $3f, $c0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $fc, $00, $07, $ff, $00, $1f, $ff, $00, $3f
		.byte	$ff, $00, $7f, $ff, $00, $ff, $fe, $01, $ff, $fe, $03, $ff, $fc, $03, $ff, $f8
		.byte	$07, $ff, $f0, $07, $ff, $e0, $01, $ff, $c0, $01, $80, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $fc, $00, $07, $ff, $00, $1f, $ff, $00, $3f
		.byte	$ff, $00, $7f, $ff, $00, $ff, $ff, $01, $ff, $ff, $03, $ff, $fe, $03, $ff, $fc
		.byte	$07, $ff, $f8, $07, $ff, $f0, $00, $3f, $c0, $00, $07, $00, $00, $06, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$1f, $80, $00, $ff, $e0, $03, $ff, $e0, $07, $ff, $e0, $0f, $ff, $e0, $1f, $ff
		.byte	$e0, $3f, $ff, $e0, $7f, $ff, $e0, $7f, $ff, $c0, $ff, $ff, $c0, $ff, $fd, $c0
		.byte	$07, $f9, $c0, $00, $01, $c0, $00, $01, $c0, $00, $00, $c0, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$1f, $80, $00, $ff, $e0, $03, $ff, $e0, $07, $ff, $e0, $0f, $ff, $e0, $1f, $ff
		.byte	$e0, $3f, $ff, $f0, $7f, $ff, $f0, $7f, $ff, $f0, $ff, $ff, $f8, $ff, $fd, $f8
		.byte	$07, $f8, $7c, $00, $00, $3e, $00, $00, $1e, $00, $00, $0f, $00, $00, $03, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $0f, $00, $00, $7f, $00, $01, $ff, $00, $03, $ff, $00, $07, $ff, $00, $0f
		.byte	$ff, $00, $1f, $ff, $00, $3f, $ff, $00, $3f, $ff, $00, $7f, $ff, $00, $7f, $fe
		.byte	$00, $03, $fc, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0
		.byte	$00, $00, $f0, $00, $00, $f0, $00, $00, $f0, $00, $00, $f8, $00, $00, $f8, $00
		.byte	$00, $fc, $00, $00, $7c, $00, $00, $7e, $00, $00, $3e, $00, $00, $1f, $00, $00
		.byte	$0f, $00, $00, $07, $80, $00, $03, $c0, $00, $01, $e0, $00, $00, $60, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0
		.byte	$00, $00, $f0, $00, $00, $f0, $00, $00, $f8, $00, $00, $fc, $00, $00, $fe, $00
		.byte	$00, $ff, $00, $00, $ff, $80, $00, $3f, $c0, $00, $07, $e0, $00, $00, $f0, $00
		.byte	$00, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0
		.byte	$00, $00, $f0, $00, $00, $fc, $00, $00, $ff, $80, $00, $ff, $f0, $00, $ff, $fc
		.byte	$00, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $03, $c0, $00, $ff
		.byte	$80, $00, $ff, $80, $00, $ff, $00, $00, $fe, $00, $00, $f8, $00, $00, $e0, $00
		.byte	$00, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00
		.byte	$0e, $06, $00, $1f, $fe, $00, $3f, $ff, $00, $3f, $ff, $00, $7f, $fe, $00, $7f
		.byte	$fe, $00, $ff, $fe, $01, $ff, $fc, $03, $ff, $f8, $07, $ff, $f8, $07, $ff, $f0
		.byte	$0f, $ff, $e0, $0f, $ff, $e0, $00, $7f, $c0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $e0, $00, $01, $f8, $00, $01
		.byte	$fe, $00, $01, $ff, $fc, $01, $ff, $fe, $00, $ff, $fe, $00, $7f, $fc, $00, $7f
		.byte	$fc, $00, $ff, $f8, $01, $ff, $f0, $03, $ff, $f0, $07, $ff, $f0, $07, $ff, $e0
		.byte	$0f, $ff, $e0, $0f, $ff, $e0, $00, $7f, $e0, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $80, $00, $07, $f0, $00, $0f
		.byte	$ff, $f0, $0f, $ff, $f8, $07, $ff, $fc, $03, $ff, $fc, $01, $ff, $fc, $01, $ff
		.byte	$fc, $01, $ff, $f8, $03, $ff, $f8, $03, $ff, $f8, $07, $ff, $f8, $07, $ff, $f8
		.byte	$07, $ff, $f8, $07, $ff, $f8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $ff, $80, $07
		.byte	$ff, $e0, $0f, $ff, $f0, $1f, $ff, $f8, $3f, $ff, $f8, $3f, $ff, $fc, $3f, $ff
		.byte	$fc, $3f, $ff, $fc, $1f, $ff, $fc, $1f, $ff, $f8, $1f, $ff, $f8, $0f, $ff, $f0
		.byte	$0f, $ff, $f0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $ff, $80, $0f
		.byte	$ff, $e0, $1f, $ff, $f8, $3f, $ff, $fc, $7f, $ff, $fe, $7f, $ff, $ef, $ff, $ff
		.byte	$e7, $ef, $ff, $e7, $ef, $ff, $ef, $ef, $ff, $fe, $ff, $ff, $fc, $7f, $ff, $f8
		.byte	$7f, $ff, $f0, $60, $00, $00, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $7f, $f8, $00, $7f, $f8, $00, $7f, $f8, $00, $3f, $f0, $00, $3f, $f0, $00
		.byte	$3f, $f0, $00, $3f, $e0, $00, $1f, $e0, $00, $1f, $e0, $00, $1f, $c0, $00, $1f
		.byte	$c0, $00, $1f, $c0, $00, $1f, $c0, $00, $1f, $c0, $00, $1f, $c0, $00, $1f, $c0
		.byte	$00, $1f, $c0, $00, $1f, $c0, $00, $1f, $c0, $00, $1f, $c0, $00, $1f, $f0, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7f, $00, $00
		.byte	$ff, $80, $01, $ff, $c0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff
		.byte	$c0, $01, $ff, $c0, $01, $ff, $c0, $01, $ff, $c0, $01, $ff, $c0, $01, $ff, $e0
		.byte	$01, $ff, $e0, $00, $1c, $00, $00, $0c, $00, $00, $04, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7f, $00, $00
		.byte	$ff, $80, $01, $ff, $c0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff
		.byte	$e0, $01, $ff, $e0, $01, $ff, $f0, $01, $ff, $f0, $01, $ff, $f0, $03, $ff, $f0
		.byte	$03, $ff, $f0, $03, $00, $10, $02, $00, $10, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7f, $00, $00
		.byte	$ff, $80, $01, $ff, $c0, $01, $ff, $e0, $01, $ff, $f0, $01, $ff, $f0, $01, $ff
		.byte	$f8, $01, $ff, $f8, $03, $ff, $fc, $03, $ff, $fc, $07, $ff, $fc, $0f, $ff, $ee
		.byte	$1f, $ff, $ee, $38, $00, $06, $60, $00, $06, $00, $00, $02, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7f, $00, $00
		.byte	$ff, $c0, $01, $ff, $e0, $01, $ff, $f0, $01, $ff, $f8, $01, $ff, $fc, $01, $ff
		.byte	$fe, $03, $ff, $fe, $07, $ff, $fe, $0f, $ff, $ef, $1d, $ff, $e7, $39, $ff, $e7
		.byte	$71, $ff, $e7, $c0, $00, $03, $00, $00, $03, $00, $00, $01, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7f, $00, $00
		.byte	$ff, $80, $01, $ff, $c0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff
		.byte	$e0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff, $e0, $01, $ff, $e0, $03, $ff, $e0
		.byte	$03, $ff, $e0, $06, $00, $60, $04, $00, $20, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $80, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40
		.byte	$00, $00, $70, $00, $00, $0e, $00, $00, $01, $c0, $00, $00, $78, $00, $00, $0f
		.byte	$00, $00, $01, $e0, $00, $00, $38, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08
		.byte	$00, $00, $0c, $00, $00, $03, $00, $00, $00, $c0, $00, $00, $38, $00, $00, $0e
		.byte	$00, $00, $03, $80, $00, $00, $e0, $00, $00, $38, $00, $00, $08, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $18, $00, $00, $e0, $00, $07, $00, $00, $38, $00, $01, $e0, $00, $0f, $00
		.byte	$00, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $40, $00, $01, $80, $00, $06, $00, $00, $18, $00, $00, $60, $00, $01, $c0
		.byte	$00, $07, $00, $00, $1c, $00, $00, $70, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $02, $00, $00, $04, $00
		.byte	$00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $20, $00, $00, $20, $00, $00, $20, $00, $00, $20, $00
		.byte	$00, $20, $00, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $08, $00, $00, $04, $00, $00, $02, $00, $00, $01
		.byte	$00, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $00
		.byte	$60, $00, $00, $18, $00, $00, $06, $00, $00, $01, $80, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $00, $00
		.byte	$e0, $00, $00, $1c, $00, $00, $03, $80, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $07, $ff, $f0, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $1c, $00, $00, $e0, $00, $07, $00, $00, $38, $00, $01
		.byte	$c0, $00, $0e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $04, $00, $00, $0c, $00, $00, $18, $00, $00, $30, $00, $00, $60, $00
		.byte	$00, $c0, $00, $01, $00, $00, $02, $00, $00, $04, $00, $00, $08, $00, $00, $10
		.byte	$00, $00, $60, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $40, $00, $00, $40, $00, $00, $40, $00, $00, $20, $00, $00, $20, $00, $00
		.byte	$20, $00, $00, $10, $00, $00, $10, $00, $00, $10, $00, $00, $08, $00, $00, $08
		.byte	$00, $00, $08, $00, $00, $04, $00, $00, $04, $00, $00, $06, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$80, $00, $00, $40, $00, $00, $20, $00, $00, $10, $00, $00, $08, $00, $00, $04
		.byte	$00, $00, $02, $00, $00, $01, $00, $00, $00, $80, $00, $00, $40, $00, $00, $20
		.byte	$00, $00, $10, $00, $00, $08, $00, $00, $06, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $00, $00, $0c, $00, $00, $03
		.byte	$00, $00, $00, $c0, $00, $00, $30, $00, $00, $0c, $00, $00, $03, $00, $00, $00
		.byte	$c0, $00, $00, $30, $00, $00, $0c, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$20, $00, $00, $40, $00, $00, $80, $00, $01, $00, $00, $02, $00, $00, $04, $00
		.byte	$00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $18, $00, $00, $10, $00, $00, $10, $00, $00, $10, $00, $00, $10, $00, $00
		.byte	$10, $00, $00, $10, $00, $00, $10, $00, $00, $10, $00, $00, $10, $00, $00, $10
		.byte	$00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
; unreferenced records
unknown_5900:
		.byte	$00, $0c, $28, $32, $00, $00, $09, $15, $22, $14, $1d, $26, $02, $00, $00, $09
		.byte	$18, $00, $04, $00, $08, $28, $33, $00, $00, $09, $15, $22, $15, $1d, $26, $02
		.byte	$00, $00, $09, $18, $00, $04, $00, $06, $2c, $34, $00, $00, $09, $15, $22, $16
		.byte	$1d, $26, $02, $00, $00, $09, $18, $00, $04, $00, $05, $1e, $35, $00, $00, $09
		.byte	$15, $22, $17, $1d, $26, $02, $00, $00, $09, $18, $00, $04, $00, $05, $11, $36
		.byte	$00, $00, $09, $15, $22, $18, $1d, $26, $02, $00, $00, $09, $18, $00, $04, $00
		.byte	$08, $07, $37, $00, $00, $09, $15, $22, $19, $1d, $26, $02, $00, $00, $09, $18
		.byte	$00, $04, $00, $0d, $fa, $38, $00, $00, $09, $15, $22, $1a, $1d, $26, $02, $00
		.byte	$00, $09, $18, $00, $04, $00, $16, $f6, $39, $00, $00, $09, $1a, $1e, $1b, $1d
		.byte	$26, $02, $00, $00, $09, $18, $00, $04, $00, $28, $f4, $3a, $00, $00, $09, $1a
		.byte	$1e, $1c, $1d, $26, $02, $00, $00, $09, $18, $00, $04, $00, $34, $f4, $3b, $11
		.byte	$1e, $1d, $29, $1e, $1e, $1d, $26, $02, $00, $00, $09, $18, $00, $04, $00, $33
		.byte	$02, $3c, $11, $1e, $1d, $29, $1e, $1f, $1d, $26, $02, $00, $00, $09, $18, $00
		.byte	$04, $00, $33, $18, $37, $11, $1e, $1d, $29, $1e, $20, $1d, $26, $02, $00, $00
		.byte	$09, $18, $00, $04, $00, $2e, $2f, $3d, $11, $1e, $1d, $29, $1e, $21, $1e, $26
		.byte	$03, $00, $00, $09, $18, $00, $04, $00, $18, $38, $34, $00, $00, $09, $16, $22
		.byte	$22, $1c, $2a, $01, $00, $00, $09, $18, $00, $05, $00, $0f, $34, $34, $00, $00
		.byte	$09, $16, $22, $23, $1c, $2a, $01, $00, $00, $09, $18, $00, $06, $00, $1d, $21
		.byte	$2f, $00, $00, $09, $15, $22, $24, $18, $2c, $01, $00, $00, $09, $18, $00, $07
		.byte	$00, $00, $00, $09, $00, $00, $09, $16, $22, $25, $16, $2e, $01, $00, $00, $09
		.byte	$18, $00, $08, $00, $09, $12, $34, $00, $00, $09, $16, $22, $26, $15, $2e, $01
		.byte	$00, $00, $09, $18, $00, $08, $fc, $12, $0e, $2e, $00, $00, $09, $16, $22, $29
		.byte	$16, $2e, $00, $00, $00, $09, $18, $00, $11, $00, $15, $0c, $2d, $00, $00, $09
		.byte	$14, $22, $28, $14, $2e, $00, $00, $00, $09, $0f, $00, $0a, $fe, $19, $0e, $30
		.byte	$00, $00, $09, $12, $22, $2c, $12, $2e, $00, $00, $00, $09, $11, $00, $0b, $ff
		.byte	$1d, $0e, $30, $00, $00, $09, $11, $22, $2a, $11, $2e, $00, $00, $00, $09, $11
		.byte	$00, $0c, $fa, $1e, $0c, $30, $00, $00, $09, $12, $22, $2b, $12, $2e, $00, $07
		.byte	$00, $0d, $1f, $00, $0e, $fb, $1d, $0c, $30, $00, $00, $09, $12, $22, $2a, $12
		.byte	$2e, $00, $09, $00, $0f, $1b, $00, $10, $fd, $18, $0d, $30, $00, $00, $09, $12
		.byte	$22, $2c, $12, $2e, $00, $00, $00, $09, $14, $00, $11, $fa, $17, $0b, $2d, $00
		.byte	$00, $09, $16, $22, $28, $16, $2e, $00, $00, $00, $09, $11, $00, $0a, $00, $0d
		.byte	$0c, $2d, $00, $00, $09, $12, $22, $29, $12, $2e, $00, $00, $00, $09, $11, $00
		.byte	$0b, $ff, $09, $0e, $2e, $00, $00, $09, $11, $22, $2a, $11, $2e, $00, $00, $00
		.byte	$09, $11, $00, $0c, $fb, $07, $12, $2f, $00, $00, $09, $12, $22, $2b, $12, $2e
		.byte	$00, $07, $00, $0d, $1f, $00, $0e, $fb, $09, $0e, $2e, $00, $00, $09, $12, $22
		.byte	$2a, $12, $2e, $00, $09, $00, $0f, $1b, $00, $10, $fd, $0d, $0d, $2e, $00, $00
		.byte	$09, $12, $22, $29, $12, $2e, $00, $00, $00, $09, $14, $00, $11, $fa, $17, $0c
		.byte	$2d, $00, $00, $09, $16, $22, $28, $16, $2e, $00, $00, $00, $09, $11, $00, $0a
		.byte	$00, $09, $15, $2f, $00, $00, $09, $12, $22, $12, $16, $2e, $00, $00, $00, $09
		.byte	$11, $00, $0a, $00, $08, $19, $3e, $00, $00, $09, $12, $22, $13, $16, $2e, $00
		.byte	$00, $00, $09, $11, $00, $0a, $00, $01, $0e, $33, $00, $00, $09, $12, $22, $12
		.byte	$16, $2e, $00, $00, $00, $09, $11, $00, $0a, $00, $00, $00, $09, $00, $00, $09
		.byte	$16, $22, $28, $16, $2e, $00, $00, $00, $09, $11, $00, $0a, $06, $00, $00, $09
		.byte	$00, $00, $09, $12, $22, $29, $12, $2e, $00, $00, $00, $09, $14, $00, $11, $00
		.byte	$00, $00, $09, $00, $00, $09, $16, $22, $26, $15, $2e, $01, $00, $00, $09, $18
		.byte	$00, $08, $00, $00, $00, $09, $00, $00, $09, $12, $22, $29, $12, $2e, $00, $00
		.byte	$00, $09, $14, $00, $11, $fa, $00, $00, $09, $00, $00, $09, $16, $22, $28, $16
		.byte	$2e, $00, $00, $00, $09, $11, $00, $0a, $00, $01, $0e, $33, $00, $00, $09, $12
		.byte	$22, $12, $16, $2e, $00, $00, $00, $09, $11, $00, $0a, $00, $08, $19, $3e, $00
		.byte	$00, $09, $12, $22, $13, $16, $2e, $00, $00, $00, $09, $11, $00, $0a, $00, $09
		.byte	$15, $2f, $00, $00, $09, $12, $22, $12, $16, $2e, $00, $00, $00, $09, $11, $00
		.byte	$0a, $06, $00, $00, $09, $00, $00, $09, $12, $22, $29, $12, $2e, $00, $00, $00
		.byte	$09, $14, $00, $11, $00, $00, $00, $09, $00, $00, $09, $16, $22, $26, $15, $2e
		.byte	$01, $00, $00, $09, $18, $00, $08, $00
unused_5c58:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $7d, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $7d, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $7d, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $7d, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $7d, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00

.virtual $6000
; the multicolor bitmap, drawn at run time
; read by: check_terrain, $b626, $b62f
; written by: scroll_text, $b629, $b632
bitmap:
		.fill	8000
.endv

*=$7f40

; the tamper check at $aa0b compares this table
; read by: tamper_check
data_pointers:
		.addr	font, shapes, terrain_pointers, hole_shapes, pointers_9421, pointers_9419, shapes2

font:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $38, $38, $38, $38, $00, $38, $38, $00
		.byte	$6c, $6c, $24, $6c, $00, $00, $00, $00, $48, $fc, $fc, $48, $fc, $fc, $48, $00
		.byte	$30, $fc, $c0, $fc, $0c, $fc, $30, $00, $00, $e4, $e8, $f0, $3c, $5c, $9c, $00
		.byte	$60, $90, $40, $20, $54, $88, $74, $00, $30, $30, $10, $30, $00, $00, $00, $00
		.byte	$1c, $38, $70, $70, $70, $38, $1c, $00, $70, $38, $1c, $1c, $1c, $38, $70, $00
		.byte	$10, $54, $38, $7c, $38, $54, $10, $00, $30, $30, $fc, $fc, $30, $30, $00, $00
		.byte	$00, $00, $00, $00, $00, $38, $18, $30, $00, $00, $7c, $7c, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $38, $38, $00, $06, $0e, $1c, $38, $70, $e0, $c0, $00
		.byte	$78, $cc, $cc, $cc, $cc, $cc, $78, $00, $3c, $6c, $cc, $0c, $0c, $0c, $0c, $00
		.byte	$78, $fc, $cc, $1c, $70, $fc, $fc, $00, $78, $fc, $0c, $7c, $0c, $fc, $78, $00
		.byte	$1c, $3c, $6c, $cc, $fc, $0c, $0c, $00, $fc, $fc, $c0, $f8, $0c, $fc, $78, $00
		.byte	$38, $60, $c0, $f8, $cc, $cc, $78, $00, $fc, $fc, $0c, $18, $30, $30, $30, $00
		.byte	$78, $fc, $cc, $78, $cc, $fc, $78, $00, $78, $fc, $cc, $7c, $0c, $7c, $78, $00
		.byte	$00, $38, $38, $00, $00, $38, $38, $00, $00, $38, $38, $00, $00, $38, $18, $30
		.byte	$0e, $1c, $38, $70, $38, $1c, $0e, $00, $00, $7c, $7c, $00, $7c, $7c, $00, $00
		.byte	$e0, $70, $38, $1c, $38, $70, $e0, $00, $78, $fc, $cc, $18, $30, $00, $30, $00
		.byte	$fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $78, $fc, $cc, $fc, $fc, $cc, $cc, $00
		.byte	$f8, $fc, $cc, $f8, $cc, $fc, $f8, $00, $78, $fc, $cc, $c0, $cc, $fc, $78, $00
		.byte	$f8, $fc, $cc, $cc, $cc, $fc, $f8, $00, $fc, $fc, $c0, $f8, $c0, $fc, $fc, $00
		.byte	$fc, $fc, $c0, $f8, $f8, $c0, $c0, $00, $78, $fc, $c0, $dc, $cc, $fc, $78, $00
		.byte	$cc, $cc, $cc, $fc, $fc, $cc, $cc, $00, $fc, $fc, $30, $30, $30, $fc, $fc, $00
		.byte	$0c, $0c, $0c, $0c, $cc, $fc, $78, $00, $cc, $dc, $f8, $f0, $f8, $dc, $cc, $00
		.byte	$c0, $c0, $c0, $c0, $c0, $fc, $fc, $00, $c6, $ee, $d6, $c6, $c6, $c6, $c6, $00
		.byte	$cc, $cc, $ec, $fc, $dc, $cc, $cc, $00, $78, $fc, $cc, $cc, $cc, $fc, $78, $00
		.byte	$f8, $fc, $cc, $fc, $f8, $c0, $c0, $00, $78, $fc, $c4, $c4, $d4, $c8, $74, $00
		.byte	$f8, $fc, $cc, $fc, $f8, $dc, $cc, $00, $78, $fc, $c0, $78, $0c, $fc, $78, $00
		.byte	$fc, $fc, $30, $30, $30, $30, $30, $00, $cc, $cc, $cc, $cc, $cc, $fc, $78, $00
		.byte	$cc, $cc, $cc, $cc, $cc, $78, $30, $00, $c6, $c6, $c6, $d6, $d6, $ee, $c6, $00
		.byte	$cc, $cc, $78, $30, $78, $cc, $cc, $00, $cc, $cc, $cc, $78, $30, $30, $30, $00
		.byte	$fc, $fc, $18, $30, $60, $fc, $fc, $00, $f8, $f8, $c0, $c0, $c0, $f8, $f8, $00
		.byte	$c0, $e0, $70, $38, $1c, $0e, $06, $00, $f8, $f8, $18, $18, $18, $f8, $f8, $00
		.byte	$30, $78, $fc, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $fe
		.byte	$60, $30, $18, $0c, $00, $00, $00, $00, $00, $00, $78, $0c, $7c, $cc, $7c, $00
		.byte	$c0, $c0, $f8, $cc, $cc, $cc, $f8, $00, $00, $00, $78, $cc, $c0, $cc, $78, $00
		.byte	$0c, $0c, $7c, $cc, $cc, $cc, $7c, $00, $00, $00, $78, $cc, $f8, $c0, $78, $00
		.byte	$38, $6c, $60, $f8, $60, $60, $60, $00, $00, $00, $78, $cc, $cc, $7c, $0c, $78
		.byte	$c0, $c0, $f8, $cc, $cc, $cc, $cc, $00, $00, $30, $00, $30, $30, $30, $30, $00
		.byte	$0c, $00, $0c, $0c, $0c, $cc, $cc, $78, $c0, $c0, $cc, $d8, $f0, $d8, $cc, $00
		.byte	$70, $30, $30, $30, $30, $30, $78, $00, $00, $00, $fc, $da, $da, $da, $da, $00
		.byte	$00, $00, $f8, $cc, $cc, $cc, $cc, $00, $00, $00, $78, $cc, $cc, $cc, $78, $00
		.byte	$00, $00, $f8, $cc, $cc, $f8, $c0, $c0, $00, $00, $7c, $cc, $cc, $7c, $0c, $0c
		.byte	$00, $00, $f8, $cc, $c0, $c0, $c0, $00, $00, $00, $78, $c0, $78, $0c, $78, $00
		.byte	$60, $60, $f8, $60, $60, $6c, $38, $00, $00, $00, $cc, $cc, $cc, $cc, $7c, $00
		.byte	$00, $00, $cc, $cc, $cc, $78, $30, $00, $00, $00, $b6, $b6, $b6, $b6, $7e, $00
		.byte	$00, $00, $cc, $78, $30, $78, $cc, $00, $00, $00, $cc, $cc, $cc, $7c, $0c, $78
		.byte	$00, $00, $fc, $18, $30, $60, $fc, $00, $38, $78, $60, $e0, $60, $78, $38, $00
		.byte	$30, $30, $30, $30, $30, $30, $30, $30, $70, $78, $18, $1c, $18, $78, $70, $00
		.byte	$00, $00, $14, $28, $00, $00, $00, $00, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe

; 7 rows of 7 pointers; the 8th word of each row is unused
; read by: find_cell
terrain_pointers:
		.word	$931b, $9327, $9340, $934d, $9359, $9382, $93bd, $b3cc, $90bb, $9113, $9171, $919f, $91b8, $91ff, $9272, $1301
		.word	$8e06, $8e4f, $8e7d, $8f02, $8f4b, $8fc5, $9021, $a8cd, $8b3c, $8b9f, $8c75, $8cd9, $8d29, $8d5d, $8db2, $41f5
		.word	$88ba, $8904, $896c, $89d6, $8a01, $8a68, $8af0, $c9d1, $863b, $86b6, $8731, $876e, $87a1, $87ff, $8860, $54cc
		.word	$82bc, $8379, $8413, $8460, $84cd, $852a, $8562

; written by: decrunch
terrain_82bc:
		.byte	$00, $06, $38, $24, $06, $80, $03, $16, $0b, $03, $1c, $0b, $03, $22, $0b, $03
		.byte	$28, $05, $03, $30, $05, $03, $37, $0b, $08, $20, $01, $0e, $01, $09, $0d, $0f
		.byte	$0f, $0e, $27, $0a, $0c, $3e, $08, $10, $30, $03, $14, $1c, $07, $18, $34, $05
		.byte	$1b, $0e, $0b, $1c, $07, $04, $1c, $27, $05, $1c, $3c, $05, $1d, $0a, $00, $1e
		.byte	$0d, $02, $1f, $23, $03, $20, $0e, $02, $20, $30, $05, $21, $27, $03, $24, $2c
		.byte	$00, $26, $1c, $0a, $27, $37, $05, $2a, $35, $05, $2c, $2e, $03, $2e, $02, $07
		.byte	$2e, $3a, $05, $32, $30, $03, $32, $35, $05, $33, $37, $05, $35, $39, $03, $36
		.byte	$35, $03, $37, $0e, $00, $37, $16, $09, $37, $3d, $05, $38, $0a, $06, $38, $35
		.byte	$03, $38, $38, $05, $39, $06, $00, $3a, $36, $03, $3b, $39, $05, $3c, $34, $03
		.byte	$3c, $3f, $05, $3d, $01, $03, $3d, $07, $01, $3d, $37, $05, $3e, $04, $03, $3e
		.byte	$11, $01, $3e, $39, $05, $3e, $3f, $05, $3f, $14, $01, $3f, $35, $03, $80, $31
		.byte	$27, $07, $3d, $1f, $02, $37, $1b, $05, $80, $80, $80, $01, $80
terrain_8379:
		.byte	$01, $06, $80, $01, $32, $03, $02, $01, $03, $02, $0b, $0c, $02, $2f, $0c, $03
		.byte	$10, $03, $03, $18, $05, $03, $25, $03, $03, $2b, $05, $03, $3d, $0e, $05, $15
		.byte	$0a, $05, $1c, $03, $05, $20, $0c, $05, $27, $01, $06, $0e, $01, $06, $3c, $0c
		.byte	$07, $19, $05, $0a, $01, $01, $0f, $38, $05, $10, $08, $09, $14, $30, $01, $14
		.byte	$37, $0e, $18, $28, $0a, $1a, $2e, $03, $1c, $18, $08, $1c, $36, $03, $1c, $3f
		.byte	$04, $20, $39, $0b, $20, $3b, $0b, $20, $3d, $02, $23, $12, $0d, $25, $11, $02
		.byte	$25, $22, $02, $26, $0f, $02, $26, $20, $02, $27, $1e, $02, $29, $0e, $04, $2a
		.byte	$04, $01, $2a, $20, $05, $2a, $27, $05, $2b, $0b, $0b, $2c, $3d, $05, $32, $3d
		.byte	$05, $38, $08, $0f, $38, $38, $07, $3c, $20, $07, $3d, $3d, $0e, $3f, $2c, $02
		.byte	$80, $13, $01, $01, $80, $80, $80, $01, $02, $80
terrain_8413:
		.byte	$02, $06, $0c, $04, $06, $80, $02, $18, $08, $04, $10, $07, $08, $29, $0d, $08
		.byte	$3c, $03, $0c, $3a, $0c, $10, $3d, $03, $11, $0c, $08, $12, $19, $0d, $14, $30
		.byte	$08, $1b, $15, $07, $1b, $3e, $0b, $1f, $3e, $0d, $22, $3f, $02, $23, $32, $0b
		.byte	$24, $3f, $02, $26, $31, $0b, $28, $34, $0a, $30, $3f, $0f, $38, $3f, $06, $3f
		.byte	$3f, $0b, $80, $06, $0a, $07, $80, $02, $80, $80, $03, $04, $80
terrain_8460:
		.byte	$03, $06, $3d, $37, $06, $80, $04, $3b, $0d, $05, $3f, $02, $07, $3f, $02, $09
		.byte	$3f, $02, $0f, $3e, $08, $10, $20, $06, $10, $2a, $00, $16, $3f, $09, $17, $3b
		.byte	$07, $18, $0e, $05, $1a, $0f, $03, $1b, $0d, $0e, $1c, $0a, $0c, $1c, $27, $08
		.byte	$1d, $0f, $03, $1e, $0d, $03, $1e, $3f, $0f, $20, $0a, $05, $22, $3c, $04, $24
		.byte	$3f, $09, $25, $3d, $04, $29, $3f, $06, $2c, $3e, $0f, $2d, $27, $0d, $32, $26
		.byte	$02, $32, $3f, $03, $39, $2a, $0d, $3d, $3f, $02, $3f, $3e, $02, $80, $07, $24
		.byte	$0f, $35, $30, $05, $35, $3c, $14, $80, $02, $80, $80, $04, $80
terrain_84cd:
		.byte	$04, $06, $80, $02, $25, $0a, $03, $07, $03, $03, $31, $01, $04, $02, $05, $04
		.byte	$3e, $0b, $05, $32, $01, $07, $3f, $0f, $08, $18, $08, $08, $28, $07, $0b, $3f
		.byte	$09, $18, $38, $09, $1b, $26, $0d, $1c, $20, $02, $1d, $0f, $01, $1e, $06, $0a
		.byte	$20, $18, $09, $21, $3e, $0e, $25, $0b, $06, $27, $34, $02, $28, $10, $00, $28
		.byte	$3c, $0c, $2b, $34, $0b, $30, $18, $09, $30, $3e, $03, $33, $10, $07, $37, $22
		.byte	$0f, $3c, $2b, $08, $80, $80, $02, $03, $80, $80, $04, $05, $80
terrain_852a:
		.byte	$05, $06, $80, $10, $08, $07, $14, $2e, $01, $15, $31, $01, $20, $38, $03, $28
		.byte	$3e, $0c, $2b, $06, $08, $32, $37, $0a, $36, $33, $05, $38, $3e, $05, $3a, $31
		.byte	$03, $3a, $35, $01, $3c, $2f, $03, $3d, $32, $0c, $3f, $2e, $03, $3f, $31, $05
		.byte	$80, $80, $03, $04, $80, $80, $07, $80
terrain_8562:
		.byte	$06, $06, $24, $30, $06, $80, $01, $29, $0c, $01, $33, $03, $02, $2b, $0a, $02
		.byte	$2e, $01, $03, $28, $03, $03, $30, $0e, $05, $2d, $05, $07, $32, $01, $08, $2c
		.byte	$0a, $08, $38, $0e, $0c, $30, $05, $0d, $3a, $0a, $0f, $2e, $03, $10, $04, $06
		.byte	$10, $36, $0a, $11, $32, $05, $11, $3a, $03, $11, $3e, $05, $13, $33, $01, $14
		.byte	$39, $05, $16, $1a, $03, $16, $35, $03, $18, $1d, $01, $18, $38, $03, $18, $3c
		.byte	$05, $1a, $1a, $05, $1a, $39, $01, $1b, $1d, $0a, $1c, $3d, $05, $1d, $3a, $03
		.byte	$1f, $0a, $06, $20, $16, $06, $20, $20, $03, $21, $0f, $06, $22, $08, $09, $22
		.byte	$0c, $00, $22, $14, $06, $24, $13, $00, $24, $1d, $05, $25, $11, $06, $25, $3e
		.byte	$05, $26, $16, $06, $28, $3e, $03, $29, $1e, $03, $2b, $22, $01, $2c, $28, $0a
		.byte	$2c, $3c, $01, $2e, $2d, $03, $2f, $3e, $0a, $32, $3b, $03, $35, $3e, $0e, $3a
		.byte	$3e, $01, $3c, $08, $0b, $3c, $10, $0b, $3c, $18, $02, $3c, $20, $02, $3c, $28
		.byte	$02, $3e, $02, $06, $3e, $30, $04, $3e, $39, $0a, $3e, $3e, $05, $3f, $0d, $04
		.byte	$3f, $14, $0d, $80, $10, $1a, $07, $1d, $35, $07, $1f, $25, $07, $29, $0b, $06
		.byte	$29, $38, $04, $80, $80, $80, $07, $08, $80
terrain_863b:
		.byte	$00, $05, $80, $04, $3d, $00, $08, $02, $09, $08, $24, $0a, $09, $3f, $06, $0c
		.byte	$2e, $01, $1c, $04, $01, $1c, $0c, $0a, $1e, $18, $04, $1f, $14, $0b, $1f, $1c
		.byte	$01, $20, $08, $01, $20, $0f, $0b, $21, $15, $0b, $22, $2e, $06, $24, $25, $04
		.byte	$25, $2a, $09, $27, $27, $04, $2a, $30, $00, $30, $11, $03, $31, $3c, $06, $33
		.byte	$17, $05, $33, $35, $00, $34, $0f, $0c, $35, $20, $03, $36, $1b, $0c, $38, $13
		.byte	$0e, $38, $29, $07, $3b, $32, $09, $3c, $0e, $03, $3c, $11, $05, $3c, $1b, $07
		.byte	$3c, $3a, $05, $3d, $04, $0a, $3d, $2b, $0e, $3e, $31, $05, $3e, $36, $05, $3f
		.byte	$1d, $05, $80, $15, $38, $01, $80, $80, $80, $01, $80
terrain_86b6:
		.byte	$01, $05, $3a, $08, $06, $80, $01, $3e, $0c, $02, $19, $00, $02, $38, $05, $03
		.byte	$16, $03, $03, $34, $0e, $03, $3b, $05, $04, $22, $05, $04, $3e, $05, $05, $14
		.byte	$03, $07, $11, $0c, $07, $1d, $09, $08, $16, $03, $08, $39, $0c, $0f, $1a, $00
		.byte	$10, $34, $0a, $11, $2c, $08, $13, $1d, $0a, $14, $16, $06, $18, $27, $06, $19
		.byte	$1c, $00, $1b, $12, $07, $1c, $19, $09, $1d, $20, $07, $20, $14, $0f, $24, $0c
		.byte	$01, $28, $32, $0a, $2d, $05, $00, $2d, $2e, $01, $37, $1c, $04, $39, $1e, $0d
		.byte	$3c, $38, $06, $3d, $20, $02, $3e, $1e, $02, $3f, $1b, $02, $80, $2e, $0e, $05
		.byte	$39, $02, $05, $3d, $0f, $01, $80, $80, $80, $02, $80
terrain_8731:
		.byte	$02, $05, $80, $01, $02, $01, $02, $12, $0b, $03, $0e, $01, $03, $17, $07, $04
		.byte	$04, $07, $05, $11, $0b, $06, $03, $0d, $08, $0c, $0a, $0a, $02, $01, $0e, $03
		.byte	$0a, $14, $05, $01, $1d, $1f, $04, $3d, $0b, $03, $3e, $04, $03, $3e, $15, $05
		.byte	$80, $09, $35, $07, $12, $3e, $0b, $80, $02, $80, $80, $03, $80
terrain_876e:
		.byte	$03, $05, $80, $03, $12, $0e, $03, $1a, $03, $04, $04, $0a, $04, $0a, $05, $05
		.byte	$18, $0c, $06, $0f, $0c, $06, $1b, $05, $07, $16, $03, $08, $08, $01, $08, $19
		.byte	$0e, $0a, $0c, $03, $33, $2e, $07, $3c, $3c, $05, $3e, $3f, $0e, $80, $80, $02
		.byte	$80, $80, $80
terrain_87a1:
		.byte	$04, $05, $80, $03, $3e, $0c, $04, $34, $07, $06, $29, $05, $18, $3c, $00, $1c
		.byte	$0c, $03, $1e, $11, $05, $23, $38, $06, $2a, $33, $00, $2e, $32, $06, $2f, $3a
		.byte	$05, $30, $34, $09, $31, $2f, $00, $35, $20, $01, $38, $2c, $01, $38, $3c, $01
		.byte	$3a, $14, $0a, $3c, $18, $01, $3c, $28, $0a, $3c, $34, $0e, $3d, $0c, $03, $3d
		.byte	$0f, $03, $3f, $09, $05, $3f, $14, $05, $3f, $1c, $03, $3f, $22, $03, $80, $0b
		.byte	$36, $0a, $33, $29, $12, $36, $17, $06, $80, $02, $80, $80, $05, $80
terrain_87ff:
		.byte	$05, $05, $0c, $1f, $06, $80, $03, $3e, $0a, $04, $13, $01, $08, $08, $06, $0a
		.byte	$29, $01, $0e, $2a, $0a, $0e, $2d, $03, $10, $28, $03, $11, $31, $03, $12, $34
		.byte	$01, $13, $2e, $05, $15, $25, $0c, $15, $29, $05, $16, $22, $01, $16, $32, $05
		.byte	$16, $38, $0a, $1b, $1e, $00, $25, $08, $06, $2c, $14, $0f, $2e, $06, $00, $32
		.byte	$08, $06, $37, $35, $0d, $3c, $2d, $02, $3c, $2f, $0b, $3d, $32, $02, $3e, $34
		.byte	$02, $80, $06, $1b, $02, $0c, $25, $05, $14, $1a, $16, $80, $80, $80, $06, $07
		.byte	$80
terrain_8860:
		.byte	$06, $05, $80, $03, $2f, $0d, $08, $34, $07, $14, $09, $01, $20, $3c, $06, $24
		.byte	$38, $06, $26, $06, $0f, $26, $2b, $00, $26, $35, $06, $26, $3c, $09, $28, $32
		.byte	$09, $29, $38, $0f, $30, $14, $0f, $32, $21, $04, $34, $1b, $00, $36, $17, $00
		.byte	$38, $20, $09, $3a, $3e, $01, $3c, $12, $0f, $3c, $1d, $01, $3c, $24, $06, $3c
		.byte	$28, $08, $3c, $31, $04, $3c, $38, $0b, $3d, $2f, $02, $3e, $17, $0f, $80, $2a
		.byte	$27, $06, $37, $29, $12, $80, $80, $80, $08, $80
terrain_88ba:
		.byte	$00, $04, $80, $01, $2f, $02, $04, $2b, $02, $04, $3a, $00, $07, $27, $0b, $08
		.byte	$20, $07, $0a, $23, $0d, $0d, $17, $0e, $10, $28, $00, $11, $24, $00, $13, $32
		.byte	$0f, $15, $26, $09, $18, $1c, $07, $18, $27, $0a, $18, $3c, $07, $1d, $1c, $0b
		.byte	$1d, $2a, $08, $20, $08, $0f, $20, $20, $07, $26, $20, $0b, $28, $25, $08, $3c
		.byte	$39, $07, $80, $80, $01, $80, $02, $80, $01, $80
terrain_8904:
		.byte	$01, $04, $80, $02, $31, $0e, $04, $34, $03, $06, $2e, $05, $08, $18, $0f, $08
		.byte	$30, $03, $0a, $2b, $03, $0d, $29, $03, $0d, $2c, $02, $0d, $31, $08, $0e, $03
		.byte	$09, $10, $2c, $0b, $14, $04, $01, $18, $0c, $06, $19, $02, $06, $1b, $05, $00
		.byte	$1d, $30, $08, $20, $04, $09, $24, $08, $00, $24, $10, $0f, $28, $2b, $07, $28
		.byte	$30, $0f, $2f, $3f, $06, $34, $30, $08, $34, $38, $03, $34, $3c, $05, $38, $3c
		.byte	$03, $3a, $3a, $0c, $3c, $3d, $03, $3d, $36, $03, $3e, $32, $05, $3f, $3e, $05
		.byte	$80, $80, $01, $80, $03, $80, $02, $80
terrain_896c:
		.byte	$02, $04, $80, $02, $3a, $03, $04, $3e, $0e, $10, $0c, $06, $10, $14, $09, $12
		.byte	$18, $06, $14, $01, $09, $14, $10, $00, $16, $04, $06, $17, $0a, $06, $18, $01
		.byte	$06, $18, $0f, $06, $19, $03, $00, $1a, $05, $00, $1b, $03, $06, $1c, $0d, $06
		.byte	$1c, $10, $00, $1c, $14, $06, $1e, $04, $00, $1f, $0b, $00, $1f, $12, $06, $22
		.byte	$24, $08, $23, $0d, $09, $24, $02, $09, $29, $0b, $05, $2c, $18, $07, $30, $04
		.byte	$0b, $35, $0a, $0b, $3b, $0a, $0d, $3b, $30, $05, $3c, $32, $0a, $3d, $37, $01
		.byte	$3e, $04, $04, $80, $80, $01, $80, $03, $80, $80
terrain_89d6:
		.byte	$03, $04, $18, $08, $02, $80, $01, $3e, $01, $02, $10, $08, $02, $33, $03, $04
		.byte	$3a, $0a, $06, $36, $0c, $07, $3a, $03, $09, $3e, $05, $0c, $14, $09, $13, $16
		.byte	$06, $17, $12, $00, $80, $80, $02, $80, $04, $80, $80
terrain_8a01:
		.byte	$04, $04, $1c, $0c, $00, $80, $10, $30, $05, $10, $38, $05, $11, $35, $03, $14
		.byte	$2c, $03, $14, $2e, $0c, $15, $35, $0c, $18, $24, $03, $18, $30, $05, $1a, $2f
		.byte	$01, $1c, $28, $0e, $1c, $2c, $03, $1e, $32, $05, $1e, $36, $0a, $20, $28, $03
		.byte	$21, $2f, $03, $22, $35, $0c, $23, $2d, $05, $24, $32, $03, $26, $2a, $03, $26
		.byte	$2e, $0a, $27, $22, $01, $27, $26, $0a, $2a, $2a, $01, $2b, $22, $0b, $2c, $11
		.byte	$07, $2c, $27, $07, $2e, $20, $0d, $2f, $23, $04, $80, $2f, $19, $0e, $39, $08
		.byte	$08, $80, $02, $80, $80, $05, $80
terrain_8a68:
		.byte	$05, $04, $01, $0c, $06, $80, $05, $27, $00, $09, $02, $0a, $0c, $01, $05, $0c
		.byte	$38, $0b, $0d, $09, $06, $0e, $26, $0b, $0f, $03, $00, $10, $18, $06, $10, $20
		.byte	$0b, $10, $3c, $0d, $12, $10, $00, $14, $34, $04, $15, $38, $08, $16, $01, $01
		.byte	$18, $05, $00, $1a, $07, $09, $1b, $01, $06, $24, $0c, $03, $24, $14, $05, $26
		.byte	$06, $03, $27, $3c, $00, $28, $12, $03, $29, $01, $06, $29, $3d, $03, $2a, $0b
		.byte	$05, $2a, $14, $0c, $2b, $04, $0c, $2c, $1e, $03, $2d, $12, $05, $2f, $03, $03
		.byte	$2f, $1a, $0e, $30, $09, $06, $32, $0f, $06, $33, $1b, $0c, $34, $0a, $06, $3a
		.byte	$1a, $05, $3b, $20, $03, $3e, $18, $0e, $80, $02, $33, $12, $06, $15, $10, $08
		.byte	$0c, $02, $80, $80, $80, $05, $06, $80
terrain_8af0:
		.byte	$06, $04, $08, $28, $06, $80, $01, $1b, $0c, $04, $18, $05, $07, $1c, $03, $08
		.byte	$04, $0f, $0a, $1e, $04, $0c, $1e, $03, $12, $2b, $0b, $14, $29, $07, $2e, $21
		.byte	$06, $36, $01, $09, $38, $1c, $00, $3b, $35, $04, $3c, $38, $04, $3e, $27, $0d
		.byte	$3e, $33, $04, $3f, $06, $06, $3f, $0e, $06, $3f, $15, $06, $80, $08, $37, $05
		.byte	$09, $3e, $08, $16, $33, $0f, $80, $80, $80, $08, $09, $80
terrain_8b3c:
		.byte	$00, $03, $12, $01, $01, $80, $01, $06, $03, $02, $14, $03, $03, $09, $05, $03
		.byte	$28, $05, $04, $3a, $03, $06, $0e, $05, $06, $15, $01, $08, $18, $0a, $0a, $0b
		.byte	$03, $0b, $11, $0c, $0b, $16, $05, $0c, $1f, $01, $0c, $38, $05, $0e, $2c, $0d
		.byte	$10, $29, $07, $19, $02, $08, $1a, $35, $0a, $20, $10, $0f, $21, $35, $00, $2c
		.byte	$36, $07, $2e, $3a, $0b, $33, $36, $0b, $34, $0c, $06, $36, $0f, $00, $38, $0c
		.byte	$08, $38, $30, $0b, $3b, $0e, $01, $3c, $2c, $08, $3f, $37, $0b, $80, $80, $80
		.byte	$01, $80, $80
terrain_8b9f:
		.byte	$01, $03, $80, $02, $31, $0b, $06, $2f, $00, $06, $37, $0b, $09, $33, $0b, $0a
		.byte	$3f, $01, $0b, $31, $06, $0c, $2c, $06, $0e, $39, $0b, $0f, $3e, $06, $10, $34
		.byte	$0b, $12, $30, $00, $13, $21, $06, $13, $3f, $08, $14, $29, $09, $15, $3a, $0b
		.byte	$16, $26, $00, $17, $22, $09, $17, $2e, $00, $17, $35, $0b, $1a, $27, $06, $1a
		.byte	$32, $06, $1c, $1d, $06, $1c, $22, $00, $1c, $2b, $09, $1c, $3c, $0b, $1d, $36
		.byte	$0b, $1e, $26, $06, $1e, $32, $06, $1f, $21, $00, $1f, $2e, $06, $20, $2a, $06
		.byte	$22, $1c, $09, $22, $25, $09, $22, $2e, $00, $22, $34, $00, $23, $29, $0a, $24
		.byte	$22, $06, $24, $31, $09, $24, $39, $07, $25, $26, $00, $26, $2d, $00, $27, $24
		.byte	$09, $27, $29, $00, $27, $35, $06, $28, $3c, $0b, $29, $1b, $06, $29, $2c, $06
		.byte	$2b, $0f, $00, $2b, $21, $09, $2c, $07, $08, $2e, $25, $06, $2f, $16, $00, $30
		.byte	$1d, $09, $31, $22, $00, $33, $14, $06, $33, $26, $09, $34, $1d, $06, $35, $0f
		.byte	$07, $35, $22, $06, $36, $07, $00, $36, $18, $06, $38, $1c, $01, $39, $15, $00
		.byte	$3a, $19, $00, $3b, $21, $00, $3c, $14, $06, $3e, $19, $09, $3e, $1e, $06, $80
		.byte	$80, $80, $03, $80, $11, $80
terrain_8c75:
		.byte	$02, $03, $80, $02, $1c, $06, $06, $1e, $00, $0c, $22, $0b, $0c, $28, $04, $0d
		.byte	$08, $08, $0e, $02, $01, $12, $0c, $06, $13, $2d, $01, $14, $04, $00, $14, $34
		.byte	$03, $18, $03, $01, $18, $14, $00, $19, $32, $07, $1a, $39, $03, $1b, $1c, $05
		.byte	$1b, $22, $0c, $1b, $35, $05, $1b, $3f, $06, $1d, $18, $03, $1e, $2e, $03, $1e
		.byte	$3f, $00, $1f, $38, $09, $1f, $3d, $06, $23, $3c, $00, $2c, $22, $09, $2c, $30
		.byte	$0f, $38, $10, $0f, $3f, $34, $06, $80, $04, $03, $12, $3c, $26, $16, $80, $80
		.byte	$80, $10, $11, $80
terrain_8cd9:
		.byte	$03, $03, $0b, $28, $06, $10, $3e, $03, $80, $01, $36, $06, $04, $3b, $00, $08
		.byte	$34, $08, $08, $38, $0b, $0c, $38, $0b, $0e, $36, $04, $10, $30, $06, $10, $38
		.byte	$0b, $13, $23, $09, $14, $2c, $00, $1a, $0c, $00, $1c, $21, $06, $20, $0b, $08
		.byte	$28, $1b, $00, $2c, $18, $06, $33, $19, $09, $38, $10, $06, $3e, $02, $0d, $3e
		.byte	$0a, $07, $80, $04, $2f, $07, $07, $1e, $03, $80, $02, $80, $04, $80, $10, $80
terrain_8d29:
		.byte	$04, $03, $18, $0c, $00, $80, $22, $02, $0b, $29, $15, $07, $30, $2c, $08, $32
		.byte	$32, $06, $34, $3a, $0a, $36, $31, $06, $36, $36, $01, $39, $3e, $07, $3a, $3a
		.byte	$00, $3d, $36, $05, $3e, $30, $03, $3f, $02, $06, $3f, $3b, $01, $80, $80, $02
		.byte	$80, $80, $0e, $80
terrain_8d5d:
		.byte	$05, $03, $1c, $34, $06, $80, $03, $39, $06, $03, $3d, $06, $04, $0d, $00, $05
		.byte	$36, $09, $05, $3f, $0c, $06, $3c, $01, $0a, $3e, $03, $0b, $21, $01, $0d, $36
		.byte	$01, $0e, $27, $00, $0e, $3d, $06, $10, $1c, $06, $13, $22, $09, $1b, $21, $06
		.byte	$1c, $0c, $08, $1e, $28, $07, $22, $03, $01, $2c, $0f, $06, $37, $2e, $08, $80
		.byte	$23, $2b, $15, $28, $3a, $04, $2d, $35, $0e, $3c, $10, $0a, $3c, $1c, $12, $80
		.byte	$80, $80, $0d, $0e, $80
terrain_8db2:
		.byte	$06, $03, $80, $05, $04, $0b, $08, $18, $06, $0e, $23, $0f, $14, $1b, $09, $19
		.byte	$30, $08, $1c, $36, $07, $22, $01, $09, $24, $2d, $00, $28, $10, $08, $29, $33
		.byte	$0d, $2e, $13, $00, $30, $17, $06, $30, $28, $09, $34, $15, $02, $36, $1c, $07
		.byte	$3a, $05, $0d, $3c, $14, $0b, $3d, $01, $0b, $3d, $08, $0b, $3d, $2f, $0b, $3e
		.byte	$22, $0b, $3e, $2c, $0b, $80, $10, $03, $05, $2c, $1a, $01, $36, $2b, $0a, $80
		.byte	$80, $80, $09, $80
terrain_8e06:
		.byte	$00, $02, $14, $30, $06, $80, $01, $18, $07, $01, $24, $0b, $01, $3b, $0b, $02
		.byte	$37, $0b, $04, $0c, $08, $0a, $20, $08, $0b, $33, $0d, $10, $15, $02, $12, $11
		.byte	$0b, $14, $23, $0d, $18, $01, $0d, $18, $03, $0d, $2d, $2d, $07, $2f, $3b, $00
		.byte	$34, $32, $06, $3e, $0b, $0a, $80, $0e, $29, $0c, $1b, $1d, $0c, $23, $30, $16
		.byte	$25, $21, $05, $80, $80, $01, $80, $12, $80
terrain_8e4f:
		.byte	$01, $02, $80, $05, $02, $00, $06, $1d, $06, $16, $0b, $03, $19, $01, $0a, $1c
		.byte	$10, $03, $21, $04, $0e, $24, $0f, $0c, $24, $15, $05, $2c, $02, $05, $3f, $2c
		.byte	$0b, $80, $0c, $15, $16, $2f, $3c, $16, $80, $80, $80, $11, $12, $80
terrain_8e7d:
		.byte	$02, $02, $38, $38, $04, $80, $02, $2f, $0d, $03, $06, $0f, $03, $28, $07, $03
		.byte	$34, $0d, $04, $20, $01, $07, $32, $09, $08, $3c, $0b, $09, $26, $09, $0a, $2f
		.byte	$0a, $0c, $39, $0a, $0d, $34, $00, $10, $2c, $00, $11, $25, $06, $11, $30, $01
		.byte	$11, $38, $00, $13, $35, $01, $13, $3f, $09, $14, $2a, $06, $14, $32, $00, $16
		.byte	$36, $01, $17, $30, $06, $17, $33, $01, $17, $39, $0a, $18, $36, $01, $1a, $2a
		.byte	$00, $1a, $38, $00, $1a, $3c, $0b, $1b, $32, $00, $1b, $35, $00, $1c, $3b, $0b
		.byte	$1d, $25, $01, $1d, $34, $00, $1f, $2d, $01, $23, $26, $09, $24, $30, $06, $28
		.byte	$22, $01, $2a, $35, $06, $2c, $29, $06, $2e, $20, $08, $38, $27, $07, $80, $80
		.byte	$06, $80, $80, $11, $80
terrain_8f02:
		.byte	$03, $02, $38, $30, $06, $80, $0c, $38, $0d, $0e, $3a, $0b, $10, $39, $07, $13
		.byte	$37, $0b, $14, $34, $07, $15, $37, $0b, $28, $20, $0b, $28, $24, $0b, $29, $22
		.byte	$03, $2e, $0c, $06, $2e, $11, $06, $30, $20, $08, $31, $0a, $08, $31, $13, $06
		.byte	$32, $0f, $07, $3f, $25, $06, $80, $32, $37, $09, $33, $02, $01, $37, $27, $15
		.byte	$3d, $3c, $05, $80, $06, $80, $80, $0f, $80
terrain_8f4b:
		.byte	$04, $02, $80, $03, $20, $0a, $04, $34, $0b, $09, $11, $08, $0b, $28, $0a, $0c
		.byte	$02, $07, $0c, $35, $0c, $0d, $2b, $01, $0f, $29, $03, $0f, $31, $03, $10, $2e
		.byte	$05, $10, $34, $03, $12, $36, $05, $13, $2b, $03, $13, $31, $0a, $14, $0e, $06
		.byte	$14, $18, $07, $15, $12, $06, $16, $02, $0a, $17, $32, $05, $17, $36, $01, $18
		.byte	$10, $06, $1a, $2e, $05, $1c, $31, $03, $1d, $35, $0a, $1d, $39, $00, $34, $2e
		.byte	$09, $37, $37, $01, $38, $28, $06, $3b, $39, $0a, $3c, $25, $00, $3d, $2b, $07
		.byte	$3e, $10, $07, $3e, $27, $06, $80, $07, $2e, $0a, $20, $2d, $02, $27, $0e, $05
		.byte	$36, $17, $06, $80, $05, $80, $80, $0e, $0f, $80
terrain_8fc5:
		.byte	$05, $02, $30, $04, $06, $80, $02, $22, $08, $03, $2e, $00, $06, $25, $09, $07
		.byte	$09, $0b, $0a, $18, $07, $0b, $16, $06, $18, $3c, $0d, $1c, $0e, $0f, $1f, $04
		.byte	$00, $21, $2f, $09, $24, $20, $0a, $25, $06, $06, $29, $0d, $06, $36, $19, $06
		.byte	$37, $1c, $00, $38, $21, $09, $39, $07, $07, $39, $1d, $06, $3a, $04, $08, $3a
		.byte	$1e, $06, $3a, $25, $0d, $3a, $2a, $06, $3c, $3f, $01, $3e, $08, $03, $3f, $02
		.byte	$05, $80, $36, $04, $02, $80, $05, $80, $80, $0c, $0d, $80
terrain_9021:
		.byte	$06, $02, $10, $04, $06, $80, $01, $06, $03, $02, $24, $06, $02, $2c, $09, $02
		.byte	$35, $0d, $02, $3b, $0b, $05, $0b, $0b, $05, $10, $0b, $06, $0d, $0d, $06, $18
		.byte	$0d, $07, $09, $0d, $07, $3d, $0d, $08, $38, $06, $09, $16, $07, $09, $1a, $0d
		.byte	$19, $26, $0f, $1c, $0b, $0a, $1d, $3f, $0f, $1f, $01, $01, $1f, $12, $0d, $20
		.byte	$0e, $08, $20, $16, $0d, $20, $2c, $00, $21, $13, $0b, $24, $19, $0b, $27, $1b
		.byte	$07, $2c, $07, $06, $2c, $34, $0c, $2e, $01, $06, $2e, $0e, $01, $2e, $31, $03
		.byte	$30, $36, $0e, $35, $06, $0a, $3a, $20, $03, $3a, $39, $0d, $3b, $25, $05, $3c
		.byte	$3b, $0b, $3c, $3e, $0d, $3d, $28, $0c, $3d, $35, $07, $3d, $38, $0b, $3e, $03
		.byte	$0c, $3e, $1f, $05, $3e, $22, $05, $80, $0a, $02, $02, $0e, $16, $01, $1a, $05
		.byte	$0b, $1a, $12, $13, $80, $80, $80, $09, $0a, $80
terrain_90bb:
		.byte	$00, $01, $80, $04, $38, $0b, $08, $04, $07, $08, $32, $08, $0a, $1e, $08, $16
		.byte	$2c, $06, $17, $26, $06, $18, $1c, $06, $19, $14, $06, $1a, $2a, $06, $1c, $1f
		.byte	$09, $1c, $24, $06, $1c, $27, $06, $1c, $2d, $06, $1c, $34, $06, $1f, $12, $06
		.byte	$1f, $25, $06, $1f, $29, $06, $20, $1e, $06, $20, $2d, $06, $21, $29, $06, $23
		.byte	$27, $06, $23, $2b, $06, $23, $33, $06, $24, $20, $06, $30, $3c, $0f, $3c, $08
		.byte	$08, $80, $80, $80, $01, $80, $12, $80
terrain_9113:
		.byte	$01, $01, $80, $06, $2c, $07, $08, $22, $0a, $0a, $26, $0b, $0d, $3d, $06, $16
		.byte	$12, $01, $18, $08, $0a, $1b, $0b, $01, $1e, $38, $01, $24, $34, $05, $25, $2c
		.byte	$03, $25, $3e, $03, $26, $2f, $05, $27, $25, $05, $28, $38, $0c, $29, $2f, $0c
		.byte	$2a, $29, $03, $2a, $33, $03, $2c, $2e, $0e, $2c, $38, $03, $2f, $2d, $05, $2f
		.byte	$31, $05, $31, $2d, $03, $31, $34, $0b, $33, $24, $0e, $34, $2c, $0c, $38, $20
		.byte	$03, $80, $3a, $38, $15, $3d, $05, $0e, $80, $80, $80, $11, $12, $80
terrain_9171:
		.byte	$02, $01, $80, $18, $04, $08, $18, $1c, $0f, $2c, $0b, $03, $2c, $16, $03, $32
		.byte	$11, $05, $34, $0f, $03, $34, $12, $03, $36, $0c, $05, $36, $14, $05, $37, $11
		.byte	$03, $80, $0a, $3a, $16, $0c, $0c, $12, $80, $06, $80, $80, $11, $80
terrain_919f:
		.byte	$03, $01, $80, $27, $34, $0b, $28, $38, $0b, $2a, $1e, $07, $2a, $31, $08, $80
		.byte	$37, $1d, $05, $80, $06, $80, $80, $0f, $80
terrain_91b8:
		.byte	$04, $01, $80, $07, $1e, $08, $09, $1f, $0f, $0a, $26, $00, $16, $33, $0c, $17
		.byte	$3e, $05, $18, $04, $0f, $18, $3a, $0e, $19, $31, $05, $19, $33, $03, $1e, $1a
		.byte	$09, $23, $1c, $08, $32, $01, $07, $37, $18, $06, $3b, $1a, $06, $3c, $28, $00
		.byte	$3c, $38, $0b, $3e, $35, $0b, $3f, $12, $00, $80, $06, $2e, $01, $28, $18, $05
		.byte	$80, $05, $80, $80, $0e, $0f, $80
terrain_91ff:
		.byte	$05, $01, $80, $02, $38, $0d, $04, $0a, $0f, $08, $3e, $04, $0e, $33, $06, $10
		.byte	$10, $0d, $10, $38, $06, $21, $3d, $07, $27, $07, $06, $2c, $24, $01, $30, $10
		.byte	$0a, $31, $1c, $01, $31, $24, $03, $33, $27, $0c, $34, $2e, $01, $35, $18, $05
		.byte	$35, $2b, $05, $36, $1a, $03, $36, $25, $05, $37, $37, $05, $38, $18, $03, $38
		.byte	$2a, $0e, $38, $2e, $03, $38, $31, $0a, $38, $3b, $0c, $3a, $38, $03, $3a, $3e
		.byte	$03, $3c, $27, $0a, $3c, $2c, $03, $3c, $39, $0c, $3d, $31, $05, $3d, $36, $05
		.byte	$3d, $3d, $0e, $80, $28, $1c, $05, $28, $3c, $15, $34, $3c, $07, $80, $05, $80
		.byte	$80, $0c, $80
terrain_9272:
		.byte	$06, $01, $80, $01, $22, $03, $01, $3b, $0c, $02, $20, $05, $02, $36, $03, $02
		.byte	$3f, $05, $04, $23, $0c, $04, $31, $01, $04, $34, $05, $04, $3d, $03, $06, $2d
		.byte	$0a, $07, $34, $0e, $09, $33, $0c, $09, $35, $03, $0b, $2e, $05, $0c, $34, $03
		.byte	$0c, $39, $00, $0d, $2a, $01, $0e, $31, $01, $11, $36, $03, $12, $2c, $05, $14
		.byte	$20, $05, $14, $31, $0a, $14, $34, $03, $17, $2d, $03, $18, $34, $05, $19, $2a
		.byte	$03, $1b, $2d, $03, $1b, $31, $0e, $1c, $35, $0c, $1d, $3c, $06, $1e, $2c, $05
		.byte	$1f, $1b, $0a, $1f, $24, $0c, $1f, $34, $03, $20, $31, $05, $20, $38, $0c, $21
		.byte	$04, $0d, $22, $36, $0b, $30, $34, $01, $33, $0b, $0d, $33, $31, $0a, $34, $34
		.byte	$07, $34, $37, $0b, $37, $36, $01, $38, $31, $03, $3c, $34, $05, $3d, $3d, $05
		.byte	$3e, $05, $0f, $3e, $0c, $06, $3e, $38, $0e, $80, $15, $3a, $09, $22, $0d, $03
		.byte	$2f, $18, $01, $80, $80, $80, $09, $0a, $80
terrain_931b:
		.byte	$00, $00, $80, $28, $30, $0f, $80, $80, $07, $80, $80, $80
terrain_9327:
		.byte	$01, $00, $80, $23, $3e, $0d, $25, $3b, $04, $25, $3d, $0d, $27, $3b, $0b, $80
		.byte	$3c, $3c, $13, $80, $07, $80, $80, $11, $80
terrain_9340:
		.byte	$02, $00, $04, $3e, $06, $80, $80, $80, $06, $80, $80, $11, $80
terrain_934d:
		.byte	$03, $00, $10, $28, $00, $80, $80, $80, $06, $80, $80, $80
terrain_9359:
		.byte	$04, $00, $24, $34, $06, $30, $08, $05, $80, $14, $3a, $06, $1b, $3e, $06, $1c
		.byte	$2a, $0d, $28, $28, $08, $3f, $0b, $07, $80, $22, $3c, $05, $2c, $3c, $12, $2d
		.byte	$2e, $0f, $80, $05, $80, $80, $0e, $0f, $80
terrain_9382:
		.byte	$05, $00, $10, $20, $06, $3c, $04, $00, $80, $04, $1a, $06, $05, $26, $06, $10
		.byte	$10, $08, $10, $2c, $07, $12, $2e, $06, $1c, $34, $0f, $22, $32, $09, $24, $3c
		.byte	$00, $28, $2f, $06, $32, $24, $0a, $80, $0a, $1e, $03, $10, $1a, $01, $16, $1c
		.byte	$0a, $16, $25, $11, $80, $05, $80, $80, $0b, $0c, $80
; read by: draw_terrain, setup_hole
terrain_93bd:
		.byte	$06, $00, $28, $14, $06, $80, $34, $0e, $0d, $36, $06, $08, $37, $1a, $0b, $38
		.byte	$28, $09, $39, $13, $0b, $3a, $3e, $07, $3d, $3c, $06, $3e, $30, $06, $3e, $3e
		.byte	$06, $3f, $2a, $00, $80, $24, $21, $15, $2c, $10, $07, $2f, $1d, $05, $34, $3c
		.byte	$12, $80, $05, $80, $80, $0a, $0b, $80
; 29 shapes, indexed from 1 through hole_shapes_base: 18 fairways with their greens,
; then 4 drawn in color 12 and 7 in color 14
; read by: draw_terrain, setup_hole
hole_shapes_base = $93f3

hole_shapes:
		.addr	shape_9477, shape_94c5, shape_9507, shape_9541, shape_9587, shape_9607, shape_9659, shape_969f, shape_970f, shape_9775, shape_97cb, shape_980b, shape_984d, shape_989d, shape_9907, shape_9963
		.addr	shape_99a9, shape_9a0f
pointers_9419:
		.addr	shape_9c36, shape_9c7b, shape_9c90, shape_9cb1
; read by: setup_hole
pointers_9421:
		.addr	shape_9a63, shape_9abc, shape_9b6d, shape_9b8e, shape_9ba9, shape_9bd0, shape_9c19
; per hole: two words, indexed from 1 by hole number through hole_positions_base
; read by: setup_hole
hole_positions_base = $942b

hole_positions:
		.word	$0038, $01a4, $007a, $0148, $008c, $0184, $00fd, $01b7, $0141, $010c, $014c, $015f, $01a4, $01b0, $0188, $0128
		.word	$0190, $0084, $01a8, $0014, $0150, $0020, $0170, $0084, $015c, $00f4, $0124, $0034, $00f8, $00b0, $00cb, $00e8
		.word	$0084, $003e, $0014, $00b0

shape_9477:
		.byte	$00, $04, $0d, $32, $00, $00, $00, $fe, $fe, $00, $fd, $0e, $fd, $1e, $fc, $26
		.byte	$fd, $2e, $01, $38, $05, $46, $0c, $4e, $13, $56, $1f, $76, $29, $7f, $32, $7f
		.byte	$33, $7c, $35, $77, $33, $6f, $31, $69, $26, $5c, $1f, $4e, $1c, $49, $13, $3c
		.byte	$11, $32, $0e, $28, $0c, $1e, $0b, $0f, $06, $06, $03, $ff, $80, $2b, $72, $03
		.byte	$05, $06, $01, $03, $fd, $fc, $fc, $fa, $fe, $fb, $01, $fe, $04, $80
shape_94c5:
		.byte	$01, $06, $05, $36, $00, $00, $02, $03, $05, $00, $0b, $f6, $15, $e2, $23, $ca
		.byte	$2b, $be, $2f, $a6, $3b, $98, $3f, $93, $3b, $8d, $39, $8a, $33, $88, $30, $8a
		.byte	$21, $9a, $1b, $aa, $0a, $ca, $07, $de, $03, $ee, $fd, $fe, $fd, $02, $80, $35
		.byte	$92, $03, $05, $06, $02, $05, $ff, $01, $fd, $fb, $fd, $f6, $00, $f9, $05, $ff
		.byte	$06, $80
shape_9507:
		.byte	$02, $05, $12, $0a, $00, $00, $ff, $fe, $f7, $06, $f2, $13, $f2, $23, $f4, $36
		.byte	$f2, $3c, $f4, $43, $f7, $44, $fc, $42, $01, $3d, $03, $36, $03, $2e, $05, $1e
		.byte	$0a, $06, $08, $02, $04, $fe, $80, $fa, $3a, $00, $06, $03, $02, $04, $fe, $03
		.byte	$fb, $ff, $fb, $fc, $fe, $fc, $02, $fd, $06, $80
shape_9541:
		.byte	$02, $06, $04, $1e, $00, $00, $ff, $02, $04, $06, $10, $0a, $1c, $0e, $34, $17
		.byte	$3c, $1a, $48, $1a, $5c, $1c, $6c, $1f, $7c, $1e, $7f, $1c, $7f, $16, $7c, $12
		.byte	$74, $10, $67, $0d, $4c, $0d, $3c, $06, $32, $06, $1c, $01, $10, $fd, $ff, $fd
		.byte	$80, $79, $19, $00, $03, $03, $02, $04, $00, $03, $fd, $ff, $fc, $fb, $fc, $f8
		.byte	$fd, $f9, $00, $fc, $02, $80
shape_9587:
		.byte	$04, $06, $10, $38, $00, $c8, $00, $3b, $04, $39, $08, $2e, $0a, $1e, $0b, $06
		.byte	$10, $00, $12, $f6, $1d, $f0, $25, $ec, $28, $e3, $29, $d8, $28, $d0, $29, $cd
		.byte	$2a, $c8, $2c, $c0, $30, $bc, $36, $b2, $3a, $a7, $39, $a1, $39, $9b, $3c, $93
		.byte	$3c, $8c, $39, $86, $34, $83, $30, $82, $2b, $82, $29, $84, $26, $88, $24, $8d
		.byte	$24, $94, $25, $9d, $25, $a3, $22, $a9, $1d, $b5, $1a, $c0, $18, $c8, $16, $d0
		.byte	$10, $d8, $04, $e2, $fe, $ea, $f8, $f5, $f6, $00, $f6, $04, $f8, $10, $fb, $28
		.byte	$fd, $39, $80, $31, $8c, $02, $07, $05, $02, $06, $fd, $05, $fa, $02, $f9, $ff
		.byte	$f9, $fc, $fa, $f9, $fe, $f7, $03, $f7, $06, $f9, $0a, $fd, $0b, $ff, $0a, $80
shape_9607:
		.byte	$05, $04, $18, $14, $00, $00, $00, $1c, $00, $22, $fe, $2c, $f4, $3c, $f0, $40
		.byte	$ec, $45, $eb, $4a, $ec, $50, $f0, $54, $f6, $54, $f9, $52, $fd, $4e, $00, $4c
		.byte	$06, $3c, $10, $34, $15, $2c, $16, $24, $13, $18, $08, $04, $04, $ff, $00, $fd
		.byte	$fc, $fe, $fc, $02, $fd, $0c, $80, $f4, $4b, $01, $04, $04, $03, $06, $00, $05
		.byte	$fd, $04, $f7, $02, $f6, $ff, $f7, $fd, $f9, $fc, $fc, $fb, $00, $fc, $03, $fe
		.byte	$04, $80
shape_9659:
		.byte	$05, $05, $04, $34, $00, $00, $05, $0c, $28, $28, $35, $2c, $3c, $32, $4c, $38
		.byte	$57, $43, $60, $48, $64, $48, $68, $45, $69, $3f, $64, $30, $52, $2a, $4c, $23
		.byte	$3c, $1c, $25, $13, $1c, $0c, $05, $fe, $fe, $fd, $fd, $00, $80, $60, $3c, $00
		.byte	$08, $02, $08, $04, $05, $05, $02, $05, $fd, $03, $f8, $00, $f6, $fd, $f8, $fb
		.byte	$fd, $fb, $02, $fd, $06, $80
shape_969f:
		.byte	$06, $06, $36, $32, $fa, $be, $02, $40, $05, $45, $07, $45, $0a, $43, $0a, $3c
		.byte	$09, $31, $08, $20, $08, $10, $0a, $02, $0b, $fc, $09, $f5, $02, $ea, $fe, $e4
		.byte	$fd, $e0, $fa, $d0, $ee, $c4, $e7, $c0, $e2, $bd, $df, $b8, $de, $b2, $dc, $b0
		.byte	$d7, $af, $d2, $b0, $d1, $b4, $d0, $ba, $d1, $c0, $d3, $c7, $d6, $d0, $dd, $d6
		.byte	$e6, $e0, $f2, $f0, $fb, $01, $fc, $08, $fa, $10, $f4, $18, $f4, $1c, $f8, $24
		.byte	$fa, $2b, $80, $d8, $b8, $00, $0c, $03, $0b, $05, $07, $06, $02, $05, $fd, $02
		.byte	$fa, $00, $f9, $fd, $f9, $fb, $fb, $fa, $ff, $fb, $06, $fc, $0a, $fe, $0c, $80
shape_970f:
		.byte	$06, $04, $20, $24, $f8, $9c, $08, $66, $0b, $65, $12, $60, $19, $51, $1d, $40
		.byte	$21, $35, $21, $2c, $20, $25, $1f, $20, $0f, $11, $03, $00, $04, $f0, $07, $e4
		.byte	$06, $dc, $06, $cf, $07, $c7, $04, $c0, $00, $be, $f8, $bc, $f2, $bd, $f0, $c0
		.byte	$f0, $c8, $ef, $d0, $ef, $d3, $f3, $d6, $f4, $e4, $f4, $00, $f6, $08, $08, $20
		.byte	$0c, $2c, $0c, $34, $08, $40, $04, $57, $04, $63, $06, $66, $80, $f8, $c4, $01
		.byte	$10, $05, $0d, $07, $08, $07, $01, $06, $fc, $02, $fa, $fe, $fa, $fc, $fc, $fa
		.byte	$05, $f9, $0b, $fa, $0f, $80
shape_9775:
		.byte	$06, $02, $28, $04, $00, $bc, $00, $47, $04, $44, $04, $40, $08, $30, $0a, $21
		.byte	$0a, $18, $06, $0f, $04, $06, $04, $00, $08, $fb, $0c, $f5, $0d, $ed, $0c, $e5
		.byte	$0a, $da, $09, $d0, $06, $cc, $01, $cb, $f9, $cf, $f7, $d5, $f6, $e2, $fa, $eb
		.byte	$f9, $f6, $f6, $00, $f6, $0c, $f9, $1c, $fb, $30, $fc, $3b, $fc, $40, $fd, $45
		.byte	$80, $00, $d4, $02, $08, $05, $06, $06, $02, $04, $fe, $00, $fc, $fc, $fd, $fa
		.byte	$01, $fa, $05, $fd, $07, $80
shape_97cb:
		.byte	$06, $00, $16, $14, $da, $0c, $00, $08, $10, $02, $20, $fb, $28, $f7, $29, $f4
		.byte	$28, $f2, $21, $f0, $10, $f2, $08, $f5, $f6, $f8, $f2, $f8, $e8, $f5, $dc, $f8
		.byte	$d8, $fd, $d8, $02, $da, $06, $de, $08, $e4, $07, $f0, $08, $80, $e0, $00, $03
		.byte	$05, $05, $01, $03, $fd, $00, $fc, $fc, $fd, $fb, $00, $fb, $04, $fe, $06, $80
shape_980b:
		.byte	$05, $00, $04, $30, $1c, $28, $00, $18, $04, $28, $08, $2f, $0d, $31, $13, $32
		.byte	$17, $2f, $18, $2b, $18, $28, $11, $18, $0d, $00, $fd, $f3, $f3, $e8, $e8, $d8
		.byte	$e5, $d5, $e2, $d6, $e2, $da, $e6, $e8, $f0, $fc, $fa, $05, $80, $10, $2c, $00
		.byte	$03, $03, $02, $04, $fe, $04, $fc, $02, $fa, $fe, $f9, $fb, $fc, $fa, $00, $fc
		.byte	$02, $80
shape_984d:
		.byte	$05, $02, $30, $14, $00, $2c, $02, $36, $04, $2f, $08, $28, $10, $20, $10, $16
		.byte	$0e, $0e, $0a, $00, $08, $ec, $05, $da, $03, $d3, $00, $d2, $fc, $d4, $fa, $e8
		.byte	$fc, $00, $fe, $10, $f4, $20, $f1, $28, $e8, $30, $e4, $34, $e3, $39, $e4, $3c
		.byte	$e8, $3f, $ed, $3f, $f5, $3d, $fe, $3a, $80, $ec, $34, $04, $08, $0a, $05, $0d
		.byte	$ff, $09, $fb, $02, $fa, $fd, $fd, $fb, $00, $fa, $04, $fb, $07, $fe, $09, $80
shape_989d:
		.byte	$05, $03, $08, $30, $e8, $90, $07, $60, $10, $6d, $14, $71, $18, $72, $1b, $71
		.byte	$1c, $6c, $1c, $66, $18, $60, $10, $53, $07, $40, $02, $32, $02, $26, $0a, $18
		.byte	$0c, $0d, $0b, $00, $08, $f0, $04, $d6, $03, $c8, $00, $c0, $00, $bc, $fe, $b3
		.byte	$f9, $ae, $f3, $ac, $ee, $ae, $ec, $b1, $ec, $b5, $ed, $bb, $f0, $c0, $f0, $c8
		.byte	$f1, $d3, $f6, $db, $fa, $f0, $f8, $00, $f2, $0e, $f0, $22, $ed, $2c, $f0, $38
		.byte	$f4, $40, $f8, $4a, $80, $f4, $b4, $00, $06, $05, $06, $08, $04, $07, $ff, $04
		.byte	$fb, $ff, $fa, $fc, $fc, $fb, $00, $fc, $04, $80
shape_9907:
		.byte	$04, $00, $10, $2c, $e8, $3c, $08, $50, $10, $4c, $13, $48, $12, $42, $0d, $3f
		.byte	$09, $38, $08, $28, $0b, $18, $0c, $0f, $0e, $0a, $11, $08, $12, $04, $10, $ff
		.byte	$0e, $f5, $18, $d8, $1d, $c4, $1b, $c0, $18, $c0, $13, $c3, $08, $da, $f9, $f4
		.byte	$f8, $08, $f8, $18, $fc, $28, $f9, $3a, $f3, $48, $f3, $4c, $f5, $50, $fc, $52
		.byte	$80, $00, $48, $05, $06, $0a, $03, $0c, $ff, $0c, $fb, $08, $f8, $04, $f8, $00
		.byte	$fb, $fa, $fa, $f8, $fc, $f7, $00, $f9, $04, $ff, $06, $80
shape_9963:
		.byte	$03, $03, $38, $08, $00, $00, $02, $02, $02, $fe, $fa, $fe, $ec, $04, $dc, $08
		.byte	$c8, $10, $c1, $18, $c0, $1e, $c3, $26, $c8, $2a, $cc, $2b, $d0, $2a, $d4, $27
		.byte	$d8, $24, $da, $22, $da, $1e, $d9, $1b, $da, $18, $f4, $0c, $80, $d3, $20, $00
		.byte	$05, $03, $03, $04, $00, $04, $fd, $01, $fa, $fd, $fa, $fa, $fb, $f8, $fd, $f7
		.byte	$01, $f9, $04, $fc, $06, $80
shape_99a9:
		.byte	$02, $03, $18, $2d, $e8, $93, $00, $54, $0d, $60, $11, $6a, $18, $70, $1d, $6f
		.byte	$1c, $68, $19, $60, $12, $50, $05, $40, $00, $38, $fd, $29, $00, $18, $0c, $00
		.byte	$0d, $f9, $0d, $f0, $0f, $d2, $10, $cc, $10, $c6, $0f, $c0, $08, $b7, $00, $b6
		.byte	$fc, $b6, $f7, $ba, $f7, $c0, $fa, $c8, $fc, $d7, $fc, $dc, $f6, $f0, $f3, $00
		.byte	$ed, $10, $ec, $20, $ea, $32, $ec, $40, $f0, $47, $80, $04, $be, $00, $0c, $04
		.byte	$0c, $08, $0a, $09, $07, $08, $02, $07, $ff, $04, $fc, $01, $fb, $fe, $fd, $fd
		.byte	$02, $fc, $06, $fd, $0a, $80
shape_9a0f:
		.byte	$01, $01, $24, $10, $dc, $30, $00, $24, $0f, $1c, $12, $17, $17, $00, $20, $f0
		.byte	$26, $dc, $27, $d1, $26, $cd, $23, $cc, $20, $cf, $18, $dc, $07, $f0, $00, $f8
		.byte	$fc, $00, $e7, $15, $dd, $20, $d0, $2a, $cd, $30, $cf, $36, $d6, $3b, $df, $3e
		.byte	$e2, $3c, $e6, $34, $e9, $2c, $f0, $28, $80, $d4, $30, $08, $0b, $0b, $0b, $0d
		.byte	$08, $0c, $04, $0a, $00, $0a, $fb, $09, $f8, $06, $f7, $01, $f9, $fd, $fd, $fc
		.byte	$00, $fe, $05, $80
shape_9a63:
		.byte	$01, $04, $18, $30, $00, $04, $04, $fc, $0c, $f8, $12, $f8, $1a, $f9, $24, $f7
		.byte	$2e, $f3, $38, $f1, $40, $f0, $48, $f0, $52, $f1, $5b, $f4, $68, $fa, $68, $ef
		.byte	$5c, $ee, $53, $ec, $48, $eb, $38, $ec, $28, $f0, $20, $f3, $0c, $f3, $01, $f8
		.byte	$f8, $05, $e6, $0b, $de, $09, $d5, $00, $c8, $f5, $b5, $ee, $b1, $e8, $a8, $d7
		.byte	$a8, $dc, $aa, $e1, $af, $eb, $b4, $f1, $bc, $f4, $c6, $f8, $d0, $00, $dc, $0c
		.byte	$e3, $0f, $e8, $0f, $f0, $0c, $f9, $0a, $80
shape_9abc:
		.byte	$03, $05, $20, $00, $00, $44, $07, $40, $0c, $3c, $0e, $37, $0e, $31, $10, $2c
		.byte	$1a, $24, $20, $24, $24, $23, $2f, $21, $34, $24, $39, $2a, $3c, $34, $42, $40
		.byte	$43, $3d, $3f, $35, $3c, $2a, $34, $20, $33, $1d, $38, $18, $37, $10, $34, $09
		.byte	$30, $05, $2c, $00, $2a, $f8, $2a, $f0, $2b, $e7, $2f, $df, $35, $dc, $3d, $db
		.byte	$42, $da, $45, $d8, $47, $d4, $48, $ce, $48, $c8, $46, $c0, $43, $b9, $43, $b3
		.byte	$45, $ad, $48, $a8, $49, $a0, $48, $98, $45, $8e, $40, $84, $40, $81, $26, $81
		.byte	$20, $8c, $14, $a0, $10, $a8, $09, $ae, $06, $b4, $04, $c0, $ff, $cc, $f8, $d5
		.byte	$f4, $d8, $e8, $db, $e0, $df, $e0, $ea, $e6, $ef, $ea, $f9, $ec, $00, $ed, $07
		.byte	$ec, $10, $ea, $18, $e8, $1c, $e5, $1d, $e0, $1c, $dc, $1a, $d3, $1c, $cc, $20
		.byte	$c0, $24, $b9, $28, $b7, $32, $b7, $38, $b8, $40, $ba, $4c, $c0, $58, $c4, $5c
		.byte	$ca, $5f, $d6, $62, $e0, $60, $e7, $59, $f0, $54, $f2, $51, $f4, $4b, $f8, $47
		.byte	$80
shape_9b6d:
		.byte	$04, $06, $28, $08, $04, $08, $0f, $13, $14, $19, $18, $24, $20, $2e, $2b, $38
		.byte	$2e, $38, $20, $2b, $18, $20, $15, $17, $0d, $0e, $06, $07, $fd, $f8, $fc, $fb
		.byte	$80
shape_9b8e:
		.byte	$05, $06, $30, $24, $05, $0a, $0c, $0a, $10, $08, $0e, $03, $08, $fe, $fe, $fb
		.byte	$f9, $fc, $f5, $ff, $f5, $02, $f8, $06, $fe, $09, $80
shape_9ba9:
		.byte	$05, $01, $00, $10, $fc, $b4, $00, $b2, $0d, $b2, $17, $b4, $24, $b8, $30, $ba
		.byte	$40, $b9, $50, $b5, $60, $b2, $70, $b0, $c0, $b0, $c0, $cc, $c8, $c0, $d8, $b8
		.byte	$ee, $b3, $f2, $b3, $f5, $b6, $80
shape_9bd0:
		.byte	$03, $01, $00, $00, $00, $68, $04, $68, $10, $60, $18, $58, $1c, $50, $20, $40
		.byte	$20, $30, $23, $24, $28, $14, $30, $08, $38, $00, $3a, $f8, $3c, $ec, $40, $dc
		.byte	$40, $c0, $c0, $c0, $c0, $e0, $cc, $e3, $e0, $ea, $ea, $f0, $ec, $f4, $ec, $00
		.byte	$f0, $04, $f8, $08, $fc, $10, $fc, $13, $fa, $16, $ec, $20, $e4, $30, $e2, $40
		.byte	$e2, $48, $e4, $50, $e8, $58, $f4, $64, $80
shape_9c19:
		.byte	$01, $00, $00, $08, $00, $11, $08, $15, $18, $18, $24, $19, $2c, $19, $40, $18
		.byte	$40, $f8, $c0, $f8, $d0, $00, $de, $02, $f0, $06, $f8, $0a, $80
shape_9c36:
		.byte	$00, $02, $0c, $0c, $04, $f4, $04, $d0, $f4, $b5, $f4, $ba, $01, $d1, $01, $f4
		.byte	$fa, $13, $fa, $23, $fe, $2e, $06, $34, $08, $3c, $06, $44, $04, $4c, $04, $54
		.byte	$09, $66, $0a, $6c, $0a, $74, $0c, $74, $0c, $6c, $0b, $66, $14, $66, $34, $69
		.byte	$34, $67, $15, $64, $0a, $64, $06, $54, $06, $4c, $0a, $3c, $08, $34, $ff, $2d
		.byte	$fc, $24, $fc, $14, $80
shape_9c7b:
		.byte	$00, $04, $14, $14, $01, $00, $04, $ec, $02, $ec, $ff, $00, $f8, $10, $ec, $21
		.byte	$ec, $24, $fa, $10, $80
shape_9c90:
		.byte	$01, $03, $18, $38, $00, $01, $08, $03, $10, $08, $20, $0f, $28, $10, $68, $10
		.byte	$68, $0e, $28, $0e, $20, $0d, $14, $08, $09, $01, $00, $ff, $e8, $fb, $e8, $fd
		.byte	$80
shape_9cb1:
		.byte	$03, $04, $08, $08, $00, $08, $0c, $08, $14, $00, $18, $f8, $10, $f4, $00, $f4
		.byte	$f8, $fe, $f8, $00, $80
unused_9cc6:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $fd, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
; leftover text
leftover_9ff1:
		.byte	$81, $50, $4e, $45, $57, $20, $30, $3a, $47, $4f, $4c, $47, $4f, $4c, $46

; jumped to by: start2
lA000:
		jmp main

; jumped to by: start2
lA003:
		lda cpu_port
		and #$fe
		sta cpu_port
		jsr lB5E8

; read by: l4345, random
vectors:
		.addr	add_stroke, update_scores, read_aim_cursor, read_joystick, lB49B, lB496, aim, lB5FC, lB08B, lB6F8
; read by: l4348
aA00E = $a00e
; read by: l32AD
aA010 = $a010
; read by: l32B0
aA012 = $a012
; read by: l434B
aA014 = $a014
; read by: l434E
aA016 = $a016
; read by: l32B3
aA018 = $a018
; read by: l32B3
aA01A = $a01a
; read by: l32B9
aA01C = $a01c
; read by: l4351
aA01E = $a01e

; called by: draw_object
lA020:
		jmp lB79F

; jumped to by: draw_shape
lA023:
		jmp lB7D2

; called by: replot_seeds
lA026:
		jmp lB805

; read by: l4354
aA029:
		.addr	lAE18

; printed piece by piece through print_char, from digit_text_index on
; read by: l3A73
digit_text:
		.text	" 13694 23664 31743 43694 55585 6"
		.text	"2353 73424 84504 949251033641121"
		.text	"33122854133064145955154204161803"
		.text	"175465183784      "

; jumped to by: $a000, $a647
main:
		jsr install_interrupts
		lda #$ff
		sta game_mode
		tax 
		txs 
		lda #$01
		sta text_color
		lda #$00
		sta text_x
		lda #$c7
		sta text_y
		lda #$30
		sta clip_top
		lda #$c8
		sta clip_bottom
		lda #$0f
		sta border_color
		lda cia2_direction_a
		ora #$03
		sta cia2_direction_a
		lda cia2_port_a
		and #$fc
		ora #$02
		sta cia2_port_a
		lda #$02
		sta sprite_multicolor0
		lda #$0f
		sta sprite_multicolor1
		jsr bank_out_io
		jsr lA927
		jsr bank_in_io
		lda #$20
		sta vabf4
		lda #$90
		sta horizon
		jsr l0B95
		jsr random_wind
		jsr fill_colors
		lda sprite_multicolor1
		jsr enable_raster_irq
; jumped to by: shot_loop
new_game:
		lda #$00
		sta leader
		sta sprite_enable
		jsr clear_screen
		jsr bitmap_mode
		lda #$13
		jsr lA95B
		jsr change_wind
		jsr lA964
		jsr enable_raster_irq
		jsr lB5B0
		jsr title_screen
		jsr fill_colors
		jsr clear_screen
		ldx #$0a
		lda #$00
; jumped to by: new_game
lA12B:
		sta vad47, x
		dex 
		bne lA12B
		lda #$00
		sta par
		jsr lAC2B
		jsr random_wind
		lda #$0c
		sta ball_x
		lda #$00
		sta ball_x + $1
		lda #$30
		sta ball_y
		lda #$01
		sta ball_y + $1
; jumped to by: shot_loop
hole_loop:
		lda hole_number
		jsr lA95B
		jsr change_wind
		lda #$ff
		sta v0452
		lda #$7f
		sta v0453
		lda #$00
		sta current_player
		jsr save_player
		lda #$01
		sta current_player
		jsr save_player
		jsr lAE92
		jsr select_player
; jumped to by: shot_loop
lA175:
		jmp shot_loop

; called by: shot_loop
print_score_labels:
		lda #$ff
		sta pixel_pattern
		lda #$00
		sta text_x
		lda #$2f
		sta text_y
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_player:
		.text	"PLAYER", $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_1:
		.text	"1", $ff
		jsr print_inline

newline:
		.byte	$0d, $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_player2:
		.text	"PLAYER", $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_2:
		.text	"2", $ff
		jsr print_inline

newline2:
		.byte	$0d, $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_hole:
		.text	"HOLE    ", $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_club:
		.text	"CLUB", $ff
		jsr print_inline

newline3:
		.byte	$0d, $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_yds:
		.text	"YDS", $ff
		jsr print_inline

newline4:
		.byte	$0d, $ff
		lda text_x
		clc 
		adc #$04
		sta text_x
		jsr print_inline

text_par:
		.text	"PAR", $ff
		rts 

; jumped to by: hole_loop
shot_loop:
		jsr print_score_labels
		jsr enable_raster_irq
		jsr lAE92
		jsr select_player
		jsr lA964
		jsr compute_drift
		lda hole_distance
		pha 
		lda #$00
		sta green_view
		lda #$00
		sta green_flag_x
		sta green_flag_y
		pla 
		cmp #$40
		bcs lA299
		lda ball_x + $1
		pha 
		lda ball_x
		pha 
		lda ball_y + $1
		pha 
		lda ball_y
		pha 
		lda v046c
		sta ball_x
		lda v046d
		sta ball_x + $1
		lda v046e
		sta ball_y
		lda v046f
		sta ball_y + $1
		jsr bank_out_io
		lda shapes + $24
		sta shapes + $1e
		lda shapes + $25
		sta shapes + $1f
		jsr lB5B0
		jsr bank_out_io
		lda shapes + $24
		sta shapes + $1e
		lda shapes + $25
		sta shapes + $1f
		jsr bank_in_io
		pla 
		sta ball_y
		pla 
		sta ball_y + $1
		pla 
		sta ball_x
		pla 
		sta ball_x + $1
		jsr draw_flag
		lda #$01
		sta green_view
		ldx #$04
		jsr lB458
		jmp lA2A1

; jumped to by: shot_loop
lA299:
		jsr lB5B0
		ldx #$00
		jsr lB458
; jumped to by: shot_loop
lA2A1:
		jsr lA95E
		lda sprite_multicolor1
		jsr save_player
		jsr clear_screen
		lda v0443
		pha 
		lda game_mode
		and #$01
		tax 
		pla 
		cpx #$00
		beq lA2BF
		ora v044d
; jumped to by: shot_loop
lA2BF:
		ora #$00
		beq lA2C6
		jmp lA175

; jumped to by: shot_loop
lA2C6:
		jsr lAC2B
		lda #$00
		sta sprite_enable
		ldx hole_number
		inx 
		cpx #$13
		bne lA2D9
		jmp new_game

; jumped to by: shot_loop
lA2D9:
		stx hole_number
		lda game_mode
		and #$02
		bne lA2E6
		jmp hole_loop

; jumped to by: shot_loop
lA2E6:
		jmp new_game

; called by: new_game, shot_loop
clear_screen:
		lda #$00
		sta pointer_06
		lda #$60
		sta pointer_06 + $1
		lda #$40
		sta pointer_08
		lda #$e8
		sta pointer_08 + $1
		ldy #$00
; jumped to by: clear_screen
lA2FB:
		lda #$00
		sta (pointer_06), y
		iny 
		bne lA304
		inc pointer_06 + $1
; jumped to by: clear_screen
lA304:
		inc pointer_08
		bne lA2FB
		inc pointer_08 + $1
		bne lA2FB
		lda #$00
		sta pointer_06
		lda #$44
		sta pointer_06 + $1
		lda #$08
		sta pointer_08
		lda #$fd
		sta pointer_08 + $1
		ldy #$00
; jumped to by: clear_screen
lA31E:
		lda #$0f
		sta (pointer_06), y
		iny 
		bne lA327
		inc pointer_06 + $1
; jumped to by: clear_screen
lA327:
		inc pointer_08
		bne lA31E
		inc pointer_08 + $1
		bne lA31E
		lda #$00
		sta pointer_06
		lda #$d8
		sta pointer_06 + $1
		lda #$08
		sta pointer_08
		lda #$fd
		sta pointer_08 + $1
		ldy #$00
; jumped to by: clear_screen
lA341:
		lda #$00
		sta (pointer_06), y
		iny 
		bne lA34A
		inc pointer_06 + $1
; jumped to by: clear_screen
lA34A:
		inc pointer_08
		bne lA341
		inc pointer_08 + $1
		bne lA341
		lda #$00
		sta pointer_06
		lda #$cb
		sta pointer_06 + $1
		lda #$08
		sta pointer_08
		lda #$fd
		sta pointer_08 + $1
		ldy #$00
; jumped to by: clear_screen
lA364:
		lda #$ff
		sta (pointer_06), y
		iny 
		bne lA36D
		inc pointer_06 + $1
; jumped to by: clear_screen
lA36D:
		inc pointer_08
		bne lA364
		inc pointer_08 + $1
		bne lA364
		jsr lA901
		rts 

; jumped to by: irq
lA379:
		lda #$01
		sta background_color
		lda menu_sprite_flag
		beq lA3F7
		ldx #$08
		lda saved_sprite_registers, x
		sta sprite_pointers + $3
		inx 
		lda saved_sprite_registers, x
		sta sprite3_x
		inx 
		lda saved_sprite_registers, x
		sta sprite3_y
		inx 
		lda saved_sprite_registers, x
		sta sprite_multicolor
		inx 
		lda saved_sprite_registers, x
		sta sprite_expand_y
		inx 
		lda saved_sprite_registers, x
		sta sprite3_color
		inx 
		lda saved_sprite_registers, x
		sta sprite_multicolor0
		inx 
		lda saved_sprite_registers, x
		sta sprite_multicolor1
		inx 
		ldx #$00
		lda saved_sprite_registers, x
		sta sprite_pointers
		inx 
		lda saved_sprite_registers, x
		sta sprite0_x
		inx 
		lda saved_sprite_registers, x
		sta sprite0_y
		inx 
		lda saved_sprite_registers, x
		sta sprite_multicolor
		inx 
		lda saved_sprite_registers, x
		sta sprite_expand_y
		inx 
		lda saved_sprite_registers, x
		sta sprite0_color
		inx 
		lda saved_sprite_registers, x
		sta sprite_multicolor0
		inx 
		lda saved_sprite_registers, x
		sta sprite_multicolor1
		inx 
; jumped to by: clear_screen
lA3F7:
		lda #$00
		sta sprite6_color
		lda #$5f
		sta raster
		jmp lA57B

; jumped to by: irq
lA404:
		ldy #$05
		lda raster
		lda #$69
; jumped to by: clear_screen
lA40B:
		cmp raster
		bcs lA40B
		sty background_color
		lda #$01
		sta sprite6_color
		lda #$82
		ldx #$00
		stx menu_sprite_flag
		ldx v0477
		bne lA426
		lda #$cb
; jumped to by: clear_screen
lA426:
		sta raster
		jmp lA57B

; read by: clear_screen
; written by: clear_screen, $a4af
menu_sprite_flag:
		.byte	$08

; jumped to by: irq
lA42D:
		ldx #$00
		lda sprite_pointers
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite_pointers
		inx 
		lda sprite0_x
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite0_x
		inx 
		lda sprite0_y
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite0_y
		inx 
		lda sprite_multicolor
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite_multicolor
		inx 
		lda sprite_expand_y
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		and sprite_expand_y
		sta sprite_expand_y
		inx 
		lda sprite0_color
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite0_color
		inx 
		lda sprite_multicolor0
		sta saved_sprite_registers, x
		lda #$02
		ldy current_player
		beq lA48F
		lda #$0b
; jumped to by: $a48b
lA48F:
		sta sprite_multicolor0
		inx 
		lda sprite_multicolor1
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite_multicolor1
		inx 
		lda #$9b
		sta raster
		jmp lA57B

; jumped to by: irq
lA4A8:
		lda #$cb
		sta raster
		ldx #$08
		stx menu_sprite_flag
		lda sprite_pointers + $3
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite_pointers + $3
		inx 
		lda sprite3_x
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite3_x
		inx 
		lda sprite3_y
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite3_y
		inx 
		lda sprite_multicolor
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite_multicolor
		inx 
		lda sprite_expand_y
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		and sprite_expand_y
		sta sprite_expand_y
		inx 
		lda sprite3_color
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite3_color
		inx 
		lda sprite_multicolor0
		sta saved_sprite_registers, x
		lda #$02
		ldy current_player
		beq lA512
		lda #$0b
; jumped to by: $a50e
lA512:
		sta sprite_multicolor0
		inx 
		lda sprite_multicolor1
		sta saved_sprite_registers, x
		lda menu_sprite_registers, x
		sta sprite_multicolor1
		inx 
		jmp lA57B

; jumped to by: irq
lA526:
		lda #$fc
		sta raster
		lda #$0b
		sta background_color
		jmp lA57B

; sprite registers saved while a menu sprite is shown, and the values it sets
; read by: clear_screen
; written by: $a432, $a43f, $a44c, $a459, $a466, $a476, $a483, $a496, $a4b5, $a4c2, $a4cf, $a4dc, $a4e9, $a4f9, $a506, $a519
saved_sprite_registers:
		.byte	$26, $47, $63, $01, $3e, $f9, $f2, $ff, $4b, $48, $6f, $01, $3e, $f2, $f2, $f0
		.byte	$cd, $51, $7d, $75, $00, $00, $45, $32, $3f, $09, $09, $09, $09, $09, $09, $45
		.byte	$4e, $44, $0d, $0d, $20, $31, $0d, $0d
; read by: $a435, $a442, $a44f, $a45c, $a469, $a479, $a499, $a4b8, $a4c5, $a4d2, $a4df, $a4ec, $a4fc, $a51c
menu_sprite_registers:
		.byte	$23, $32, $91, $01, $fe, $01, $00, $00, $24, $32, $a6, $09, $f6, $01, $00, $00

irq:
		lda cpu_port
		pha 
		jsr bank_in_io
		lda vic_irq_status
		and #$01
		and vic_irq_enable
		bne lA58A
; jumped to by: clear_screen, $a4a5, $a523, $a530
lA57B:
		lda cia1_interrupt_control
		pla 
		sta cpu_port
		pla 
		tay 
		pla 
		tax 
		pla 
		rti 

; after irq's rti, unreached: a leftover exit to the KERNAL's handler
		jmp kernal_irq

; jumped to by: irq
lA58A:
		sta vic_irq_status
		lda raster
		cmp #$82
		bcs lA597
		jmp lA404

; jumped to by: irq
lA597:
		cmp #$9b
		bcs lA59E
		jmp lA42D

; jumped to by: irq
lA59E:
		cmp #$cb
		bcs lA5A5
		jmp lA4A8

; jumped to by: irq
lA5A5:
		cmp #$fc
		bcs lA5AC
		jmp lA526

; jumped to by: irq
lA5AC:
		jmp lA379

; called by: main, lB5E8
install_interrupts:
		ldx #$00
; jumped to by: install_interrupts
lA5B1:
		lda kernal_copy + $100, x
		sta kernal_copy + $100, x
		lda kernal_copy, x
		sta kernal_copy, x
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
		sta nmi_active
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
		cmp nmi_active
		bne lA5FA
		jmp lA680

; jumped to by: nmi
lA5FA:
		sta nmi_active
		lda cpu_port
		pha 
		jsr bank_in_io
		lda volume_filter_mode
		pha 
		lda #$00
		sta volume_filter_mode
		lda text_pointer + $1
		pha 
		lda text_pointer
		pha 
		lda pointer_04 + $1
		pha 
		lda pointer_04
		pha 
		lda pointer_06 + $1
		pha 
		lda pointer_06
		pha 
		lda text_y
		pha 
		lda text_x
		pha 
		lda bitmap_pointer + $1
		pha 
		lda bitmap_pointer
		pha 
		jsr lB5EE
		jsr print_inline

text_quit_y_n:
		.text	"QUIT (Y/N) ? ", $ff

; jumped to by: $a651
lA63E:
		jsr scnkey
		lda kernal_lstx
		cmp #$19
		bne lA64A
		jmp main

; jumped to by: $a645
lA64A:
		cmp #$17
		bne lA64F
		brk 

; jumped to by: $a64c
lA64F:
		cmp #$27
		bne lA63E
		jsr lB5EE
		pla 
		sta bitmap_pointer
		pla 
		sta bitmap_pointer + $1
		pla 
		sta text_x
		pla 
		sta text_y
		pla 
		sta pointer_06
		pla 
		sta pointer_06 + $1
		pla 
		sta pointer_04
		pla 
		sta pointer_04 + $1
		pla 
		sta text_pointer
		pla 
		sta text_pointer + $1
		pla 
		sta volume_filter_mode
		pla 
		sta cpu_port
		lda #$00
		sta nmi_active
; jumped to by: nmi
lA680:
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		rti 

; $ff while nmi runs, so a nested NMI returns at once
; read by: nmi
; written by: install_interrupts, nmi, $a67d
nmi_active:
		.byte	$00

; called by: main, new_game, shot_loop
enable_raster_irq:
		lda raster
		cmp #$14
		bcc enable_raster_irq
		cmp #$32
		bcs enable_raster_irq
		lda #$5f
		sta raster
		lda #$7f
		and vic_control1
		sta vic_control1
		lda #$01
		ora vic_irq_enable
		sta vic_irq_enable
		cli 
		rts 

; called by: main, new_game
fill_colors:
		lda #$c0
		sta pointer_06
		lda #$77
		sta pointer_06 + $1
		lda #$80
		sta pointer_08
		lda #$f8
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA6BC:
		lda #$aa
		sta (pointer_06), y
		iny 
		bne lA6C5
		inc pointer_06 + $1
; jumped to by: fill_colors
lA6C5:
		inc pointer_08
		bne lA6BC
		inc pointer_08 + $1
		bne lA6BC
		lda #$f8
		sta pointer_06
		lda #$da
		sta pointer_06 + $1
		lda #$10
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA6DF:
		lda #$0f
		sta (pointer_06), y
		iny 
		bne lA6E8
		inc pointer_06 + $1
; jumped to by: fill_colors
lA6E8:
		inc pointer_08
		bne lA6DF
		inc pointer_08 + $1
		bne lA6DF
		lda #$f8
		sta pointer_06
		lda #$46
		sta pointer_06 + $1
		lda #$10
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA702:
		lda #$cc
		sta (pointer_06), y
		iny 
		bne lA70B
		inc pointer_06 + $1
; jumped to by: fill_colors
lA70B:
		inc pointer_08
		bne lA702
		inc pointer_08 + $1
		bne lA702
		lda game_mode
		cmp #$ff
		bne lA71D
		jmp lA8C8

; jumped to by: fill_colors
lA71D:
		lda #$48
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$ef
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA72F:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA738
		inc pointer_06 + $1
; jumped to by: fill_colors
lA738:
		inc pointer_08
		bne lA72F
		inc pointer_08 + $1
		bne lA72F
		lda #$70
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$ef
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA752:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA75B
		inc pointer_06 + $1
; jumped to by: fill_colors
lA75B:
		inc pointer_08
		bne lA752
		inc pointer_08 + $1
		bne lA752
		lda #$98
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$ef
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA775:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA77E
		inc pointer_06 + $1
; jumped to by: fill_colors
lA77E:
		inc pointer_08
		bne lA775
		inc pointer_08 + $1
		bne lA775
		lda #$63
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$f3
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA798:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA7A1
		inc pointer_06 + $1
; jumped to by: fill_colors
lA7A1:
		inc pointer_08
		bne lA798
		inc pointer_08 + $1
		bne lA798
		lda #$8b
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$f3
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA7BB:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA7C4
		inc pointer_06 + $1
; jumped to by: fill_colors
lA7C4:
		inc pointer_08
		bne lA7BB
		inc pointer_08 + $1
		bne lA7BB
		lda #$b3
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$f3
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA7DE:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA7E7
		inc pointer_06 + $1
; jumped to by: fill_colors
lA7E7:
		inc pointer_08
		bne lA7DE
		inc pointer_08 + $1
		bne lA7DE
		lda #$db
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$f3
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA801:
		lda #$bb
		sta (pointer_06), y
		iny 
		bne lA80A
		inc pointer_06 + $1
; jumped to by: fill_colors
lA80A:
		inc pointer_08
		bne lA801
		inc pointer_08 + $1
		bne lA801
		lda #$66
		sta pointer_06
		lda #$db
		sta pointer_06 + $1
		lda #$f6
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA824:
		lda #$01
		sta (pointer_06), y
		iny 
		bne lA82D
		inc pointer_06 + $1
; jumped to by: fill_colors
lA82D:
		inc pointer_08
		bne lA824
		inc pointer_08 + $1
		bne lA824
		lda #$8e
		sta pointer_06
		lda #$db
		sta pointer_06 + $1
		lda #$f6
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA847:
		lda #$01
		sta (pointer_06), y
		iny 
		bne lA850
		inc pointer_06 + $1
; jumped to by: fill_colors
lA850:
		inc pointer_08
		bne lA847
		inc pointer_08 + $1
		bne lA847
		lda #$b6
		sta pointer_06
		lda #$db
		sta pointer_06 + $1
		lda #$f6
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA86A:
		lda #$01
		sta (pointer_06), y
		iny 
		bne lA873
		inc pointer_06 + $1
; jumped to by: fill_colors
lA873:
		inc pointer_08
		bne lA86A
		inc pointer_08 + $1
		bne lA86A
		lda #$de
		sta pointer_06
		lda #$db
		sta pointer_06 + $1
		lda #$f6
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA88D:
		lda #$01
		sta (pointer_06), y
		iny 
		bne lA896
		inc pointer_06 + $1
; jumped to by: fill_colors
lA896:
		inc pointer_08
		bne lA88D
		inc pointer_08 + $1
		bne lA88D
		lda game_mode
		and #$01
		bne lA8C8
		lda #$20
		sta pointer_06
		lda #$db
		sta pointer_06 + $1
		lda #$d8
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: fill_colors
lA8B7:
		lda #$0c
		sta (pointer_06), y
		iny 
		bne lA8C0
		inc pointer_06 + $1
; jumped to by: fill_colors
lA8C0:
		inc pointer_08
		bne lA8B7
		inc pointer_08 + $1
		bne lA8B7
; jumped to by: fill_colors
lA8C8:
		jmp lA901

; called by: draw_wind
lA8CB:
		lda #$1f
		sta pointer_04
		lda #$7b
		sta pointer_04 + $1
		ldx #$04
; jumped to by: lA8CB
lA8D5:
		lda pointer_04 + $1
		pha 
		lda pointer_04
		pha 
		ldy #$50
		lda #$00
; jumped to by: lA8CB
lA8DF:
		sta (pointer_04), y
		cpy #$12
		bcs lA8E7
		lda #$aa
; jumped to by: lA8CB
lA8E7:
		dey 
		bne lA8DF
		pla 
		sta pointer_04
		pla 
		sta pointer_04 + $1
		lda #$40
		clc 
		adc pointer_04
		sta pointer_04
		lda #$01
		adc pointer_04 + $1
		sta pointer_04 + $1
		dex 
		bne lA8D5
		rts 

; called by: clear_screen
; jumped to by: fill_colors
lA901:
		ldx #$00
		stx seed_count
		stx line_x
		ldy #$30
		sty line_y
		ldx #$9f
		jsr draw_line
		ldx #$9f
		ldy #$c7
		jsr draw_line
		ldx #$00
		ldy #$c7
		jsr draw_line
		ldx #$00
		ldy #$30
		jsr draw_line
		rts 

; called by: main
lA927:
		ldx #$2c
		lda shapes2, x
		cmp #$02
		bne lA95A
; jumped to by: lA927
lA930:
		lda shape_eb26 + $f, x
		sta pointer_08
		lda shape_eb36, x
		sta pointer_08 + $1
		ldy #$00
; jumped to by: lA927
lA93C:
		lda (pointer_08), y
		cmp #$80
		beq lA956
		asl 
		php 
		ror 
		plp 
		ror 
		sta (pointer_08), y
		iny 
		lda (pointer_08), y
		asl 
		php 
		ror 
		plp 
		ror 
		sta (pointer_08), y
		iny 
		bne lA93C
; jumped to by: lA927
lA956:
		dex 
		dex 
		bne lA930
; jumped to by: lA927
lA95A:
		rts 

; called by: new_game, hole_loop
; jumped to by: $b348, $b350
lA95B:
		jmp (a2CE5)

; called by: shot_loop
lA95E:
		jmp (a2CE7)

; called by: add_stroke, update_scores, print_par_result, $b340, aim
; jumped to by: lB5EE
lA961:
		jmp (a2CE9)

; called by: new_game, shot_loop
lA964:
		jmp (a2CEB)

; called by: $b4fa
lA967:
		jmp (a2CED)

		jsr lA99A
		jsr direction_up
		jsr direction_up
		jsr direction_up
		jsr lA99A
		jmp lA98E

; unreferenced
		jsr lA99A
		jsr direction_down
		jsr direction_down
		jsr direction_down
		jsr lA99A
		jmp lA98E

; jumped to by: lA967
lA98E:
		jsr direction_up
		jsr direction_up
		jsr direction_up
		jmp direction_up

; called by: lA967
lA99A:
		jsr lA99D
; called by: lA99A
lA99D:
		ldy direction
		lda steps_x2, y
		bmi lA9B6
		lsr 
		lsr 
		lsr 
		clc 
		adc ball_x
		sta ball_x
		lda ball_x + $1
		adc #$00
		sta ball_x + $1
		jmp lA9CE

; jumped to by: lA99D
lA9B6:
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
		adc ball_x
		sta ball_x
		lda ball_x + $1
		sbc #$00
		sta ball_x + $1
; jumped to by: lA99D
lA9CE:
		lda steps_y2, y
		bmi lA9E2
		lsr 
		lsr 
		lsr 
		clc 
		adc ball_y
		sta ball_y
		lda ball_y + $1
		adc #$00
		sta ball_y + $1
		rts 

; jumped to by: lA99D
lA9E2:
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
		adc ball_y
		sta ball_y
		lda ball_y + $1
		sbc #$00
		sta ball_y + $1
		rts 

; read by: lA99D
steps_x2:
		.char	0, 8, 8, 8, 0, -8, -8, -8
; read by: lA99D
steps_y2:
		.char	8, 8, 0, -8, -8, -8, 0, 8

tamper_check:
		lda data_pointers
		cmp #$4e
		bne lAA17
		lda data_pointers + $1
		cmp #$7f
; jumped to by: tamper_check
lAA17:
		beq lAA1C
		jmp tamper_crash

; jumped to by: tamper_check
lAA1C:
		lda data_pointers + $2
		cmp #$00
		bne lAA28
		lda data_pointers + $3
		cmp #$e0
; jumped to by: tamper_check
lAA28:
		beq lAA2D
		jmp tamper_crash

; jumped to by: tamper_check
lAA2D:
		lda data_pointers + $4
		cmp #$4e
		bne lAA39
		lda data_pointers + $5
		cmp #$82
; jumped to by: tamper_check
lAA39:
		beq lAA3E
		jmp tamper_crash

; jumped to by: tamper_check
lAA3E:
		lda data_pointers + $6
		cmp #$f5
		bne lAA4A
		lda data_pointers + $7
		cmp #$93
; jumped to by: tamper_check
lAA4A:
		beq lAA4F
		jmp tamper_crash

; jumped to by: tamper_check
lAA4F:
		lda data_pointers + $8
		cmp #$21
		bne lAA5B
		lda data_pointers + $9
		cmp #$94
; jumped to by: tamper_check
lAA5B:
		beq lAA60
		jmp tamper_crash

; jumped to by: tamper_check
lAA60:
		lda data_pointers + $a
		cmp #$19
		bne lAA6C
		lda data_pointers + $b
		cmp #$94
; jumped to by: tamper_check
lAA6C:
		beq lAA71
		jmp tamper_crash

; jumped to by: tamper_check
lAA71:
		lda data_pointers + $c
		cmp #$37
		bne lAA7D
		lda data_pointers + $d
		cmp #$eb
; jumped to by: tamper_check
lAA7D:
		beq lAA82
		jmp tamper_crash

; jumped to by: tamper_check
lAA82:
		lda $08c0
		cmp #$b8
		bne lAA8E
		lda $08c1
		cmp #$0d
; jumped to by: tamper_check
lAA8E:
		beq lAA93
		jmp tamper_crash2

; jumped to by: tamper_check
lAA93:
		lda $08c2
		cmp #$10
		bne lAA9F
		lda $08c3
		cmp #$10
; jumped to by: tamper_check
lAA9F:
		beq lAAA4
		jmp tamper_crash2

; jumped to by: tamper_check
lAAA4:
		lda $08c4
		cmp #$73
		bne lAAB0
		lda $08c5
		cmp #$0d
; jumped to by: tamper_check
lAAB0:
		beq lAAB5
		jmp tamper_crash2

; jumped to by: tamper_check
lAAB5:
		lda $08c6
		cmp #$ab
		bne lAAC1
		lda $08c7
		cmp #$18
; jumped to by: tamper_check
lAAC1:
		beq lAAC6
		jmp tamper_crash2

; jumped to by: tamper_check
lAAC6:
		lda $08c8
		cmp #$34
		bne lAAD2
		lda $08c9
		cmp #$10
; jumped to by: tamper_check
lAAD2:
		beq lAAD7
		jmp tamper_crash2

; jumped to by: tamper_check
lAAD7:
		lda $08ca
		cmp #$36
		bne lAAE3
		lda $08cb
		cmp #$25
; jumped to by: tamper_check
lAAE3:
		beq lAAE8
		jmp tamper_crash2

; jumped to by: tamper_check
lAAE8:
		lda $08cc
		cmp #$37
		bne lAAF4
		lda $08cd
		cmp #$25
; jumped to by: tamper_check
lAAF4:
		beq lAAF9
		jmp tamper_crash2

; jumped to by: tamper_check
lAAF9:
		lda $08ce
		cmp #$5f
		bne lAB05
		lda $08cf
		cmp #$2c
; jumped to by: tamper_check
lAB05:
		beq lAB0A
		jmp tamper_crash2

; jumped to by: tamper_check
lAB0A:
		lda l08D0
		cmp #$7c
		bne lAB16
		lda l08D0 + 1
		cmp #$12
; jumped to by: tamper_check
lAB16:
		beq lAB1B
		jmp tamper_crash2

; jumped to by: tamper_check
lAB1B:
		lda l08D0 + 2
		cmp #$b9
		bne lAB27
		lda $08d3
		cmp #$0d
; jumped to by: tamper_check
lAB27:
		beq lAB2C
		jmp tamper_crash2

; jumped to by: tamper_check
lAB2C:
		lda $08d4
		cmp #$75
		bne lAB38
		lda $08d5
		cmp #$2c
; jumped to by: tamper_check
lAB38:
		beq lAB3D
		jmp tamper_crash2

; jumped to by: tamper_check
lAB3D:
		lda $08d6
		cmp #$5f
		bne lAB49
		lda $08d7
		cmp #$16
; jumped to by: tamper_check
lAB49:
		beq lAB4E
		jmp tamper_crash2

; jumped to by: tamper_check
lAB4E:
		lda $08d8
		cmp #$6d
		bne lAB5A
		lda $08d9
		cmp #$13
; jumped to by: tamper_check
lAB5A:
		beq lAB5F
		jmp tamper_crash2

; jumped to by: tamper_check
lAB5F:
		lda loader_part
		cmp #$f3
		bne lAB6B
		lda loader_part + $1
		cmp #$0f
; jumped to by: tamper_check
lAB6B:
		beq lAB70
		jmp tamper_crash2

; jumped to by: tamper_check
lAB70:
		lda $08dc
		cmp #$fb
		bne lAB7C
		lda $08dd
		cmp #$0f
; jumped to by: tamper_check
lAB7C:
		beq lAB81
		jmp tamper_crash2

; jumped to by: tamper_check
lAB81:
		lda $08de
		cmp #$8b
		bne lAB8D
		lda $08df
		cmp #$2c
; jumped to by: tamper_check
lAB8D:
		beq lAB92
		jmp tamper_crash2

; jumped to by: tamper_check
lAB92:
		lda $08e0
		cmp #$79
		bne lAB9E
		lda $08e1
		cmp #$0d
; jumped to by: tamper_check
lAB9E:
		beq lABA3
		jmp tamper_crash2

; jumped to by: tamper_check
lABA3:
		lda $08e2
		cmp #$95
		bne lABAF
		lda $08e3
		cmp #$0b
; jumped to by: tamper_check
lABAF:
		beq lABB4
		jmp tamper_crash2

; jumped to by: tamper_check
lABB4:
		lda $08e4
		cmp #$db
		bne lABC0
		lda $08e5
		cmp #$24
; jumped to by: tamper_check
lABC0:
		beq lABC5
		jmp tamper_crash2

; jumped to by: tamper_check
lABC5:
		lda $08e6
		cmp #$57
		bne lABD1
		lda $08e7
		cmp #$10
; jumped to by: tamper_check
lABD1:
		beq lABD6
		jmp tamper_crash2

; jumped to by: tamper_check
lABD6:
		lda $08e8
		cmp #$08
		bne lABE2
		lda $08e9
		cmp #$20
; jumped to by: tamper_check
lABE2:
		beq lABE7
		jmp tamper_crash2

; jumped to by: tamper_check
lABE7:
		rts 

; the tamper check at $aa0b ends here when the $7f40 table or the loader at
; $08c0 was changed: the jsr runs the old screen as code, so the jmp after it
; never runs
; jumped to by: tamper_check
tamper_crash:
		jsr l07C6

never_reached_abeb:
		.byte	$4c, $00, $0c

; jumped to by: tamper_check
tamper_crash2:
		jsr l07C3

never_reached_abf1:
		.byte	$4c, $00, $0c
; start-up sets this to $20
; written by: main
vabf4:		.byte	$20

add_stroke:
		ldx current_player
		sed 
		lda #$01
		clc 
		adc strokes, x
		sta strokes, x
		cld 
		lda #$90
		sta text_x
		lda #$2f
		sta text_y
		cpx #$00
		beq lAC17
		lda #$90
		sta text_x
		lda #$27
		sta text_y
; jumped to by: add_stroke
lAC17:
		lda #$02
		jsr lA961
		ldx current_player
		lda strokes, x
		ldy #$00
		sty bcd_leading_zero
		jsr lAD27
		rts 

; called by: new_game, shot_loop
lAC2B:
		lda #$00
		sta current_player
		ldx #$00
		lda strokes
		cmp strokes + $1
		beq lAC41
		bcc lAC3E
		ldx #$01
; jumped to by: lAC2B
lAC3E:
		stx leader
; jumped to by: lAC2B
lAC41:
		lda game_mode
		and #$01
		beq update_scores
		jsr update_scores
		inc current_player
; called by: lAC2B
; jumped to by: lAC2B
update_scores:
		ldx current_player
		txa 
		asl 
		tay 
		sed 
		lda strokes, x
		clc 
		adc total_strokes, y
		sta total_strokes, y
		lda total_strokes + $1, y
		adc #$00
		sta total_strokes + $1, y
		lda strokes, x
		sec 
		sbc par
		bcc lAC82
		clc 
		adc score_vs_par, y
		sta score_vs_par, y
		lda score_vs_par + $1, y
		adc #$00
		sta score_vs_par + $1, y
		jmp lAC91

; jumped to by: update_scores
lAC82:
		clc 
		adc score_vs_par
		sta score_vs_par, y
		lda score_vs_par + $1, y
		adc #$99
		sta score_vs_par + $1, y
; jumped to by: update_scores
lAC91:
		lda #$00
		sta strokes, x
		cld 
		stx vad46
		sty vad47
		lda #$48
		sta text_x
		lda #$2f
		sta text_y
		lda current_player
		beq lACB2
		lda #$48
		sta text_x
		lda #$27
		sta text_y
; jumped to by: update_scores
lACB2:
		lda #$0b
		jsr lA961
		ldy vad47
		ldx total_strokes + $1, y
		lda total_strokes, y
		ldy #$00
		sty bcd_leading_zero
		jsr lAD21
		lda #$68
		sta text_x
		ldy vad47
		lda score_vs_par, y
		sta vad52
		lda score_vs_par + $1, y
		sta vad53
		lda #$2b
		pha 
		lda vad53
		cmp #$50
		bcc lACFC
		pla 
		lda #$2d
		pha 
		lda #$00
		sed 
		sec 
		sbc vad52
		sta vad52
		lda #$00
		sbc vad53
		sta vad53
		cld 
; jumped to by: update_scores
lACFC:
		pla 
		jsr print_char
		lda vad52
		ldx vad53
		ldy #$00
		sty bcd_leading_zero
		jsr lAD21
		lda #$90
		sta text_x
		ldx vad46
		lda strokes, x
		ldy #$00
		sty bcd_leading_zero
		jsr lAD27
		rts 

; called by: update_scores
lAD21:
		pha 
		txa 
		jsr lAD35
		pla 
; called by: add_stroke, update_scores
lAD27:
		pha 
		lsr 
		lsr 
		lsr 
		lsr 
		jsr lAD35
		ldx #$01
		stx bcd_leading_zero
		pla 
; called by: lAD21, lAD27, draw_wind
lAD35:
		and #$0f
		bne lAD3F
		ldx bcd_leading_zero
		bne lAD3F
		rts 

; jumped to by: lAD35
lAD3F:
		sta bcd_leading_zero
		jmp print_nibble

; read by: lAD35
; written by: add_stroke, update_scores, lAD27, lAD35, draw_wind
bcd_leading_zero:
		.byte	$02
; read by: update_scores
; written by: update_scores
vad46:		.byte	$00
; read by: update_scores
; written by: new_game, update_scores
vad47:		.byte	$00
; read by: add_stroke, lAC2B, update_scores, print_par_result
; written by: add_stroke, update_scores
strokes:
		.byte	$00, $00

; read by: update_scores
; written by: update_scores
score_vs_par:
		.word	$0000, $0000
; read by: update_scores
; written by: update_scores
total_strokes:
		.word	$0000, $0000

; read by: update_scores
; written by: update_scores
vad52:
		.byte	$00
; read by: update_scores
; written by: update_scores
vad53:		.byte	$00

; called by: shot_loop
draw_flag:
		lda #$82
		sta green_flag_x
		lda #$6c
		sta green_flag_y
		jsr lB396
		lda hole_x
		sta point_x
		lda hole_x + $1
		sta point_x + $1
		lda hole_y
		sta point_y
		lda hole_y + $1
		sta point_y + $1
		jsr to_view
		lda view_x
		jsr lAE18
		sta view_x
		lda view_y
		sec 
		sbc #$02
		jsr lAE18
		sta view_y
		lda #$ff
		sta pixel_pattern
		lda view_x
		clc 
		adc green_flag_x
		tax 
		ldy green_flag_y
		dex 
		dex 
		stx line_x
		dey 
		dey 
		sty line_y
		ldy line_y
		tya 
		clc 
		adc #$04
		sta line_y
		ldx line_x
		jsr draw_line
		inc line_x
		dec line_y
		ldy line_y
		tya 
		clc 
		adc #$06
		sta line_y
		ldx line_x
		jsr draw_line
		inc line_x
		ldy line_y
		tya 
		clc 
		adc #$06
		sta line_y
		ldx line_x
		jsr draw_line
		inc line_x
		inc line_y
		ldy line_y
		tya 
		clc 
		adc #$04
		sta line_y
		ldx line_x
		jsr draw_line
		inc line_x
		lda green_flag_y
		sec 
		sbc view_y
		tay 
		sta green_flag_y
		ldx green_flag_x
		stx line_x
		sty line_y
		lda line_x
		clc 
		adc #$06
		asl 
		sta sprite6_x
		bcc lAE0A
		lda sprites_x_msb
		ora #$40
		sta sprites_x_msb
; jumped to by: draw_flag
lAE0A:
		lda #$f0
		sec 
		sbc line_y
		sta sprite6_y
		lda #$21
		sta sprite_pointers + $6
		rts 

; called by: draw_flag
lAE18:
		ora #$00
		php 
		bpl lAE22
		clc 
		eor #$ff
		adc #$01
; jumped to by: lAE18
lAE22:
		tax 
		lda #$00
		jsr to_log
		sta log_value
		stx log_value + $1
		lda #$00
		ldx #$03
		jsr to_log
		dex 
		jsr log_divide
		lda log_value
		ldx log_value + $1
		jsr from_log
		txa 
		plp 
		bpl lAE47
		clc 
		eor #$ff
		adc #$01
; jumped to by: lAE18
lAE47:
		rts 

read_aim_cursor:
		lda sprite5_x
		sta proj_x
		ldx #$00
		lda sprites_x_msb
		and #$20
		beq lAE58
		inx 
; jumped to by: read_aim_cursor
lAE58:
		stx proj_x + $1
		lda sprite5_y
		sta proj_y
		lda proj_x
		lsr proj_x + $1
		ror 
		sec 
		sbc #$06
		sta proj_x
		lda #$ef
		sec 
		sbc proj_y
		sta proj_y
		lda proj_x
		cmp #$65
		bcc lAE8F
		lda #$9e
		cmp proj_x
		bcc lAE8F
		lda proj_x
		ldx proj_y
		jsr test_pixel
		rts 

; jumped to by: read_aim_cursor
lAE8F:
		lda #$00
		rts 

; called by: hole_loop, shot_loop
lAE92:
		lda game_mode
		and #$01
		bne lAE9C
		jmp lAF26

; jumped to by: lAE92
lAE9C:
		lda v043f
		bpl lAEB7
		ldx v043e
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta v043f
		stx v043e
; jumped to by: lAE92
lAEB7:
		lda v0441
		bpl lAED2
		ldx v0440
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta v0441
		stx v0440
; jumped to by: lAE92
lAED2:
		lda v0449
		bpl lAEED
		ldx v0448
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta v0449
		stx v0448
; jumped to by: lAE92
lAEED:
		lda v044b
		bpl lAF08
		ldx v044a
		pha 
		txa 
		clc 
		eor #$ff
		adc #$01
		tax 
		pla 
		eor #$ff
		adc #$00
		sta v044b
		stx v044a
; jumped to by: lAE92
lAF08:
		ldx #$01
; jumped to by: lAE92
lAF0A:
		lda v043e, x
		ora v0440, x
		sta v0439
		lda v0448, x
		ora v044a, x
		cmp v0439
		beq lAF27
		bcs lAF24
		lda #$00
		beq lAF26
; jumped to by: lAE92
lAF24:
		lda #$01
; jumped to by: lAE92
lAF26:
		rts 

; jumped to by: lAE92
lAF27:
		dex 
		beq lAF0A
		lda leader
		rts 

; read by: lAE92
; written by: new_game, lAC2B
leader:
		.byte	$00

; called by: hole_loop, shot_loop
select_player:
		sta current_player
		ora #$00
		bne lAF39
		tax 
		beq lAF3B
; jumped to by: select_player
lAF39:
		ldx #$0a
; jumped to by: select_player
lAF3B:
		lda v0442, x
		sta v0456
		lda v0443, x
		beq lAF5D
		sta hole_distance
		lda v043a, x
		sta ball_x
		lda v043b, x
		sta ball_x + $1
		lda v043c, x
		sta ball_y
		lda v043d, x
		sta ball_y + $1
		rts 

; jumped to by: select_player
lAF5D:
		lda current_player
		eor #$01
		jmp select_player

; called by: hole_loop, shot_loop
save_player:
		lda hole_distance
		bne lAF75
		sta v0452
		sta v0453
		sta v0454
		sta v0455
; jumped to by: save_player
lAF75:
		ldx current_player
		beq lAF7C
		ldx #$0a
; jumped to by: save_player
lAF7C:
		lda ball_x
		sta v043a, x
		lda ball_x + $1
		sta v043b, x
		lda ball_y
		sta v043c, x
		lda ball_y + $1
		sta v043d, x
		lda v0452
		sta v043e, x
		lda v0453
		sta v043f, x
		lda v0454
		sta v0440, x
		lda v0455
		sta v0441, x
		lda v0456
		sta v0442, x
		lda hole_distance
		sta v0443, x
		beq print_par_result
		rts 

; jumped to by: save_player
print_par_result:
		lda #$00
		sta text_x
		lda #$07
		sta text_y
		lda text_x
		clc 
		adc #$04
		sta text_x
		lda #$0c
		jsr lA961
		ldx current_player
		lda strokes, x
		sec 
		sbc par
		bcc lAFE9
		beq lAFFB
		jsr print_inline

text_over_par:
		.text	"OVER PAR", $ff
		lda #$03
		jmp play_tune

; jumped to by: print_par_result
lAFE9:
		jsr print_inline

text_under_par:
		.text	"UNDER PAR", $ff
		lda #$01
		jmp play_tune

; jumped to by: print_par_result
lAFFB:
		jsr print_inline

text_level_par:
		.text	"LEVEL PAR", $ff
		lda #$02
		jmp play_tune

; changes the wind a little at random
; called by: new_game, hole_loop
change_wind:
		ldx hole_number
		lda text_wind_tilt + $7, x
		pha 
		and #$0f
		sta tilt_direction
		pla 
		lsr 
		lsr 
		lsr 
		lsr 
		sta tilt_strength
		jsr random
		and #$03
		cmp #$02
		bcs lB044
		cmp #$01
		beq lB03B
		ldx wind_strength
		inx 
		cpx #$0a
		bcs lB044
		stx wind_strength
		bcc lB044
; jumped to by: change_wind
lB03B:
		ldx wind_strength
		dex 
		beq lB044
		stx wind_strength
; jumped to by: change_wind
lB044:
		jsr random
		and #$03
		cmp #$02
		bcs lB060
		cmp #$01
		beq lB055
		lda #$01
		bne lB057
; jumped to by: change_wind
lB055:
		lda #$ff
; jumped to by: change_wind
lB057:
		clc 
		adc wind_direction
		and #$07
		sta wind_direction
; jumped to by: change_wind
lB060:
		rts 

; called by: main, new_game
random_wind:
		jsr random
		and #$07
		sta wind_direction
		jsr random
		and #$07
		clc 
		adc #$01
		sta wind_strength
		rts 

; the wind's push when far from the hole, the green's tilt when near
; called by: shot_loop
compute_drift:
		lda hole_distance
		cmp #$40
		bcc lB08B
		lda wind_direction
		sta drift_direction
		lda wind_strength
		sta drift_strength
		lda #$01
		bne lB099
; jumped to by: compute_drift
lB08B:
		lda tilt_direction
		sta drift_direction
		lda tilt_strength
		sta drift_strength
		lda #$05
; jumped to by: compute_drift
lB099:
		sta wind_or_tilt
		lda drift_direction
		sec 
		sbc direction
		and #$07
		sta v0459
		tax 
		lda table_b0dd, x
		jsr lB0BE
		sta v0458
		lda table_b0e5, x
		jsr lB0BE
		sta v0457
		jmp draw_wind

; called by: compute_drift
lB0BE:
		tay 
		beq lB0CE
		bmi lB0CF
		lda drift_strength
		cpy #$0a
		beq lB0CE
		tay 
		lda strength_scale, y
; jumped to by: lB0BE
lB0CE:
		rts 

; jumped to by: lB0BE
lB0CF:
		clc 
		eor #$ff
		adc #$01
		jsr lB0BE
		clc 
		eor #$ff
		adc #$01
		rts 

; read by: compute_drift
table_b0dd:
		.char	10, 7, 0, -7, -10, -7, 0, 7
; read by: compute_drift
table_b0e5:
		.char	0, 7, 10, 7, 0, -7, -10, -7

; read by: lB0BE
strength_scale:
		.byte	$00, $01, $01, $02, $03, $04, $04, $05, $06, $06
; read by: lB0BE, draw_wind
; written by: compute_drift
drift_strength:		.byte	$02
; read by: compute_drift
; written by: compute_drift
drift_direction:		.byte	$00
; read by: compute_drift
; written by: change_wind
tilt_strength:		.byte	$01
; read by: compute_drift
; written by: change_wind
tilt_direction:		.byte	$07
; 1 to print "WIND", 5 to print "TILT"
; read by: draw_wind
; written by: compute_drift
wind_or_tilt:		.byte	$01

; read by: change_wind
text_wind_tilt:
		.text	"WINDTILT"

; the green's tilt per hole, indexed from 1: strength in the high nibble, direction in the low
green_tilt:
		.byte	$17, $30, $25, $72, $41, $94, $33, $56, $62, $15, $82, $43, $74, $92, $24, $15
		.byte	$63, $52

; returns the next byte of $a000-$b0ff
; called by: change_wind, random_wind
random:
		lda vectors
		pha 
		inc random + 1
		bne lB122
		inc random + 2
; jumped to by: random
lB122:
		lda random + 2
		cmp #$b1
		bcc lB133
		lda #$00
		sta random + 1
		lda #$a0
		sta random + 2
; jumped to by: random
lB133:
		pla 
		rts 

; jumped to by: compute_drift
draw_wind:
		jsr lA8CB
		lda #$ff
		sta pixel_pattern
		lda #$78
		sta text_x
		lda #$27
		sta text_y
		ldx #$04
		ldy wind_or_tilt
; jumped to by: draw_wind
lB14A:
		lda text_x
		sec 
		sbc #$08
		sta text_x
		lda text_y
		sec 
		sbc #$08
		sta text_y
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda wind_or_tilt, y
		jsr print_char
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
		sta text_x
		lda #$17
		sta text_y
		lda #$01
		sta bcd_leading_zero
		lda drift_strength
		jsr lAD35
		lda clip_top
		pha 
		lda #$00
		sta seed_count
		sta clip_top
		lda v0459
		asl 
		asl 
		tax 
		pha 
		lda arrow_lines + $1, x
		jsr lB23A
		stx line_x
		sty line_y
		pla 
		pha 
		tax 
		lda arrow_lines, x
		jsr lB23A
		jsr draw_line
		pla 
		pha 
		tax 
		lda line_x + $1
		pha 
		lda line_x
		pha 
		lda line_y + $1
		pha 
		lda line_y
		pha 
		lda arrow_lines + $2, x
		jsr lB23A
		jsr draw_line
		pla 
		sta line_y
		pla 
		sta line_y + $1
		pla 
		sta line_x
		pla 
		sta line_x + $1
		pla 
		tax 
		lda arrow_lines + $3, x
		jsr lB23A
		jsr draw_line
		pla 
		sta clip_top
		lda #$2f
		sta pointer_04
		lda #$7b
		sta pointer_04 + $1
		ldx #$04
; jumped to by: draw_wind
lB1E4:
		ldy #$40
; jumped to by: draw_wind
lB1E6:
		lda (pointer_04), y
		ora #$aa
		sta (pointer_04), y
		dey 
		bne lB1E6
		lda #$40
		clc 
		adc pointer_04
		sta pointer_04
		lda #$01
		adc pointer_04 + $1
		sta pointer_04 + $1
		dex 
		bne lB1E4
		rts 

; read by: lB23A
arrow_x:
		.byte	$84
; read by: lB23A
arrow_y:		.byte	$10
; read by: draw_wind
arrow_lines:
		.byte	$00, $04, $0b, $08, $01, $05, $00, $02, $02, $06, $08, $09, $03, $07, $02, $04
		.byte	$04, $00, $09, $0a, $05, $01, $04, $06, $06, $02, $0a, $0b, $07, $03, $06, $00

; read by: lB23A
arrow_points:
		.char	0, 12, 8, 12, 8, 0, 8, -12, 0, -12, -8, -12, -8, 0, -8, 12
		.char	4, 6, 4, -6, -4, -6, -4, 6

; called by: draw_wind
lB23A:
		asl 
		tax 
		lda arrow_points + $1, x
		clc 
		adc arrow_y
		tay 
		lda arrow_points, x
		clc 
		adc arrow_x
		tax 
		rts 

; called by: new_game
title_screen:
		lda #$48
		sta pointer_06
		lda #$47
		sta pointer_06 + $1
		lda #$60
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: title_screen
lB25F:
		lda #$cc
		sta (pointer_06), y
		iny 
		bne lB268
		inc pointer_06 + $1
; jumped to by: title_screen
lB268:
		inc pointer_08
		bne lB25F
		inc pointer_08 + $1
		bne lB25F
		lda #$48
		sta pointer_06
		lda #$db
		sta pointer_06 + $1
		lda #$60
		sta pointer_08
		lda #$ff
		sta pointer_08 + $1
		ldy #$00
; jumped to by: title_screen
lB282:
		lda #$01
		sta (pointer_06), y
		iny 
		bne lB28B
		inc pointer_06 + $1
; jumped to by: title_screen
lB28B:
		inc pointer_08
		bne lB282
		inc pointer_08 + $1
		bne lB282
		lda #$40
		sta pointer_06
		lda #$7a
		sta pointer_06 + $1
		lda #$00
		sta pointer_08
		lda #$fb
		sta pointer_08 + $1
		ldy #$00
; jumped to by: title_screen
lB2A5:
		lda #$aa
		sta (pointer_06), y
		iny 
		bne lB2AE
		inc pointer_06 + $1
; jumped to by: title_screen
lB2AE:
		inc pointer_08
		bne lB2A5
		inc pointer_08 + $1
		bne lB2A5
		lda #$ff
		sta pixel_pattern
		lda #$20
		sta text_x
		lda #$1f
		sta text_y
		jsr print_inline

text_f1_1_player:
		.text	"F1) 1 PLAYER", $ff
		jsr print_inline

newline5:
		.byte	$0d, $ff
		jsr print_inline

text_f3_2_player:
		.text	"    F3) 2 PLAYER", $ff
		jsr print_inline

newline6:
		.byte	$0d, $ff
		jsr print_inline

text_f5_practice:
		.text	"    F5) PRACTICE", $ff

; jumped to by: $b318
lB305:
		lda #$00
		jsr play_tune
		ldx #$00
		cmp #$85
		beq lB34B
		inx 
		cmp #$86
		beq lB34B
		inx 
		cmp #$87
		bne lB305
		stx game_mode
		jsr print_inline

newline7:
		.byte	$0d, $ff
		jsr print_inline

text_hole_1_18:
		.text	"    HOLE (1-18) ", $ff

; jumped to by: $b346
lB336:
		lda #$80
		sta text_x
		lda #$07
		sta text_y
		lda #$02
		jsr lA961
		jsr read_hole_number
		beq lB336
		jmp lA95B

; jumped to by: $b30e, $b313
lB34B:
		stx game_mode
		lda #$01
		jmp lA95B

; called by: $b343
read_hole_number:
		lda #$00
; jumped to by: read_hole_number
lB355:
		sta hole_number
; jumped to by: read_hole_number
lB358:
		jsr scnkey
		jsr getin
		bne lB358
; jumped to by: read_hole_number
lB360:
		jsr scnkey
		jsr getin
		cmp #$0d
		beq lB389
		cmp #$30
		bcc lB360
		cmp #$3a
		bcs lB360
		pha 
		jsr print_char
		pla 
		sec 
		sbc #$30
		ldx hole_number
		beq lB355
		cpx #$02
		bcs lB393
		clc 
		adc #$0a
		sta hole_number
; jumped to by: read_hole_number
lB389:
		lda hole_number
		cmp #$13
		bcs lB393
		ora #$00
		rts 

; jumped to by: read_hole_number
lB393:
		lda #$00
		rts 

; called by: draw_flag
lB396:
		lda #$c7
		sta pointer_04
		lda #$6a
		sta pointer_04 + $1
		lda #$58
		sta pointer_06
		lda #$45
		sta pointer_06 + $1
		lda #$58
		sta pointer_08
		lda #$cc
		sta pointer_08 + $1
		ldx #$78
		ldy #$0b
; jumped to by: lB396
lB3B2:
		tya 
		pha 
		txa 
		tay 
		lda #$00
; jumped to by: lB396
lB3B8:
		sta (pointer_04), y
		dey 
		bne lB3B8
		ldy #$0f
; jumped to by: lB396
lB3BF:
		lda #$0f
		sta (pointer_06), y
		lda #$ff
		sta (pointer_08), y
		dey 
		bne lB3BF
		lda #$40
		clc 
		adc pointer_04
		sta pointer_04
		lda #$01
		adc pointer_04 + $1
		sta pointer_04 + $1
		lda #$28
		clc 
		adc pointer_06
		sta pointer_06
		lda pointer_06 + $1
		adc #$00
		sta pointer_06 + $1
		lda #$28
		clc 
		adc pointer_08
		sta pointer_08
		lda pointer_08 + $1
		adc #$00
		sta pointer_08 + $1
		pla 
		tay 
		dey 
		bne lB3B2
		ldx #$9f
		stx line_x
		ldy #$30
		sty line_y
		ldy #$87
		lda #$00
		sta seed_count
		jsr draw_line
		ldx #$64
		ldy #$87
		jsr draw_line
		ldx #$64
		ldy #$30
		jsr draw_line
		ldx #$9f
		ldy #$30
		jmp draw_line

read_joystick:
		pha 
		txa 
		pha 
		lda game_mode
		and #$01
		beq lB430
		ldx current_player
		lda cia1_port_a, x
		jmp lB436

; jumped to by: read_joystick
lB430:
		lda cia1_port_a
		and cia1_port_b
; jumped to by: read_joystick
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

; jumped to by: read_joystick
lB453:
		pla 
		tax 
		pla 
		tya 
		rts 

; called by: shot_loop
lB458:
		ldy #$00
; jumped to by: lB458
lB45A:
		lda aim_limits, x
		sta aim_x, y
		inx 
		iny 
		cpy #$04
		bcc lB45A
		rts 

; read by: lB458
aim_limits:
		.byte	$56, $3c, $92, $0f, $88, $73, $64, $3c

beep:
		ldx #$19
; jumped to by: beep
lB471:
		lda #$00
		sta vic_mirrors + $3ce, x
		dex 
		bne lB471
		lda #$09
		sta voice1_attack_decay
		lda #$0f
		sta volume_filter_mode
		sty voice1_frequency + $1
		lda #$11
		sta voice1_control
		jsr delay
		lda #$10
		sta voice1_control
		jmp silence_sid

; jumped to by: $b565
lB496:
		ldy #$1e
		jmp beep

lB49B:
		ldy #$3c
		jmp beep

; called by: beep
delay:
		ldx #$46
; jumped to by: delay
lB4A2:
		pha 
		txa 
		pha 
		ldx #$00
; jumped to by: delay
lB4A7:
		dex 
		bne lB4A7
		pla 
		tax 
		pla 
		dex 
		bne lB4A2
		rts 

aim:
		lda #$00
		sta text_x
		lda #$07
		sta text_y
		lda text_x
		clc 
		adc #$04
		sta text_x
		lda #$0d
		jsr lA961
		jsr print_inline

text_aim:
		.text	"AIM", $ff
		lda sprite_enable
		ora #$80
		sta sprite_enable
		lda #$22
		sta sprite_pointers + $7
		lda #$00
		sta sprite7_color
		lda aim_y
		sta sprite7_y
		lda aim_x
		asl 
		sta sprite7_x
		bcc lB4F5
		lda sprites_x_msb
		ora #$80
		sta sprites_x_msb
; jumped to by: $b4eb
lB4F5:
		lda #$50
		sta aim_offset
; jumped to by: $b50a, $b570, $b57e, $b589, $b594, $b5ad
lB4FA:
		jsr lA967
		cmp #$29
		beq lB568
		cmp #$2a
		bne lB508
		jmp lB58C

; jumped to by: $b503
lB508:
		cmp #$3c
		bne lB4FA
		lda aim_offset
		sec 
		sbc #$50
		sta aim_offset
		lda green_view
		beq lB55B
		lda aim_offset
		php 
		bpl lB525
		clc 
		eor #$ff
		adc #$01
; jumped to by: $b51e
lB525:
		tax 
		lda #$00
		jsr to_log
		sta log_value
		stx log_value + $1
		lda #$6c
		sec 
		sbc green_flag_y
		tax 
		lda #$00
		jsr to_log
		jsr log_divide
		lda #$00
		ldx #$28
		jsr to_log
		jsr log_multiply
		lda log_value
		ldx log_value + $1
		jsr from_log
		txa 
		plp 
		bpl lB558
		clc 
		eor #$ff
		adc #$01
; jumped to by: $b551
lB558:
		sta aim_offset
; jumped to by: $b518
lB55B:
		lda #$fe
		sta sprite7_y
		lda #$20
		sta sprite_pointers + $7
		jmp lB496

; jumped to by: $b4ff
lB568:
		lda aim_offset
		cmp aim_max
		bcc lB573
		jmp lB4FA

; jumped to by: $b56e
lB573:
		inc aim_offset
		inc sprite7_x
		inc sprite7_x
		beq lB581
		jmp lB4FA

; jumped to by: $b57c
lB581:
		lda sprites_x_msb
		ora #$80
		sta sprites_x_msb
		jmp lB4FA

; jumped to by: $b505
lB58C:
		lda aim_offset
		cmp aim_min
		bcs lB597
		jmp lB4FA

; jumped to by: $b592
lB597:
		dec aim_offset
		lda sprite7_x
		bne lB5A7
		lda sprites_x_msb
		and #$7f
		sta sprites_x_msb
; jumped to by: $b59d
lB5A7:
		dec sprite7_x
		dec sprite7_x
		jmp lB4FA

; called by: new_game, shot_loop
lB5B0:
		jsr silence_sid
		jsr bank_out_io
		jsr draw_view
		jmp bank_in_io

; called by: main, shot_loop, lB5B0
bank_out_io:
		lda cpu_port
		and #$fd
		sta cpu_port
		rts 

; called by: main, shot_loop, irq, nmi
; jumped to by: lB5B0
bank_in_io:
		lda cpu_port
		ora #$02
		sta cpu_port
		rts 

; unreferenced debugging code: copies $e000 to $cd00, and prints it in hex
		ldx #$00
; jumped to by: bank_in_io
lB5CC:
		lda shapes, x
		sta cell_depths + $200, x
		inx 
		bne lB5CC
		rts 

		ldx #$00
; jumped to by: bank_in_io
lB5D8:
		txa 
		pha 
		lda cell_depths + $200, x
		jsr print_hex
		pla 
		tax 
		inx 
		bne lB5D8
		jmp l0FF3

; called by: $a009
lB5E8:
		jsr install_interrupts
		jmp lC01A

; called by: nmi, $a653
lB5EE:
		lda #$00
		sta text_x
		lda #$07
		sta text_y
		lda #$0d
		jmp lA961

unused_b5fb:
		.byte	$0d

lB5FC:
		ldx #$06
		lda #$ff
		sta pointer_04
		lda #$73
		sta pointer_04 + $1
; jumped to by: $b61d
lB606:
		lda #$00
		ldy #$a0
; jumped to by: $b60d
lB60A:
		sta (pointer_04), y
		dey 
		bne lB60A
		lda #$a0
		clc 
		adc pointer_04
		sta pointer_04
		lda pointer_04 + $1
		adc #$00
		sta pointer_04 + $1
		dex 
		bne lB606
		ldy #$20
		ldx #$00
; jumped to by: $b63d
lB623:
		lda table_b660, y
		and bitmap + $12c0, x
		sta bitmap + $12c0, x
		lda table_b678, y
		and bitmap + $1360, x
		sta bitmap + $1360, x
		iny 
		tya 
		and #$7f
		tay 
		inx 
		cpx #$a0
		bcc lB623
		lda #$ff
		sta pixel_pattern
		ldx #$00
		stx seed_count
		stx line_x
		ldy #$30
		sty line_y
		ldy #$50
		jsr draw_line
		ldx #$9f
		stx line_x
		ldy #$30
		jsr draw_line
		jmp (a2CEF)

; read by: $b623
table_b660:
		.byte	$ff, $ff, $ff, $ff, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $00, $00
; read by: $b62c
table_b678:
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
		.byte	$ff, $ff, $ff, $ff, $ff, $00, $00, $00, $ff, $ff, $ff, $ff, $00, $00, $00, $00
		.byte	$ff, $ff, $ff, $00, $00, $00, $00, $00, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$ff, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $00, $00, $00, $00, $00, $00
		.byte	$ff, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $00, $00, $00, $00, $00, $00
		.byte	$ff, $ff, $ff, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $00, $00, $00, $00
		.byte	$ff, $ff, $ff, $ff, $ff, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00

lB6F8:
		lda green_view
		beq lB700
		jmp lB785

; jumped to by: $b6fb
lB700:
		lda hole_x
		sta point_x
		lda hole_x + $1
		sta point_x + $1
		lda hole_y
		sta point_y
		lda hole_y + $1
		sta point_y + $1
		lda direction_flag
		pha 
		lda #$ff
		sta direction_flag
		jsr to_view
		pla 
		sta direction_flag
		jsr project
		lda #$2a
		clc 
		eor #$ff
		adc #$01
		clc 
		adc proj_x
		sta proj_x
		lda proj_x + $1
		sbc #$00
		sta proj_x + $1
		lda horizon
		sec 
		sbc proj_y
		sta proj_y
		lda proj_x
		asl 
		sta sprite7_x
		bcc lB757
		lda sprites_x_msb
		ora #$80
		bne lB75C
; jumped to by: $b74e
lB757:
		lda sprites_x_msb
		and #$7f
; jumped to by: $b755
lB75C:
		sta sprites_x_msb
		lda #$ee
		sec 
		sbc proj_y
		sta sprite7_y
		lda #$21
		sta sprite_pointers + $7
		lda sprite_enable
		ora #$80
		sta sprite_enable
		lda #$00
		sta sprite7_color
		jsr lB78E
		lda #$01
		sta sprite7_color
		jsr lB78E
; jumped to by: $b6fd
lB785:
		lda sprite_enable
		and #$7f
		sta sprite_enable
		rts 

; called by: $b77a, $b782
lB78E:
		ldx #$80
; jumped to by: lB78E
lB790:
		pha 
		txa 
		pha 
		ldx #$00
; jumped to by: lB78E
lB795:
		dex 
		bne lB795
		pla 
		tax 
		pla 
		dex 
		bne lB790
		rts 

; jumped to by: lA020
lB79F:
		ldx #$14
		stx vb800
		lda shapes, x
		cmp pointer_04
		bne lB7CF
		lda shapes + $1, x
		cmp pointer_04 + $1
		bne lB7CF
		lda #$00
		sta vb800
		lda proj_x
		sta vb801
		lda proj_x + $1
		sta vb802
		lda proj_y
		sta vb803
		lda proj_y + $1
		sta vb804
; jumped to by: lB78E
lB7CF:
		ldy #$00
		rts 

; jumped to by: lA020
lB7D2:
		lda vb800
		bne lB7FD
		lda pen_x
		clc 
		adc vb801
		sta proj_x
		lda pen_x + $1
		adc vb802
		sta proj_x + $1
		lda pen_y
		clc 
		adc vb803
		sta proj_y
		lda pen_y + $1
		adc vb804
		sta proj_y + $1
; jumped to by: lB78E
lB7FD:
		jmp draw_shape

; read by: lB78E
; written by: lB78E
vb800:
		.byte	$14
; read by: lB78E
; written by: lB78E
vb801:		.byte	$6b
; read by: lB78E
; written by: lB78E
vb802:		.byte	$00
; read by: lB78E
; written by: lB78E
vb803:		.byte	$87
; read by: lB78E
; written by: lB78E
vb804:		.byte	$00

; jumped to by: lA026
lB805:
		jsr test_pixel
		bne lB852
		php 
		pha 
		txa 
		pha 
		tya 
		pha 
		lda #$ff
		sta vb853
		ldy plot_y
		lda seed_edges, y
		sta vb854
		ldx fill_seeds + $ff, y
		ldy #$00
; jumped to by: $b82d, $b835, $b83a
lB822:
		iny 
		iny 
		cpy seed_count
		bcs lB83D
		txa 
		cmp seed_edges, y
		bne lB822
		lda vb854
		cmp seed_edges + $1, y
		bne lB822
		inc vb853
		jmp lB822

; jumped to by: $b827
lB83D:
		pla 
		tay 
		pla 
		tax 
		pla 
		plp 
		lda vb853
		beq lB852
		lda pixel_bits, x
		and pixel_pattern
		ora (bitmap_pointer), y
		sta (bitmap_pointer), y
; jumped to by: $b808, $b846
lB852:
		rts 

; read by: $b843
; written by: $b812
; modified by: $b837
vb853:
		.byte	$00
; read by: $b82f
; written by: $b81a
vb854:		.byte	$76

; called by: lB8A8, $b9d9, $b9e8, $b9f7, $ba23, $ba86, $ba95, $baa4
music_push:
		ldx music_voice
		lda v0479, x
		tax 
		lda v0439
		sta v047d, x
		inx 
		lda v043a
		sta v047d, x
		inx 
		txa 
		ldx music_voice
		sta v0479, x
		rts 

; called by: lB8A8, $ba3d, $ba4a, $ba59, $ba68
music_pop:
		ldx music_voice
		lda v0479, x
		tax 
		dex 
		lda v047d, x
		sta v043a
		dex 
		lda v047d, x
		sta v0439
		txa 
		ldx music_voice
		sta v0479, x
		rts 

; called by: lB8A8, music_step, $ba13
next_music_byte:
		inc pointer_06
		bne lB895
		inc pointer_06 + $1
; jumped to by: next_music_byte
lB895:
		lda pointer_06 + $1
		cmp v0410
		bne lB8A1
		lda pointer_06
		cmp v040f
; jumped to by: next_music_byte
lB8A1:
		beq lB8A7
		ldy #$00
		lda (pointer_06), y
; jumped to by: next_music_byte
lB8A7:
		rts 

; called by: $ba04, $baa7, $bab6
lB8A8:
		jsr next_music_byte
		sta v0429
		lda pointer_06
		sta v0439
		lda pointer_06 + $1
		sta v043a
		jsr music_push
		lda #$18
		sta pointer_06
		lda #$bd
		sta pointer_06 + $1
		lda v040f
		sta v0439
		lda v0410
		sta v043a
		jsr music_push
		lda #$00
		sta v0410
; jumped to by: lB8A8
lB8D7:
		jsr next_music_byte
		cmp #$82
		bne lB8D7
		jsr next_music_byte
		cmp v0429
		bne lB8D7
		lda pointer_06
		sta v0429
		lda pointer_06 + $1
		sta v042a
		jsr music_pop
		lda v0439
		sta v040f
		lda v043a
		sta v0410
		jsr music_pop
		lda v0439
		sta pointer_06
		lda v043a
		sta pointer_06 + $1
		rts 

; plays tune A until it ends or F1/F3/F5 is pressed
; called by: $b307
; jumped to by: $afe6, $aff8, $b00a
play_tune:
		jsr music_start
		pha 
		jsr silence_sid
		pla 
		rts 

; called by: play_tune
music_start:
		tsx 
		stx music_saved_stack
		pha 
		lda #$7c
		sta v0416
		lda #$be
		sta v0417
		lda #$18
		sta v0419
		lda #$bd
		sta v041a
		lda #$8b
		sta v0420
		lda #$bd
		sta v0421
		lda #$dd
		sta v0427
		lda #$bd
		sta v0428
		lda v0416
		sta v041d
		lda v0417
		sta v041e
		lda v0416
		sta v0424
		lda v0417
		sta v0425
		pla 
		jsr select_tune
		jsr init_sid
		lda #$01
		sta v0435
		sta v0436
		sta v0437
		lda #$00
		sta v047a
		lda #$40
		sta v047b
		lda #$80
		sta v047c
		jmp lBB2F

; called by: $ba30
; jumped to by: $ba77, $bae5, $baf7, $bbdc
music_step:
		jsr next_music_byte
		sta music_note
		bne lB988
; jumped to by: $b9ca
lB987:
		rts 

; jumped to by: music_step
lB988:
		lda music_note
		bmi lB99B
		jsr next_music_byte
		sta music_duration
		beq lB9C1
		jmp lBBDF

; unreferenced
		jmp music_step

; jumped to by: music_step
lB99B:
		cmp #$80
		beq lB9CD
		cmp #$81
		bne lB9A6
		jmp lBA7A

; jumped to by: music_step
lB9A6:
		cmp #$8c
		bne lB9AD
		jmp lBAD8

; jumped to by: music_step
lB9AD:
		cmp #$8d
		bne lB9B4
		jmp lBAE8

; jumped to by: music_step
lB9B4:
		cmp #$82
		bne lB9C1
		inc pointer_06
		bne lB9BE
		inc pointer_06 + $1
; jumped to by: music_step
lB9BE:
		jmp music_step

; jumped to by: music_step
lB9C1:
		jsr print_inline

text_error:
		.text	"ERROR", $ff
		jmp lB987

; jumped to by: music_step
lB9CD:
		lda v040d
		sta v0439
		lda v040e
		sta v043a
		jsr music_push
		lda v040f
		sta v0439
		lda v0410
		sta v043a
		jsr music_push
		lda v0411
		sta v0439
		lda v0412
		sta v043a
		jsr music_push
		lda pointer_06
		sta v040f
		lda pointer_06 + $1
		sta v0410
		jsr lB8A8
		lda v0429
		sta v040d
		lda v042a
		sta v040e
		jsr next_music_byte
		sta v0411
; jumped to by: $bad5
lBA19:
		lda pointer_06
		sta v0439
		lda pointer_06 + $1
		sta v043a
		jsr music_push
; jumped to by: $ba36, $ba3b
lBA26:
		lda v040d
		sta pointer_06
		lda v040e
		sta pointer_06 + $1
		jsr music_step
		lda v0411
		beq lBA26
		dec v0411
		bne lBA26
		jsr music_pop
		lda v0439
		sta pointer_06
		lda v043a
		sta pointer_06 + $1
		jsr music_pop
		lda v0439
		sta v0411
		lda v043a
		sta v0412
		jsr music_pop
		lda v0439
		sta v040f
		lda v043a
		sta v0410
		jsr music_pop
		lda v0439
		sta v040d
		lda v043a
		sta v040e
		jmp music_step

; jumped to by: music_step
lBA7A:
		lda v040d
		sta v0439
		lda v040e
		sta v043a
		jsr music_push
		lda v040f
		sta v0439
		lda v0410
		sta v043a
		jsr music_push
		lda v0411
		sta v0439
		lda v0412
		sta v043a
		jsr music_push
		jsr lB8A8
		lda v0429
		sta v040d
		lda v042a
		sta v040e
		jsr lB8A8
		lda v0429
		sta v040f
		lda v042a
		sta v0410
		lda v040f
		bne lBACD
		dec v0410
; jumped to by: $bac8
lBACD:
		dec v040f
		lda #$01
		sta v0411
		jmp lBA19

; jumped to by: music_step
lBAD8:
		lda #$09
		sta voice2_attack_decay
		sta voice2_sustain_release
		lda #$40
		sta v0432
		jmp music_step

; jumped to by: music_step
lBAE8:
		lda #$59
		sta voice2_attack_decay
		lda #$54
		sta voice2_sustain_release
		lda #$20
		sta v0432
		jmp music_step

; unreferenced: a sound effect
		lda music_note
		asl 
		tax 
		lda note_frequencies, x
		sta voice2_frequency
		lda note_frequencies + $1, x
		sta voice2_frequency + $1
		lda #$61
		sta voice2_control
		pha 
		ldx music_duration
; jumped to by: $bb26
lBB14:
		ldy music_tempo
; jumped to by: $bb23
lBB17:
		pha 
		txa 
		pha 
		ldx #$00
; jumped to by: $bb1d
lBB1C:
		dex 
		bne lBB1C
		pla 
		tax 
		pla 
		dey 
		bne lBB17
		dex 
		bne lBB14
		pla 
		and #$fe
		sta voice2_control
		rts 

; jumped to by: music_start, $bb9f
lBB2F:
		lda #$01
		sta music_voice
; jumped to by: $bb7f
lBB34:
		ldx music_voice
		dec v0434, x
		bne lBB77
		lda voice_offsets, x
		sta v042f
		tax 
		ldy music_voice
		lda v0430, y
		sta voice1_control, x
		jmp lBBBD

; jumped to by: $bbfe
lBB4F:
		lda music_note
		asl 
		tay 
		ldx v042f
		lda note_frequencies, y
		sta voice1_frequency, x
		lda note_frequencies + $1, y
		sta voice1_frequency + $1, x
		ldy music_voice
		lda v0430, y
		ora #$01
		sta voice1_control, x
		lda music_duration
		ldx music_voice
		sta v0434, x
; jumped to by: $bb3a
lBB77:
		inc music_voice
		lda music_voice
		cmp #$04
		bcc lBB34
		jsr scnkey
		jsr getin
		bne lBBA2
; jumped to by: $bbac
lBB89:
		ldx #$01
; jumped to by: $bb9d
lBB8B:
		ldy music_tempo
; jumped to by: $bb9a
lBB8E:
		pha 
		txa 
		pha 
		ldx #$00
; jumped to by: $bb94
lBB93:
		dex 
		bne lBB93
		pla 
		tax 
		pla 
		dey 
		bne lBB8E
		dex 
		bne lBB8B
		jmp lBB2F

; jumped to by: $bb87
lBBA2:
		cmp #$85
		beq lBBAE
		cmp #$86
		beq lBBAE
		cmp #$87
		bne lBB89
; jumped to by: $bba4, $bba8
lBBAE:
		pha 
		jsr silence_sid
		pla 
		ldx music_saved_stack
		txs 
		rts 

; read by: $bb3c, $bbc0, $bbe2
voice_offsets:
		.byte	$00, $00, $07, $0e, $15

; jumped to by: $bb4c
lBBBD:
		ldx music_voice
		lda voice_offsets + $1, x
		tax 
		ldy #$00
; jumped to by: $bbd0
lBBC6:
		lda v040d, x
		sta v040d, y
		inx 
		iny 
		cpy #$07
		bcc lBBC6
		lda v0412
		sta pointer_06
		lda v0413
		sta pointer_06 + $1
		jmp music_step

; jumped to by: music_step
lBBDF:
		ldx music_voice
		lda voice_offsets + $1, x
		tax 
		ldy #$00
		lda pointer_06
		sta v0412
		lda pointer_06 + $1
		sta v0413
; jumped to by: $bbfc
lBBF2:
		lda v040d, y
		sta v040d, x
		inx 
		iny 
		cpy #$07
		bcc lBBF2
		jmp lBB4F

; called by: lB5B0, play_tune, $bbaf, init_sid
; jumped to by: beep
silence_sid:
		ldx #$19
		lda #$00
; jumped to by: silence_sid
lBC05:
		sta voice1_frequency, x
		dex 
		bne lBC05
		rts 

; called by: music_start
init_sid:
		jsr silence_sid
		lda #$09
		sta voice1_attack_decay
		lda #$04
		sta voice1_sustain_release
		lda #$01
		sta voice1_pulse_width + $1
		lda #$b4
		sta voice1_pulse_width
		lda #$40
		sta v0431
		lda #$09
		sta voice2_attack_decay
		sta voice3_attack_decay
		sta voice2_sustain_release
		sta voice3_sustain_release
		lda #$03
		sta voice2_pulse_width + $1
		sta voice3_pulse_width + $1
		lda #$40
		sta v0432
		sta v0433
		lda #$0f
		sta volume_filter_mode
		lda #$9b
		sta music_tempo
		rts 

; called by: music_start
select_tune:
		cmp #$00
		beq lBC61
		cmp #$01
		beq lBC62
		cmp #$02
		beq lBC9F
		cmp #$03
		beq lBCDC
; jumped to by: select_tune
lBC61:
		rts 

; jumped to by: select_tune
lBC62:
		lda #$92
		sta v0424
		lda #$be
		sta v0425
		lda #$7b
		sta v0427
		lda #$be
		sta v0428
		lda #$a8
		sta v041d
		lda #$be
		sta v041e
		lda #$91
		sta v0420
		lda #$be
		sta v0421
		lda #$b0
		sta v0416
		lda #$be
		sta v0417
		lda #$a7
		sta v0419
		lda #$be
		sta v041a
		rts 

; jumped to by: select_tune
lBC9F:
		lda #$be
		sta v0424
		lda #$be
		sta v0425
		lda #$af
		sta v0427
		lda #$be
		sta v0428
		lda #$cc
		sta v041d
		lda #$be
		sta v041e
		lda #$bd
		sta v0420
		lda #$be
		sta v0421
		lda #$e6
		sta v0416
		lda #$be
		sta v0417
		lda #$cb
		sta v0419
		lda #$be
		sta v041a
		rts 

; jumped to by: select_tune
lBCDC:
		lda #$00
		sta v0424
		lda #$bf
		sta v0425
		lda #$e5
		sta v0427
		lda #$be
		sta v0428
		lda #$0e
		sta v041d
		lda #$bf
		sta v041e
		lda #$ff
		sta v0420
		lda #$be
		sta v0421
		lda #$16
		sta v0416
		lda #$bf
		sta v0417
		lda #$0d
		sta v0419
		lda #$bf
		sta v041a
		rts 

; ---- music ----
; notes and durations; $8x bytes are commands
music_data:
		.byte	$82, $01, $30, $01, $30, $01, $27, $01, $2a, $01, $80, $01, $07, $82, $02, $33
		.byte	$01, $33, $01, $2a, $01, $31, $01, $80, $02, $03, $82, $03, $80, $01, $01, $82
		.byte	$04, $27, $01, $27, $01, $22, $01, $25, $01, $80, $04, $07, $80, $01, $01, $82
		.byte	$05, $28, $02, $28, $02, $28, $02, $28, $02, $82, $06, $2a, $02, $2a, $02, $2a
		.byte	$02, $2a, $02, $82, $07, $2b, $02, $2b, $02, $2b, $02, $2b, $02, $30, $02, $30
		.byte	$02, $30, $02, $30, $02, $81, $06, $07, $25, $02, $25, $02, $25, $02, $25, $02
		.byte	$22, $02, $22, $02, $22, $02, $22, $02, $27, $02, $27, $02, $27, $02, $27, $02
		.byte	$80, $01, $00, $82, $0a, $8c, $57, $06, $55, $02, $54, $08, $80, $0a, $01, $5a
		.byte	$06, $58, $02, $57, $08, $80, $0a, $01, $5b, $02, $5b, $02, $59, $02, $59, $02
		.byte	$57, $02, $57, $02, $59, $02, $59, $02, $5b, $06, $59, $02, $57, $04, $57, $04
		.byte	$80, $0a, $01, $8d, $60, $04, $60, $04, $5a, $04, $57, $04, $57, $04, $55, $04
		.byte	$53, $04, $53, $04, $54, $04, $54, $04, $55, $04, $55, $04, $59, $04, $55, $04
		.byte	$57, $08, $80, $0a, $00, $82, $14, $54, $06, $52, $02, $50, $08, $80, $14, $01
		.byte	$57, $06, $55, $02, $53, $08, $80, $14, $01, $57, $02, $57, $02, $55, $02, $55
		.byte	$02, $4b, $02, $52, $02, $55, $02, $55, $02, $57, $06, $55, $02, $4b, $02, $52
		.byte	$02, $55, $02, $52, $02, $80, $14, $01, $82, $15, $48, $01, $50, $01, $53, $01
		.byte	$50, $01, $80, $15, $01, $82, $16, $47, $01, $4a, $01, $53, $01, $4a, $01, $80
		.byte	$16, $01, $82, $17, $47, $01, $4b, $01, $52, $01, $4b, $01, $80, $17, $01, $82
		.byte	$18, $43, $01, $47, $01, $50, $01, $47, $01, $80, $18, $01, $82, $19, $47, $01
		.byte	$4a, $01, $50, $01, $4a, $01, $80, $19, $01, $82, $1a, $45, $01, $48, $01, $50
		.byte	$01, $48, $01, $80, $1a, $01, $82, $1b, $42, $01, $45, $01, $49, $01, $45, $01
		.byte	$80, $1b, $01, $82, $1c, $47, $01, $4b, $01, $52, $01, $55, $01, $80, $1c, $01
		.byte	$80, $14, $00, $47, $03, $47, $01, $47, $01, $47, $01, $50, $02, $47, $02, $50
		.byte	$02, $54, $02, $50, $02, $54, $02, $57, $06, $44, $03, $44, $01, $44, $01, $44
		.byte	$01, $47, $02, $44, $02, $47, $02, $50, $02, $49, $02, $50, $02, $4b, $06, $30
		.byte	$06, $2b, $06, $29, $06, $27, $06, $4a, $02, $4a, $02, $49, $02, $45, $02, $43
		.byte	$02, $43, $02, $42, $04, $44, $02, $47, $02, $40, $02, $40, $02, $39, $02, $40
		.byte	$02, $35, $04, $20, $01, $20, $01, $24, $01, $24, $01, $25, $01, $25, $01, $29
		.byte	$01, $29, $01, $25, $01, $25, $01, $29, $01, $29, $01, $2a, $04, $51, $01, $4a
		.byte	$01, $47, $01, $44, $01, $50, $01, $48, $01, $45, $01, $42, $01, $4a, $01, $47
		.byte	$01, $44, $01, $41, $01, $48, $04, $3a, $02, $3a, $02, $38, $02, $38, $02, $34
		.byte	$02, $34, $02, $40, $04, $20, $04, $20, $04, $20, $04, $25, $04

; SID frequencies: 16 words per octave, 12 of them used
; read by: $baff, $bb05, $bb57, $bb5d
note_frequencies:
		.word	$010c, $011c, $012d, $013e, $0151, $0166, $017b, $0191, $01a9, $01c3, $01dd, $01fa, $0000, $0000, $0000, $0000
		.word	$0218, $0238, $025a, $027d, $02a3, $02cc, $02f6, $0323, $0353, $0386, $03bb, $03f4, $0000, $0000, $0000, $0000
		.word	$0430, $0470, $04b4, $04fb, $0547, $0598, $05ed, $0647, $06a7, $070c, $0777, $07e9, $0000, $0000, $0000, $0000
		.word	$0861, $08e1, $0968, $09f7, $0a8f, $0b30, $0bda, $0c8f, $0d4e, $0e18, $0eef, $0fd2, $0000, $0000, $0000, $0000
		.word	$10c3, $11c3, $12d1, $13ef, $151f, $1660, $17b5, $191e, $1a9c, $1c31, $1ddf, $1fa5, $0000, $0000, $0000, $0000
		.word	$2187, $2386, $25a2, $27df, $2a3e, $2cc1, $2f6b, $323c, $3539, $3863, $3bbe, $3f4b, $0000, $0000, $0000, $0000
		.word	$430f, $470c, $4b45, $4fbf, $547d, $5983, $5ed6, $6479, $6a73, $70c7, $777c, $7e97, $0000, $0000, $0000, $0000
		.word	$861e, $8e18, $968b, $9f7e, $a8fa, $b306, $bdac, $c8f3, $d4e6, $e18f, $eef8, $fd2e

; read by: lC0F3
; written by: $c03b
vc00e:
		.byte	$08

unused_golf:
		.text	"GOLF"

; written by: lC13B
vc013:
		.byte	$34
; read by: $c129
vc014:		.byte	$05

; read by: lC13B
; written by: $c072, $c077, $c089, $c08e, $c0a0, $c0a5, $c0bc, $c0c1, $c0d6, $c0db
vc015:
		.word	$7f40

; read by: lC13B
; written by: lC0F3
; modified by: lC13B
vc017:
		.byte	$34

; read by: lC13B
; written by: $c07c, $c081, $c093, $c098, $c0aa, $c0af, $c0c6, $c0cb, $c0e0, $c0e5
vc018:
		.word	$c17d

; jumped to by: lB5E8, $c034
lC01A:
		lda #$ea
		sta $a64e
		jsr l0FF3
		ldx #$01
		cmp #$43
		beq lC03B
		cmp #$4e
		beq lC036
		ldx #$08
		cmp #$44
		beq lC03B
		cmp #$4d
		bne lC01A
; jumped to by: $c02a
lC036:
		lda #$00
		sta $a64e
; jumped to by: $c026, $c030
lC03B:
		stx vc00e
		jsr lC0F3
		lda cpu_port
		and #$fd
		sta cpu_port
		lda #$00
		sta vfb
		lda #$e0
		sta vfc
		lda #$00
		sta pointer_fd
		lda #$60
		sta pointer_fd + $1
		ldy #$00
; jumped to by: $c05e, $c068
lC059:
		lda (vfb), y
		sta (pointer_fd), y
		iny 
		bne lC059
		inc vfc
		inc pointer_fd + $1
		lda vfc
		cmp #$f0
		bcc lC059
		lda cpu_port
		ora #$02
		sta cpu_port
		lda #$00
		sta vc015
		lda #$60
		sta vc015 + $1
		lda #$00
		sta vc018
		lda #$70
		sta vc018 + $1
		jsr lC13B
		lda #$00
		sta vc015
		lda #$09
		sta vc015 + $1
		lda #$00
		sta vc018
		lda #$44
		sta vc018 + $1
		jsr lC13B
		lda #$00
		sta vc015
		lda #$48
		sta vc015 + $1
		lda #$00
		sta vc018
		lda #$60
		sta vc018 + $1
		jsr lC13B
		lda $a64e
		beq lC0D4
		lda #$40
		sta vc015
		lda #$7f
		sta vc015 + $1
		lda #$1a
		sta vc018
		lda #$c0
		sta vc018 + $1
		jsr lC13B
		jmp lC0EB

; jumped to by: $c0b8
lC0D4:
		lda #$40
		sta vc015
		lda #$7f
		sta vc015 + $1
		lda #$7d
		sta vc018
		lda #$c1
		sta vc018 + $1
		jsr lC13B
; jumped to by: $c0d1
lC0EB:
		lda #$00
		sta $a64e
		jmp start

; called by: $c03e
lC0F3:
		lda cpu_port
		and #$fe
		sta cpu_port
		lda #$30
		sta vc017
		jsr clall
		ldx vc00e
		ldy #$01
		lda vc00e
		jsr setlfs
		bcs lC129
		jsr print_hex
		jsr print_inline

text_error_in_setlfs:
		.text	" ERROR IN SETLFS", $0d, $ff

; jumped to by: $c126
lC126:
		jmp lC126

; jumped to by: lC0F3
lC129:
		lda vc014
		ldx #$0f
		ldy #$c0
		jsr setnam
		bcs lC13A
		bcc lC13A
; jumped to by: $c137
lC137:
		jmp lC137

; jumped to by: $c133, $c135
lC13A:
		rts 

; called by: $c084, $c09b, $c0b2, $c0ce, $c0e8
lC13B:
		inc vc017
		lda vc017
		sta vc013
		lda vc015
		sta text_pointer
		lda vc015 + $1
		sta text_pointer + $1
		ldx vc018
		ldy vc018 + $1
		lda #$02
		jsr save
		bcc lC176
		jsr print_hex
		jsr print_inline

text_save_routine_error:
		.text	" SAVE ROUTINE ERROR", $0d, $ff

; jumped to by: lC13B
lC176:
		rts 

; unreferenced: flashes the border forever
; jumped to by: $c17a
lC177:
		inc border_color
		jmp lC177

unused_nops:
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea
; unreferenced leftover data
; per screen cell, the depth of the nearest object drawn there; rebuilt each frame
; read by: bank_in_io
; written by: bank_in_io
cell_depths:
		.byte	$7e, $7e, $7e, $7e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7e, $7e, $7e, $7e, $7e, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $86, $86, $86, $86, $86, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $87, $87, $ff, $ff
		.byte	$7e, $7e, $7e, $7e, $7e, $ff, $ff, $ff, $ff, $ff, $86, $86, $86, $86, $86, $86
		.byte	$86, $86, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $87, $87, $87, $87, $ff, $ff, $7e, $7e, $7e, $7e, $ff, $ff, $ff
		.byte	$ff, $ff, $86, $86, $86, $86, $86, $86, $86, $86, $86, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $87, $87, $87, $87, $ff
		.byte	$ff, $7e, $7e, $7e, $ff, $ff, $ff, $ff, $ff, $86, $86, $86, $86, $86, $86, $86
		.byte	$86, $86, $86, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $8c, $8c, $8a, $8a
		.byte	$8a, $8a, $ff, $87, $87, $87, $87, $ff, $ff, $7e, $7e, $7e, $ff, $ff, $ff, $ff
		.byte	$ff, $86, $86, $86, $86, $86, $86, $86, $86, $86, $86, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $8c, $8c, $8a, $8a, $8a, $8a, $8b, $87, $8e, $89, $89, $ff
		.byte	$7e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $86, $86, $86, $86, $86, $86
		.byte	$86, $86, $8e, $8e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $8e, $8e, $8c, $8a, $8a
		.byte	$8c, $8b, $8b, $8e, $8e, $89, $89, $81, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $86, $86, $ff, $ff, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8c, $8e, $8e, $8e, $ff, $ff, $ff, $ff, $ff, $81, $81
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $86, $86, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $ff, $ff, $81, $81, $7e, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $ff, $ff
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
		.byte	$ff, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $ff, $ff, $ff, $ff, $ff, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$ff, $ff, $ff, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $ff, $ff, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e
		.byte	$8e, $8e, $8e, $8e, $8e, $8e, $8e, $8e, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
unused_nops2:
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
		.byte	$ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea

.virtual $d000
; ---- VIC-II ----
; read by: $a43c
; written by: l33C0, clear_screen, $a445
sprite0_x:		.byte	?
; read by: $a449
; written by: l33C0, clear_screen, $a452
sprite0_y:		.byte	?
sprite1_x:		.byte	?
sprite1_y:		.byte	?
sprite2_x:		.byte	?
sprite2_y:		.byte	?
; read by: $a4bf
; written by: clear_screen, $a4c8
sprite3_x:		.byte	?
; read by: $a4cc
; written by: clear_screen, $a4d5
sprite3_y:		.byte	?
sprite4_x:		.byte	?
sprite4_y:		.byte	?
; read by: read_aim_cursor
sprite5_x:		.byte	?
; read by: read_aim_cursor
sprite5_y:		.byte	?
; written by: check_terrain, position_ball_sprite, draw_flag
sprite6_x:		.byte	?
; written by: $3013, check_terrain, position_ball_sprite, draw_flag
sprite6_y:		.byte	?
; read by: $b59a
; written by: position_ball_sprite, $b4e8, $b74b
; modified by: $b576, $b579, $b5a7, $b5aa
sprite7_x:		.byte	?
; written by: $3016, check_landing, position_ball_sprite, $b4e1, $b55d, $b765
sprite7_y:		.byte	?
; read by: draw_golfer, position_ball_sprite, draw_flag, read_aim_cursor, $b4ed, $b581, $b59f, $b750, $b757
; written by: draw_golfer, $3019, position_ball_sprite, draw_flag, $b4f2, $b586, $b5a4, $b75c
sprites_x_msb:		.byte	?
; read by: old_loader, screen_off, screen_on, bitmap_mode, text_mode, enable_raster_irq
; written by: old_loader, screen_off, screen_on, bitmap_mode, text_mode, enable_raster_irq
vic_control1:		.byte	?
; read by: set_golfer_colors, get_key, snapshot_pc, wait_frames, l33C0, clear_screen, irq, enable_raster_irq
; written by: clear_screen, $a4a2, $a4aa, $a528, enable_raster_irq
raster:		.byte	?
light_pen_x:		.byte	?
light_pen_y:		.byte	?
; read by: check_terrain, l3C3F, $3d3b, $3d45, $3d59, $3d70, $3d8a, $b4cc, $b76d, $b785
; written by: $2ec1, check_landing, $3159, check_terrain, l3C3F, $3d40, $3d5e, $3d75, $3d8f, new_game, shot_loop, $b4d1, $b772, $b78a
sprite_enable:		.byte	?
; read by: old_loader, bitmap_mode, text_mode
; written by: old_loader, bitmap_mode, text_mode
vic_control2:		.byte	?
; read by: load_animation, $a463, $a46c, $a4e6, $a4ef
; written by: load_animation, clear_screen, $a46f, $a4f2
sprite_expand_y:		.byte	?
; read by: bitmap_mode, text_mode
; written by: old_loader, bitmap_mode, text_mode
vic_memory:		.byte	?
; read by: irq
; written by: irq
vic_irq_status:		.byte	?
; read by: irq, enable_raster_irq
; written by: enable_raster_irq
vic_irq_enable:		.byte	?
sprite_priority:		.byte	?
; read by: load_animation, $a456, $a4d9
; written by: load_animation, clear_screen, $a45f, $a4e2
sprite_multicolor:		.byte	?
; read by: load_animation, position_ball_sprite
; written by: load_animation
sprite_expand_x:		.byte	?
sprite_sprite_collision:		.byte	?
sprite_background_collision:		.byte	?
; written by: main
; modified by: $c177
border_color:		.byte	?
; written by: old_loader, clear_screen, $a52d
background_color:		.byte	?
background_color1:		.byte	?
background_color2:		.byte	?
background_color3:		.byte	?
; read by: $a480, $a503
; written by: main, clear_screen, $a48f, $a512
sprite_multicolor0:		.byte	?
; read by: main, shot_loop, $a493, $a516
; written by: main, clear_screen, $a49c, $a51f
sprite_multicolor1:		.byte	?
; read by: $a473
; written by: set_golfer_colors, clear_screen, $a47c
sprite0_color:		.byte	?
sprite1_color:		.byte	?
sprite2_color:		.byte	?
; read by: $a4f6
; written by: clear_screen, $a4ff
sprite3_color:		.byte	?
sprite4_color:		.byte	?
sprite5_color:		.byte	?
; written by: clear_screen
sprite6_color:		.byte	?
; written by: $b4db, $b777, $b77f
sprite7_color:		.byte	?
vic_unused_2f:		.byte	?
; the C128's clock speed register; the decruncher runs at 2 MHz on a C128
; modified by: d0103, decrunch
c128_clock:		.byte	?
; written by: beep
vic_mirrors:
		.fill	975
; ---- SID ----
; written by: swing_sound, l2F79, beep, $bb5a, $bb60, silence_sid
voice1_frequency:		.word	?
; written by: init_sid
voice1_pulse_width:		.word	?
; written by: silence_voices, swing_sound, l2F5A, l2F79, l2F9B, beep, $bb49, $bb6b
voice1_control:		.byte	?
; written by: swing_sound, l2F79, beep, init_sid
voice1_attack_decay:		.byte	?
; written by: swing_sound, l2F79, init_sid
voice1_sustain_release:		.byte	?
; written by: swing_sound, $bb02, $bb08
voice2_frequency:		.word	?
; written by: init_sid
voice2_pulse_width:		.word	?
; written by: silence_voices, swing_sound, click_sound, $bb0d, $bb2b
voice2_control:		.byte	?
; written by: swing_sound, $bada, $baea, init_sid
voice2_attack_decay:		.byte	?
; written by: swing_sound, $badd, $baef, init_sid
voice2_sustain_release:		.byte	?
voice3_frequency:		.word	?
; written by: init_sid
voice3_pulse_width:		.word	?
; written by: silence_voices
voice3_control:		.byte	?
; written by: init_sid
voice3_attack_decay:		.byte	?
; written by: init_sid
voice3_sustain_release:		.byte	?
; written by: l2F60, l2F79
filter_cutoff:		.word	?
; written by: swing_sound, l2F79
filter_control:		.byte	?
; read by: nmi
; written by: swing_sound, l2F79, nmi, $a675, beep, init_sid
volume_filter_mode:		.byte	?
sid_mirrors:
		.fill	999
; ---- color RAM ----
color_ram:
		.fill	1024
; ---- CIAs ----
; read by: read_joystick
cia1_port_a:		.byte	?
; read by: read_joystick
cia1_port_b:		.byte	?
cia1_unused:
		.fill	11
; read by: irq
cia1_interrupt_control:		.byte	?
cia1_rest:
		.fill	242
; read by: old_loader, main
; written by: old_loader, main
cia2_port_a:		.byte	?
cia2_port_b:		.byte	?
; read by: main
; written by: main
cia2_direction_a:		.byte	?
cia2_rest:
		.fill	253
io_expansion:
		.fill	512
.endv

*=$e000

; ---- shape data, read with all RAM banked in ----
; lists of x/y steps, each ending with $80
; read by: draw_objects, shot_loop, bank_in_io, lB78E
; written by: shot_loop
shapes:
		.addr	shape_e026, shape_e0b1, shape_e11c, shape_e1d0, shape_e2a6, shape_e2bd, shape_e35c, shape_e3c5, shape_e3fe, shape_e443, shape_e4e4, shape_e8ef, shape_e9a0, shape_ea63, shape_ea86, shape_eb0d
		.addr	shape_eb26, shape_eb36, shape_eb0d

shape_e026:
		.byte	$00, $48, $04, $20, $18, $1c, $19, $14, $10, $11, $20, $0f, $24, $00, $1c, $00
		.byte	$1c, $fb, $26, $f5, $25, $e9, $22, $e9, $1f, $e3, $20, $d8, $18, $d8, $14, $d4
		.byte	$0d, $dc, $08, $dc, $0c, $e2, $18, $e5, $0e, $e8, $10, $ec, $0b, $f1, $08, $f1
		.byte	$fd, $f8, $ed, $f0, $f5, $e9, $fa, $e1, $f8, $de, $ec, $de, $ee, $d8, $f4, $d6
		.byte	$f4, $d3, $e8, $d2, $df, $de, $e4, $e6, $dc, $e8, $dd, $f8, $ee, $fc, $e0, $04
		.byte	$e4, $14, $ee, $1e, $80, $05, $00, $d0, $03, $24, $04, $15, $0b, $21, $0c, $20
		.byte	$04, $10, $04, $03, $0f, $0a, $10, $09, $04, $00, $05, $eb, $08, $e8, $02, $ea
		.byte	$fa, $e8, $fc, $ec, $fc, $04, $f4, $05, $f8, $06, $ef, $0e, $f0, $0e, $fc, $06
		.byte	$fd, $1c, $f5, $24, $fd, $1e, $fd, $28, $80, $09, $80
shape_e0b1:
		.byte	$00, $58, $00, $17, $0a, $12, $0e, $0e, $04, $08, $10, $04, $19, $f8, $16, $f6
		.byte	$1f, $f1, $1a, $ee, $1e, $ea, $1c, $e8, $13, $ed, $07, $eb, $ff, $f3, $ec, $e0
		.byte	$e5, $e5, $e7, $ec, $f8, $f4, $e4, $f4, $e5, $f8, $ec, $f9, $e6, $ff, $f2, $04
		.byte	$ed, $06, $f0, $14, $80, $05, $10, $e0, $0c, $02, $08, $01, $0d, $fa, $04, $f8
		.byte	$02, $fc, $f6, $00, $f1, $00, $f8, $08, $80, $05, $e0, $fc, $09, $04, $0e, $00
		.byte	$0e, $ff, $f3, $f7, $f8, $00, $80, $05, $10, $f4, $01, $1d, $03, $1f, $01, $16
		.byte	$03, $d8, $fe, $d8, $fe, $22, $ff, $23, $80, $09, $80
shape_e11c:
		.byte	$00, $20, $00, $40, $04, $31, $07, $29, $09, $20, $09, $14, $0a, $08, $08, $f8
		.byte	$04, $ed, $00, $e9, $fc, $ed, $f8, $f8, $f6, $08, $f6, $18, $f8, $28, $fb, $30
		.byte	$80, $05, $00, $e4, $01, $06, $01, $fc, $ff, $fc, $ff, $06, $80, $09, $80, $00
		.byte	$30, $00, $21, $04, $25, $02, $1b, $0d, $22, $06, $14, $14, $1e, $19, $1c, $0c
		.byte	$16, $1b, $17, $12, $14, $0c, $0d, $14, $0e, $16, $0c, $10, $0b, $0c, $07, $1a
		.byte	$0c, $25, $00, $18, $08, $10, $00, $22, $fc, $25, $f5, $10, $fe, $20, $f0, $24
		.byte	$e8, $10, $f8, $02, $fb, $ff, $ec, $fc, $fb, $f4, $f3, $f7, $fc, $f0, $f8, $f1
		.byte	$ff, $e8, $f0, $ec, $ff, $e4, $fc, $da, $e9, $e0, $00, $f0, $0b, $e8, $0a, $da
		.byte	$06, $df, $0b, $ec, $10, $db, $0d, $eb, $18, $f4, $19, $f8, $16, $f4, $1e, $e7
		.byte	$1f, $f5, $22, $f9, $18, $f8, $24, $fc, $1c, $fd, $26, $80, $05, $00, $d8, $02
		.byte	$23, $07, $22, $05, $18, $05, $f8, $fb, $f8, $fb, $18, $fa, $21, $fc, $23, $ff
		.byte	$14, $80, $09, $80
shape_e1d0:
		.byte	$00, $18, $00, $58, $05, $4d, $07, $4d, $03, $48, $09, $48, $04, $46, $05, $3e
		.byte	$10, $3f, $04, $3a, $12, $39, $05, $33, $0c, $2f, $16, $30, $08, $28, $1a, $27
		.byte	$10, $24, $1c, $1e, $0b, $18, $20, $18, $0c, $11, $21, $0b, $0c, $04, $1b, $00
		.byte	$24, $01, $13, $fa, $28, $f8, $0c, $f0, $02, $f4, $f8, $f4, $e0, $f1, $ec, $f6
		.byte	$d8, $f8, $f5, $04, $de, $07, $f4, $08, $f0, $10, $e4, $10, $f4, $1c, $e4, $1a
		.byte	$f6, $20, $e4, $20, $f8, $27, $e6, $29, $f9, $2e, $fc, $34, $e9, $32, $f9, $3a
		.byte	$ee, $3b, $fc, $40, $f4, $41, $fe, $43, $f8, $47, $fe, $46, $fc, $49, $80, $05
		.byte	$00, $ec, $02, $08, $02, $fc, $fe, $fc, $fe, $08, $80, $09, $80, $00, $54, $00
		.byte	$0a, $05, $11, $06, $11, $00, $04, $0b, $08, $10, $04, $12, $00, $0b, $03, $03
		.byte	$02, $0d, $ff, $11, $fa, $11, $f7, $02, $00, $07, $f8, $05, $f4, $01, $fc, $ff
		.byte	$fd, $f6, $f6, $fa, $fc, $ec, $f4, $ea, $f4, $fa, $ff, $eb, $fe, $f1, $01, $f9
		.byte	$02, $ec, $06, $ed, $08, $fa, $05, $f2, $14, $f5, $12, $f7, $12, $f9, $10, $f9
		.byte	$14, $fc, $15, $fe, $13, $80, $05, $01, $b4, $02, $00, $03, $f8, $ff, $f8, $fc
		.byte	$48, $fd, $4a, $80, $09, $80
shape_e2a6:
		.byte	$00, $08, $00, $22, $08, $10, $0c, $04, $0a, $fc, $04, $f8, $fc, $f8, $f6, $fc
		.byte	$f4, $04, $f8, $10, $80, $05, $80
shape_e2bd:
		.byte	$00, $20, $00, $78, $02, $6b, $08, $6e, $02, $66, $02, $5e, $0c, $61, $03, $5a
		.byte	$04, $55, $0f, $56, $04, $50, $05, $46, $18, $48, $06, $3d, $18, $3d, $04, $36
		.byte	$1d, $37, $0a, $31, $0c, $2b, $23, $2d, $0a, $26, $10, $20, $27, $21, $14, $1c
		.byte	$10, $16, $2c, $1a, $2e, $15, $10, $0f, $20, $0f, $10, $0c, $14, $08, $30, $08
		.byte	$28, $06, $30, $04, $1a, $03, $2c, $ff, $18, $fe, $24, $f9, $12, $f9, $18, $f6
		.byte	$fe, $f6, $e0, $f5, $f0, $f9, $dc, $fa, $ec, $fd, $d0, $04, $e8, $04, $d2, $09
		.byte	$f8, $08, $e8, $10, $f9, $0c, $fb, $16, $d8, $20, $fc, $1d, $dc, $2a, $f6, $24
		.byte	$fc, $32, $e8, $3f, $f4, $3d, $e8, $46, $fd, $41, $fd, $49, $f0, $54, $fe, $50
		.byte	$f2, $60, $fd, $58, $fe, $5c, $f6, $6c, $fe, $63, $fe, $68, $fa, $72, $fe, $6d
		.byte	$80, $05, $00, $e8, $02, $0e, $02, $f8, $fd, $f8, $fe, $0e, $80, $09, $80
shape_e35c:
		.byte	$00, $18, $04, $38, $0c, $37, $08, $35, $12, $33, $18, $2f, $14, $2e, $14, $2b
		.byte	$1c, $28, $20, $24, $1c, $1c, $20, $1c, $24, $1a, $28, $14, $27, $0e, $24, $0b
		.byte	$21, $0b, $25, $08, $23, $fc, $26, $fa, $21, $f8, $26, $f5, $1c, $f3, $10, $f5
		.byte	$08, $f4, $fd, $f4, $f4, $f6, $e8, $f4, $e2, $f4, $dc, $f8, $dc, $00, $d9, $06
		.byte	$dc, $10, $d8, $13, $d8, $18, $e0, $1f, $e0, $24, $e5, $28, $ec, $2a, $e7, $2d
		.byte	$f0, $32, $f7, $33, $f5, $36, $fe, $37, $80, $05, $00, $ec, $04, $08, $04, $00
		.byte	$05, $fc, $fc, $fc, $fd, $08, $80, $09, $80
shape_e3c5:
		.byte	$00, $08, $00, $14, $05, $19, $08, $18, $0c, $15, $11, $17, $14, $17, $18, $14
		.byte	$1b, $10, $1c, $0c, $23, $0b, $24, $06, $2c, $02, $34, $f8, $d4, $f8, $d0, $fd
		.byte	$d0, $04, $d8, $0c, $da, $10, $e0, $13, $e4, $1c, $e8, $1e, $ec, $1d, $f0, $1b
		.byte	$f4, $18, $f6, $10, $fc, $0f, $80, $05, $80
shape_e3fe:
		.byte	$00, $04, $02, $0e, $04, $0c, $06, $08, $0b, $07, $0e, $03, $12, $02, $16, $03
		.byte	$1a, $00, $1e, $fe, $22, $fe, $24, $00, $27, $01, $2c, $02, $2f, $00, $32, $fc
		.byte	$cd, $fc, $d0, $fe, $d2, $02, $d5, $01, $d9, $03, $dc, $03, $de, $06, $e0, $08
		.byte	$e4, $07, $e7, $04, $ec, $04, $ef, $06, $f3, $05, $f5, $08, $f9, $0a, $fb, $0d
		.byte	$ff, $0d, $80, $05, $80
shape_e443:
		.byte	$00, $38, $15, $08, $21, $f5, $18, $f8, $0e, $f9, $f8, $f9, $ec, $f7, $eb, $08
		.byte	$f8, $0a, $05, $0a, $80, $02, $e0, $d0, $40, $07, $58, $08, $56, $02, $4c, $f8
		.byte	$16, $f8, $0f, $fa, $0c, $fa, $06, $f8, $ff, $fa, $f9, $fc, $f4, $fb, $f0, $f8
		.byte	$d8, $06, $bc, $0c, $d8, $08, $f8, $07, $80, $07, $07, $0c, $00, $5c, $01, $04
		.byte	$49, $04, $49, $03, $01, $02, $01, $fb, $fe, $fb, $ff, $5c, $80, $09, $21, $fc
		.byte	$10, $02, $10, $ff, $f4, $ff, $f4, $02, $80, $0c, $f8, $18, $00, $32, $10, $20
		.byte	$22, $04, $28, $f8, $2b, $f0, $21, $f3, $0d, $f5, $fc, $f6, $f3, $f6, $ec, $f5
		.byte	$e8, $f0, $eb, $f8, $ec, $04, $eb, $24, $e8, $42, $f2, $3c, $80, $01, $d0, $f8
		.byte	$08, $28, $16, $40, $14, $3c, $13, $38, $0e, $20, $0c, $10, $0b, $fc, $15, $ef
		.byte	$0b, $f8, $04, $f9, $fe, $f9, $f4, $f8, $e2, $f1, $f3, $f9, $f9, $0c, $80, $01
		.byte	$80
shape_e4e4:
		.byte	$fb, $14, $04, $07, $04, $fd, $fc, $fd, $fc, $07, $80, $0c, $05, $14, $04, $07
		.byte	$04, $fd, $fc, $fd, $fc, $07, $80, $0c, $00, $24, $00, $02, $09, $fe, $f7, $fe
		.byte	$80, $00, $e0, $19, $03, $06, $03, $fe, $fe, $fe, $fe, $06, $80, $0c, $e6, $19
		.byte	$03, $06, $03, $fe, $fe, $fe, $fe, $06, $80, $0c, $e0, $10, $03, $06, $03, $fe
		.byte	$fe, $fe, $fe, $06, $80, $0c, $e6, $10, $03, $06, $03, $fe, $fe, $fe, $fe, $06
		.byte	$80, $0c, $19, $19, $03, $06, $03, $fe, $fe, $fe, $fe, $06, $80, $0c, $1f, $19
		.byte	$03, $06, $03, $fe, $fe, $fe, $fe, $06, $80, $0c, $19, $10, $03, $06, $03, $fe
		.byte	$fe, $fe, $fe, $06, $80, $0c, $1f, $10, $03, $06, $03, $fe, $fe, $fe, $fe, $06
		.byte	$80, $0c, $e0, $40, $0a, $08, $0a, $fa, $fa, $fa, $fa, $08, $80, $0c, $f2, $42
		.byte	$04, $06, $04, $fd, $fb, $fd, $fb, $06, $80, $0c, $0c, $43, $0b, $05, $0b, $fe
		.byte	$fe, $fe, $fe, $05, $80, $0c, $1b, $43, $0b, $05, $0b, $fe, $fe, $fe, $fe, $05
		.byte	$80, $0c, $0c, $3c, $0b, $05, $0b, $fe, $fe, $fe, $fe, $05, $80, $0c, $1b, $3c
		.byte	$0b, $05, $0b, $fe, $fe, $fe, $fe, $05, $80, $0c, $d3, $30, $01, $08, $01, $fe
		.byte	$ff, $fe, $ff, $08, $80, $0a, $d7, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08
		.byte	$80, $0a, $db, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $df, $30
		.byte	$01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $e3, $30, $01, $08, $01, $fe
		.byte	$ff, $fe, $ff, $08, $80, $0a, $e7, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08
		.byte	$80, $0a, $eb, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $ef, $30
		.byte	$01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $f3, $30, $01, $08, $01, $fe
		.byte	$ff, $fe, $ff, $08, $80, $0a, $f7, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08
		.byte	$80, $0a, $fb, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $05, $30
		.byte	$01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $09, $30, $01, $08, $01, $fe
		.byte	$ff, $fe, $ff, $08, $80, $0a, $0d, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08
		.byte	$80, $0a, $11, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $15, $30
		.byte	$01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $19, $30, $01, $08, $01, $fe
		.byte	$ff, $fe, $ff, $08, $80, $0a, $1d, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08
		.byte	$80, $0a, $21, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $25, $30
		.byte	$01, $08, $01, $fe, $ff, $fe, $ff, $08, $80, $0a, $29, $30, $01, $08, $01, $fe
		.byte	$ff, $fe, $ff, $08, $80, $0a, $2d, $30, $01, $08, $01, $fe, $ff, $fe, $ff, $08
		.byte	$80, $0a, $00, $30, $01, $20, $01, $0a, $2e, $0a, $2e, $20, $30, $20, $30, $fc
		.byte	$d0, $fc, $d0, $20, $d2, $20, $d2, $0a, $ff, $0a, $ff, $20, $80, $00, $ec, $3c
		.byte	$0c, $0d, $0c, $fe, $ec, $fe, $ec, $0d, $80, $01, $18, $3c, $10, $0d, $10, $fe
		.byte	$f0, $fe, $f0, $0d, $80, $01, $e0, $0d, $0a, $13, $0a, $ff, $fd, $ff, $fd, $13
		.byte	$80, $01, $19, $0d, $0a, $13, $0a, $ff, $fd, $ff, $fd, $13, $80, $01, $00, $21
		.byte	$00, $07, $12, $ff, $ee, $ff, $80, $01, $00, $08, $0a, $14, $0a, $fa, $f6, $fa
		.byte	$f6, $14, $80, $01, $e0, $0b, $0c, $01, $0c, $ff, $fb, $ff, $fb, $01, $80, $09
		.byte	$19, $0b, $0c, $01, $0c, $ff, $fb, $ff, $fb, $01, $80, $09, $00, $01, $14, $01
		.byte	$14, $ff, $ec, $ff, $ec, $01, $80, $09, $f1, $04, $02, $1c, $02, $00, $03, $00
		.byte	$03, $fe, $fe, $fe, $fe, $00, $ff, $00, $ff, $1c, $80, $01, $0e, $04, $02, $1c
		.byte	$02, $00, $03, $00, $03, $fe, $fe, $fe, $fe, $00, $ff, $00, $ff, $1c, $80, $01
		.byte	$d4, $04, $04, $28, $04, $26, $03, $26, $03, $00, $05, $00, $05, $fc, $fb, $fc
		.byte	$fb, $00, $fd, $00, $fd, $26, $fc, $26, $fc, $28, $80, $01, $2c, $04, $04, $28
		.byte	$04, $26, $03, $26, $03, $00, $05, $00, $05, $fc, $fb, $fc, $fb, $00, $fd, $00
		.byte	$fd, $26, $fc, $26, $fc, $28, $80, $01, $e0, $40, $1f, $10, $1f, $fa, $f2, $fa
		.byte	$f2, $10, $80, $0a, $10, $40, $1e, $10, $1e, $fa, $f1, $fa, $f1, $10, $80, $0a
		.byte	$00, $28, $29, $02, $29, $d8, $d7, $d8, $d7, $02, $80, $0a, $00, $08, $0d, $18
		.byte	$0d, $fa, $f3, $fa, $f3, $18, $80, $0a, $00, $58, $00, $14, $30, $f8, $d0, $f8
		.byte	$80, $01, $00, $6e, $00, $02, $38, $e2, $30, $e2, $00, $fe, $d0, $e2, $c8, $e2
		.byte	$80, $00, $a8, $48, $16, $03, $16, $ff, $fa, $ff, $fa, $03, $80, $0c, $a8, $3c
		.byte	$16, $0a, $16, $fc, $fa, $fc, $fa, $0a, $80, $0c, $a8, $18, $1e, $0e, $1e, $fa
		.byte	$fa, $fa, $fa, $0e, $80, $0c, $a8, $11, $20, $16, $20, $ff, $f8, $ff, $f8, $16
		.byte	$80, $0c, $a8, $0f, $22, $01, $22, $ff, $f6, $ff, $f6, $01, $80, $09, $a8, $37
		.byte	$18, $15, $18, $ff, $f8, $ff, $f8, $15, $80, $0c, $a8, $35, $1a, $01, $1a, $ff
		.byte	$f6, $ff, $f6, $01, $80, $09, $b0, $28, $21, $2a, $21, $d8, $e8, $d8, $e8, $2a
		.byte	$80, $0a, $c8, $53, $08, $01, $08, $ff, $c2, $ff, $c2, $01, $80, $00, $34, $53
		.byte	$42, $01, $42, $ff, $fc, $ff, $fc, $01, $80, $00, $40, $48, $0e, $03, $0e, $ff
		.byte	$fe, $ff, $fe, $03, $80, $0c, $40, $3c, $0e, $0a, $0e, $fc, $fe, $fc, $fe, $0a
		.byte	$80, $0c, $40, $37, $10, $15, $10, $ff, $fc, $ff, $fc, $15, $80, $01, $40, $35
		.byte	$12, $01, $12, $ff, $fa, $ff, $fa, $01, $80, $09, $40, $14, $1e, $12, $1e, $fe
		.byte	$fa, $fe, $fa, $12, $80, $0c, $40, $11, $20, $16, $20, $ff, $f8, $ff, $f8, $16
		.byte	$80, $01, $40, $0f, $22, $01, $22, $ff, $f6, $ff, $f6, $01, $80, $09, $40, $28
		.byte	$28, $2a, $28, $d8, $ef, $d8, $ef, $2a, $80, $0a, $30, $58, $08, $14, $46, $fc
		.byte	$01, $fc, $d7, $14, $80, $0c, $d0, $58, $29, $14, $ff, $fc, $ba, $fc, $f8, $14
		.byte	$80, $0c, $64, $60, $04, $08, $04, $f9, $fc, $fc, $fc, $08, $80, $0a, $64, $69
		.byte	$02, $02, $02, $ff, $fe, $ff, $fe, $02, $80, $0c, $80
shape_e8ef:
		.byte	$f8, $08, $0e, $00, $fe, $fe, $fd, $01, $80, $0c, $08, $fc, $0e, $05, $12, $06
		.byte	$09, $0b, $14, $06, $1a, $06, $27, $04, $2c, $03, $30, $02, $30, $01, $2e, $00
		.byte	$2e, $ff, $29, $fe, $22, $fe, $20, $01, $1d, $02, $1b, $02, $18, $01, $16, $fe
		.byte	$f2, $fe, $f1, $ff, $f0, $01, $ee, $03, $eb, $04, $e8, $03, $e6, $01, $e5, $ff
		.byte	$e4, $fe, $e2, $fe, $d9, $00, $d7, $00, $d7, $02, $d8, $02, $d8, $07, $db, $07
		.byte	$f4, $0b, $f6, $0b, $f9, $06, $80, $02, $eb, $ff, $00, $03, $03, $02, $04, $00
		.byte	$02, $fe, $fe, $fe, $fc, $00, $fd, $02, $80, $0c, $00, $00, $00, $05, $03, $04
		.byte	$05, $02, $06, $00, $03, $fd, $00, $fc, $fd, $fd, $fa, $00, $fb, $02, $fd, $04
		.byte	$80, $00, $31, $00, $00, $02, $03, $01, $04, $00, $03, $ff, $00, $fe, $fd, $ff
		.byte	$fc, $00, $fd, $01, $80, $0c, $00, $00, $01, $03, $04, $02, $05, $00, $05, $ff
		.byte	$04, $fd, $00, $fc, $fc, $fd, $fb, $ff, $fb, $00, $fc, $02, $ff, $03, $80, $00
		.byte	$80
shape_e9a0:
		.byte	$00, $10, $08, $05, $08, $fe, $f3, $fe, $fd, $05, $80, $0c, $10, $00, $04, $05
		.byte	$0c, $ff, $fa, $fe, $fa, $05, $80, $0c, $f0, $f8, $16, $0e, $26, $07, $32, $08
		.byte	$32, $07, $2f, $05, $2f, $fd, $31, $fd, $31, $fb, $27, $fb, $26, $fc, $26, $fe
		.byte	$24, $00, $22, $01, $1e, $01, $1c, $00, $1a, $fe, $1a, $fc, $19, $fb, $ef, $fb
		.byte	$ee, $fc, $ee, $fe, $ec, $00, $e9, $01, $e7, $01, $e4, $00, $e2, $fe, $e2, $fc
		.byte	$e1, $fb, $d2, $fb, $d2, $fd, $d4, $fd, $d4, $01, $d9, $03, $f0, $06, $fd, $0e
		.byte	$80, $01, $e8, $fc, $00, $04, $03, $03, $04, $01, $03, $ff, $00, $fe, $fd, $ff
		.byte	$fc, $01, $fd, $03, $80, $0c, $00, $00, $01, $05, $04, $04, $06, $02, $06, $00
		.byte	$03, $fd, $01, $fc, $ff, $fc, $fd, $fd, $fa, $00, $fa, $02, $fc, $04, $ff, $05
		.byte	$80, $00, $38, $00, $00, $04, $03, $03, $04, $01, $03, $ff, $00, $fe, $fd, $ff
		.byte	$fc, $01, $fd, $03, $80, $0c, $00, $00, $02, $05, $04, $04, $06, $02, $06, $00
		.byte	$03, $fd, $01, $fc, $ff, $fc, $fd, $fd, $fa, $00, $fa, $02, $fc, $04, $fe, $05
		.byte	$80, $00, $80
; jumped to by: irq
kernal_irq = $ea31

shape_ea63:
		.byte	$00, $18, $00, $54, $06, $4f, $08, $f0, $f8, $f0, $fa, $4f, $80, $07, $00, $ec
		.byte	$10, $04, $10, $00, $18, $00, $18, $fc, $e8, $fc, $e8, $00, $f0, $00, $f0, $04
		.byte	$80, $00, $80
shape_ea86:
		.byte	$f8, $5e, $03, $04, $03, $fc, $fc, $fc, $fc, $04, $80, $0c, $08, $00, $03, $04
		.byte	$03, $fc, $fd, $fc, $fd, $04, $80, $0c, $08, $00, $04, $04, $04, $fc, $fd, $fc
		.byte	$fd, $04, $80, $0c, $f8, $00, $0e, $06, $0e, $fa, $f2, $fa, $f2, $06, $80, $0b
		.byte	$00, $c2, $00, $4e, $04, $4d, $08, $4b, $09, $48, $0a, $44, $0a, $20, $0b, $00
		.byte	$0e, $eb, $06, $ec, $02, $eb, $f6, $ed, $f3, $ec, $f5, $00, $f6, $20, $f6, $44
		.byte	$f7, $48, $f8, $4b, $fc, $4d, $80, $01, $00, $e4, $02, $07, $06, $08, $0c, $07
		.byte	$0f, $07, $0f, $05, $15, $04, $17, $01, $1c, $ff, $1e, $fd, $20, $fc, $d0, $fc
		.byte	$d6, $fe, $da, $fe, $db, $01, $dd, $03, $e2, $02, $e7, $02, $e8, $04, $ee, $05
		.byte	$f0, $08, $f6, $09, $80, $0c, $80
kernal_scnkey = $ea87

shape_eb0d:
		.byte	$00, $18, $07, $00, $ff, $fc, $ff, $e8, $ff, $04, $80, $02, $ff, $e8, $02, $00
		.byte	$00, $fe, $fe, $00, $00, $02, $80, $00, $80
; read by: draw_terrain, lA927
shape_eb26:
		.byte	$00, $00, $14, $0a, $1e, $00, $14, $f6, $ec, $f6, $e2, $00, $ec, $0a, $80, $00
; read by: draw_terrain, lA927
shape_eb36:		.byte	$80

; read by: lA927
shapes2:
		.addr	shape_eb63, shape_eb70, shape_eb7d, shape_eb8a, shape_eb97, shape_eba8, shape_ebb9, shape_ebca, shape_ebdb, shape_ebf0, shape_ec05, shape_ec1a, shape_ec2f, shape_ec44, shape_ec59, shape_ec6e
		.addr	shape_ec83, shape_ec94, shape_eca5, shape_ecc4, shape_ecdd, shape_ecf2

shape_eb63:
		.byte	$01, $01, $02, $00, $01, $ff, $ff, $ff, $fe, $00, $ff, $01, $80
shape_eb70:
		.byte	$00, $02, $01, $01, $01, $ff, $00, $fe, $ff, $ff, $ff, $01, $80
shape_eb7d:
		.byte	$00, $01, $01, $01, $01, $00, $00, $fe, $fe, $fe, $fe, $00, $80
shape_eb8a:
		.byte	$00, $01, $01, $00, $01, $fe, $00, $fe, $fe, $00, $fe, $01, $80
shape_eb97:
		.byte	$00, $01, $02, $01, $02, $00, $02, $ff, $00, $fe, $fe, $ff, $fd, $00, $fe, $01
		.byte	$80
shape_eba8:
		.byte	$00, $02, $01, $02, $01, $00, $01, $fe, $00, $fd, $ff, $fe, $fe, $00, $ff, $02
		.byte	$80
shape_ebb9:
		.byte	$00, $02, $02, $02, $02, $00, $01, $ff, $ff, $fe, $fe, $fe, $fe, $ff, $ff, $01
		.byte	$80
shape_ebca:
		.byte	$01, $01, $02, $ff, $02, $fe, $00, $fe, $ff, $ff, $fe, $00, $fe, $02, $ff, $02
		.byte	$80
shape_ebdb:
		.byte	$01, $01, $03, $01, $03, $00, $03, $ff, $01, $fe, $ff, $fe, $fd, $ff, $fc, $00
		.byte	$fd, $01, $ff, $01, $80
shape_ebf0:
		.byte	$00, $03, $01, $03, $01, $01, $01, $ff, $01, $fd, $00, $fc, $ff, $fd, $fe, $ff
		.byte	$fe, $01, $ff, $03, $80
shape_ec05:
		.byte	$00, $02, $01, $02, $02, $02, $02, $01, $02, $00, $00, $fe, $fe, $fd, $fd, $fd
		.byte	$fd, $fe, $fe, $00, $80
shape_ec1a:
		.byte	$00, $02, $02, $00, $02, $fe, $02, $fd, $01, $fd, $00, $fe, $fe, $00, $fd, $01
		.byte	$fd, $02, $fe, $02, $80
shape_ec2f:
		.byte	$01, $02, $04, $01, $04, $00, $04, $ff, $01, $fe, $ff, $fe, $fc, $ff, $fb, $00
		.byte	$fc, $01, $ff, $02, $80
shape_ec44:
		.byte	$00, $04, $01, $04, $02, $01, $02, $ff, $01, $fc, $00, $fb, $ff, $fc, $fe, $ff
		.byte	$fe, $01, $ff, $04, $80
shape_ec59:
		.byte	$02, $03, $03, $03, $03, $02, $02, $ff, $00, $fd, $fe, $fc, $fd, $fd, $fc, $fe
		.byte	$fd, $00, $ff, $02, $80
shape_ec6e:
		.byte	$00, $02, $02, $00, $03, $fe, $03, $fd, $02, $fc, $ff, $fd, $fd, $ff, $fc, $02
		.byte	$fd, $03, $fe, $03, $80
shape_ec83:
		.byte	$00, $01, $01, $00, $01, $ff, $00, $fe, $ff, $fe, $fe, $ff, $fe, $00, $ff, $01
		.byte	$80
shape_ec94:
		.byte	$00, $02, $01, $01, $02, $00, $01, $fe, $00, $fe, $fe, $fe, $fe, $00, $fe, $01
		.byte	$80
shape_eca5:
		.byte	$00, $02, $01, $02, $02, $01, $02, $00, $02, $ff, $02, $fe, $01, $fe, $00, $fd
		.byte	$ff, $fd, $fe, $fe, $fe, $fe, $fd, $ff, $fd, $00, $fe, $01, $fe, $02, $80
shape_ecc4:
		.byte	$00, $03, $01, $02, $02, $01, $03, $00, $02, $fe, $01, $fd, $00, $fd, $fe, $fd
		.byte	$fd, $fe, $fd, $00, $fd, $01, $fe, $02, $80
shape_ecdd:
		.byte	$01, $02, $03, $01, $03, $00, $03, $fe, $01, $fd, $ff, $fd, $fd, $fe, $fc, $00
		.byte	$fd, $01, $ff, $02, $80
shape_ecf2:
		.byte	$00, $03, $01, $03, $02, $01, $02, $ff, $01, $fd, $00, $fc, $fe, $fd, $fd, $ff
		.byte	$fd, $01, $fe, $03, $80

.virtual $ed07
; never written: still the RAM's power-on pattern
; read by: decrunch_get_byte
unused_ed07:
		.fill	4345
; read by: install_interrupts
; written by: install_interrupts
kernal_copy:
		.fill	385
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
tksa:
		.fill	3
memtop:
		.fill	3
membot:
		.fill	3
; called by: l0FF3, get_key, read_hex_digit, $a63e, read_hole_number, $bb81
scnkey:
		.fill	3
settmo:
		.fill	3
acptr:
		.fill	3
ciout:
		.fill	3
untlk:
		.fill	3
unlsn:
		.fill	3
listen:
		.fill	3
talk:
		.fill	3
readst:
		.fill	3
; called by: lC0F3
setlfs:
		.fill	3
; called by: $08de, $c130
setnam:
		.fill	3
open:
		.fill	3
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
chrout:
		.fill	3
; called by: $08e3
load:
		.fill	3
; called by: lC13B
save:
		.fill	3
settim:
		.fill	3
rdtim:
		.fill	3
stop:
		.fill	3
; called by: l0FF3, read_hex_digit, read_hole_number, $bb84
getin:
		.fill	3
; called by: lC0F3
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
unused_fff6:
		.fill	4
nmi_hw_vector:		.addr	?
reset_hw_vector:		.addr	?
; read by: l3CB7
irq_hw_vector:		.addr	?
.endv
