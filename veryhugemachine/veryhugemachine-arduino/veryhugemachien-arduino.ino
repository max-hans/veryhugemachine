#include <AccelStepper.h>
#include <MultiStepper.h>
#include <EEPROM.h> 

#define STEPPIN1  7
#define DIRPIN1   8

#define SENSORPIN1 3
#define SENSORPIN2 4

#define CALIBRATEPIN 2

byte state = 0;

int calibSpeed = 2500;
int calibDist = 100;

int normalSpeed = 5000;
unsigned int normalAccel = 3000;
unsigned long maxDist;

unsigned long lastPrint;
unsigned int printInterval = 200;
byte printCount = 0;

boolean invertDir = true;

int eepromAdress = 0;

AccelStepper axis1(1, STEPPIN1, DIRPIN1);

void setup() {
  pinMode(SENSORPIN1, INPUT);
  pinMode(SENSORPIN2, INPUT);
  pinMode(CALIBRATEPIN, INPUT);
  axis1.setMaxSpeed(400);
  axis1.setSpeed(400);
  axis1.setAcceleration(500);
  state = 1;
  Serial.begin(115200);
  axis1.setPinsInverted(invertDir, false, false);
  axis1.setSpeed(calibSpeed);

  maxDist = EEPROMReadlong(eepromAdress);
  Serial.println("");
  Serial.println("------------------------------------");
  Serial.println("Starting up");
  printProgress();
  if(maxDist == 0){
    Serial.println("No data found - please calibrate");
  }
  else{
    Serial.println("Data found : max distance " + String(maxDist));
  }
  Serial.println("------------------------------------");
  

  state = 0;

}

void loop() {



  switch (state) {
    case 0: {
        axis1.run();
        break;
      }
/*

    case 1: {
        if (digitalRead(SENSORPIN1)) {
          axis1.setCurrentPosition(0);
          axis1.setSpeed(-calibSpeed);
          state++;
          Serial.println("----------------------------------");
          Serial.println("Done calibrating Stop 1");
          Serial.println("----------------------------------");
          Serial.println("Setting Current Position: 0");
          Serial.println("----------------------------------");
          Serial.println("Running to other endpoint");
          Serial.println("----------------------------------");
          Serial.println();
        }
        else {
          axis1.runSpeed();
        }
        break;
      }



    case 2: {
        if (digitalRead(SENSORPIN2)) {
          maxDist = axis1.currentPosition();
          state = 0;
          resetMotorData();
          Serial.println("------------------------------------");
          Serial.println("Done calibrating Stop 2");
          Serial.println("----------------------------------");
          Serial.println("Maximum Distance: " + String(maxDist));
          Serial.println("------------------------------------");
          lastPrint = millis();
        }
        else {
          axis1.runSpeed();
        }
        break;
      }
      */

  }

  if (digitalRead(CALIBRATEPIN)) calibrate();

}




void resetMotorData() {
  axis1.setSpeed(normalSpeed);
  axis1.setAcceleration(normalAccel);
}



void calibrate() {
  
  
  Serial.println("Starting calibration process");
  Serial.println("----------------------------------");
  Serial.println("Running to first stop!");
  
  axis1.setSpeed(-normalSpeed);
  while (!digitalRead(SENSORPIN1)) {
    axis1.runSpeed();
  }

  axis1.setCurrentPosition(0);
  delay(200);

  Serial.println("----------------------------------");
  Serial.println("Done calibrating Stop 1");
  Serial.println("------------------------------------");
  Serial.println("Setting Current Position: 0");
  Serial.println("------------------------------------");
  Serial.println("Running to second stop!");
  

  axis1.setSpeed(normalSpeed);

  while (!digitalRead(SENSORPIN2)) {
    axis1.runSpeed();
  }
  maxDist = axis1.currentPosition();
  delay(200);

  Serial.println("------------------------------------");
  Serial.println("Done calibrating Stop 2");
  Serial.println("------------------------------------");
  Serial.println("Maximum Distance: " + String(maxDist));
  Serial.println("------------------------------------");
  EEPROMWritelong(eepromAdress, maxDist);
  Serial.println("Saving to EEPROM--------------------");
  printProgress();
  Serial.println("Waiting for directions--------------");
  Serial.println("------------------------------------");
  resetMotorData();
  state = 0;
}

void EEPROMWritelong(int address, long value) {
  byte four = (value & 0xFF);
  byte three = ((value >> 8) & 0xFF);
  byte two = ((value >> 16) & 0xFF);
  byte one = ((value >> 24) & 0xFF);

  EEPROM.write(address, four);
  EEPROM.write(address + 1, three);
  EEPROM.write(address + 2, two);
  EEPROM.write(address + 3, one);
}

long EEPROMReadlong(long address) {
  long four = EEPROM.read(address);
  long three = EEPROM.read(address + 1);
  long two = EEPROM.read(address + 2);
  long one = EEPROM.read(address + 3);

  return ((four << 0) & 0xFF) + ((three << 8) & 0xFFFF) + ((two << 16) & 0xFFFFFF) + ((one << 24) & 0xFFFFFFFF);
}

void printProgress(){
  
  for(int i = 0; i<33;i+=3){
    Serial.print("---");
    delay(100);
  }
  Serial.println("---");
}

