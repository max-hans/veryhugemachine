void interfaceRegular(){
  drawCorners(canvasOffset, canvasOffset, canvasSize, canvasSize, 18);
  drawGrid(canvasOffset, canvasOffset, canvasSize, canvasSize, 10);
  drawSamplePoints(canvasOffset,canvasSize,true);
  showDrawing();

  cp5.draw();
}
