import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:win_toast/win_toast.dart';

Future showToast(String msg, {context}) async {
  //const winMsg = const String.fromEnvironment('msg');
  if (Platform.isWindows) {
      showOkAlertDialog(
        context: context,
        title: 'ご注意',
        message: '$msg',
        okLabel: 'はい',
        
      );
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
