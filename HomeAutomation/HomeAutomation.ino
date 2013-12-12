#include "HomeAutomation.h"

#define r_1 6
#define g_1 5
#define b_1 3

#define r_2 9
#define g_2 10
#define b_2 11

void setup() {
  // put your setup code here, to run once:
  pinMode(r_1, OUTPUT);
  pinMode(g_1, OUTPUT);
  pinMode(b_1, OUTPUT);
  
  pinMode(r_2, OUTPUT);
  pinMode(g_2, OUTPUT);
  pinMode(b_2, OUTPUT);  
  
  colour c = { 255, 255, 255 };
  //set_room_colour(0, c);
  set_room_colour(1, c);
        
  Serial.begin(9600);
}

int alarmCurrent = 0;

void loop() {
  //Serial.println(analogRead(A0)); 
  int val = analogRead(A0);

  if (val <= 50 && alarmCurrent == 0) {
    // Someone has broken in
    alarmCurrent = 1;
    Serial.print("1");
  } else if (val > 50 && alarmCurrent == 1) {
    alarmCurrent = 0;
    //Serial.print("0");
  }
  
  delay(10);
  
  if (Serial.available() >= 5) {

    int room = Serial.read();
    //Serial.println(room);
    
    int red = Serial.read();
    //Serial.println(red);
    
    int green = Serial.read();
    //Serial.println(green);
    
    int blue = Serial.read();
    //Serial.println(blue);

    int brightness = Serial.read();
    //Serial.println(brightness);
    
    float b = (float)brightness / 255.0;
          
     colour c = {(float)red * b, (float)green * b, (float)blue * b};
     set_room_colour(room, c);
     
   }
   
   
}

void set_room_colour(int room, colour c) {
  if (room == 0) {
    analogWrite(r_1, c.red);
    analogWrite(g_1, c.green);
    analogWrite(b_1, c.blue);
  } else {
    analogWrite(r_2, c.red);
    analogWrite(g_2, c.green);
    analogWrite(b_2, c.blue);
  }
}

