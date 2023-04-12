import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/colorsUtil.dart';

import 'package:foodorder/plugins/appset/lib/appset.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:get/get.dart' hide Response,FormData,MultipartFile;


import 'package:foodorder/controller/homePageController.dart';

import 'package:package_info/package_info.dart';

import 'package:foodorder/config/color.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/services/showToast.dart';

import 'VerifyPassword.dart';

class MiddlewareSettingPage extends StatefulWidget {
  Map arguments;

  MiddlewareSettingPage({Key key, this.arguments}) : super(key: key);

  _MiddlewareSettingPageState createState() => _MiddlewareSettingPageState();
}

class _MiddlewareSettingPageState extends State<MiddlewareSettingPage> {

  String _machineCode = "";


  //监听页面销毁的事件
  dispose() {
    //eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this._machineCode = widget.arguments['machineCode'];

    jumpSetting();

  }

  jumpSetting() async {
    var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      showSettingPassword();
    }else{
      Navigator.pushNamed(context, '/settingPage', arguments: {"machineCode": this._machineCode});
    }
  }

  showSettingPassword() async {
    await showDialog(
        context: context,
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        builder: (BuildContext context) {
          return VerifyPasswordPage(machineCode: _machineCode,);
        });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: Text("设置")),
        body: Container());
  }
}
