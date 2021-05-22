.include"m8535def.inc"
	.def aux =r16
	.def col=r17
	.equ A = $77
	.equ B = $7c
	.equ C = $39
	.equ D = $5e
	.equ E = $79
	.equ F = $71
	.equ G = $7d
	.equ H = $76
	.equ I = $06
	.equ J = $1e
	.equ L = $38
	.equ N = $37
	.equ O = $3f
	.equ P = $73
	.equ Q = $67
	.equ R = $50
	.equ S = $6d
	.equ T = $78
	.equ U = $3e
	.equ Ye = $6e

.macro ldb
	ldi aux,@1
	mov @0,aux
	.endm
.macro mensaje
	ldb r7,@0 
	ldb r6,@1
	ldb r5,@2 
	ldb r4,@3
	ldb r3,@4 
	ldb r2,@5
	ldb r1,@6 
	ldb r0,@7
	.endm

reset:
	rjmp main ; vector de reset
	rjmp texto1;verctor INT0
	rjmp texto2;verctor INT1
	.org $008
	rjmp corre;vector timer1
	rjmp barre;vector timer0
	.org $012
	rjmp stop ;vector INT2
main:
	ldi aux,low(ramend)
	out spl,aux
	ldi aux,high(ramend)
	out sph,aux
	rcall config_io
	rcall texto0
	clr zh
	clr zl
	ldi col,1;00000001
	out portc,col
	ld aux,z
	out porta,aux
uno:nop
	nop
	rjmp uno
config_io:
	ser aux
	out ddra,aux
	out portb,aux
	out ddrc,aux
	out portd,aux
	ldi aux,3
	out tccr0,aux; preescala ck/64
	ldi aux,2
	out tccr1b,aux; preescala ck/8
	ldi aux,$01; 0000 0001
	out timsk,aux; toie0
	ldi r18,193; para contar 63 4ms
	ldi aux,$0a; 0000 1010
	out mcucr,aux
;	ldi r19,255
;	ldi r20,1
	ldi r19,0x0B
	ldi r20,0xDC
	out TCNT1H,r19
	out TCNT1L,r20
	ldi aux,$e0; 1110 0000
	out gicr,aux
	sei
	ret

texto0:
	mensaje 0,H,O,L,A,0,Ye,0
	rcall limpia
	ret
texto1:
	mensaje 0,G,H,I,J,L,0,0
	rcall limpia
	reti
texto2:
	mensaje 0,A,B,C,D,E,F,G
	rcall limpia
	reti
limpia:
	clr r8
	clr r9
	ret
barre:
	out tcnt0,r18
	out porta,zh
	inc zl
	lsl col
	brne dos; si z = 0
	ldi col,1
	clr zl
dos:
	com col
	out portc,col
	com col
	ld aux,z
	out porta,aux
	reti
corre:
	mov r9,r8
	mov r8,r7
	mov r7,r6
	mov r6,r5
	mov r5,r4
	mov r4,r3
	mov r3,r2
	mov r2,r1
	mov r1,r0
	mov r0,r9
	reti
stop:
	push aux
	push col
	in aux,timsk
	ldi col,$04; 0000 0100
	eor aux,col
	out timsk,aux
	pop col
	pop aux
	reti
