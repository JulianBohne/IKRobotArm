Arm obliqueSwivelTestArm(){
  float angle = PI/9;
  
  Arm arm = new Arm()
    .addComponentToActive(new ObliqueSwivelJoint(0), "j0")
    .addComponentToActive(new ArmLink(1), "l0")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j1")
    .addComponentToActive(new ArmLink(1), "l1")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j2")
    .addComponentToActive(new ArmLink(1), "l2")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j3")
    .addComponentToActive(new ArmLink(1), "l3")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j4")
    .addComponentToActive(new ArmLink(1), "l4")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j5")
    .addComponentToActive(new ArmLink(1), "l5")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j6")
    .addComponentToActive(new ArmLink(1), "l6")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j7")
    .addComponentToActive(new ArmLink(1), "l7")
    .addComponentToActive(new ObliqueSwivelJoint(angle), "j8")
    .addComponentToActive(new ArmLink(0.8), "l8")
    .addComponentToActive(new ArmEndpoint(0, 0.2, 0), "end");
  
    
  arm.getComponent("j1").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j2").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j3").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j4").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j5").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j6").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j7").visual.transform.scale.set(0.8, 0.2, 0.8);
  arm.getComponent("j8").visual.transform.scale.set(0.8, 0.2, 0.8);
  
  arm.getComponent(ArmLink.class, "l8").setDiameter(0.3);
  
  arm.getComponent("end").visual.style.fill = color(255, 0, 0);
  arm.getComponent("end").visual.transform.scale.set(0.1, 0.1, 0.1);
  
  //arm.transform.position.add(-1, 0, -1);
  
  //arm.transform.rotation.rotateY(-PI/4);
  //arm.transform.rotation.rotateZ(-PI/2);
  
  return arm;
}
