

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


