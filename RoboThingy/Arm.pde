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
  HingeJoint(){
    this(null);
  }
  
  HingeJoint(ArmLink parent){
    super(parent);
    visual = new Cylinder();
    visual.transform.rotation.rotateZ(HALF_PI);
    visual.transform.scale.mult(0.8);
  }
  
  void setRotation(float angle){
    endpoint.rotation.reset();
    endpoint.rotation.rotateX(angle);
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
