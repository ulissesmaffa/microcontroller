;
; CapMeter.asm
;
; Created: 9/16/2017 11:13:01 PM
; Author : jlfragoso
;
;                   Resistor 1K      Capacitor on Test
;                +      R1      -    + Ct -
;               -----/\/\/\/\/--------] [----------|'=
;                PD2              PD7          GROUND

; Pin Out Configuration
; PD2 --> arduino 2 --> PIN R1+ (R1 1k resitor 2-7)
; PD7 --> arduino 7 --> PIN R1-/CT+ (R1 and Test capacitor +) (CT- ground)
; PB0 --> arduino 8 --> LCD EN
; PB1 --> arduino 9 --> LCD RS
; PB2 --> arduino 10 --> LCD DB4
; PB3 --> arduino 11 --> LCD DB4
; PB4 --> arduino 12 --> LCD DB4
; PB5 --> arduino 13 --> LCD DB4
; PD4 --> arduino 4 --> Led (grove shield D4)
; PD3 --> arduino 3 --> button (grove shiel D3)

#define LCD_4BITS
;ISR Lists
	jmp start					; Reset
;	jmp INT0_ 					; IRQ0
;	jmp INT0_ 					; IRQ1
;	jmp PCINT1_					; PCINT0
;	jmp PCINT1_					; PCINT1
;	jmp PCINT2 					; PCINT2
;	jmp WDT 					; Estouro de Watchdog
;	jmp TIM2_COMPA 				; Timer2 Comparacao A
;	jmp TIM2_COMPB 				; Timer2 Comparacao B
;	jmp TIM2_OVF 				; Timer2 Estouro
.org 0x0014
	jmp TIM1_CAPT 				; Timer1 Captura
;	jmp TIM1_COMPA 				; Timer1 Comparacao A
;	jmp TIM1_COMPB 				; Timer1 Comparacao B
.org 0x001a
	jmp TIM1_OVF 				; Timer1 Estouro
;	jmp TIM0_COMPA 				; Timer0 Comparacao A
;	jmp TIM0_COMPB 				; Timer0 Comparacao B
;	jmp TIM0_OVF 				; Timer0 Estouro
;	jmp SPI_STC 				; SPI Transferencia Completa
;	jmp USART_RXC 				; USART RX Completa
;	jmp ADC_COMP

.include "lcd.inc"

.macro nibble_to_hex
	andi @0, 0x0f
	ori @0, 0x30
	cpi @0, 0x3a
	brmi pc+2
	add @0, @1
	nop
.endm


start:
	ldi r16, high(RAMEND) ; stack configuration
	out sph, r16
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r20, 0x30

	ldi r24,0x14 ; port configuration	
	out ddrd, r24
	ldi r24, 0x3F 
	out ddrb, r24
	cbi PORTD, PD2 ; ensure no comparator

	ldi r16, 0xff
	sts didr1, r16; disabling digital inputs to reduce power for comparator
	ldi r16, 0x44; enable comparator to trigger capture on rising edge (not interrupt)
	out acsr, r16
	ldi r16, 0
	sts adcsrb, r16

	rcall init_lcd

	write_lcd_data 'C'
	write_lcd_data 'a'
	write_lcd_data 'p'
	write_lcd_data ' '
	write_lcd_data 'M'
	write_lcd_data 'e'
	write_lcd_data 't'
	write_lcd_data 'e'
	write_lcd_data 'r'
	write_lcd_cmd (LCD_SET_CURSOR | LCD_LINE_1 | 0x00)
	write_lcd_data 'P'
	write_lcd_data 'r'
	write_lcd_data 'e'
	write_lcd_data 's'
	write_lcd_data 's'
	write_lcd_data ' '
	write_lcd_data 't'
	write_lcd_data 'o'
	write_lcd_data ' '
	write_lcd_data 'S'
	write_lcd_data 't'
	write_lcd_data 'a'
	write_lcd_data 'r'
	write_lcd_data 't'
wait_button:
	sbis PIND, PD3
	rjmp wait_button
	sbi PORTD, PD4
wait_release:
	sbic PIND, PD3
	rjmp wait_release
	cbi PORTD, PD4
	write_lcd_cmd (LCD_SET_CURSOR | LCD_LINE_1 | 0x00)
	write_lcd_data ' '
	write_lcd_data 'V'
	write_lcd_data 'a'
	write_lcd_data 'l'
	write_lcd_data 'u'
	write_lcd_data 'e'
	write_lcd_data ':'
	write_lcd_data ' '
	write_lcd_data ' '
	write_lcd_data ' '
	write_lcd_data ' '
	write_lcd_data ' '
	write_lcd_data ' '
	write_lcd_data ' '
	write_lcd_data 'F'
	write_lcd_data ' '

start_measure:
	write_lcd_cmd (LCD_SET_CURSOR | LCD_LINE_1 | 0x08)
	rcall delay_2ms

	clr r19 ; semaphore from interruption
	ldi r16, 0    ; timer1 configuration
	sts tcnt1h, r16 ; reset counter 1
	sts tcnt1l, r16

	sts tccr1a, r16 ; enable counter 1 reg a

	ldi r16, 0x21 ; enable Capture and Overflow interrupts	
	sts timsk1, r16

	ldi r16, 0x82; enabling noise canceler & rising edge & starting counter 
	sts tccr1b, r16 ; 
	ldi r16, 0xff ; reset flags
	out tifr1, r16

	sbi PORTD, PD2 ; turn on capacitor

	sei	

loop_esp: ; wait interruption
	tst r19
	breq loop_esp

	cli ; disable all interruption

	cbi portd, pd2 ; discharge capacitor

		; multiple by two to correct -- each count = 2nF
    clc ; clear carry
	rol r24
	rol r25

conv_16bit_ascii:
	ldi r20, 5
begin_f:
	clr r26
	clr r27
begin_w :
	tst r25
	brne go_on
	tst r24
	brmi go_on ; avoid 2comp error
	cpi r24, 10
	brmi end_w
go_on:	
	sbiw r24, 10
	adiw r26, 1
	rjmp begin_w
end_w:
	ori r24, 0x30
	push r24
	movw r24, r26
	dec r20
	brne begin_f
end_conv:
	; display result
	ldi r17, 0x01
	ldi r18, 0x01
dig5:
	pop r16
	cpi r16, 0x30
	brne p_dig5
	clr r17
	clr r18
	ldi r16, 0x20
p_dig5:
	write_lcd_data_reg r16
dig4:
	pop r16
	tst r17
	brne p_dig4
	ldi r17, 0x01
	ldi r18, 0x01
	cpi r16, 0x30
	brne p_dig4
	clr r17
	clr r18
	ldi r16, 0x20
p_dig4:
	write_lcd_data_reg r16
	; see if will print uF
	tst r18
	breq dig3
	write_lcd_data ','
dig3:
	pop r16
	tst r17
	brne p_dig3
	cpi r16, 0x30
	brne p_dig3
	clr r17
	ldi r16, 0x20
p_dig3:
	write_lcd_data_reg r16
dig2:
	pop r16
	tst r17
	brne p_dig2
	cpi r16, 0x30
	brne p_dig2
	clr r17
	ldi r16, 0x20
p_dig2:
	write_lcd_data_reg r16
dig1:
	pop r16
	tst r18
	breq put_nf
put_uf:
	write_lcd_data 'u'
	rjmp next_measure
put_nf:
	write_lcd_data_reg r16
	write_lcd_data 'n'

	; return cursor

next_measure:
	; wait before another measure
	ldi r16, 255
loop_next:
	rcall delay_2ms
	dec r16
	brne loop_next
fim_p:
    rjmp start_measure


TIM1_CAPT:
	; load result from counter
	lds r24, icr1l
	lds r25, icr1h
	; set semaphore to go 
	ldi r19, 0x01
	; stop counter to avoid overflow
	ldi r16, 0x80; enabling noise canceler e faling edge
	sts tccr1b, r16 ; mov 0x82 to enable counter at 1/8
	reti

TIM1_OVF:
	sbi PORTD, PD4
	reti
	