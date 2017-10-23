void createInterface() {
  color fg = color(25, 181, 137);
  color bg = color(25, 181, 137, 50);

  PFont p = createFont("Roboto Mono", 10); 
  ControlFont font = new ControlFont(p);

  cp5.setColorForeground(fg);
  cp5.setColorBackground(bg);
  cp5.setFont(font);
  cp5.setColorActive(fg);
  // create a toggle
  cp5.addToggle("showTransformed")
    .setPosition(40, 100)
    .setSize(50, 20)
    ;


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
}


void updateInterface() {
  
}



/*
void toggle(boolean theFlag) {
 if(theFlag==true) {
 col = color(255);
 } else {
 col = color(100);
 }
 println("a toggle event.");
 }
 */