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
}
