/*
 * Projeto_Leitor_Codig_de_Barras.cpp
 *
 * Created: 14/06/2022 13:07:25
 * Author : Master
 */ 
//clk arduino 16MHz:
#define F_CPU 16000000L
//taxa de transmissao: 
#define BAUD_RATE 115200L
#define UBRR_VALUE (F_CPU/8/BAUD_RATE-1)
//config LCD
#define LCD_Dir  DDRD			// Definindo a direção do LCD
#define LCD_Port PORTD			// Definindo a porta D como LCD
#define RS PD0					// Definindo o pino de Reset
#define EN PD1 					// Definindo o pino de Enable

#define USER_LENGTH 2
#define CODE_LENGTH 14

#include <avr/io.h>
#include <avr/common.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <math.h>

bool  isZero = false;//garante que primeiro bit eh 1
int counter = 0;
double barTime = 0;
double auxTime = 0;
bool autorizado = false;
int codigo[14];
int index = 0;
int soma = 0;

typedef struct {
	const char* nome;
	int codigo[14];
} User;
User users[2] = {
		{
			"Lucas",
			{1,1,0,0,1,0,1,1,0,0,1,0,1,1},
		},
		{
			"Ulisses",
			{1,0,0,1,0,1,0,0,1,1,1,0,0,1},
		},
	};

void _LCD_SEND_COMMAND(unsigned char cmnd )
{
	LCD_Port = (LCD_Port & 0x0F) | (cmnd & 0xF0); // Envia o nibble mais alto
	LCD_Port &= ~ (1<<RS);						  // Rs em 0 para receber uma instrução
	LCD_Port |= (1<<EN);
	_delay_us(1);
	LCD_Port &= ~ (1<<EN);

	_delay_us(200);

	LCD_Port = (LCD_Port & 0x0F) | (cmnd << 4);   // Envia o nibble mais baixo
	LCD_Port |= (1<<EN);
	_delay_us(1);
	LCD_Port &= ~ (1<<EN);
	_delay_ms(2);
}

void _LCD_SEND_CHAR(unsigned char data )
{
	LCD_Port = (LCD_Port & 0x0F) | (data & 0xF0); // Envia o nibble mais alto
	LCD_Port |= (1<<RS);						  // Rs em 1 para receber um dado
	LCD_Port |= (1<<EN);
	_delay_us(1);
	LCD_Port &= ~ (1<<EN);

	_delay_us(200);

	LCD_Port = (LCD_Port & 0x0F) | (data << 4); // Envia o nibble mais baixo
	LCD_Port |= (1<<EN);
	_delay_us(1);
	LCD_Port &= ~ (1<<EN);
	_delay_ms(2);
}

void _LCD_SEND_STRING(const char *str)
{
	int i;
	for(i=0;str[i]!=0;i++)
	{
		_LCD_SEND_CHAR(str[i]);
	}
}

void _LCD_SEND_STRING_XY (char row, char pos, const char *str)
{
	if (row == 0 && pos<16)
	_LCD_SEND_COMMAND((pos & 0x0F)|0x80);
	else if (row == 1 && pos<16)
	_LCD_SEND_COMMAND((pos & 0x0F)|0xC0);
	_LCD_SEND_STRING(str);
}

void _LCD_CLEAR()
{
	_LCD_SEND_COMMAND(0x01);
	_delay_ms(2);
	_LCD_SEND_COMMAND(0x80);
}

//Interrupção por mudança de estado do pino PB1
void _PCINT_INIT(void){
	PCICR = (1 << PCIE0);//habilita interrupcao pinos [7:0]
	PCMSK0 = (1 << PCINT1); //habilita interrupcao no pino PB1
	//config timer modo normal
	TCCR1A &= (~(1 << WGM10)) & (~(1 << WGM11));
	TCCR1B &= (~(1 << WGM12)) & (~(1 << WGM13));
	//prescaler 1024
	TCCR1B |= (1 << CS10) | (1 << CS12); 
	TCCR1B &= (~(1 << CS11));
	TCCR2B |= (1 << CS10) | (1 << CS21) | (1 << CS22) ;
	
	TIMSK1 = (1 << TOIE1);//habilita chamada do overflow
	TCNT1 = 0;//contador do interupcao
}

void _LCD_INIT(void)
{
	LCD_Dir = 0xFF;			// Define Porta D como saída
	_delay_ms(20);			// Delay para ligar o LCD
	
	_LCD_SEND_COMMAND(0x02);				// Inicializa LCD
	_LCD_SEND_COMMAND(0x28);				// Seta LCD para o modo de 4-bits
	_LCD_SEND_COMMAND(0x0c);              // Desabilita o cursor
	_LCD_SEND_COMMAND(0x06);              // Incrementa o cursor
	_LCD_SEND_COMMAND(0x01);              // Limpa o display
	_delay_ms(2);
}

//interrupcao do PB1
ISR(PCINT0_vect){
	if(counter == 0){//primeira entrada para contar tempo medio
		_LCD_CLEAR();	
		TCNT1=0;//zerar contador
		counter++;
	}else if(counter < 7){
		
		if(counter == 6){
			//medir tempo medio da passagem do cartao (1;0;1;0;1;0)
			barTime = TCNT1/6;//tempo medio de uma barra (velocidade)
			TCNT1=0;//zerar contador
		}
		counter++;
	
	}else{
		if(isZero){//BIT 0
			auxTime = round(TCNT1/barTime);
			TCNT1=0;//zerar contador
			isZero = false;
			if(auxTime==0){
				codigo[index] = 0;
				_LCD_SEND_STRING("0");
				index++;
			}
			for(int i=0; i<auxTime; i++){
				codigo[index] = 0;
				_LCD_SEND_STRING("0");
				index++;
			}
		//primeiro bit depois do calc de media deve ser 1
		}else{//BIT 1
			auxTime = round(TCNT1/barTime);//verifica quantos bit 1
			TCNT1=0;//zerar contador
			isZero = true;//se estou no 1 o prox vai ser zero
			if(auxTime==0){//se arredondou para zero, deve ter ao menos 1 bit 1
				codigo[index] = 1;
				_LCD_SEND_STRING("1");
				index++;
			}
			//inserindo codigo
			for(int i=0; i<auxTime; i++){
				codigo[index] = 1;
				_LCD_SEND_STRING("1");
				index++;
			}
		}
	}
}

ISR(TIMER1_OVF_vect){
	if(index != 0){
		if(index > 0 && index <14){
			_LCD_CLEAR();
			_LCD_SEND_STRING_XY(0,5,"TENTE");
			_LCD_SEND_STRING_XY(1,3,"NOVAMENTE");
		}
	}
	isZero = false;
	index = 0;
	counter = 0;
	barTime = 0;
}

int main(void)
{
	_PCINT_INIT();//interrupcao PB1
	_LCD_INIT();
	_LCD_SEND_STRING_XY(0,6,"INSIRA");
	_LCD_SEND_STRING_XY(1,5,"O CODIGO");
	sei();//habilita interrupcoes globalmente

    while (1)
    {	
		while(index<CODE_LENGTH);//travado enquanto sistema coleta bits
		_LCD_CLEAR();
		//verifica autenticidade do codigo
		for(int j=0; j<USER_LENGTH; j++){//varre usuarios
			for(int i=0; i<CODE_LENGTH; i++){//varre codigo dos usuarios
				if(codigo[i] == users[j].codigo[i]){
					soma++;
				}
			}
			if(soma == CODE_LENGTH){//VALIDACAO DE AUTENTICIDADE. SOMA DE BIT LEITURA=BIT BD
				_LCD_SEND_STRING("BEM-VINDO:");
				_LCD_SEND_COMMAND(0xC0);
				_LCD_SEND_STRING(users[j].nome);
				autorizado = true;
			}
			soma=0;
		}
		if(!autorizado){
			_LCD_CLEAR();
			_LCD_SEND_STRING_XY(0,5,"TENTE");
			_LCD_SEND_STRING_XY(1,3,"NOVAMENTE");
		}
		//REINICIALIZACAO DO SISTEMA, ESPERA RECEBER NOVO CODIGO
		autorizado = false;
		isZero = false;
		index = 0;
		counter = 0;
		barTime = 0;
		soma =0;
    }
}

