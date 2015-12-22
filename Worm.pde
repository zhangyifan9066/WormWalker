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
  float strokeOpacity;
  int seekRadius;
  
  float G;
  
  public Worm(PVector c, PVector pos, PVector v) {
    this.c = c;
    this.pos = pos;
    this. v = v;
    this.strokeWeight = 3.0f;
    this.strokeOpacity = 128.0;
    this.seekRadius = 2;
    this.G = 10.0;
    
    this.rgb = Lab2RGB(this.c);
  }
  
  private PVector seek() {
    PVector force = calculateTotalForce();
    this.v.add(force.mult(1.0)).normalize().mult(random(2.5, 3.5));
    PVector newPos = new PVector(this.pos.x + (float)round(v.x * 1.0), this.pos.y + (float)round(v.y * 1.0));
    return newPos;
  }
  
  public void crawl() {
    PVector newPos = seek();
    //println(newPos);
    
    if (newPos.x >= 0 && newPos.x < imgHeight && newPos.y >= 0 && newPos.y < imgWidth) {
      float aberration = calculateAberration(pixelColor[(int)(this.pos.x * imgWidth + this.pos.y)], this.c);
      float newAberration = calculateAberration(pixelColor[(int)(newPos.x * imgWidth + newPos.y)], this.c);
      
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
    }
    
    strokeWeight(this.strokeWeight);
    stroke(red(this.rgb), green(this.rgb), blue(this.rgb), this.strokeOpacity);
    line(this.pos.y, this.pos.x, newPos.y, newPos.x);
    
    this.pos = newPos;
    if (newPos.x < 0 || newPos.x >= imgHeight || newPos.y < 0 || newPos.y >= imgWidth) {
      this.pos = new PVector((int)random(0, imgHeight), (int)(random(0, imgWidth)));
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
}