class Button{
  int xpos, ypos, wid, hei;
  String label;
  
  Button(
  int tx, int ty,
  int tw, int th,
  String tlabel
  ){
    xpos = tx;
    ypos = ty;
    wid = tw;
    hei = th;
    label = tlabel;
  }
  
  void update(){
    smooth();
    fill(255);
    stroke(0);
    rect(xpos, ypos, wid, hei, 10);//draws the rectangle, the last param is the round corners
    fill(0);
    textSize(24); 
    text(label, xpos+wid/2-(textWidth(label)/2), ypos+hei/2+(textAscent()/2)); 
    //all of this just centers the text in the box
  } 
}
