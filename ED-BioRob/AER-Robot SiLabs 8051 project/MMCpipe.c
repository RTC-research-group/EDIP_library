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
#include <string.h>


long MMCbase=MMC_BASE; //Address for the first MMC sequential access.
extern xdata unsigned char sector[512];

char InitMMC(void){
  //raise SS and MOSI for 80 clock cycles
  //SendByte(0xff) 10 times with SS high
  //RAISE SS
  char i;
  char response=0x01;
  //initialization sequence on PowerUp
  RaiseSS();
  for( i=0;i<=9;i++)
    vSendByte(0xff);
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
    vSendByte(0xff);
    LowerSS();
    SendCmd(0x01,0x00ffc000,0xff);
    response=MMCgetResponse();
  } 
  if(response==0x00)
 //   printf("RESPONSE WAS GOOD\n"); 
  
  RaiseSS();
  vSendByte(0xff);
  
 // printf("MMC INITIALIZED AND SET TO SPI MODE PROPERLY.\n");
  return -1;  
}

char MMCgetResponse(){
  //Response comes 1-8bytes after command
  //the first bit will be a 0
  //followed by an error code
  //data will be 0xff until response
  char i=0;
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
  //idata char cmd[6];
  char temp;
  char i;
 while(!TXBMT);  //wait for xmit buffer empty
 
 SPI0DAT=command|0x40;
  
  
  for(i=24;i>=0;i-=8){
    temp=(argument>>(i));
	
	while(!TXBMT);  //wait for xmit buffer empty
 
	SPI0DAT=temp;
  }
	while(!SPIF); //wait for end of transmition
 	SPIF=0;  //clear SPIF
 while(!TXBMT);  //wait for xmit buffer empty
 
 SPI0DAT=CRC;
  while(!SPIF); //wait for end of transmition
 SPIF=0;  //clear SPIF
    
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
char MMCreadBlock(char *Block, long address){
unsigned  char dataResp,i,rc;
  int count;
  //Block size is 512 bytes exactly
  //First Lower SS
  LowerSS();
  //Then send read command
  SendCmd(17,address,0xff);
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
    for( count=0;count<512;count++) Block[count]=SendByte(0xff);
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
    return rc;
 }


char MMCreadBlockSeq(char *Block)
{
char rc;

rc=MMCreadBlock(Block,MMCbase);
MMCbase+=512;
return rc;
}
//READ a BLOCK starting at address


 void MMCchangeBase(long address)
 {
 MMCbase=address;
 }


long MMCgetFirst(char *filename, long *lenght)
{

unsigned long longitud;

unsigned long first_add=0;
unsigned char FATcopies;
unsigned int  sectors_per_FAT,res_sectors,Root_entries;
unsigned char sectors_per_cluster;
unsigned long first_root_offset;
unsigned int num_root_sectors=0;
unsigned int initial_cluster=0;
int j,k;


MMCchangeBase(0); //Change base to boot sector
MMCreadBlockSeq(sector);
if(sector[0]==0)
{
	first_add+=(long)sector[0x1c6];
	first_add+=(long)sector[0x1c7]<<8;
	first_add<<=9;
	
	MMCbase=first_add;
	MMCreadBlockSeq(sector);
		
}

sectors_per_cluster=sector[0x0D];

res_sectors=sector[0xe]; //Reserved sectors low
res_sectors+=(unsigned int)sector[0xf]<<8; //Reserved sectors
FATcopies=sector[0x10]; //FAT copies
Root_entries=sector[0x11]; 
Root_entries+=(unsigned int)sector[0x12]<<8; //Root entries

num_root_sectors = Root_entries >> 4; // Num of sector that use ROOT
sectors_per_FAT=sector[0x16]; 
sectors_per_FAT+=(unsigned int)sector[0x13]<<8; //Sectors per Fat offset 16/17H

first_add+=(unsigned long)(res_sectors)<<9;
first_add+=((unsigned long)(FATcopies)*sectors_per_FAT)<<9;

first_root_offset = first_add; //offset of the first root sector

first_add+=(unsigned long)(Root_entries)<<5;


for(k=0;k<num_root_sectors;k++)
{
	MMCbase=first_root_offset+(k<<9);
	MMCreadBlockSeq(sector);
	for(j=0;j<512;j+=32)
		{
		if(memcmp(filename,&sector[j],11)==0) // Si encontrado
			{
			initial_cluster=(unsigned int)sector[j+0x1a];
			initial_cluster+=(unsigned int)sector[j+0x1b]<<8;
			longitud=(unsigned long)sector[j+0x1c];
			longitud+=(unsigned long)sector[j+0x1d]<<8;
			longitud+=(unsigned long)sector[j+0x1e]<<16;
			longitud+=(unsigned long)sector[j+0x1f]<<24;
			first_add+=(unsigned long)(initial_cluster-2)*sectors_per_cluster<<9;
			first_add+=0;
			*lenght = longitud;
			return (first_add);
			}
		}
}



return((unsigned long)0);
}



