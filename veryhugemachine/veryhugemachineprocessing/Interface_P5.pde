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
    .setPosition(200, 50)
    .setColorValue(255)
    .setFont(font)
    ;

  cp5.addButton("motor1reset")
    .setValue(0)
    .setPosition(buttonX, 50 + 30*1)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addButton("motor2reset")
    .setValue(0)
    .setPosition(buttonX, 50 + 30*2)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addButton("motor1requestPos")
    .setValue(0)
    .setPosition(buttonX, 50 + 30*3)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addButton("motor2requestPos")
    .setValue(0)
    .setPosition(buttonX, 50 + 30*4)
    .setSize(buttonWidth, buttonHeight)
    ;
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}

void updateInterface() {
}


void motor1reset(int theValue) {
  motor1.recalibrate();
}

void motor2reset(int theValue) {
  motor2.recalibrate();
}

void motor1requestPos(int theValue) {
  motor1.requestPos();
}

void motor2requestPos(int theValue) {
  motor2.requestPos();
}