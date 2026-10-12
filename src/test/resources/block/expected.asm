
*=$c000

entry:
		lda #$0f
		sta volume
		lda notes + $1
		sta control1
		rts 

waveform:
		.byte	$21
; read by: entry
notes:
		.byte	$10, $20, $30

.virtual $d400
; the SID chip's registers
freq1:		.word	?
.endv

.virtual $d404
; written by: entry
control1:		.byte	?
.endv

.virtual $d418
; written by: entry
volume:		.byte	?
.endv
