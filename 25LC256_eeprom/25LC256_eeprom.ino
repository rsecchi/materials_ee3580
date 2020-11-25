#include "25LC256.h"

#define MAXLEN 1000

char buffer[MAXLEN];
char res[200];

int len;

void setup() {
  len = strlen(buffer);
  Serial.begin(9600);

  for(int i=0; i<MAXLEN; i++)
  {
    buffer[i] = 'B' + i%40;
  }

  conf_spi_25LC256();
  //eeprom_write_msg(buffer, MAXLEN, 0x0FAE);

  char buffo[5] = {'U','o','A','!','\0'};
  char lettura[20];

  Serial.println("\n\n------------");
  Serial.println(buffo);
  Serial.println(strlen(buffo));

 
  eeprom_write_msg(buffo, 5, 0x2000);
  eeprom_read_msg(0x2000, 5, lettura);
  
  Serial.println("Read: ");
  Serial.println(lettura);

  for(;;);

}

void loop() {

}
