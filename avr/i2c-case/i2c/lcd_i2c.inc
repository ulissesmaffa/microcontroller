/*
 * lcd_i2c.inc
 *
 *  Created: 10/17/2017 2:38:18 PM
 *   Author: jlfragoso
 */ 

 #ifndef __LCD_I2C_INC__
 #define __LCD_I2C_INC__

.equ LCD_ADDRESS		= (0x7c>>1)
.equ RGB_ADDRESS        = (0xc4>>1)
.equ LCD_POWER_UP		= 0x28
.equ LCD_8BIT_2LINES	= 0x38 
.equ LCD_8BIT_1LINE		= 0x30  ; power_up
.equ LCD_4BIT_2LINES	= 0x28 
.equ LCD_4BIT_1LINE		= 0x20 
.equ LCD_DON_COFF_BOFF	= 0x0C  ;--display on, cursor off, blink off
.equ LCD_DON_COFF_BON	= 0x0D  ;--display on, cursor off, blink on
.equ LCD_DON_CON_BOFF	= 0x0E  ;--display on, cursor on, blink off
.equ LCD_DON_CON_BON	= 0x0F  ;--display on, cursor on, blink on
.equ LCD_DOFF_COFF_BOFF	= 0x08  ;--display off, cursor off, blink off
.equ LCD_DOFF_COFF_BON	= 0x09  ;--display off, cursor off, blink on
.equ LCD_DOFF_CON_BOFF	= 0x0A  ;--display off, cursor on, blink off
.equ LCD_DOFF_CON_BON	= 0x0B  ;--display off, cursor on, blink on
.equ LCD_MODE_INC		= 0x06
.equ LCD_MODE_INC_SHIFT = 0x07
.equ LCD_MODE_DEC		= 0x04
.equ LCD_MODE_DEC_SHIF	= 0x05
.equ LCD_CLEAR			= 0x01
.equ LCD_SET_CURSOR     = 0x80
.equ LCD_LINE_0         = 0x00
.equ LCD_LINE_1         = 0x40

.include "misc.inc"
.include "twi.inc"

.macro write_lcd_cmd
	ldi r24, LCD_ADDRESS
	ldi r25, 0x80
    ldi r26, @0
	rcall write_byte_twi
	delay_us 50
.endm

.macro write_lcd_data
	ldi r24, LCD_ADDRESS
	ldi r25, 0x40
	ldi r26, @0
	rcall write_byte_twi
	delay_us 50
.endm

.macro write_lcd_cmd_reg
	mov r26, @0
	ldi r24, LCD_ADDRESS
	ldi r25, 0x80
	rcall write_byte_twi
	delay_us 50	
.endm

.macro write_lcd_data_reg
	mov r26, @0
	ldi r24, LCD_ADDRESS
	ldi r25, 0x40
	rcall write_byte_twi
	delay_us 50	
.endm

.cseg
init_lcd:

	write_lcd_cmd LCD_POWER_UP
	delay_6ms
	write_lcd_cmd LCD_POWER_UP
	delay_us 100
	write_lcd_cmd LCD_POWER_UP
	write_lcd_cmd LCD_POWER_UP
	write_lcd_cmd LCD_8BIT_2LINES
	write_lcd_cmd LCD_DOFF_COFF_BOFF
	write_lcd_cmd LCD_CLEAR
	rcall delay_2ms
	write_lcd_cmd LCD_MODE_INC
	write_lcd_cmd LCD_DON_COFF_BOFF

	ldi r24, RGB_ADDRESS
	ldi r25, 0x00
	ldi r26, 0x00
	rcall write_byte_twi
	ldi r24, RGB_ADDRESS
	ldi r25, 0x08
	ldi r26, 0xff
	rcall write_byte_twi
	ldi r24, RGB_ADDRESS
	ldi r25, 0x01
	ldi r26, 0x20
	rcall write_byte_twi

	ldi r24, RGB_ADDRESS
	ldi r25, 0x02
	ldi r26, 0x00
	rcall write_byte_twi
	ldi r24, RGB_ADDRESS
	ldi r25, 0x03
	ldi r26, 0x00
	rcall write_byte_twi
	ldi r24, RGB_ADDRESS
	ldi r25, 0x03
	ldi r26, 0xff
	rcall write_byte_twi


	ret

clear_lcd:
	write_lcd_cmd LCD_CLEAR
	rcall delay_2ms
	ret	


/*
write_lcd_string_from_flash:
	sbi LCD_CTRL, LCD_RS ; RS=1 data
	clc
	rol zl
	rol zh
_loop_string:
	lpm r24, z+
	tst r24
	brne _p_string ; 0 end string
	ret
_p_string:
	push r24
	rcall _write_lcd
#ifdef LCD_4BITS
	delay_us 50
	pop r24
	swap r24
	rcall _write_lcd
#endif
	delay_us 50
	rjmp _loop_string	

write_lcd_string_from_sram:
	sbi LCD_CTRL, LCD_RS ; RS=1 data
_loop_string_:
	ld r24, z+
	tst r24
	brne _p_string_ ; 0 end string
	ret
_p_string_:
	push r24
	rcall _write_lcd
#ifdef LCD_4BITS
	delay_us 50
	pop r24
	swap r24
	rcall _write_lcd
#endif
	delay_us 50
	rjmp _loop_string_	

*/

#endif
