/*
     25LC256 drivers for Arduino
     R. Secchi
     University of Aberdeen - 2020
*/
#include "Arduino.h"
#include "25LC256.h"

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


// SPI implementation

uint8_t spi_transfer_byte(uint8_t data)
{
  SPDR = data;                 // load SPI buffer
  while(!(SPSR & (1<<SPIF)));  // wait for SPI transfer to end
  return SPDR;                 // return buffer
}

void spi_write_word(uint16_t wrd)
{
  spi_transfer_byte((uint8_t)(wrd >> 8));
  spi_transfer_byte((uint8_t)(wrd & 0xFF));
}


void spi_read_array(uint8_t* data_in, uint16_t len)
{
  for(;len>0; len--)
  {
    SPDR = NOCMD;
    while(!(SPSR & (1<<SPIF)));
    *data_in = SPDR;
    data_in++;
  }
}

void spi_write_array(uint8_t* data_out, uint16_t len)
{
  for(;len>0; len--)
  {
    SPDR = *data_out;
    data_out++;
    while(!(SPSR & (1<<SPIF)));
  }
}


/// EEPROM control implementation

uint8_t eeprom_read(uint16_t addr)
{

  uint8_t result;

  START_SPI;
  spi_transfer_byte(READ);
  spi_write_word(addr);
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

  eeprom_enable_write();
  
  START_SPI;
  spi_transfer_byte(WRITE);
  spi_write_word(addr);
  spi_transfer_byte(data);
  STOP_SPI;
  
  eeprom_wait_write();

}

uint16_t eeprom_read_msg(uint16_t addr, uint16_t size, uint8_t* out)
{  

  START_SPI;
  spi_transfer_byte(READ);
  spi_write_word(addr);
  spi_read_array(out, size);
  STOP_SPI;
}

void eeprom_write_msg(uint8_t* out, int size, uint16_t addr)
{  
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

    eeprom_enable_write();
    
    START_SPI;
    spi_transfer_byte(WRITE);
    spi_write_word(addr);
    spi_write_array(out, blocksize);
    addr += blocksize;
    STOP_SPI;

    eeprom_wait_write();

  }

}
