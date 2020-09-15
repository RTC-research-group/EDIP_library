/*
   File:    usb_top_isr.c
   Author:  DM
   Created: 11/8/02

   Target Device: C8051F320

   Source file for USB firmware. Includes top level isr with Setup,
   and Endpoint data handlers.  Also includes routine for USB suspend,
   reset, and procedural stall.
*/

#include "c8051F320.h"
#include "USB_REGISTER.h"
#include "micro.h"
#include "USB_DESCRIPTOR.h"

extern xdata unsigned char OUT_PACKET[];
extern xdata unsigned char IN_PACKET[];
extern bit entradapc;
extern bit salidapc;
//extern bit primero;

BYTE USB_State;                         // Holds the current USB State def. in USB_MAIN.h

setup_buffer Setup;                     // Buffer for current device request information

unsigned int DataSize;                  // Size of data to return
unsigned int DataSent;                  // Amount of data sent so far
BYTE* DataPtr;                          // Pointer to data to return

BYTE Ep_Status[3] = {EP_IDLE, EP_IDLE, EP_IDLE};             
                                        // Holds the status for each endpoint

//-------------------------
// Usb_ISR
//-------------------------
// Called after any USB type interrupt, this handler determines which type
// of interrupt occurred, and calls the specific routine to handle it.
//
void Usb_ISR(void) interrupt 8          // Top-level USB ISR
{
   BYTE bCommon, bIn, bOut;
   POLL_READ_BYTE(CMINT, bCommon);      // Read all interrupt registers
   POLL_READ_BYTE(IN1INT, bIn);         // this read also clears the register
   POLL_READ_BYTE(OUT1INT, bOut);
   {
      if (bCommon & rbRSUINT)           // Handle Resume interrupt
      {
         Usb_Resume();
      }
      if (bCommon & rbRSTINT)           // Handle Reset interrupt
      {
         Usb_Reset();
      }
      if (bIn & rbEP0)                  // Handle Setup packet received
      {                                 // or packet transmitted if Endpoint 0 is
         Handle_Setup();                // transmit mode
      }
      if (bIn & rbIN1)                  // Handle In Packet sent, put new data on
      {                                 // endpoint 1 fifo
         Handle_In1();
      }
      if (bOut & rbOUT2)                // Handle Out packet received, take data off
      {                                 // endpoint 2 fifo
         Handle_Out2();
      }   
	  if (bCommon & rbSUSINT)           // Handle Suspend interrupt
      {
         Usb_Suspend();
      }
   }
} 

//-------------------------
// Usb_Resume
//-------------------------
// Resume normal USB operation
//
void Usb_Resume(void)                   // Add code to turn on anything turned off when
{                                       // entering suspend mode
   volatile int k;
   k++;
}

//-------------------------
// Usb_Reset
//-------------------------
// - Set state to default
// - Clear Usb Inhibit bit
//
void Usb_Reset(void)
{
   USB_State = DEV_DEFAULT;             // Set device state to default

   POLL_WRITE_BYTE(POWER, 0x01);        // Clear usb inhibit bit to enable USB
                                        // suspend detection

   Ep_Status[0] = EP_IDLE;              // Set default Endpoint Status
   Ep_Status[1] = EP_HALT;
   Ep_Status[2] = EP_HALT;
}

//-------------------------
// Handle_Setup
//-------------------------
// - Decode Incoming Setup requests
// - Load data packets on fifo while in transmit mode
//
void Handle_Setup(void)                     
{                                   
   BYTE ControlReg,TempReg;             // Temporary storage for EP control register

   POLL_WRITE_BYTE(INDEX, 0);           // Set Index to Endpoint Zero
   POLL_READ_BYTE(E0CSR, ControlReg);   // Read control register

   if (Ep_Status[0] == EP_ADDRESS)      // Handle Status Phase of Set Address command
   {
      POLL_WRITE_BYTE(FADDR, Setup.wValue.c[LSB]);
      Ep_Status[0] = EP_IDLE;
   }

   if (ControlReg & rbSTSTL)            // If last packet was a sent stall, reset STSTL
   {                                    // bit and return EP0 to idle state
      POLL_WRITE_BYTE(E0CSR, 0);
      Ep_Status[0] = EP_IDLE;
      return;
   }

   if (ControlReg & rbSUEND)            // If last setup transaction was ended prematurely
   {                                    // then set
      POLL_WRITE_BYTE(E0CSR, rbDATAEND);
      POLL_WRITE_BYTE(E0CSR, rbSSUEND); // Serviced Setup End bit and return EP0
      Ep_Status[0] = EP_IDLE;           // to idle state
   }

   if (Ep_Status[0] == EP_IDLE)         // If Endpoint 0 is in idle mode
   {
      if (ControlReg & rbOPRDY)         // Make sure that EP 0 has an Out Packet ready from host
      {                                 // although if EP0 is idle, this should always be the case
         Fifo_Read(FIFO_EP0, 8, (BYTE *)&Setup);
                                        // Get Setup Packet off of Fifo, it is currently Big-Endian

                                        // Compiler Specific - these next three statements swap the
										// bytes of the setup packet words to Big Endian so they
										// can be compared to other 16-bit values elsewhere properly
         Setup.wValue.i = Setup.wValue.c[MSB] + 256*Setup.wValue.c[LSB];
         Setup.wIndex.i = Setup.wIndex.c[MSB] + 256*Setup.wIndex.c[LSB];
         Setup.wLength.i = Setup.wLength.c[MSB] + 256*Setup.wLength.c[LSB];
                                        

         switch(Setup.bRequest)         // Call correct subroutine to handle each kind of 
         {                              // standard request
            case GET_STATUS:
               Get_Status();
               break;             
            case CLEAR_FEATURE:
               Clear_Feature();
               break;
            case SET_FEATURE:
               Set_Feature();
               break;
            case SET_ADDRESS:
               Set_Address();
               break;
            case GET_DESCRIPTOR:
               Get_Descriptor();
               break;
            case GET_CONFIGURATION:
               Get_Configuration();
               break;
            case SET_CONFIGURATION:
               Set_Configuration();
               break;
            case GET_INTERFACE:
               Get_Interface();
               break;
            case SET_INTERFACE:
               Set_Interface();
               break;
            default:
               Force_Stall();           // Send stall to host if invalid request
               break;
         }
      }
   } 

   if (Ep_Status[0] == EP_TX)           // See if the endpoint has data to transmit to host
   {
      if (!(ControlReg & rbINPRDY))     // Make sure you don't overwrite last packet
      {
                                        // Endpoint 0 transmit mode
         //Delay();
         POLL_READ_BYTE(E0CSR, ControlReg);
                                        // Read control register
		 
         if ((!(ControlReg & rbSUEND)) || (!(ControlReg & rbOPRDY)))
                                        // Check to see if Setup End or Out Packet received, if so			                      
                                        // do not put any new data on FIFO
         {     
            TempReg = rbINPRDY;         // Add In Packet ready flag to E0CSR bitmask              
			 
			                            // Break Data into multiple packets if larger than Max Packet
            if (DataSize >= EP0_PACKET_SIZE)
            {
               Fifo_Write(FIFO_EP0, EP0_PACKET_SIZE, (BYTE *)DataPtr);// Put Data on Fifo
               DataPtr  += EP0_PACKET_SIZE;                           // Advance data pointer
               DataSize -= EP0_PACKET_SIZE;                           // Decrement data size
               DataSent += EP0_PACKET_SIZE;                           // Increment data sent counter
            }
			else                        // If data is less than Max Packet size or zero
            {
               Fifo_Write(FIFO_EP0, DataSize, (BYTE *)DataPtr);       // Put Data on Fifo
               TempReg |= rbDATAEND;                                  // Add Data End bit to bitmask
               Ep_Status[0] = EP_IDLE;                                // Return EP 0 to idle state
            }
            if (DataSent == Setup.wLength.i)
			                            // This case exists when the host requests an even multiple of
                                        // your endpoint zero max packet size, and you need to exit
                                        // transmit mode without sending a zero length packet
            {
               TempReg |= rbDATAEND;    // Add Data End bit to mask
               Ep_Status[0] = EP_IDLE;  // and return Endpoint 0 to an idle state
            }
            POLL_WRITE_BYTE(E0CSR, TempReg);                          // Write mask to E0CSR
         }
      }
   }
}

//-------------------------
// Handle_In1
//-------------------------
// - This routine loads the current value from In_Packet on the Endpoint 1 fifo, after 
// an interrupt is received from the last packet being transmitted
void Handle_In1()
{
   BYTE ControlReg;

   POLL_WRITE_BYTE(INDEX, 1);           // Set index to endpoint 1 registers
   POLL_READ_BYTE(EINCSR1, ControlReg); // Read contol register for EP 1

   if (Ep_Status[1] == EP_HALT)         // If endpoint is currently halted, send a stall
   {
      POLL_WRITE_BYTE(EINCSR1, rbInSDSTL);
   }

   else                                 // Otherwise send last updated data to host
   {
      if (ControlReg & rbInSTSTL)       // Clear sent stall if last packet returned a stall
      {
         POLL_WRITE_BYTE(EINCSR1, rbInCLRDT);
		 
      }

      if (ControlReg & rbInUNDRUN)      // Clear underrun bit if it was set
      {
         POLL_WRITE_BYTE(EINCSR1, 0x00);
		 
      }
/*	if(primero==0)
	{
	primero=1;
    POLL_WRITE_BYTE(EINCSR1, rbInINPRDY);
	}
	else
    { 
  */                                      // Put new data on Fifo
  //    Fifo_Write(FIFO_EP1, EP1_PACKET_SIZE, (BYTE *)IN_PACKET);
 //        POLL_WRITE_BYTE(EINCSR1, rbInINPRDY); 
       entradapc=1;                                 // Set In Packet ready bit, indicating fresh data
	// } 
   }                                    // on Fifo 1
}

//-------------------------
// Handle_Out2
//-------------------------
// Take the received packet from the host off the fifo and put it into the Out_Packet array
//
void Handle_Out2()
{
   BYTE Count = 0;
   BYTE ControlReg;

   POLL_WRITE_BYTE(INDEX, 2);           // Set index to endpoint 2 registers
   POLL_READ_BYTE(EOUTCSR1, ControlReg);

   if (Ep_Status[2] == EP_HALT)         // If endpoint is halted, send a stall
   {
      POLL_WRITE_BYTE(EOUTCSR1, rbOutSDSTL);
   }

   else                                 // Otherwise read received packet from host
   {
      if (ControlReg & rbOutSTSTL)      // Clear sent stall bit if last packet was a stall
      {
         POLL_WRITE_BYTE(EOUTCSR1, rbOutCLRDT);
      }
	  
      POLL_READ_BYTE(EOUTCNTL, Count);
      if (Count != EP2_PACKET_SIZE)     // If host did not send correct packet size, flush buffer
      {
         POLL_WRITE_BYTE(EOUTCNTL, rbOutFLUSH); 
      }
      else                              // Otherwise get the data packet
      {
         Fifo_Read(FIFO_EP2, EP2_PACKET_SIZE, (BYTE*)OUT_PACKET);
		salidapc=1;
      }
      //POLL_WRITE_BYTE(EOUTCSR1, 0);     // Clear Out Packet ready bit
   }
}

//-------------------------
// Usb_Suspend
//-------------------------
// Enter suspend mode after suspend signalling is present on the bus
//
void Usb_Suspend(void)
{                                         // Add power-down features here if you wish to 
   volatile int k;                        // reduce power consumption during suspend mode
   k++;
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
void Fifo_Read(BYTE addr, unsigned int uNumBytes, BYTE * pData)
{
   int i;

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
void Fifo_Write(BYTE addr, unsigned int uNumBytes, BYTE * pData)
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

//-------------------------
// Force_Stall
//-------------------------
// Force a procedural stall to be sent to the host
//
void Force_Stall(void)
{
   POLL_WRITE_BYTE(INDEX, 0);
   POLL_WRITE_BYTE(E0CSR, rbSDSTL);       // Set the send stall bit
   Ep_Status[0] = EP_STALL;               // Put the endpoint in stall status
}

