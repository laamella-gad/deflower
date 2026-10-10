
.virtual $00fb
ptr:		.word	?
.endv

*=$c000

entry:
		lda #$00
		sta border_color
		sta color_ram + $2
		sta $d400
		sta ptr
		rts 

.virtual $d020
; VIC-II border colour
border_color:		.byte	?
.endv

.virtual $d800
color_ram:		.byte	?
second_color:
		.fill	3
.endv
