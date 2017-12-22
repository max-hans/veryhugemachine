int uiDeltaY = 60;

int fontSize = 12;

ListBox motorList;


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
int leftBorderUI = 1140;

int gridY = 70;
int gridX = 150;
int buttonGridX = 150;

int buttonWidth = 130;
int buttonHeight = 15;
int buttonOffsetY = 100;

int offsetY = 200;

void createInterface() {

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  remapControl = new ControlP5(this);

  ControlFont font = new ControlFont(p);

  cp5.setColorForeground(fga);
  cp5.setColorBackground(bga);
  cp5.setFont(font);
  cp5.setColorActive(fga);

  remapControl.setColorForeground(fga);
  remapControl.setColorBackground(bga);
  remapControl.setFont(font);
  remapControl.setColorActive(fga);

  // first row

  cp5.addBang("zero")
    .setPosition(leftBorderUI + buttonGridX * 0, buttonOffsetY + gridY * 0)
    .setColorValue(255)
    .setLabel("zero all")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("stopall")
    .setPosition(leftBorderUI + buttonGridX * 1, buttonOffsetY + gridY * 0)
    .setColorValue(255)
    .setLabel("stop all")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  remapControl.addBang("remap")
    .setPosition(leftBorderUI + buttonGridX * 3, buttonOffsetY + gridY * 0)
    .setColorValue(255)
    .setLabel("remap")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  // second row

  cp5.addToggle("toggleSampling")
    .setPosition(leftBorderUI + buttonGridX * 0, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("sample")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("learn")
    .setPosition(leftBorderUI + buttonGridX * 1, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("learn")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("save")
    .setPosition(leftBorderUI + buttonGridX * 2, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("save")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("load")
    .setPosition(leftBorderUI + buttonGridX * 3, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("load")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

// row 3

cp5.addBang("startSketch")
  .setPosition(leftBorderUI + buttonGridX * 0, buttonOffsetY + gridY * 2)
  .setColorValue(255)
  .setLabel("startSketch")
  .setFont(p)
  .setSize(buttonWidth, buttonHeight)
  ;

  cp5.addBang("delSketch")
    .setPosition(leftBorderUI + buttonGridX * 1, buttonOffsetY + gridY * 2)
    .setColorValue(255)
    .setLabel("del sketch")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;


  cp5.addBang("startDraw")
    .setPosition(leftBorderUI + buttonGridX * 2, buttonOffsetY + gridY * 2)
    .setColorValue(255)
    .setLabel("start")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("stopDraw")
    .setPosition(leftBorderUI + buttonGridX * 3, buttonOffsetY + gridY * 2)
    .setColorValue(255)
    .setLabel("start")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
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


// Interface stuff

void toggleVideo() {
  drawVideo = !drawVideo;
}

// Update functions

// void updateMarkerPos() {
//   markerPos = marker.getPosNormalized();
//   String xT = nf(markerPos.x,1,5);
//   String yT = nf(markerPos.y,1,5);
//   coordX.setText("X: [" + xT + "]");
//   coordY.setText("Y: [" + yT + "]");
// }


/*
void updateMotorPos() {
 motor1Pos.setText("Motor1: [" + motor1.motorPosScaled + "]");
 motor2Pos.setText("Motor2: [" + motor2.motorPosScaled + "]");
 }
 */
