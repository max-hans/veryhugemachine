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

void transferSamples(){
  for(Sample s : samples){
    s.printData();
    wsSendSample(s);
  }
}

// method to save sampled points to a file
void saveSamplesToFile(){
  PrintWriter writer = createWriter("exports/" + getDateString() + "_data.txt");
  for(Sample s : samples){
    writer.println(s.dataToString());
    println("Exporting sample " + s.dataToString());
  }
  writer.flush();
  writer.close();
  println("Done exporting.");
}

void importSamples(File importFile){
  if (importFile == null) {
    println("Window was closed or the user hit cancel.");
  } else {

    BufferedReader reader = createReader(importFile.getAbsolutePath());
    String line = null;
    samples.clear();
    try {
        int counter = 0;
      while ((line = reader.readLine()) != null) {
        String[] pieces = split(line, ',');
        println("Importing sample " + counter + " : " + pieces[0] + " | "+ pieces[1] + " | "+ pieces[2] + " | "+ pieces[3]);
        samples.add(new Sample(float(pieces[0]),float(pieces[1]),float(pieces[2]),float(pieces[3])));
        counter++;
      }
      reader.close();
      println("Done importing. Found " + counter + " samples.");
    }
    catch (IOException e) {
        e.printStackTrace();
      }
  }
}


  void loadSamplesFromFile(){
    selectInput("Select a file to process:", "importSamples");
  }
