;
; main.asm
;
; * Exemplo de interrupcao INT1 no ATMEGA328P em Assembly


.dseg
;variaveis na memoria RAM
current_delay:
	.db 0
select_delay:
	.db 0

.cseg
; vetor de interrupcoes
	jmp main       ;0x0000              ; Reset
.org 0x0004
	jmp INT1_vect    ;0x0004				; INT1

.org INT_VECTORS_SIZE
;constante com os delays
delays:
	.db 8, 16, 32, 48 ; 125ms, 250, 500 e 750ms @16M

INT1_vect:
	;;;; salvando o contexto
	push r16            
	in r16, SREG
	push r16
	push zh
	push zl
	push xh
	push xl
    ;;;;;;; select_delay ++
	; carregando select_delay para o R16
	ldi zh, high(select_delay)
	ldi zl, low(select_delay)
	ld r16, z
	; incrementando
	inc r16
	; mantem so os ultimos dois bits
	andi r16, 0x3
	; guarda de volta na memoria
	st z, r16

	;;;;; r16 <= delays[r16=select_delay]
	; lendo proximo delay
	ldi zh, high(delays)
	ldi zl, low(delays)
	clc
	rol zl
	rol zh
	add zl, r16
	adc zh, r1 ; r1 eh sempre 0
	; movendo para delay atual
	lpm r16, z
	;;; current_delay <= r16
	; setando endereco do delay atual
	ldi xh, high(current_delay)
	ldi xl, low(current_delay)
	st x, r16
	;;;; restaurando contexto antes de voltar
	pop xl
	pop xh
	pop zl
	pop zh
	pop r16
	out SREG, r16
	pop r16
	reti

main:
	; led PORTB0
	ldi R16, 0x01
	out DDRB, R16;
	sbi PORTB, 0
	; configurar a interrupcao
	ldi R16, (3 << ISC10) ; borda subida INT1
	sts EICRA, R16
	ldi R16, (1 << INT1) ; habilita INT1
	out EIMSK, R16

	;; seta primeiro current delay
	;; inicializa RAM variavel current_delay
	ldi r16, 8
	ldi xl, low(current_delay)
	ldi xh, high(current_delay)
	st x, r16

	sei ;; habilita interrupcao

;; loop infinito
loop:
	sbi PORTB, 0
	rcall delay_current_delay
	cbi PORTB, 0
	rcall delay_current_delay
	rjmp loop


;; rotina para delay 
delay_current_delay:  
 ;; equivale ~current_delay*(15,625ms) 
 ;; current_delay = 8 => delay ~125ms
	ldi xh, high(current_delay)
	ldi xl, low(current_delay)
	ld R16, x
loop2:
	ldi R24, low(3037)
	ldi R25, high(3037)
delay_loop2:
	adiw R24, 1
	brne delay_loop2
	dec R16
	brne loop2
	ret


