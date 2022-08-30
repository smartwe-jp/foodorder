import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:foodorder/services/HomeServices.dart';

import '../../services/HttpService.dart';

class TransitPage extends StatefulWidget {
  TransitPage({Key key}) : super(key: key);

  _TransitPageState createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  String _machineCode = "";
  var _machineMode = "1";//1 券卖机  2 精算机

  @override
  void initState() {
    super.initState();
    _getMachineInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });

      //_getDiningTypeInfo();
      _getSystemSettingInfo();
    }
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();//print(systemSettingInfo);
    if (systemSettingInfo.isEmpty) {
      var DiningTypeInfo = await HomeServices.getDiningTypeInfo();
      var systemSettingData = {
        "diningType":(DiningTypeInfo !="" && DiningTypeInfo!=null) ? DiningTypeInfo : "1", //1堂食 2外带
        "menuDirection":"1",//1顶部横向 2左侧竖
        "printPaperSize":"1",//1 58mm 2 80mm
        "isAllowReceipt":"1",//1必须打印小票 2不必须
        "machineMode":"1",//1券卖机 2精算机
        "isReservation":"0",//0关闭 1开启
      };
      Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm
      systemSettingInfo = systemSettingData;
    }
    if(null == systemSettingInfo["machineMode"]){
      var systemSettingData = {
        "diningType": systemSettingInfo["diningType"], //1堂食 2外带
        "menuDirection": systemSettingInfo["menuDirection"],//1顶部横向 2左侧竖
        "printPaperSize": systemSettingInfo["printPaperSize"],//1 58mm 2 80mm
        "isAllowReceipt": systemSettingInfo["isAllowReceipt"],//1必须打印小票 2不必须
        "machineMode":"1",//1券卖机 2精算机
        "isReservation":"0",//0关闭 1开启
      };
      Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm

      setState(() {
        _machineMode = "1";
      });

    }else{
      setState(() {
        _machineMode = systemSettingInfo['machineMode'];
      });
    }

    _getMachineActivate();


  }

  _getMachineActivate(){
    var formData = {
      "machineCode": _machineCode,
    };
    request('webBootActivate', method: 'GET', parameters: formData).then((val) {
      var response = json.decode(val.toString());//print(response);
      if (response['code'] == 200) {
        var shopData = response['data'];
          //_shopCode = shopData["shopCode"];
        var _showWechat = shopData["linePayChannelMap"]["Wechat"] != null ? shopData["linePayChannelMap"]["Wechat"] :false;
        var _showAlipay = shopData["linePayChannelMap"]["Alipay"] != null ? shopData["linePayChannelMap"]["Alipay"] :false;
        var _showPayPay = shopData["linePayChannelMap"]["PayPay"] != null ? shopData["linePayChannelMap"]["PayPay"] :false;
        var machineActivateData = {
          "showWechat":_showWechat,
          "showAlipay":_showAlipay,
          "showPayPay":_showPayPay,
        };
        Storage.setString('smartwe_machineActivateData', json.encode(machineActivateData));

      }
      if(_machineMode == "2"){
        _goCheckOut();
      }else{
        _goMain();
      }
    });
  }

  void _goMain() async {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  void _goCheckOut() async {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/checkOutPage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: Colors.white,
        child: Container(
          //height: ScreenUtil().setHeight(400),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenAdapter.width(405),
                //height: ScreenUtil().setHeight(320),
                child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitWidth,),
              ),
              //Text('拼命加载中...',style: TextStyle(color: Colors.black),)
            ],
          ),
        ),
      ),
    );
  }
}
