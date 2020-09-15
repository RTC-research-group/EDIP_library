/*   MMC.c -
/*   Daniel Riiff
/*   
/*   Contains the implementation of commands needed
/*   to interface with the SPI interface of MMC card */


#include <c8051f320.h>
//#include <stdio.h>
#include <intrins.h>
#include "SPImaster.h"
#include "MMC.h"
#include "micro.h"


long MMCbase=MMC_BASE; //Address for the first MMC sequential access.


char InitMMC(void){
  //raise SS and MOSI for 80 clock cycles
  //SendByte(0xff) 10 times with SS high
  //RAISE SS
  int delay=0, trials=0,i;
  char response=0x01;
  //initialization sequence on PowerUp
  RaiseSS();
  for( i=0;i<=9;i++)
    SendByte(0xff);
  LowerSS();  
  //Send Command 0 to put MMC in SPI mode
  SendCmd(0x00,0,0x95);
  //Now wait for READY RESPONSE
  //response=MMCgetResponse();
  response=MMCgetResponse();
  if(response!=0x01)
    return 0;
  
  while(response==0x01){
 //   printf("\n Sending Command 1\n");
    RaiseSS();
    SendByte(0xff);
    LowerSS();
    SendCmd(0x01,0x00ffc000,0xff);
    response=MMCgetResponse();
  } 
  if(response==0x00)
 //   printf("RESPONSE WAS GOOD\n"); 
  
  RaiseSS();
  SendByte(0xff);
  
 // printf("MMC INITIALIZED AND SET TO SPI MODE PROPERLY.\n");
  return -1;  
}

char MMCgetResponse(){
  //Response comes 1-8bytes after command
  //the first bit will be a 0
  //followed by an error code
  //data will be 0xff until response
  int i=0;
  char response;
  
  while(i<=32){//originalmente i<=8
    response=SendByte(0xff);
    if(response==0x00)
      break;
    if(response==0x01)
      break;
    i++;
  }
  return response;
}

void SendCmd(char command, long argument, char CRC){
  idata char cmd[6];
  char temp;
  int i;
  cmd[0]=(command|0x40);
  for(i=3;i>=0;i--){
    temp=(char)(argument>>(8*i));
    cmd[4-i]=(temp);
  }
  cmd[5]=(CRC);
  for(i=0;i<6;i++)
    SendByte(cmd[i]);
}

//WRITE a BLOCK starting at address
/*char MMCwriteBlock(char *Block, long address){
  char busy,dataResp;
  int count;
  //Block size is 512 bytes exactly
  //First Lower SS
  LowerSS();
  //Then send write command
  SendCmd(24,address,0xff);
  if(MMCgetResponse()==00){
    //command was a success - now send data
    //start with DATA TOKEN = 0xFE
    SendByte(0xfe);
    //now send data
    for( count=0;count<512;count++){
      SendByte(Block[count]);
    }
    //data block sent - now send checksum
    SendByte(0xff);
    SendByte(0xff);
    //Now read in the DATA RESPONSE token
    dataResp=SendByte(0xff);
    //Following the DATA RESPONSE token
    //are a number of BUSY bytes
    //a zero byte indicates the MMC is busy
    busy=SendByte(0xff);
    while(busy==0){
      busy=SendByte(0xff);
    }
    dataResp=dataResp&0x0f;	//mask the high byte of the DATA RESPONSE token
    RaiseSS();
    SendByte(0xff);
    if(dataResp==0x0b){
      printf("DATA WAS NOT ACCEPTED BY CARD -- CRC ERROR\n");
      return 0;
      }
    if(dataResp==0x05)
      return -1;
      
    printf("Invalid data Response token.");
    return 0;
 }
  printf("Command 24 (Write) was not received by the MMC.\n");
  return 0;
}
*/

//READ a BLOCK starting at address

char MMCreadBlocktoFPGA(){
unsigned  char dataResp,rc;
  int count;
  idata char fdata;
  idata unsigned char i;
  //Block size is 512 bytes exactly
  //First Lower SS
  LowerSS();
  //Then send read command
  SendCmd(17,MMCbase,0xff);
  rc=0;
  if(MMCgetResponse()==00){
    	//command was a success - now send data
    	//read start with DATA TOKEN = 0xFE
		for(i=0;i<256;i++)
			{
   		 	dataResp=SendByte(0xff);
			if(dataResp==0xFE) {rc=1;break;}
			}
	}
    //now send data
  if(rc)
  	{
    for( count=0;count<512;count++) 
		{
 		while(!TXBMT);  //wait for xmit buffer empty
 		 SPI0DAT=0xFF;
 		 while(!SPIF); //wait for end of transmition
 		 SPIF=0;  //clear SPIF
		fdata=SPI0DAT;
  		 for(i=0;i<8;i++){
   			    CCLK=0;
	 			if(fdata>=0)DOUT=0;else DOUT=1;
	  			fdata=fdata<<1;
	  			CCLK=1;
    			  }
		}
    }
    //data block sent - now send checksum
    SendByte(0xff);
    SendByte(0xff);
    //DELAY_U;
	dataResp=SendByte(0xff);
	for(count=0;count<1024;count++)
		{dataResp=SendByte(0xff);if(dataResp)break;}
	//Now read in the DATA RESPONSE token
      RaiseSS();
	MMCbase+=512;
    return rc;
 }


 void MMCchangeBase(long address)
 {
 MMCbase=address;
 }

/*  
char MMCreadBlockSeq(char *Block)
{
char rc;

rc=MMCreadBlock(Block,MMCbase);
MMCbase+=512;
return rc;
}
*/

void readByte(char *value)
{
unsigned  char dataResp,i;
static int rc,count=0;
  //Block size is 512 bytes exactly
  //First Lower SS
if(count++==0)
{
  LowerSS();
  //Then send read command
  SendCmd(17,MMCbase,0xff);
  rc=0;
  if(MMCgetResponse()==00){
    	//command was a success - now send data
    	//read start with DATA TOKEN = 0xFE
		for(i=0;i<256;i++)
			{
   		 	dataResp=SendByte(0xff);
			if(dataResp==0xFE) {rc=1;break;}
			}
	}
}
    //now send data
  if(rc)
  	{
    *value=SendByte(0xff);
    }
if(count==512)
{
    //data block sent - now send checksum
    SendByte(0xff);
    SendByte(0xff);
    //DELAY_U;
	dataResp=SendByte(0xff);
	for(count=0;count<1024;count++)
		{dataResp=SendByte(0xff);if(dataResp)break;}
	//Now read in the DATA RESPONSE token
      RaiseSS();
	  MMCbase+=512;count=0;
}
    
 }