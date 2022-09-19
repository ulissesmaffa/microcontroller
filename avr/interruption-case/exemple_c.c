/*
 * main.cpp
 *
 * Exemplo de interrupcao INT1 no ATMEGA328P em C
*/
#define __HAS_DELAY_CYCLES 0 // para poder chamar delay com variavel
#define F_CPU 16000000  //clock frequency // precisa pro delay.h
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

int8_t select_delay = 0;
int current_delay = 250;
const int delays[] = {125,250,500,750};

// rotina da interrupcao INT1
ISR(INT1_vect) {
	select_delay++;    //incrementa para proximo delay
	select_delay &= 0x03; // mantem soh ultimo dois bits (0 a 3)
	current_delay = delays[select_delay];
}

int main(void)
{
	// LED PORTB0
	DDRB = (0x01); // habilita porta B0 para saida
	PORTB |= _BV(0); // seta bit 0 para 1 (_BV macro para setar bit avr/sfr_defs.h)
	// configura interrupcao...
	EICRA = _BV(ISC11) | _BV(ISC10); // borda de subida da interrupcao 0
	EIMSK = _BV(INT1); // habilita interrupcao 1
    /* Replace with your application code */
	sei(); // habilita todas interrup��es
	
	//pisca led
    while (1) 
    {
		_delay_ms(current_delay);
		PORTB ^= _BV(0); // inverte bit 0
    }
	return 0;
}
