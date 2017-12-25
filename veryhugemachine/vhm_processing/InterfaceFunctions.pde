
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

void toggleSampling(boolean theFlag){
  if(theFlag){
    println("Starting to sample data.");
    isSampling = true;
    lastSample = millis();
  }
  else{
    println("Stopping to sample data.");
    isSampling = false;
  }
}

void startLearn(){
  println("starting transfer of samples");
  transferSamples();
  println("finished transferring samples");
  activateLearning();
}

void save(){
  saveSamplesToFile();
}

void load(){
  loadSamplesFromFile();
}

// row 3
void startSketch(){
  switchDraw();
}

void delSketch(){
  deleteDraw();
}
