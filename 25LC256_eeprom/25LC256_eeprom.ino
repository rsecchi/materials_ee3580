#include "25LC256.h"

char buffer[] = "Test one two three testo ... ";
char res[200];

int len;

void setup() {
  len = strlen(buffer);
  Serial.begin(9600);

  conf_spi_25LC256();
  eeprom_write_msg(buffer, len, 0x0300);

}

void loop() {
  uint8_t sr;

  eeprom_read_msg(0x0300, len, res);
  res[len] =  '\0'; 

  Serial.println(len);
  Serial.println(res);
  delay(1000);
}
