/*MMC.h - header file for MMC interface
*/

char InitMMC(void);
char MMCgetResponse(void);
void SendCmd(char command, long argument, char CRC);
//char MMCwriteBlock(char *Block, long address);
char MMCreadBlock(char *Block, long address);
void MMCchangeBase(long address);
char MMCreadBlockSeq(char *Block);
void readByte(char *value);
char MMCreadBlocktoFPGA(void);
long MMCgetFirst(char *, long *);

#define MMC_BASE (long)528*512  //Posición inicial de datos en MMC FAT16