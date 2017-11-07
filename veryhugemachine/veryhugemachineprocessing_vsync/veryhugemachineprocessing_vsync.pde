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
import vsync.*;

ValueReceiver receiver1;
ValueSender sender1;

ValueReceiver receiver2;
ValueSender sender2;

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

  String portName1 = Serial.list()[1];
  String portName2 = Serial.list()[2];
  
  motor1 = new Motor(this, portName1, 1);
  motor2 = new Motor(this, portName2, 2);

  canvasSize = cam.height;
  cam.start();



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

  cp5 = new ControlP5(this);
  createInterface();

}

// ====================================================================================================

void draw()
{  
  background(30);

  //motor1.update();
  //motor2.update();

  //sample();

  checkFrames();

  updateInterface();

  motor1.handleData();
  motor2.handleData();

  displayCamera();
  displayWarped();
}

// ====================================================================================================


void sample() {

  if (millis() > lastSample + sampleFreq) {
    println(motor1.motorPosScaled + ", " + motor2.motorPosScaled);
  }
}

void startSampling() {
  sampleState = 1;
  lastSample = millis();
}

void stopSampling() {
  sampleState = 0;
}

void connectSerial() {
  receiver1 = new ValueReceiver(this, port1);
  sender1 = new ValueSender(this, port2);

  receiver2 = new ValueReceiver(this, port1);
  sender2 = new ValueSender(this, port2);
}