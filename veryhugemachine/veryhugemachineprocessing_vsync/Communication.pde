
// Websocket

void sendPos() {
  wsc.sendMessage(markerPos.x + "," + markerPos.y);
}

void activateLearning() {
  wsc.sendMessage("enableLearning");
}


void updateIpAdress(String inputString) {
  wsAdress = inputString;
}

// MQTT
void connectMQTT() {
  client.connect(mqttAdress + ':' + mqttPort, "processing");
}

void connectWS() {
  wsc= new WebsocketClient(this, wsAdress + ':' + wsPort);
}


/*
void requestPositions() {
  motor1.received = false;
  motor2.received = false;
  client.publish(requestChannel, "getPositions");
}
*/
void sendDataPos() {
  String msg = "ip" + ',' + marker.getPosX() + ',' + marker.getPosY() + ',' + motor1.motorPosScaled + ',' + motor2.motorPosScaled;
  wsc.sendMessage(msg);
}

void sendDataVec() {
  String msg = "iv" + ',' + marker.getPosX() + ',' + marker.getPosY() + ',' + marker.lastPosX() + ',' + marker.lastPosY() + ',' + motor1.motorPosScaled + ',' + motor2.motorPosScaled;
  wsc.sendMessage(msg);
}


/*

 
 void sendPosition() {
 String msg = str(marker.getPosX()) + ',' + str(marker.getPosY()); 
 client.publish('/' + trackingChannel, msg);
 }
 
 
 void messageReceived(String topic, byte[] payload) {
 String msg = new String(payload);
 switch(topic) {
 
 case "motor1pos":
 motor1.received = true;
 motorPositions[0] = Float.parseFloat(msg);
 break;
 case "motor2pos":
 motor2.received = true;
 motorPositions[1] = Float.parseFloat(msg);
 break;
 case "motor1ready":
 motor1.ready = true;
 break;
 case "motor2ready":
 motor2.ready = true;
 break;
 }
 }
 */