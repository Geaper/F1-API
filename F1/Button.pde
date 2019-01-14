class Button {
 
  color butFill = 0;
  int buttonX, buttonY, buttonWidth, buttonHeight;
  boolean overButton, buttonOn;
  String text;
 
  Button(int tempbuttonX, int tempbuttonY, int tempbuttonWidth, int tempbuttonHeight, String text) {
    buttonX = tempbuttonX;
    buttonY = tempbuttonY;
    buttonWidth = tempbuttonWidth;
    buttonHeight = tempbuttonHeight;
    this.text = text;
  }
  void display() {
    fill(butFill);
    rect(buttonX, buttonY, buttonWidth, buttonHeight);
    textSize(10);
    fill(255);
    text(text, buttonX + buttonWidth * .22, buttonY + buttonHeight/2);
  }
 
  boolean hasClicked() {
    return mouseX > buttonX & mouseX < buttonX+buttonWidth & mouseY > buttonY & mouseY < buttonY+buttonHeight;
  }
}
