#include <AccelStepper.h>
#include <MultiStepper.h>
#include <EEPROM.h>
#include <VSync.h>

#define STEPPIN1  7
#define DIRPIN1   8

#define SENSORPIN1 3
#define SENSORPIN2 4

#define CALIBRATEPIN 2

//byte state = 0;
int eepromAdress = 0;

unsigned int normalAccel = 3000;
unsigned long maxDist;

AccelStepper axis1(1, STEPPIN1, DIRPIN1);

ValueSender<2> sender;
ValueReceiver<3> receiver;

// Position values are stored in range between 0 and 32767 and scaled accordingly

int motorPosRaw = 0;
int motorTargetRaw = 0;
int lastTargetRaw = 0;


int motorSpeed = 0;
int lastMotorSpeed = 0;

int doCalibrate = 0;
int motorReady = 0;


// parameters for position update
unsigned int posUpdateFreq = 200;
unsigned int lastPosUpdate;

void setup() {
  pinMode(SENSORPIN1, INPUT);
  pinMode(SENSORPIN2, INPUT);
  pinMode(CALIBRATEPIN, INPUT);
  Serial.begin(115200);

  sender.observe(motorPosRaw);
  sender.observe(motorReady);

  receiver.observe(motorSpeed);
  receiver.observe(motorTargetRaw);

  axis1.setMaxSpeed(motorSpeed);
  axis1.setSpeed(motorSpeed);
  axis1.setAcceleration(1000);

  axis1.setSpeed(motorSpeed);

  maxDist = EEPROMReadlong(eepromAdress);

  runToZero();
  lastPosUpdate = millis();

}

void loop() {
  handleData();
  if (!targetReached()) {
    axis1.run();
  }
}




void handleData() {
  receiver.sync();
  // update new motor target if necessary
  if (lastTargetRaw != motorTargetRaw) {
    motorTargetRaw = lastTargetRaw;
    updateTarget();
  }

  // update motor speed if necessary
  if (lastMotorSpeed != motorSpeed) {
    lastMotorSpeed = motorSpeed;
    axis1.setMaxSpeed(motorSpeed);
  }

  if(doCalibrate == 0){
    motorReady = 0;
    sender.sync();
    calibrate();
    motorReady = 1;
  }
  
  // update position value in fixed frequency
  if(millis() > lastPosUpdate + posUpdateFreq){
    updatePos();
    lastPosUpdate = millis();
  }
  
  sender.sync();
}




void updateTarget() {
  axis1.moveTo(scaleDown(motorTargetRaw));
}

void updatePos() {
  motorPosRaw = scaleUp(axis1.currentPosition());
}

