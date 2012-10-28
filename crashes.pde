/**
 * ---------------------------------------------
 * OmicronModestMaps.pde
 * Description: Omicron Processing example for running a Modest Maps touch application on the Cyber-Commons wall.
 *    Uses a modified version of ModestMaps allowing for a map offset. Adding the following constructor:
 *    new InteractiveMap(this, new Microsoft.RoadProvider(), mapOffset.x, mapOffset.y, mapSize.x, mapSize.y );
 *
 *    Note that any direct manipulation of the map position or scale (i.e. map.sc, map.tx, map.ty)
 *    will need to take in account the offset. For example the mouseWheel code is now:
 *    float mx = (mouseX - mapOffset.x) - mapSize.x/2;
 *    float my = (mouseY - mapOffset.y) - mapSize.y/2;
 *
 * Class: 
 * System: Processing 2.0.3 (beta), Windows 7, SUSE 12.1
 * Author: Arthur Nishimoto
 * Version: 1.0
 *
 * Version Notes:
 * 10/23/12      - Initial version
 * ---------------------------------------------
 */



// Override of PApplet init() which is called before setup()
public void init() {
  super.init();
  
  // Creates the OmicronAPI object. This is placed in init() since we want to use fullscreen
  omicronManager = new OmicronAPI(this);
  
  // Removes the title bar for full screen mode (present mode will not work on Cyber-commons wall)
  omicronManager.setFullscreen(true);
}

void setup() {
  
  if( onWall )
  {
    //size(8160, 2304, P2D); // JAVA2D or P2D is recommended
    size(sizeX, sizeY, P2D);
    
    // Make the connection to the tracker machine
    omicronManager.ConnectToTracker(7001, 7340, "131.193.77.159");
  }
  else
  {
    
    size( sizeX, sizeY, JAVA2D );
    
  }
  mapSize = new PVector( percentX(20), percentY(90));
  mapOffset = new PVector(percentX(70), percentY(0) );
  // Do not use smooth() on the wall with P2D (JAVA2D ok)
  noSmooth();
  
  touchList = new Hashtable();
  
  // Create a listener to get events
  touchListener = new TouchListener();
  
  // Register listener with OmicronAPI
  omicronManager.setTouchListener(touchListener);
  
  // Sets applet to this sketch
  applet = this;

  // create a new map, optionally specify a provider
  
  // OpenStreetMap would be like this:
  //map = new InteractiveMap(this, new OpenStreetMapProvider());
  // but it's a free open source project, so don't bother their server too much
  
  // AOL/MapQuest provides open tiles too
  // see http://developer.mapquest.com/web/products/open/map for terms
  // and this is how to use them:
  String template = "http://{S}.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png";
  String[] subdomains = new String[] { "otile1", "otile2", "otile3", "otile4" }; // optional
  map = new InteractiveMap(this, new Microsoft.RoadProvider(), mapOffset.x, mapOffset.y, mapSize.x, mapSize.y );
  
  setMapProvider(0);
  
  // others would be "new Microsoft.HybridProvider()" or "new Microsoft.AerialProvider()"
  // the Google ones get blocked after a few hundred tiles
  // the Yahoo ones look terrible because they're not 256px squares :)

  // set the initial location and zoom level:
  map.setCenterZoom(locationChicago, 5);  
  
  // zoom 0 is the whole world, 19 is street level
  // (try some out, or use getlatlon.com to search for more)

  // set a default font for labels
  font = createFont("Helvetica", 12);

  // enable the mouse wheel, for zooming
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }); 

}


void draw() {
  background(0);
  
  
  // draw the map:
  map.draw();
  // (that's it! really... everything else is interactions now)
  
  // Draw a rectangle showing the the resized and offset map
  //noFill();
  //stroke(10);
  //strokeWeight(10);
  //rect(mapOffset.x,mapOffset.y, mapSize.x,mapSize.y);
  //strokeWeight(1);
  
  // Do not use smooth() on the wall with P2D (JAVA2D ok)
  noSmooth();

  // draw all the buttons and check for mouse-over
  boolean hand = false;
  if (gui) {
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw();
      hand = hand || buttons[i].mouseOver();
    }
  }

  // if we're over a button, use the finger pointer
  // otherwise use the cross
  // (I wish Java had the open/closed hand for "move" cursors)
  cursor(hand ? HAND : CROSS);

  
// see if the arrow keys or +/- keys are pressed:
  // (also check space and z, to reset or round zoom levels)
  if (keyPressed) {
    if (key == CODED) {
      if (keyCode == LEFT) {
        map.tx += 5.0/map.sc;
      }
      else if (keyCode == RIGHT) {
        map.tx -= 5.0/map.sc;
      }
      else if (keyCode == UP) {
        map.ty += 5.0/map.sc;
      }
      else if (keyCode == DOWN) {
        map.ty -= 5.0/map.sc;
      }
    }  
    else if (key == '+' || key == '=') {
      map.sc *= 1.05;
    }
    else if (key == '_' || key == '-' && map.sc > 2) {
      map.sc *= 1.0/1.05;
    }
  }
  
  if (gui) {
    textFont(font, 12);

    // grab the lat/lon location under the mouse point:
    Location location = map.pointLocation(mouseX, mouseY);

    // draw the mouse location, bottom left:
    fill(0);
    noStroke();
    rect(5, height-5-g.textSize, textWidth("mouse: " + location), g.textSize+textDescent());
    fill(255,255,0);
    textAlign(LEFT, BOTTOM);
    //text("mouse: " + location, 5, height-5);
    text("Touches: " + touchList.size(), 5, height-5);
    
    if(clicked)
    drawDetails();
    drawMenu();
    // grab the center
    //location = map.pointLocation(mapOffset.x + mapSize.x/2, mapOffset.y + mapSize.y/2);

    // draw the center location, bottom right:
    fill(0);
    noStroke();
    float rw = textWidth("map: " + location);
    rect(width-5-rw, height-5-g.textSize, rw, g.textSize+textDescent());
    fill(255,255,0);
    //textAlign(RIGHT, BOTTOM);
    text("map: " + location, width-5, height-5);

    //location = new Location(51.500, -0.126);
    location = locationChicago;
    Point2f p = map.locationPoint(location);

    fill(0,255,128);
    stroke(255,255,0);
    ellipse(p.x, p.y, 10, 10);
  }  
  
  fill(16);
  noStroke();
  rect(0, height-16 * 2, 100, 16 * 2);
  fill(255,255,0);
  //text("mouse: " + location, 5, height-5);
  
  // Center of the map
  Location location = map.pointLocation(mapOffset.x + mapSize.x/2, mapOffset.y + mapSize.y/2);
  text("map: " + location + " scale: "+map.sc, 5, height-5 - 16);
  
  text("Touches: " + touchList.size(), 5, height-5);
    
  //println((float)map.sc);
  //println((float)map.tx + " " + (float)map.ty);
  //println();
  
  omicronManager.process();
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

// see if we're over any buttons, and respond accordingly:
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


