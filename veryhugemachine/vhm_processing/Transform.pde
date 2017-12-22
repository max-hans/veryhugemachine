void resetTransformArray(PImage _imgT) {
  transformPoints.add(new PVector(_imgT.width-transformOffset, transformOffset));
  transformPoints.add(new PVector(transformOffset, transformOffset));
  transformPoints.add(new PVector(transformOffset, _imgT.height-transformOffset));
  transformPoints.add(new PVector(_imgT.width-transformOffset, _imgT.height-transformOffset));
}