
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                //跳转页面
                Navigator.pushNamed(context, '/TestingPage');
              },
              textColor: Colors.white,
              color: Colors.blue,
              child: Text("Testing Web feature"),
            ),
            MaterialButton(
              onPressed: () {
                //跳转页面=扫描二维码
                Navigator.pushNamed(context, '/SelectScannerStylePage');

              },
              textColor: Colors.white,
              color: Colors.blue,
              child: Text("Scan 1D barcode/QR code"),
            ),
            MaterialButton(
              onPressed: () {
                //跳转页面=生成二维码
                Navigator.pushNamed(context, '/CreatorPage');

              },
              textColor: Colors.white,
              color: Colors.blue,
              child: Text("Create QR code"),
            ),
          ],
        ),
      ),
    );
  }
}
