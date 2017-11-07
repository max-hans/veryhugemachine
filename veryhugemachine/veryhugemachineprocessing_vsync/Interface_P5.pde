int uiDeltaY = 60;

void createInterface() {
  color fg = color(25, 181, 137);
  color bg = color(25, 181, 137, 50);

  int buttonWidth = 100;
  int buttonHeight = 20;

  int buttonX = 1210;

  PFont p = createFont("Roboto Mono", 10); 
  ControlFont font = new ControlFont(p);

  cp5.setColorForeground(fg);
  cp5.setColorBackground(bg);
  cp5.setFont(font);
  cp5.setColorActive(fg);
  // create a toggle
  /*
  cp5.addToggle("showTransformed")
   .setPosition(40, 100)
   .setSize(50, 20)
   ;
   */

  coordX = cp5.addTextlabel("coordX")
    .setText("Coord X: [0.00000]")
    .setPosition(100, 50)
    .setColorValue(255)
    .setFont(font)
    ;

  coordY = cp5.addTextlabel("coordY")
    .setText("Coord Y: [0.00000]")
    .setPosition(300, 50)
    .setColorValue(255)
    .setFont(font)
    ;

  motor1Pos = cp5.addTextlabel("motor1 pos")
    .setText("Motor1: [0.00000]")
    .setPosition(100, 50 + 20)
    .setColorValue(255)
    .setFont(font)
    ;

  motor2Pos = cp5.addTextlabel("motor2 pos")
    .setText("Motor2: [0.00000]")
    .setPosition(300, 50 + 20)
    .setColorValue(255)
    .setFont(font)
    ;


  cp5.addBang("motor1reset")
    .setPosition(buttonX, 50 + uiDeltaY*1)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("motor1reset")
    ;

  cp5.addBang("motor2reset")
    .setPosition(buttonX, 50 + uiDeltaY*2)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("motor2reset")
    ;

  cp5.addBang("motor1requestPos")
    .setPosition(buttonX, 50 + uiDeltaY*3)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("motor1requestPos")
    ;

  cp5.addBang("motor2requestPos")
    .setPosition(buttonX, 50 + uiDeltaY*4)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("motor2requestPos")
    ;

  cp5.addTextfield("ip_adress")
    .setPosition(buttonX, 50 + uiDeltaY*5)
    .setSize(buttonWidth, buttonHeight)
    .setFont(font)
    .setAutoClear(false)
    ;

  cp5.addTextfield("motor1Speed")
    .setPosition(buttonX, 50 + uiDeltaY*10)
    .setSize(buttonWidth, buttonHeight)
    .setFont(font)
    .setAutoClear(false)
    ;

  cp5.addTextfield("motor2Speed")
    .setPosition(buttonX, 50 + uiDeltaY*11)
    .setSize(buttonWidth, buttonHeight)
    .setFont(font)
    .setAutoClear(false)
    ;

  cp5.addBang("connect_to_server")
    .setPosition(buttonX, 50 + uiDeltaY*6)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("connectToServer")
    ;

  cp5.addBang("toggleVideo")
    .setPosition(buttonX, 50 + uiDeltaY*7)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("toggleVideo")
    ;

  cp5.addBang("startSampling")
    .setPosition(buttonX, 50 + uiDeltaY*8)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("start Sampling")
    ;

  cp5.addBang("stopSampling")
    .setPosition(buttonX, 50 + uiDeltaY*9)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("stop Sampling")
    ;

  cp5.addSlider("motor1target")
    .setPosition(buttonX, 50 + uiDeltaY*12)
    .setSize(buttonWidth, buttonHeight)
    .setRange(0, 1000)
    .setValue(0)
    ;

  cp5.addSlider("motor2target")
    .setPosition(buttonX, 50 + uiDeltaY*13)
    .setSize(buttonWidth, buttonHeight)
    .setRange(0, 1000)
    .setValue(0)
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

    case "writespeed1":
      motor1.setNewSpeed(Integer.parseInt(theEvent.getStringValue()));

    case "writespeed2":
      motor2.setNewSpeed(Integer.parseInt(theEvent.getStringValue()));
    }
  }
}


void updateInterface() {
  updateMarkerPos();
  updateMotorPos();
}


void motor1reset() {
  motor1.recalibrate();
}

void motor2reset() {
  motor2.recalibrate();
}

void toggleVideo() {
  drawVideo = !drawVideo;
}

void motor1target(int val){
  motor1.updateTarget(val/1000);
}

void motor2target(int val){
  motor2.updateTarget(val/1000);
}

// Update functions

void updateMarkerPos() {
  markerPos = marker.getPosNormalized();
  coordX.setText("Coord X: [" + markerPos.x + "]");
  coordY.setText("Coord Y: [" + markerPos.y + "]");
}

void updateMotorPos() {
  motor1Pos.setText("Motor1: [" + motor1.motorPosScaled + "]");
  motor2Pos.setText("Motor2: [" + motor2.motorPosScaled + "]");
}