#include <AccelStepper.h>
#include <MultiStepper.h>
#include <EEPROM.h>

#include <ESP8266WiFi.h>
#include <PubSubClient.h>



#define STEPPIN1  7
#define DIRPIN1   8

#define SENSORPIN1 3
#define SENSORPIN2 4

#define CALIBRATEPIN 2

WiFiClient espClient;
PubSubClient client(espClient);
AccelStepper axis1(1, STEPPIN1, DIRPIN1);

char speedString[(sizeof(byte)*8+1)];
char targetString[(sizeof(byte)*8+1)];
char resetString[(sizeof(byte)*8+1)];

boolean debug = false;

const char* ssid = "thefutureisnow";
const char* password = "thefutureiswow";
const char* mqtt_server = "192.168.0.100"; // rapsberry 

char msg[50];

byte id;

//byte state = 0;
int eepromAdress = 0;

unsigned int normalAccel = 3000;
unsigned long maxDist;



// Position values are stored in range between 0 and 32767 and scaled accordingly

int motorPosRaw = 0;
int motorTargetRaw = 0;
int lastTargetRaw = 0;


int motorSpeed = 0;
int lastMotorSpeed = 0;

int doCalibrate = 0;
int motorReady = 0;


// parameters for position update
unsigned int posUpdateFreq = 200;
unsigned int lastPosUpdate;

void setup() {
  pinMode(SENSORPIN1, INPUT);
  pinMode(SENSORPIN2, INPUT);
  pinMode(CALIBRATEPIN, INPUT);
  Serial.begin(115200);

  id = analogRead(0)/4;

  

  
  targetString = '/' + String(id) + "/tgt";
  speedString = '/' + String(id) + "/spd";
  resetString = '/' + String(id) + "/rcl";
  
  Serial.println("ID: " + String(id));

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  axis1.setMaxSpeed(motorSpeed);
  axis1.setSpeed(motorSpeed);
  axis1.setAcceleration(1000);

  axis1.setSpeed(motorSpeed);

  maxDist = EEPROMReadlong(eepromAdress);

  runToZero();
  lastPosUpdate = millis();
  

}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();


  
  if (!targetReached()) {
    axis1.run();
  }
}



void updateTarget(float inTarget) {
  axis1.moveTo((int)(inTarget * maxDist));
}

void updatePos() {
  motorPosRaw = scaleUp(axis1.currentPosition());
}

