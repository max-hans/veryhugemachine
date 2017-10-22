import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;

import processing.video.*;
import blobDetection.*;

Capture cam;
BlobDetection theBlobDetection;
OpenCV opencv;

float blobThreshDelta = 0.001f;

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

int canvasSize = 500;
PImage warpedCanvas;

boolean drawUnWarped = true;

int dragThresh = 10;
boolean mouseLocked = false;

int state = 0;

// ====================================================================================================

void setup() {

  size(900, 900);
  cam = new Capture(this, 640, 480, "Microsoft® LifeCam VX-2000 #2", 30);
  cam.start();
  opencv = new OpenCV(this, cam);
  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame);
  img = new PImage(canvasSize/2,canvasSize/2); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(detectionThreshold);
  markerPos = new PVector(0, 0);
  warpedCanvas = new PImage(canvasSize, canvasSize);
  resetTransformArray(cam);
  for (PVector P : transformPoints) {
    dragPoints.add(new DragPoint(P));
  }
  
  marker = new Marker(0.5,0.5,canvasSize,canvasSize);
}

// ====================================================================================================

void draw()
{  
  background(255);
  
  switch(state) {
  case 0:
    {
      imageMode(CORNER);
      image(cam, 0, 0);
      
      for (DragPoint dP : dragPoints) {
        dP.update();
        dP.display();
      }
      
      
      break;
    }

  case 1:
    {
      pushMatrix();
      translate(width/2-warpedCanvas.width/2,height/2-warpedCanvas.height/2);
      image(warpedCanvas, 0,0);
      marker.display();
      popMatrix();
      break;
    }

  }

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

      if (blobCount > 2) {
        detectionThreshold -= blobThreshDelta;
        theBlobDetection.setThreshold(detectionThreshold);
      } else if (blobCount == 0) {
        detectionThreshold += (3*blobThreshDelta);
        theBlobDetection.setThreshold(detectionThreshold);
      }

      
      
      //println(blobCount);
      marker.updatePos(getMarkerPosition()); 
    }

  }

  void keyPressed() {
    //calibrateDetection();
    if (key == 'n'){
      if(state == 0){
        state = 1;
      }
      else if(state == 1){
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