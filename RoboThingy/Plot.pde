class ContinuousPlot{
  float x, y, w, h, min, max;
  color col;
  String label;
  Ringbuffer<Float> values;
  
  float textSize = 15;
  float padding = 5;
  
  public ContinuousPlot(float x, float y, float w, float h, float min, float max, color col, String label, int numValues){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.min = min;
    this.max = max;
    this.col = col;
    this.label = label;
    this.values = new Ringbuffer(numValues, 0f);
  }
  
  public void addValue(float value){
    values.add(value);
  }
  
  public void show(){
    pushMatrix();
    pushStyle();
    
    translate(x, y);
    stroke(255);
    strokeWeight(1);
    noFill();
    rectMode(CORNER);
    
    rect(0, 0, w, h);
    
    
    noFill();
    stroke(col);
    strokeWeight(2);
    beginShape();
    int numValues = values.size();
    for(int i = 0; i < numValues; i ++){
      vertex(map(i, 0, numValues, 0, w), map(fmod(values.get(i) - min, max - min) + min, min, max, h, 0));
    }
    endShape();
    
    textSize(textSize);
    fill(255);
    
    textAlign(LEFT, TOP);
    text(max, w + padding, -textSize/3);
    textAlign(LEFT, BOTTOM);
    text(min, w + padding, h + textSize/3);
    
    fill(255);
    textSize(h/2);
    textAlign(LEFT, CENTER);
    text(label, padding, h/2, 1);
    
    popStyle();
    popMatrix();
  }
}

class Ringbuffer<T>{
  int currentIndex;
  private Object[] values;
  
  public Ringbuffer(int capacity, Object zero){
    currentIndex = 0;
    values = new Object[capacity];
    for(int i = 0; i < capacity; i ++){
      values[i] = zero;
    }
  }
  
  public T get(int index){
    return (T)values[Math.floorMod(currentIndex + index + 1, size())];
  }
  
  public int size(){
    return values.length;
  }
  
  public void add(float value){
    currentIndex = (currentIndex + 1) % size();
    values[currentIndex] = value;
  }
  
}
