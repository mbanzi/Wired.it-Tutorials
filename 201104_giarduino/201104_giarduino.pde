// tutorial per wired di Aprile 2011
// giarduino 
// versione alpha



#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1,177 };
byte gateway[] = { 192,168,1,1 };
byte server[] = { 69,163,226,196 }; 

char myUUID[] = "5A8BA768E86F5D3008A2DB94AF0CD7E6";

// --- end of configuration
int seq = 0;
int pumpStatus=0;
int temperature=0;
int humidity=0;
int light=0;
unsigned long start = 0;
char buffer[64];
int bufferPointer = 0;

const int processDelay = 100;

const int pumpPin = 6;
const int humiditySwitchPin = 2;
const int humidityPin = A0;
const int temperaturePin = A1;
const int lightPin = A2;



Client client(server, 61613);

void setup()
{

  pinMode(pumpPin,OUTPUT);
  pinMode(humiditySwitchPin,OUTPUT);

  Ethernet.begin(mac, ip);
  Serial.begin(9600);

  delay(processDelay); //let the shield initialise

  Serial.println("connecting...");

  if (client.connect()) {
    Serial.println("connected");
    client.println("CONNECT");
    client.println("login:guest");
    client.println("password:guest");
    client.println();
    client.print('\0');
    delay(processDelay);
    processData();
    Serial.println("subscribing");
    client.println("SUBSCRIBE");
    client.print("destination:/queue/GUEST.");
    client.print(myUUID);
    client.println(".in");
    //    client.println("ack: client");
    client.println();
    client.print('\0');
    delay(processDelay);
    processData();
  } 
  else {
    Serial.println("connection failed");
  }
  start = millis();
  cleanBuffer();
  //blinkLed(); // for debugging only
}

void loop()
{
  acquireData();
  if (pumpStatus) 
    digitalWrite(pumpPin,HIGH);
  else
    digitalWrite(pumpPin,LOW);

  if (client.available()) processData(); // possibily an incoming message

  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    for(;;)
      ;
  } 
  else {
    // if we are connected, send data every minute
    if ((millis() - start) >60000) {
      sendData();
      start = millis();
    }
  }
}

void processData() {
  while (client.available()) {
    char c = client.read();

    if ((c == '\n') || (c == '\0')) { // if end of line process data
      Serial.print("line [");
      Serial.print(bufferPointer);
      Serial.print("] :");       
      Serial.println(buffer);
      if (strncmp(buffer, "ARD1", 4) == 0) {
        Serial.println("Pump On");
        pumpStatus = 1; 
      }
      if (strncmp(buffer, "ARD0", 4) == 0) {
        Serial.println("Pump Off");
        pumpStatus = 0; 
      }
      if (strncmp(buffer, "ARDS", 4) == 0) {
        sendData();
      }
      cleanBuffer();
    } // add to buffer
    else {
      buffer[bufferPointer]=c;
      if (bufferPointer < 64) bufferPointer++;
    }

  } 
}

void acquireData() {
  temperature = analogRead(temperaturePin);
  digitalWrite(humiditySwitchPin,HIGH); // turn on the sensor
  humidity    = analogRead(humidityPin);
  digitalWrite(humiditySwitchPin,LOW);  // turn off the sensor
  light       = analogRead(lightPin);
}


void sendData() {
  client.println("SEND");
  client.print("destination:/queue/GUEST.");
  client.print(myUUID);
  client.println(".out");
  client.print("receipt: ARDR");
  client.println(seq);
  client.println();
  client.print("ARDS,");
  client.print(pumpStatus);
  client.print("," );
  client.print(temperature);
  client.print(","); 
  client.print(humidity); 
  client.print(",");
  client.print(light);
  client.print('\0');  
  seq++; 
}

void cleanBuffer() {
  for (int i = 0; i < 64; i++) buffer[i] = 0;
  bufferPointer = 0;
}

void blinkLed() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(pumpPin,HIGH);
    delay(300);
    digitalWrite(pumpPin,LOW);
    delay(300); 
  } 
}







