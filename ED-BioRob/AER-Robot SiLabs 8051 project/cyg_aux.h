#ifndef CYG_AUX_H
#define CYG_AUX_H

//-----------------------------------------------------------------------------
// Function PROTOTYPES
//-----------------------------------------------------------------------------

void SYSCLK_Init (void);
void UART0_Init (void);
void PORT_Init (void);
void Timer2_Init (int);
void ADC0_Init(void);


void wait_one_second (void);
void CopyDescStr(char *);
void	Page_Erase(char*	Page_Address);

//-----------------------------------------------------------------------------
// Global CONSTANTS
//-----------------------------------------------------------------------------

#define SYSCLK      12000000           // SYSCLK frequency in Hz
#define BAUDRATE       38400           // Baud rate of UART in bps
#define TIMER2_RATE     1000           // Timer 2 overflow rate in Hz


#endif