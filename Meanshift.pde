import java.util.Map;

/*
 * Meanshift cluster
 * @class
 */
class Meanshift {
  private HashMap<Integer, Boolean> points;
  private int radius;
  
  public Meanshift(ArrayList<Integer> sample, int radius) {
    this.points = new HashMap<Integer, Boolean>();
    this.radius = radius;
    
    for (int i = 0; i < sample.size(); i++) {
      this.points.put(sample.get(i), false);
    }
  }
  
  private PVector calculateMVector(int pointIndex, Cluster c) {
    PVector mVector = new PVector(0.0, 0.0);
    PVector point = new PVector(pointIndex / imgWidth, pointIndex % imgWidth);
    //print("ss");
    //println(point);

    int count = 0;
    for (int i = (int)(point.x - this.radius); i <= (int)(point.x + this.radius); i++) {
      for (int j = (int)(point.y - this.radius); j <= (int)(point.y + this.radius); j++) {
        if (i >= 0 && i < imgHeight && j >= 0 && j < imgWidth) {
          int index = i * imgWidth + j;
          PVector targetPoint = new PVector(i, j);
          if (this.points.containsKey(index)) {
            if (calculateDistance(targetPoint, point) <= this.radius) {
              count++;
              this.points.put(index, true);
              if (!c.points.contains(index))
                c.addPoint(index);
              mVector.add(PVector.sub(targetPoint, point));
            }
          }
        }
      }
    }
    
    return count == 0 ? new PVector(0, 0) : mVector.div(count);
  }
  
  private Cluster findCluster(int startPointIndex) {
    PVector startPoint = new PVector(startPointIndex / imgWidth, startPointIndex % imgWidth);
    Cluster c = new Cluster(startPoint);
    //print("ss");
    PVector mVector = calculateMVector(startPointIndex, c);
    while (mVector.mag() > 2.0) {
      //print("haha");
      c.updateCenter(mVector);
      mVector = calculateMVector(c.getCenterIndex(), c);
      println(mVector);
    }
    println("ee");
    return c;
  }
  
  private float calculateDistance(PVector p1, PVector p2) {
    return PVector.dist(p1, p2);
  }
  
  private void mergeClusters(ArrayList<Cluster> clusters) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < clusters.size(); j++) {
        for (int k = j + 1; k < clusters.size();) {
          Cluster c1 = clusters.get(j);
          Cluster c2 = clusters.get(k);
          
          int count = 0;
          for (int ii = 0; ii < c1.points.size(); ii++) {
            if (c2.points.contains(c1.points.get(ii))) {
              count++;
              break;
            }
            /*for (int jj = 0; jj < c2.points.size(); jj++) {
              if (c1.points.get(ii) == c2.points.get(jj)) {
                count++;
              }
            }*/
          }
          
          //if ((float)count / c1.points.size() > 0.01 || (float)count / c2.points.size() > 0.01) {
          if (count > 0) {
            println("haha");
            c1.merge(c2);
            clusters.remove(k);
          } else {
            k++;
          }
          
          /*if (calculateDistance(c1.getCenter(), c2.getCenter()) < 50) {
            c1.merge(c2);
            clusters.remove(k);
          } else {
            k++;
          }*/
        }
      }
    }
  }
  
  public ArrayList<Cluster> act() {
    ArrayList<Cluster> clusters = new ArrayList<Cluster>(); //<>//
    
    int count = 0;
    for (Map.Entry ele : this.points.entrySet()) {
      if (count < 2) {
      if (!(boolean)ele.getValue()) {
        //count++;
        Cluster c = findCluster((int)ele.getKey());
        clusters.add(c);
      }
      }
    }
    
    mergeClusters(clusters);
    
    for (int i = 0; i < clusters.size();) {
      if ((float)clusters.get(i).points.size() / (float)this.points.size() < 0.001) {
        clusters.remove(i);
      } else {
        i++;
      }
    }
    
    return clusters;
  }
  
  
}