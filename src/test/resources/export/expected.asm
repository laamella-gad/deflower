
*=$c000

entry:
		ldx #$07
; jumped to by: entry
lC002:
		lda glyph_b, x
		sta $0400, x
		dex 
		bpl lC002
		lda font + $c
		jmp (aC032)
*=$c020

; the character set
; read by: entry
font:
		.binary	"font.bin"
; letter B
; read by: entry
glyph_b = $c028

table:
		.binary	"table.prg", 2
; read by: entry
aC032 = $c032

tail:
		.byte	$01, $02