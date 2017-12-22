void interfaceRemap(){
  displayCamera();
}


void displayCamera() {
  // Display camera image
  pushMatrix();
  translate(imageTransformDelta.x, imageTransformDelta.y);

  imageMode(CORNER);
  image(cam, 0, 0);

  drawCorners(0, 0, cam.width, cam.height, 18);

  // Display Markers on camera image

  for (DragPoint dP : dragPoints) {
    dP.update();
    dP.display();
  }

  drawFrame();
  popMatrix();
}
