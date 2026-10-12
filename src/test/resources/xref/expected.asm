
.virtual $0002
; modified by: sub
counter:		.byte	?
.endv

.virtual $00fb
; read by: lC009
pointer:		.word	?
.endv

*=$c000

entry:
		jsr sub
		jsr sub
		jmp lC009

; jumped to by: entry, sub
lC009:
		lda value
		sta value
		inc value
		lda table + $2, x
		lda (pointer), y
		sta (pointer), y
		sta border
		jsr chrout

lC01F:
		dex 
		bne lC01F
		jmp (aC02B)

; called by: entry
sub:
		inc counter
		beq lC009
		rts 

lC02A:
		rts 

; read by: lC01F
aC02B:
		.addr	lC02A

; read by: lC009
; written by: lC009, $c032
; modified by: lC009
value:
		.byte	$00
; read by: lC009
table:
		.byte	$01, $02, $03, $04

; reached from no label: listed by address

		sta value
		rts 
; written by: lC009
border = $d020

.virtual $ffd2
; called by: lC009
chrout:
		.fill	3
.endv
