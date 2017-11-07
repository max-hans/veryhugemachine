class Motor {

  FloatList samples;
  private float motorPos = 0.0;
  private float motorTarget = 0.0;

  private int motorState = 0;
  // 0 = waiting / 1 = calibrating / 2 = running
  
  private int motorSpeed = 5000;
  
  Textlabel motorIDLabel;
  //Textlabel motorPosLabel;
  Textlabel motorStateLabel;
  Bang resetButton;
  ControlListener cL;
  
  Slider motorSpeedSlider,motorPosSlider;
  
  // parameters to be sent

  public int id;
  
  String idString;
  
  MQTTClient client;
  //PApplet sketch;
  
  Motor(int _id, PApplet _sketch) {
    
    //sketch = _sketch;
    id = _id;
    idString = nf(id,3);
    setupMQTT(_sketch);
    
    int index = motors.size();
    
    motorIDLabel = cp5.addTextlabel("motorid" + id)
    .setText("motor ID: " + id)
    .setPosition(gridWidth, 4*gridWidth + cam.height + index*gridWidth)
    .setColorValue(255)
    .setFont(pb)
    ;

    motorStateLabel = cp5.addTextlabel("motorstate" + id)
    .setText(getMotorStateString())
    .setPosition(gridWidth + gridX, 4*gridWidth + cam.height + index*gridWidth)
    .setColorValue(255)
    .setFont(p)
    ;
    
    resetButton = cp5.addBang("motorReset"+id)
    .setPosition(gridWidth + gridX*1.5, 4*gridWidth + cam.height + index*gridWidth + fontSize/2)
    .setSize(gridX/2, 5)
    .setLabel("reset")
    .setLabelVisible(false)
    .plugTo( this, "recalibrate" )
    .setSize(gridWidth,5);
    ;
    
    motorPosSlider = cp5.addSlider("motorpos" + id)
    .setPosition(gridWidth + gridX*2, 4*gridWidth + cam.height + index*gridWidth + fontSize/2)
    .setColorValue(255)
    .setLabelVisible(false)
    .setLabel("motorpos")
    .setFont(p)
    .setSize(gridX,5)
    
    .setRange(0,1)
    .setValue(0)
    ;
    
    motorSpeedSlider = cp5.addSlider("motorspeed" + id)
    .setPosition(gridWidth + gridX*3.5, 4*gridWidth + cam.height + index*gridWidth + fontSize/2)
    .setColorValue(255)
    .setLabelVisible(false)
    .setLabel("motorspeed")
    .setFont(p)
    .setSize(gridX,5)
    
    .setRange(0.0,10000.0)
    .setValue(4000)
    ;
    
    
  }

  void setupMQTT(PApplet p) {
    client = new MQTTClient(p);
    client.connect(mqttAdress + ':' + mqttPort, str(id));
    client.subscribe('/' + idString + '/');
    println("motorID " + id + ": setup complete");
  }

  // MQTT commands
  // for higher precision all position values (target & pos) are scaled by 1000!!!
  public void setTarget(float inVal) {
    motorTarget = inVal;
    client.publish('/' + idString + "/tgt", str(inVal*1000));
    println("motorID " + id + ": setting new position: " + motorTarget);
  }
  
  public void setSpeed(float speed) {
    int inSpeed = int(speed);
    motorSpeed = inSpeed;
    client.publish('/' + idString + "/spd", str(inSpeed));
    println("motorID " + id + ": setting new speed: " + motorSpeed);
  }

  public void recalibrate() {
    client.publish('/' + idString + "/rst", "1");
    println('/' + idString + "/rst");
    println("motorID " + id + ": starting calibration procedure!");
  }
  
  public void updateInfo(){
    String posT = nf(motorPos,1,5);
    motorPosLabel.setText("X: [" + posT + "]");
  }

  // MQTT handling

  void messageReceived(String topic, byte[] payload) {
    println("new message: " + topic + " - " + new String(payload));
    String msg = new String(payload);
    String[] topicList = split(topic,'/');
    switch(topicList[1]){
      case "pos":{
        motorPos = float(msg)/1000;
        break;
      }
      case "state":{
        motorState = int(msg);
        break;
      }
    }
  }

  // public

  public String getMotorStateString(){
    switch (motorState){
      case 1:{
        return "calibrating";
      }
      case 2:{
        return "running";
      }
      default:{
        return "waiting";
      }
    }
  }

  public boolean motorReady() {
    return motorState == 0;
  }

  public void setNewSpeed(int inSpeed) {
    motorSpeed = inSpeed;
  }
  
  public float getMotorPos(){
    return motorPos;
  }
  
  public int getMotorState(){
    return motorState;
  }
  
  public void samplePos(){
    this.samples.append(this.motorPos);
  }

  // private
}