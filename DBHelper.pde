
public class DBHelper {
  
  MySQL conn = null;
  
  public void getConnection(){
    
    try{
        conn = new MySQL( applet, mysqlServer, mysqlDatabase, mysqlUser, mysqlPwd );      
    }
    catch (Exception e){
      
        System.err.println ("Error:DBHelper.getConnection() - " + e.toString());           
    }
  } 
  
  public void closeConnection(){
    
    try{
        conn.close();    
    }
    catch (Exception e){
      
        System.err.println ("Error:DBHelper.getConnection() - " + e.toString());           
    }
  } 
  
  public ArrayList<Glyph> getFormatData(){
    
    ArrayList<Glyph> data = new ArrayList<Glyph>();
    Glyph tempData;
    return data;
    //int i = 0;
    //select iaccday, iaccmon, iacchr, dayofweek from year_2001 ();
    /*try{
                
      if ( conn.connect() )
      {
         // conn.query( "select Movie,TVMovie,Video,year from pd_SinglePlotData_Format where year between " + minYearValue + " and " + maxYearValue + " order by year " );
         conn.query( "select distinct(svin) year_2001 from where icasenum in (select distinct(icasenum) from year_2001 where latitude = 42.06862778 and longitude = -88.22028056) )");
          while (conn.next()) {
            tempData = String.parseStri(conn.getString(1)); 
            data.add(dataInt);
                 
        }
      }
      
    return data;
      
    }
    catch (Exception e){      
        System.err.println ("Error:DBHelper.getData() - " + e.toString());
        return null;        
    }*/
  }

} 




