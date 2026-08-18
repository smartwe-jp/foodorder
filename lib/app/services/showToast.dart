import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';
//import 'package:win_toast/win_toast.dart';


Future showToast(String msg, {context, int duration = 2}) async {
  //const winMsg = const String.fromEnvironment('msg');
  if (Platform.isWindows) {
      if (Get.context != null) {
        FToast fToast = FToast();
        fToast.init(Get.context!);
        fToast.showToast(
          toastDuration: Duration(seconds: duration),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: const Color.fromARGB(255, 95, 98, 96),
            ),
            child: Text(
              msg,
            style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(18),
                    fontWeight: FontWeight.w400,
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                  ),
            ),
          ),
          gravity: ToastGravity.CENTER,
        );
      }
  
      // showOkAlertDialog(
      //   context: context,
      //   title: 'ご注意',
      //   message: '$msg',
      //   okLabel: 'はい',
        
      // );
    // showDialog<String>(
    //     context: context,
    //     builder: (BuildContext context) => Dialog(
    //             child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               Text(msg),
    //               const SizedBox(height: 15),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                 },
    //                 child: const Text('Close'),
    //               ),
    //             ],
    //           ),
    //         )));
  } else if (Platform.isAndroid) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        fontSize: 28);
  }
  // Add conditions for other platforms if needed
}
