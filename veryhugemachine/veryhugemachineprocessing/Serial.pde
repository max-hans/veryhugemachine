
void sendPos(Serial s, float newPos){
  int scaledVal = (int)(newPos * 65535);
  s.write("!moveTo " + scaledVal + "\r");
}