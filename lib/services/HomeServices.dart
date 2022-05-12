
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

  static getMachineInfo() async{
    String machineinfo;
    try {
      String machineInfoData = await Storage.getString('machineInfo');
      machineinfo = machineInfoData;
    } catch (e) {
      machineinfo = "";
    }
    return machineinfo;
  }
  static getShopInfo() async{
    String shopinfo;
    try {
      String shopInfoData = await Storage.getString('shopInfo');
      shopinfo = shopInfoData;
    } catch (e) {
      shopinfo = "";
    }
    return shopinfo;
  }
}