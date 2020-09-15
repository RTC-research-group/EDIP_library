

#include <C8051F320.H>

#include "micro.h"


#include "cyg_aux.h"
#include "spimaster.h"
#include "mmc.h"
#include <intrins.h>
#include "USB_REGISTER.h"
#include "USB_DESCRIPTOR.h"

#define  firmware_file "FIRMWAREBIN"
#define  memory_file   "RAM     BIN"

#define OUT_DATA_READ_BY_APPL EA=0;salidapc--;POLL_WRITE_BYTE(INDEX, 2);POLL_WRITE_BYTE(EOUTCSR1, 0);EA=1; 
#define IN_DATA_SEND_BY_APPL EA=0;POLL_WRITE_BYTE(INDEX, 1);POLL_WRITE_BYTE(EINCSR1, rbInINPRDY);EA=1;


sbit AER_REQ=P0^1;
sbit AER_ACK=P0^0;
sbit LED1 = P0^3;
sbit LED2 = P0^4;
sbit LED3 = P0^5;

sfr AER_DATA_L=0x90; //P1
sfr AER_DATA_H=0xA0; //P2


void upload_to_device(unsigned long);
void download_from_device(unsigned long);
void delayAER(void);

xdata unsigned char Out_Packet[64];   // Last packet received from host
xdata unsigned char In_Packet[512]  ;   // Next packet to sent to host
//xdata unsigned char sector[512];

//idata unsigned char  entradapc;//available in buffer slots
idata unsigned char salidapc; //number of filled buffers
idata unsigned int inp,outp;

bdata char bincode;
sbit bc0=bincode^0;
sbit bc1=bincode^1;
sbit bc2=bincode^2;
sbit bc3=bincode^3;
sbit bc4=bincode^4;
sbit bc5=bincode^5;
sbit bc6=bincode^6;
sbit bc7=bincode^7;

extern code const BYTE String2DescF[STR2LEN];

/*****************************************************************************
* Function:     main

*****************************************************************************/
void main()
{
    unsigned char     iErrorCode=0;
	unsigned char ramnum;
	unsigned long ramaddr;
//	pdata char *ramp;
//	idata char rmapdata;
	unsigned long saddr;

	unsigned long inicio;
	unsigned long longitud;
	unsigned char comando;
	
 	unsigned int i;


  
   // Disable Watchdog timer
PCA0MD &= ~0x40;                    // WDTE = 0 (clear watchdog timer
                                       // enable)
PORT_Init();                        // Initialize Port I/O
SYSCLK_Init ();                     // Initialize Oscillator
Usb0_Init(); 
 
Timer2_Init(SYSCLK/TIMER2_RATE);    // Init Timer 2

AER_ACK=1;
AER_REQ=1;

  //DOUT output
// Entramos en el bucle para esperar ordenes del USB
//entradapc=1;
//salidapc=0;
//Fifo_Read(FIFO_EP2, EP2_PACKET_SIZE, (BYTE*)Out_Packet);
//OUT_DATA_READ_BY_APPL     // Clear Out Packe

for (i=0;i<64;i++) In_Packet[i]='h';

  LED1=0;
  LED3=0;
  i=0;
  inp=0;
  outp=0;
  while(1)
  	{
    P1MDOUT=0x00; //P1 input
    P2MDOUT=0x00; //P2 input
    P0MDOUT=0xDC;
		while(!salidapc) { 
	    if (AER_REQ == 0) {
		   LED3 =1;
		   In_Packet[inp] = AER_DATA_L;
		   In_Packet[inp+1]=AER_DATA_H;
		   AER_ACK=0;
		   while(!AER_REQ);
		   AER_ACK=1;
		   if (i== 64) {
		      LED3=!LED3;
		   }	
		   if (inp<512) inp+=2;
		   else inp=0;
        } else LED3=0;
	}
	//salidapc=0;
		Fifo_Read1(FIFO_EP2, EP2_PACKET_SIZE, (BYTE*)Out_Packet);
		OUT_DATA_READ_BY_APPL 
	if(Out_Packet[0]=='A' & Out_Packet[1]=='T' & Out_Packet[2]=='C')
		{
	  	comando =Out_Packet[3];
		longitud = (unsigned long)Out_Packet[4];
		longitud+=(unsigned long)Out_Packet[5]<<8;
		longitud+=(unsigned long)Out_Packet[6]<<16;
		longitud+=(unsigned long)Out_Packet[7]<<24;

		if (comando == 1)
			upload_to_device(longitud);
		else if (comando == 2) 
			download_from_device(longitud);
		else if (comando == 3)
			upload_descriptor_string();
		}
	else
		{
		longitud=0;    // This is only for Debug porposes

		}
	}   
}

/*void shiftout(char byte)
{
  
  char input=0;
  char i;
  bit a;
   
  //get first bit to send
  for(i=0;i<8;i++){
   
    //lower CLOCK
    CCLK=0;
	 
    //put DATA on MOSI line
    

	byte=_crol_(byte,1);
	  a=byte&1;
	  
	  DOUT=a;

    //raise CLOCK
    CCLK=1;
    
        
  }
  
}*/


void upload_to_device(unsigned long longitud)
{

unsigned long kk,i,l,ibuf;
//char contador =0;
//idata BYTE ibuf;


LED1 = 1;

P1MDOUT=0x00; //P1 output
P2MDOUT=0x00; //P2 output
P0MDOUT=0xDC;
AER_REQ = 1;


// Mandamos 16 bits de control
for(i=0;i<16;i++)
{
	DELAY_U;
}

l=longitud/64;//Numero bloques

for(i=0; i<=l;i++)
  {
  	 // cada 64 bytes esperamos un nuevo paquete
		//Fifo_Read1(FIFO_EP2, EP2_PACKET_SIZE, (BYTE*)Out_Packet);
	//	OUT_DATA_READ_BY_APPL 
		OUT_DATA_READ_BY_APPL     // Clear Out
		 kk=0;
		 while(salidapc==0) {
		   kk++;
		   if (kk==0xffff) break;
		 }
		
		 if (kk<0xffff) {
	

		 USB0ADR = FIFO_EP2|0xC0;                   // Set address
                         				// Set auto-read and initiate 
                                          // first read      

      		// Unload <NumBytes> from the selected FIFO
      		for(ibuf=0;(ibuf<62) && (ibuf<longitud-2);ibuf+=2)
     		 {         
        		 while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
        		 AER_DATA_L = USB0DAT;              // Copy data byte
        		 while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
        		 AER_DATA_H = USB0DAT;              // Copy data byte
				 delayAER();
			     AER_REQ=0;           //Send REQ low
				 delayAER();
				 while(AER_ACK);      //Wait until ACK low
				 AER_REQ=1;           //Deactivate REQ
				 delayAER();
				 while(!AER_ACK);     //Wait until ACK high
   			}


        		 while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
        		 AER_DATA_L = USB0DAT;              // Copy data byte
     	   	     USB0ADR = 0;                           // Clear auto-read
        		 while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
        		 AER_DATA_H = USB0DAT;              // Copy data byte
				 delayAER();
			     AER_REQ=0;           //Send REQ low
				 delayAER();
				 while(AER_ACK);      //Wait until ACK low
				 AER_REQ=1;           //Deactivate REQ
				 delayAER();
				 while(!AER_ACK);     //Wait until ACK high
		 
		 OUT_DATA_READ_BY_APPL
		 }
	}	 
  
   LED1 = 0; /*
   for(i=0; i<longitud;i+=2)
   {
  	 if ((i%64)==0) // cada 64 bytes esperamos un nuevo paquete
		{OUT_DATA_READ_BY_APPL     // Clear Out
		 while(!salidapc);
		 EA=0;salidapc =0;
		}
   		 AER_DATA_L = Out_Packet[i%64];              // Copy data byte
   		 AER_DATA_H = Out_Packet[i%64+1];              // Copy data byte
	     AER_REQ=0;           //Send REQ low
		 while(AER_ACK);      //Wait until ACK low
		 AER_REQ=1;           //Deactivate REQ
		 while(!AER_ACK);     //Wait until ACK high

		 EA=1;
   } 
    OUT_DATA_READ_BY_APPL     // Clear Out Packe
   LED1 = 0;*/
}

upload_descriptor_string()
{
OUT_DATA_READ_BY_APPL
Page_Erase((char *)String2DescF);
CopyDescStr((char *)&Out_Packet[8]);
}


void download_from_device(unsigned long longitud)
{
unsigned int l, i;
unsigned int resto, falta;
idata BYTE ibuf;
idata BYTE ControlReg;
LED3=1;

// Mandamos 16 bytes de control
for(i=0;i<16;i++)
{
	DELAY_U;
}
//OUT_DATA_READ_BY_APPL     // Clear Out Packe
P1MDOUT=0x00; //P1 input
P2MDOUT=0x00;
//P0MDOUT=0xDF;

l=(unsigned int) longitud/64;//Numero bloques
resto=longitud - (l*64);
if (resto >0) l++;

for(i=0; i<l ;i++)
  {
		EA=0;
		//POLL_WRITE_BYTE(IN1IE,  0x0);//Disable EP0 Int
  		do
		{
		POLL_WRITE_BYTE(INDEX, 1);           // Set index to endpoint 1 registers
   		POLL_READ_BYTE(EINCSR1, ControlReg); // Read contol register for EP 1
		EA=1; //ERRor
		}
		   while(ControlReg & rbInINPRDY);
		   while(USB0ADR & 0x80);              // Wait for BUSY->'0'
                                         // (register available)
      	   USB0ADR = (FIFO_EP1);                   // Set address (mask out bits7-6)

      		// Write <NumBytes> to the selected FIFO
		   if (i<l) {
      		for(ibuf=0;(ibuf<64) && (outp !=inp);ibuf++)
      			{DELAY_U;  
        		 USB0DAT = In_Packet[outp];
				 if (outp<512) outp++;
				 outp=0;
        		 while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
      			}
           }
            if (outp==inp) {
			    while (ibuf++<64) {
				 DELAY_U;
				 USB0DAT = 0xAA;
				 while(USB0ADR & 0x80);
                }
            }
		IN_DATA_SEND_BY_APPL
		POLL_WRITE_BYTE(IN1IE,  0x01); //Enable EP0 int 		 
   }  
   LED3=0;
}





//----------------------------------
//  FIFO Read
//----------------------------------
//
// Read from the selected endpoint FIFO
//
// Inputs:
// addr: target address
// uNumBytes: number of bytes to unload
// pData: read data destination
//
void Fifo_Read1(BYTE addr, unsigned int uNumBytes, BYTE * pData)
{
   BYTE i;

   if (uNumBytes)                         // Check if >0 bytes requested,
   {      
      USB0ADR = (addr);                   // Set address
      USB0ADR |= 0xC0;                    // Set auto-read and initiate 
                                          // first read      

      // Unload <NumBytes> from the selected FIFO
      for(i=0;i<uNumBytes-1;i++)
      {         
         while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
         pData[i] = USB0DAT;              // Copy data byte
      }

      USB0ADR = 0;                           // Clear auto-read

	  while(USB0ADR & 0x80);               // Wait for BUSY->'0' (data ready)
      pData[i] = USB0DAT;                  // Copy data byte
   }
}

void delayAER (void) {

   char i;
   for (i=0; i<3; i++);
}