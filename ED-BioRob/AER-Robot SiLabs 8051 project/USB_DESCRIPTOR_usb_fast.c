// V 2.1
// (C) Rafa Paz, Anton Civit, Gabriel Jimenez
//  (C) Dep. ATC
//  (C) Universidad de Sevilla

/*  Based on

   File:    USB_DESCRIPTOR.c
   Author:  DM
   Created: 11/22/02

   Target Device: C8051F320

   Source file for USB firmware. Includes descriptor data.

   Functions:
   None

*/
#include <C8051F320.H>
#include "USB_REGISTER.h"
#include "micro.h"
#include "USB_DESCRIPTOR.h"

//---------------------------
// Descriptor Declarations
//---------------------------
const device_descriptor DeviceDesc = 
{
   18,                  // bLength
   0x01,                // bDescriptorType
   0x1001,              // bcdUSB
   0x00,                // bDeviceClass
   0x00,                // bDeviceSubClass
   0x00,                // bDeviceProtocol
   EP0_PACKET_SIZE,     // bMaxPacketSize0
   0xC410,              // idVendor
   0x0000,              // idProduct 
   0x0000,              // bcdDevice 
   0x01,                // iManufacturer
   0x02,                // iProduct     
   0x00,                // iSerialNumber
   0x01                 // bNumConfigurations
}; //end of DeviceDesc

const configuration_descriptor ConfigDesc = 
{
   0x09,                // Length
   0x02,                // Type
   0x2000,              // Totallength
   0x01,                // NumInterfaces
   0x01,                // bConfigurationValue
   0x00,                // iConfiguration
   0x80,                // bmAttributes
   0x0F                 // MaxPower
}; //end of ConfigDesc

const interface_descriptor InterfaceDesc =
{
   0x09,                // bLength
   0x04,                // bDescriptorType
   0x00,                // bInterfaceNumber
   0x00,                // bAlternateSetting
   0x02,                // bNumEndpoints
   0x00,                // bInterfaceClass
   0x00,                // bInterfaceSubClass
   0x00,                // bInterfaceProcotol
   0x00                 // iInterface
}; //end of InterfaceDesc

const endpoint_descriptor Endpoint1Desc =
{
   0x07,                // bLength
   0x05,                // bDescriptorType
   0x81,                // bEndpointAddress
   0x02,                // bmAttributes
   EP1_PACKET_SIZE_LE,  // MaxPacketSize (LITTLE ENDIAN)
   00                   // bInterval
}; //end of Endpoint1Desc

const endpoint_descriptor Endpoint2Desc =
{
   0x07,                // bLength
   0x05,                // bDescriptorType
   0x02,                // bEndpointAddress
   0x02,                // bmAttributes
   EP2_PACKET_SIZE_LE,  // MaxPacketSize (LITTLE ENDIAN)
   00                   // bInterval
}; //end of Endpoint2Desc

#define STR0LEN 4

code const BYTE String0Desc[STR0LEN] =
{
   STR0LEN, 0x03, 0x09, 0x04
}; //end of String0Desc

#define STR1LEN sizeof("UNIVERSIDAD DE SEVILLA.ATC")*2

code const BYTE String1Desc[STR1LEN] =
{
   STR1LEN, 0x03,
   'U', 0,
   'N', 0,
   'I', 0,
   'V', 0,
   'E', 0,
   'R', 0,
   'S', 0,
   'I', 0,
   'D', 0,
   'A', 0,
   'D', 0,
   ' ', 0,
   'D', 0,
   'E', 0,
   ' ', 0,
   'S', 0,
   'E', 0,
   'V', 0,
   'I', 0,
   'L', 0,
   'L', 0,
   'A', 0,
   '.', 0,
   'A', 0,
   'T', 0,
   'C', 0
}; //end of String1Desc

//#define STR2LEN sizeof("C8051F320 MAPPER. CAVIAR.  ")*2

code const BYTE String2Desc[STR2LEN]  =
{
   STR2LEN, 0x03,
   'C', 0,
   '8', 0,
   '0', 0,
   '5', 0,
   '1', 0,
   'F', 0,
   '3', 0,
   '2', 0,
   '0', 0,
   ' ', 0,
   'M', 0,
   'A', 0,
   'P', 0,
   'P', 0,
   'E', 0,
   'R', 0,
   '.', 0,
   'C', 0,
   'A', 0,
   'V', 0,
   'I', 0,
   'A', 0,
   'R', 0,
   '.', 0,
   ' ', 0,
   ' ', 0,
   ' ', 0
}; //end of String2Desc

code const BYTE String2DescF[STR2LEN] _at_ 0x3A00;

BYTE* const StringDescTable[] = 
{
   String0Desc,
   String1Desc,
   String2DescF
};