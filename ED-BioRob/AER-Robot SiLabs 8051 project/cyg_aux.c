

//-----------------------------------------------------------------------------
// Includes
//-----------------------------------------------------------------------------

#include "c8051f320.h"                 // SFR declarations
#include <intrins.h>
#include <stdio.h>
#include "cyg_aux.h"
#include "MMC.h"
#include "SPIMaster.h"
#include "USB_REGISTER.h"
#include "USB_MAIN.h"
#include "USB_DESCRIPTOR.h"


//-----------------------------------------------------------------------------
// 16-bit SFR Definitions for 'F32x
//-----------------------------------------------------------------------------

sfr16 DP       = 0x82;                 // data pointer
sfr16 TMR2RL   = 0xca;                 // Timer2 reload value
sfr16 TMR2     = 0xcc;                 // Timer2 counter
sfr16 TMR3     = 0x94;                 // Timer3 counter
sfr16 TMR3RL   = 0x92;                 // Timer3 reload value
sfr16 PCA0CP0  = 0xfb;                 // PCA0 Module 0 Capture/Compare
sfr16 PCA0CP1  = 0xe9;                 // PCA0 Module 1 Capture/Compare
sfr16 PCA0CP2  = 0xeb;                 // PCA0 Module 2 Capture/Compare
sfr16 PCA0CP3  = 0xed;                 // PCA0 Module 3 Capture/Compare
sfr16 PCA0CP4  = 0xfd;                 // PCA0 Module 4 Capture/Compare
sfr16 PCA0     = 0xf9;                 // PCA0 counter
sfr16 ADC0     = 0xbd;                 // ADC Data Word Register
sfr16 ADC0GT   = 0xc3;                 // ADC0 Greater-Than
sfr16 ADC0LT   = 0xc5;                 // ADC0 Less-Than





//-----------------------------------------------------------------------------
// Global VARIABLES
//-----------------------------------------------------------------------------
extern code const BYTE String2Desc[STR2LEN];
extern code const BYTE String2DescF[STR2LEN];


//Buffer for MMC data
// char xdata datos_mem[512];

//-----------------------------------------------------------------------------
// MAIN Routine
//-----------------------------------------------------------------------------

//void main (void) {

	

  
   // Disable Watchdog timer
//   PCA0MD &= ~0x40;                    // WDTE = 0 (clear watchdog timer
                                       // enable)
//   PORT_Init();                        // Initialize Port I/O
//   Init_MMC_Ports();
//   SYSCLK_Init ();                     // Initialize Oscillator

 
//  Timer2_Init(SYSCLK/TIMER2_RATE);    // Init Timer 2
//   UART0_Init();
//}

//-----------------------------------------------------------------------------
// Initialization Subroutines
//-----------------------------------------------------------------------------
extern char num_sensor;
//ADC0_Init
//   AMX0P   AMX0N    FC(limit switch)
//  4 P1.4   5 P1.5    RY
//  6 P1.6   7 P1.7    LY
//  8 P2.0   9 P2.1    RX
//  A P2.2   B P2.3    LX
//  C P2.4   D P2.5    Base

void ADC0_Init(void) 
{
   AMX0P = 4;
   AMX0N = 5;  
   ADC0CF= 0;
   ADC0CN= 0x80;
   AD0BUSY=1;
   num_sensor=0;
   //EIE1 |= 0x08;
}


//-----------------------------------------------------------------------------
// PORT_Init
//-----------------------------------------------------------------------------
//
// Configure the Crossbar and GPIO ports.
//
// P0.4 - UART TX
// P0.5 - UART RX
// P2.2 - LED

void PORT_Init (void)
{
 
                                       // weak pull-ups
   SPI0CFG   = 0x60;//SPI
    SPI0CN    = 0x01;
    SPI0CKR   = 0x01; //0x01
//	AMX0P=0x00;	//ADC
//	AMX0N     = 0x1F;
//    ADC0CN    = 0x80;	
	P0MDOUT=0x0d;	

	// P0.0  -  SCK  (SPI0), Open-Drain, Digital
    // P0.1  -  MISO (SPI0), Open-Drain, Digital
    // P0.2  -  MOSI (SPI0), Open-Drain, Digital
    // P0.3  -  NSS,  Open-Drain, Digital
    // P0.4  -  STR,  Open-Drain, Digital
    // P0.5  -  RST_FPGA,  Open-Drain, Digital
    // P0.6  -  Unassigned,  Open-Drain, Digital
    // P0.7  -  Unassigned,  Open-Drain, Digital

    // P1.0  -  Skipped,     Open-Drain, Analog
    // P1.1  -  Skipped,     Open-Drain, Analog
    // P1.2  -  Skipped,     Open-Drain, Analog
    // P1.3  -  Skipped,     Open-Drain, Analog
    // P1.4  -  Skipped,     Open-Drain, Analog
    // P1.5  -  Skipped,     Open-Drain, Analog
    // P1.6  -  Skipped,     Open-Drain, Analog
    // P1.7  -  Skipped,     Open-Drain, Analog
    // P2.0  -  Skipped,     Open-Drain, Analog
    // P2.1  -  Skipped,     Open-Drain, Analog
    // P2.2  -  Skipped,     Open-Drain, Analog
    // P2.3  -  Skipped,     Open-Drain, Analog

    P1MDIN    = 0xFF;
    P2MDIN    = 0xFF;
    P1SKIP    = 0x00;
    P2SKIP    = 0x00;
    XBR0      = 0x02;
    XBR1      = 0x40;


}

//-----------------------------------------------------------------------------
// SYSCLK_Init
//-----------------------------------------------------------------------------
//
// This routine initializes the system clock to use the internal oscillator
// at its maximum frequency.
// Also enables the Missing Clock Detector and VDD monitor.
//
void SYSCLK_Init(void)
{
#ifdef _USB_LOW_SPEED_

   OSCICN |= 0x03;                       // Configure internal oscillator for
                                         // its maximum frequency and enable
                                         // missing clock detector

   CLKSEL  = SYS_INT_OSC;                // Select System clock
   CLKSEL |= USB_INT_OSC_DIV_2;          // Select USB clock
#else
   OSCICN |= 0x03;                       // Configure internal oscillator for
                                         // its maximum frequency and enable
                                         // missing clock detector

   CLKMUL  = 0x00;                       // Select internal oscillator as 
                                         // input to clock multiplier

   CLKMUL |= 0x80;                       // Enable clock multiplier
   CLKMUL |= 0xC0;                       // Initialize the clock multiplier
   Delay();                              // Delay for clock multiplier to begin

   while(!(CLKMUL & 0x20));                // Wait for multiplier to lock
   CLKSEL  = SYS_INT_OSC;                // Select system clock  
   CLKSEL |= USB_4X_CLOCK;               // Select USB clock
#endif  /* _USB_LOW_SPEED_ */ 
}


void Delay(void)
{
   int x;
   for(x = 0;x < 500;x)
      x++;
}

//-------------------------
// Usb0_Init
//-------------------------
// USB Initialization
// - Initialize USB0
// - Enable USB0 interrupts
// - Enable USB0 transceiver
// - Enable USB0 with suspend detection
//
void Usb0_Init(void)
{
   if (String2DescF[0]==0xFF && String2DescF[1]==0xFF) 
   		CopyDescStr((char *)(String2Desc)); //Cadena 2 no inicializada
   POLL_WRITE_BYTE(POWER,  0x08);          // Force Asynchronous USB Reset
   POLL_WRITE_BYTE(IN1IE,  0x07);          // Enable Endpoint 0-2 in interrupts
   POLL_WRITE_BYTE(OUT1IE, 0x07);          // Enable Endpoint 0-2 out interrupts
   POLL_WRITE_BYTE(CMIE,   0x07);          // Enable Reset, Resume, and Suspend interrupts
#ifdef _USB_LOW_SPEED_
   USB0XCN = 0xC0;                         // Enable transceiver; select low speed
   POLL_WRITE_BYTE(CLKREC, 0xA0);          // Enable clock recovery; single-step mode
                                           // disabled; low speed mode enabled
#else                                      
   USB0XCN = 0xE0;                         // Enable transceiver; select full speed
   POLL_WRITE_BYTE(CLKREC, 0x80);          // Enable clock recovery, single-step mode
                                           // disabled
#endif /* _USB_LOW_SPEED_ */

   EIE1 |= 0x02;                           // Enable USB0 Interrupts
   EA = 1;                                 // Global Interrupt enable
                                           // Enable USB0 by clearing the USB Inhibit bit
   POLL_WRITE_BYTE(POWER,  0x01);          // and enable suspend detection
}

void CopyDescStr(char *pread) small
{
	char	EA_Save;					//	Used to save state of global interrupt enable
	char	xdata *pwrite;			//	Write Pointer				//	Read Pointer
	unsigned char	x;							//	Counter for 0-512 bytes
	unsigned char   str2len;
	//pread	=	(BYTE *)(String2Desc);
	EA_Save	=	EA;						//	Save EA
	EA	=	0;
	str2len= *pread;							//	Turn off interrupts
	pwrite	=	(char xdata *)(String2DescF);
	PSCTL	=	0x01;					//	Enable flash writes
	for(x = 0;	x<str2len;	x++)//	Write 512 bytes
	{
		FLKEY	=	0xA5;				//	Write flash key sequence
		FLKEY	=	0xF1;
		*pwrite	=	*pread;				//	Write data byte to flash

		pread++;						//	Increment pointers
		pwrite++;
	}
	PSCTL	=	0x00;					//	Disable flash writes
	EA	=	EA_Save;					//	Restore EA
}

void	Page_Erase(char*	Page_Address)	small
{
	char	EA_Save;					//	Used to save state of global interrupt enable
	char	xdata	*pwrite;			//	xdata pointer used to generate movx intruction
	
	pwrite	=	(char xdata *)(Page_Address);	//	Set write pointer to Page_Address
	EA_Save	=	EA;						//	Save current EA
//	EA	=	0;							//	Turn off interrupts
	
	PSCTL	=	0x03;					//	Enable flash erase and writes

	FLKEY	=	0xA5;					//	Write flash key sequence to FLKEY
	FLKEY	= 	0xF1;
	*pwrite	=	0x00;					//	Erase flash page using a write command

	PSCTL	=	0x00;					//	Disable flash erase and writes
//	EA	=	EA_Save;					//	Restore state of EA
	
}