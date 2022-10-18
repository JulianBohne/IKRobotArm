import java.util.Set;
import java.util.HashSet;

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
  //protected void solveLocal(PVector localEnd, PVector localTarget){
  //  setLength((localTarget.y - localEnd.y) + len);
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
    PVector dings = localEnd.copy();
    rotateX(dings, deltaAngle);
    return PVector.dist(localTarget, dings);
    //return len(localTarget.x - localEnd.x, len(localTarget.y, localTarget.z) - len(localEnd.y, localEnd.z));
  }
  
  //private float len(float x, float y){
  //  return sqrt(x*x + y*y);
  //}
  
  private float getDeltaAngle(PVector localEnd, PVector localTarget){
    PVector projectedEnd = new PVector(localEnd.y, localEnd.z);
    PVector projectedTarget = new PVector(localTarget.y, localTarget.z);
    return signedAngleBetween(projectedTarget, projectedEnd);
  }
  
  @Override
  protected void solveLocal(PVector localEnd, PVector localTarget){
    rotateBy(getDeltaAngle(localEnd, localTarget)*0.5);
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

class Arm extends ArmElement{
  private HashMap<Class<? extends ArmElement>, ArrayList<ArmElement>> components = new HashMap<>();
  private HashMap<String, ArmElement> namedComponents = new HashMap<>();
  
  ArmElement active;
  
  ArmElement root;
  
  Arm(){
    super();
    root = new ArmBase(this);
    active = root;
    addComponent(root);
  }
  
  <T extends ArmElement> Arm addComponentToActive(T component){
    component.setParent(active);
    return addComponent(component);
  }
  
  <T extends ArmElement> Arm addComponent(T component){
    ArrayList<ArmElement> compList = (ArrayList<ArmElement>)getComponents(component.getClass());
    active = component;
    if(compList.contains(component)) return this;
    compList.add(component);
    return this;
  }
  
  <T extends ArmElement> Arm addComponentToActive(T component, String name){
    component.setParent(active);
    return addComponent(component, name);
  }
  
  <T extends ArmElement> Arm addComponent(T component, String name){
    namedComponents.put(name, component);
    return addComponent(component);
  }
  
  ArmElement getComponent(String name){
    return namedComponents.get(name);
  }
  
  @SuppressWarnings("unused")
  <T extends ArmElement> T getComponent(Class<T> type, String name){
    return (T)getComponent(name);
  }
  
  <T extends ArmElement> ArrayList<T> getComponents(Class<T> type){
    ArrayList<ArmElement> compList = components.get(type);
    if(compList == null){
      compList = new ArrayList<ArmElement>();
      components.put(type, compList);
    }
    return (ArrayList<T>)compList;
  }
  
  <T extends ArmElement> T getComponent(Class<T> type, int index){
    return getComponents(type).get(index);
  }
  
  Arm setActive(String name){
    active = getComponent(name);
    return this;
  }
  
  @Override
  void OnRender(){
    root.render();
  }
}
