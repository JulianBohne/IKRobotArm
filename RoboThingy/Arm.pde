
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
