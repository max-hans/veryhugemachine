class Motor {
  private int lf = 10;
  private String inString = null;
  private Serial serial;
  float pos = 0;
  boolean ready = false;

  Motor(Serial _serial) {
    serial = _serial;
    serial.clear();
  }

  public float getPos() {
    return pos;
  }

  public void moveTo(float pos) {
    this.serial.write("!moveTo " + scaleUp(pos) + "\r");
  }

  public void recalibrate() {
    this.serial.write("!recalibrate\r");
  }

  public void requestPos() {
    this.serial.write("!getPos\r");
  }
  
  public void setNewSpeed(int speed){
    this.serial.write("!setSpeed " + speed + "\r");
  }

  public void update() {
    while (this.serial.available() > 0) {
      inString = serial.readStringUntil(lf);
    } if(inString != null){
      switch(inString.charAt(0)) {
      case 'p':
        {
          String param = inString.substring(1);
          pos = scaleDown(Integer.parseInt(param));
          break;
        }
      case 'r':
        {
          inString = "";
          ready = true;
        }
      }
    }
  }

  private int scaleUp(float in) {
    return (int)(in * 32767);
  }

  private float scaleDown(int in) {
    return float(in) / 32767.0;
  }
}