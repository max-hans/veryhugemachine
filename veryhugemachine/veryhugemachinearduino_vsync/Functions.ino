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

int scaleUp(int currPos){
  return map(currPos,0,maxDist,0,32767);
}

int scaleDown(int scalePos){
  return map(scalePos,0,32767,0,maxDist);
}


void runToZero() {
  axis1.setSpeed(-motorSpeed);
  while (!digitalRead(SENSORPIN1)) {
    axis1.runSpeed();
  }
  axis1.setCurrentPosition(0);
}
/*
void checkData() {
  receiver.sync();

  if (doCalibrate) {
    isReady = false;
    sender.sync();
    calibrate();
    isReady = true;
  }

  motorPosRaw = scaleUp(axis1.currentPosition());

  if (lastTarget != motorTarget) {
    motorTarget = lastTarget;
    axis1.moveTo(scaleDown(motorTarget));
  }

  if (lastSpeed != motorSpeed) {
    motorSpeed = lastSpeed;
    axis1.setMaxSpeed(motorSpeed);
  }

  if (axis1.distanceToGo() == 0) {
    targetReached = true;
  }
  else {
    targetReached = false;
  }

  sender.sync();
}
*/
void calibrate() {

  axis1.setSpeed(-motorSpeed);
  while (!digitalRead(SENSORPIN1)) {
    axis1.runSpeed();
  }

  axis1.setCurrentPosition(0);
  delay(200);

  axis1.setSpeed(motorSpeed);

  while (!digitalRead(SENSORPIN2)) {
    axis1.runSpeed();
  }

  maxDist = axis1.currentPosition();
  delay(200);

  EEPROMWritelong(eepromAdress, maxDist);

  resetMotorData();

}

boolean targetReached(){
  return (axis1.distanceToGo() == 0);
}



void resetMotorData() {
  axis1.setSpeed(motorSpeed);
  axis1.setAcceleration(normalAccel);
}


