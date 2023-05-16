
class Style{
  
  color fill;
  color stroke;
  float strokeWeight;
  
  Style(){
    fill = #FFFFFF;
    stroke = #000000;
    strokeWeight = 0;
  }
  
  void apply(){
    fill(fill);
    strokeWeight(strokeWeight);
    stroke(stroke);
  }
}
