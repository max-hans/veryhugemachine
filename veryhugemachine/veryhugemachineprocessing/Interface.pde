class DragPoint {
  int dia = 20;
  PVector pos;
  boolean isDragged = false;
  DragPoint(PVector _pos) {
    pos = _pos;
  }

  public void display() {
    setLineStyle();
    drawMarker(this.pos.x, this.pos.y, this.dia, 5);
  }

  public void update() {
    if (isDragged) {
      pos.x += (mouseX-pmouseX);
      pos.y += (mouseY-pmouseY);
      println(pos.x + ", " + pos.y);
    }
  }

  public void checkDrag() {
    if (mouseOver()) {
      isDragged = true;
      println("drag");
    } else {
      isDragged = false;
    }
  }

  private boolean mouseOver() {
    PVector posTemp = this.getTransformedCoords();
    return (abs(mouseX-posTemp.x)<dragThresh) && (abs(mouseY-posTemp.y)<dragThresh);
  }

  public void setDiameter(int _dia) {
    dia = _dia;
  }

  PVector getTransformedCoords() {
    return new PVector(pos.x+imageTransformDelta.x, pos.y+imageTransformDelta.y);
  }
}


void drawMarker(float _x, float _y, int dia) {
  setLineStyle();
  pushMatrix();
  translate(_x, _y);
  line(0, -dia/2, 0, dia/2);
  line(-dia/2, 0, dia/2, 0);
  ellipse(0, 0, dia, dia);
  popMatrix();
}

void drawMarker(float _x, float _y, int dia, int ellipseOff, int lineOff) {
  setLineStyle();
  pushMatrix();
  translate(_x, _y);
  line(0, lineOff, 0, dia/2);
  line(0, -lineOff, 0, -dia/2);
  line(lineOff, 0, dia/2, 0);
  line(-lineOff, 0, -dia/2, 0);


  ellipse(0, 0, dia+ellipseOff, dia+ellipseOff);
  popMatrix();
}

void drawMarker(float _x, float _y, int dia, int lineOff) {
  pushMatrix();
  translate(_x, _y);
  line(0, lineOff, 0, dia/2);
  line(0, -lineOff, 0, -dia/2);
  line(lineOff, 0, dia/2, 0);
  line(-lineOff, 0, -dia/2, 0);

  popMatrix();
}

void drawMarkerEllipse(float _x, float _y, int dia, int ellipseOff) {
  pushMatrix();
  translate(_x, _y);
  line(0, 0, 0, dia/2);
  line(0, 0, 0, -dia/2);
  line(0, 0, dia/2, 0);
  line(0, 0, -dia/2, 0);


  ellipse(0, 0, dia+ellipseOff, dia+ellipseOff);
  popMatrix();
}

void drawFrame() {
  setFillStyle();
  beginShape();
  vertex(0,0);
  vertex(cam.width,0);
  vertex(cam.width, cam.height);
  vertex(0,cam.height);
  
  beginContour();
  for (DragPoint dP : dragPoints) {

    //dP.display();
    vertex(dP.pos.x, dP.pos.y);
  }
  endContour();
  endShape(CLOSE);
}

void drawCorners(float posX, float posY, float _width, float _height, int size) {
  setLineStyle();
  pushMatrix();
  translate(posX, posY);

  drawCorner(0, 0, -size, -size);
  drawCorner(0, _height, -size, size);
  drawCorner(_width, _height, size, size);
  drawCorner(_width, 0, size, -size);

  popMatrix();
}

void drawCorner(int size) {
  setLineStyle();
  beginShape();
  vertex(0, -size);
  vertex(0, 0);
  vertex(-size, 0);
  endShape();
}

void drawCorner(float x, float y, int sizeX, int sizeY) {
  line(x, y, x+sizeX, y);
  line(x, y, x, y+sizeY);
}

void setLineStyle() {
  stroke(255);
  strokeWeight(1);
  noFill();
}

void setLineStyle(int c) {
  stroke(c);
  strokeWeight(1);
  noFill();
}

void setFillStyle() {
  noStroke();
  fill(255, 50);
}