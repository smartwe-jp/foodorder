import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/logUtil.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:foodorder/services/HomeServices.dart';

import 'package:foodorder/services/GetxStorage.dart';
import 'package:foodorder/services/HttpService.dart';

class TransitPage extends StatefulWidget {
  TransitPage({Key key}) : super(key: key);

  _TransitPageState createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  String _machineCode = "";
  var _machineMode = "1";//1 券卖机  2 精算机
  var _isCashState = true;
  var _machineBill = [];

  @override
  void initState() {
    super.initState();
    _getIsShowCashInfo();

  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  _getIsShowCashInfo() async {
    Map systemSettingInfo = await HomeServices.getIsShowCash();

    setState(() {
      _isCashState = systemSettingInfo['isCash'];
    });

    _getMachineInfo();
  }

  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });

      //_getSystemSettingInfo();
      _getMachineActivate();
    }
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();//print(systemSettingInfo);

    setState(() {
      _machineMode = systemSettingInfo['machineMode'];
    });

    _getMachineActivate();


  }



  _getMachineActivate(){
    var formData = {
      "machineCode": _machineCode,
    };
    request('webBootActivatev2', method: 'GET', parameters: formData).then((val) {
      var response = json.decode(val.toString());//LogUtil.d(response);
      if (response['code'] == 200) {
        var shopData = response['data'];
          //_shopCode = shopData["shopCode"];
        var _showCash = shopData["linePayChannelMap"]["Cash"] != null ? shopData["linePayChannelMap"]["Cash"] :false;
        var _showWechat = shopData["linePayChannelMap"]["Wechat"] != null ? shopData["linePayChannelMap"]["Wechat"] :false;
        var _showAlipay = shopData["linePayChannelMap"]["Alipay"] != null ? shopData["linePayChannelMap"]["Alipay"] :false;
        var _showPayPay = shopData["linePayChannelMap"]["PayPay"] != null ? shopData["linePayChannelMap"]["PayPay"] :false;
        var _showCreditCard = shopData["linePayChannelMap"]["POS"] != null ? shopData["linePayChannelMap"]["POS"] :false;
        var _auPay = shopData["linePayChannelMap"]["au_Pay"] != null ? shopData["linePayChannelMap"]["au_Pay"] :false;
        var _dPay = shopData["linePayChannelMap"]["d_Pay"] != null ? shopData["linePayChannelMap"]["d_Pay"] :false;
        var _rPay = shopData["linePayChannelMap"]["R_Pay"] != null ? shopData["linePayChannelMap"]["R_Pay"] :false;
        var _mPay = shopData["linePayChannelMap"]["m_Pay"] != null ? shopData["linePayChannelMap"]["m_Pay"] :false;
        var machineActivateData = {
          "showCash":(_isCashState == true) ? _showCash :false,
          "showWechat":_showWechat,
          "showAlipay":_showAlipay,
          "showPayPay":_showPayPay,
          "showCreditCard":_showCreditCard,
          "au_Pay":_auPay,
          "d_Pay":_dPay,
          "R_Pay":_rPay,
          "m_Pay":_mPay,
        };
        Storage.setString('smartwe_machineActivateData', json.encode(machineActivateData));
        Storage.setString('smartwe_machineLanguages', json.encode(shopData["languages"]));

        Storage.setString('smartwe_homeImages', json.encode(shopData["homeImages"]));
        Storage.setString('smartwe_checkOut_takeout', json.encode(shopData["takeout"]));
        Storage.setString('smartwe_checkOut_bill', json.encode(shopData["bill"]));
        Storage.setString('smartwe_checkOut_lineUp', json.encode(shopData["lineUp"]));

        GetxStorage.setData('smartwe_machineActivateData', json.encode(machineActivateData));
        GetxStorage.setData('smartwe_machineLanguages', json.encode(shopData["languages"]));

        setState(() {
          _machineBill = shopData["bill"];
        });
      }
      /*if(_machineMode == "2"){
        _goCheckOut();
      }else{
        _goMain();
      }*/
      _getSmartweSystemSettingInfo();
    });
  }

  _getSmartweSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    var checkmachineMode = "1";
    if(SystemSettingInfo["machineMode"] !="" && SystemSettingInfo["machineMode"]!=null &&SystemSettingInfo["machineMode"] != "1"){
      if(_machineBill.length==0){
        checkmachineMode = "1";
      }else{
        checkmachineMode = "2";
      }
    }
    var DiningTypeInfo = await HomeServices.getDiningTypeInfo();//showToast("main====:::::${DiningTypeInfo}");
    var systemSettingData = {
      "diningType": (SystemSettingInfo["diningType"] !="" && SystemSettingInfo["diningType"]!=null) ? SystemSettingInfo["diningType"] :((DiningTypeInfo !="" && DiningTypeInfo!=null) ? DiningTypeInfo : "1"), //1堂食 2外带
      "menuDirection":(SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1",//1顶部横向 2左侧竖
      "printPaperSize":(SystemSettingInfo["printPaperSize"] !="" && SystemSettingInfo["printPaperSize"]!=null) ? SystemSettingInfo["printPaperSize"] :"1",//1 58mm 2 80mm
      "isAllowReceipt":(SystemSettingInfo["isAllowReceipt"] !="" && SystemSettingInfo["isAllowReceipt"]!=null) ? SystemSettingInfo["isAllowReceipt"] :"1",//1必须打印小票 2不必须
      //"machineMode":(SystemSettingInfo["machineMode"] !="" && SystemSettingInfo["machineMode"]!=null) ? SystemSettingInfo["machineMode"] :"1",//1 普通点餐券卖机  2 精算机（结账机）
      "machineMode":checkmachineMode,
      "isReservation":(SystemSettingInfo["isReservation"] !="" && SystemSettingInfo["isReservation"]!=null) ? SystemSettingInfo["isReservation"] :"0",//是否开启预约 0不开启 1开启
      "isAllowAttendance":(SystemSettingInfo["isAllowAttendance"] !="" && SystemSettingInfo["isAllowAttendance"]!=null) ? SystemSettingInfo["isAllowAttendance"] :"0",//0 不开考勤 1开考勤
      "isAllowPos":(SystemSettingInfo["isAllowPos"] !="" && SystemSettingInfo["isAllowPos"]!=null) ? SystemSettingInfo["isAllowPos"] :"0",//0 不开pos 1开pos
      "isAllowWlanPrint":(SystemSettingInfo["isAllowWlanPrint"] !="" && SystemSettingInfo["isAllowWlanPrint"]!=null) ? SystemSettingInfo["isAllowWlanPrint"] :"0",//0 不开打印机 1开打印机

    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));
    //}

    /*setState(() {
      _machineMode = checkmachineMode;
    });*/

    //判断是否第一次打开
    sleep(Duration(milliseconds: 200));
    if(checkmachineMode == "2"){
        _goCheckOut();
      }else{
        _goMain();
      }
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
