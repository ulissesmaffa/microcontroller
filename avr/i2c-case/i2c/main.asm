;
; i2c.asm
;
; Created: 10/17/2017 12:04:47 PM
; Author : jlfragoso
;

.cseg
.org 0x0000
;ISR Lists
	jmp start					; 0x0000 Reset
;	jmp INT0_ 					; 0x0002 IRQ0
;	jmp INT0_ 					; 0x0004 IRQ1
;	jmp PCINT1_					; 0x0006 PCINT0
;	jmp PCINT1_					; 0x0008 PCINT1
;	jmp PCINT2 					; 0x000A PCINT2
;	jmp WDT 					; 0x000C Estouro de Watchdog
;	jmp TIM2_COMPA 				; 0x000E Timer2 Comparacao A
;	jmp TIM2_COMPB 				; 0x0010 Timer2 Comparacao B
;	jmp TIM2_OVF 				; 0x0012 Timer2 Estouro
;	jmp TIM1_CAPT 				; 0x0014 Timer1 Captura
;	jmp TIM1_COMPA 				; 0x0016 Timer1 Comparacao A
;	jmp TIM1_COMPB 				; 0x0018 Timer1 Comparacao B
;	jmp TIM1_OVF 				; 0x001A Timer1 Estouro
;	jmp TIM0_COMPA 				; 0x001C Timer0 Comparacao A
;	jmp TIM0_COMPB 				; 0x001E Timer0 Comparacao B
;	jmp TIM0_OVF 				; 0x0020 Timer0 Estouro
;	jmp SPI_STC 				; 0x0022 SPI Transferencia Completa
;	jmp USART_RXC 				; 0x0024 USART RX Completa
;	jmp USART_EMPTY				; 0x0026 Registro de Dados Vazio na USART
;	jmp USART_TXC				; 0x0028 USART TX Completa
;	jmp ADC_COMP                ; 0x002A ADC Conversion Complete
;	jmp EE_READY				; 0x002C EEPROM Ready
;	jmp ANALOG_COMP				; 0x002E Analog Comparator
.org 0x0030
    jmp TWI_ISR					; 0x0030 2-wire Serial Interrupt (I2C)
;	jmp SPM_READY				; 0x0032 Store Program Memory Ready


.org INT_VECTORS_SIZE

.include "lcd_i2c.inc"

; Replace with your application code
.cseg
start:

	; configuracao da pilha
	ldi r16, high(RAMEND) 
	out sph, r16
	ldi r16, low(RAMEND)
	out spl, r16

	; configuracao das portas
	ldi r24, (1<<PD2); 	
	out ddrd, r24 ; port D botao e Led
	ldi r24, (1<<PC4)|(1<<PC5)
	out ddrc, r24

	; inicializa I2c e LCD
	rcall config_twi
	rcall init_lcd

	;programa
	write_lcd_cmd (LCD_SET_CURSOR | LCD_LINE_0 | 0x00)
	write_lcd_data 'U'
	write_lcd_data 'e'
	write_lcd_data 'r'
	write_lcd_data 'g'
	write_lcd_data 's'
	wait_button_press_and_release PIND, PD3
	rcall clear_lcd
	write_lcd_cmd (LCD_SET_CURSOR | LCD_LINE_1 | 0x00)
	write_lcd_data 'B'
	write_lcd_data 'e'
	write_lcd_data 'm'
	write_lcd_data '-'
	write_lcd_data 'V'
	write_lcd_data 'i'
	write_lcd_data 'n'
	write_lcd_data 'd'
	write_lcd_data 'o'
	write_lcd_data '!'

inf:
	nop
    rjmp inf


