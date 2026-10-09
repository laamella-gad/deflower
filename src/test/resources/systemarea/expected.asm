; VIC-II border colour
border_color = $D020
color_ram = $D800

*=$C000

entry:
		LDA #$00
		STA border_color
		STA color_ram + $2
		STA $D400
		RTS 