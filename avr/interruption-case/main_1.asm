;
; lab6_interrupcao.asm
; Author : ulisses

; Tab REF:
; Freq  | OCR1A
; 0.5Hz | 7A12 
; 1.0Hz | 3D09
; 2.0Hz | 1E84
; 4.0Hz | 0F42

.def freq1_h = r25
.def freq1_l = r24

.def freq2_h = r23
.def freq2_l = r22

.def freq3_h = r21
.def freq3_l = r20

.def freq4_h = r19
.def freq4_l = r18

.cseg
jmp start ; Reset 0x0000 
.org 0x0016
jmp _TIM1_COMPA ; Timer1 CompareA 0x0016 

.org INT_VECTORS_SIZE

start:
;habilita interrupções
	sei
;configura frequencias
	ldi freq1_h, 0x7A
	ldi freq1_l, 0x12
	
	ldi freq2_h, 0x3D
	ldi freq2_l, 0x09
	
	ldi freq3_h, 0x1E
	ldi freq3_l, 0x84
		
	ldi freq4_h, 0x0F
	ldi freq4_l, 0x42

;config led
    ldi r16, 0x10
	out DDRD, r16
;config btn - PC0 pull-up
	ldi r16, 0x01
	out PORTC, r16
;config interrupções
	;presclaer 1:1024
	ldi r16, (1<<CS12)|(0<<CS11)|(1<<CS10)
	sts TCCR1B, r16
	;configura comparador para 0.5Hz
	;ldi r16, 0x30
	sts OCR1AH, freq2_h
	;ldi r16, 0xD4
	sts OCR1AL, freq2_l
	;registrador de inicio
	ldi r16, 0x00
	sts TCNT1H, r16
	sts TCNT1L, r16

;config controle liga led
	ldi r18, 0x00
;config controle freq
	ldi r19, 0x00

loop:
	;sbi PORTD, 4 ;liga led
	sbis PINC, 0 ;verifica se btn foi pressionado
	rjmp btn_press ;btn pressionado
    rjmp loop

btn_press:
	cbi PORTD, 4 ;desliga led
	sbis PINC, 0 ;verifica se btn está pressionado
	rjmp btn_press ;btn pressionado

;habilita interrupção do timer1
	ldi r16, (1<<OCIE1A)
	sts TIMSK1, r16

;isso está muito feio, mas preciso terminar outros trabalho, é passível de ajuste. Sei que é possivel somar a frequencia atual com a anterior
	inc r19
	cpi r19, 0x01 ;freq1 -> freq1
	breq f1_f1
	cpi r19, 0x02 ;freq1 -> freq2
	breq f1_f2
	cpi r19, 0x03 ;freq2 -> freq3
	breq f2_f3
	cpi r19, 0x04 ;freq3 -> freq4
	breq f3_f4

	rjmp loop

f1_f1:
	sts OCR1AH, freq1_h
	sts OCR1AL, freq1_l
	rjmp loop

f1_f2:
	sts OCR1AH, freq2_h
	sts OCR1AL, freq2_l
	rjmp loop

f2_f3:
	sts OCR1AH, freq3_h
	sts OCR1AL, freq3_l
	rjmp loop

f3_f4:
	sts OCR1AH, freq4_h
	sts OCR1AL, freq4_l
	ldi r19, 0x00
	rjmp loop


;INTERRUPÇÃO TIMER1 =======================
_TIM1_COMPA:
	;zerar comparador
	ldi r16, 0x00
	sts TCNT1H, r16
	sts TCNT1L, r16

	;controle do led
	inc r18
	cpi r18,0x01
	breq led_on
	rjmp led_off

led_on:
	sbi PORTD, 4
	reti

led_off:
	cbi PORTD, 4
	ldi r18,0x00
	reti
;FIM INTERRUPÇÃO TIMER1 =======================