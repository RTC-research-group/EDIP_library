// V 2.1
// (C) Rafa Paz, Anton Civit, Gabriel Jimenez
//  (C) Dep. ATC
//  (C) Universidad de Sevilla


#include <c8051F320.h>
#include "SPImaster.h"
#include <stdio.h>
#include <intrins.h>


char MMCpresent(void)
{
return (char) MMC_P;
} 
  
void RaiseSS(){
  SPI0CFG|=0x08;
}

void LowerSS(){
  SPI0CFG&=0xF7;
}


void Init_MMC_Ports()
{
SPI0CFG=0x70; //Master. CKPHA=1 CKPOL=1
SPI0CKR=0; // SPI CLK= SYSCLK/2. Do not decrease.
SPI0CN=0xD; //1101b 4 Wire Master. MMC_SS=1.Enable SPI
}

//SendByte - in SPI MASTER fashion
//will READ a byte everytime it writes a byte
char SendByte(char byte){

  while(!TXBMT);  //wait for xmit buffer empty
  SPI0DAT=byte;
  while(!SPIF); //wait for end of transmition
  SPIF=0;  //clear SPIF
  
  return SPI0DAT;
}

void vSendByte(char byte){

  while(!TXBMT);  //wait for xmit buffer empty
 
 SPI0DAT=byte;
  while(!SPIF); //wait for end of transmition
 SPIF=0;  //clear SPIF
  
//  return SPI0DAT;
}
