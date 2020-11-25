/*
     25LC256 drivers for Arduino
     R. Secchi
     University of Aberdeen - 2020
*/
#include "Arduino.h"

#define NOCMD   0x00
#define WRSR    0x01
#define WRITE   0x02
#define READ    0x03
#define WRDI    0x04
#define RDSR    0x05
#define WREN    0x06

#define WPEN    7
#define BP1     3
#define BP0     2
#define WEL     1
#define WIP     0

#define START_SPI   (PORTB &= ~(1<<PB2))
#define STOP_SPI    (PORTB |= (1<<PB2))

void conf_spi_25LC256()
{
  // MISO (Arduino 12, PB4, input)
  // MOSI (Arduino 11, PB3, output)
  // SCK  (Arduino 13, PB5, output)
  // /SS  (Arduino 10, PB2, output)
    
  pinMode(10, OUTPUT);   //   /SS
  pinMode(11, OUTPUT);   //   MOSI
  pinMode(12, INPUT);    //   MISO 
  pinMode(13, OUTPUT);   //   SCK
    
  SPCR = 0x53;  // SPE, MSTR, mode(0,0), 125kHz
}

uint8_t spi_transfer_byte(uint8_t data)
{
  SPDR = data;                 // load SPI buffer
  while(!(SPSR & (1<<SPIF)));  // wait for SPI transfer to end
  return SPDR;                 // return buffer
}

uint8_t eeprom_read(uint16_t addr)
{
  uint8_t addrH, addrL;
  uint8_t result;
  addrH = addr >> 8;
  addrL = addr & 0xFF;

  START_SPI;
  spi_transfer_byte(READ);
  spi_transfer_byte(addrH);   
  spi_transfer_byte(addrL);
  result = spi_transfer_byte(NOCMD);
  STOP_SPI;

  return result;
}

uint8_t eeprom_read_SR()
{
  uint8_t  result;
  
  START_SPI;
  spi_transfer_byte(RDSR);  // read status register
  result = spi_transfer_byte(NOCMD);
  STOP_SPI;

  return result;
}

void eeprom_enable_write()
{
  START_SPI;
  spi_transfer_byte(WREN);
  STOP_SPI;
}

void eeprom_disable_write()
{
  START_SPI;
  spi_transfer_byte(WRDI);
  STOP_SPI;
}

/* wait for device to terminate write cycle */
void eeprom_wait_write()
{
  uint8_t result;
  
  do {
    START_SPI;
    spi_transfer_byte(RDSR);
    result = spi_transfer_byte(NOCMD);
    STOP_SPI;
  } while (result & (1<<WIP));
}

void eeprom_write(uint16_t addr, uint8_t data)
{
  uint8_t result;
  uint8_t addrH, addrL;
  addrH = addr >> 8;
  addrL = addr & 0xFF;

  eeprom_enable_write();
  
  START_SPI;
  spi_transfer_byte(WREN);
  spi_transfer_byte(WRITE);
  spi_transfer_byte(addrH);
  spi_transfer_byte(addrL);
  spi_transfer_byte(data);
  STOP_SPI;
  
  eeprom_wait_write();

}

uint16_t eeprom_read_msg(uint16_t addr, uint16_t size, uint8_t* out)
{  
  uint8_t addrH, addrL;
  uint8_t result;
  addrH = addr >> 8;
  addrL = addr & 0xFF;


  START_SPI;
  spi_transfer_byte(READ);
  spi_transfer_byte(addrH);   
  spi_transfer_byte(addrL);
  
  while(size)
  {
    *out = spi_transfer_byte(NOCMD);
    out++;
    size--;
  }
  
  STOP_SPI;
}


void eeprom_write_msg(uint8_t* out, int size, uint16_t addr)
{  
  uint8_t addrH, addrL;
  uint8_t result;
  uint16_t blocksize;

  while(size>0)
  {

    // write block within a page
    blocksize = (~addr & 0x003F) + 1;
    
    if (blocksize > size) {
        blocksize = size;
        size = 0;
    }
    else
        size -= blocksize;
   
    addrH = addr >> 8;
    addrL = addr & 0xFF;

    eeprom_enable_write();
    
    START_SPI;
    spi_transfer_byte(WRITE);
    spi_transfer_byte(addrH);
    spi_transfer_byte(addrL);

    for(; blocksize>0; blocksize--) {
       spi_transfer_byte(*out);
       out++;
       addr++;
    }
    STOP_SPI;

    eeprom_wait_write();
  }

}
