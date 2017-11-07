// Websocket




void updateIpAdress(String inputString) {
  wsAdress = inputString;
}

void connectWS() {
  wsc= new WebsocketClient(this, wsAdress + ':' + wsPort);
}




// Websocket Communication
/*
void sendDataPos() {
  String msg = "ip" + ',' + marker.getPosX() + ',' + marker.getPosY() + ',' + motor1.motorPosScaled + ',' + motor2.motorPosScaled;
  wsc.sendMessage(msg);
}

void sendDataVec() {
  String msg = "iv" + ',' + marker.getPosX() + ',' + marker.getPosY() + ',' + marker.lastPosX() + ',' + marker.lastPosY() + ',' + motor1.motorPosScaled + ',' + motor2.motorPosScaled;
  wsc.sendMessage(msg);
}

void sendPos() {
  wsc.sendMessage(markerPos.x + "," + markerPos.y);
}

void activateLearning() {
  wsc.sendMessage("enableLearning");
}
*/