
class ArmElement extends GameObject{
  ArmElement parent;
  ArrayList<ArmElement> children;
  GameObject visual;
  Transform endpoint;
  boolean disableIK = false;
  
  ArmElement(){
    this(null);
  }
  
  void inverseKinematicsIteration(PVector target){
    PVector localTarget = toLocalSpace(target);
    inverseKinematicsIteration(localTarget.mag(), new PVector(0, 0, 0), localTarget);
  }
  
  private float inverseKinematicsIteration(float childMinError, PVector localEnd, PVector localTarget){
    float localError = disableIK ? Float.MAX_VALUE : testSolveLocal(localEnd, localTarget);
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
