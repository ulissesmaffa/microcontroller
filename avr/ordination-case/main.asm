;
; ordenacao2.asm
;
; Created: 13/04/2022 20:28:22
; Author : ulisses
;

.cseg

; Replace with your application code
start:
	; copia dados para vetores
	rcall copia_v_z
	;chamando rotina para ordenar vetor
	ldi r25, high(v_z)
	ldi r24, low(v_z)
	rcall sort

	;chamando rotina para encontrar maior
	
	ldi r25, high(v_v)
	ldi r24, low(v_v)
	rcall maior

	;ldi r24, 0x27
	sts v_maior, r24 ; guarda na memoria o resultado
	;chamando rotina para encontrar maior
	;ldi r19, 10
	ldi r25, high(v_v)
	ldi r24, low(v_v)
	rcall menor	
	sts v_menor, r24

_end:
	nop
    rjmp _end

; r25:r24 recebe o endereco do vetor
; r26 recebe o tamanho do vetor
; a rotina ordena o vetor
sort:
ini:
	ldi r19, 9
	mov xh, r25
	mov xl, r24
loopsort:
	ld r16,x+
	ld r17,x
	sub r16,r17
	brmi troca
	dec r19
	brne loopsort
	ret
troca:
	ld r16, -x
	st x+ , r17
	st x , r16
	rjmp ini

; r25:r24 recebe o endereco do vetor
; r26 recebe o tamanho do vetor
; retorna r25 igual a zero e r24 com o MAIOR valor do vetor
maior:
inimaior:
	ldi r19, 9
	mov xh, r25
	mov xl, r24
	ld r24,x+

loopmaior:
	ld r16,x+
	mov r17,r24
	sub r24,r16
	brmi ehmaior
	mov r24,r17
	dec r19
	brne loopmaior
	ldi r25,0
	ret
ehmaior:
	ld r24,-x
	rjmp loopmaior

; r25:r24 recebe o endereco do vetor
; r26 recebe o tamanho do vetor
; retorna r25 igual a zero e r24 com o MENOR valor do vetor
menor:
inimenor:
	ldi r19, 9
	mov xh, r25
	mov xl, r24
	ld r24,x+
loopmenor:
	ld r16,x+
	mov r17,r24
	sub r16,r24
	brmi ehmenor
	mov r24,r17
	dec r19
	brne loopmenor
	ldi r25,0
	ret
ehmenor:
	ld r24,-x
	rjmp loopmenor


;; simples codigo para copiar o vetor para a memoria IRAM
copia_v_z:
	ldi zh, high(__v)
	ldi zl, low(__v)
	ldi xh, high(v_v) ;; suas rotinas não devem usar os labels (so parametros)
	ldi xl, low(v_v)
	clc
	rol zl
	rol zh
	ldi r16, v_size ;; suas rotinas não devem usar v_size
loop1:
	lpm r17,z+
	st x+,r17
	dec r16
	brne loop1
	nop
	ldi zh, high(__v)
	ldi zl, low(__v)
	ldi xh, high(v_z)
	ldi xl, low(v_z)
	clc
	rol zl
	rol zh
	ldi r16, v_size
loop2:
	lpm r17,z+
	st x+,r17
	dec r16
	brne loop2
	nop
	ret

; este é um vetor de teste
; lembre-se que este valores podem mudar
; sinta-se livre para alterar e testar o seu programa
__v: 
.db 3,4,7,1,2,3,2,9,8,1,1,1
.equ v_size = 10

.dseg
v_v: ;vector 1
.byte 20
v_z: ;vector 2
.byte 20 
v_maior:
.byte 1
v_menor:
.byte 1
