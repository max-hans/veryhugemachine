class DragPoint {
  int dia = 20;
  PVector pos;
  boolean isDragged = false;
  DragPoint(PVector _pos) {
    pos = _pos;
  }
  
  public void display(){
    stroke(255);
    noFill();
    strokeWeight(1);
    line(pos.x,pos.y-dia/2,pos.x,pos.y+dia/2);
    line(pos.x-dia/2,pos.y,pos.x+dia/2,pos.y);
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
    return (abs(mouseX-pos.x)<dragThresh) && (abs(mouseY-pos.y)<dragThresh);
  }
  
  public void setDiameter(int _dia){
    dia = _dia;
  }
}