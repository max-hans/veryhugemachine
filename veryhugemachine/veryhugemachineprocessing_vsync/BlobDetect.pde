PVector getMarkerPosition() {
  Blob b;
  int record = 0;
  int index = 0;
  int blobCount = theBlobDetection.getBlobNb();
  if (blobCount == 0) {
    calibrateDetection();
    blobCount = theBlobDetection.getBlobNb();
  }
  if (blobCount>0) {
    for (int n=0; n<blobCount; n++) {
      b = theBlobDetection.getBlob(n);
      if (b.getEdgeNb()>record) {
        index = n;
        record = b.getEdgeNb();
      }
    }
    b = theBlobDetection.getBlob(index);
    int edgeCount = b.getEdgeNb();
    float edgePoints[][] = new float[2][edgeCount];
    for (int i = 0; i<edgeCount; i++) {
      edgePoints[0][i] = b.getEdgeVertexA(i).x;
      edgePoints[1][i] = b.getEdgeVertexA(i).y;
    }
    PVector p = getAverage(edgeCount, edgePoints);

    return p;
  } else {
    return new PVector(0, 0);
  }
}

// ====================================================================================================

PVector getAverage(int coordCount, float incoordinates[][]) {
  float xAv = 0.0f;
  float yAv = 0.0f;
  for (int i = 0; i<coordCount; i++) {
    xAv += incoordinates[0][i];
    yAv += incoordinates[1][i];
  }
  xAv /= coordCount;
  yAv /= coordCount;
  return new PVector(xAv, yAv);
}

// ====================================================================================================

void calibrateDetection() {
  detectionThreshold = 0.5f;
  theBlobDetection.setThreshold(detectionThreshold);
  int count;
  do {
    count = updateBlobCount();
    detectionThreshold -= 0.001f;
    theBlobDetection.setThreshold(detectionThreshold);
    println(count);
    println(detectionThreshold);
  } while (count > 1 && detectionThreshold > 0);
}

// ====================================================================================================

int updateBlobCount() {
  img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);
  img.filter(INVERT);
  fastblur(img, 2);
  theBlobDetection.computeBlobs(img.pixels);
  return theBlobDetection.getBlobNb();
}

// ====================================================================================================

void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      //println(frameCount + ": " + b.getEdgeNb());

      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0, 255, 0);
        for (int m=0; m<b.getEdgeNb(); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }
    }
  }
}

// ====================================================================================================

// Super Fast Blur v1.1
// by Mario Klingemann 

void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0; i<256*div; i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0; y<h; y++) {
    rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0; x<w; x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0; y<h; y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}