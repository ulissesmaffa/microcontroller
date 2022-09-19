;
; LedBtn.asm
;
; Created: 03/04/2022 15:55:40
; Author : ulisses
;


; Replace with your application code
start:
;LED EXTERNO
	ldi r16, 0x80 ;1000 0000
	out DDRD, r16 ;configura PD7 como saída
;BOTAO
	ldi r16, 0x10 ;0001 0000
	out PORTD, r16 ;inicializa PD4 em LOW, habilita pull-up em PD4 
;LED INTERNO
	ldi r16, 0x20 ;0010 0000 
	out DDRB, r16 ;configura PB5 como saída
	out PORTB, r16

loop:
	sbic PIND, PD4 ;btn solto?
;NAO
	rjmp led_on ;nao, liga led
	;sbi PORTB, PB5 ;liga led interno
	;cbi PORTD, PD7;sim, desliga led
;SIM
	rjmp loop
led_on:
	sbic PIND, PD4 ;btn solto?
;NAO
	rjmp loop
;SIM
	cbi PORTB, 5 ;desliga led interno
	rjmp loop_led_on

loop_led_on:
	sbi PORTD, PD7 ;liga led externo
	rcall delay_05 ;inicia delay 0,5 segundos
	cbi PORTD, PD7 ;desliga led externo
	rcall delay_05 ;inicia delay 0,5 segundos
	rjmp loop_led_on ;loop de liga e desliga led externo

delay_05:
	ldi r16, 8
loop1:
	ldi r24, low(3037)
	ldi r25, high(3037)
delay_loop:
	adiw r24, 1
	brne delay_loop
	dec r16
	brne loop1
	ret	

