import processing.net.*;
import omicronAPI.*;
import processing.opengl.*;
import com.modestmaps.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;
import com.modestmaps.providers.*;
import de.bezier.data.sql.*;
import org.gicentre.utils.stat.*;

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


BarChart barChart;
PFont titleFont,smallFont;

Hashtable touchList;
int sizeX = ceil(8160/5);
int sizeY = ceil(2304/5);
int scaleFactor = 1; //5 for wall
int scaleFactorY = 1; //5 for wall
boolean clicked = false, menu = false, menuS = false;


//Database stuff
String mysqlUser = "root";
String mysqlPwd = "bs140209";
String mysqlServer = "localhost";
String mysqlDatabase = "FARS"; 
int theState = 17;
int theYear = 2001;

// Switch statement categories
int currentYear;
int gender;
int age;
int weather;
int hitAndRun;
int time; 
int season;
int days;

// Arrays to store values
float[] values = new float [10];

String theGender = "where gender = 'male' or gender = 'female'";
String theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_"+theYear+" where istatenum = "+theState;
String dataPointQuery = "", dataPointQInitial = "Select latitude, longitude ", dataPointQtrail = " where latitude != -1.0 and longitude != -1";
ArrayList<Integer> dataPoint = new ArrayList<Integer>();
String d_age = "", d_gen = "", d_time = "", d_wday = "", d_hnr = "", d_wtr = "", d_from = "", d_year = " from year_2010";


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

//Create State buttons
easyButton bSt1  = new easyButton(percentX(1), percentY(37), percentX(1), percentX(1),"Sunday");
easyButton bSt2  = new easyButton(percentX(1), percentY(43), percentX(1), percentX(1),"Monday");
easyButton bSt3  = new easyButton(percentX(1), percentY(49), percentX(1), percentX(1),"Tuesday");
easyButton bSt4  = new easyButton(percentX(1), percentY(55), percentX(1), percentX(1),"Wednesday");
easyButton bSt5  = new easyButton(percentX(1), percentY(61), percentX(1), percentX(1),"Thursday");
easyButton bSt6  = new easyButton(percentX(1), percentY(67), percentX(1), percentX(1),"Friday");
easyButton bSt7  = new easyButton(percentX(1), percentY(73), percentX(1), percentX(1),"Saturday");
easyButton bSt8  = new easyButton(percentX(1), percentY(79), percentX(1), percentX(1),"Saturday");
easyButton bSt9  = new easyButton(percentX(1), percentY(85), percentX(1), percentX(1),"Saturday");
easyButton bSt10  = new easyButton(percentX(1), percentY(91), percentX(1), percentX(1),"Saturday");

easyButton bSt11  = new easyButton(percentX(9), percentY(37), percentX(1), percentX(1),"Sunday");
easyButton bSt12  = new easyButton(percentX(9), percentY(43), percentX(1), percentX(1),"Monday");
easyButton bSt13  = new easyButton(percentX(9), percentY(49), percentX(1), percentX(1),"Tuesday");
easyButton bSt14  = new easyButton(percentX(9), percentY(55), percentX(1), percentX(1),"Wednesday");
easyButton bSt15  = new easyButton(percentX(9), percentY(61), percentX(1), percentX(1),"Thursday");
easyButton bSt16  = new easyButton(percentX(9), percentY(67), percentX(1), percentX(1),"Friday");
easyButton bSt17  = new easyButton(percentX(9), percentY(73), percentX(1), percentX(1),"Saturday");
easyButton bSt18  = new easyButton(percentX(9), percentY(79), percentX(1), percentX(1),"Saturday");
easyButton bSt19  = new easyButton(percentX(9), percentY(85), percentX(1), percentX(1),"Saturday");
easyButton bSt20  = new easyButton(percentX(9), percentY(91), percentX(1), percentX(1),"Saturday");

easyButton bSt21  = new easyButton(percentX(18), percentY(37), percentX(1), percentX(1),"Sunday");
easyButton bSt22  = new easyButton(percentX(18), percentY(43), percentX(1), percentX(1),"Monday");
easyButton bSt23  = new easyButton(percentX(18), percentY(49), percentX(1), percentX(1),"Tuesday");
easyButton bSt24  = new easyButton(percentX(18), percentY(55), percentX(1), percentX(1),"Wednesday");
easyButton bSt25  = new easyButton(percentX(18), percentY(61), percentX(1), percentX(1),"Thursday");
easyButton bSt26  = new easyButton(percentX(18), percentY(67), percentX(1), percentX(1),"Friday");
easyButton bSt27  = new easyButton(percentX(18), percentY(73), percentX(1), percentX(1),"Saturday");
easyButton bSt28  = new easyButton(percentX(18), percentY(79), percentX(1), percentX(1),"Saturday");
easyButton bSt29  = new easyButton(percentX(18), percentY(85), percentX(1), percentX(1),"Saturday");
easyButton bSt30  = new easyButton(percentX(18), percentY(91), percentX(1), percentX(1),"Saturday");

easyButton bSt31  = new easyButton(percentX(27), percentY(37), percentX(1), percentX(1),"Sunday");
easyButton bSt32  = new easyButton(percentX(27), percentY(43), percentX(1), percentX(1),"Monday");
easyButton bSt33  = new easyButton(percentX(27), percentY(49), percentX(1), percentX(1),"Tuesday");
easyButton bSt34  = new easyButton(percentX(27), percentY(55), percentX(1), percentX(1),"Wednesday");
easyButton bSt35  = new easyButton(percentX(27), percentY(61), percentX(1), percentX(1),"Thursday");
easyButton bSt36  = new easyButton(percentX(27), percentY(67), percentX(1), percentX(1),"Friday");
easyButton bSt37  = new easyButton(percentX(27), percentY(73), percentX(1), percentX(1),"Saturday");
easyButton bSt38  = new easyButton(percentX(27), percentY(79), percentX(1), percentX(1),"Saturday");
easyButton bSt39  = new easyButton(percentX(27), percentY(85), percentX(1), percentX(1),"Saturday");
easyButton bSt40  = new easyButton(percentX(27), percentY(91), percentX(1), percentX(1),"Saturday");

easyButton bSt41  = new easyButton(percentX(36), percentY(37), percentX(1), percentX(1),"Sunday");
easyButton bSt42  = new easyButton(percentX(36), percentY(43), percentX(1), percentX(1),"Monday");
easyButton bSt43  = new easyButton(percentX(36), percentY(49), percentX(1), percentX(1),"Tuesday");
easyButton bSt44  = new easyButton(percentX(36), percentY(55), percentX(1), percentX(1),"Wednesday");
easyButton bSt45  = new easyButton(percentX(36), percentY(61), percentX(1), percentX(1),"Thursday");
easyButton bSt46  = new easyButton(percentX(36), percentY(67), percentX(1), percentX(1),"Friday");
easyButton bSt47  = new easyButton(percentX(36), percentY(73), percentX(1), percentX(1),"Saturday");
easyButton bSt48  = new easyButton(percentX(36), percentY(79), percentX(1), percentX(1),"Saturday");
easyButton bSt49  = new easyButton(percentX(36), percentY(85), percentX(1), percentX(1),"Saturday");
easyButton bSt50  = new easyButton(percentX(36), percentY(91), percentX(1), percentX(1),"Saturday");




void drawStateMenu()
{
  bSt1.drawEasy();
  bSt2.drawEasy();
  bSt3.drawEasy();
  bSt4.drawEasy();
  bSt5.drawEasy();
  bSt6.drawEasy();
  bSt7.drawEasy();
  bSt8.drawEasy();
  bSt9.drawEasy();
  bSt10.drawEasy();
  bSt11.drawEasy();
  bSt12.drawEasy();
  bSt13.drawEasy();
  bSt14.drawEasy();
  bSt15.drawEasy();
  bSt16.drawEasy();
  bSt17.drawEasy();
  bSt18.drawEasy();
  bSt19.drawEasy();
  bSt20.drawEasy();
  bSt21.drawEasy();
  bSt22.drawEasy();
  bSt23.drawEasy();
  bSt24.drawEasy();
  bSt25.drawEasy();
  bSt26.drawEasy();
  bSt27.drawEasy();
  bSt28.drawEasy();
  bSt29.drawEasy();
  bSt30.drawEasy();
  bSt31.drawEasy();
  bSt32.drawEasy();
  bSt33.drawEasy();
  bSt34.drawEasy();
  bSt35.drawEasy();
  bSt36.drawEasy();
  bSt37.drawEasy();
  bSt38.drawEasy();
  bSt39.drawEasy();
  bSt40.drawEasy();
  bSt41.drawEasy();
  bSt42.drawEasy();
  bSt43.drawEasy();
  bSt44.drawEasy();
  bSt45.drawEasy();
  bSt46.drawEasy();
  bSt47.drawEasy();
  bSt48.drawEasy();
  bSt49.drawEasy();
  bSt50.drawEasy();
  
}

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
 //checkButton();
 
}

void checkButton()
{
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
  if(menu)
  {
      if (b1.mouseOver())
      {
        b1.toggleState();
        gender = 1;
        d_gen = " and gender = 'male'";
        b2.setStateFalse();
      }
      else if (b2.mouseOver())
      {
        b2.toggleState();
        gender = 2;
        d_gen = " and gender = 'female'";
        b1.setStateFalse();
      }
      else if (b3.mouseOver())
      {
        b3.toggleState();
        age = 1;
        d_age = " and driver = 'young adult'";
        b4.setStateFalse();
        b5.setStateFalse();
        b6.setStateFalse();
      }
      else if (b4.mouseOver())
      {
        b4.toggleState();
        age = 2;
        d_age = " and driver = 'adult'";
        b3.setStateFalse();
        b5.setStateFalse();
        b6.setStateFalse();
      }
      else if (b5.mouseOver())
      {
        b5.toggleState();
        age = 3;
        d_age = " and driver = 'old adult'";
        b3.setStateFalse();
        b4.setStateFalse();
        b6.setStateFalse();
      }
      else if (b6.mouseOver())
      {
        b6.toggleState();
        age = 4;
        d_age = " and driver = 'elderly'";
        b3.setStateFalse();
        b4.setStateFalse();
        b5.setStateFalse();
      }
      else if (b7.mouseOver())
      {
        b7.toggleState();
        weather = 1;
        d_wtr = " and aatmcond = 'clear'";
        b8.setStateFalse();
        b9.setStateFalse();
        b10.setStateFalse();
        b11.setStateFalse();
      }
      else if (b8.mouseOver())
      {
        b8.toggleState();
        weather = 2;
        d_wtr = " and aatmcond = 'rain'";
        b7.setStateFalse();
        b9.setStateFalse();
        b10.setStateFalse();
        b11.setStateFalse();
      }
      else if (b9.mouseOver())
      {
        b9.toggleState();
        weather = 3;
        d_wtr = " and aatmcond = 'sleet'";
        b8.setStateFalse();
        b7.setStateFalse();
        b10.setStateFalse();
        b11.setStateFalse();
      }
      else if (b10.mouseOver())
      {
        b10.toggleState();
        weather = 4;
        d_wtr = " and aatmcond = 'snow'";
        b7.setStateFalse();
        b8.setStateFalse();
        b9.setStateFalse();
        b11.setStateFalse();
      }
      else if (b11.mouseOver())
      {
        b11.toggleState();
        weather = 5;
        d_wtr = " and aatmcond = 'fog'";
        b7.setStateFalse();
        b8.setStateFalse();
        b9.setStateFalse();
        b10.setStateFalse();
      }
      else if (b12.mouseOver())
      {
        b12.toggleState();
        hitAndRun = 1;
        d_hnr = " and hitrun != 'no'";
      }
      else if (b13.mouseOver())
      {
        b13.toggleState();
        time = 1;
        d_time = " and time = 'morning'";
        b14.setStateFalse();
        b15.setStateFalse();
        b16.setStateFalse();
      }
      else if (b14.mouseOver())
      {
        b14.toggleState();
        time = 2;
        d_time = " and time = 'afternoon'";
        b13.setStateFalse();
        b15.setStateFalse();
        b16.setStateFalse();
      }
      else if (b15.mouseOver())
      {
        b15.toggleState();
        time = 3;
        d_time = " and time = 'evening'";
        b13.setStateFalse();
        b14.setStateFalse();
        b16.setStateFalse();
      }
      else if (b16.mouseOver())
      {
        b16.toggleState();
        time = 4;
        d_time = " and time = 'night'";
        b13.setStateFalse();
        b14.setStateFalse();
        b15.setStateFalse();
      }
      else if (b17.mouseOver())
      {
        b17.toggleState();
        season = 1;
        d_wtr = " and season = 'winter'";
        b18.setStateFalse();
        b19.setStateFalse();
        b20.setStateFalse();
      }
      else if (b18.mouseOver())
      {
        b18.toggleState();
        season = 2;
        d_wtr = " and season = 'spring'";
        b17.setStateFalse();
        b19.setStateFalse();
        b20.setStateFalse();
      }
      else if (b19.mouseOver())
      {
        b19.toggleState();
        season = 3;
        d_wtr = " and season = 'summer'";
        b17.setStateFalse();
        b18.setStateFalse();
        b20.setStateFalse();
      }
      else if (b20.mouseOver())
      {
        b20.toggleState();
        season = 4;
        d_wtr = " and season = 'fall'";
        b17.setStateFalse();
        b18.setStateFalse();
        b19.setStateFalse();
      }
      else if (b21.mouseOver())
      {
        b21.toggleState();
        days = 1;
        d_wday = " and day = 'sunday'";
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
        days = 2;
        d_wday = " and day = 'monday'";
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
        days = 3;
        d_wday = " and day = 'tuesday'";
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
        days = 4;
        d_wday = " and day = 'wednesday'";
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
        days = 5;
        d_wday = " and day = 'thursday'";
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
        days = 6;
        d_wday = " and day = 'friday'";
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
        days = 7;
        d_wday = " and day = 'saturday'";
        b21.setStateFalse();
        b22.setStateFalse();
        b23.setStateFalse();
        b24.setStateFalse();
        b25.setStateFalse();
        b26.setStateFalse();
      }
      // Update Button
        else if (b28.mouseOver())
      {
        
      if (currentYear == 0){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2001 where istatenum = "+theState;
         
      }
      else
      {
        dataPointQuery =  dataPointQInitial + d_year + dataPointQtrail + d_age + d_gen + d_time + d_wday + d_hnr + d_wtr;
         println(dataPointQuery);
         mapData.clear();
       
       try{
               db.getConnection(); 
              if (db.conn.connect())
              {
                  db.conn.query(dataPointQuery);
                                     
                  while (db.conn.next()) {
                    p = new position(); 
                    p.lat = Float.parseFloat(db.conn.getString(1)); 
                    p.lon = Float.parseFloat(db.conn.getString(2));
                     
                    mapData.add(p);
                          
                }
              }
          }
          catch (Exception e)
          {      
              System.err.println ("Error:DBHelper.dataPointQuery - " + e.toString());
           //   return null;        
          }
          
          db.closeConnection();
        
      }
    
        
        
        String newQuery = theQuery;
        
        // Switch statement
        switch(gender){
          case 1:
          newQuery += " and gender = 'male'";
          break;
          case 2:
          newQuery += " and gender = 'female'";
          break;  
        }
        switch(hitAndRun){
          case 1:
          newQuery += " and hitrun != 'no'";
          break;
        }
        switch(age){
          case 1:
          newQuery += " and driver = 'young adult'";
          break;
          case 2:
          newQuery += " and driver = 'adult'";
          break;  
          case 3:
          newQuery += " and driver = 'old adult'";
          break;  
          case 4:
          newQuery += " and driver = 'elderly'";
          break;  
        }
        switch(weather){
          case 1:
          newQuery += " and aatmcond = 'clear'";
          break;
          case 2:
          newQuery += " and aatmcond = 'rain'";
          break;  
          case 3:
          newQuery += " and aatmcond = 'sleet'";
          break;  
          case 4:
          newQuery += " and aatmcond = 'snow'";
          break;
          case 5:
          newQuery += " and aatmcond = 'fog'";
          break;  
        }
        switch(time){
          case 1:
          newQuery += " and time = 'morning'";
          break;
          case 2:
          newQuery += " and time = 'afternoon'";
          break;  
          case 3:
          newQuery += " and time = 'evening'";
          break;  
          case 4:
          newQuery += " and time = 'night'";
          break;
        }
        switch(season){
          case 1:
          newQuery += " and season = 'winter'";
          break;
          case 2:
          newQuery += " and season = 'spring'";
          break;  
          case 3:
          newQuery += " and season = 'summer'";
          break;  
          case 4:
          newQuery += " and season = 'fall'";
          break;
        }
        switch(days){
          case 1:
          newQuery += " and day = 'sunday'";
          break;
          case 2:
          newQuery += " and day = 'monday'";
          break;  
          case 3:
          newQuery += " and day = 'tuesday'";
          break;  
          case 4:
          newQuery += " and day = 'wednesday'";
          break;
          case 5:
          newQuery += " and day = 'thursday'";
          break;
          case 6:
          newQuery += " and day = 'friday'";
          break;
          case 7:
          newQuery += " and day = 'saturday'";
          break;
        }
        switch(currentYear){
          case 2001:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[0] = db.conn.getFloat(1);
           //println(values[0]);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2002:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[1] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;  
          case 2003:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[2] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;  
          case 2004:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[3] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2005:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[4] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2006:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[5] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2007:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[6] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2008:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[7] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2009:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[8] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
          case 2010:
         // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[9] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
          break;
        }
        
        println(newQuery);
    
        
        if(currentYear == 0){
        // ----------- Databse Query ------------
        Arrays.fill(values,0);
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[0] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        newQuery = newQuery.replaceAll("year_2001", "year_2002");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[1] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2002", "year_2003");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[2] = db.conn.getInt(1);
          }
        }
        db.closeConnection();  
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2003", "year_2004");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[3] = db.conn.getInt(1);
          }
        }
        db.closeConnection();  
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2004", "year_2005");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[4] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2005", "year_2006");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[5] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2006", "year_2007");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[6] = db.conn.getInt(1);
          }
        }
        db.closeConnection();
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2007", "year_2008");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[7] = db.conn.getInt(1);
          }
        }
        db.closeConnection();  
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2008", "year_2009");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[8] = db.conn.getInt(1);
          }
        }
        db.closeConnection(); 
        // ----------- Databse Query ------------
        newQuery = newQuery.replaceAll("year_2009", "year_2010");
        db.getConnection();
        if (db.conn.connect()){
            db.conn.query(newQuery);
           while(db.conn.next()){
           values[9] = db.conn.getInt(1);
          }
        }
        db.closeConnection();   
        }
      
      
      }
    }
  else if (by1.mouseOver())
  {
    by1.toggleState();
    theYear = 2001;
    currentYear = 0;
    db.getConnection();
    if (db.conn.connect()){
      // Loop over all the years
      for(int i = 2001,j=0; i< 2011; i++,j++){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_"+theYear+" where istatenum = "+theState;
        theYear++;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[j] = db.conn.getInt(1);
      }
    }
    }
    db.closeConnection();
    
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
    d_year = " from year_2001";
  }
  else if (by2.mouseOver())
  {
    by2.toggleState();
    d_year = " from year_2001";
    currentYear = 2001;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2001 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       //println(db.conn.getFloat(1));
       values[0] = db.conn.getFloat(1);
       //println(values[0]);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
    
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
    d_year = " from year_2002";
    currentYear = 2002;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2002 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[1] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2003";
    currentYear = 2003;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2003 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[2] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2004";
    currentYear = 2004;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2004 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[3] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    currentYear = 2005;
    d_year = " from year_2005";
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2005 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[4] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2006";
    currentYear = 2006;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2006 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[5] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2007";
    currentYear = 2007;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2007 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[6] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2008";
    currentYear = 2008;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2008 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[7] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2009";
    currentYear = 2009;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2009 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[8] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
    d_year = " from year_2010";
    currentYear = 2010;
    // ----------- Databse Query ------------
    Arrays.fill(values,0);
    db.getConnection();
    if (db.conn.connect()){
        theQuery = "SELECT COUNT(distinct icasenum) as NumberofCases from year_2010 where istatenum = "+theState;
        db.conn.query(theQuery);
       while(db.conn.next()){
       values[9] = db.conn.getInt(1);
      }
    }
    db.closeConnection();
    // ----------- Databse Query ------------
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
  
  if(menuS)
  {
    if (bSt1.mouseOver())
    {
        bSt1.toggleState();
        
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt2.mouseOver())
    {
        bSt2.toggleState();
        
        bSt1.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt3.mouseOver())
    {
        bSt3.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt4.mouseOver())
    {
        bSt4.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt5.mouseOver())
    {
        bSt5.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt6.mouseOver())
    {
        bSt6.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt7.mouseOver())
    {
        bSt7.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt8.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt8.mouseOver())
    {
        bSt8.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt9.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt9.mouseOver())
    {
        bSt9.toggleState();
        
        bSt1.setStateFalse();
        bSt2.setStateFalse();
        bSt3.setStateFalse();
        bSt4.setStateFalse();
        bSt5.setStateFalse();
        bSt6.setStateFalse();
        bSt7.setStateFalse();
        bSt8.setStateFalse();
        bSt10.setStateFalse();
        bSt11.setStateFalse();
        bSt12.setStateFalse();
        bSt13.setStateFalse();
        bSt14.setStateFalse();
        bSt15.setStateFalse();
        bSt16.setStateFalse();
        bSt17.setStateFalse();
        bSt18.setStateFalse();
        bSt19.setStateFalse();
        bSt20.setStateFalse();
        bSt21.setStateFalse();
        bSt22.setStateFalse();
        bSt23.setStateFalse();
        bSt24.setStateFalse();
        bSt25.setStateFalse();
        bSt26.setStateFalse();
        bSt27.setStateFalse();
        bSt28.setStateFalse();
        bSt29.setStateFalse();
        bSt30.setStateFalse();
        bSt31.setStateFalse();
        bSt32.setStateFalse();
        bSt33.setStateFalse();
        bSt34.setStateFalse();
        bSt35.setStateFalse();
        bSt36.setStateFalse();
        bSt37.setStateFalse();
        bSt38.setStateFalse();
        bSt39.setStateFalse();
        bSt40.setStateFalse();
        bSt41.setStateFalse();
        bSt42.setStateFalse();
        bSt43.setStateFalse();
        bSt44.setStateFalse();
        bSt45.setStateFalse();
        bSt46.setStateFalse();
        bSt47.setStateFalse();
        bSt48.setStateFalse();
        bSt49.setStateFalse();
        bSt50.setStateFalse();

    }
    else if(bSt10.mouseOver())
    {
        bSt10.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt11.setStateFalse();
        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();        bSt16.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt11.mouseOver())
    {
        bSt11.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();        bSt16.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt12.mouseOver())
    {
        bSt12.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();        bSt16.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt13.mouseOver())
    {
        bSt13.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();        bSt16.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt14.mouseOver())
    {
        bSt14.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt15.setStateFalse();        bSt16.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt15.mouseOver())
    {
        bSt15.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt16.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt16.mouseOver())
    {
        bSt16.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();
        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt17.mouseOver())
    {
        bSt17.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();
        bSt16.setStateFalse();        bSt18.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt18.mouseOver())
    {
        bSt18.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();
        bSt16.setStateFalse();        bSt17.setStateFalse();        bSt19.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
    else if(bSt19.mouseOver())
    {
        bSt19.toggleState();
        
        bSt1.setStateFalse();        bSt2.setStateFalse();        bSt3.setStateFalse();        bSt4.setStateFalse();        bSt5.setStateFalse();
        bSt6.setStateFalse();        bSt7.setStateFalse();        bSt8.setStateFalse();        bSt9.setStateFalse();        bSt10.setStateFalse();
        bSt11.setStateFalse();        bSt12.setStateFalse();        bSt13.setStateFalse();        bSt14.setStateFalse();        bSt15.setStateFalse();
        bSt16.setStateFalse();        bSt17.setStateFalse();        bSt18.setStateFalse();        bSt20.setStateFalse();        bSt21.setStateFalse();
        bSt22.setStateFalse();        bSt23.setStateFalse();        bSt24.setStateFalse();        bSt25.setStateFalse();        bSt26.setStateFalse();
        bSt27.setStateFalse();        bSt28.setStateFalse();        bSt29.setStateFalse();        bSt30.setStateFalse();        bSt31.setStateFalse();
        bSt32.setStateFalse();        bSt33.setStateFalse();        bSt34.setStateFalse();        bSt35.setStateFalse();        bSt36.setStateFalse();
        bSt37.setStateFalse();        bSt38.setStateFalse();        bSt39.setStateFalse();        bSt40.setStateFalse();        bSt41.setStateFalse();
        bSt42.setStateFalse();        bSt43.setStateFalse();        bSt44.setStateFalse();        bSt45.setStateFalse();        bSt46.setStateFalse();
        bSt47.setStateFalse();        bSt48.setStateFalse();        bSt49.setStateFalse();        bSt50.setStateFalse();

    }
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
  
  checkButton();
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
  
    
  
  if(menu && dist(percentX(2), percentY(35), xPos, yPos) < percentY(5))
  {
    //println();
     menu = false;
    // println("menu is turned " + menu);
  }
  else if (!menu && dist(percentX(2), percentY(99), xPos, yPos) < percentY(5))
  {
      menu = true;
      //println("menu is turned " + menu);
  }
  
  if (menu && dist(percentX(20), percentY(35), xPos, yPos) < percentY(5))
      menuS = true;
  else if (menu && dist(percentX(30), percentY(35), xPos, yPos) < percentY(5))
      menuS = false;
  
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
    fill (#333333,100);
    rectMode(CORNERS);
    noStroke();
    rect(percentX(0),percentY(_mhgt), percentX(45), percentY(100), percentX(2));
    stroke(#333333,100);
    strokeWeight(2 * scaleFactor);
    fill (#191919);
    ellipse(percentX(30), percentY(_mhgt), percentX(4), percentY(3));
    ellipse(percentX(20), percentY(_mhgt), percentX(4), percentY(3));
    fill (#B22400);
    ellipse(percentX(1), percentY(_mhgt), percentX(2), percentX(2));
    fill(255,255,255);
    textAlign(CENTER, CENTER);
    text("Filter",percentX(30), percentY(_mhgt));
    text("States",percentX(20), percentY(_mhgt));
    noStroke();
    strokeWeight(0);
}

void graphSetup(){
  
  noSmooth();
  //noLoop();
  
  titleFont = loadFont("Helvetica-22.vlw");
  smallFont = loadFont("Helvetica-12.vlw");
  textFont(smallFont);

  barChart = new BarChart(this);
  barChart.setData(values);
  barChart.setBarLabels(new String[] {"2001","2002","2003","2004","2005","2006","2007","2008","2009","2010"});
  barChart.setBarColour(color(200,80,80,100));
  barChart.setBarGap(3); 
  barChart.setValueFormat("###,###");
  barChart.showValueAxis(true); 
  barChart.showCategoryAxis(true); 
  barChart.setMinValue(0);
  barChart.setValueAxisLabel("Number Of Accidents");
  barChart.setCategoryAxisLabel("Year");
}
void drawGraph(){
  
  barChart.draw(0.04*sizeX,0.1*sizeY,sizeX/2.5,sizeY/2);
  fill(120);
  textFont(titleFont);
  text("Accidents", 0.08*sizeX,0.1*sizeY);
  float textHeight = textAscent();
  textFont(smallFont);
  text("For Illinois", 0.08*sizeX,0.1*sizeY+textHeight);
  
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




