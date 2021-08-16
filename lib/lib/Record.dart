import 'package:shared_preferences/shared_preferences.dart';
//使用  shared_preferences

class Record
{
  static Future <void> init() async
  {
    if( _prefs != null ) return ;
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences _prefs;

  static void writeStringByKey(String key ,String value)
  {
    if( _prefs == null ) return ;
    _prefs.setString(key, value) ;
  }

  static String readStringByKey(String key)
  {
    if( _prefs == null ) return "" ;
    return _prefs.getString(key);
  }

  static void writeIntByKey(String key ,int value)
  {
    if( _prefs == null ) return ;
    _prefs.setInt(key, value) ;
  }

  static int readIntByKey(String key)
  {
    if( _prefs == null ) return 0 ;
    return _prefs.getInt(key)?? 0 ;
  }

}