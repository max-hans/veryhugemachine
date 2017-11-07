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

Slider motor1target;
Slider motor2target;

float motor1posval = 0.0;
float motor2posval = 0.0;

int transformOffset = 20;

int dragThresh = 10;
boolean mouseLocked = false;
int cornerSize = 10;


// Communication
import processing.serial.*;

// Websocket
import websockets.*;
WebsocketClient wsc;

// MQTT
import mqtt.*;
MQTTClient client;


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

float[] motorPositions = new float[2];
boolean[] motorUpdated = {false, false};

int sampleFreq = 1000;
int lastSample;
boolean isSampling = false;
int sampleState = 0;

int state = 0;

String wsAdress = "ws://127.0.0.1";
int wsPort = 8080;
String mqttAdress = "mqtt://127.0.0.1";
int mqttPort = 1883;

String trackingChannel = "track";
String requestChannel = "rq";

// UI

boolean drawVideo = true;

// ====================================================================================================

void setup() {

  size(1400, 1000);
  cam = new Capture(this, 640, 480, "Microsoft® LifeCam VX-2000", 30);
  if (cam == null) {
    cam = new Capture(this, 640, 480);
  }

  motor1 = new Motor(0);
  motor2 = new Motor(1);

  canvasSize = cam.height;
  cam.start();

  cp5 = new ControlP5(this);
  createInterface();

  client = new MQTTClient(this);

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

  

  

  
}

// ====================================================================================================

void draw()
{  
  background(30);

  //motor1.update();
  //motor2.update();

  sample();

  checkFrames();

  updateInterface();

  displayCamera();
  displayWarped();
}

// ====================================================================================================

void sample() {
  switch(sampleState) {
  case 0:
    break;
  case 1:
    {
      if (millis() > lastSample + sampleFreq) {
        motor1.requestPos();
        motor2.requestPos();
        sampleState = 2;
        break;
      }
    }
  case 2:
    {
      if (motor1.received && motor2.received) {
        sendDataPos();
        sampleState = 1;
        break;
      }
    }
  }
}

void startSampling() {
  sampleState = 1;
  lastSample = millis();
}

void stopSampling() {
  sampleState = 0;
}

void connectSerial(){
  String portName1 = Serial.list()[1];
  String portName2 = Serial.list()[2];
  
  port1 = new Serial(this, portName1, 115200);
  port2 = new Serial(this, portName2, 115200);
  
  motor1.serial = port1;
  motor2.serial = port2;
  /*
  motor1.startConnection(port1);
  motor2.startConnection(port2);
  */
}