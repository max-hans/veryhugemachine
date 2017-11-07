#include <AccelStepper.h>
#include <MultiStepper.h>
#include <EEPROM.h>
#include <CommandHandler.h>

#define STEPPIN1  7
#define DIRPIN1   8

#define SENSORPIN1 3
#define SENSORPIN2 4

#define CALIBRATEPIN 2

CommandHandler<> SerialCommandHandler;

byte state = 0;

int calibSpeed = 2500;
int calibDist = 100;

int normalSpeed = 8000;
unsigned int normalAccel = 3000;
unsigned long maxDist;

unsigned long lastPrint;
unsigned int printInterval = 200;
byte printCount = 0;

boolean invertDir = true;

const char commandChar = '!';

int eepromAdress = 0;

AccelStepper axis1(1, STEPPIN1, DIRPIN1);

void setup() {
  pinMode(SENSORPIN1, INPUT);
  pinMode(SENSORPIN2, INPUT);
  pinMode(CALIBRATEPIN, INPUT);
  Serial.begin(115200);
  while (Serial.available()) {
    Serial.read();
  }
  /*
  SerialCommandHandler.AddCommand(F("moveTo"), updateTarget);
  SerialCommandHandler.AddCommand(F("recalibrate"), recalibrate);
  SerialCommandHandler.AddCommand(F("getPos"), getPos);
  SerialCommandHandler.AddCommand(F("setSpeed"), setNewSpeed);
  */

  axis1.setMaxSpeed(400);
  axis1.setSpeed(400);
  axis1.setAcceleration(500);
  state = 1;

  axis1.setPinsInverted(invertDir, false, false);
  axis1.setSpeed(calibSpeed);

  maxDist = EEPROMReadlong(eepromAdress);
  Serial.println("");

  Serial.println("Starting up");
  printProgress();
  if (maxDist == 0) {
    Serial.println("No data found - please calibrate");
  }
  else {
    Serial.println("Data found : max distance " + String(maxDist));
  }
  runToZero();
  Serial.println("Waiting for directions--------------");
  state = 0;
}

void loop() {
  SerialCommandHandler.Process();
  switch (state) {
    case 0: {
        break;
      }

    case 1: {
        axis1.run();
        if (axis1.distanceToGo() == 0) {
          state = 0;
        }
        break;
      }
  }
}

void resetMotorData() {
  axis1.setSpeed(normalSpeed);
  axis1.setAcceleration(normalAccel);
}

void calibrate() {
  Serial.println("Starting calibration process");
  Serial.println("Running to first stop!");

  axis1.setSpeed(-normalSpeed);
  while (!digitalRead(SENSORPIN1)) {
    axis1.runSpeed();
  }

  axis1.setCurrentPosition(0);
  delay(200);

  Serial.println("Done calibrating Stop 1");
  Serial.println("Setting Current Position: 0");
  Serial.println("Running to second stop!");

  axis1.setSpeed(normalSpeed);

  while (!digitalRead(SENSORPIN2)) {
    axis1.runSpeed();
  }

  maxDist = axis1.currentPosition();
  delay(200);

  Serial.println("Done calibrating Stop 2");
  Serial.println("Maximum Distance: " + String(maxDist));

  EEPROMWritelong(eepromAdress, maxDist);
  Serial.println("Saving to EEPROM");
  Serial.println("Waiting for directions" + millis());

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
  long four =     EEPROM.read(address);
  long three =    EEPROM.read(address + 1);
  long two =      EEPROM.read(address + 2);
  long one =      EEPROM.read(address + 3);

  return ((four << 0) & 0xFF) + ((three << 8) & 0xFFFF) + ((two << 16) & 0xFFFFFF) + ((one << 24) & 0xFFFFFFFF);
}

void printProgress() {
  for (int i = 0; i < 33; i += 3) {
    Serial.print("---");
    delay(100);
  }
  Serial.println("---");
}

void updateTarget(CommandParameter &parameter) {
  double normalizedTarget = float(parameter.NextParameterAsInteger()) / 32767.0;
  unsigned long absoluteTarget = (int)(maxDist * normalizedTarget);
  axis1.moveTo(absoluteTarget);
  state = 1;
}


void sendState(boolean s) {
  if (s) {
    // print "!r" for ready
    Serial.println(commandChar + "r");
  }
  else {
    // print "!w" for working
    Serial.println(commandChar + "w");
  }
}

void recalibrate(CommandParameter &parameter) {
  calibrate();
}

void getPos(CommandParameter &parameter) {
  Serial.println("test");
  Serial.print(commandChar);
  Serial.println(normalizedPos(), 5);
}

void runToZero() {
  Serial.println("Running to zero");
  axis1.setSpeed(-normalSpeed);
  while (!digitalRead(SENSORPIN1)) {
    axis1.runSpeed();
  }
  axis1.setCurrentPosition(0);
  sendState(true);

}

void setNewSpeed(CommandParameter &parameter) {
  int newSpeed = parameter.NextParameterAsInteger();
  axis1.setMaxSpeed(newSpeed);
  Serial.println("Setting new speed: " + newSpeed);
}

float normalizedPos() {
  return float(axis1.currentPosition()) / float(maxDist);
}

