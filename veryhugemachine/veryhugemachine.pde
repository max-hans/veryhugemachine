import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;

import processing.video.*;
import blobDetection.*;

import controlP5.*;
ControlP5 cp5;

Capture cam;
BlobDetection theBlobDetection;
OpenCV opencv;

float blobThreshDelta = 0.001f;

boolean showTransformed = false;

Textlabel coordX;
Textlabel coordY;

PImage img;
PImage targetImg;

Marker marker;

boolean newFrame=false;

float detectionThreshold = 0.3f;
PVector markerPos;
PVector newPos;

int transformOffset = 20;

ArrayList<PVector> transformPoints = new ArrayList<PVector>();
ArrayList<DragPoint> dragPoints = new ArrayList<DragPoint>();

int canvasSize;
PImage warpedCanvas;

PVector imageTransformDelta;

boolean drawUnWarped = true;

int dragThresh = 10;
boolean mouseLocked = false;

int cornerSize = 10;

int state = 0;

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
  //imageTransformDelta = new PVector((width-cam.width)/2, (height-cam.height)/2);
  imageTransformDelta = new PVector(30, 100);
  opencv = new OpenCV(this, cam);
  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame);
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
}

// ====================================================================================================

void draw()
{  
  background(30);

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
  translate(imageTransformDelta.x + cam.width + 30 , 0);
  image(warpedCanvas, 0, 0);
  drawCorners(0, 0, warpedCanvas.width, warpedCanvas.height, cornerSize);
  marker.display();
  popMatrix();
  
  
  println(marker.getPosNormalized());

if (newFrame)
{
  newFrame=false;

  opencv.loadImage(cam);
  warpImg(warpedCanvas, canvasSize, transformPoints);
  img.copy(warpedCanvas, 0, 0, canvasSize, canvasSize, 
    0, 0, img.width, img.height);
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
  //println(blobCount);
  marker.updatePos(getMarkerPosition());
  updateMarkerPos();
}
}

void keyPressed() {
  //calibrateDetection();
  if (key == 'n') {
    if (state == 0) {
      state = 1;
    } else if (state == 1) {
      state = 0;
    }
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