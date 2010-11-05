/*
  PCF8563.h - Controlling the RTC PCF8563 from Arduino
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

#ifndef Pins_Arduino_h
#include "pins_arduino.h"
#endif

#ifndef PCF8563_h
#define PCF8563_h

#define RST_RTC 2 // pin where we will get alarms from the clock

#define DAY_1 "Mo"
#define DAY_2 "Tu"
#define DAY_3 "We"
#define DAY_4 "Th"
#define DAY_5 "Fr"
#define DAY_6 "Sa"
#define DAY_7 "Su"

#include <inttypes.h>

#define RTC_ADDRESS 	0x51
#define RTC_DATA_SIZE 	0x0F

class PCF8563
{
  private:

  public:
    PCF8563();
    uint8_t BCD2byte(uint8_t number);

    uint8_t BCD2byte(uint8_t high, uint8_t low);
    uint8_t byte2BCD(uint8_t theNumber);
    uint8_t registersRTC[RTC_DATA_SIZE];
    uint8_t year;
    uint8_t month;
    uint8_t day;
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint8_t date;
    char auxBuffer[50];
    void init();

    void resetVars();

    char* getRTCarray();
    char* getTimestamp();
    void writeRTC();
    void readRTC();
    void writeRTCregister(uint8_t theAddress);
    void readRTCregister(uint8_t theAddress);
    void setWatchdog(uint8_t seconds, uint8_t tenths);
    void resetWatchdog();
};

extern PCF8563 RTC;

#endif


