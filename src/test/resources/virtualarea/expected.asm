
.virtual $00FB
ptr:		.word	?
.endv

*=$C000

entry:
		LDA #$00
		STA border_color
		STA color_ram + $2
		STA dD400
		STA ptr
		RTS 

.virtual $D020
; VIC-II border colour
border_color:		.byte	?
.endv

*=$D400

dD400:

.virtual $D800
color_ram:		.byte	?
second_color:
		.fill	3
.endv
