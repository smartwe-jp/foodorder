import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';

Future showToast(String msg) async {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 5,
    fontSize: 28
  );
}
