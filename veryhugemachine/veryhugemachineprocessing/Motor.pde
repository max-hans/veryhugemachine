class Motor {
  int id;
  char lf = '\r';
  private String inString = "";
  private Serial serial;
  public boolean received = false;

  float pos = 0;
  int posSteps = 0;

  boolean ready = false;
  boolean online = false;

  Motor(int _id) {
    id = _id;
  }

  public float getPos() {
    return pos;
  }

  public void startConnection(Serial _serial) {
    this.serial = _serial;
    this.serial.clear();
    this.serial.bufferUntil(lf);
    online = true;
  }
  
  void serialEvent(Serial p){
    String cmd = p.readString();
    print(cmd);
  }

  public void moveTo(float pos) {
    this.serial.write("!moveTo 0" + scaleUp(pos) + "\r");
  }

  public void recalibrate() {
    this.serial.write("!recalibrate\r");
  }

  public void requestPos() {
    this.serial.write("!getPos \r");
    println("requesting pos");
    received = false;
  }

  public void setNewSpeed(int speed) {
    this.serial.write("!setSpeed " + speed + "\r");
  }
 
 
  /*
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

  private int scaleUp(float in) {
    return (int)(in * 32767);
  }

  private float scaleDown(int in) {
    return float(in) / 32767.0;
  }
}