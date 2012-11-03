class easyButton
{
  float X, Y, w, h;
  boolean state;
  String label;
  
  easyButton(float _x, float _y, float _w, float _h,String _l )
  {
    X = _x;
    Y = _y;
    w = _w;
    h = _h;
    label = _l;
    state = false;
    
    println("Inside the contrctor of easyButton. Value of (X, Y) is (" + X + "," + Y + ") \n");
  }
  
  boolean mouseOver() {
    return (mouseX > X && mouseX < X + w && mouseY > Y && mouseY < Y + h);
  }
  
  void toggleState()
  {
    state = !state;
  }
  
  void setStateFalse()
  {
    if(state == true)
      state = !state;//set it to false
  }
  
  void drawEasy()
  {
    //println("entering drawEasy function. Value of (X, Y) is (" + X + "," + Y + ") \n");
    rectMode(CORNER);
    stroke(#D9D9D9);
    strokeWeight(2 * scaleFactor);
    fill(#404040, 200);
    rect(X, Y, w, h, percentY(1));
    noFill();
    stroke(#D9D9D9);
    if (state)
    {
      line(X,Y, X+w, Y+h);
      line(X+w,Y, X, Y+h);
    }
    textFont(font, 13 * scaleFactor);
    textAlign(LEFT, UP);
    fill(0);
    text(label, X + percentY(8), Y + h / 2);
    
  }
  
}


class Button {
  
  float x, y, w, h;
  
  Button(float x, float y, float w, float h) {
//    println("Value of x and y in button is x = " + x + " y = " + y);
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  } 
  
  boolean mouseOver() {
    return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
  }
  
  void draw() {
    stroke(8);
    fill(mouseOver() ? 255: 220);
    rect(x,y,w,h); 
//    println("drawing rectagle from (" + x + "," + y + " with width (" + w + ", " + h + ")");
  }
  
}

class ZoomButton extends Button {
  
  boolean in = false;
  
  ZoomButton(float x, float y, float w, float h, boolean in) {
        super(x, y, w, h);    
   // println("Value of x and y in zoom button is x = " + x + " y = " + y);

    this.in = in;
  }
  
  void draw() {
    super.draw();
    stroke(2);
    line(x+3,y+h/2,x+w-3,y+h/2);
    if (in) {
      line(x+w/2,y+3,x+w/2,y+h-3);
    }
  }
  
}


class PanButton extends Button {
  
  int dir = UP;
  
  PanButton(float x, float y, float w, float h, int dir) {
    super(x, y, w, h);
    this.dir = dir;
  }
  
  void draw() {
    super.draw();
    stroke(0);
    switch(dir) {
      case UP:
        line(x+w/2,y+3,x+w/2,y+h-3);
        line(x-3+w/2,y+6,x+w/2,y+3);
        line(x+3+w/2,y+6,x+w/2,y+3);
        break;
      case DOWN:
        line(x+w/2,y+3,x+w/2,y+h-3);
        line(x-3+w/2,y+h-6,x+w/2,y+h-3);
        line(x+3+w/2,y+h-6,x+w/2,y+h-3);
        break;
      case LEFT:
        line(x+3,y+h/2,x+w-3,y+h/2);
        line(x+3,y+h/2,x+6,y-3+h/2);
        line(x+3,y+h/2,x+6,y+3+h/2);
        break;
      case RIGHT:
        line(x+3,y+h/2,x+w-3,y+h/2);
        line(x+w-3,y+h/2,x+w-6,y-3+h/2);
        line(x+w-3,y+h/2,x+w-6,y+3+h/2);
        break;
    }
  }
  
}
