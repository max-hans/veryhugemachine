//
// OpenCV
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
OpenCV opencv;


// UI
import controlP5.*;
ControlP5 cp5;
Textlabel coordX;
Textlabel coordY;

int transformOffset = 20;

int dragThresh = 10;
boolean mouseLocked = false;
int cornerSize = 10;


// Communication
import processing.serial.*;
import websockets.*;
WebsocketClient wsc;

// Tracking
import processing.video.*;
Capture cam;
boolean newFrame=false;

import blobDetection.*;
BlobDetection theBlobDetection;
float blobThreshDelta = 0.001f;
float detectionThreshold = 0.3f;

int canvasSize;

PImage img;
PImage warpedCanvas;

PVector markerPos;
PVector newPos;

Marker marker;

ArrayList<PVector> transformPoints = new ArrayList<PVector>();
ArrayList<DragPoint> dragPoints = new ArrayList<DragPoint>();

PVector imageTransformDelta;

Serial port1;
Serial port2;

Motor motor1;
Motor motor2;
int state = 0;

String serverAdress = "ws://127.0.0.1:8080";

// ====================================================================================================

void setup() {

  size(1400, 700);
  cam = new Capture(this, 640, 480, "Microsoft® LifeCam VX-2000 #2", 30);
  if (cam == null) {
    cam = new Capture(this, 640, 480);
  }
  canvasSize = cam.height;
  cam.start();

  cp5 = new ControlP5(this);
  createInterface();
  
  imageTransformDelta = new PVector(30, 100);
  
  opencv = new OpenCV(this, cam);
  img = new PImage(canvasSize/2, canvasSize/2);
  
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(detectionThreshold);
  
  markerPos = new PVector(0, 0);
  warpedCanvas = new PImage(canvasSize, canvasSize);
  
  resetTransformArray(cam);
  
  for (PVector P : transformPoints) {
    dragPoints.add(new DragPoint(P));
  }

  marker = new Marker(0.5, 0.5, canvasSize, canvasSize);
  
  String portName1 = Serial.list()[1];
  String portName2 = Serial.list()[2];
  
  port1 = new Serial(this,portName1,115200);
  port2 = new Serial(this,portName2,115200);
  
  motor1 = new Motor(port1);
  motor2 = new Motor(port2);
  
  wsc= new WebsocketClient(this, serverAdress);
}

// ====================================================================================================

void draw()
{  
  
  motor1.update();
  motor2.update();
  
  background(30);

  // Display camera image
  pushMatrix();
  translate(imageTransformDelta.x, imageTransformDelta.y);

  imageMode(CORNER);
  image(cam, 0, 0);

  drawCorners(0, 0, cam.width, cam.height, cornerSize);

  for (DragPoint dP : dragPoints) {
    dP.update();
    dP.display();
  }
  drawFrame();
  popMatrix();

  // Display warped image
  pushMatrix();
  translate(imageTransformDelta.x + cam.width + 30, imageTransformDelta.y);
  image(warpedCanvas, 0, 0);
  drawCorners(0, 0, warpedCanvas.width, warpedCanvas.height, cornerSize);
  marker.display();
  popMatrix();
  
  // Update video frames
  if (newFrame)
  {
    newFrame=false;

    opencv.loadImage(cam);
    warpImg(warpedCanvas, canvasSize, transformPoints);

    img.copy(warpedCanvas, 0, 0, canvasSize, canvasSize,0, 0, img.width, img.height);
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
    updateMarkerPos();
  }
}

void mousePressed() {
  if (!mouseLocked) {
    mouseLocked = true;
    for (DragPoint DP : dragPoints) {
      DP.checkDrag();
    }
  }
}

void mouseReleased() {
  for (DragPoint DP : dragPoints) {
    DP.isDragged = false;
  }
  mouseLocked = false;
}

void keyPressed(){
  if(key == 'm')sendData();
  if(key == 'l')activateLearning();
}