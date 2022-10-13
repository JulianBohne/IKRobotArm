import java.util.Set;
import java.util.HashSet;

class ArmElement extends GameObject{
  ArmElement parent;
  ArrayList<ArmElement> children;
  GameObject visual;
  Transform endpoint;
  
  ArmElement(){
    this(null);
  }
  
  void inverseKinematicsIteration(PVector target){
    PVector localTarget = toLocalSpace(target);
    inverseKinematicsIteration(Float.MAX_VALUE, new PVector(0, 0, 0), localTarget);
  }
  
  private float inverseKinematicsIteration(float childMinError, PVector localEnd, PVector localTarget){
    float localError = testSolveLocal(localEnd, localTarget);
    if(parent != null){
      float parentMinError = parent.inverseKinematicsIteration(
        min(childMinError, localError),
        toParentSpace(localEnd),
        toParentSpace(localTarget)
      );
      if(parentMinError < localError && parentMinError <= childMinError) return parentMinError;
    }
    if(localError <= childMinError){
      solveLocal(localEnd, localTarget);
      return localError;
    }
    
    return childMinError;
  }
  
  protected float testSolveLocal(PVector localEnd, PVector localTarget){
    return PVector.dist(localTarget, localEnd);
  }
  
  @SuppressWarnings("unused")
  protected void solveLocal(PVector localEnd, PVector localTarget){}
  
  PVector toParentSpace(PVector vec){
    PMatrix3D mat;
    PVector tmp;
    mat = endpoint.asMatrix();
    tmp = mult(mat, vec);
    mat = transform.asMatrix();
    tmp = mult(mat, tmp);
    return tmp;
  }
  
  private PVector mult(PMatrix3D mat, PVector vec){
    return new PVector(
      mat.m00 * vec.x + mat.m01 * vec.y + mat.m02 * vec.z + mat.m03,
      mat.m10 * vec.x + mat.m11 * vec.y + mat.m12 * vec.z + mat.m13,
      mat.m20 * vec.x + mat.m21 * vec.y + mat.m22 * vec.z + mat.m23
    );
  }
  
  PVector toWorldSpace(PVector vec){
    Vec4 transformed = new Vec4(vec);
    Vec4 tmp = new Vec4();
    toWorldSpace(transformed, tmp);
    return new PVector(transformed.x, transformed.y, transformed.z);
  }
  
  private void toWorldSpace(Vec4 vec, Vec4 tmp){
    PMatrix3D mat;
    mat = endpoint.asMatrix();
    mult(mat, vec, tmp);
    mat = transform.asMatrix();
    mult(mat, vec, tmp);
    if(parent != null) parent.toWorldSpace(vec, tmp);
  }
  
  PVector toLocalSpace(PVector vec){
    Vec4 transformed = new Vec4(vec);
    Vec4 tmp = new Vec4();
    toLocalSpace(transformed, tmp);
    return new PVector(transformed.x, transformed.y, transformed.z);
  }
  
  private void toLocalSpace(Vec4 vec, Vec4 tmp){
    if(parent != null) parent.toLocalSpace(vec, tmp);
    PMatrix3D mat;
    mat = transform.asMatrix();
    mat.invert();
    mult(mat, vec, tmp);
    mat = endpoint.asMatrix();
    mat.invert();
    mult(mat, vec, tmp);
  }
  
  private class Vec4{
    float x, y, z, w;
    
    Vec4(){
      x = 0;
      y = 0;
      z = 0;
      w = 0;
    }
    
    Vec4(PVector vec){
      x = vec.x;
      y = vec.y;
      z = vec.z;
      w = 1;
    }
  }
  
  private Vec4 mult(PMatrix3D mat, Vec4 vec, Vec4 tmp){
    tmp.x = vec.x;
    tmp.y = vec.y;
    tmp.z = vec.z;
    tmp.w = vec.w;
    vec.x = mat.m00 * tmp.x + mat.m01 * tmp.y + mat.m02 * tmp.z + mat.m03 * tmp.w;
    vec.y = mat.m10 * tmp.x + mat.m11 * tmp.y + mat.m12 * tmp.z + mat.m13 * tmp.w;
    vec.z = mat.m20 * tmp.x + mat.m21 * tmp.y + mat.m22 * tmp.z + mat.m23 * tmp.w;
    vec.w = mat.m30 * tmp.x + mat.m31 * tmp.y + mat.m32 * tmp.z + mat.m33 * tmp.w;
    return vec;
  }
  
  ArmElement(ArmElement parent){
    this.parent = parent;
    this.children = new ArrayList<ArmElement>();
    this.visual = new Sphere();
    this.endpoint = new Transform();
    
    if(parent != null) parent.addChildUnique(this);
  }
  
  ArmElement setParent(ArmElement nParent){
    if(parent != nParent){
      if(parent != null) parent.removeChild(this);
      parent = nParent;
      if(parent != null) parent.addChildUnique(this);
    }
    return this;
  }
  
  ArmElement removeChild(ArmElement child){
    children.remove(child);
    return this;
  }
  
  ArmElement addChildUnique(ArmElement child){
    if(children.contains(child)) return this;
    children.add(child);
    child.setParent(this);
    return this;
  }
  
  @Override
  void OnRender(){
    endpoint.apply();
    visual.render();
    for(ArmElement child : children){
      child.render();
    }
  }
}

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
    visual.transform.scale.set(0.5, len, 0.5);
    endpoint.position.set(0, len, 0);
    this.len = len;
  }
  
  float getLength(){
    return len;
  }
  
  ArmLink setLength(float nLen){
    len = nLen;
    visual.transform.scale.y = len;
    visual.transform.position.set(0, -len/2, 0);
    endpoint.position.set(0, len, 0);
    return this;
  }
  
  ArmLink setDiameter(float d){
    visual.transform.scale.x = d;
    visual.transform.scale.z = d;
    return this;
  }
  
  ArmLink setVisual(GameObject nVisual){
    visual = nVisual;
    return this;
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
  
  float angleRange = HALF_PI;
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
