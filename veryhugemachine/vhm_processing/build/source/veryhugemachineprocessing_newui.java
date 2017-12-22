import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gab.opencv.*; 
import org.opencv.imgproc.Imgproc; 
import org.opencv.core.MatOfPoint2f; 
import org.opencv.core.Point; 
import org.opencv.core.Size; 
import org.opencv.core.Mat; 
import org.opencv.core.CvType; 
import controlP5.*; 
import processing.serial.*; 
import websockets.*; 
import mqtt.*; 
import processing.video.*; 
import blobDetection.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class veryhugemachineprocessing_newui extends PApplet {

//
// OpenCV







OpenCV opencv;

// UI Colors

int darkblue = color(26, 26, 30);
int white = color(255, 255, 255);
int col1 = color(255, 33, 81);
int col2 = color(27, 198, 180);

// UI

ControlP5 cp5;
ControlP5 remapControl;


Textlabel coordX;
Textlabel coordY;
Textlabel motor1Pos;
Textlabel motor2Pos;
Slider abc;

int canvasOffset = 122;
int canvasSize = 836;

PrintWriter backupFile;

Slider motor1target;
Slider motor2target;

float motor1posval = 0.0f;
float motor2posval = 0.0f;

int transformOffset = 20;

int dragThresh = 10;
boolean mouseLocked = false;
int cornerSize = 10;


Motor Motor0, Motor1;
ArrayList<Motor> motors;

Motor[] motorArray = new Motor[2];


// sampling




// Communication


// Websocket

WebsocketClient wsc;

// MQTT

MQTTClient client;

PFont p; // regular font
PFont pb; // bold font

// Tracking

Capture cam;
boolean newFrame=false;


BlobDetection theBlobDetection;
float blobThreshDelta = 0.001f;
float detectionThreshold = 0.3f;

PImage img;
PImage warpedCanvas;

PVector markerPos;
PVector newPos;

Marker marker;

ArrayList<PVector> transformPoints = new ArrayList<PVector>();
ArrayList<DragPoint> dragPoints = new ArrayList<DragPoint>();

PVector imageTransformDelta;

float[] motorPositions = new float[2];
boolean[] motorUpdated = {false, false};

int sampleFreq = 1000;
int lastSample;
boolean isSampling = false;
int sampleState = 0;

ArrayList<Sample> samples = new ArrayList<Sample>();

boolean sampling = false;

// ====================================================================================================

int state = 0;

String wsAdress = "ws://127.0.0.1";
int wsPort = 8080;
//String mqttAdress = "mqtt://192.168.2.101";
String mqttAdress = "mqtt://127.0.0.1";
int mqttPort = 1883;

String trackingChannel = "track";
String requestChannel = "rq";

ArrayList<PVector> shapePoints;

// UI constants

boolean drawVideo = false;
int gridWidth = 20;

int borderY = 340;

int barHeight = 15;
int barWidth = 580;

int caseByte = 0;
boolean motorsOnline = true;

// ====================================================================================================

public void setup() {

  
  background(darkblue);
  p = createFont("Roboto Mono 700", fontSize);
  pb = createFont("Roboto Mono", fontSize);

  cp5 = new ControlP5(this);
  setupCamera("USB 2.0 Camera");

  motors = new ArrayList<Motor>();

  setupMQTTglobal();

  createInterface();
  shapePoints = new ArrayList<PVector>();

  Motor0 = new Motor(0);
  Motor1 = new Motor(1);

  motorArray[0] = new Motor(0);
  motorArray[1] = new Motor(1);

  motorsOnline = true;

  printArray(motorArray);

  // Start camera interface

  imageTransformDelta = new PVector(122, 122);

  opencv = new OpenCV(this, cam);
  img = new PImage(canvasSize/2, canvasSize/2);

  // Start computer vision stuff

  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(detectionThreshold);

  markerPos = new PVector(0, 0);
  warpedCanvas = new PImage(canvasSize, canvasSize);

  resetTransformArray(cam);

  for (PVector P : transformPoints) {
    dragPoints.add(new DragPoint(P));
  }

  marker = new Marker(0.5f, 0.5f, canvasSize, canvasSize);
}

// ====================================================================================================

public void draw()
{
  background(darkblue);
  switch(caseByte) {
  case 0:
    {
      checkFrames();
      interfaceRegular();
      displayWarped();
      checkSampling();
      break;
    }
  case 1:
    {
      interfaceRemap();
      break;
    }
  }
}
public PVector getMarkerPosition() {
  Blob b;
  int record = 0;
  int index = 0;
  int blobCount = theBlobDetection.getBlobNb();
  if (blobCount == 0) {
    calibrateDetection();
    blobCount = theBlobDetection.getBlobNb();
  }
  if (blobCount>0) {
    for (int n=0; n<blobCount; n++) {
      b = theBlobDetection.getBlob(n);
      if (b.getEdgeNb()>record) {
        index = n;
        record = b.getEdgeNb();
      }
    }
    b = theBlobDetection.getBlob(index);
    int edgeCount = b.getEdgeNb();
    float edgePoints[][] = new float[2][edgeCount];
    for (int i = 0; i<edgeCount; i++) {
      edgePoints[0][i] = b.getEdgeVertexA(i).x;
      edgePoints[1][i] = b.getEdgeVertexA(i).y;
    }
    PVector p = getAverage(edgeCount, edgePoints);

    return p;
  } else {
    return new PVector(0, 0);
  }
}

// ====================================================================================================

public PVector getAverage(int coordCount, float incoordinates[][]) {
  float xAv = 0.0f;
  float yAv = 0.0f;
  for (int i = 0; i<coordCount; i++) {
    xAv += incoordinates[0][i];
    yAv += incoordinates[1][i];
  }
  xAv /= coordCount;
  yAv /= coordCount;
  return new PVector(xAv, yAv);
}

// ====================================================================================================

public void calibrateDetection() {
  detectionThreshold = 0.5f;
  theBlobDetection.setThreshold(detectionThreshold);
  int count;
  do {
    count = updateBlobCount();
    detectionThreshold -= 0.001f;
    theBlobDetection.setThreshold(detectionThreshold);
    //println(count);
    //println(detectionThreshold);
  } while (count > 1 && detectionThreshold > 0);
}

// ====================================================================================================

public int updateBlobCount() {
  img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);
  img.filter(INVERT);
  fastblur(img, 2);
  theBlobDetection.computeBlobs(img.pixels);
  return theBlobDetection.getBlobNb();
}

// ====================================================================================================

public void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      //println(frameCount + ": " + b.getEdgeNb());

      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0, 255, 0);
        for (int m=0; m<b.getEdgeNb(); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }
    }
  }
}

// ====================================================================================================

// Super Fast Blur v1.1
// by Mario Klingemann 

public void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0; i<256*div; i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0; y<h; y++) {
    rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0; x<w; x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0; y<h; y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}




boolean isDrawing = false;

public void deleteDraw(){
  shapePoints.clear();
}

public void checkVertex(float _x, float _y){
  if(onCanvas(_x,_y)){
    shapePoints.add(new PVector(map(_x,canvasOffset,canvasSize+canvasOffset,0.0f,1.0f),map(_y,canvasOffset,canvasSize+canvasOffset,0.0f,1.0f)));
  }
}

public boolean onCanvas(float _x, float _y){
  return(((_x > canvasOffset) && (_x < (canvasOffset + canvasSize))) && ((_y > canvasOffset) && (_y < (canvasOffset + canvasSize))));
}

public void showDrawing(){
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

public void switchDraw(){
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
class DragPoint {
  int dia = 20;
  PVector pos;
  boolean isDragged = false;
  DragPoint(PVector _pos) {
    pos = _pos;
  }

  public void display() {
    setLineStyle();
    drawMarker(this.pos.x, this.pos.y, 50);
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

  public PVector getTransformedCoords() {
    return new PVector(pos.x+imageTransformDelta.x, pos.y+imageTransformDelta.y);
  }
}


public void drawMarker(float _x, float _y, int dia) {
  stroke(white);
  fill(darkblue);
  strokeWeight(1);

  pushMatrix();
  translate(_x, _y);

  line(0, -dia/2, 0, dia/2);
  line(-dia/2, 0, dia/2, 0);
  rect(-10, -10, 20, 20);
  drawCross(0, 0);

  popMatrix();
}

public void drawMarker(float _x, float _y, int dia, int ellipseOff, int lineOff) {
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

public void drawMarker(float _x, float _y, int dia, int lineOff) {
  pushMatrix();
  translate(_x, _y);
  line(0, lineOff, 0, dia/2);
  line(0, -lineOff, 0, -dia/2);
  line(lineOff, 0, dia/2, 0);
  line(-lineOff, 0, -dia/2, 0);

  popMatrix();
}

public void drawNode(float x, float y, int s) {
  stroke(white);
  strokeWeight(255);
  fill(col2);
  rect(x-s/2, y-s/2, s, s);
}

public void drawFrame() {
  setFillStyle();
  beginShape();
  vertex(0, 0);
  vertex(cam.width, 0);
  vertex(cam.width, cam.height);
  vertex(0, cam.height);

  beginContour();
  for (DragPoint dP : dragPoints) {
    //dP.display();
    vertex(dP.pos.x, dP.pos.y);
  }
  endContour();
  endShape(CLOSE);
}

public void drawCorners(float posX, float posY, float _width, float _height, int size) {
  setLineStyle();
  pushMatrix();
  translate(posX, posY);

  drawCorner(0, 0, -size, -size);
  drawCorner(0, _height, -size, size);
  drawCorner(_width, _height, size, size);
  drawCorner(_width, 0, size, -size);

  popMatrix();
}

public void drawCorner(int size) {
  setLineStyle();
  beginShape();
  vertex(0, -size);
  vertex(0, 0);
  vertex(-size, 0);
  endShape();
}

public void drawCorner(float x, float y, int sizeX, int sizeY) {
  line(x, y, x+sizeX, y);
  line(x, y, x, y+sizeY);
}

public void setLineStyle() {
  stroke(255);
  strokeWeight(1);
  noFill();
}

public void setLineStyle(int c) {
  stroke(c);
  strokeWeight(1);
  noFill();
}

public void setFillStyle() {
  noStroke();
  fill(255, 50);
}

public void drawCrossHair(PVector targetN, int frameWidth, int frameHeight, int offset) {
  setLineStyle();
  float targetX = targetN.x * frameWidth;
  float targetY = targetN.y * frameHeight;

  line(targetX, 0, targetX, targetY-offset);
  line(targetX, targetY + offset, targetX, frameHeight);

  line(0, targetY, targetX-offset, targetY);
  line(targetX + offset, targetY, frameWidth, targetY);
}




public void displayWarped() {
  // Display warped image
  pushMatrix();
  translate(imageTransformDelta.x, imageTransformDelta.y);
  if (drawVideo) {
    image(warpedCanvas, 0, 0);
    marker.display(0);
  } else {
    drawCrossHair(marker.posN, warpedCanvas.width, warpedCanvas.height, 20);
    marker.display(255);
  }


  drawCorners(0, 0, warpedCanvas.width, warpedCanvas.height, cornerSize);

  popMatrix();
}

public void checkFrames() {
  if (newFrame)
  {
    newFrame=false;

    opencv.loadImage(cam);
    warpImg(warpedCanvas, canvasSize, transformPoints);

    img.copy(warpedCanvas, 0, 0, canvasSize, canvasSize, 0, 0, img.width, img.height);
    img.filter(INVERT);

    fastblur(img, 2);
    theBlobDetection.computeBlobs(img.pixels);
    int blobCount = theBlobDetection.getBlobNb();
    if (mouseLocked) {
      if (blobCount > 2) {
        detectionThreshold -= blobThreshDelta;
        theBlobDetection.setThreshold(detectionThreshold);
      } else if (blobCount == 0) {
        detectionThreshold += (3*blobThreshDelta);
        theBlobDetection.setThreshold(detectionThreshold);
      }
    }
    marker.updatePos(getMarkerPosition());
  }
}

public void mousePressed() {
  if (!mouseLocked) {
    mouseLocked = true;
    for (DragPoint DP : dragPoints) {
      DP.checkDrag();
    }
  }
}

public void mouseClicked(){
  if(isDrawing){
    checkVertex(mouseX, mouseY);
  }
}

public void mouseReleased() {
  for (DragPoint DP : dragPoints) {
    DP.isDragged = false;
  }
  mouseLocked = false;
}

public void keyPressed() {
  motors.clear();
  //if (key == 'm')sendPos();
  //if (key == 'l')activateLearning();
}

public void drawCross(float x, float y) {
  stroke(white);
  strokeWeight(1);
  line(x-2, y-2, x+2, y+2);
  line(x-2, y+2, x+2, y-2);
}

public void drawCorners(float x, float y, float w, float h, float s) {
  beginShape();
  vertex(x, y-s);
  vertex(x, y);
  vertex(x-s, y);
  endShape();

  beginShape();
  vertex(x+w, y-s);
  vertex(x+w, y);
  vertex(x+w+s, y);
  endShape();

  beginShape();
  vertex(x+w+s, y+h);
  vertex(x+w, y+h);
  vertex(x+w, y+h+s);
  endShape();

  beginShape();
  vertex(x, y+h+s);
  vertex(x, y+h);
  vertex(x-s, y+h);
  endShape();
}

public void drawGrid(float x, float y, float w, float h, float count) {
  float delta = w / count;
  for (float i = 1; i< count; i++) {
    for ( float j = 1; j<count; j++) {
      drawCross(x + (delta * i), y + (delta * j));
    }
  }
}

public void drawPoint(float _x, float _y){
  stroke(white);
  strokeWeight(2);
  point(_x,_y);
}

// row 1

public void zero(){
  for(Motor m : motors){
    m.setTarget(0.0f);
  }
}

public void stopall(){
  for(Motor m : motors){
    m.setSpeed(0);
    }
}

public void recalibrate(){
  for(Motor m : motors){
    m.recalibrate();
  }
}

public void remap(){
  if(caseByte == 0){
    caseByte = 1;
    //cp5.setVisible(false);
  }
  else{
    caseByte = 0;
  }
}




// row 2



public void toggleSampling(boolean theFlag){
  if(theFlag){
    println("Starting to sample data.");
    isSampling = true;
    lastSample = millis();
  }
  else{
    println("Stopping to sample data.");
    isSampling = false;
  }
}

public void learn(){
  
  // add websocket command to start learning
}

public void save(){
  // add websocket command to save data
}

public void load(){
  // keep?
}

// row 3
public void startSketch(){
  switchDraw();
}

public void delSketch(){
  deleteDraw();
}



public void startLearn(){

}
public void interfaceRegular(){
  drawCorners(canvasOffset, canvasOffset, canvasSize, canvasSize, 18);
  drawGrid(canvasOffset, canvasOffset, canvasSize, canvasSize, 10);
  drawSamplePoints(canvasOffset,canvasSize,true);
  showDrawing();

  cp5.draw();
}
public void interfaceRemap(){
  displayCamera();
}


public void displayCamera() {
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
int uiDeltaY = 60;

int fontSize = 12;

ListBox motorList;


Textlabel motorPosLabel;

Slider motorPos;
Slider motorTgt;
Slider motorSpd;

int fga = color(25, 181, 137);
int fgi = color(255, 100);

int bga = color(25, 181, 137, 50);
int bgi = color(200, 100);

float motorPosition = 0;
float motorTarget = 0;
float motorSpeed = 0;
int leftBorderUI = 1140;

int gridY = 70;
int gridX = 150;
int buttonGridX = 150;

int buttonWidth = 130;
int buttonHeight = 15;
int buttonOffsetY = 100;

int offsetY = 200;

public void createInterface() {

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  remapControl = new ControlP5(this);

  ControlFont font = new ControlFont(p);

  cp5.setColorForeground(fga);
  cp5.setColorBackground(bga);
  cp5.setFont(font);
  cp5.setColorActive(fga);

  remapControl.setColorForeground(fga);
  remapControl.setColorBackground(bga);
  remapControl.setFont(font);
  remapControl.setColorActive(fga);

  // first row

  cp5.addBang("zero")
    .setPosition(leftBorderUI + buttonGridX * 0, buttonOffsetY + gridY * 0)
    .setColorValue(255)
    .setLabel("zero all")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("stopall")
    .setPosition(leftBorderUI + buttonGridX * 1, buttonOffsetY + gridY * 0)
    .setColorValue(255)
    .setLabel("stop all")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  remapControl.addBang("remap")
    .setPosition(leftBorderUI + buttonGridX * 3, buttonOffsetY + gridY * 0)
    .setColorValue(255)
    .setLabel("remap")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  // second row

  cp5.addToggle("toggleSampling")
    .setPosition(leftBorderUI + buttonGridX * 0, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("sample")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("learn")
    .setPosition(leftBorderUI + buttonGridX * 1, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("learn")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("save")
    .setPosition(leftBorderUI + buttonGridX * 2, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("save")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("load")
    .setPosition(leftBorderUI + buttonGridX * 3, buttonOffsetY + gridY * 1)
    .setColorValue(255)
    .setLabel("load")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

// row 3

cp5.addBang("startSketch")
  .setPosition(leftBorderUI + buttonGridX * 0, buttonOffsetY + gridY * 2)
  .setColorValue(255)
  .setLabel("startSketch")
  .setFont(p)
  .setSize(buttonWidth, buttonHeight)
  ;

  cp5.addBang("delSketch")
    .setPosition(leftBorderUI + buttonGridX * 1, buttonOffsetY + gridY * 2)
    .setColorValue(255)
    .setLabel("del sketch")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;


  cp5.addBang("startDraw")
    .setPosition(leftBorderUI + buttonGridX * 2, buttonOffsetY + gridY * 2)
    .setColorValue(255)
    .setLabel("start")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;

  cp5.addBang("stopDraw")
    .setPosition(leftBorderUI + buttonGridX * 3, buttonOffsetY + gridY * 2)
    .setColorValue(255)
    .setLabel("start")
    .setFont(p)
    .setSize(buttonWidth, buttonHeight)
    ;
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent);
  if (theEvent.isAssignableFrom(Textfield.class)) {

    //println("controlEvent: accessing a string from controller '"+theEvent.getName()+"': "+theEvent.getStringValue()
    switch(theEvent.getName()) {
    case "ip_adress":
      updateIpAdress(theEvent.getStringValue());
      break;
    }
  }
}


// Interface stuff

public void toggleVideo() {
  drawVideo = !drawVideo;
}

// Update functions

// void updateMarkerPos() {
//   markerPos = marker.getPosNormalized();
//   String xT = nf(markerPos.x,1,5);
//   String yT = nf(markerPos.y,1,5);
//   coordX.setText("X: [" + xT + "]");
//   coordY.setText("Y: [" + yT + "]");
// }


/*
void updateMotorPos() {
 motor1Pos.setText("Motor1: [" + motor1.motorPosScaled + "]");
 motor2Pos.setText("Motor2: [" + motor2.motorPosScaled + "]");
 }
 */
// ====================================================================================================

public void startSampling() {
  if (motors.size() > 0) {
    println("Starting sampling procedure...");
    backupFile = createWriter(getDateString() + "_data.csv");
    sampleState = 1;
    lastSample = millis();
    for (Motor m : motors) {
      m.samples = new FloatList();
    }
  }
  println("No motors attached ... =(");
}

public void stopSampling() {
  if (sampling) {
    println("Stopping sampling procedure...");
    println("Writing to file.");
    sampleState = 0;
    sampling = false;
    backupFile.flush();
    backupFile.close();
  }
}

public void sample() {
  if (sampling) {
    for (Motor m : motors) {
      m.samplePos();
    }
    lastSample = millis();
  }
}
// MQTT setup

public void setupMQTTglobal() {
  client = new MQTTClient(this);
  client.connect(mqttAdress + ':' + mqttPort, "main");
  client.subscribe("/register");
  client.subscribe("/+/pos");
  client.subscribe("/+/state");
}

public void messageReceived(String topic, byte[] payload) {

  String msg = new String(payload);
  println("new message: " + topic + " - " + msg);

  String[] topicList = split(topic, '/');

  if ((motorArray[0] == null) && (motorArray[1] == null)) {
    println("motors not online yet");
  } else {
    int index = PApplet.parseInt(topicList[1]);

    if (topicList[2].equals("pos")) {
      motorArray[index].updatePos(PApplet.parseFloat(msg));
    } else if (topicList[2].equals("state")) {
      motorArray[index].updateState(PApplet.parseInt(msg));
    }
  }
}

public void activateUi(boolean val) {
  motorPos.setLock(val).setColorForeground(fgi);
  motorTgt.setLock(val).setColorForeground(fgi);
  motorSpd.setLock(val).setColorForeground(fgi);
}
class Marker {
  PVector posN;
  PVector lastPos;

  int dia = 20;

  int scaleX;
  int scaleY;

  float lerpAmt = 0.1f;

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

  public float getNormalizedX(){
    return posN.x;
  }

  public float getNormalizedY(){
    return posN.y;
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
class Motor {

  FloatList samples;
  private float motorPos = 0.0f;
  private float motorTarget = 0.0f;

  private int motorState = 0;
  // 0 = waiting / 1 = calibrating / 2 = running / 3 = waiting for setup

  private int motorSpeed = 5000;

  Textlabel motorIDLabel;
  Textlabel motorStateLabel;

  ControlListener cL;

  Slider motorSpeedSlider, motorPosSlider, motorTargetSlider, motorStateSlider;

  public int id;

  String idString;

  Motor(int _id) {
    id = _id;
    idString = nf(id, 3);

    int offsetY =  buttonOffsetY + 2 * gridY + (5 * gridY * id);

    motorIDLabel = cp5.addTextlabel("motorid: " + id)
      .setText("MOTOR ID " + id)
      .setPosition(leftBorderUI, offsetY + gridY)
      .setColorValue(255)
      .setFont(p)
      ;

    motorPosSlider = cp5.addSlider("motorpos" + id)
      .setPosition(leftBorderUI, offsetY + gridY * 2)
      .setColorValue(255)
      .setLabel("motorpos")
      .setFont(p)
      .setSize(barWidth, barHeight)
      .setRange(0.0f, 1.0f)
      .setValue(0)
      .setNumberOfTickMarks(5)
      .snapToTickMarks(false)
      .plugTo(this, "motorPos")
      .setDecimalPrecision(5)
      .lock()
      ;

    motorTargetSlider = cp5.addSlider("motortarget" + id)
      .setPosition(leftBorderUI, offsetY + gridY * 3)
      .setColorValue(255)
      .setLabel("motortarget")
      .setFont(p)
      .setSize(barWidth, barHeight)
      .setRange(0, 1)
      .setValue(0)
      .setNumberOfTickMarks(5)
      .snapToTickMarks(false)
      .setHandleSize(5)
      .plugTo(this, "setTarget")
      ;

    motorSpeedSlider = cp5.addSlider("motorspeed" + id)
      .setPosition(leftBorderUI, offsetY + gridY * 4)
      .setColorValue(255)
      .setLabel("motorspeed")
      .setFont(p)
      .setSize(barWidth, barHeight)
      .setRange(0.0f, 10000.0f)
      .setValue(4000)
      .setNumberOfTickMarks(5)
      .snapToTickMarks(false)
      .plugTo(this, "setSpeed")
      ;

    motorStateSlider = cp5.addSlider("motorstate" + id)
      .setPosition(leftBorderUI, offsetY + gridY * 5)
      .setColorValue(255)
      .setLabel("motorstate")
      .setFont(p)
      .setSize(barWidth, barHeight)
      .setRange(0, 3)
      .setValue(getMotorState())
      .lock()
      .setNumberOfTickMarks(3)
      .snapToTickMarks(false)
      .plugTo(this, "motorState")
      ;
  }

  public void setTarget(float inVal) {
    motorTarget = inVal;
    client.publish('/' + idString + "/tgt", str(inVal*1000));
    println("motorID " + id + ": setting new position: " + motorTarget);
  }

  public void setSpeed(float speed) {
    int inSpeed = PApplet.parseInt(speed);
    motorSpeed = inSpeed;
    client.publish('/' + idString + "/spd", str(inSpeed));
    println("motorID " + id + ": setting new speed: " + motorSpeed);
  }

  public void recalibrate() {
    client.publish('/' + idString + "/rst", "1");
    println('/' + idString + "/rst");
    println("motorID " + id + ": starting calibration procedure!");
  }

  public void updateInfo() {
    String posT = nf(motorPos, 1, 5);
    motorPosLabel.setText("X: [" + posT + "]");
  }

  public void processCmd(String cmd, String payload) {
    if (cmd.equals("pos")) {
      motorPos = PApplet.parseFloat(payload)/1000;
      this.motorPosSlider.setValue(motorPos);
      println("setting new pos: " + motorPos);
    } else if (cmd.equals("state")) {
      motorState = PApplet.parseInt(payload);
      this.motorPosSlider.setValue(motorState);
      println("setting new state: " + motorState);
    }
  }

  public String getMotorStateString() {
    switch (motorState) {
    case 1:
      {
        return "calibrating";
      }
    case 2:
      {
        return "running";
      }
    default:
      {
        return "waiting";
      }
    }
  }

  public boolean motorReady() {
    return motorState == 0;
  }

  public void setNewSpeed(int inSpeed) {
    motorSpeed = inSpeed;
  }

  public float getMotorPos() {
    return motorPos;
  }

  public int getMotorState() {
    return motorState;
  }

  public void samplePos() {
    this.samples.append(this.motorPos);
  }

  public void updatePos(float val) {
    motorPos = val/1000.0f;
    motorPosSlider.setValue(motorPos);
    println("Motor" + id + " - new position: " + motorPos);
  }

  public void updateState(int val) {
    motorState = val;
    motorStateSlider.setValue(motorState);
    println("Motor" + id + " - new state: " + motorState);
  }

}
class Sample{

  private float[] data = new float[4];

  Sample(float _x, float _y, float _a1, float _a2){
    data[0] = _x;
    data[1] = _y;
    data[2] = _a1;
    data[3] = _a2;
  }

  public float getX(){
    return data[0];
  }

  public float getY(){
    return data[1];
  }
}
public void checkSampling(){
  if(isSampling){
    if(motorsReady()){
      saveNewSample();
      setNewTarget();
    }
    else{
      if(lastSample + sampleFreq < millis()){
        saveNewSample();
        lastSample = millis();
      }
    }
  }
}


public boolean motorsReady(){
  return (motorArray[0].motorReady() && motorArray[1].motorReady());
}

public void setNewTarget(){
  float t1 = random(1);
  float t2 = random(1);

  motorArray[0].setTarget(t1);
  motorArray[1].setTarget(t2);

  println("Setting new target: " + t1 + " / " + t2 + "!");
}

public void saveNewSample(){
  samples.add(new Sample(marker.getNormalizedX(),marker.getNormalizedY(),motorArray[0].getMotorPos(),motorArray[1].getMotorPos()));
}

public void drawSamplePoints(int _offset, int _size, boolean drawTrace){
  if(!samples.isEmpty()){
    pushMatrix();
    translate(_offset,_offset);
    if(drawTrace){
      beginShape();
      for(Sample s : samples){
        vertex(s.getX() * _size,s.getY() * _size);
      }
      endShape();
    }
    for(Sample s : samples){
      drawPoint(s.getX() * _size,s.getY() * _size);
    }
    popMatrix();
  }
}

public void sendPos(Serial s, float newPos) {
}
public void resetTransformArray(PImage _imgT) {
  transformPoints.add(new PVector(_imgT.width-transformOffset, transformOffset));
  transformPoints.add(new PVector(transformOffset, transformOffset));
  transformPoints.add(new PVector(transformOffset, _imgT.height-transformOffset));
  transformPoints.add(new PVector(_imgT.width-transformOffset, _imgT.height-transformOffset));
}
public void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}


public String getDateString() {
  return year() + "-" + month() + "-" + day() + "_" + hour() + "-" + minute();
}

public void setupCamera(String camId) {
  try {
    cam = new Capture(this, 960, 540, camId, 30);
    if (cam == null) {
      cam = new Capture(this, 640, 480);
    }
    cam.start();
  }

  catch(NullPointerException e) {
    println("No camera attached - falling back to built-in.");
    cam = new Capture(this, 640, 480);
    cam.start();
  }
}
// Websocket




public void updateIpAdress(String inputString) {
  wsAdress = inputString;
}

public void connectWS() {
  wsc= new WebsocketClient(this, wsAdress + ':' + wsPort);
}




// Websocket Communication
/*
void sendDataPos() {
 String msg = "ip" + ',' + marker.getPosX() + ',' + marker.getPosY() + ',' + motor1.motorPosScaled + ',' + motor2.motorPosScaled;
 wsc.sendMessage(msg);
 }
 
 void sendDataVec() {
 String msg = "iv" + ',' + marker.getPosX() + ',' + marker.getPosY() + ',' + marker.lastPosX() + ',' + marker.lastPosY() + ',' + motor1.motorPosScaled + ',' + motor2.motorPosScaled;
 wsc.sendMessage(msg);
 }
 
 void sendPos() {
 wsc.sendMessage(markerPos.x + "," + markerPos.y);
 }
 
 void activateLearning() {
 wsc.sendMessage("enableLearning");
 }
 */

public void warpImg(PImage targetImg, int warpSize, ArrayList<PVector> warpPoints) {

  opencv.toPImage(warpPerspective(warpPoints, warpSize, warpSize), targetImg);
}


public Mat warpPerspective(ArrayList<PVector> inputPoints, int w, int h) {
  Mat transform = getPerspectiveTransformation(inputPoints, w, h);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
}


public Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
  Point[] canonicalPoints = new Point[4];
  canonicalPoints[0] = new Point(w, 0);
  canonicalPoints[1] = new Point(0, 0);
  canonicalPoints[2] = new Point(0, h);
  canonicalPoints[3] = new Point(w, h);

  MatOfPoint2f canonicalMarker = new MatOfPoint2f();
  canonicalMarker.fromArray(canonicalPoints);

  Point[] points = new Point[4];
  for (int i = 0; i < 4; i++) {
    points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
  }
  MatOfPoint2f marker = new MatOfPoint2f(points);
  return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
}
  public void settings() {  size(1920, 1080); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "veryhugemachineprocessing_newui" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
