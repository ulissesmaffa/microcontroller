;
; HelloWorldUSART.asm

;ISR Lists
.def DIN = R4
.def NEW_DATA = R5
.cseg
jmp start ; Reset 0x0000 
; jmp _INT0 ; IRQ0 0x0002 
; jmp _INT1 ; IRQ1 0x0004 
; jmp _PCINT0 ; PCINT0 0x0006 
; jmp _PCINT1 ; PCINT1 0x0008 
; jmp _PCINT2 ; PCINT2 0x000A 
; jmp _WDT ; Watchdog Timeout 0x000C 
; jmp _TIM2_COMPA ; Timer2 CompareA 0x000E 
; jmp _TIM2_COMPB ; Timer2 CompareB 0x0010 
; jmp _TIM2_OVF ; Timer2 Overflow 0x0012 
; jmp _TIM1_CAPT ; Timer1 Capture 0x0014 
; jmp _TIM1_COMPA ; Timer1 CompareA 0x0016 
; jmp _TIM1_COMPB ; Timer1 CompareB 0x0018 
; jmp _TIM1_OVF ; Timer1 Overflow 0x001A 
; jmp _TIM0_COMPA ; Timer0 CompareA 0x001C 
; jmp _TIM0_COMPB ; Timer0 CompareB 0x001E 
; jmp _TIM0_OVF ; Timer0 Overflow 0x0020 
; jmp _SPI_STC ; SPI Transfer Complete 0x0022 
.org 0x0024
jmp _USART_RXC ; USART RX Complete 0x0024 
jmp _USART_UDRE ; USART UDR Empty 0x0026 
; jmp _USART_TXC ; USART TX Complete 0x0028 
; jmp _ADC ; ADC Conversion Complete 0x002A 
; jmp _EE_RDY ; EEPROM Ready 0x002C 
; jmp _ANA_COMP ; Analog Comparator 0x002E 
; jmp _TWI ; 2-wire Serial 0x0030 
; jmp _SPM_RDY ; SPM Ready 0x0032 

.org INT_VECTORS_SIZE
start:
	call _USART_INIT
	call _CPY_MSG
	sei
loop:
	sbic PIND, PD3
	call _SEND_MSG
	tst NEW_DATA
	breq loop
	mov r16, DIN
	call _SEND_DIN
	eor NEW_DATA,NEW_DATA
    rjmp loop

_SEND_DIN:
	; Wait for empty transmit buffer
	lds r17, UCSR0A
	sbrs r17, UDRE0
	rjmp _SEND_DIN
	; Put data (r16) into buffer, sends the data
	sts UDR0, r16
	ret

_SEND_MSG:
	ldi xl, low(msg)
	ldi xh, high(msg)
_NEXT_CHAR:
	ld r16, x+
	tst r16
	breq _MSG_DONE
	call _SEND_DIN
	rjmp _NEXT_CHAR
_MSG_DONE:
	ret

_USART_RXC:
	lds DIN, UDR0
	ldi r18, 1
	mov NEW_DATA, r18
	reti

_USART_UDRE:
	reti

_USART_INIT:
	; set 115.200 U2x
	ldi r17, 0
	ldi r16, 16
	; Set baud rate to UBRR0
	sts UBRR0H, r17
	sts UBRR0L, r16
	; Enable U2X
	ldi r16, (1<<U2X0)
	sts UCSR0A,r16
	; Enable receiver and transmitter
	ldi r16, (1<<RXEN0)|(1<<TXEN0)| (1<<RXCIE0) ; | (1<<UDRIE0)
	sts UCSR0B,r16
	; Set frame format: 8data, 2stop bit
	ldi r16, (1<<USBS0)|(3<<UCSZ00)
	sts UCSR0C,r16
	ret

_CPY_MSG:
	ldi zl, low(_msg)
	ldi zh, high(_msg)
	clc
	rol zl
	rol zh
	ldi xl, low(msg)
	ldi xh, high(msg)
_loop_cpy:
	lpm r16, z+
	st  x+, r16
	tst r16
	brne _loop_cpy
	ret

_msg: .db "Hello World, Leonardo!",10,13,0,0

.dseg
msg: .byte 20
test: .db "toto"