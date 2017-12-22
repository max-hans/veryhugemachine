// MQTT setup

void setupMQTTglobal() {
  client = new MQTTClient(this);
  client.connect(mqttAdress + ':' + mqttPort, "main");
  client.subscribe("/register");
  client.subscribe("/+/pos");
  client.subscribe("/+/state");
}

void messageReceived(String topic, byte[] payload) {

  String msg = new String(payload);
  println("new message: " + topic + " - " + msg);

  String[] topicList = split(topic, '/');

  if ((motorArray[0] == null) && (motorArray[1] == null)) {
    println("motors not online yet");
  } else {
    int index = int(topicList[1]);

    if (topicList[2].equals("pos")) {
      motorArray[index].updatePos(float(msg));
    } else if (topicList[2].equals("state")) {
      motorArray[index].updateState(int(msg));
    }
  }
}

void activateUi(boolean val) {
  motorPos.setLock(val).setColorForeground(fgi);
  motorTgt.setLock(val).setColorForeground(fgi);
  motorSpd.setLock(val).setColorForeground(fgi);
}
