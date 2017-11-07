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
Textlabel motor1Pos;
Textlabel motor2Pos;
Slider abc;

PrintWriter backupFile;

Slider motor1target;
Slider motor2target;

float motor1posval = 0.0;
float motor2posval = 0.0;

int transformOffset = 20;

int dragThresh = 10;
boolean mouseLocked = false;
int cornerSize = 10;

ArrayList<Motor> motors = new ArrayList<Motor>();
Motor mTemp;

FloatList samples;
boolean sampling;
// Communication
import processing.serial.*;

// Websocket
import websockets.*;
WebsocketClient wsc;

// MQTT
import mqtt.*;
MQTTClient client;

PFont p; // regular font
PFont pb; // bold font
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

float[] motorPositions = new float[2];
boolean[] motorUpdated = {false, false};

int sampleFreq = 1000;
int lastSample;
boolean isSampling = false;
int sampleState = 0;

int state = 0;

String wsAdress = "ws://127.0.0.1";
int wsPort = 8080;
String mqttAdress = "mqtt://192.168.2.101";
int mqttPort = 1883;

String trackingChannel = "track";
String requestChannel = "rq";

// UI

boolean drawVideo = true;

int gridWidth = 20;

// ====================================================================================================

void setup() {

  size(1400, 1000);
  try {
  cam = new Capture(this, 640, 480, "Microsoft® LifeCam VX-2000", 30);
  if (cam == null) {
    cam = new Capture(this, 640, 480);
  }
  cam.start();
  }
  catch(NullPointerException e){
    println("No camera attached - falling back to built-in.");
    cam = new Capture(this, 640,480);
    cam.start();
  }
  setupMQTT();





  canvasSize = cam.height;
  

  imageTransformDelta = new PVector(gridWidth, gridWidth);

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
  marker.addLabel(coordX, coordY);

  cp5 = new ControlP5(this);
  createInterface();
}

// ====================================================================================================

void draw()
{  
  background(30);
  checkFrames();
  updateInterface();
  displayCamera();
  displayWarped();
}

// ====================================================================================================

void startSampling() {
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

void stopSampling(){
  if(sampling){
    println("Stopping sampling procedure...");
    println("Writing to file.");
    sampleState = 0;
    sampling = false;
    backupFile.flush();
    backupFile.close();
  }
}

void sample() {
  if (sampling) {
    for (Motor m : motors) {
      m.samplePos();
    }
    lastSample = millis();
  }
}