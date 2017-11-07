class Motor {

  ValueReceiver receiver;
  ValueSender sender;

  public float motorPosScaled = 0.0;
  public float motorTargetScaled = 0;

  // parameters to be received 
  public int motorPosRaw = 0;
  public int motorReady = 0;

  // parameters to be sent
  public int motorTargetRaw = 0;
  public int motorSpeed = 5000;
  public int doCalibrate = 0;

  int motorPos = 0;
  int id;
  
  Serial port;
  PApplet sketch;
  Motor(PApplet _sketch, String portName, int _id) {
    sketch = _sketch;
    id = _id;
    
    port = new Serial(this.sketch, portName, 115200);
    
    receiver = new ValueReceiver(this.sketch,port);
    sender = new ValueSender(this.sketch,port);
    
    receiver.observe("motorPosRaw").observe("motorReady");
    sender.observe("motorTargetRaw").observe("motorSpeed").observe("doCalibrate");
    
  }

// public

  public void handleData() {
    updatePos();
  }

  public void updateTarget(float inVal) {
    motorTargetScaled = inVal;
    this.motorTargetRaw = scaleVal(motorTargetScaled);
  }

  public boolean motorReady() {
    return motorReady != 0;
  }

  public void setNewSpeed(int inSpeed) {
    motorSpeed = inSpeed;
  }

  public void recalibrate() {
    doCalibrate = 1;
  }


// private

  private void updatePos() {
    this.motorPosScaled = normalizeVal(motorPosRaw);
  }

  private int scaleVal(float in) {
    return int(in * 32767);
  }

  private float normalizeVal(int in) {
    return float(in) / 32767.0;
  }

  /*
  
   public void requestPos() {
   this.serial.write("!getPos \r");
   println("requesting pos");
   received = false;
   }
   public void update() {
   if (online) {
   
   if (inString != null) {
   if (inString.charAt(0) == '!') {
   switch(inString.charAt(1)) {
   case 'p':
   {
   String param = inString.substring(2);
   posSteps = Integer.parseInt(param);
   pos = scaleDown(posSteps);
   println("Position: " + pos);
   received = true;
   break;
   }
   case 'r':
   {
   ready = true;
   break;
   }
   }
   } else {
   println(serial + ": " + inString);
   }
   inString = null;
   }
   }
   }
   */
}