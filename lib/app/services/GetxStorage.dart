import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class GetxStorage {
  static GetStorage getStorage = GetStorage();

  static setData(String key, dynamic value) async {
    await getStorage.write(key, value);
  }

  static setBool(String key, bool value) async {
    await getStorage.write(key, value);
  }

  static getData(String key) async {
    try {
      String tempData =getStorage.read(key);
      if (tempData != null) {
        return json.decode(tempData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static getBool(String key) async {
    try {
      bool tempData =getStorage.read(key);
      return tempData;
    } catch (e) {
      return false;
    }
  }


  static Future<String> getString(key) async{
    try {
      String tempData =getStorage.read(key);
      if (tempData != null) {
        return tempData;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  static removeData(String key) async {
    getStorage.remove(key);
  }

  static clear(String key) async {
    getStorage.erase();
  }
}
