;
; Count2.asm
;
; Created: 05/04/2022 00:26:21
; Author : ulisses
;


; Replace with your application code
start:
;1-CONFIGURA ENTRADA E SAIDA
;display
	ldi r16, 0xFF
	out DDRD, r16 ;todas as portas D como saida
;led interno(PB5)
	ldi r16, 0x20
	out DDRB, r16 ;apenas PB5 como saida
;btn (PC0) saida e habilitar pull-up
	ldi r16, 0x00 
	out DDRC, r16 ;todas as portas C comop entrada
	ldi r16, 0x01
	out PORTC, r16
;2-ZERAR CONTADOR
	ldi r17, 0x00
	ldi r16, 0x3F
	nop
;3-APRESENTAR VALOR
show_display:
	out PORTD, r16
	nop

;4-ACENDER LED ARDUINO
led_on:
	sbi PORTB, 5

;5-ESPERAR ATE BTN SER PRESSIONADO
loop1:
	sbis PINC, PC0 ;pula se for 1
	rjmp led_off ;0=pressionado
	rjmp loop1
;6-APAGAR LED INTERNO
led_off:
	cbi PORTB, 5

;7-ESPERAR BTN SER SOLTO
loop2:
	sbis PINC, PC0 ;pula se for 1
	rjmp loop2
	rjmp incrementa

;8-INCREMENTO
incrementa:	 
	cpi r17, 0x09
	breq erro

	inc r17

	cpi r17, 0x01
	breq um

	cpi r17, 0x02
	breq dois

	cpi r17, 0x03
	breq tres

	cpi r17, 0x04
	breq quatro

	cpi r17, 0x05
	breq cinco

	cpi r17, 0x06
	breq seis

	cpi r17, 0x07
	breq sete

	cpi r17, 0x08
	breq oito

	cpi r17, 0x09
	breq nove

	cpi r17, 0x0A
	breq erro

;9-VOLTA ITEM 3
um:
	ldi r16, 0x06
	rjmp show_display
dois:
	ldi r16, 0x5B
	rjmp show_display
tres:
	ldi r16, 0x4F
	rjmp show_display
quatro:
	ldi r16, 0x66
	rjmp show_display
cinco:
	ldi r16, 0x6D
	rjmp show_display
seis:
	ldi r16, 0x7D
	rjmp show_display
sete:
	ldi r16, 0x07
	rjmp show_display
oito:
	ldi r16, 0x7F
	rjmp show_display
nove:
	ldi r16, 0x6F
	rjmp show_display
erro:
	ldi r17, 0x00
	ldi r16, 0x3F
	rjmp show_display