// ====================================================================================================

/*

void startSampling() {
  if (motors.size() > 0) {
    println("Starting sampling procedure...");
    backupFile = createWriter(getDateString() + "_data.csv");
    sampleState = 1;
    lastSample = millis();
    for (Motor m : motors) {
      m.samples = new FloatList();
    }
  }
  println("No motors attached ... =(");
}

void stopSampling() {
  if (sampling) {
    println("Stopping sampling procedure...");
    println("Writing to file.");
    sampleState = 0;
    sampling = false;
    backupFile.flush();
    backupFile.close();
  }
}

void sample() {
  if (sampling) {
    for (Motor m : motors) {
      m.samplePos();
    }
    lastSample = millis();
  }
}

*/
