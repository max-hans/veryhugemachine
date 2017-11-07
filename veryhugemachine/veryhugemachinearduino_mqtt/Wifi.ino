

void callback(char* topic, byte* payload, unsigned int length) {
  if (debug) {
    Serial.print("Message arrived [");
    Serial.print(topic);
    Serial.print("] ");
    for (int i = 0; i < length; i++) {
      Serial.print((char)payload[i]);
    }
    Serial.println();
  }
  String inString = "";

  for (int i = 0; i < length; i++) {
    inString += (char)payload[i];
  }

  
  const String prefix = "/" + String(id) + "/";
  if (strcmp(topic,resetString)==0){
    // reset / recalibrate
    calibrate();
  }

  else if (strcmp(topic,targetString)==0){
    // new target
    updateTarget(inString.toFloat() / 1000.0);
  }

  else if (strcmp(topic,speedString)==0){
    // new speed
    axis1.setSpeed(inString.toInt());
    
  }


  if ((char)payload[0] == 'M') {
    String parseString = "";
    Serial.println("Received command: " + parseString);
    bool isPositive = true;
    for (int i = 1; i < length; i++) {
      if ((i == 1) && (payload[i] == '-')) {
        isPositive = false;
      }
      else if (isDigit(payload[i])) {
        parseString += payload[i] - '0';
      }
    }
    Serial.println("Raw: " + parseString);
    const char * parseChar = parseString.c_str();
    int delta = atoi(parseChar);
    if (!isPositive) {
      delta *= (-1);
    }
    //offTime = millis() + delta;
    Serial.println("Waiting for " + String(delta) + " ms");
  }
}

void setup_wifi() {

  delay(10);
  if (debug) {
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);
  }

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  if (debug) {
    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish("outTopic", "hello world");
      // ... and resubscribe
      client.subscribe("inTopic");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
