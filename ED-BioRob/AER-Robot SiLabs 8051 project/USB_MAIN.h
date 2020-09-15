/*
   Rev History

   11/22/02 - DM: 1. Updated function prototypes and added constants
                  to USB_MAIN.h with sample interrupt firmware.

   File:    USB_MAIN.h
   Author:  JS
   Created: 4/5/02

   Target Device: C8051F320

   Main header file for USB firmware. Includes function prototypes,
   standard constants, and configuration constants.

*/

#ifndef _USB_MAIN_H_
#define _USB_MAIN_H_

//#define _USB_LOW_SPEED_                      // Change this comment to make Full/Low speed

#define SYSCLK                   12000000    // SYSCLK frequency in Hz

// USB clock selections (SFR CLKSEL)
#define USB_4X_CLOCK             0x00        // Select 4x clock multiplier, for USB Full Speed
#define USB_INT_OSC_DIV_2        0x10        // See Data Sheet section 13. Oscillators
#define USB_EXT_OSC              0x20
#define USB_EXT_OSC_DIV_2        0x30
#define USB_EXT_OSC_DIV_3        0x40
#define USB_EXT_OSC_DIV_4        0x50

// System clock selections (SFR CLKSEL)
#define SYS_INT_OSC              0x00        // Select to use internal oscillator
#define SYS_EXT_OSC              0x01        // Select to use an external oscillator
#define SYS_4X_DIV_2             0x02

// BYTE type definition
#ifndef _BYTE_DEF_
#define _BYTE_DEF_
typedef unsigned char BYTE;
#endif   /* _BYTE_DEF_ */

// WORD type definition, for KEIL Compiler
#ifndef _WORD_DEF_                           // Compiler Specific, written for Little Endian
#define _WORD_DEF_
typedef union {unsigned int i; unsigned char c[2];} WORD;
#define LSB 1                                // All words sent to and received from the host are
#define MSB 0                                // little endian, this is switched by software when
                                             // neccessary.  These sections of code have been marked
											 // with "Compiler Specific" as above for easier modification
#endif   /* _WORD_DEF_ */

// Define Endpoint Packet Sizes
#ifdef _USB_LOW_SPEED_
#define  EP0_PACKET_SIZE         0x08        // This value can be 8,16,32,64 depending on device speed, see USB spec
#else
#define  EP0_PACKET_SIZE         0x40
#endif /* _USB_LOW_SPEED_ */ 
#define  EP1_PACKET_SIZE         0x0040      // Can range 0 - 1024 depending on data and transfer type  
#define  EP1_PACKET_SIZE_LE      0x4000      // IMPORTANT- this should be Little-Endian version of EP1_PACKET_SIZE
#define  EP2_PACKET_SIZE         0x0040      // Can range 0 - 1024 depending on data and transfer type
#define  EP2_PACKET_SIZE_LE      0x4000      // IMPORTANT- this should be Little-Endian version of EP2_PACKET_SIZE

// Standard Descriptor Types
#define  DSC_DEVICE              0x01        // Device Descriptor
#define  DSC_CONFIG              0x02        // Configuration Descriptor
#define  DSC_STRING              0x03        // String Descriptor
#define  DSC_INTERFACE           0x04        // Interface Descriptor
#define  DSC_ENDPOINT            0x05        // Endpoint Descriptor

// Standard Request Codes
#define  GET_STATUS              0x00        // Code for Get Status
#define  CLEAR_FEATURE           0x01        // Code for Clear Feature
#define  SET_FEATURE             0x03        // Code for Set Feature
#define  SET_ADDRESS             0x05        // Code for Set Address
#define  GET_DESCRIPTOR          0x06        // Code for Get Descriptor
#define  SET_DESCRIPTOR          0x07        // Code for Set Descriptor(not used)
#define  GET_CONFIGURATION       0x08        // Code for Get Configuration
#define  SET_CONFIGURATION       0x09        // Code for Set Configuration
#define  GET_INTERFACE           0x0A        // Code for Get Interface
#define  SET_INTERFACE           0x0B        // Code for Set Interface
#define  SYNCH_FRAME             0x0C        // Code for Synch Frame(not used)

// Define device states
#define  DEV_ATTACHED            0x00        // Device is in Attached State
#define  DEV_POWERED             0x01        // Device is in Powered State
#define  DEV_DEFAULT             0x02        // Device is in Default State
#define  DEV_ADDRESS             0x03        // Device is in Addressed State
#define  DEV_CONFIGURED          0x04        // Device is in Configured State
#define  DEV_SUSPENDED           0x05        // Device is in Suspended State

// Define bmRequestType bitmaps
#define  IN_DEVICE               0x00        // Request made to device, direction is IN 
#define  OUT_DEVICE              0x80        // Request made to device, direction is OUT
#define  IN_INTERFACE            0x01        // Request made to interface, direction is IN
#define  OUT_INTERFACE           0x81        // Request made to interface, direction is OUT
#define  IN_ENDPOINT             0x02        // Request made to endpoint, direction is IN
#define  OUT_ENDPOINT            0x82        // Request made to endpoint, direction is OUT

// Define wIndex bitmaps
#define  IN_EP1                  0x81        // Index values used by Set and Clear feature
#define  OUT_EP1                 0x01        // commands for Endpoint_Halt
#define  IN_EP2                  0x82
#define  OUT_EP2                 0x02

// Define wValue bitmaps for Standard Feature Selectors
#define  DEVICE_REMOTE_WAKEUP    0x01        // Remote wakeup feature(not used)
#define  ENDPOINT_HALT           0x00        // Endpoint_Halt feature selector

// Define Endpoint States
#define  EP_IDLE                 0x00        // This signifies Endpoint Idle State
#define  EP_TX                   0x01        // Endpoint Transmit State
#define  EP_RX                   0x02        // Endpoint Receive State
#define  EP_HALT                 0x03        // Endpoint Halt State (return stalls)
#define  EP_STALL                0x04        // Endpoint Stall (send procedural stall next status phase)
#define  EP_ADDRESS              0x05        // Endpoint Address (change FADDR during next status phase)

// Function prototypes
// USB Routines
void Usb_Resume(void);                       // This routine resumes USB operation
void Usb_Reset(void);                        // Called after USB bus reset
void Handle_Setup(void);                     // Handle setup packet on Endpoint 0
void Handle_In1(void);                       // Handle in packet on Endpoint 1
void Handle_Out2(void);                      // Handle out packet on Endpoint 2
void Usb_Suspend(void);                      // This routine called when suspend signalling on bus

// Standard Requests
void Get_Status(void);                       // These are called for each specific standard request
void Clear_Feature(void);
void Set_Feature(void);
void Set_Address(void);
void Get_Descriptor(void);
void Get_Configuration(void);
void Set_Configuration(void);
void Get_Interface(void);
void Set_Interface(void);

// Initialization Routines
void Sysclk_Init(void);                      // Initialize the system clock(depends on Full/Low speed)
void Port_Init(void);                        // Configure ports for this specific application
void Usb0_Init(void);                        // Configure USB core for either Full/Low speed
void Timer_Init(void);                       // Start timer 2 for use by ADC and to check switches
void Adc_Init(void);                         // Configure ADC for continuous conversion, low-power mode

// Other Routines
void Timer2_ISR(void);                       // Called when Timer 2 overflows, see if switches are pressed
void Adc_ConvComple_ISR(void);               // When a conversion completes, switch ADC multiplexor
void Usb_ISR(void);                          // Called to determine type of USB interrupt
void Fifo_Read (BYTE, unsigned int, BYTE *); // Used for multiple byte reads of Endpoint fifos
void Fifo_Write (BYTE, unsigned int, BYTE *);// Used for multiple byte writes of Endpoint fifos
void Force_Stall(void);                      // Forces a procedural stall on Endpoint 0
void Delay(void);                            // Approximately 80 us/1 ms on Full/Low Speed

#endif      /* _USB_MAIN_H_ */

