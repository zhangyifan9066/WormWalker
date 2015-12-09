PImage refImg;

void setup() {
  size(1024, 512);
  refImg = loadImage("lena.gif");
  image(refImg, 0, 0);
  Cluster c = new Cluster(50, refImg); //<>//
  c.act();
  c.rendering();
}