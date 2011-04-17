// Officina Arduino
// Maggio 2010
//
// Portaspezie musicale
// 

int val = 0; // creiamo una variabile per memorizzare i valori 
// che leggiamo dagli ingressi analogici

void setup() {
  Serial.begin(9600); // Apre la comunicazione col computer
}

void loop() {
  for (int i = 0; i < 6; i++) { // contiamo da 0 a 5
    val = analogRead(i); // leggiamo l'ingresso analogico 
    Serial.print(val);   // Invia il numero al computer
    if (i < 5) {         // Se il numero è inferiore a 5
      Serial.print(","); // Inviamo una virgola
    } 
    else {
      Serial.println("");// Altrimenti inviamo un acapo
    } 
  }  
  delay(100); //leggero ritardo per evitare di sovraccaricare il computer
}


