
.virtual $00c5
; read by: start
last_key:		.byte	?
.endv

.virtual $00fb
; overrides the zero page piece's free bytes
; read by: start
pointer:		.word	?
.endv

.virtual $0314
; read by: start
irq_vector:		.addr	?
.endv

.virtual $033c
; overlaps the system piece's tape_buffer
; written by: start
my_buffer:
		.fill	4
.endv

.virtual $0400
; written by: start
screen_ram:
		.fill	1000
.endv

*=$c000

start:
		lda #$41
		jsr chrout
		lda #$00
		sta border_color
		sta screen_color
		lda cia1_port_b
		sta screen_ram + $5
		lda pointer
		sta my_buffer + $1
		lda last_key
		sta mine
		jmp (irq_vector)

vectors:
		.addr	kernal_irq, start

.virtual $c100
; written by: start
mine:		.byte	?
.endv

.virtual $d020
; written by: start
border_color:		.byte	?
; overrides the I/O piece's background_color
; written by: start
screen_color:		.byte	?
.endv

.virtual $dc01
; keyboard rows, joystick port 1
; read by: start
cia1_port_b:		.byte	?
.endv
; the KERNAL interrupt handler: cursor, jiffy clock, keyboard
kernal_irq = $ea31
; called by: start
chrout = $ffd2