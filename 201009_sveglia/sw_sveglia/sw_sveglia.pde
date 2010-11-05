// Sveglia Tutorial Wired Settembre 2010
// 
// Versione 03


// libreria I2C per parlare con il PCF8563
#include <Wire.h>

// Codice di gestione del RTC (Real Time Clock)
#include "PCF8563.h"
// include the library code:
#include <LiquidCrystal.h>

// inizializza la libreria che gestisce gli LCD
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

// Diamo un nome ai piedini connessi ai pulsanti
const int btn01Pin = 10;
const int btn02Pin = 9;
const int btn03Pin = 8;
const int btn04Pin = 7;


// variabili che contengono lo stato dei pulsanti
int btn01State = HIGH;
int btn02State = HIGH;
int btn03State = HIGH;
int btn04State = HIGH;

// variabli che contengono lo stato precedente del pulsante
int btn01Prev = HIGH;
int btn02Prev = HIGH;
int btn03Prev = HIGH;
int btn04Prev = HIGH;

// flag che segnale se un certo pulsante è stato effettivamente premuto
int btn01Pressed = false;
int btn02Pressed = false;
int btn03Pressed = false;
int btn04Pressed = false;


// Definizione stati 
const int NORMAL  = 0;
const int ALARM1  = 1;
const int ALARM2  = 2;
const int ALARM3  = 3;
const int ALARM4  = 4;

// partiamo con stato NORMAL
int state = NORMAL;

// cache ore e minuti
int a_hh = 0;
int a_mm = 0;


// siamo in allarme?
int alarm = false;


// array della combinazione di sblocco 
int unlock_sequence[4] = { 
  1,2,3,4};

// stampa un numero aggiungendo uno zero prima
// dei valori inferiori a 10
void printPadded(int num) {
  if (num < 10)
    lcd.print("0");

  lcd.print(num,DEC);
}


// legge i 4 pulsati 
void readButtons() {
  btn01State = digitalRead(btn01Pin);
  btn02State = digitalRead(btn02Pin);
  btn03State = digitalRead(btn03Pin);
  btn04State = digitalRead(btn04Pin);

  if ((btn01State == LOW) && (btn01Prev == HIGH)) {
    btn01Pressed = true;
  }
  btn01Prev = btn01State;

  if ((btn02State == LOW) && (btn02Prev == HIGH)) {
    btn02Pressed = true;
  }
  btn02Prev = btn02State;

  if ((btn03State == LOW) && (btn03Prev == HIGH)) {
    btn03Pressed = true;
  }
  btn03Prev = btn03State;

  if ((btn04State == LOW) && (btn04Prev == HIGH)) {
    btn04Pressed = true;
  }
  btn04Prev = btn04State;


}

// Dato il numero di un pulsate imposta il flag 
// corrispondente se è premuto
int buttonPressed(int btn) {
  int result = false;

  switch(btn) {

  case 1:
    if (btn01Pressed) result = true;
    break;
  case 2:
    if (btn02Pressed) result = true;
    break;
  case 3:
    if (btn03Pressed) result = true;
    break;
  case 4:
    if (btn04Pressed) result = true;
    break; 
  } 

  btn01Pressed = false;
  btn02Pressed = false;
  btn03Pressed = false;
  btn04Pressed = false;


  return result;
}

// genera una sequenza semi a caso
void generateSequence() {
  randomSeed(analogRead(0));

  unlock_sequence[0] = random(1,5);
  unlock_sequence[1] = random(1,5);  
  unlock_sequence[2] = random(1,5);  
  unlock_sequence[3] = random(1,5);

  Serial.print(unlock_sequence[0]);
  Serial.print( " ");
  Serial.print(unlock_sequence[1]);
  Serial.print( " ");
  Serial.print(unlock_sequence[2]);
  Serial.print( " ");
  Serial.print(unlock_sequence[3]);
  Serial.println( " ");
}

// Mostra la sequenza sul display
void displaySequence(int n) {

  // visualizza sequenza
  lcd.setCursor(0,0);
  lcd.print("Premi   ");
  lcd.setCursor(0,1);
  if (n > 3) 
    lcd.print(unlock_sequence[0]);
  else 
    lcd.print(" ");    
  lcd.print(" ");
  
  if (n > 2) 
    lcd.print(unlock_sequence[1]);
  else 
    lcd.print(" ");    
  lcd.print(" "); 
  
  if (n > 1) 
    lcd.print(unlock_sequence[2]);
  else 
    lcd.print(" ");    
  lcd.print(" ");  
  
  if (n > 0) 
    lcd.print(unlock_sequence[3]);
  else 
    lcd.print(" ");    
  lcd.print(" ");
}


// inizializza la scheda
void setup()
{

  // mettiamo a INPUT gli ingressi dei pulsanti
  pinMode(btn01Pin,INPUT);
  pinMode(btn02Pin,INPUT);
  pinMode(btn03Pin,INPUT);
  pinMode(btn04Pin,INPUT);

  // LED 13 usato per il debug e per il cicalino
  pinMode(13,OUTPUT);

  // Apre comunicazione con l'RTC e lo inizializza
  Wire.begin();     // join i2c bus (address optional for master)
  Serial.begin(9600);  // per debugging
  RTC.init();       // init variables, get info from the clock and store in in the register
  RTC.registersRTC[0] = 0;
  RTC.writeRTCregister(0);
  RTC.registersRTC[2] = 0;
  RTC.writeRTCregister(2);

  // imposta il display 
  // il nostro display è 1 riga di 16 caratteri ma internamente
  // crede di avere 2 righe di 8 caratteri
  // dovete aggiustare il codice in base al vostro display
  lcd.begin(8, 2);
  generateSequence();
}

void loop()
{
  // Legge l'RTC
  RTC.readRTC();
  // negli ultimi 20 secondi del minuto l'ora è aumentata di 40, mah..
  // è un baco della libreria ma non ho tempo di debuggarlo :) :)
  if (RTC.hour > 23) RTC.hour = RTC.hour - 40;  

  // legge i pulsanti
  readButtons();


  // in base allo stato in cui ci troviamo vengono eseguiti diversi
  // pezzi di codice.. poi un giorno devo scrivere un tuttorial
  switch(state) {

  // visualizza l'ora o l'allarme in base al pulsante 1
  case NORMAL:
    // se il pulsante 01 NON è premuto visualizzo l'ora
    if (btn01State == HIGH) {
      
      // se il pulsante 3 è premuto aumento le ore
      if (btn03Pressed) {
        RTC.hour++;
        // dopo 23 torna a 0
        if (RTC.hour  > 23) RTC.hour  = 0;
        // scrivi nell'RTC l'ora impostata
        RTC.writeRTC();
        // dopo aver gestito l'evento azzero il flag
        btn03Pressed = false; 
      }

      // stessa cosa per i minuti      
      if (btn04Pressed) {
        RTC.minute++;
        if (RTC.minute  > 59) RTC.minute  = 0;
        RTC.writeRTC();  
        btn04Pressed = false;
      }

      // visualizza ora
      lcd.setCursor(0,0);
      lcd.print("        ");
      lcd.setCursor(0,1);
      printPadded(RTC.hour);
      lcd.print(":");
      printPadded(RTC.minute);
      lcd.print(":");
      printPadded(RTC.second);
    } 
    else {
      // pulsante 1 premuto allora aggiorniamo l'ora
      // dell'allarme
      if (btn03Pressed) {
        a_hh++;
        if (a_hh  > 23) a_hh  = 0;
        btn03Pressed = false; 
      }

      if (btn04Pressed) {
        a_mm++;
        if (a_mm  > 59) a_mm  = 0;
        btn04Pressed = false;
      }
      
      //visualizza l'allarme
      lcd.setCursor(0,0);
      lcd.print("Alarm   ");
      lcd.setCursor(0,1);
      printPadded(a_hh);
      lcd.print(":");
      printPadded(a_mm);
      lcd.print(":");
      printPadded(0);
    }

    // banale verifica se è l'ora di far partire l'allarme
    if ((RTC.hour == a_hh) && (RTC.minute == a_mm) & (RTC.second == 0)) {
      alarm = true; 

      // genera sequenza random
      generateSequence();
      state = ALARM1;
    }
    break;

  // gestisce la prima cifra dell'allarme
  case ALARM1:
    // do it
    displaySequence(4);
    if (buttonPressed(unlock_sequence[0])) {
      state = ALARM2;
    }
    break;

  // gestisce la seconda cifra dell'allarme
  case ALARM2:
    // do it
    displaySequence(3);
    if (buttonPressed(unlock_sequence[1])) {
      state = ALARM3;
    }
    break;

  // gestisce la terza cifra dell'allarme
  case ALARM3:
    // do it
    displaySequence(2);
    if (buttonPressed(unlock_sequence[2])) {
      state = ALARM4;
    }
    break;

  // gestisce la quarta cifra dell'allarme
  case ALARM4:
    // do it
    displaySequence(1);
    if (buttonPressed(unlock_sequence[3])) {
      alarm = false;
      state = NORMAL;     
    }
    break;
  }

  // suona l'allarme , 100 va regolato per avere il suono migliore
  if (alarm) {
    digitalWrite(13,HIGH);
    delayMicroseconds(100);
    digitalWrite(13,HIGH);
    delayMicroseconds(100);
  }
  else
    digitalWrite(13,LOW);


}











