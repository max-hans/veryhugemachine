
// row 1

void zero(){
  for(Motor m : motors){
    m.setTarget(0.0);
  }
}

void stopall(){
  for(Motor m : motors){
    m.setSpeed(0);
    }
}

void recalibrate(){
  for(Motor m : motors){
    m.recalibrate();
  }
}

void remap(){
  if(caseByte == 0){
    caseByte = 1;
    //cp5.setVisible(false);
  }
  else{
    caseByte = 0;
  }
}



// row 2

void collect(){

}

void learn(){
  // add websocket command to start learning
}

void save(){
  // add websocket command to save data
}

void load(){
  // keep?
}

// row 3
void startSketch(){
  switchDraw();
}

void delSketch(){
  deleteDraw();
}



void start(){

}
