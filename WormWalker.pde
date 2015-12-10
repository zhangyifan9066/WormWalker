PImage refImg;
PVector[] pixelColor;
int[] nearestCluster;
ArrayList<ArrayList<Integer>> colorGroup;
int totalWorm;
ArrayList<Worm> worms;

void setup() {
  int k = 5;
  totalWorm = 10;
  
  size(1024, 512);
  refImg = loadImage("lena.gif");
  image(refImg, 0, 0);
  Cluster c = new Cluster(k, refImg); //<>//
  c.act();
  c.rendering();
  
  pixelColor = new PVector[refImg.width * refImg.height];
  nearestCluster = new int[refImg.width * refImg.height];
  ArrayList<PVector> clusterColor = new ArrayList<PVector>();
  colorGroup = new ArrayList<ArrayList<Integer>>();
  
  pixelColor = c.getPixelColor();
  nearestCluster = c.getNearestCluster();
  clusterColor = c.getClusterCenter();
  for (int i = 0; i < k; i++) {
    ArrayList<Integer> group = new ArrayList<Integer>();
    colorGroup.add(group);
  }
  
  for (int i = 0; i < refImg.width * refImg.height; i++) {
    int index = nearestCluster[i];
    colorGroup.get(index).add(i);
  }
  /*colorGroup.get(0).add(1);
  for (int i = 0; i < 2; i++) {
    println(colorGroup.get(i).size());
  }*/
}

void initializeWorms(ArrayList<PVector> clusterColor, int k) {
  int totalPixel = refImg.width * refImg.height;
  float[] portion = new float[k];
  int[] wormCount = new int[k];
  
  worms = new ArrayList<Worm>();
  
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
    for (int j = 0; j < wormCount[i]; j++) {
      int posIndex = (int)random(0, colorGroup.get(i).size());
      int row = posIndex / refImg.width;
      int col = posIndex % refImg.width;
      PVector pos = new PVector(col, row);
      PVector v = new PVector(random(0, 1), random(0, 1));
      v.normalize();
      v.mult(5);
      Worm worm = new Worm(clusterColor.get(i), pos, v);
      worms.add(worm);
    }
  }
}