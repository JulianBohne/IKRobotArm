public static float dt = 1/60f;
public static float time = 0f;
public static boolean pmousePressed = false;

float xAngle = 0, yAngle = 0;
float mouseSensitivity = 0.5; // degrees per pixel
float zoom = 1, zoomMultiplier = 1.1;

Transform worldTransform = new Transform();

Arm arm;

ArrayList<PVector> endpointPath = new ArrayList<>();
ArrayList<Float> errorPath = new ArrayList<>();

LineToolPath tp = new LineToolPath();

void setup() {
  size(800, 600, P3D);

  windowResizable(true);

  worldTransform.scale.z = -1;
  worldTransform.scale.mult(height/20);

  arm = obliqueSwivelTestArm();
  //arm = testArm1();
  
  setupPlots();
  
  for(int i : range(10))
    tp.add(new PVector(random(0, 4), random(0, 4), random(0, 4)));

  /*for(int i : range(1501)){
    tp.add(paramFunction(currentParamValue));
    currentParamValue += 1f/50;
  }*/
  
}

float armAngleRange = PI/2;
float armSpeed = 0.1;
float armAngleX = -armAngleRange;
float armAngleZ = -armAngleRange;

boolean pCloseToZero = true;
float timeOffset = 0;
float currentParamValue = 0;

float maxError = 0.000001;
float smoothedError = 0;

void draw() {
  dt = 1f/frameRate;
  //dt *= 0.01;
  //dt *= 0.5;
  // CONTROLS AND SIM

  //float a = 100; // 2
  //float b = 100; // 3
  //float c = 100; // 5
  //float d = 0.01;//1.349823; // 1.349823

  float currentPos = triangle(2*(time - timeOffset) / tp.getLength())*tp.getLength();//((-cos(20 * (time - timeOffset) /tp.getLength()) / 2) + 0.5) * tp.getLength();

  PVector target = tp.getPoint(currentPos);

  float error = arm.getComponent("end").inverseKinematics(target);
  maxError = max(maxError, error);
  smoothedError = lerp(smoothedError, error, 0.05);

  endpointPath.add(arm.getComponent("end").toWorldSpace(new PVector(0, 0, 0)));
  
  errorPath.add(error);
  
  println(maxError);
  
  if(currentPos < 0.1){
    if(!pCloseToZero){
      timeOffset = time;
      /*for(int i : range(50)){
        tp.add(paramFunction(currentParamValue));
        currentParamValue += 1f/50;
      }*/
      tp.add(new PVector(random(0, 6), random(0, 6), random(0, 6)));
      pCloseToZero = true;
    }
  }else pCloseToZero = false;
  
  //arm.getComponent(HingeJoint.class, "j3").rotateBy(0.1);

  //PVector target = new PVector();
  //for (int j = 0; j < 1; j ++) {
  //  //target.set(cos(time)*(4+sin(time*(a + .01))*3), (sin(time* (b))+1)*2, sin(time)*(4+sin(time*(c + .01))*3));
  //  float x = 16*pow(sin(time), 3);
  //  float y = 13*cos(time)-5*cos(2*time)-2*cos(3*time)-cos(4*time);
  //  target.set(cos(time*d)*2*(x*0.04+2), y*0.1, sin(time*d)*2*(x*0.04+2));
  //  //target.set(cos(time*d)*2*(sin(time*a)+2), (cos(time*b)+1)*2, sin(time*d)*2*(sin(time*c)+2));
  //  for (int i = 0; i < 25; i ++)
  //    arm.getComponent("end").inverseKinematicsIteration(target);
  //  //arm.getComponent(HingeJoint.class, "j1").setRotation(time*2 % TWO_PI);
  //  //arm.getComponent(HingeJoint.class, "j2").setRotation(sin(time*1.5)*HALF_PI);
  //  //arm.getComponent(HingeJoint.class, "j3").setRotation(sin(time*3)*HALF_PI);

  //  //arm.getComponent(HingeJoint.class, "j1").setRotation(armAngleX);
  //  //arm.getComponent(HingeJoint.class, "j2").setRotation(armAngleZ);
  //  arm.getComponent(HingeJoint.class, "j3").rotateBy(0.1);
  //  endpointPath.add(arm.getComponent("end").toWorldSpace(new PVector(0, 0, 0)));
  //  time += dt;
  //}


  //armAngleX += armSpeed;
  //if(abs(armAngleX) > armAngleRange){
  //  armAngleZ += abs(armSpeed);
  //  armSpeed *= -1;
  //  armAngleX += armSpeed;
  //  if(armAngleZ > armAngleRange) armAngleZ = -armAngleRange;
  //}


  //al.joint.transform.setRotation(new PVector(armAngleX, 0, armAngleZ));


  // DON'T TOUCH (ROTATE CAMERA AND UPDATE TIME STUFF)

  if (mousePressed && pmousePressed) { // pmousePressed bcs touch input is annoying otherwise
    xAngle += (pmouseX - mouseX)*mouseSensitivity/360*TWO_PI;
    yAngle += (pmouseY - mouseY)*mouseSensitivity/360*TWO_PI;
    yAngle = constrain(yAngle, -HALF_PI, HALF_PI);
  }

  pmousePressed = mousePressed;
  time += dt;

  // RENDERING
  pushMatrix(); // Encapsulate whole 3D render part
  background(32);

  pushMatrix();
  worldTransform.apply(); // put the lights through the world transform, otherwise it looks strange
  lights();
  popMatrix();

  translate(width/2, height/2);
  scale(zoom);

  rotateX(PI); // Make Y point up

  rotateX(yAngle);
  rotateY(xAngle);

  pushMatrix();
  worldTransform.apply();
  
  PMatrix3D mat = getMatrix((PMatrix3D)null);
  if(mousePressed && !pmousePressed){
    println(mat);
  }
  
  coords();

  arm.render();

  stroke(0, 255, 0);
  strokeWeight(0.2);
  //point(target.x, target.y, target.z);

  tp.show();

  pushStyle();
  colorMode(HSB);
  noFill();
  strokeWeight(0.2);
  beginShape();
  PVector point;
  float currentError;
  for (int i : range(endpointPath.size())) {
    point = endpointPath.get(i);
    currentError = errorPath.get(i);
    //float opacity = 255*((float)i/endpointPath.size());
    //stroke(((float)i*0.100001)%255, 255, 255, 255);
    stroke(map(currentError, 0, maxError, 168, 0), 255, 255, 255);
    vertex(point.x, point.y, point.z);
    i++;
  }
  endShape();
  popStyle();

  popMatrix();
  
  popMatrix(); // Encapsulates whole 3D render part
  
  // Overlays
  
  lights(); // The other lighting is not suitable for the overlays
  
  errorBar(width-20, 20, 20, height-40, maxError, smoothedError);
  
  //angleList(arm.getAllComponents(HingeJoint.class));
  updateAndShowPlots();
  
  //saveFrame("frames/frame####.png");
}

PVector paramFunction(float t){
  float x = (cos(t*TWO_PI)+0)*cos(t/5)*4 + 0;
  float z = (sin(t*TWO_PI)+0)*cos(t/5)*4 + 0;
  float y = t/5;
  
  //float x = 2*(2*cos(t) + cos(2*t));
  //float z = 2*(2*sin(t) - sin(2*t));
  return new PVector(x, y, z);
}


ArrayList<HingeJoint> hingeJoints;
ArrayList<ContinuousPlot> anglePlots = new ArrayList<>();

void setupPlots(){
  float padding = 5;
  float plotHeight = 50;
  float plotWidth = width/4;
  
  hingeJoints = arm.getAllComponents(HingeJoint.class);
  
  HingeJoint current;
  float cAngleRange;
  color cCol;
  String cName;
  for(int i = 0; i < hingeJoints.size(); i ++){
    current = hingeJoints.get(i);
    cAngleRange = degrees(current.constrained ? current.angleRange : PI);
    cCol = current.visual.style.fill;
    cName = current.name;
    anglePlots.add(new ContinuousPlot(padding, padding + (padding + plotHeight)*i, plotWidth, plotHeight, -cAngleRange, cAngleRange, cCol, cName, (int)plotWidth*1));
  }
}

void updateAndShowPlots(){
  for(int i = 0; i < hingeJoints.size(); i ++){
    anglePlots.get(i).addValue(degrees(hingeJoints.get(i).getAngle()));
    anglePlots.get(i).show();
  }
}

void mousePressed() {
}

void keyPressed() {
  if (key == 'c'){
    maxError = 0.000001;
    endpointPath.clear();
    errorPath.clear();
  }else if(key == 'd'){
    arm.setShowDebug(!arm.showDebug);
  }
}

void mouseWheel(MouseEvent e) {
  zoom *= pow(zoomMultiplier, -e.getCount());
}
