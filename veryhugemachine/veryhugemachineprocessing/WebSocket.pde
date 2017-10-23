void sendData(){
  wsc.sendMessage(markerPos.x + "," + markerPos.y);
}

void activateLearning(){
  wsc.sendMessage("enableLearning");
}