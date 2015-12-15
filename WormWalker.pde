// input
String imgName;
PImage img;
int imgWidth;
int imgHeight;
int totalPixel;
int totalCluster;
int totalWorm;

ArrayList<PVector> clusterColor;
int[] nearestCluster;
PVector[] pixelColor;

float MAX_LAB_ABERRATION = PVector.dist(new PVector(0.0, -128.0, -128.0), new PVector(100.0, 127.0, 127.0));

ArrayList<ArrayList<Integer>> colorGroup;
ArrayList<Worm> worms;

void setup() {
  size(1024, 512);
  
  imgName = "lena.gif";
  totalCluster = 5;
  totalWorm = 60;
  
  loadImg(imgName);
  
  Cluster c = new Cluster(totalCluster); //<>//
  c.act();
  c.rendering();
  clusterColor = c.getClusterCenter();
  
  groupUpPixels();
  
  initializeWorms(totalCluster);
}

/*void draw() {
  for (int i =  0; i < worms.size(); i++) {
    worms.get(i).crawl();
  }
}*/

void loadImg(String name) {
  img = loadImage(name);
  imgWidth = img.width;
  imgHeight = img.height;
  totalPixel = imgWidth * imgHeight;
}

void groupUpPixels() {
  colorGroup = new ArrayList<ArrayList<Integer>>();
  for (int i = 0; i < totalCluster; i++) {
    ArrayList<Integer> group = new ArrayList<Integer>();
    colorGroup.add(group);
  }
  
  for (int i = 0; i < totalPixel; i++) {
    int index = nearestCluster[i];
    colorGroup.get(index).add(i);
  }
}

void initializeWorms(int k) {
  worms = new ArrayList<Worm>();
  
  // calculate the worm count for each color
  float[] portion = new float[k];
  int[] wormCount = new int[k];
  for (int i = 0; i < k; i++) {
    portion[i] = (float)colorGroup.get(i).size() / (float)totalPixel;
    float delta = (totalWorm * portion[i]) - (int)(totalWorm * portion[i]);
    if (delta > 0.5f)
      wormCount[i] = (int)(totalWorm * portion[i]) + 1;
    else
      wormCount[i] = (int)(totalWorm * portion[i]);
  }
  int wormLeft = totalWorm;
  for (int i = 0; i < k; i++)
    wormLeft -= wormCount[i];
  wormCount[k - 1] += wormLeft;
  
  for (int i = 0; i < k; i++) {
    println(wormCount[i]);
  }
  
  // initialize each worm
  float limitDistance = sqrt(pow(imgWidth, 2.0f) + pow(imgHeight, 2.0f)) / 10.0f;
  for (int i = 0; i < k; i++) {
    ArrayList<Integer> chosenPos = new ArrayList<Integer>();
    for (int j = 0; j < wormCount[i]; j++) {
      int posIndex = 0;
      
      int loopDepth = 5;
      while (loopDepth > 0) {
        boolean toBreak = true;
        
        posIndex = (int)random(0, colorGroup.get(i).size());
        for (int kk = 0; kk < chosenPos.size(); kk++) {
          int cp = chosenPos.get(kk);
          if (getDistance(cp, posIndex) < limitDistance) {
            toBreak = false;
            break;
          }
        }   
        if (toBreak)
          break;
        loopDepth--;
      }
      int p = colorGroup.get(i).get(posIndex)
      chosenPos.add(p);
      
      
      int row = p / imgWidth;
      int col = p % imgWidth;
      PVector pos = new PVector(row, col);
      PVector v = new PVector(random(0, 1), random(0, 1));
      v.normalize();
      v.mult(5);
      Worm worm = new Worm(clusterColor.get(i), pos, v);
      worms.add(worm);
      
      color c = Lab2RGB(clusterColor.get(i));
      stroke(red(c), green(c), blue(c));
      fill(red(c), green(c), blue(c));
      
      ellipse(512 + col, row, 3, 3);
    }
  }
}

float getDistance(int p1, int p2) {
  PVector v1 = new PVector((int)(p1 % imgWidth), (int)(p1 / imgWidth));
  PVector v2 = new PVector((int)(p2 % imgWidth), (int)(p2 / imgWidth));
  return PVector.dist(v1, v2);
}