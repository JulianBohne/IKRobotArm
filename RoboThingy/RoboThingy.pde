public static float dt = 1/60f;
public static PVector gravity = new PVector(0, -9.81, 0);
public static float time = 0f;
public static boolean pmousePressed = false;
public static boolean paused = false;

float xAngle = 0, yAngle = 0;
float mouseSensitivity = 0.5; // degrees per pixel
float zoom = 1, zoomMultiplier = 1.1;

Transform worldTransform = new Transform();

Arm arm;

ArrayList<PVector> endpointPath = new ArrayList<>();
ArrayList<Float> errorPath = new ArrayList<>();

LineToolPath tp = new LineToolPath();

BouncyThingy ball;

void setup() {
  size(800, 600, P3D);

  windowResizable(true);

  worldTransform.scale.z = -1;
  worldTransform.scale.mult(height/20);

  arm = obliqueSwivelTestArm();
  //arm = testArm1();
  //arm = testArm2();
  
  setupPlots();
  
  for(int i : range(10))
    tp.add(new PVector(random(0, 4), random(0, 4), random(0, 4)));

  /*for(int i : range(1501)){
    tp.add(paramFunction(currentParamValue));
    currentParamValue += 1f/50;
  }*/
  
  ball = new BouncyThingy(new PVector(0, 7, 0), new PVector(random(1, 10)*0, 10*0, random(1, 10)*0), new Bounds3D(-4, 2, -4, 8, 8, 8));
  ball.radius = 0.5;
  println(ball.velocity);
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

boolean step = false;

void draw() {
  dt = 1f/frameRate;
  
  // CONTROLS AND SIM
  
  if(!paused || step){

    //ball.physicsUpdate();
  
    float currentPos = triangle(2*(time - timeOffset) / tp.getLength())*tp.getLength();
    //float currentPos = ((-cos(20 * (time - timeOffset) /tp.getLength()) / 2) + 0.5) * tp.getLength();
  
    PVector target = tp.getPoint(currentPos);
    //PVector target = ball.transform.position.copy();
  
    //float error = 0;
    float error = arm.getComponent("end").inverseKinematics(target);
    maxError = max(maxError, error);
    smoothedError = lerp(smoothedError, error, 0.05);
  
    endpointPath.add(arm.getComponent("end").toWorldSpace(new PVector(0, 0, 0)));
    
    errorPath.add(error);
    
    println(maxError);
    
    if(currentPos < 0.1){
      if(!pCloseToZero){
        timeOffset = time;
        //for(int i : range(50)){
        //  tp.add(paramFunction(currentParamValue));
        //  currentParamValue += 1f/50;
        //}
        tp.add(new PVector(random(0, 6), random(0, 6), random(0, 6)));
        pCloseToZero = true;
      }
    }else pCloseToZero = false;
    
    //arm.getComponent(HingeJoint.class, "j3").rotateBy(0.1);
    
    updatePlots();
    
    time += dt;
    step = false;
  }
  
  // DON'T TOUCH (ROTATE CAMERA)
  if (mousePressed && pmousePressed) { // pmousePressed bcs touch input is annoying otherwise
    xAngle += (pmouseX - mouseX)*mouseSensitivity/360*TWO_PI;
    yAngle += (pmouseY - mouseY)*mouseSensitivity/360*TWO_PI;
    yAngle = constrain(yAngle, -HALF_PI, HALF_PI);
  }
  pmousePressed = mousePressed;

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

  worldTransform.apply();
  
  PMatrix3D mat = getMatrix((PMatrix3D)null);
  if(mousePressed && !pmousePressed){
    println(mat);
  }
  
  coords();

  arm.render();

  stroke(0, 255, 0);
  strokeWeight(0.2);

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
    stroke(map(currentError, 0, maxError, 168, 0), 255, 255, 255);
    vertex(point.x, point.y, point.z);
    i++;
  }
  endShape();
  popStyle();
  
  //ball.render();
  //ball.bounds.show();
  tp.show();
  
  popMatrix(); // Encapsulates whole 3D render part
  
  // OVERLAYS
  
  lights(); // The other lighting is not suitable for the overlays
  
  errorBar(width-20, 20, 20, height-40, maxError, smoothedError);
  showPlots();
  
  // END OF DRAW LOOP
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

void updatePlots(){
  for(int i = 0; i < hingeJoints.size(); i ++){
    anglePlots.get(i).addValue(degrees(hingeJoints.get(i).getAngle()));
  }
}

void showPlots(){
  for(ContinuousPlot plot : anglePlots) plot.show();
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
  }else if(key == 'p'){
    paused = !paused;
  }else if(key == CODED){
    if(keyCode == RIGHT){
      step = true;
    }
  }
}

void mouseWheel(MouseEvent e) {
  zoom *= pow(zoomMultiplier, -e.getCount());
}
