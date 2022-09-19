/*
 * twi.inc
 *
 *  Created: 10/17/2017 12:05:20 PM
 *   Author: jlfragoso
 */ 

 #ifndef __TWI_INC__
 #define __TWI_INC__

 .equ TWI_START			= 0x08
 .equ TWI_RESTART		= 0x10
 .equ TWI_SLA_W_ACK		= 0x18
 .equ TWI_SLA_W_NACK	= 0x20
 .equ TWI_DATA_ACK		= 0x28
 .equ TWI_DATA_NACK		= 0x30
 .equ TWI_ARB_LOST		= 0x38

 .cseg
 ; twi interruption service routine
 TWI_ISR:
	reti

 /*
 * Init TWI to 100Khz
 */
 config_twi:
	sbi PORTC, PC4
	sbi PORTC, PC5
	ldi r24, 72   ; ((16M/100K)-16)/2
	sts TWBR, r24
	ldi r24, 0
	sts TWSR, r24
	ldi r24, (1 << TWEN) | (1 << TWIE) | (1 << TWEA)
	sts TWCR, r24
	ret

;R24 slave address
;Z a start address of byte vector null-ended 
write_twi:
	push r16
	; send start condition
	ldi r16,(1<<TWINT) | (1<<TWSTA) | (1<<TWEN)
	sts TWCR, r16
wait1:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait1
	lds r16,TWSR
	andi r16, 0xF8
	cpi r16, TWI_START
	;brne end_write_twi
	; send SLA + W 
	clc
	rol r24
	sts TWDR, r24
	ldi r16, (1<<TWINT) | (1<<TWEN)
	sts TWCR, r16
wait2:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait2
	lds r16,TWSR
	andi r16, 0xF8
	cpi r16, TWI_SLA_W_ACK
	;brne end_write_twi

	; send data from memory
twi_send_data:
	ld r16, z+
	tst r16
	breq end_write_twi
	sts TWDR, r16
	ldi r16, (1<<TWINT) |(1<<TWEN)
	sts TWCR, r16
wait3:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait3
	lds r16,TWSR
	andi r16, 0xF8
	cpi r16, TWI_DATA_ACK
	;brne end_write_twi
	rjmp twi_send_data
end_write_twi:
	ldi r16,(1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
	sts TWCR, r16
	pop r16
	ret


;R24 slave address
;R25 register address
;R26 data 
write_byte_twi:
	push r16
	; send start condition
	ldi r16,(1<<TWINT) | (1<<TWSTA) | (1<<TWEN)
	sts TWCR, r16
wait1_:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait1_
	lds r16,TWSR
	andi r16, 0xF8
	cpi r16, TWI_START
	;brne end_write_byte_twi
	; send SLA + W 
	clc
	rol r24
	sts TWDR, r24
	ldi r16, (1<<TWINT) | (1<<TWEN)
	sts TWCR, r16
wait2_:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait2_
	lds r16,TWSR
	andi r16, 0xF8
	cpi r16, TWI_SLA_W_ACK
	;brne end_write_byte_twi

	; send reg address
twi_send_reg_:
	sts TWDR, r25
	ldi r16, (1<<TWINT) |(1<<TWEN)
	sts TWCR, r16
wait3_:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait3_
	lds r16,TWSR
	andi r16, 0xF8
	cpi r16, TWI_DATA_ACK
	;brne end_write_byte_twi
	; send data value
twi_send_data_:
	sts TWDR, r26
	ldi r16, (1<<TWINT) |(1<<TWEN)
	sts TWCR, r16
wait4_:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp wait4_
	lds r16,TWSR
;	andi r16, 0xF8
;	cpi r16, TWI_DATA_ACK
;	brne end_write_byte_twi
end_write_byte_twi:
	ldi r16,(1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
	sts TWCR, r16
	pop r16
	ret


.dseg
TWI_MODE : .db 0
TWI_NBYTES : .db 0
TWI_BUFFER : .db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

#endif
