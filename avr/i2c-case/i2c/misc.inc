/*
 * misc.inc
 *
 *  Created: 10/17/2017 2:33:36 PM
 *   Author: jlfragoso
 */ 

 #ifndef __MISC_INC__
 #define __MISC_INC__

.macro nibble_to_hex
	andi @0, 0x0f
	ori @0, 0x30
	cpi @0, 0x3a
	brmi pc+2
	add @0, @1
	nop
.endm

.macro wait_button_press
	sbis @0, @1
	rjmp pc-1
.endm

.macro wait_button_release
	sbic @0, @1
	rjmp pc-1
.endm

.macro wait_button_press_and_release
	sbis @0, @1
	rjmp pc-1
	sbic @0, @1
	rjmp pc-1
.endm

.macro delay_us
	ldi r24, @0
	rcall _delay_us
.endm

.macro delay_6ms
	rcall delay_2ms
	rcall delay_2ms
	rcall delay_2ms
.endm

.cseg
delay_1us:
	nop
	ldi r24, 2
loop1_d1:
	dec r24
	brne loop1_d1
	ret

_delay_us:  ; carregar em r24 valor em us
	ldi r25, 3
loop1_d45:
	nop
	dec r25
	brne loop1_d45
	dec r24
	brne _delay_us
	ret

delay_2ms:
	ldi r24, low(57520)
	ldi r25, high(57520)
loop1_d2:
	adiw r24,1
	brne loop1_d2
	ret



 #endif

