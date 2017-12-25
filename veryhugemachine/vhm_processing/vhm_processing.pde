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

import java.io.*;


// UI Colors

color darkblue = color(26, 26, 30);
color white = color(255, 255, 255);

color col1 = color(230);
color col1_2 = color(230,150);
color col2 = color(27, 198, 180);

/*
color col1 = color(255, 33, 81);
color col1_2 = color(255,33,81,150);
color col2 = color(27, 198, 180);
*/

// UI
import controlP5.*;
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

float motor1posval = 0.0;
float motor2posval = 0.0;

int transformOffset = 20;

int dragThresh = 10;
boolean mouseLocked = false;
int cornerSize = 10;


Motor Motor0, Motor1;
ArrayList<Motor> motors;

Motor[] motorArray = new Motor[2];

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

PImage img;
PImage warpedCanvas;

PVector markerPos;
PVector newPos;

Marker marker;

ArrayList<PVector> transformPoints = new ArrayList<PVector>();
ArrayList<DragPoint> dragPoints = new ArrayList<DragPoint>();

PVector imageTransformDelta;

// Motors

int sampleFreq = 1000;
int lastSample;
boolean isSampling = false;
int sampleState = 0;

ArrayList<Sample> samples = new ArrayList<Sample>();

boolean sampling = false;

// AI

boolean waitingForPos = false;

// ====================================================================================================

int state = 0;

//String wsAdress = "ws://127.0.0.1";
//String wsAdress = "ws://localhost";
//int wsPort = 8080;
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

void setup() {

  size(1920, 1080);
  background(darkblue);
  p = createFont("Roboto Mono 700", fontSize);
  pb = createFont("Roboto Mono", fontSize);

  cp5 = new ControlP5(this);
  setupCamera("USB 2.0 Camera");

  client = new MQTTClient(this);
  client.connect(mqttAdress + ':' + mqttPort, "main");

  client.subscribe("/register");
  client.subscribe("/+/pos");
  client.subscribe("/+/state");

  wsc = new WebsocketClient(this,"ws://localhost:8080");

  createInterface();

  shapePoints = new ArrayList<PVector>();

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
  marker = new Marker(0.5, 0.5, canvasSize, canvasSize);
}

// ====================================================================================================

void draw()
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
