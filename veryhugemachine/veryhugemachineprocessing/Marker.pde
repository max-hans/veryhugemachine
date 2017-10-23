class Marker{
  PVector posN;
  
  int dia = 20;
  
  int scaleX;
  int scaleY;
  
  float lerpAmt = 0.1;
  
  Marker(float _x, float _y, int _scaleX, int _scaleY){
    posN = new PVector(_x,_y);
    scaleX = _scaleX;
    scaleY = _scaleY;
    
  }
  
  
  public void display(){
    
    
    PVector posTemp = this.getPosScaled(scaleX,scaleY);
    setLineStyle(0);
    drawMarker(posTemp.x,posTemp.y,this.dia,5);
  }
  
  public void setDiameter(int _dia){
    dia = _dia;
  }
  
  public void setLerpAmt(float _lerpAmt){
    lerpAmt = _lerpAmt;
  }
  
  public void updatePos(PVector newPos){
    posN.lerp(newPos,lerpAmt);
}

  public PVector getPosNormalized(){
    return posN.copy();
  }
  
  public PVector getPosScaled(float xScale, float yScale){
    PVector posScaled = new PVector();
    posScaled.set(posN.x*xScale,posN.y*yScale);
    return posScaled;
  }
}

void updateMarkerPos(){
  markerPos = marker.getPosNormalized();
  coordX.setText("Coord X: [" + markerPos.x + "]");
  coordY.setText("Coord Y: [" + markerPos.y + "]");
}