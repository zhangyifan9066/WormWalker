/*
 * Worm
 * @class
 */
class Worm {
  PVector c;
  color rgb;
  PVector pos;
  PVector v;
  float strokeWeight;
  int seekRadius;
  
  float G;
  
  public Worm(PVector c, PVector pos, PVector v) {
    this.c = c;
    this.pos = pos;
    this. v = v;
    this.strokeWeight = 1.0f;
    this.seekRadius = 1;
    this.G = 10.0;
    
    this.rgb = Lab2RGB(thsis.c);
  }
  
  private PVector seek() {
    PVector force = calculateTotalForce();
    this.v.add(force.mult(1.0)).normalize().mult(2.0);
    PVector newPos = new PVector(this.pos.x + (float)round(v.x * 1.0), this.pos.y + (float)round(v.y * 1.0));
    return newPos;
  }
  
  public void crawl() {
    PVector newPos = seek();
    //println(newPos);
    stroke(red(this.rgb), green(this.rgb), blue(this.rgb));
    line(this.pos.y, this.pos.x, newPos.y, newPos.x);
    
    this.pos = newPos;
    if (newPos.x < 0 || newPos.x >= imgHeight || newPos.y < 0 || newPos.y >= imgWidth) {
      this.pos = new PVector(round(random(0, imgHeight - 1)), round(random(0, imgWidth)));
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
   * Calculate the total force within the seeking range;
   */
  private PVector calculateTotalForce() {
    PVector force = new PVector(0.0, 0.0);
    
    for (int i = (int)(this.pos.y - this.seekRadius); i <= (int)(this.pos.y + this.seekRadius); i++) {
      for (int j = (int)(this.pos.x - this.seekRadius); j <= (int)(this.pos.x + this.seekRadius); j++) {
        if (i >= 0 && i < imgHeight && j >= 0 && j < imgWidth) {
          int index = i * imgWidth + j;
          PVector targetPos = new PVector(j, i);
          float forceMagnitude = calculateForceMagnitude(targetPos, pixelColor[index], 1.0);
          force.add(targetPos.sub(this.pos).normalize().mult(forceMagnitude));
        }
      }
    }
    
    //println(force);
    return force;
  }
  
  /*
   * Calculate the chromatic aberration of 2 Lab color  
   */
  private float calculateAberration(PVector c1, PVector c2) {
    return PVector.dist(c1, c2);
  }
  
  /*
   * Calculate the distance of 2 points  
   */
  private float calculateDistance(PVector p1, PVector p2) {
    return PVector.dist(p1, p2);
  }
}