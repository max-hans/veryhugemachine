
///////////////////////////////////////////////////////////////////////////////////////////////

void callback(char* topic, byte* payload, unsigned int length) {

  String topicString = "";

  String parseString = "";
  for (int i = 0; i < length; i++) {
    parseString += payload[i] - '0';
  }
  

  const char * parseChar = parseString.c_str();

  for (int i = 0; i < 3; i++) {
    topicString += topic[5 + i];
  }
  Serial.println(topicString);
  if (topicString == "rst") {
    Serial.println("received command: reset");
    calibrate();
  }
  
  else if (topicString == "tgt") {
    Serial.println("received command: new target");

    float inVal = atof(parseChar) / 1000.0;
    Serial.println(parseString);
    Serial.println(parseChar);
    Serial.println(inVal);
    updateTarget(inVal);
  }
  
  else if (topicString == "spd") {
    Serial.println("received command: speed");
    int inVal = atoi(parseChar);
    setNewSpeed(inVal);
  }
  else {
    Serial.println("unknown command");
  }

  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {

    Serial.print((char)payload[i]);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////

void sendPosition() {
  float posVal = getNormalizedPos() * 1000;
  String posPost = String(posVal, 5);
  client.publish(posString.c_str(), posPost.c_str());
  //Serial.println("Publishing position: " + posPost);
}

///////////////////////////////////////////////////////////////////////////////////////////////

float getNormalizedPos() {
  if(calibrated){
  return float(axis1.currentPosition()) / maxDist;
  }
  else{
    return 0;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

///////////////////////////////////////////////////////////////////////////////////////////////

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    String idString = String(id);
    char registerMsg[idString.length() + 1];
    idString.toCharArray(registerMsg, idString.length() + 1);

    if (client.connect(registerMsg)) {
      Serial.println("connected");
      Serial.println("test");
      resetString = prefix + "rst";
      speedString = prefix + "spd";
      targetString = prefix + "tgt";
      posString += prefix;
      posString += "pos";

      client.subscribe(resetString.c_str());
      client.subscribe(speedString.c_str());
      client.subscribe(targetString.c_str());

      Serial.println(registerMsg);
      client.publish("/register", registerMsg);
      Serial.println(resetString);
      Serial.println(speedString);
      Serial.println(targetString);

    } else {

      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");

      delay(5000);
    }

  }

}

///////////////////////////////////////////////////////////////////////////////////////////////
