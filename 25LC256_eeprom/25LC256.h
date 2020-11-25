/*
     25LC256 drivers for Arduino
     R. Secchi
     University of Aberdeen - 2020
*/

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

/*
  Configure the SPI as follows:

  MISO (Arduino 12, PB4, input)
  MOSI (Arduino 11, PB3, output)
  SCK  (Arduino 13, PB5, output)
  /SS  (Arduino 10, PB2, output)

  SPI configuration register:
    + SPIE=0  IRQ disabeld (bit 7)
    + SPE=1   enabled (bit 6)
    + DORD=0  MSB first
    + MSTR=1  MCU is master
    + CPOL=0  clock idle low
    + CPHA=0  sampling on leading edge
    + SPR=10  Rate is Fosc/128 = 125kHz

*/
void conf_spi_25LC256();

/* Single SPI transfer */
uint8_t spi_transfer_byte(uint8_t data);

/* Returns byte at addr [0x0000:0x7FFF] */
uint8_t eeprom_read(uint16_t addr);

/* Returns the status register */
uint8_t eeprom_read_SR();

/* Enable EEPROM write */
void eeprom_enable_write();

/* Disable EEPROM write */
void eeprom_disable_write();

/* wait for device to terminate write cycle */
void eeprom_wait_write();

/* write 'data' at address [0x0000:0x7FFF] */
void eeprom_write(uint16_t addr, uint8_t data);

/* copies size EEPROM bytes startging at addr into the buffer 'out' */
uint16_t eeprom_read_msg(uint16_t addr, uint16_t size, uint8_t* out);


/* write size bytes from 'out' into EEPROM starting at 'addr' */
void eeprom_write_msg(uint8_t* out, int size, uint16_t addr);
