class Marker{
  PVector posN;
  
  int dia = 20;
  
  int scaleX;
  int scaleY;
  
  float lerpAmt = 0.2;
  
  Marker(float _x, float _y, int _scaleX, int _scaleY){
    posN = new PVector(_x,_y);
    scaleX = _scaleX;
    scaleY = _scaleY;
    
  }
  
  
  public void display(){
    noFill();
    stroke(0);
    strokeWeight(3);
    line(posN.x*scaleX,posN.y*scaleY-dia/2,posN.x*scaleX,posN.y*scaleY+dia/2);
    line(posN.x*scaleX-dia/2,posN.y*scaleY,posN.x*scaleX+dia/2,posN.y*scaleY);
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
}