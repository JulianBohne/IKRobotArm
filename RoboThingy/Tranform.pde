class Transform{
  public PVector position;
  public PMatrix3D rotation;
  public PVector scale;
  
  Transform(){
    position = new PVector(0, 0, 0);
    rotation = new PMatrix3D();
    scale = new PVector(1, 1, 1);
  }
  
  public PVector getRotationVector(){ // yoinked from https://www.programcreek.com/java-api-examples/?api=javax.vecmath.Matrix3d
    float sy = sqrt(rotation.m00*rotation.m00 + rotation.m10*rotation.m10);
    boolean singular = sy < 1e-6;
    float x,y,z;
    
    if(!singular) {
      x = atan2( rotation.m21,rotation.m22);
      y = atan2(-rotation.m20,sy);
      z = atan2( rotation.m10,rotation.m00);
    } else {
      x = atan2(-rotation.m12, rotation.m11);
      y = atan2(-rotation.m20, sy);
      z = 0;
    }
    
    return new PVector(x,y,z);
  }
  
  public void setRotationVector(PVector rot){
    rotation.reset();
    rotation.rotateX(rot.x);
    rotation.rotateY(rot.y);
    rotation.rotateZ(rot.z);
  }
  
  public void reset(){
    rotation.reset();
    resetPosition();
    resetScale();
  }
  
  public void resetPosition(){
    position.set(0, 0, 0);
  }
  
  public void resetScale(){
    scale.set(1, 1, 1);
  }
  
  public void apply(){
    translate(position.x, position.y, position.z);
    PVector rot = getRotationVector();
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);
    scale(scale.x, scale.y, scale.z);
  }
  
  public PMatrix3D asMatrix(){
    PMatrix3D current = new PMatrix3D();
    current.translate(position.x, position.y, position.z);
    current.apply(rotation);
    current.scale(scale.x, scale.y, scale.z);
    return current;
  }
}

class OldTransform{ // TODO: Remove unnecessary allocations (if performance becomes a problem)

  // Could optimize these, so it takes up less space, but this works for now
  private PMatrix3D positionMat;
  private PMatrix3D rotation;
  private PMatrix3D scaleMat;
  
  OldTransform(){
    positionMat = new PMatrix3D();
    rotation    = new PMatrix3D();
    scaleMat    = new PMatrix3D();
  }
  
  /*public void show(){
    pushMatrix();
    PMatrix3D current = new PMatrix3D(); // maybe without constantly allocating stuff????? hellooooo
    mult(rotation, current);
    mult(positionMat, current);
    mult(getMatrix((PMatrix3D) null), current); // maybe without constantly allocating stuff????? hellooooo
    setMatrix(current);
    axes(getScale(), 0.5);
    popMatrix();
  }*/
  
  public void reset(){
    resetPosition();
    resetRotation();
    resetScale();
  }
  
  public void resetPosition(){
    positionMat.reset();
  }
  
  public void resetRotation(){
    rotation.reset();
  }
  
  public void resetScale(){
    scaleMat.reset();
  }
  
  public void translate(float x, float y, float z){
    positionMat.translate(x, y, z);
  }
  
  public void translate(PVector vec){
    translate(vec.x, vec.y, vec.z);
  }
  
  public void setPosition(float x, float y, float z){
    positionMat.m03 = x;
    positionMat.m13 = y;
    positionMat.m23 = z;
  }
  
  public void setPosition(PVector pos){
    setPosition(pos.x, pos.y, pos.z);
  }
  
  public PVector getPosition(){
    return getPosition(null);
  }
  
  public PVector getPosition(PVector out){
    if(out == null) out = new PVector();
    out.set(positionMat.m03, positionMat.m13, positionMat.m23);
    return out;
  }
  
  public void scale(float s){
    scaleMat.m00 *= s;
    scaleMat.m11 *= s;
    scaleMat.m22 *= s;
  }
  
  public void scale(float x, float y, float z){
    scaleMat.m00 *= x;
    scaleMat.m11 *= y;
    scaleMat.m22 *= z;
  }
  
  public void scale(PVector scale){
    scale(scale.x, scale.y, scale.z);
  }
  
  public void setScale(float s){
    scaleMat.m00 = s;
    scaleMat.m11 = s;
    scaleMat.m22 = s;
  }
  
  public void setScale(float x, float y, float z){
    scaleMat.m00 = x;
    scaleMat.m11 = y;
    scaleMat.m22 = z;
  }
  
  public void setScale(PVector scale){
    setScale(scale.x, scale.y, scale.z);
  }
  
  public void scaleX(float s){
    scaleMat.m00 *= s;
  }
  
  public void scaleY(float s){
    scaleMat.m11 *= s;
  }
  
  public void scaleZ(float s){
    scaleMat.m22 *= s;
  }
  
  public void setScaleX(float s){
    scaleMat.m00 = s;
  }
  
  public void setScaleY(float s){
    scaleMat.m11 = s;
  }
  
  public void setScaleZ(float s){
    scaleMat.m22 = s;
  }
  
  public PVector getScale(PVector out){
    if(out == null) out = new PVector();
    out.set(scaleMat.m00, scaleMat.m11, scaleMat.m22);
    return out;
  }
  
  public PVector getScale(){
    return getScale(null);
  }
  
  public void rotateX(float angle){ // angle in radians
    PMatrix3D rotX = new PMatrix3D( // alloc bad :'((((
      1,          0,           0, 0,
      0, cos(angle), -sin(angle), 0,
      0, sin(angle),  cos(angle), 0,
      0,          0,           0, 1
    );
    mult(rotX, rotation);
  }
  
  public void rotateY(float angle){ // angle in radians
    PMatrix3D rotY = new PMatrix3D( // alloc bad :'((((
       cos(angle), 0, sin(angle), 0,
                0, 1,          0, 0,
      -sin(angle), 0, cos(angle), 0,
                0, 0,          0, 1
    );
    mult(rotY, rotation);
  }
  
  public void rotateZ(float angle){ // angle in radians
    PMatrix3D rotZ = new PMatrix3D( // alloc bad :'((((
      cos(angle), -sin(angle), 0, 0,
      sin(angle),  cos(angle), 0, 0,
               0,           0, 1, 0,
               0,           0, 0, 1
    );
    mult(rotZ, rotation);
  }
  
  public void setRotation(PVector rot){
    resetRotation();
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);
  }
  
  public PVector getRotation(){ // yoinked from https://www.programcreek.com/java-api-examples/?api=javax.vecmath.Matrix3d
    float sy = sqrt(rotation.m00*rotation.m00 + rotation.m10*rotation.m10);
    boolean singular = sy < 1e-6;
    float x,y,z;
    
    if(!singular) {
      x = atan2( rotation.m21,rotation.m22);
      y = atan2(-rotation.m20,sy);
      z = atan2( rotation.m10,rotation.m00);
    } else {
      x = atan2(-rotation.m12, rotation.m11);
      y = atan2(-rotation.m20, sy);
      z = 0;
    }
    
    return new PVector(x,y,z);
  }
  
  public void apply(){
    PMatrix3D current = asMatrix();
    mult(getMatrix((PMatrix3D) null), current); // maybe without constantly allocating stuff????? hellooooo
    setMatrix(current); // not using apply matrix because it's apparently slow, hope this works though
  }
  
  public PMatrix3D asInvertedMatrix(){
    PMatrix3D current = asMatrix();
    current.invert();
    return current;
  }
  
  public PMatrix3D asMatrix(){
    PMatrix3D current = new PMatrix3D(); // maybe without constantly allocating stuff????? hellooooo
    mult(scaleMat, current);
    //current.apply(scaleMat);
    mult(rotation, current);
    //current.apply(rotation);
    mult(positionMat, current);
    //current.apply(positionMat);
    return current;
  }
  
  private void mult(PMatrix3D a, PMatrix3D b){
    float[] ncol = new float[4]; // BOOOOO EVEN MORE ALLOCATIONS >:(
    
    ncol[0] = a.m00*b.m00 + a.m01*b.m10 + a.m02*b.m20 + a.m03*b.m30;
    ncol[1] = a.m10*b.m00 + a.m11*b.m10 + a.m12*b.m20 + a.m13*b.m30;
    ncol[2] = a.m20*b.m00 + a.m21*b.m10 + a.m22*b.m20 + a.m23*b.m30;
    ncol[3] = a.m30*b.m00 + a.m31*b.m10 + a.m32*b.m20 + a.m33*b.m30;
    b.m00 = ncol[0];
    b.m10 = ncol[1];
    b.m20 = ncol[2];
    b.m30 = ncol[3];
    
    ncol[0] = a.m00*b.m01 + a.m01*b.m11 + a.m02*b.m21 + a.m03*b.m31;
    ncol[1] = a.m10*b.m01 + a.m11*b.m11 + a.m12*b.m21 + a.m13*b.m31;
    ncol[2] = a.m20*b.m01 + a.m21*b.m11 + a.m22*b.m21 + a.m23*b.m31;
    ncol[3] = a.m30*b.m01 + a.m31*b.m11 + a.m32*b.m21 + a.m33*b.m31;
    b.m01 = ncol[0];
    b.m11 = ncol[1];
    b.m21 = ncol[2];
    b.m31 = ncol[3];
    
    ncol[0] = a.m00*b.m02 + a.m01*b.m12 + a.m02*b.m22 + a.m03*b.m32;
    ncol[1] = a.m10*b.m02 + a.m11*b.m12 + a.m12*b.m22 + a.m13*b.m32;
    ncol[2] = a.m20*b.m02 + a.m21*b.m12 + a.m22*b.m22 + a.m23*b.m32;
    ncol[3] = a.m30*b.m02 + a.m31*b.m12 + a.m32*b.m22 + a.m33*b.m32;
    b.m02 = ncol[0];
    b.m12 = ncol[1];
    b.m22 = ncol[2];
    b.m32 = ncol[3];
    
    ncol[0] = a.m00*b.m03 + a.m01*b.m13 + a.m02*b.m23 + a.m03*b.m33;
    ncol[1] = a.m10*b.m03 + a.m11*b.m13 + a.m12*b.m23 + a.m13*b.m33;
    ncol[2] = a.m20*b.m03 + a.m21*b.m13 + a.m22*b.m23 + a.m23*b.m33;
    ncol[3] = a.m30*b.m03 + a.m31*b.m13 + a.m32*b.m23 + a.m33*b.m33;
    b.m03 = ncol[0];
    b.m13 = ncol[1];
    b.m23 = ncol[2];
    b.m33 = ncol[3];
  }
  
}
