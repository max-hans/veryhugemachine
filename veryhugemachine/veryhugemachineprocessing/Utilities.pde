void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}


String getDateString(){
  return year() + "-" + month() + "-" + day() + "_" + hour() + "-" + minute();
}