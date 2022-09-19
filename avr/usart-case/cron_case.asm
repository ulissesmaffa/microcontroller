;
; lab08_b.asm
; Author : ulisses
;
.def DIN = R4
.def NEW_DATA = R5

.def MILISEG = R21
.def SEGUNDO = R22
.def MINUTO  = R23

.cseg
jmp start ; Reset 0x0000 
.org 0x0016
jmp _TIM1_COMPA ; Timer1 CompareA 0x0016 
.org 0x0024
jmp _USART_RXC ; USART RX Complete 0x0024 
jmp _USART_UDRE ; USART UDR Empty 0x0026 

.org INT_VECTORS_SIZE

start:
;USART
	call _USART_INIT
	call _CPY_MSG
;habilita interrupções
	sei
;config led
    ldi r16, 0x10
	out DDRD, r16
;config btn - PC0 pull-up
	ldi r16, 0x01
	out PORTC, r16
;config interrupções
	;presclaer 1:256
	ldi r16, (1<<CS12)|(0<<CS11)|(0<<CS10)
	sts TCCR1B, r16
	;configura comparador 0,1s=6250=1806 -SEGUNDO É 62500=F424
	ldi r16, 0x18
	sts OCR1AH, r16
	ldi r16, 0x06
	sts OCR1AL, r16
	;registrador de inicio
	ldi r16, 0x00
	sts TCNT1H, r16
	sts TCNT1L, r16

;config controle liga led
	ldi r18, 0x00

;ENVIA MENSAGEM INICIAL
	call _SEND_MSG

;PRIMEIRO LOOP. CRONOMETRO NAO INICIADO AINDA
loop:
	;sbi PORTD, 4 ;liga led
	sbis PINC, 0 ;verifica se btn foi pressionado
	rjmp btn_press ;btn pressionado
    rjmp loop

btn_press:
	cbi PORTD, 4 ;desliga led
	sbis PINC, 0 ;verifica se btn está pressionado
	rjmp btn_press ;btn pressionado
    ;rjmp loop ;btn solto

;APOS APERTAR BTN E ESPERAR SOLTAR, INICIA CONTAGEM

;config cronometro
	;habilita interrupção do timer1
	ldi r16, (1<<OCIE1A)
	sts TIMSK1, r16

;inicializa contagem
start_cron:
	;zerar registradores do cronometro
	ldi MILISEG, 0
	ldi SEGUNDO, 0
	ldi MINUTO, 0

;aguarda btn 2. CASO APERTE O BTN NOVAMENTE, O PROGRAMA APENAS ZERA OS REGISTRADORES DE TEMPO
loop2:
	sbis PINC, 0 ;verifica se btn foi pressionado
	rjmp btn_press2 ;btn pressionado
    rjmp loop2
btn_press2:
	cbi PORTD, 4 ;desliga led
	sbis PINC, 0 ;verifica se btn está pressionado
	rjmp btn_press2 ;btn pressionado
	call _SEND_MSG ;deve trocar por msg2
    rjmp start_cron ;btn solto

;INTERRUPÇÃO TIMER1 =======================
_TIM1_COMPA:
	;zerar comparador
	ldi r16, 0x00
	sts TCNT1H, r16
	sts TCNT1L, r16
	
	;atualizacao do cronometro
	inc MILISEG
	;verifica miliseg
	call ver_miliseg
	;verifica segundo
	call ver_segundo
	;verifica minuto
	call ver_minuto
	
	;inicio incremento de comunicação USART
	ldi r16, 48
	ldi r18, 0
	ldi r19, 0
	mov r24, MINUTO
	call uint8_asc
	mov r16, r19
	call _SEND_DIN
	mov r16, r20
	call _SEND_DIN
	ldi r16, 58
	call _SEND_DIN
	ldi r16, 48
	ldi r18, 0
	ldi r19, 0
	mov r24, SEGUNDO
	call uint8_asc
	mov r16, r19
	call _SEND_DIN
	mov r16, r20
	call _SEND_DIN
	ldi r16, 58
	call _SEND_DIN
	ldi r16, 48
	ldi r18, 0
	ldi r19, 0
	mov r24, MILISEG
	call uint8_asc
	mov r16, r20
	call _SEND_DIN
	ldi r16, 13
	call _SEND_DIN

	reti

;FIM INTERRUPÇÃO TIMER1 =======================

ver_miliseg:
	cpi MILISEG, 0x0A
	brne fim_miliseg
	ldi MILISEG, 0x00
	inc SEGUNDO
fim_miliseg:
	ret

ver_segundo:
	cpi SEGUNDO, 0X3C
	brne fim_segundo
	ldi SEGUNDO, 0x00
	inc MINUTO
fim_segundo:
	ret

ver_minuto:
	cpi MINUTO, 0x3C
	brne fim_minuto
	ldi MINUTO, 0x00
fim_minuto:
	ret ;aqui vai ser o final do programa ou voltar para inicio

uint8_asc:
    cpi r24, 100
    brsh DivideBy100_uint8	
    cpi	r24, 10
    brsh DivideBy10_uint8
    mov	r20, r24
    add	r18, r16
    add	r19, r16
    add	r20, r16
    ret

DivideBy100_uint8:
    subi r24, 100
    inc	r18
    rjmp uint8_asc
                                    
DivideBy10_uint8:
    subi r24, 10
    inc	r19
    rjmp uint8_asc

          

;USART ===========================
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

;FIM USART ============

_msg: .db "Aperte o botao",10,13,0,0
.dseg
msg: .byte 20