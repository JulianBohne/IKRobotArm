public static float dt = 1/60f;
public static float time = 0f;
public static boolean pmousePressed = false;

import java.util.LinkedList;

float xAngle = 0, yAngle = 0;
float mouseSensitivity = 0.5; // degrees per pixel
float zoom = 1, zoomMultiplier = 1.1;

Transform worldTransform = new Transform();

Arm arm;

ArrayList<PVector> endpointPath = new ArrayList<>();

LineToolPath tp = new LineToolPath();

void setup() {
  size(800, 600, P3D);

  windowResizable(true);

  worldTransform.scale.z = -1;
  worldTransform.scale.mult(height/20);

  arm = new Arm()
    .addComponentToActive(new HingeJoint(), "j1")
    .addComponentToActive(new ArmLink(1.5), "l1")
    .addComponentToActive(new HingeJoint(), "jk")
    .addComponentToActive(new ArmLink(4), "lk")
    .addComponentToActive(new HingeJoint(), "jk2")
    .addComponentToActive(new ArmLink(3.5), "lk2")
    .addComponentToActive(new HingeJoint(), "j2")
    .addComponentToActive(new ArmLink(3).setDiameter(0.4), "l2")
    .addComponentToActive(new HingeJoint().setDiameter(0.5), "j3")
    .addComponentToActive(new ArmLink(0.5).setDiameter(0.3), "l3")
    .addComponentToActive(
      new HingeJoint().setDiameter(0.3).setLength(0.5),
      "hj1"
    )
    .addComponentToActive(
      new ArmLink().setDiameter(0.25).setLength(0.75),
      "hl1"
    )
    .addComponentToActive(
      new HingeJoint().setDiameter(0.3).setLength(0.4),
      "hj12"
    )
    .addComponentToActive(
      new ArmLink().setDiameter(0.25).setLength(0.5),
      "hl12"
    )
    .setActive("l3")
    .addComponentToActive(
      new HingeJoint().setDiameter(0.3).setLength(0.5),
      "hj2"
    )
    .addComponentToActive(
      new ArmLink().setDiameter(0.25).setLength(0.75),
      "hl2"
    )
    .addComponentToActive(
      new HingeJoint().setDiameter(0.3).setLength(0.4),
      "hj22"
    )
    .addComponentToActive(
      new ArmLink().setDiameter(0.25).setLength(0.5),
      "hl22"
    )
    .setActive("l3")
    .addComponentToActive(
      new ArmEndpoint(0, 1, 0),
      "end"
    );

  arm.getComponent("hj1").transform.position.add(-0.15, 0, 0);
  arm.getComponent("hj1").transform.rotation.rotateY(-HALF_PI);
  arm.getComponent(HingeJoint.class, "hj1").setRotation(0.6);
  arm.getComponent(HingeJoint.class, "hj12").setRotation(-0.6);

  arm.getComponent("hj2").transform.position.add(0.15, 0, 0);
  arm.getComponent("hj2").transform.rotation.rotateY(HALF_PI);
  arm.getComponent(HingeJoint.class, "hj2").setRotation(0.6);
  arm.getComponent(HingeJoint.class, "hj22").setRotation(-0.6);

  arm.getComponent(HingeJoint.class, "j3").setRotation(HALF_PI - 0.75 - 0.2);
  arm.getComponent("j3").disableIK = true;
  arm.getComponent(HingeJoint.class, "j3").constrained = false;
  //arm.getComponent(HingeJoint.class, "j2").setRotation(-HALF_PI);
  //arm.getComponent(HingeJoint.class, "j2").angleRange = 0;
  //arm.getComponent("j2").disableIK = true;
  arm.getComponent(HingeJoint.class, "j1").setRotation(0.2);
  arm.getComponent(HingeJoint.class, "j1").constrained = false;
  arm.getComponent(HingeJoint.class, "jk2").angleRange = PI*0.9;

  arm.getComponent("j1").transform.rotation.rotateZ(HALF_PI);
  arm.getComponent("j1").transform.position.add(0, 0.4, 0);

  //arm.getComponent("l1").transform.rotation.rotateZ(HALF_PI);

  arm.getComponent(HingeJoint.class, "jk").constrained = false;
  arm.getComponent("jk").transform.rotation.rotateZ(-HALF_PI);
  //arm.getComponent("lk").transform.rotation.rotateZ(HALF_PI);
  arm.getComponent("l3").transform.rotation.rotateZ(-HALF_PI);

  arm.getComponent("end").visual.style.fill = color(255, 0, 0);
  arm.getComponent("end").visual.transform.scale.set(0.1, 0.1, 0.1);


  arm.transform.rotation.rotateY(HALF_PI);

  //tp.add(new PVector(2, 0, 2));
  //tp.add(new PVector(2, 0, -2));
  //tp.add(new PVector(-2, 0, -2));
  //tp.add(new PVector(-2, 0, 2));
  //tp.add(new PVector(2, 0, 2));
  //tp.add(new PVector(2, 4, 2));
  //tp.add(new PVector(2, 4, -2));
  //tp.add(new PVector(-2, 4, -2));
  //tp.add(new PVector(-2, 4, 2));
  //tp.add(new PVector(2, 4, 2));
  
  for(int i : range(2))
    tp.add(new PVector(random(0, 4), random(0, 4), random(0, 4)));
}

float armAngleRange = PI/2;
float armSpeed = 0.1;
float armAngleX = -armAngleRange;
float armAngleZ = -armAngleRange;

boolean pCloseToZero = true;
float timeOffset = 0;

void draw() {
  dt = 1f/60f;///frameRate;
  //dt *= 0.01;
  //dt *= 0.1;
  // CONTROLS AND SIM

  //float a = 100; // 2
  //float b = 100; // 3
  //float c = 100; // 5
  //float d = 0.01;//1.349823; // 1.349823

  float currentPos = ((-cos(20 * (time - timeOffset) /tp.getLength()) / 2) + 0.5) * tp.getLength();

  PVector target = tp.getPoint(currentPos);
  arm.getComponent(HingeJoint.class, "j3").rotateBy(0.1);

  for (int i = 0; i < 25; i ++)
    arm.getComponent("end").inverseKinematicsIteration(target);

  endpointPath.add(arm.getComponent("end").toWorldSpace(new PVector(0, 0, 0)));
  
  if(currentPos < 0.01){
    if(!pCloseToZero){
      timeOffset = time;
      tp.add(new PVector(random(0, 4), random(0, 4), random(0, 4)));
      pCloseToZero = true;
    }
  }else pCloseToZero = false;
  

  //PVector target = new PVector();
  //for (int j = 0; j < 10; j ++) {
  //  //target.set(cos(time)*(4+sin(time*(a + .01))*3), (sin(time* (b))+1)*2, sin(time)*(4+sin(time*(c + .01))*3));
  //  float x = 16*pow(sin(time), 3);
  //  float y = 13*cos(time)-5*cos(2*time)-2*cos(3*time)-cos(4*time);
  //  target.set(cos(time*d)*2*(x*0.08+2), y*0.2, sin(time*d)*2*(x*0.08+2));
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
  int i = 0;
  for (PVector point : endpointPath) {
    point = endpointPath.get(i);
    //float opacity = 255*((float)i/endpointPath.size());
    stroke(((float)i*0.100001)%255, 255, 255, 255);
    vertex(point.x, point.y, point.z);
    i++;
  }
  endShape();
  popStyle();

  popMatrix();
}

void mousePressed() {
}

void keyPressed() {
  if (key == 'c') endpointPath.clear();
}


void mouseWheel(MouseEvent e) {
  zoom *= pow(zoomMultiplier, -e.getCount());
}
