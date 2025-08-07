import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';

class LoadingFailedWidget extends StatefulWidget {

  final Function onBack;

  LoadingFailedWidget({Key? key, required this.onBack}) : super(key: key);
  @override
  _LoadingFailedWidgetState createState() => _LoadingFailedWidgetState();
}

class _LoadingFailedWidgetState extends State<LoadingFailedWidget> {
  int _countdown = 10;
  late Timer _timer;
  String language = "JP";

  @override
  void initState() {
    super.initState();
    language = Get.locale != null ? Get.locale!.languageCode.toUpperCase() : "JP";
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_countdown == 0) {
            timer.cancel();
            widget.onBack();
        } else {
          setState(() {
            _countdown--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('load_menu_failure_title'.tr,
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(30),
                fontFamily: GFont.getFontFamily(),
                color: Colors.black,
                fontWeight: FontWeight.w600
            ),
          ),
          SizedBox(height: 20),
          Text('load_menu_failure_content'.tr.trParams({'seconds': '$_countdown'}),
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(30),
                fontFamily: GFont.getFontFamily(),
                color: Colors.black,
                fontWeight: FontWeight.w400
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            value: _countdown / 15,
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 40),
          Image.asset(
            'assets/images/public/sorry.png',
            width: 200,
            height: 200,
          ),

          SizedBox(height: 100),
          //主动返回按钮
          ElevatedButton(
            onPressed: () {
              _timer.cancel();
              widget.onBack();
            },
            child: Text('load_menu_failure_back'.tr,
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(30),
                  fontFamily: GFont.getFontFamily(),
                  color: Colors.white,
                  fontWeight: FontWeight.w600
              ),
            ),
            style: ButtonStyle(
              //backgroundColor: MaterialStateProperty.all(ColorsUtil.hexToColor("0xEE0000")),
              padding: WidgetStateProperty.all(EdgeInsets.fromLTRB(30, 10, 30, 10)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
              )),
            ),
          ),
        ],
      ),
    );
  }
}
