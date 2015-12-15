/*
 * K-means cluster
 * @class
 */
class Cluster {
  private boolean enable;
  private int k;
  private ArrayList<PVector> prevClusterCenter;
  private ArrayList<PVector> clusterCenter;
  
  /*
   * @constructor
   */
  public Cluster(int k) {
    setK(k);
  }
  
  private void setK(int k) {
    this.k = k;
    this.enable = true;
    
    initializepixelColor();
    initializeClusterCenter();
    initializeNearestCluster();
  }
  
  private float calculateNearestDistance(PVector c) {
    if (this.prevClusterCenter.size() == 0)
      return 0.0;
      
    float distance = calculateAberration(this.prevClusterCenter.get(0), c);
    for (int i = 1; i < this.prevClusterCenter.size(); i++) {
      float d = calculateAberration(this.prevClusterCenter.get(i), c);
      if (d < distance)
        distance = d;
    }
    
    return distance;
  }
  
  private void initializeClusterCenter() {
    this.prevClusterCenter = new ArrayList<PVector>();
    this.clusterCenter = new ArrayList<PVector>();
    /*for (int i = 0; i < k; i++) {
      PVector p = new PVector(random(0, 100),
                              random(-128, 127),
                              random(-128, 127));
      this.prevClusterCenter.add(p);
      this.clusterCenter.add(p);
    }*/
    
    float[] d = new float[totalPixel];
    float sum = 0.0;
    int index = (int)random(0, totalPixel);
    this.prevClusterCenter.add(pixelColor[index]);
    
    for (int i = 1; i < k; i++) {
      sum = 0.0;
      for (int j = 0; j < totalPixel; j++) {
        d[j] = calculateNearestDistance(pixelColor[j]);
        sum += d[j];
      }
      sum = random(0, sum);
      for (int j = 0; j < totalPixel; j++) {
         sum -= d[j];
         if (sum > 0)
           continue;
         this.prevClusterCenter.add(pixelColor[j]);
         break;
      }
    }
    
    for (int i = 0; i < k; i++) {
      this.clusterCenter.add(this.prevClusterCenter.get(i));
    }
  }
  
  private void initializepixelColor() {
    pixelColor = new PVector[totalPixel];
    for (int i = 0; i < totalPixel; i++) {
      pixelColor[i] = RGB2Lab(img.pixels[i]);
    }
  }
  
  private void initializeNearestCluster() {
    nearestCluster = new int[totalPixel];
    //for (int i = 0; i < img.width * img.height; i++)
    //  this.nearestCluster[i] = -1;
  }
  
  /*
   * Calculate the chromatic aberration of 2 Lab color  
   */
  private float calculateAberration(PVector c1, PVector c2) {
    return PVector.dist(c1, c2);
  }
  
  private void findNearestCluster() {
    for (int i = 0; i < totalPixel; i++) {
      float nearestDistance = calculateAberration(prevClusterCenter.get(0), pixelColor[i]);
      nearestCluster[i] = 0;
      for (int j = 1; j < k; j++) {
        float distance = calculateAberration(prevClusterCenter.get(j), pixelColor[i]);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestCluster[i] = j;
        }
      }
    }
  }
  
  private void calculateClusterCenter() {
    int count[] = new int[k];
    PVector sum[] = new PVector[k];
    
    for (int i = 0; i < k; i++) {
      count[i] = 0;
      sum[i] = new PVector(0.0f, 0.0f, 0.0f);
    }
    
    for (int i = 0; i < totalPixel; i++) {
      int index = nearestCluster[i];
      count[index]++;
      sum[index].add(pixelColor[i]);
    }
    
    for (int i = 0; i < k; i++) {
      if (count[i] > 0) {
        this.clusterCenter.set(i, sum[i].div(count[i]));
      } else {
        this.clusterCenter.set(i, prevClusterCenter.get(i));
      }
    }
  }
  
  private void updateClusterCenter() {
    for (int i = 0; i < k; i++)
      this.prevClusterCenter.set(i, this.clusterCenter.get(i));
  }    
  
  public void act() {
    while (true) {
      findNearestCluster();
      calculateClusterCenter();
      
      boolean toStop = true; //<>//
      for (int i = 0; i < k; i++) {
        if (calculateAberration(this.prevClusterCenter.get(i), this.clusterCenter.get(i)) > 1.0) {
          toStop = false;
          break;
        }
      }
      
      if (!toStop) {
        updateClusterCenter();
      } else {
        break;
      }
    }
    
    this.enable = false;
  }
  
  public void rendering() {
    color[] centerColor = new color[k];
    for (int i = 0; i < k; i++) {
      centerColor[i] = Lab2RGB(this.clusterCenter.get(i));
      //println(this.clusterCenter.get(i));
      //println(centerColor[i]);
    }
      
    img.loadPixels();
    for (int i = 0; i < totalPixel; i++) {
      int index = nearestCluster[i];  
      img.pixels[i] = centerColor[index];
    }
    img.updatePixels();
    
    image(img, 512, 0);
  }
  
  public void reAct() {
    setK(this.k);
    act();
  }

  public ArrayList<PVector> getClusterCenter() {
    return this.clusterCenter;
  }
}