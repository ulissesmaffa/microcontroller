;
; multPorDeslocamento.asm
;
; Created: 25/04/2022 21:40:59
; Author : ulisses
;


; Replace with your application code
start:
	ldi r16, 195 ; registrador X
	ldi r17, 201 ; registrador Y

	ldi r18, 0 ;ZH
	ldi r19, 0 ;ZL

	ldi r20, 8

verifica_y:
	bst r17, 0 ;verificar r17(0) primeiro
	lsr r17 ;shift r17 para ver o prox bit
	brtc shift_zh ;se y(n) = 0
	rjmp soma_x  ;se y(n) = 1

soma_x:
	add r18, r16 ;soma x                     
	bst r18, 0  ;bit r18(0) para usar no shift de zn          
	brcc shift_zh    
	ror r18  ;shift right usando o carry em r18 
	rjmp shift_zl  

shift_zh:
	bst r18, 0 ;bit r18(0) em T                      
	lsr r18 ;shift right em r18 para pegar prox  

shift_zl:
	lsr r19 ;shift em r19                               
	bld r19, 7     
	subi r20, 1	                              
	brne verifica_y


fim:
  rjmp fim ; loop infinito quando acabar