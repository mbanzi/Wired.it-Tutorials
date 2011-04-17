// Intervaluino
// this code programs the Arduino as an intervalometer for a Canon EOS camera, using two relays and a push button
// this enables you to create time-lapse movies with your camera.
// change the variables “full_time” and “short_time” to automatically calculate the right time interval (based on 25 frames per second)
// upload the code via USB, fire up the Arduino, plug it into your camera’s remote shutter release, and press the Intervaluino push button.
// press the button another time to stop the sequence (doesn’t work that well if your interval is long)
// make sure to turn on single shoot
// (c) Lord Yo 2008 (intervaluino a_t sporez do:t com)
// modified by Massimo Banzi 2010
// Licensed under a Creative Commons (Attribution Non-Commercial Share-Alike) license

/////////// Change these variables according to your needs

long full_time = 14400; //full length time to cover (in seconds)
long short_time = 120; //length of time-lapse movie (in seconds)

int shutter_on = 200; //time to press shutter, set between 100 and 300
int shutter_wait = 5000; //initial time to wait to begin sequence
int wakeup = 300; //time to activate wakeup (focus)
int wakewait =200; //time between wake and shutter

/////////// Further Variables ////////////

long shutter_off = 0;

int outpin = 11; //output for shutter relay from pin 11
int wakepin = 8; //output for focus relay from pin 8
int switchpin = 2; //input from button from pin 2
int potPin = 0; //where

int val; //value of button press
int buttonState; //check variable for change of button press
int on_off = 0; //state of sequence (turned on, turned off)
int potVal = 0; // Holds the value of the potentiometer
/////////// Setup ////////////

void setup() {
  pinMode(outpin, OUTPUT); //outpin gives output
  pinMode(switchpin, INPUT); //switchpin receives input
  pinMode(wakepin, OUTPUT); //wakepin gives output

  buttonState = digitalRead(switchpin); //read value of the button
}

/////////// Loop ////////////

void loop(){

  val = digitalRead(switchpin); // read button value and store it in val

  potVal = analogRead(potPin);
 
 
  if (potVal > 5) { //if the value of the pot is more than 0 use it as the "short_time"
      shutter_off = (40 * full_time / potVal) - shutter_on - wakeup - wakewait; //time to wait between shutter releases;
  } else { // else use the default value
      shutter_off = (40 * full_time / short_time) - shutter_on - wakeup - wakewait; //time to wait between shutter releases;
  }

  if (val != buttonState) { // if the button state has changed…
    if (val == LOW) { // check if the button is pressed…
      if (on_off == 0) { // if the sequence is currently off…
        on_off = 1; // turn the sequence on
        delay(shutter_wait); // wait the initial period
      } else {
        on_off = 0; // turn the sequence off
    }
  }
}

buttonState = val; //switch the button state

  if (on_off == 1) { //while the sequence is turned on…

    digitalWrite(wakepin, HIGH); //turn wakeup/focus on
    delay(wakeup); //keep focus
    digitalWrite(wakepin, LOW); //turn wakeup off
    delay(wakewait); //wait
    digitalWrite(outpin, HIGH); //press the shutter
    delay(shutter_on); //wait the shutter release time
    digitalWrite(outpin, LOW); //release shutter
    delay(shutter_off); //wait for next round
  }

}
