/*
 * Worm
 * @class
 */
class Worm {
  PVector c;
  color rgb;
  PVector pos;
  PVector prevPos;
  PVector v;
  float strokeWeight;
  float strokeOpacity;
  int seekRadius;
  int edgeCount;
  int stepCount;
  float step;
  
  PVector prevColor;

  ArrayList<Cluster> clusters;
  ArrayList<Integer> pointIndexes;

  float G;

  public Worm(PVector c, PVector pos, PVector v, ArrayList<Cluster> clusters, ArrayList<Integer> pointIndexes) {
    this.c = new PVector(c.x, c.y, c.z);
    this.pos = new PVector(pos.x, pos.y);
    this.prevPos = new PVector(pos.x, pos.y);
    this.v = v;
    this.clusters = clusters;
    this.pointIndexes = pointIndexes;
    this.strokeWeight = 3.0f;
    this.strokeOpacity = 128.0;
    this.seekRadius = 4;
    this.edgeCount = 0;
    this.stepCount = 0;
    this.G = 10.0;

    this.step = this.seekRadius / 1.66;

    this.rgb = Lab2RGB(this.c);
  }

  private PVector seek() {
    PVector force = calculateTotalForce();
    this.v.add(force.mult(1.0)).normalize().mult(this.step);
    PVector newPos = new PVector(this.pos.x + (float)round(v.x * 1.0), this.pos.y + (float)round(v.y * 1.0));

    return newPos;
  }

  public void crawl() {
    PVector newPos = seek();

    if (newPos.x >= 0 && newPos.x < imgHeight && newPos.y >= 0 && newPos.y < imgWidth) {
      PVector prevDir = PVector.sub(this.pos, this.prevPos);
      PVector newDir = PVector.sub(newPos, this.pos);
      float angleBetween = degrees(PVector.angleBetween(prevDir, newDir));

      PVector a = PVector.add(this.pos, prevDir.normalize().mult(this.seekRadius));
      a.x = (float)round(a.x);
      a.y = (float)round(a.y);
      PVector aColor = this.c;
      if (a.x >= 0 && a.x < imgHeight && a.y >= 0 && a.y < imgWidth) {
        int aIndex = nearestCluster[(int)(a.x * imgWidth + a.y)];
        aColor = clusterColor.get(aIndex);
      }
      
      /*if (this.seekRadius == 6) {
        if (PVector.dist(aColor, this.c) > 0.00001) {// && this.c.x - aColor.x > 0) {
          if (angleBetween > 70) {
            this.step = this.seekRadius / 2.0;
            this.seekRadius = 12;
            
            PVector cc = new PVector(this.c.x, this.c.y, this.c.z);
            this.prevColor = new PVector(aColor.x, aColor.y, aColor.z);
            changeColor(aColor);
            newPos = seek();
            changeColor(cc);
            
            this.strokeWeight = 0.5;
            this.strokeOpacity = 128;
          }
        }
      }
      
      if (this.seekRadius == 12) {
        if (this.stepCount == 1) {
          changeColor(prevColor);
          newPos = seek();
        }
        this.stepCount++;
      }
      if (this.stepCount == 2) {
        this.stepCount = 0;
        this.seekRadius = 6;
        this.step = this.seekRadius / 2.7;
      }*/

      if (angleBetween > 140 && PVector.dist(aColor, this.c) > 0.00001) {
        if (this.edgeCount < 2) {
          this.edgeCount++;
        } else {
          println("ch");
          /*this.strokeOpacity = 128;
           this.strokeWeight = 1;
           changeColor(aColor);*/
          //this.seekRadius = 7;
          this.edgeCount = 0;
          newPos = PVector.add(this.pos, prevDir.normalize().mult(this.seekRadius));
          newPos.x = (float)round(newPos.x);
          newPos.y = (float)round(newPos.y);

          if (newPos.x >= 0 && newPos.x < imgHeight && newPos.y >= 0 && newPos.y < imgWidth) {
            int newColorIndex = nearestCluster[(int)(newPos.x * imgWidth + newPos.y)];
            PVector newColor = clusterColor.get(newColorIndex);

            if (PVector.dist(this.c, newColor) > 0.00001) {
              PVector delta = prevDir.normalize().mult(random(2.5, 3.5)).rotate(random(-HALF_PI, HALF_PI));
              PVector tmp = new PVector((int)(this.pos.x + delta.x), (int)(this.pos.y + delta.y));
              this.v.add(delta);
              strokeWeight(1);
              this.strokeOpacity = 128;
              this.strokeWeight = 1;
              //stroke(255, 0, 0);
              line((int)this.pos.y, (int)this.pos.x, (int)tmp.y, (int)tmp.x);
              changeColor(newColor);
              //stroke(red(this.rgb), green(this.rgb), blue(this.rgb));
              //line((int)((this.pos.y + newPos.y) / 2.0), (int)((this.pos.x + newPos.x) / 2.0), (int)newPos.y, (int)newPos.x);

              this.prevPos = this.pos;
              this.pos = tmp;
              newPos = seek();
            } else {
              newPos = seek();
            }
          }



          //newPos = seek();
        }
      }

      newPos.x = (float)round(newPos.x);
      newPos.y = (float)round(newPos.y);
      this.pos.x = (int)this.pos.x;
      if ((int)this.pos.x == 512)
        this.pos.x = 511;
      if ((int)this.pos.x == -1)
        this.pos.x = 0;
      this.pos.y = (int)this.pos.y;
      if (newPos.x >= 0 && newPos.x < imgHeight && newPos.y >= 0 && newPos.y < imgWidth) {

        float aberration = calculateAberration(pixelColor[(int)(this.pos.x * imgWidth + this.pos.y)], this.c);
        float newAberration = calculateAberration(pixelColor[(int)(newPos.x * imgWidth + newPos.y)], this.c);

        /*int minIndex = 0;
         float minAberration = calculateAberration(pixelColor[(int)(newPos.x * imgWidth + newPos.y)], clusterColor.get(0));
         for (int i = 1; i < totalCluster; i++) {
         float newColorAberration = calculateAberration(pixelColor[(int)(newPos.x * imgWidth + newPos.y)], clusterColor.get(i));
         if (newColorAberration < minAberration) {
         minIndex = i;
         minAberration = newColorAberration;
         }
         }
         if (abs(minAberration - newAberration) > 0.0001 && this.seekRadius == 7) {
         println("changed"); 
         changeColor(clusterColor.get(minIndex));
         this.seekRadius = 8;
         }*/

         /*int newColorIndex = nearestCluster[(int)(newPos.x * imgWidth + newPos.y)];
         PVector newColor = clusterColor.get(newColorIndex);
         changeColor(newColor);*/

        float factor = (aberration - newAberration) / aberration;
        //factor = factor < 0 ? 0 : factor;
        float limit = ((1 - newAberration / MAX_LAB_ABERRATION) - 0.80) / 0.3;
        limit = limit < 0 ? 0 : limit;

        float limitWeight = (0.25 + 2.75 * limit);
        float limitOpacity = (20 + 235 * limit);
        if (factor >= 0) {
          this.strokeWeight = this.strokeWeight > limitWeight ? limitWeight : this.strokeWeight;
          this.strokeOpacity = this.strokeOpacity > limitOpacity ? limitOpacity : this.strokeOpacity;
        } else {
          this.strokeWeight = this.strokeWeight < limitWeight ? limitWeight : this.strokeWeight;
          this.strokeOpacity = this.strokeOpacity < limitOpacity ? limitOpacity : this.strokeOpacity;
        }
        this.strokeWeight *= (1 + factor);
        this.strokeOpacity *= (1 + factor);

        this.strokeWeight = this.strokeWeight > 3 ? 3 : this.strokeWeight;
        this.strokeOpacity = this.strokeOpacity > 255 ? 255 : this.strokeOpacity;
        this.strokeWeight = this.strokeWeight < 0.25 ? 0.25 : this.strokeWeight;
        this.strokeOpacity = this.strokeOpacity < 20 ? 20 : this.strokeOpacity;

        /*int newPosIndex = (int)newPos.x * imgWidth + (int)newPos.y;
         if (this.pointIndexes.contains(newPosIndex)) {
         if (visitedDepth[newPosIndex] == 0) {
         for (int i = 0; i < this.clusters.size(); i++) {
         Cluster c = this.clusters.get(i);
         if (c.points.contains(newPosIndex)) {
         c.removePoint(newPosIndex);
         }
         }
         this.pointIndexes.remove(new Integer(newPosIndex));
         }
         visitedDepth[newPosIndex]++;
         }*/
      }
    }

    strokeWeight(this.strokeWeight);
    //if (this.seekRadius != 9)
      stroke(red(this.rgb), green(this.rgb), blue(this.rgb), this.strokeOpacity);
    //else
      //stroke(255, 0, 0);
    line(this.pos.y, this.pos.x, newPos.y, newPos.x);

    this.prevPos = this.pos;
    this.pos = newPos;
    if (newPos.x < 0 || newPos.x >= imgHeight || newPos.y < 0 || newPos.y >= imgWidth) {
      this.pos = new PVector((int)random(0, imgHeight), (int)(random(0, imgWidth)));
      this.prevPos = new PVector(this.pos.x, this.pos.y);
      this.edgeCount = 0;
    }
  }

  /*
   * Calculate the magnitude of the force from the target point
   */
  private float calculateForceMagnitude(PVector targetPos, PVector targetColor, float weight) {
    float distance = calculateDistance(targetPos, this.pos);
    float aberration = calculateAberration(targetColor, this.c);
    float force = 0.0; 

    if (distance > 0.00000001)
      force = this.G * pow(((1 - aberration / MAX_LAB_ABERRATION) / distance), 2.0) * weight;
    //println(pow((1 - aberration / MAX_LAB_ABERRATION), 2.0));
    //println(this.pos);
    //println(force);
    return force;
  }

  /*
   * Calculate the magnitude of the force from the target point
   */
  private float calculateForceMagnitude1(PVector targetPos, PVector targetColor, float weight) {
    float distance = calculateDistance(targetPos, this.pos);
    float aberration = calculateAberration(targetColor, this.c);
    float force = 0.0; 

    if (distance > 0.00000001)
      force = this.G * pow((1 - aberration / MAX_LAB_ABERRATION) / distance, 2.0) * weight;
    //println(pow((1 - aberration / MAX_LAB_ABERRATION), 2.0));
    //println(this.pos);
    //println(force);
    return force;
  }

  /*
   * Calculate the total force within the seeking range;
   */
  private PVector calculateTotalForce() {
    PVector force = new PVector(0.0, 0.0);

    for (int i = (int)(this.pos.x - this.seekRadius); i <= (int)(this.pos.x + this.seekRadius); i++) {
      for (int j = (int)(this.pos.y - this.seekRadius); j <= (int)(this.pos.y + this.seekRadius); j++) {
        if (i >= 0 && i < imgHeight && j >= 0 && j < imgWidth) {
          int index = i * imgWidth + j;
          PVector targetPos = new PVector(i, j);
          float forceMagnitude = calculateForceMagnitude(targetPos, pixelColor[index], 1.0);
          force.add(targetPos.sub(this.pos).normalize().mult(forceMagnitude));
        }
      }
    }

    /*for (int i = 0; i < this.clusters.size(); i++) {
     Cluster cluster = this.clusters.get(i);
     PVector targetPos = new PVector(cluster.getCenter().x, cluster.getCenter().y);
     float forceMagnitude = calculateForceMagnitude1(targetPos, this.c, (float)cluster.points.size()) * 50 * cluster.points.size() / (float)this.pointIndexes.size();
     PVector tmp = PVector.sub(targetPos, this.pos);
     tmp.normalize().mult(forceMagnitude);
     //println(tmp);
     force.add(targetPos.sub(this.pos).normalize().mult(forceMagnitude));
     }*/

    //println(force);
    return force;
  }

  /*
   * Calculate the chromatic aberration of 2 Lab color  
   */
  private float calculateAberration(PVector c1, PVector c2) {
    return PVector.dist(c1, c2);
    //return PVector.dist(new PVector(c1.y, c1.z), new PVector(c2.y, c2.z));
  }

  /*
   * Calculate the distance of 2 points  
   */
  private float calculateDistance(PVector p1, PVector p2) {
    return PVector.dist(p1, p2);
  }

  private void changeColor(PVector c) {
    this.c.x = c.x;
    this.c.y = c.y;
    this.c.z = c.z;

    this.rgb = Lab2RGB(this.c);
  }
}