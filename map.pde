
// this is the only bit that's needed to show a map:
InteractiveMap map;
// Locations
Location locationBerlin = new Location(52.5f, 13.4f);
Location locationLondon = new Location(51.5f, 0f);
Location locationChicago = new Location(41.9f, -87.6f);

Location locationUSA = new Location(38.962f, -93.928); // Use with zoom level 6
// set the initial location and zoom level:
  
  
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
