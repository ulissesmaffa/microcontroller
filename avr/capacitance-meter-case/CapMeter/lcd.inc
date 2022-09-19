/*
 * lcd.inc
 *
 *  Created: 9/17/2017 4:10:41 PM
 *   Author: jlfragoso
 */ 

.equ LCD_CTRL = PORTB
.equ LCD_EN = PB0
.equ LCD_RS = PB1
#ifndef LCD_4BITS
.equ LCD_DATA = PORTD
#else
.equ LCD_DATA = PORTB
.equ LCD_D7 = PB5
.equ LCD_D6 = PB4
.equ LCD_D5 = PB3
.equ LCD_D4 = PB2
#endif
.equ LCD_POWER_UP		= 0x30
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


.macro delay_us
	ldi r24, @0
	rcall _delay_us
.endm

.macro delay_6ms
	rcall delay_2ms
	rcall delay_2ms
	rcall delay_2ms
.endm

.macro write_lcd_init
	ldi r24, @0
	cbi LCD_CTRL, LCD_RS;  RS=0
	rcall _write_lcd
	delay_us 100
.endm

.macro write_lcd_cmd
	ldi r24, @0
    cbi LCD_CTRL, LCD_RS  ; RS = 0
	rcall _write_lcd
#ifdef LCD_4BITS
    rcall delay_1us
	ldi r24, low(@0<<4)
;	swap r24
	rcall _write_lcd
#endif
	delay_us 50
.endm

.macro write_lcd_data
	ldi r24, @0
    sbi LCD_CTRL, LCD_RS  ; RS = 1
	rcall _write_lcd
#ifdef LCD_4BITS
	delay_us 50
	ldi r24, low(@0<<4)
;	swap r24
	rcall _write_lcd
#endif
	delay_us 50
.endm

.macro write_lcd_cmd_reg
	mov r24, @0
    cbi LCD_CTRL, LCD_RS  ; RS = 0
	rcall _write_lcd
#ifdef LCD_4BITS
    rcall delay_1us
	swap @0
	mov r24, @0
;	swap r24
	rcall _write_lcd
#endif
	delay_us 50
.endm

.macro write_lcd_data_reg
	mov r24, @0
    sbi LCD_CTRL, LCD_RS  ; RS = 1
	rcall _write_lcd
#ifdef LCD_4BITS
	delay_us 50
	swap @0
	mov r24, @0
;	swap r24
	rcall _write_lcd
#endif
	delay_us 50
.endm


init_lcd:
	write_lcd_init LCD_POWER_UP
	delay_6ms
	write_lcd_init LCD_POWER_UP
	write_lcd_init LCD_POWER_UP

#ifdef LCD_4BITS
	write_lcd_init LCD_4BIT_2LINES
	write_lcd_cmd LCD_4BIT_2LINES
#else
	write_lcd_cmd LCD_8BIT_2LINES
#endif
	write_lcd_cmd LCD_DOFF_COFF_BOFF
	write_lcd_cmd LCD_CLEAR
	rcall delay_2ms
	write_lcd_cmd LCD_MODE_INC
	write_lcd_cmd LCD_DON_COFF_BOFF
	ret


_write_lcd:   ; cmd on R24
#ifndef LCD_4BITS
	out LCD_DATA, R24
#else
	cbi LCD_DATA, LCD_D7
	cbi LCD_DATA, LCD_D6
	cbi LCD_DATA, LCD_D5
	cbi LCD_DATA, LCD_D4
	sbrc r24, 7
	sbi LCD_DATA, LCD_D7
	sbrc r24, 6
	sbi LCD_DATA, LCD_D6
	sbrc r24, 5
	sbi LCD_DATA, LCD_D5
	sbrc r24, 4
	sbi LCD_DATA, LCD_D4
#endif
	sbi LCD_CTRL, LCD_EN  ; EN = 1
	rcall delay_1us
	cbi LCD_CTRL, LCD_EN ; EN = 0
	ret

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