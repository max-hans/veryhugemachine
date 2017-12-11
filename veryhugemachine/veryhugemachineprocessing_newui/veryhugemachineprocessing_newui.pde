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

// UI Colors

color darkblue = color(26, 26, 30);
color white = color(255, 255, 255);
color col1 = color(255, 33, 81);
color col2 = color(27, 198, 180);

// UI
import controlP5.*;
ControlP5 cp5;
ControlP5 remapControl;


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

Motor Motor1;
Motor Motor2;

Motor mTemp;

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
//String mqttAdress = "mqtt://192.168.2.101";
//String mqttAdress = "mqtt://127.0.0.1";
String mqttAdress = "mqtt://127.0.0.1";
int mqttPort = 1883;

String trackingChannel = "track";
String requestChannel = "rq";

// UI

boolean drawVideo = false;

int gridWidth = 20;

int borderY = 340;

int barHeight = 15;
int barWidth = 580;

int caseByte = 0;

// ====================================================================================================

void setup() {

  size(1920, 1080);
  background(darkblue);
  p = createFont("Roboto Mono 700", fontSize);
  pb = createFont("Roboto Mono", fontSize);

  cp5 = new ControlP5(this);
  createInterface();

  Motor1 = new Motor(0, this);
  Motor2 = new Motor(1, this);

  motors.add(Motor1);
  motors.add(Motor2);

  // Start camera interface


  setupCamera("USB 2.0 Camera");

  setupMQTT();

  //canvasSize = cam.height;

  canvasSize = 836;
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

  marker = new Marker(0.5, 0.5, canvasSize, canvasSize);



}

// ====================================================================================================

void draw()
{
  background(darkblue);


  switch(caseByte){
    case 0:{
      checkFrames();
      interfaceRegular();
      displayWarped();
      break;
    }
    case 1:{
      interfaceRemap();
      break;
    }
  }

  //displayCamera();


}
