import 'package:shared_preferences/shared_preferences.dart';

class Storage{

  static Future<void> setString(key,value) async{
       SharedPreferences sp=await SharedPreferences.getInstance();
       sp.setString(key, value);
  }
  static Future<void> setDouble(key,value) async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    sp.setDouble(key, value);
  }

  static Future<void> setInt(key,value) async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    sp.setInt(key, value);
  }

  static Future<String?> getString(key) async{
       SharedPreferences sp=await SharedPreferences.getInstance();
       return sp.getString(key);
  }
  static Future<double?> getDouble(key) async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    return sp.getDouble(key);
  }
  static Future<void> setBool(key,value) async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    sp.setBool(key, value);
  }
  static Future<bool?> getBool(key) async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    return sp.getBool(key);
  }
  static Future<void> remove(key) async{
       SharedPreferences sp=await SharedPreferences.getInstance();
       sp.remove(key);
  }
  static Future<void> clear() async{
       SharedPreferences sp=await SharedPreferences.getInstance();
       sp.clear();
  }


  setItem(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future getItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    return value;
  }

  deleteItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }


}