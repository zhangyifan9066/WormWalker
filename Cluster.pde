/*
 * K-means cluster
 * @class
 */
class Cluster {
  private int k;
  private ArrayList<PVector> prevClusterCenter;
  private ArrayList<PVector> clusterCenter;
  private PImage img;
  private PVector[] imgPixels;
  private int nearestCluster[];
  /*
   * @constructor
   */
  public Cluster(int k, PImage img) {
    this.k = k;
    this.img = img;

    initializeClusterCenter();
    initializeImgPixels();
    initializeNearestCluster();
  }
  
  private void initializeClusterCenter() {
    this.prevClusterCenter =new ArrayList<PVector>();
    this.clusterCenter = new ArrayList<PVector>();
    for (int i = 0; i < k; i++) {
      PVector p = new PVector(random(0, 100),
                              random(-128, 127),
                              random(-128, 127));
      this.prevClusterCenter.add(p);
      this.clusterCenter.add(p);
    }
  }
  
  private void initializeImgPixels() {
    this.imgPixels = new PVector[img.width * img.height];
    for (int i = 0; i < img.width * img.height; i++) {
      this.imgPixels[i] = RGB2Lab(img.pixels[i]);
    }
  }
  
  private void initializeNearestCluster() {
    this.nearestCluster = new int[img.width * img.height];
    //for (int i = 0; i < img.width * img.height; i++)
    //  this.nearestCluster[i] = -1;
  }
  
  /*
   * Calculate the chromatic aberration of 2 Lab color  
   */
  private float calculateDistance(PVector c1, PVector c2) {
    return PVector.dist(c1, c2);
  }
  
  private void findNearestCluster() {
    for (int i = 0; i < img.width * img.height; i++) {
      float nearestDistance = calculateDistance(prevClusterCenter.get(0), imgPixels[i]);
      this.nearestCluster[i] = 0;
      for (int j = 1; j < k; j++) {
        float distance = calculateDistance(prevClusterCenter.get(j), imgPixels[i]);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          this.nearestCluster[i] = j;
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
    
    for (int i = 0; i < img.width * img.height; i++) {
      int index = nearestCluster[i];
      count[index]++;
      sum[index].add(imgPixels[i]);
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
        if (calculateDistance(this.prevClusterCenter.get(i), this.clusterCenter.get(i)) > 1.0) {
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
  }
  
  public void rendering() {
    color[] centerColor = new color[k];
    for (int i = 0; i < k; i++) {
      centerColor[i] = Lab2RGB(this.clusterCenter.get(i));
      //println(this.clusterCenter.get(i));
      //println(centerColor[i]);
    }
      
    img.loadPixels();
    for (int i = 0; i < img.width * img.height; i++) {
      int index = this.nearestCluster[i];  
      img.pixels[i] = centerColor[index];
    }
    img.updatePixels();
    
    image(img, 512, 0);
  }
}