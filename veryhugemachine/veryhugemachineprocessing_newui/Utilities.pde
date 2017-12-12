void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}


String getDateString() {
  return year() + "-" + month() + "-" + day() + "_" + hour() + "-" + minute();
}

void setupCamera(String camId) {
  try {
    cam = new Capture(this, 960, 540, camId, 30);
    if (cam == null) {
      cam = new Capture(this, 640, 480);
    }
    cam.start();
  }

  catch(NullPointerException e) {
    println("No camera attached - falling back to built-in.");
    cam = new Capture(this, 640, 480);
    cam.start();
  }
}
