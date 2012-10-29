import processing.net.*;
import omicronAPI.*;
import processing.opengl.*;
import com.modestmaps.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;
import com.modestmaps.providers.*;

OmicronAPI omicronManager;
TouchListener touchListener;
PVector mapSize;
PVector mapOffset;
boolean onWall = false;
boolean gui = true;
PFont font = createFont("Helvetica", 12);
// Link to this Processing applet - used for touchDown() callback example
PApplet applet;

Hashtable touchList;
int sizeX = ceil(8160/5);
int sizeY = ceil(2304/5);
int scaleFactor = 1; //5 for wall
boolean clicked = false, menu = false;
int menuCounter = 99;//when the menu is closed, position of the upper line is percentY(99)


float c_lat, c_lon;


// buttons take x,y and width,height:
ZoomButton out = new ZoomButton(5,5,14,14,false);
ZoomButton in = new ZoomButton(22,5,14,14,true);
PanButton up = new PanButton(14,25,14,14,UP);
PanButton down = new PanButton(14,57,14,14,DOWN);
PanButton left = new PanButton(5,41,14,14,LEFT);
PanButton right = new PanButton(22,41,14,14,RIGHT);


// all the buttons in one place, for looping:
Button[] buttons = { in, out, up, down, left, right };


//percent screen width height utilites
int percentX(int value){

//  println("Returning value of percent " + (value * width)/100 + "value of width is " + width);
  return (value * width)/100;
}

int percentY(int value){
  return (value * height)/100;
}

void mouseClicked() {
  if (in.mouseOver()) {
    map.zoomIn();
  }
  else if (out.mouseOver()) {
    map.zoomOut();
  }
  else if (up.mouseOver()) {
    map.panUp();
  }
  else if (down.mouseOver()) {
    map.panDown();
  }
  else if (left.mouseOver()) {
    map.panLeft();
  }
  else if (right.mouseOver()) {
    map.panRight();
  }
}


// See TouchListener on how to use this function call
// In this example TouchListener draws a solid ellipse
// Ths functions here draws a ring around the solid ellipse

// NOTE: Mouse pressed, dragged, and released events will also trigger these
//       using an ID of -1 and an xWidth and yWidth value of 10.

// Touch position at last frame
PVector lastTouchPos = new PVector();
PVector lastTouchPos2 = new PVector();
int touchID1;
int touchID2;

PVector initTouchPos = new PVector();
PVector initTouchPos2 = new PVector();

void touchDown(int ID, float xPos, float yPos, float xWidth, float yWidth){
  noFill();
  stroke(255,0,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  
  // Update the last touch position
  lastTouchPos.x = xPos;
  lastTouchPos.y = yPos;
  
  // Add a new touch ID to the list
  Touch t = new Touch( ID, xPos, yPos, xWidth, yWidth );
  touchList.put(ID,t);
  
  if( touchList.size() == 1 ){ // If one touch record initial position (for dragging). Saving ID 1 for later
    touchID1 = ID;
    initTouchPos.x = xPos;
    initTouchPos.y = yPos;
  }
  else if( touchList.size() == 2 ){ // If second touch record initial position (for zooming). Saving ID 2 for later
    touchID2 = ID;
    initTouchPos2.x = xPos;
    initTouchPos2.y = yPos;
  }
  
  c_lat = xPos; c_lon = yPos;
  if(!clicked)
    clicked = true;
  else
    clicked = false;
    
  println("menu is " + menu);
  if(menu && dist(percentX(22), percentY(65), xPos, yPos) < percentY(5))
  {
    //println();
     menu = false;
     println("menu is turned " + menu);
  }
  else if (!menu && dist(percentX(22), percentY(99), xPos, yPos) < percentY(5))
  {
      menu = true;
      println("menu is turned " + menu);
  }
  
}// touchDown

void touchMove(int ID, float xPos, float yPos, float xWidth, float yWidth){
  noFill();
  stroke(0,255,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  
  if( touchList.size() < 2 ){
    // Only one touch, drag map based on last position
    map.tx += (xPos - lastTouchPos.x)/map.sc;
    map.ty += (yPos - lastTouchPos.y)/map.sc;
  } else if( touchList.size() == 2 ){
    // Only two touch, scale map based on midpoint and distance from initial touch positions
    
    float sc = dist(lastTouchPos.x, lastTouchPos.y, lastTouchPos2.x, lastTouchPos2.y);
    float initPos = dist(initTouchPos.x, initTouchPos.y, initTouchPos2.x, initTouchPos2.y);
    
    PVector midpoint = new PVector( (lastTouchPos.x+lastTouchPos2.x)/2, (lastTouchPos.y+lastTouchPos2.y)/2 );
    sc -= initPos;
    sc /= 5000;
    sc += 1;
    //println(sc);
    float mx = (midpoint.x - mapOffset.x) - mapSize.x/2;
    float my = (midpoint.y - mapOffset.y) - mapSize.y/2;
    map.tx -= mx/map.sc;
    map.ty -= my/map.sc;
    map.sc *= sc;
    map.tx += mx/map.sc;
    map.ty += my/map.sc;
  } else if( touchList.size() >= 5 ){
    
    // Zoom to entire USA
    map.setCenterZoom(locationUSA, 6);  
  }
  
  // Update touch IDs 1 and 2
  if( ID == touchID1 ){
    lastTouchPos.x = xPos;
    lastTouchPos.y = yPos;
  } else if( ID == touchID2 ){
    lastTouchPos2.x = xPos;
    lastTouchPos2.y = yPos;
  } 
  
  // Update touch list
  Touch t = new Touch( ID, xPos, yPos, xWidth, yWidth );
  touchList.put(ID,t);
}// touchMove

void touchUp(int ID, float xPos, float yPos, float xWidth, float yWidth){
  noFill();
  stroke(0,0,255);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  
  // Remove touch and ID from list
  touchList.remove(ID);
}// touchUp

// see if we're over any buttons, otherwise tell the map to drag
void mouseDragged() {
  boolean hand = false;
  if (gui) {
    for (int i = 0; i < buttons.length; i++) {
      hand = hand || buttons[i].mouseOver();
      if (hand) break;
    }
  }
  if (!hand) {
    //map.mouseDragged(); 
  }
}

// zoom in or out:
void mouseWheel(int delta) {
  float sc = 1.0;
  if (delta < 0) {
    sc = 1.05;
  }
  else if (delta > 0) {
    sc = 1.0/1.05; 
  }
  float mx = (mouseX - mapOffset.x) - mapSize.x/2;
  float my = (mouseY - mapOffset.y) - mapSize.y/2;
  map.tx -= mx/map.sc;
  map.ty -= my/map.sc;
  map.sc *= sc;
  map.tx += mx/map.sc;
  map.ty += my/map.sc;
}

void keyReleased() {
  if (key == 'g' || key == 'G') {
    gui = !gui;
  }
  else if (key == 's' || key == 'S') {
    save("modest-maps-app.png");
  }
  else if (key == 'z' || key == 'Z') {
    map.sc = pow(2, map.getZoom());
  }
  else if (key == ' ') {
    map.sc = 2.0;
    map.tx = -128;
    map.ty = -128; 
  }
  else if (key == 'm') {
    currentProvider++;
    
    if( currentProvider > 2 )
      currentProvider = 0;
      
    setMapProvider( currentProvider );
  }
}



void drawDetails()
{
  Point2f p = map.locationPoint(locationChicago);
  float d = dist(c_lat, c_lon, p.x, p.y);
  if (d < percentY(1))
  {
    fill (0,255,0,200);
    rectMode(CORNER);
    rect(p.x, p.y, percentX(10), percentY(30), percentX(2));
  }
}

void drawMenu(int _mhgt)
{
    fill (100,0,255,100);
    rectMode(CORNERS);
    rect(percentX(0),percentY(_mhgt), percentX(45), percentY(100), percentX(2));
    fill (#1947D1);
    stroke(100,0,255,100);
    strokeWeight(percentY(1));
    ellipse(percentX(22), percentY(_mhgt), percentX(2), percentY(3));
    noStroke();
    strokeWeight(0);
}




