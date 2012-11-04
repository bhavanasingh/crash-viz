
// this is the only bit that's needed to show a map:
InteractiveMap map;
// Locations
Location locationBerlin = new Location(52.5f, 13.4f);
Location locationLondon = new Location(51.5f, 0f);
Location locationChicago = new Location(41.9f, -87.6f);

Location locationUSA = new Location(38.962f, -93.928); // Use with zoom level 6

position p;
ArrayList<position> mapData = new ArrayList<position>();
// set the initial location and zoom level:
  
void drawMap()
{
  //println("printing mapData");
  fill(0);
  for (int i = 0; i < mapData.size(); i++)
  {
    mapData.get(i).l = new Location(mapData.get(i).lat, mapData.get(i).lon);
    mapData.get(i).setPoint2f();
    noStroke();
    if(mapData.get(i).pf.x > percentX(45) && mapData.get(i).pf.x < percentX(100))
      ellipse(mapData.get(i).pf.x, mapData.get(i).pf.y, percentY(1), percentY(2));
   // println("Value of latitude and logitude " + mapData.get(i).lat + mapData.get(i).lon + "\n");
  }
  
  
}

  
// Providers ( 'm' on keyboard )
// 0 = Microsoft Road
// 1 = Microsoft Hybrid
// 2 = Microsoft Aerial
int currentProvider = 0;

void setMapProvider(int newProviderID){
  switch( newProviderID ){
    case 0: map.setMapProvider( new Microsoft.RoadProvider() ); break;
    case 1: map.setMapProvider( new Microsoft.HybridProvider() ); break;
    case 2: map.setMapProvider( new Microsoft.AerialProvider() ); break;
  }
}

public class position
{
  float mx, my, lat, lon;
  Location l;
  Point2f pf;
  
  void position()
  {
    mx = 0;
    my = 0;
    lat = 0;
    lon = 0;
  }
  
  void setPoint2f()
  {
    pf = map.locationPoint(l);
  }
}
