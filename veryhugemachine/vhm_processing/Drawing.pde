



boolean isDrawing = false;

void deleteDraw(){
  shapePoints.clear();
}

void checkVertex(float _x, float _y){
  if(onCanvas(_x,_y)){
    shapePoints.add(new PVector(map(_x,canvasOffset,canvasSize+canvasOffset,0.0,1.0),map(_y,canvasOffset,canvasSize+canvasOffset,0.0,1.0)));
  }
}

boolean onCanvas(float _x, float _y){
  return(((_x > canvasOffset) && (_x < (canvasOffset + canvasSize))) && ((_y > canvasOffset) && (_y < (canvasOffset + canvasSize))));
}

void showDrawing(){
  if(!shapePoints.isEmpty()){
    pushMatrix();
    translate(canvasOffset,canvasOffset);

    stroke(col2);
    strokeWeight(5);

    beginShape();
    for(PVector P : shapePoints){
      vertex(P.x*canvasSize,P.y*canvasSize);
    }
    endShape();
    popMatrix();
  }
}

void switchDraw(){
  if(isDrawing){
    println("stopping drawing");
    isDrawing = false;
    }
    else{
      println("starting drawing");
      isDrawing = true;
    }
}

/*
void startDrawing(){
  shapePoints = new ArrayList<PVector>();
}
*/
