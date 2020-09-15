

#include "C8051F320.H"

#include "micro.h"


#include "cyg_aux.h"
#include <intrins.h>
#include "USB_REGISTER.h"
#include "USB_DESCRIPTOR.h"

#define  firmware_file "FIRMWAREBIN"
#define  memory_file   "RAM     BIN"

#define OUT_DATA_READ_BY_APPL EA=0;POLL_WRITE_BYTE(INDEX, 2);POLL_WRITE_BYTE(EOUTCSR1, 0);EA=1; 
#define IN_DATA_SEND_BY_APPL EA=0;POLL_WRITE_BYTE(INDEX, 1);POLL_WRITE_BYTE(EINCSR1, rbInINPRDY);EA=1;

#define SMAX 0x80


void upload_to_device(unsigned long);
void download_from_device(unsigned long);
void upload_descriptor_string();
void delayAER(void);

void sendSensorValue(unsigned char,unsigned int);
void sendConfigValue(unsigned char, unsigned int);
void sendValue(unsigned char dir, unsigned char msb, unsigned char lsb);
char SendByte(char byte);
void initialize_robot(void);
xdata unsigned char Out_Packet[64];   // Last packet received from host
xdata unsigned char In_Packet[64]  ;   // Next packet to sent to host



sfr16 	ADC0	= 0xBD;

sbit NSS=P0^3;
sbit STR=P0^4;
sbit RST_FPGA=P0^5;

sbit LED1 = P2^4;
sbit LED2 = P2^5;

unsigned int statusRegister;
unsigned int bdata sensorEnable;
unsigned int mask;
unsigned int FCmax[5], FCmin[5];


bit entradapc;
bit salidapc;
idata unsigned int inp,outp;

xdata unsigned char sector[512];

extern code const BYTE String2DescF[STR2LEN];

char num_sensor;


/*****************************************************************************
* Function:     main

*****************************************************************************/
void main()
{
    unsigned char iErrorCode=0;
	unsigned long longitud;
	unsigned char comando;
	
 	unsigned int i;

unsigned int value;
  
   // Disable Watchdog timer
PCA0MD &= ~0x40;                    // WDTE = 0 (clear watchdog timer
                                       // enable)
PORT_Init();                        // Initialize Port I/O
SYSCLK_Init ();                     // Initialize Oscillator
Usb0_Init(); 
ADC0_Init();
REF0CN    = 0x2B;	//REF

	NSS=1; 		//Deseleccionamos al esclavo SPI
	RST_FPGA=1;	//Reseteamos la FPGA
	RST_FPGA=0;
	RST_FPGA=1;
	for (i=0;i<5;i++) { FCmax[i]=0; FCmin[i]=65535;}
	sensorEnable=0xFFFF;	//Habilitamos por defecto la lectura de todos los sensores
	statusRegister=0xD7FF;
//	run , todo PT, uno PFM, otro PWM, todos enable. y 1 bit no usado, propagamos eventos o no, y enables encoders
//	sendConfigValue(0x00,statusRegister); //Inicializamos el estado

// Entramos en el bucle para esperar ordenes del USB
entradapc=1;
salidapc=0;
OUT_DATA_READ_BY_APPL     // Clear Out Packe

for (i=0;i<64;i++)
	In_Packet[i]=0xff;


	In_Packet[32]=(unsigned char) (statusRegister/255);	//MSB
	In_Packet[33]=(unsigned char) (0x00FF & statusRegister);//LSB
	
	
  i=0;
  inp=0;
  outp=0;

  initialize_robot();  

  while(1){
	while(!salidapc) { 

		LED1=1;			
		LED2=1;

	}
	LED1=0;
	LED2=1;
	salidapc=0;

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
		else if (comando == 4)
		    { 	RST_FPGA=1;	RST_FPGA=0;	RST_FPGA=1; }
 
		}
	else{salidapc =0;OUT_DATA_READ_BY_APPL}     // Clear Out Packe



	}   
}


void initialize_robot()
{
    char i;

	//Turn on LED 0
	NSS=0; 
	SendByte(0);
	SendByte(0);
	SendByte(1);
	NSS=1;

	//Base
	NSS=0; 
	SendByte(0xF0);
	SendByte(128);
	SendByte(0);
	NSS=1;

    //activate spike_width of PI controller
	NSS=0; 
	SendByte(0x12);
	SendByte(20);
	SendByte(0);
	NSS=1;

	NSS=0; 
	SendByte(0x42);
	SendByte(2);
	SendByte(0);
	NSS=1;

    for (i=0; i<=4; i++) {
	   NSS=0; 
	   SendByte(3+i);
	   SendByte(2);
	   SendByte(0);
	   NSS=1;
	   NSS=0; 
	   SendByte(0x30+i);
	   SendByte(2);
	   SendByte(0);
	   NSS=1;
	   NSS=0; 
	   SendByte(128+3+i);
	   SendByte(2);
	   SendByte(0);
	   NSS=1;
	   NSS=0; 
	   SendByte(128+0x30+i);
	   SendByte(2);
	   SendByte(0);
	   NSS=1;
	}  

	//Motor RX:
	//Move left until end sensed by ADC
	NSS=0; 
	SendByte(128+1);
	SendByte(170);
	SendByte(0);
	NSS=1;
	
	//Motor LX:
	//Move left until end sensed by ADC
	NSS=0; 
	SendByte(128+2);
	SendByte(0);
	SendByte(0);
	NSS=1;

	//Motor RY:
	//Move up until end sensed by ADC

	//Motor LY:
	//Move up until end sensed by ADC

	//Send reset for encoders start counting.

	//Motor RX:
	//Move right until end, sesed by ADC

	//Motor LX:
	//Move right until end, sesed by ADC

	//Motor RY:
	//Move down until end, sesed by ADC

	//Motor LY:
	//Move down until end, sesed by ADC

	//Send order to PI controller to save encoders values
	//This order will set up the zero position to the middle for each controller / motor

}

//ADC end of conversion interrupt: will change periodically the source to convert for all the end of movement
//signals. If one of them is reached, a command has to be send to the controller in order to fix the maximum or
//minimum spike frequency to actual one.

void ADC_ISR (void) interrupt 10
{
  unsigned int sensor=0;

  AD0INT = 0;
  sensor=((int)ADC0H*256+ADC0L);
  if (FCmax[num_sensor]<sensor) FCmax[num_sensor]=sensor;
  if (FCmin[num_sensor]>sensor) FCmin[num_sensor]=sensor;

  if (num_sensor<8) num_sensor++;
  else num_sensor=0;
  if (num_sensor >= 5 && num_sensor <=8 && sensor>SMAX) 
  {
  	NSS=0; 
	SendByte(0);
	SendByte(0);
	SendByte(4);
	NSS=1;
     // enviar comando SPI al controlador para no seguir
  } else {
  	NSS=0; 
	SendByte(0);
	SendByte(0);
	SendByte(0);
	NSS=1;
  }

  switch (num_sensor) {
     case 0: AMX0P=4;   AMX0N=5; break;
     case 1: AMX0P=6;   AMX0N=7; break;
     case 2: AMX0P=8;   AMX0N=9; break;
     case 3: AMX0P=0xA; AMX0N=0xB; break;
     case 4: AMX0P=0xC; AMX0N=0xD; break;
     case 5: AMX0P=0; AMX0N=0xff; break;  //Hall effect current sensor
     case 6: AMX0P=1; AMX0N=0xff; break;  //Hall effect current sensor 
     case 7: AMX0P=2; AMX0N=0xff; break;  //Hall effect current sensor
     case 8: AMX0P=3; AMX0N=0xff; break;  //Hall effect current sensor
  }
  AD0BUSY=1;
}

void upload_to_device(unsigned long longitud)
{
    unsigned long i;
	unsigned char b1, b2, b3;
	//NSS=0;
	for(i=0;i<longitud;i++){
	  	if ((i%64)==0){ // cada 64 bytes esperamos un nuevo paquete
			OUT_DATA_READ_BY_APPL     // Clear Out
			while(!salidapc);
			EA=0;salidapc =0;
		}
    }
		LED2=0;
		//Poner Rutina atencion paquetes
		NSS=0; //Transferimos los 3 bytes.
		//SendByte(0x00);
		b1=SendByte(Out_Packet[0]);
		b2=SendByte(Out_Packet[1]);
		b3=SendByte(Out_Packet[2]);
		NSS=1;
		EA=1;
		LED2=1;
		In_Packet[34] = b1; In_Packet[35]=b2;  //commands with address xF1-xF3 must be sent twice!!
		In_Packet[36] = b3; 	   
        OUT_DATA_READ_BY_APPL     // Clear Out Packet
}



void download_from_device(unsigned long longitud)
{
	//Actualizamos el valor del registro de estado
	In_Packet[32]=(unsigned char) (statusRegister/255);	//MSB
	In_Packet[33]=(unsigned char) (0x00FF & statusRegister);//LSB
	entradapc=1;
	OUT_DATA_READ_BY_APPL     // Clear Out Packe
	while(!entradapc);
	 entradapc =0;
	//EA=0;
	Fifo_Write1(FIFO_EP1, EP1_PACKET_SIZE, (BYTE *)In_Packet);
	//No limpiamos el paquete de salida
//       for(i=0;i<64;i++) In_Packet[i]=0x0;
			
	IN_DATA_SEND_BY_APPL
		 
}

void upload_descriptor_string(){

	OUT_DATA_READ_BY_APPL
	Page_Erase((char *)String2DescF);
	CopyDescStr((char *)&Out_Packet[8]);
}

//----------------------------------
//  FIFO Write
//----------------------------------
//
// Write to the selected endpoint FIFO
//
// Inputs:
// addr: target address
// uNumBytes: number of bytes to write
// pData: location of source data
//
void Fifo_Write1(BYTE addr, unsigned int uNumBytes, BYTE * pData)
{
   int i;
                                          
   // If >0 bytes requested,
   if (uNumBytes) 
   {
      while(USB0ADR & 0x80);              // Wait for BUSY->'0'
                                          // (register available)
      USB0ADR = (addr);                   // Set address (mask out bits7-6)

      // Write <NumBytes> to the selected FIFO
      for(i=0;i<uNumBytes;i++)
      {  
         USB0DAT = pData[i];
         while(USB0ADR & 0x80);           // Wait for BUSY->'0' (data ready)
      }
   }
}

void sendValue(unsigned char dir, unsigned char msb, unsigned char lsb){
	NSS=0; //Transferimos los 3 bytes.
	SendByte(dir);
	SendByte(msb);
	SendByte(lsb);
	NSS=1;	
}

void sendConfigValue(unsigned char dir, unsigned int value){
	unsigned char frame [3];
	frame[0]=(0x3F & dir)|0x40;
	frame[1]= (unsigned char) (value/256); //(cogemos el MSB)
	frame[2]= (unsigned char) (0x00FF & value);// (Tomamos el LSB)
	NSS=0; //Transferimos los 3 bytes.
	SendByte(frame[0]);
	SendByte(frame[1]);
	SendByte(frame[2]);
	NSS=1;	
}

void sendSensorValue(unsigned char sensor,unsigned int value){
	unsigned char frame [3];
	frame[0]=0x1F & sensor;
	frame[1]= (unsigned char) (value/256); //(cogemos el MSB)
	frame[2]= (unsigned char) (0x00FF & value);// (Tomamos el LSB)
	NSS=0; //Transferimos los 3 bytes.
	SendByte(frame[0]);
	SendByte(frame[1]);
	SendByte(frame[2]);
	NSS=1;
}

char SendByte(char byte){

  while(!TXBMT);  //wait for xmit buffer empty
  SPI0DAT=byte;

  while(!SPIF); //wait for end of transmition
  SPIF=0;  //clear SPIF
  
  return SPI0DAT;
}