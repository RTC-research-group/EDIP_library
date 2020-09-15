//FUNCTION PROTOTYPES


char SendByte(char byte);
void vSendByte(char byte);
void RaiseSS();
void LowerSS();
void Init_MMC_Ports(void);
char MMCpresent(void);



sbit MMC_SCK= P0^0;
sbit MMC_MISO= P0^1;
sbit MMC_MOSI =P0^2;
sbit MMC_SS =P0^3;
sbit MMC_P =P2^7;

/*#define DELAY_U _nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;\
_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;\
_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_;_nop_; /* */


#define DELAY_U _nop_;
