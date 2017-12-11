class Marker {
  PVector posN;
  PVector lastPos;

  int dia = 20;

  int scaleX;
  int scaleY;

  float lerpAmt = 0.1;

  Marker(float _x, float _y, int _scaleX, int _scaleY) {
    posN = new PVector(_x, _y);
    scaleX = _scaleX;
    scaleY = _scaleY;
  }

  public void display(int c) {
    PVector posTemp = this.getPosScaled(scaleX, scaleY);
    setLineStyle(c);
    drawMarker(posTemp.x, posTemp.y, this.dia, 5);
    drawMarker(posTemp.x, posTemp.y, 50);
    fill(255);
  }

  public void setDiameter(int _dia) {
    dia = _dia;
  }

  public void setLerpAmt(float _lerpAmt) {
    lerpAmt = _lerpAmt;
  }

  public void updatePos(PVector newPos) {
    posN.lerp(newPos, lerpAmt);
  }

  public PVector getPosNormalized() {
    return posN.copy();
  }

  public float getPosX() {
    return posN.x;
  }

  public float getPosY() {
    return posN.y;
  }

  public PVector getPosScaled(float xScale, float yScale) {
    PVector posScaled = new PVector();
    posScaled.set(posN.x*xScale, posN.y*yScale);
    return posScaled;
  }

  public float lastPosX() {
    return lastPos.x;
  }

  public float lastPosY() {
    return lastPos.y;
  }

  public void archive() {
    lastPos = posN.copy();
  }
}