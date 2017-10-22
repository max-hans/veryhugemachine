void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}