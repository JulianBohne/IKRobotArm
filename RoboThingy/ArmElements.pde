
class ArmEndpoint extends ArmElement{
  
  ArmEndpoint(){
    this(0, 0, 0);
  }
  
  ArmEndpoint(PVector offset){
    this(offset.x, offset.y, offset.z);
  }
  
  ArmEndpoint(float x, float y, float z){
    super();
    visual = new Sphere();
    visual.transform.scale.mult(0.25);
    endpoint.position.set(x, y, z);
  }
}

class ArmLink extends ArmElement{
  
  private float len; // length
  private float diameter;
  
  ArmLink(){
    this(1);
  }
  
  ArmLink(ArmElement parent){
    this(1, parent);
  }
  
  ArmLink(float len){
    this(len, null);
  }
  
  ArmLink(float len, ArmElement parent){
    super(parent);
    visual = new Box();
    visual.transform.position.set(0, -len/2, 0);
    diameter = 0.5;
    visual.transform.scale.set(diameter, len, diameter);
    endpoint.position.set(0, len, 0);
    this.len = len;
  }
  
  float getLength(){
    return len;
  }
  
  ArmLink setLength(float nLen){
    len = nLen;
    updateVisual();
    return this;
  }
  
  ArmLink setDiameter(float d){
    diameter = d;
    updateVisual();
    return this;
  }
  
  ArmLink setVisual(GameObject nVisual){
    visual = nVisual;
    updateVisual();
    return this;
  }
  
  private void updateVisual(){
    visual.transform.scale.x = diameter;
    visual.transform.scale.z = diameter;
    visual.transform.scale.y = len;
    visual.transform.position.set(0, -len/2, 0);
    endpoint.position.set(0, len, 0);
    
  }
  
  //@Override
  //protected float testSolveLocal(PVector localEnd, PVector localTarget){
  //  return new PVector(localTarget.x - localEnd.x, 0, localTarget.z - localEnd.z).mag();
  //}
  
  //@Override
  //protected void solveLocal(PVector localEnd, PVector localTarget, float amount){
  //  setLength((localTarget.y - localEnd.y)*amount + len);
  //}
}

class ArmBase extends ArmElement{
  
  ArmBase(ArmElement parent){
    super(parent);
    visual = new Box();
    visual.transform.position.set(0, -0.5, 0);
    endpoint.position.set(0, 0.5, 0);
  }
  
  ArmBase(){
    this(null);
  }
  
}

class ObliqueSwivelJoint extends HingeJoint{
  private float obliqueness;
  
  ObliqueSwivelJoint(float obliqueness){
    super();
    this.obliqueness = obliqueness;
    this.constrained = false;
    transform.rotation.rotateZ(PI/2 - obliqueness);
    visual.transform.scale.set(0.8, 0.2, 0.8);
  }
  
  @Override
  ArmElement addChildUnique(ArmElement child){
    super.addChildUnique(child);
    child.transform.rotation.rotateZ(-obliqueness -PI/2);
    return this;
  }
}

class SwivelJoint extends ObliqueSwivelJoint{
  SwivelJoint(){
    super(0);
  }
}

class HingeJoint extends ArmElement{
  
  float angleRange = PI*0.75;
  boolean constrained = true;
  private float currentAngle;
  
  HingeJoint(){
    this(null);
  }
  
  HingeJoint(ArmLink parent){
    super(parent);
    visual = new Cylinder();
    visual.transform.rotation.rotateZ(HALF_PI);
    visual.transform.scale.mult(0.8);
    currentAngle = 0;
  }
  
  float getAngle(){
    return currentAngle;
  }
  
  void setRotation(float angle){
    endpoint.rotation.reset();
    rotateBy(angle);
    currentAngle = angle;
  }
  
  void rotateBy(float angle){
    angle = toLegalAngle(angle);
    endpoint.rotation.rotateX(angle);
    currentAngle += angle;
  }
  
  private float toLegalAngle(float rawAngle){
    if(!constrained) return rawAngle;
    return constrain(currentAngle + rawAngle, -angleRange, angleRange) - currentAngle;
  }
  
  @Override
  protected float testSolveLocal(PVector localEnd, PVector localTarget){
    float deltaAngle = toLegalAngle(getDeltaAngle(localEnd, localTarget));
    PVector transformedEnd = localEnd.copy();
    rotateX(transformedEnd, deltaAngle);
    return PVector.dist(localTarget, transformedEnd);// * (abs(deltaAngle) + 2);
  }
  
  private float getDeltaAngle(PVector localEnd, PVector localTarget){
    PVector projectedEnd = new PVector(localEnd.y, localEnd.z);
    PVector projectedTarget = new PVector(localTarget.y, localTarget.z);
    return signedAngleBetween(projectedTarget, projectedEnd);
  }
  
  @Override
  protected void solveLocal(PVector localEnd, PVector localTarget, float amount){
    rotateBy(getDeltaAngle(localEnd, localTarget)*amount);
  }
  
  HingeJoint setLength(float nLen){
    visual.transform.scale.y = nLen;
    return this;
  }
  
  HingeJoint setDiameter(float d){
    visual.transform.scale.x = d;
    visual.transform.scale.z = d;
    return this;
  }
}
