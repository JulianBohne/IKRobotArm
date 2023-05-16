
abstract class Path{
  public abstract float getLength();
  public abstract PVector getPoint(float at);
  public void show(){}
}

class ToolPath extends Path{
  
  private float len;
  private ArrayList<Path> subPaths;
  private float currentPosition;
  private int currentSubPath;
  private float currentSubPathPosition;
  
  ToolPath(){
    len = 0;
    subPaths = new ArrayList<Path>();
    currentPosition = 0;
    currentSubPath = 0;
    currentSubPathPosition = 0;
  }
  
  @Override
  public float getLength(){
    return len;
  }
  
  @Override
  public PVector getPoint(float at){
    if(at < 0 || at > len) throw new IllegalArgumentException();
    
    float delta = at - currentPosition;
    currentPosition = at;
    currentSubPathPosition += delta;
    if(delta > 0){
      while(currentSubPath < subPaths.size()-1 && currentSubPathPosition > subPaths.get(currentSubPath).getLength()){
        currentSubPathPosition -= subPaths.get(currentSubPath).getLength();
        currentSubPath ++;
      }
    } else {
      while(currentSubPath > 0 && currentSubPathPosition < 0){
        currentSubPath --;
        currentSubPathPosition += subPaths.get(currentSubPath).getLength();
      }
    }
    
    return subPaths.get(currentSubPath).getPoint(currentSubPathPosition);
  }
  
  public void add(Path p){
    subPaths.add(p);
    len += p.getLength();
  }
  
  @Override
  public void show(){
    for(Path p : subPaths) p.show();
  }
}

class LineSegment extends Path{
  
  PVector start, end;
  
  LineSegment(PVector start, PVector end){
    this.start = start;
    this.end = end;
  }
  
  @Override
  public float getLength(){
    return PVector.dist(start, end);
  }
  
  @Override
  public PVector getPoint(float at){
    return PVector.lerp(start, end, at/getLength());
  }
  
  @Override
  public void show(){
    pushStyle();
    stroke(255);
    strokeWeight(0.05);
    line(start.x, start.y, start.z, end.x, end.y, end.z);
    popStyle();
  }
}

class LineToolPath extends Path{
  private ToolPath path;
  
  private PVector lastPoint;
  
  LineToolPath(){
    path = new ToolPath();
    lastPoint = null;
  }
  
  @Override
  public PVector getPoint(float at){
    return path.getPoint(at);
  }
  
  @Override
  public float getLength(){
    return path.getLength();
  }
  
  public void add(PVector point){
    PVector cpy = point.copy();
    if(lastPoint != null) path.add(new LineSegment(lastPoint, cpy));
    lastPoint = cpy;
  }
  
  @Override
  public void show(){
    path.show();
  }
}
