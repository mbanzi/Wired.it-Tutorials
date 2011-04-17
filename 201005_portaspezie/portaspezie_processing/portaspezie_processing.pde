import processing.serial.*;

import java.io.*; 

Serial p; // la porta alla quale è collegato Arduino
String s; // raccoglie i dati in arrivo da Arduino
PFont fp; // font piccolo
PFont fg; // font grande
String msg = "";  // messaggio che appare in mezzo allo schermo


int[] sensori = new int[7]; // array di numeri interi che viene aggiornato
// ogni volta che arduino manda i valori dei 
// sei ingressi analogici

// le 6 playlist che avete creato in iTunes
String[] playlists = {"arduino1","arduino2","arduino3","arduino4","arduino5","arduino6"};

// soglia alla quale il sensore si attiva e parte la musica
int soglia = 512;

void setup() {
  size(480,300);
  String portName = Serial.list()[0];
  p = new Serial(this, portName, 9600);
  p.bufferUntil(10);
  fp = createFont("Arial", 12);
  fg = createFont("Arial", 36);

}

void draw() {
  background(0); // fondo nero
  stroke(255);   // linee bianche
  fill(255);
  textFont(fg);
  text("Portaspezie musicale",50,50);
  textFont(fp);
  text("Un progetto di Tinker it! per Wired.it",50,100);
  text(msg,50, 150);
  
  for (int i = 0; i < 6; i++) {
    // riempimento con un grigio proporzionale al valore letto
    fill(sensori[i] /4); 
    // disegna un quadrato che rappresenta i valori degli ingressi
    rect((i*50)+50, 200,30,30);
    fill(255);
    // e scrive il numero sotto il quadrato
    text(sensori[i],(i*50)+50,250);
    // se il valore letto è superiore alla soglia vuol dire che il
    // barattolo è stato sollevato
    if (sensori[i] > soglia) {
      playList(playlists[i]);
      
    }
  }
  
  


}

void serialEvent(Serial p) {
  s = p.readString(); // leggiamo i 6 numeri che ci ha mandato Arduino
  if (s.length() > 12) { // la stringa deve avere almeno 12 caratteri per essere valida
    s = s.substring(0,s.length()-2);   // eliminiamo l'ultimo carattere
    String[] ss= split(s,",");// dividiamo la stringa ad ogni virgola
    sensori = int(ss); // convertiamo ogni elemento in un numero intero
    // ora "sensori" contiene i 6 valori mandati da Arduino
  }
}


void keyPressed() {
  if ((keyCode >= 48) && (keyCode <= 53)){
    playList(playlists[keyCode-48]);
  }
}


// comanda iTunes lanciando la playlist indicata
void playList(String playlist) {
  msg = "Selezionata " + playlist;
  // script è un micro-programma in Applescript che viene inviato ad iTunes
  String script = "tell application \"iTunes\""+"\n";
  // assicuriamoci che la playlist selezioni i brani a caso
  script += "set shuffle of playlist \""+playlist+"\" to true\n";
  // facciamo partire la musica
  script += "play playlist \"" + playlist + "\"\n";
  // ciao iTunes grazie di tutto
  script += "end tell";
  // invia il comando
  executeScript(script);
}

// invia ad iTunes il comando indicato 
void iTunes(String command) {
  String script = "tell application \"iTunes\""+"\n";
  script += command + "\n";
  script += "end tell";
  executeScript(script);
}

// Esegue il comando AppleScript
void executeScript(String script) { 
  String[] params = { // prepara il comando
    "osascript", "-e" ,script    }; // osascript è l'interprete di AppleScript
  try {
    Runtime.getRuntime().exec(params); // esegue il comando
  } 
  catch (Exception e) {
    println(e); // se qualcosa va storto salta qui 
  }
}


