Arm testArm2(){
  Arm arm = new Arm()
  .addComponentToActive(new SwivelJoint(), "j0")
  .addComponentToActive(new ArmLink(0.5), "fixedl0")
  .addComponentToActive(new HingeJoint(), "fixedj0")
  .addComponentToActive(new ArmLink(2), "l0")
  .addComponentToActive(new HingeJoint(), "j1")
  .addComponentToActive(new ArmLink(4), "l1")
  .addComponentToActive(new HingeJoint(), "j2")
  .addComponentToActive(new ArmLink(1), "l2")
  .addComponentToActive(new SwivelJoint(), "j3")
  .addComponentToActive(new ArmLink(2), "l3")
  .addComponentToActive(new HingeJoint(), "j4")
  .addComponentToActive(new ArmLink(0.5), "l4")
  .addComponentToActive(new SwivelJoint(), "j5")
  .addComponentToActive(new ArmLink(1), "l5")
  .addComponentToActive(new ArmEndpoint(0, 0.2, 0), "end");
  
  HingeJoint fixedJoint = arm.getComponent(HingeJoint.class, "fixedj0");
  fixedJoint.transform.rotation.rotateX(HALF_PI*2/3);
  fixedJoint.disableIK = true;
  
  arm.getComponent("j1").transform.rotation.rotateX(-PI + HALF_PI*2/3);
  arm.getComponent("j2").transform.rotation.rotateX(PI - HALF_PI*2/3);
  
  arm.getComponent(ArmLink.class, "l5").setDiameter(0.2);
  
  
  arm.getComponent("end").visual.style.fill = color(255, 0, 0);
  arm.getComponent("end").visual.transform.scale.set(0.1, 0.1, 0.1);
  
  return arm;
}
