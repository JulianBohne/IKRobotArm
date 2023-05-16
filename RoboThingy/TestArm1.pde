
Arm testArm1() {
  Arm arm = new Arm()
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

  return arm;
}
