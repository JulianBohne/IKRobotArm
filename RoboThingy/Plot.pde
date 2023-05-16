
class ContinuousPlot{
  float x, y, w, h, min, max;
  boolean autoScale = true;
  boolean autoMinScale = true;
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
    
    if(autoMinScale){
      float actMin = Float.MAX_VALUE;
      float actMax = -Float.MAX_VALUE;
      for(Object obj : values.getValues()){ // Not the most efficient to do this every time, but computers are fast xD
        actMin = min((Float)obj, actMin);
        actMax = max((Float)obj, actMax);
      }
      min = min(lerp(min, actMin, 0.1), actMin);
      max = max(lerp(max, actMax, 0.1), actMax);
      if(min == max){
        max += 0.0001;
        min -= 0.0001;
      }
    }else if(autoScale){
      min = min(min, value);
      max = max(max, value);
    }
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
    float currentValue;
    for(int i = 0; i < numValues; i ++){
      currentValue = autoScale ? values.get(i) : fmod(values.get(i) - min, max - min) + min;
      vertex(map(i, 0, numValues, 0, w), map(currentValue, min, max, h, 0));
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
  
  public T add(T value){
    currentIndex = (currentIndex + 1) % size();
    Object tmp = values[currentIndex];
    values[currentIndex] = value;
    return (T)tmp;
  }
  
  public Object[] getValues(){
    return (Object[])values;
  }
  
}
