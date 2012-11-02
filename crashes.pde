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
//  initializeStuff();
  touchList = new Hashtable();
  
  // Create a listener to get events
  touchListener = new TouchListener();
  
  // Register listener with OmicronAPI
  omicronManager.setTouchListener(touchListener);
  
  // Sets applet to this sketch
  applet = this;
  
  String template = "http://{S}.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png";
  String[] subdomains = new String[] { "otile1", "otile2", "otile3", "otile4" }; // optional
  map = new InteractiveMap(this, new Microsoft.RoadProvider(), mapOffset.x, mapOffset.y, mapSize.x, mapSize.y );
  
  setMapProvider(0);
  map.setCenterZoom(locationChicago, 5);
  // others would be "new Microsoft.HybridProvider()" or "new Microsoft.AerialProvider()"
  // the Google ones get blocked after a few hundred tiles
  // the Yahoo ones look terrible because they're not 256px squares :)

  
  // zoom 0 is the whole world, 19 is street level
  // (try some out, or use getlatlon.com to search for more)

  // enable the mouse wheel, for zooming
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }); 
  rectMode(CORNER);

}


void draw() {
  background(#CCCCCC);
  
  map.draw();
    
  // Do not use smooth() on the wall with P2D (JAVA2D ok)
  noSmooth();

  // draw all the buttons and check for mouse-over
  boolean hand = false;
  

//fetchData();
// see if we're over any buttons, and respond accordingly:

  // if we're over a button, use the finger pointer
  // otherwise use the cross
  cursor(hand ? HAND : CROSS);
if (gui) {
    textFont(font, 12 * scaleFactor);

    // grab the lat/lon location under the mouse point:
    Location location = map.pointLocation(mouseX, mouseY);

    fill(255,255,0);
    textAlign(LEFT, BOTTOM);
    //text("mouse: " + location, 5, height-5);
    text("Touches: " + touchList.size(), 5, height-5);

    if(clicked)
    drawDetails();
    if(menuCounter <= 99 && menuCounter >= 35)
    {
      if(!menu)
      {
        while(menuCounter < 99)
        {
          menuCounter += 1;
        }
      }
      else if (menu)
      {
        while(menuCounter > 35)
        {
           menuCounter -= 1;
        }
      }
    }
    
    drawMenu(menuCounter);
    
    if (menu && menuCounter == 35)
    {
      drawButtons();
    }
    // grab the center
    //location = map.pointLocation(mapOffset.x + mapSize.x/2, mapOffset.y + mapSize.y/2);

    fill(255,255,0);
    //textAlign(RIGHT, BOTTOM);
    text("map: " + location, width-5, height-5);

    //location = new Location(51.500, -0.126);
    location = locationChicago;
    Point2f p = map.locationPoint(location);

    if (p.x > percentX(35) )
    {
      fill(0,255,128);
      stroke(255,255,0);
      ellipse(p.x, p.y, 10*scaleFactorY, 10);
    }
  }  
  
  fill(0);
  //text("mouse: " + location, 5, height-5);
  
  // Center of the map
  Location location = map.pointLocation(mapOffset.x + mapSize.x/2, mapOffset.y + mapSize.y/2);
  text("map: " + location + " scale: "+map.sc, 5, height-5 - 16);
  
  text("Touches: " + touchList.size(), 5, height-5);
    
  //println((float)map.sc);
  //println((float)map.tx + " " + (float)map.ty);
  //println();
 if (gui && !onWall) {
   //println("Inside the function that prints buttons");
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw();
      hand = hand || buttons[i].mouseOver();
    }
  } 
  
 omicronManager.process();
}


