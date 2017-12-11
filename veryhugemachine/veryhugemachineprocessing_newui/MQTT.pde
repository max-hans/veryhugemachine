// MQTT setup

void setupMQTT() {
  client = new MQTTClient(this);
  client.connect(mqttAdress + ':' + mqttPort, "main");
  client.subscribe("/register");
}

void messageReceived(String topic, byte[] payload) {
  String msg = new String(payload);
  println("new message: " + topic + " - " + msg);
  switch(topic) {
  case "/register":
    {
      boolean known = false;
      int inId = Integer.parseInt(msg);
      println("incoming: " + inId);
      for (Motor m : motors) {
        if (m.id == inId) {
          println("motor ID " + inId + " already registered!");
          known = true;
          break;
        }
      }
      if (!known) {
        println("adding new motor - ID: " + msg);
        motors.add(new Motor(inId, this));
      }
    }
  }
}

void setActiveMotor(int id) {
  mTemp = motors.get(id);
  motorPos.setValue(mTemp.motorPos);
  motorTgt.setValue(mTemp.motorTarget);
  motorSpd.setValue(mTemp.motorSpeed);
}

void activateUi(boolean val) {
  motorPos.setLock(val).setColorForeground(fgi);
  motorTgt.setLock(val).setColorForeground(fgi);
  motorSpd.setLock(val).setColorForeground(fgi);
}