void errorBar(int x, int y, int w, int h, float errorMax){
  float padding = 5;
  float numEveryPixels = 100;
  
  pushStyle();
  colorMode(HSB);
  strokeWeight(1);
  for(int yoff = 0; yoff < h; yoff ++){
    stroke(map(yoff, 0, h, 0, 168), 255, 255);
    line(x, y + yoff, x + w, y + yoff);
  }
  stroke(255);
  noFill();
  rect(x, y, w, h);
  textAlign(LEFT, CENTER);
  int numLabels = floor(h/numEveryPixels);
  for(int i = 0; i <= numLabels; i ++){
    text(errorMax * (1 - (float)i/numLabels), x + w + padding, y + i * ((float)h/numLabels));
  }
  popStyle();
}

void coords(){
  float axisLength = 10; // All in all 20 = 10 + 10
  float arrowSize = 1;
  
  PVector currentAxis = new PVector(axisLength*2, 0, 0);
  pushMatrix();
  translate(-axisLength, 0, 0);
  showVector(currentAxis, color(255, 0, 0), arrowSize); // X Axis
  popMatrix();
  
  currentAxis.set(0, axisLength*2, 0);
  pushMatrix();
  translate(0, -axisLength, 0);
  showVector(currentAxis, color(0, 255, 0), arrowSize); // Y Axis
  popMatrix();
  
  currentAxis.set(0, 0, axisLength*2);
  pushMatrix();
  translate(0, 0, -axisLength);
  showVector(currentAxis, color(0, 0, 255), arrowSize); // Z Axis
  popMatrix();
}

void axes(){
  float axisLength = 5;
  float arrowSize = axisLength/10;
  
  pushStyle();
  
  PVector currentAxis = new PVector(axisLength, 0, 0);
  pushMatrix();
  showVector(currentAxis, color(255, 0, 0), arrowSize); // X Axis
  popMatrix();
  
  currentAxis.set(0, axisLength, 0);
  pushMatrix();
  showVector(currentAxis, color(0, 255, 0), arrowSize); // Y Axis
  popMatrix();
  
  currentAxis.set(0, 0, axisLength);
  pushMatrix();
  showVector(currentAxis, color(0, 0, 255), arrowSize); // Z Axis
  popMatrix();
}

void axes(PVector lengths, float arrowHeadSize){
  PVector currentAxis = new PVector(lengths.x, 0, 0);
  pushMatrix();
  showVector(currentAxis, color(255, 0, 0), arrowHeadSize); // X Axis
  popMatrix();
  
  currentAxis.set(0, lengths.y, 0);
  pushMatrix();
  showVector(currentAxis, color(0, 255, 0), arrowHeadSize); // Y Axis
  popMatrix();
  
  currentAxis.set(0, 0, lengths.z);
  pushMatrix();
  showVector(currentAxis, color(0, 0, 255), arrowHeadSize); // Z Axis
  popMatrix();
}

void cone(float d, float h){ // Cone pointing up the y-axis with a diameter of d and a height of h
  int vertCount = 16; // amount of vertices at the circle end
  float angle = TWO_PI/vertCount;
  
  PVector circ = new PVector(d/2, -h/2, 0);
  
  beginShape(TRIANGLE_FAN);
  vertex(0, h/2, 0);
  for(int i = 0; i <= vertCount; i ++){
    vertex(circ.x, circ.y, circ.z);
    rotateY(circ, angle);
  }
  endShape();
  
  beginShape(TRIANGLE_FAN);
  vertex(0, -h/2, 0); // not strictly necessary, but makes a nicer wireframe :D
  for(int i = 0; i <= vertCount; i ++){
    vertex(circ.x, circ.y, circ.z);
    rotateY(circ, angle);
  }
  endShape();
}

void cylinder(float d, float h){
  int vertCount = 16; // amount of vertices at the circle end
  float angle = TWO_PI/vertCount;
  
  PVector circ = new PVector(d/2, h/2, 0);
  beginShape(TRIANGLE_FAN);
  vertex(0, h/2, 0); // not strictly necessary, but makes a nicer wireframe :D
  for(int i = 0; i <= vertCount; i ++){
    vertex(circ.x, circ.y, circ.z);
    rotateY(circ, angle);
  }
  endShape();
  
  beginShape(QUAD_STRIP);
  for(int i = 0; i <= vertCount; i ++){
    vertex(circ.x, circ.y, circ.z);
    vertex(circ.x, -circ.y, circ.z);
    rotateY(circ, angle);
  }
  vertex(circ.x, circ.y, circ.z);
  endShape();
  
  circ.set(d/2, -h/2, 0);
  beginShape(TRIANGLE_FAN);
  vertex(0, -h/2, 0); // not strictly necessary, but makes a nicer wireframe :D
  for(int i = 0; i <= vertCount; i ++){
    vertex(circ.x, circ.y, circ.z);
    rotateY(circ, angle);
  }
  endShape();
}

void showVector(PVector v){
  showVector(v, color(255), 1);
}

void showVector(PVector v, color col, float arrowSize){
  pushStyle();
  
  PVector vEnd = v.copy();
  vEnd.setMag(vEnd.mag() - arrowSize/2);
  
  stroke(col);
  strokeWeight(arrowSize / 8);
  line(0, 0, 0, vEnd.x, vEnd.y, vEnd.z);
  
  noStroke();
  fill(col);
  
  pushMatrix();
  translate(vEnd.x, vEnd.y, vEnd.z);
  
  // What follows is angle *magic*
  PVector vProjXY = new PVector(v.x, v.y);
  float angle = signedAngleBetween(vProjXY, new PVector(0,1));
  rotateZ(angle);
  PVector vRotYZToXY = new PVector(v.z, vProjXY.mag()); // TODO: clean this up a bit
  angle = signedAngleBetween(vRotYZToXY, new PVector(0, 1));
  rotateX(-angle);
  cone(arrowSize/2, arrowSize);
  popMatrix();
  
  popStyle();
}

float signedAngleBetween(PVector a, PVector b){ // only for 2D vectors
  return PVector.angleBetween(a, b) * Math.signum(a.y*b.x - a.x*b.y);
}

PVector rotateY(PVector v, float angle){
  float tmpX = v.x;
  v.x = cos(angle)*v.x + sin(angle)*v.z;
  v.z = cos(angle)*v.z - sin(angle)*tmpX;
  return v;
}

PVector rotateX(PVector v, float angle){
  float tmpY = v.y;
  v.y = cos(angle)*v.y - sin(angle)*v.z;
  v.z = cos(angle)*v.z + sin(angle)*tmpY;
  return v;
}

float triangle(float x){
  return 2 * abs(x - floor(x + 0.5));
}

import java.util.Iterator;

Range range(int to){
  return new Range(to);
}

Range range(int from, int to){
  return new Range(from, to);
}

Range range(int from, int to, int step){
  return new Range(from, to, step);
}

class Range implements Iterable<Integer>{
  
  private int current;
  private int to;
  private int step;
  
  Range(int to){
    this(0, to, 1);
  }
  
  Range(int from, int to){
    this(from, to, 1);
  }
  
  Range(int from, int to, int step){
    if(step == 0) throw new IllegalArgumentException("Step can't be 0");
    this.current = from;
    this.to = to;
    this.step = step;
  }
  
  public Iterator<Integer> iterator(){
    return new RangeIterator();
  }
  
  class RangeIterator implements Iterator<Integer>{
    public boolean hasNext(){
      return current != to && ((step < 0) ^ (current < to));
    }
    
    public Integer next(){
      int tmp = current;
      current += step;
      return tmp;
    }
  }
}
