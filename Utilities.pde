import processing.net.*;
import omicronAPI.*;
import processing.opengl.*;
import com.modestmaps.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;
import com.modestmaps.providers.*;
import de.bezier.data.sql.*;

OmicronAPI omicronManager;
TouchListener touchListener;
PVector mapSize;
PVector mapOffset;
boolean onWall = false;
boolean gui = true;
PFont font = createFont("Helvetica", 30);
// Link to this Processing applet - used for touchDown() callback example
PApplet applet;
DBHelper db = new DBHelper();//To work with database

Hashtable touchList;
int sizeX = ceil(8160/5);
int sizeY = ceil(2304/5);
int scaleFactor = 1; //5 for wall
int scaleFactorY = 1; //5 for wall
boolean clicked = false, menu = false;
int menuCounter = 99;//when the menu is closed, position of the upper line is percentY(99)

//Database stuff
String mysqlUser = "root";
String mysqlPwd = "bs140209";
String mysqlServer = "";
String mysqlDatabase = "FARS"; 

ArrayList<Integer> dataPoint = new ArrayList<Integer>();


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

//Menu buttons
easyButton b1  = new easyButton(percentX(1), percentY(37), percentX(2), percentX(2),"Male");
easyButton b2  = new easyButton(percentX(1), percentY(45), percentX(2), percentX(2),"Female");

easyButton b3  = new easyButton(percentX(1), percentY(58), percentX(2), percentX(2),"Young\nAdult");
easyButton b4  = new easyButton(percentX(1), percentY(66), percentX(2), percentX(2),"Adult");
easyButton b5  = new easyButton(percentX(1), percentY(74), percentX(2), percentX(2),"Old Adult");
easyButton b6  = new easyButton(percentX(1), percentY(82), percentX(2), percentX(2),"Elderly");

easyButton b7  = new easyButton(percentX(10), percentY(37), percentX(2), percentX(2),"Clear");
easyButton b8  = new easyButton(percentX(10), percentY(45), percentX(2), percentX(2),"Rain");
easyButton b9  = new easyButton(percentX(10), percentY(53), percentX(2), percentX(2),"Sleet");
easyButton b10  = new easyButton(percentX(10), percentY(61), percentX(2), percentX(2),"Snow");
easyButton b11  = new easyButton(percentX(10), percentY(69), percentX(2), percentX(2),"Fog");

easyButton b12  = new easyButton(percentX(10), percentY(82), percentX(2), percentX(2),"Hit and\nRun");

easyButton b13  = new easyButton(percentX(19), percentY(37), percentX(2), percentX(2),"Morning");
easyButton b14  = new easyButton(percentX(19), percentY(45), percentX(2), percentX(2),"Afternoon");
easyButton b15  = new easyButton(percentX(19), percentY(53), percentX(2), percentX(2),"Evening");
easyButton b16  = new easyButton(percentX(19), percentY(61), percentX(2), percentX(2),"Night");

easyButton b17  = new easyButton(percentX(28), percentY(37), percentX(2), percentX(2),"Winter");
easyButton b18  = new easyButton(percentX(28), percentY(45), percentX(2), percentX(2),"Spring");
easyButton b19  = new easyButton(percentX(28), percentY(53), percentX(2), percentX(2),"Summer");
easyButton b20  = new easyButton(percentX(28), percentY(61), percentX(2), percentX(2),"Fall");

easyButton b21  = new easyButton(percentX(37), percentY(37), percentX(2), percentX(2),"Sunday");
easyButton b22  = new easyButton(percentX(37), percentY(45), percentX(2), percentX(2),"Monday");
easyButton b23  = new easyButton(percentX(37), percentY(53), percentX(2), percentX(2),"Tuesday");
easyButton b24  = new easyButton(percentX(37), percentY(61), percentX(2), percentX(2),"Wednesday");
easyButton b25  = new easyButton(percentX(37), percentY(69), percentX(2), percentX(2),"Thursday");
easyButton b26  = new easyButton(percentX(37), percentY(77), percentX(2), percentX(2),"Friday");
easyButton b27  = new easyButton(percentX(37), percentY(86), percentX(2), percentX(2),"Saturday");

easyButton b28  = new easyButton(percentX(21), percentY(80), percentX(8), percentX(2),"Update");

//year buttons

easyButton by1  = new easyButton(percentX(1), percentY(80), percentX(6), percentY(15),"All");
easyButton by2  = new easyButton(percentX(10), percentY(80), percentX(6), percentY(5),"2001");
easyButton by3  = new easyButton(percentX(16), percentY(80), percentX(6), percentY(5),"2002");
easyButton by4  = new easyButton(percentX(22), percentY(80), percentX(6), percentY(5),"2003");
easyButton by5  = new easyButton(percentX(28), percentY(80), percentX(6), percentY(5),"2004");
easyButton by6  = new easyButton(percentX(34), percentY(80), percentX(6), percentY(5),"2005");
easyButton by7  = new easyButton(percentX(10), percentY(90), percentX(6), percentY(5),"2006");
easyButton by8  = new easyButton(percentX(16), percentY(90), percentX(6), percentY(5),"2007");
easyButton by9  = new easyButton(percentX(22), percentY(90), percentX(6), percentY(5),"2008");
easyButton by10  = new easyButton(percentX(28), percentY(90), percentX(6), percentY(5),"2009");
easyButton by11  = new easyButton(percentX(34), percentY(90), percentX(6), percentY(5),"2010");

//percent screen width height utilites
float percentX(int value){
  return (value * sizeX)/100;
}

float percentY(int value){
  return (value * sizeY)/100;
}

void drawYearButtons()
{
  by1.drawEasy();
  by2.drawEasy();
  by3.drawEasy();
  by4.drawEasy();
  by5.drawEasy();
  by6.drawEasy();
  by7.drawEasy();
  by8.drawEasy();
  by9.drawEasy();
  by10.drawEasy();
  by11.drawEasy();
  
}

void drawButtons()
{
  b1.drawEasy();
  b2.drawEasy();
  b3.drawEasy();
  b4.drawEasy();
  b5.drawEasy();
  b6.drawEasy();
  b7.drawEasy();
  b8.drawEasy();
  b9.drawEasy();
  b10.drawEasy();
  b11.drawEasy();
  b12.drawEasy();
  b13.drawEasy();
  b14.drawEasy();
  b15.drawEasy();
  b16.drawEasy();
  b17.drawEasy();
  b18.drawEasy();
  b19.drawEasy();
  b20.drawEasy();
  b21.drawEasy();
  b22.drawEasy();
  b23.drawEasy();
  b24.drawEasy();
  b25.drawEasy();
  b26.drawEasy();
  b27.drawEasy();
  b28.drawEasy();
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
  else if (b1.mouseOver())
  {
    b1.toggleState();
    b2.setStateFalse();
  }
  else if (b2.mouseOver())
  {
    b2.toggleState();
    b1.setStateFalse();
  }
  else if (b3.mouseOver())
  {
    b3.toggleState();
    b4.setStateFalse();
    b5.setStateFalse();
    b6.setStateFalse();
  }
  else if (b4.mouseOver())
  {
    b4.toggleState();
    b3.setStateFalse();
    b5.setStateFalse();
    b6.setStateFalse();
  }
  else if (b5.mouseOver())
  {
    b5.toggleState();
    b3.setStateFalse();
    b4.setStateFalse();
    b6.setStateFalse();
  }
  else if (b6.mouseOver())
  {
    b6.toggleState();
    b3.setStateFalse();
    b4.setStateFalse();
    b5.setStateFalse();
  }
  else if (b7.mouseOver())
  {
    b7.toggleState();
    b8.setStateFalse();
    b9.setStateFalse();
    b10.setStateFalse();
    b11.setStateFalse();
  }
  else if (b8.mouseOver())
  {
    b8.toggleState();
    b7.setStateFalse();
    b9.setStateFalse();
    b10.setStateFalse();
    b11.setStateFalse();
  }
  else if (b9.mouseOver())
  {
    b9.toggleState();
    b8.setStateFalse();
    b7.setStateFalse();
    b10.setStateFalse();
    b11.setStateFalse();
  }
  else if (b10.mouseOver())
  {
    b10.toggleState();
    b7.setStateFalse();
    b8.setStateFalse();
    b9.setStateFalse();
    b11.setStateFalse();
  }
  else if (b11.mouseOver())
  {
    b11.toggleState();
    b7.setStateFalse();
    b8.setStateFalse();
    b9.setStateFalse();
    b10.setStateFalse();
  }
  else if (b12.mouseOver())
  {
    b12.toggleState();
  }
  else if (b13.mouseOver())
  {
    b13.toggleState();
    b14.setStateFalse();
    b15.setStateFalse();
    b16.setStateFalse();
  }
  else if (b14.mouseOver())
  {
    b14.toggleState();
    b13.setStateFalse();
    b15.setStateFalse();
    b16.setStateFalse();
  }
  else if (b15.mouseOver())
  {
    b15.toggleState();
    b13.setStateFalse();
    b14.setStateFalse();
    b16.setStateFalse();
  }
  else if (b16.mouseOver())
  {
    b16.toggleState();
    b13.setStateFalse();
    b14.setStateFalse();
    b15.setStateFalse();
  }
  else if (b17.mouseOver())
  {
    b17.toggleState();
    b18.setStateFalse();
    b19.setStateFalse();
    b20.setStateFalse();
  }
  else if (b18.mouseOver())
  {
    b18.toggleState();
    b17.setStateFalse();
    b19.setStateFalse();
    b20.setStateFalse();
  }
  else if (b19.mouseOver())
  {
    b19.toggleState();
    b17.setStateFalse();
    b18.setStateFalse();
    b20.setStateFalse();
  }
  else if (b20.mouseOver())
  {
    b20.toggleState();
    b17.setStateFalse();
    b18.setStateFalse();
    b19.setStateFalse();
  }
  else if (b21.mouseOver())
  {
    b21.toggleState();
    b22.setStateFalse();
    b23.setStateFalse();
    b24.setStateFalse();
    b25.setStateFalse();
    b26.setStateFalse();
    b27.setStateFalse();
  }
  else if (b22.mouseOver())
  {
    b22.toggleState();
    b21.setStateFalse();
    b23.setStateFalse();
    b24.setStateFalse();
    b25.setStateFalse();
    b26.setStateFalse();
    b27.setStateFalse();
  }
  else if (b23.mouseOver())
  {
    b23.toggleState();
    b21.setStateFalse();
    b22.setStateFalse();
    b24.setStateFalse();
    b25.setStateFalse();
    b26.setStateFalse();
    b27.setStateFalse();
  }
  else if (b24.mouseOver())
  {
    b24.toggleState();
    b21.setStateFalse();
    b22.setStateFalse();
    b23.setStateFalse();
    b25.setStateFalse();
    b26.setStateFalse();
    b27.setStateFalse();
  }
  else if (b25.mouseOver())
  {
    b25.toggleState();
    b21.setStateFalse();
    b22.setStateFalse();
    b23.setStateFalse();
    b24.setStateFalse();
    b26.setStateFalse();
    b27.setStateFalse();
  }
  else if (b26.mouseOver())
  {
    b26.toggleState();
    b21.setStateFalse();
    b22.setStateFalse();
    b23.setStateFalse();
    b24.setStateFalse();
    b25.setStateFalse();
    b27.setStateFalse();
  }
  else if (b27.mouseOver())
  {
    b27.toggleState();
    b21.setStateFalse();
    b22.setStateFalse();
    b23.setStateFalse();
    b24.setStateFalse();
    b25.setStateFalse();
    b26.setStateFalse();
  }
  else if (by1.mouseOver())
  {
    by1.toggleState();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by2.mouseOver())
  {
    by2.toggleState();
    by1.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by3.mouseOver())
  {
    by3.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by4.mouseOver())
  {
    by4.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by5.mouseOver())
  {
    by5.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by6.mouseOver())
  {
    by6.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by7.mouseOver())
  {
    by7.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by8.mouseOver())
  {
    by8.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by9.mouseOver())
  {
    by9.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by10.setStateFalse();
    by11.setStateFalse();
  }
  else if (by10.mouseOver())
  {
    by10.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by11.setStateFalse();
  }
  else if (by11.mouseOver())
  {
    by11.toggleState();
    by1.setStateFalse();
    by2.setStateFalse();
    by3.setStateFalse();
    by4.setStateFalse();
    by5.setStateFalse();
    by6.setStateFalse();
    by7.setStateFalse();
    by8.setStateFalse();
    by9.setStateFalse();
    by10.setStateFalse();
    
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

void fetchData()
{
  //println("inside fetch Data");
  db.getConnection();
 // dataPoint = db.getFormatData(); 
  if (dataPoint == null)
    System.exit(1);  
  db.closeConnection();
}


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
    
  //println("menu is " + menu);
  if(menu && dist(percentX(22), percentY(35), xPos, yPos) < percentY(5))
  {
    //println();
     menu = false;
    // println("menu is turned " + menu);
  }
  else if (!menu && dist(percentX(22), percentY(99), xPos, yPos) < percentY(5))
  {
      menu = true;
      //println("menu is turned " + menu);
  }
  
}// touchDown

void touchMove(int ID, float xPos, float yPos, float xWidth, float yWidth){
  noFill();
  stroke(0,255,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  
  if( touchList.size() < 2 && xPos > percentX(40)){
    // Only one touch, drag map based on last position
    map.tx += (xPos - lastTouchPos.x)/map.sc;
    map.ty += (yPos - lastTouchPos.y)/map.sc;
  } else if( touchList.size() == 2 && xPos > percentX(40)){
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
  } else if( touchList.size() >= 5 && xPos > percentX(40)){
    
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
    textAlign(LEFT, UP);
    textFont(font);
    fill(0,0,0);
    text(dataPoint.get(0), p.x, p.y );
  }
}

void drawMenu(int _mhgt)
{
    fill (100,0,255,100);
    rectMode(CORNERS);
    noStroke();
    rect(percentX(0),percentY(_mhgt), percentX(45), percentY(100), percentX(2));
    fill (#1947D1);
    stroke(100,0,255,100);
    strokeWeight(percentY(1));
    ellipse(percentX(22), percentY(_mhgt), percentX(2), percentY(3));
    noStroke();
    strokeWeight(0);
}

/***************Structures******************/

class Glyph
{
  int fatalities;
  int caseId;
  String HitNRun;
  String Holiday;
  int alcohol;
  String[] vins;
}




