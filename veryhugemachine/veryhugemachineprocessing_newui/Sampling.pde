void checkSampling(){
  if(isSampling){
    if(motorsReady()){
      saveNewSample();
      setNewTarget();
    }
    else{
      if(lastSample + sampleFreq < millis()){
        saveNewSample();
        lastSample = millis();
      }
    }
  }
}


boolean motorsReady(){
  return (motorArray[0].motorReady() && motorArray[1].motorReady());
}

void setNewTarget(){
  float t1 = random(1);
  float t2 = random(1);

  motorArray[0].setTarget(t1);
  motorArray[1].setTarget(t2);

  println("Setting new target: " + t1 + " / " + t2 + "!");
}

void saveNewSample(){
  samples.add(new Sample(marker.getNormalizedX(),marker.getNormalizedY(),motorArray[0].getMotorPos(),motorArray[1].getMotorPos()));
}

void drawSamplePoints(int _offset, int _size, boolean drawTrace){
  if(!samples.isEmpty()){
    pushMatrix();
    translate(_offset,_offset);
    if(drawTrace){
      beginShape();
      for(Sample s : samples){
        vertex(s.getX() * _size,s.getY() * _size);
      }
      endShape();
    }
    for(Sample s : samples){
      drawPoint(s.getX() * _size,s.getY() * _size);
    }
    popMatrix();
  }
}
