
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

class ScanPayPage extends StatefulWidget {
  ScanPayPage({Key key}) : super(key: key);

  _ScanPayPageState createState() => _ScanPayPageState();
}

class _ScanPayPageState extends State<ScanPayPage> {
  var textStr = '';
  @override
  void initState() {
    super.initState();


  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    canCelListener();
  }

//扫描二维码
  static Future<String> getQrcodeState() async {
    try {
      const ScanOptions options = ScanOptions(
        strings: {
          'cancel': '取消',
          'flash_on': '开启闪光灯',
          'flash_off': '关闭闪光灯',
        },
      );
      final ScanResult result = await BarcodeScanner.scan(options: options);
      return result.rawContent;
    } catch (e) {

    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    //ScreenAdapter.init(context);
    //显示底部栏(隐藏顶部状态栏)
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    //显示顶部栏(隐藏底部栏)
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    //隐藏底部栏和顶部状态栏
    //SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: AppBar(
        title: Text("二维码"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,  //充满屏幕宽度,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,  //居中
          children: [
            SizedBox(height: 50,),
            RaisedButton(
              child: Text("二维码扫描"),
              onPressed: () {
                getQrcodeState().then((value) => setState(() {
                  this.textStr = value;
                }));
              },
            ),
            SizedBox(height: 20,),
            Text("扫描内容为${this.textStr}"),
          ],
        ),
      ),
    );
  }
}
