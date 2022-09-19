;
; temporizador.asm
;
; Created: 03/05/2022 14:54:31
; Author : ulisses
;



; Replace with your application code
start:
    ldi r16, 0x40
	out DDRD, r16
	ldi r16, 0x50 ;modo 1
	out OCR0A, r16
	ldi r16, (2<<COM0A0) | (3<<WGM00)
	out TCCR0A, r16
	ldi r16, (0<<CS02)|(1<<CS01)|(0<<CS00)
	out TCCR0B, r16

;led interno(PB5)
	ldi r16, 0x20
	out DDRB, r16 ;apenas PB5 como saida

;btn (PC0) saida e habilitar pull-up
	ldi r16, 0x00 
	out DDRC, r16 ;todas as portas C comop entrada
	ldi r16, 0x01
	out PORTC, r16

loop_1:
	sbi PORTB, 5 ;liga led
	sbis PINC, 0x00 ;pula se for 1
	rjmp modo_2 ;0=pressionado
    rjmp loop_1

loop_2:
	cbi PORTB, 5 ;desliga led
	sbis PINC, 0x00 ;pula se for 1
	rjmp modo_1 ;0=pressionado
    rjmp loop_2

modo_1:
	ldi r16, 0x50
	out OCR0A, r16
	rjmp loop_1

modo_2:
	ldi r16, 0xBF
	out OCR0A, r16
	rjmp loop_2
