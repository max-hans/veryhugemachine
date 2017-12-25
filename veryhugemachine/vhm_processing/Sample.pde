class Sample{

  private float[] data = new float[4];

  Sample(float _x, float _y, float _a1, float _a2){
    data[0] = _x;
    data[1] = _y;
    data[2] = _a1;
    data[3] = _a2;
  }

  public float getX(){
    return data[0];
  }

  public float getY(){
    return data[1];
  }

  public void printData(){
    for(int i = 0; i<data.length;i++){
      print(data[i]);
      if(i == data.length-1){
        println();
      }
      else{
        print(" - ");
      }
    }
  }

  public String dataToString(){
    String str = "";
    for(int i = 0; i<data.length;i++){
      str += data[i];
      if(i != 3){
        str+=",";
      }
    }
    return str;
  }
}
