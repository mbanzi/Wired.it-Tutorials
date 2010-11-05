/*

  PCF8563.cpp - Controlling the RTC PCF8563 from Arduino
  Copyright (c) 2009 David Cuartielles.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
  Created 5 January 2009 by David J. Cuartielles
*/

#include "PCF8563.h"
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include "wiring.h"
#include <Wire.h>

//#include "twi.h"

// Variables ////////////////////////////////////////////////////////////////
// Constructors ////////////////////////////////////////////////////////////////

PCF8563::PCF8563()
{
  // nothing to do when constructing
}

// Public Methods //////////////////////////////////////////////////////////////

void PCF8563::init()
{
  // enable the internal pull-up resistor for the RTC-interrupt pin
  pinMode(RST_RTC, INPUT);
  digitalWrite(RST_RTC, HIGH);
  
  // initialize the variables used to store the data
  // from the RTC
  readRTC();
}

void PCF8563::resetVars()
{
  // reset the variables to zero
    year = 0;
    month = 0;
    day = 0;
    hour = 0;
    minute = 0;
    second = 0;
    date = 0;
}

/* getRTCarray
 * - will answer last array taken from the RTC
 * - includes: day of the week, date, and time, watchdog registers, etc
 */
char* PCF8563::getRTCarray() 
{
  char* aux = "\0                                      ";
  for(uint8_t i = 0; i < RTC_DATA_SIZE; i++) {
    sprintf(aux, "%u", registersRTC[i]);
  }
  return aux;
}

/* getTimestamp
 * - will answer the current state of the variables
 * - includes: day of the week, date, and time
 */
char* PCF8563::getTimestamp() 
{
//  char weekday[2];
  switch (day) {
  case 1:
//    sprintf (weekday, "%s", DAY_1);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_1, year, month, date, hour, minute, second);
    break;
  case 2:
//    sprintf (weekday, "%s", DAY_2);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_2, year, month, date, hour, minute, second);
    break;
  case 3:
//    sprintf (weekday, "%s", DAY_3);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_3, year, month, date, hour, minute, second);
    break;
  case 4:
//    sprintf (weekday, "%s", DAY_4);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_4, year, month, date, hour, minute, second);
    break;
  case 5:
//    sprintf (weekday, "%s", DAY_5);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_5, year, month, date, hour, minute, second);
    break;
  case 6:
//    sprintf (weekday, "%s", DAY_6);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_6, year, month, date, hour, minute, second);
    break;
  case 7:
//    sprintf (weekday, "%s", DAY_7);
    sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", DAY_7, year, month, date, hour, minute, second);
    break;
  }
//  sprintf (auxBuffer, "%s, %d/%d/%d - %d:%d.%d", *weekday, year, month, date, hour, minute, second);
  return auxBuffer;
}

/* readRTC
 * - read the status of the RTC
 * - gets all the 0x0C first spaces in the RTC
 * - stores the data on the registersRTC[] array
 * - puts the data into the year, month, date, hour, minute, second, and day variables
 */
void PCF8563::readRTC() 
{
  uint16_t timecount = 0;
  // ADDRESSING FROM MEMORY POSITION ZERO
  Wire.beginTransmission(RTC_ADDRESS); // transmit to device #81 (0x51)
  Wire.send(0x00);  // start from address zero
  Wire.endTransmission();
  
  // START READING
  Wire.requestFrom(RTC_ADDRESS, RTC_DATA_SIZE); // transmit to device #81 (0x51)

  while(timecount < RTC_DATA_SIZE)    // slave may send less than requested
  { 
    if (Wire.available()) {
      uint8_t c = Wire.receive(); // receive a byte as character
      registersRTC[timecount] = c;
      switch (timecount) {
      case 2:
        second = BCD2byte(c>>4, c&B1111);
        break;
      case 3:
        minute = BCD2byte(c>>4, c&B1111);
        break;
      case 4:
        hour = BCD2byte(c>>4, c&B1111);
        break;
      case 6:
        day = c;
        break;
      case 5:
        date = BCD2byte(c>>4, c&B1111);
        break;
      case 7:
        month = BCD2byte(c>>4, c&B1111);
        break;
      case 8:
        year = BCD2byte(c>>4, c&B1111);
        break;
      }
      timecount++;
    }
  }

  timecount = 0;
}

/* writeRTC
 * - write the stored variables to the RTC
 * - sends 0x0C values in a raw
 * - takes the data from the registersRTC[] array
 */
void PCF8563::writeRTC() 
{
  uint16_t timecount = 0;
  Wire.beginTransmission(RTC_ADDRESS); // transmit to device #104 (0x68)
  // the address specified in the datasheet is 208 (0xD0)
  // but i2c adressing uses the high 7 bits so it's 104    
  Wire.send(0x00);  // start from address zero

  registersRTC[0x02] = byte2BCD(second);
  registersRTC[0x03] = byte2BCD(minute);
  registersRTC[0x04] = byte2BCD(hour);
  registersRTC[0x06] = day;
  registersRTC[0x05] = byte2BCD(date);
  registersRTC[0x07] = byte2BCD(month);
  registersRTC[0x08] = byte2BCD(year);

  for(timecount = 0; timecount < RTC_DATA_SIZE; timecount++) {
    Wire.send(registersRTC[timecount]);
  }

  Wire.endTransmission();
}

/* writeRTCregister ( address )
 * - writes one register to the RTC
 * - takes the data from the registersRTC[] array
 * - the parameter states which position inside the array and on the memory
 * - FIXME: modify it to write to EEPROM
 */
void PCF8563::writeRTCregister(uint8_t theAddress) 
{
  // ADDRESSING FROM MEMORY POSITION RECEIVED AS PARAMETER
  Wire.beginTransmission(RTC_ADDRESS); // transmit to device #104 (0x68)
  // the address specified in the datasheet is 208 (0xD0)
  // but i2c adressing uses the high 7 bits so it's 104    
  Wire.send(theAddress);  // start from address theAddress

  // START SENDING
  Wire.send(registersRTC[theAddress]);
  Wire.endTransmission();
}

/* readRTCregister ( address )
 * - reads one register from the RTC
 * - puts the data into the registersRTC[] array
 * - the parameter states which position inside the array and on the memory
 * - FIXME: modify it to read from EEPROM
 */
void PCF8563::readRTCregister(uint8_t theAddress) 
{
  // ADDRESSING FROM MEMORY POSITION RECEIVED AS PARAMETER
  Wire.beginTransmission(RTC_ADDRESS); // transmit to device #104 (0x68)
  // the address specified in the datasheet is 208 (0xD0)
  // but i2c adressing uses the high 7 bits so it's 104    
  Wire.send(theAddress);  // start from address theAddress
  Wire.endTransmission();
  
  // START READING
  Wire.requestFrom(RTC_ADDRESS, 0x01); // transmit to device #104 (0x68)
  // the address specified in the datasheet is 208 (0xD0)
  // but i2c adressing uses the high 7 bits so it's 104    
  while(!Wire.available()) {};
  registersRTC[theAddress] = Wire.receive();
  Wire.endTransmission();
}

//FIXME!! this is just the watchdog for a different RTC
void PCF8563::setWatchdog(uint8_t seconds, uint8_t tenths) {
    resetWatchdog();
    RTC.registersRTC[0x08] = byte2BCD(tenths); // set up the timer --> tenths of secs
    RTC.writeRTCregister(0x08);
    RTC.registersRTC[0x09] = byte2BCD(seconds); // set up the timer --> secs
    RTC.writeRTCregister(0x09);
    RTC.registersRTC[0x0B] &= ~0x40; // clear the WF flag
    RTC.writeRTCregister(0x0B);
    RTC.registersRTC[0x0C] |= 0x03; // turn ON WDE && RST
    RTC.writeRTCregister(0x0C);
}

void PCF8563::resetWatchdog() {
    RTC.readRTCregister(0x0C);
    RTC.registersRTC[0x0C] &= ~0x03; // turn OFF WDE && RST
    RTC.writeRTCregister(0x0C);
    RTC.registersRTC[0x0B] &= ~0x40; // clear the WF flag
    RTC.writeRTCregister(0x0B);
}

/* BCD2byte ( number )
 * - returns the BCD encoded number as integer
 * - FIXME: this function was never tested, but should work
 */
uint8_t PCF8563::BCD2byte(uint8_t number) 
{
  return (number>>4)*10 | (number & 0x0F);
}

/* BCD2byte ( high, low )
 * - returns the BCD encoded number as integer
 */
uint8_t PCF8563::BCD2byte(uint8_t high, uint8_t low) 
{
  return high*10 + low;
}

/* byte2BCD ( number )
 * - returns the number as BCD
 */
uint8_t PCF8563::byte2BCD(uint8_t theNumber) 
{
  return (theNumber%10 | ((theNumber-theNumber%10)/10)<<4);  // note that binary operations have preference on the others
}


// Private Methods /////////////////////////////////////////////////////////////
// Preinstantiate Objects //////////////////////////////////////////////////////

PCF8563 RTC = PCF8563();


