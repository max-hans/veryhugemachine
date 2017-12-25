// Websocket

void wsSendSample(Sample sendSample){

  print("sending command -> new data : ");
  String msg = "ip,";
  for(int i = 0; i<4;i++){
    msg+=sendSample.data[i];
    if(i!=3){
      msg+=',';
    }
  }
  println(msg.substring(3));
  wsc.sendMessage(msg);
}

void activateLearning() {
  println("sending command -> start learning");
  wsc.sendMessage("l");
}

void requestData(float _x, float _y){
  println("sending command -> request data");
  String msg = "o," + _x + "," + _y;
  wsc.sendMessage(msg);
}

void saveNetToFile(String filename){
  println("sending command -> save net");
  String msg = "s," + filename;
  wsc.sendMessage(msg);
}

void webSocketEvent(String msg){
  if(waitingForPos){
    waitingForPos = false;
    String[] inData = split(msg,',');

  }
}

void commandMotors(float _x, float _y){
  motorArray[0].setTarget(_x);
  motorArray[1].setTarget(_y);
}
