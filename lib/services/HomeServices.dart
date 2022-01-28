
import 'package:foodorder/services/Storage.dart';
import 'dart:convert';

class HomeServices{

  static getOpenFirstState() async{
      var homeOpen = await Storage.getBool('homeOpen');
      if(homeOpen == true){
        return true;
      }
      return false;
  }
}