class BouncyThingy extends GameObject{
  float radius = 1;
  PVector velocity;
  Bounds3D bounds;
  
  BouncyThingy(PVector position, PVector velocity, Bounds3D bounds){
    this.transform.position.set(position);
    this.velocity = velocity.copy();
    this.bounds = bounds;
  }
  
  void physicsUpdate(){
    
    float x = transform.position.x, y = transform.position.y, z = transform.position.z;
    if(x-radius < bounds.x0 || x+radius > bounds.x1) velocity.x *= -1;
    if(y-radius < bounds.y0 || y+radius > bounds.y1) velocity.y *= -1;
    if(z-radius < bounds.z0 || z+radius > bounds.z1) velocity.z *= -1;
    transform.position.x = constrain(x, bounds.x0+radius, bounds.x1-radius);
    transform.position.y = constrain(y, bounds.y0+radius, bounds.y1-radius);
    transform.position.z = constrain(z, bounds.z0+radius, bounds.z1-radius);
    
    velocity.add(PVector.mult(gravity, dt));
    
    PVector delta = PVector.mult(velocity, dt);
    transform.position.add(delta);
  }
  
  @Override
  void OnRender(){
    sphere(radius);
  }
}

class Bounds3D{
  float x0, x1, y0, y1, z0, z1;
  
  // x, y, z position and width, height and depth
  Bounds3D(float x, float y, float z, float w, float h, float d){
    x0 = x;
    x1 = x + w;
    y0 = y;
    y1 = y + h;
    z0 = z;
    z1 = z + d;
  }
  
  void show(){
    pushStyle();
    pushMatrix();
    noFill();
    stroke(255);
    strokeWeight(0.05);
    
    // width, height and depth
    float w = x1-x0, h = y1-y0, d = z1-z0;
    
    translate(x0 + w/2, y0 + h/2, z0 + d/2);
    box(w, h, d);
    popMatrix();
    popStyle();
  }
}
