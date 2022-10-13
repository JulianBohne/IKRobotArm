class GameObject{
  public Transform transform;
  public Style style;
  
  GameObject(){
    transform = new Transform();
    style = new Style();
  }
  
  void render(){
    pushMatrix();
    pushStyle();
    transform.apply();
    style.apply();
    OnRender();
    popStyle();
    popMatrix();
  }
  
  void OnRender(){}
}

class Box extends GameObject{
  Box(){
    style.strokeWeight = 0.05;
  }
  
  @Override
  void OnRender(){
    box(1, 1, 1);
  }
}

class Cylinder extends GameObject{
  @Override
  void OnRender(){
    cylinder(1, 1);
  }
}

class Sphere extends GameObject{
  @Override
  void OnRender(){
    sphere(1);
  }
}
