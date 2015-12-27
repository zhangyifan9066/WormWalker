/*
 * Points cluster
 * @class
 */
class Cluster {
  private PVector center;
  public ArrayList<Integer> points;
  
  public Cluster(PVector center) {
    this.center = new PVector(center.x, center.y);
    //println(this.center);
    points = new ArrayList<Integer>();
  }
  
  public void addPoint(int pointIndex) {
    this.points.add(pointIndex);
  }
  
  public void updateCenter(PVector mVector) {
    //println(this.center);
    this.center.add(new PVector(round(mVector.x), round(mVector.y)));
  }
  
  public PVector getCenter() {
    return this.center;
  }
  
  public int getCenterIndex() {
    return (int)(this.center.x * imgWidth + this.center.y);
  }
  
  public void merge(Cluster c) {
    this.center.mult(this.points.size()).add(c.getCenter().mult(c.points.size())).div(this.points.size() + c.points.size());
    for (int i = 0; i < c.points.size(); i++) {
      if (!this.points.contains(c.points.get(i)))
        this.points.add(c.points.get(i));
    }
  }
  
  public void removePoint(int pointIndex) {
    if (this.points.contains(pointIndex)) {
      PVector point = new PVector(pointIndex / imgWidth, pointIndex % imgWidth);
      this.points.remove(new Integer(pointIndex));
      
      int size = this.points.size();
      if (size == 0)
        return;
      
      float x = ((float)(size + 1) * this.center.x - point.x) / (float)size;
      float y = ((float)(size + 1) * this.center.y - point.y) / (float)size;
      
      updateCenter(new PVector(x, y));
    }
  }
}