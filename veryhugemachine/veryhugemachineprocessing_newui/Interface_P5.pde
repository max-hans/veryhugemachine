int uiDeltaY = 60;

int fontSize = 10;

ListBox motorList;

int gridX = 150;
Textlabel motorPosLabel;

Slider motorPos;
Slider motorTgt;
Slider motorSpd;

color fga = color(25, 181, 137);
color fgi = color(255, 100);

color bga = color(25, 181, 137, 50);
color bgi = color(200, 100);

float motorPosition = 0;
float motorTarget = 0;
float motorSpeed = 0;


void createInterface() {


  int buttonWidth = 100;
  int buttonHeight = 20;

  int buttonX = 1210;

  
  
  ControlFont font = new ControlFont(p);

  cp5.setColorForeground(fga);
  cp5.setColorBackground(bga);
  cp5.setFont(font);
  cp5.setColorActive(fga);
  // create a toggle
  /*
  cp5.addToggle("showTransformed")
   .setPosition(40, 100)
   .setSize(50, 20)
   ;
   */

  coordX = cp5.addTextlabel("coordX")
    .setText("X: [0.00000]")
    .setPosition(gridWidth, 2*gridWidth + cam.height)
    .setColorValue(255)
    .setFont(font)
    ;

  coordY = cp5.addTextlabel("coordY")
    .setText("Y: [0.00000]")
    .setPosition(gridWidth + gridX*2, 2*gridWidth + cam.height)
    .setColorValue(255)
    .setFont(font)
    ;
  
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent);
  if (theEvent.isAssignableFrom(Textfield.class)) {

    //println("controlEvent: accessing a string from controller '"+theEvent.getName()+"': "+theEvent.getStringValue()
    switch(theEvent.getName()) {
    case "ip_adress":
      updateIpAdress(theEvent.getStringValue());
      break;
    }
  }
}


void updateInterface() {
  updateMarkerPos();
  //  updateMotorPos();
}


void motorReset() {
  mTemp.recalibrate();
}

void motorTarget(float val) {
  mTemp.setTarget(val/1000);
}

void motorSpeed(float val) {
  int inVal = int(val);
  mTemp.setSpeed(inVal);
}

// Interface stuff

void toggleVideo() {
  drawVideo = !drawVideo;
}

// Update functions

void updateMarkerPos() {
  markerPos = marker.getPosNormalized();
  String xT = nf(markerPos.x,1,5);
  String yT = nf(markerPos.y,1,5);
  coordX.setText("X: [" + xT + "]");
  coordY.setText("Y: [" + yT + "]");
}

void updateMotorData() {
  motorPosLabel.setText("Coord X: [" + mTemp.motorPos + "]");
}
/*
void updateMotorPos() {
 motor1Pos.setText("Motor1: [" + motor1.motorPosScaled + "]");
 motor2Pos.setText("Motor2: [" + motor2.motorPosScaled + "]");
 }
 */