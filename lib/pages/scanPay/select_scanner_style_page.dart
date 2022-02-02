import 'package:flutter/material.dart';
import 'package:foodorder/routers/router.dart';

///
/// SelectScannerStylePage
class SelectScannerStylePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectScannerStyleState();
  }
}

///
/// _SelectScannerStyleState
class _SelectScannerStyleState extends State<SelectScannerStylePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Scanner Style"),
      ),
      body: Row(
        children: <Widget>[
          Spacer(),
          Column(
            children: <Widget>[
              Spacer(),
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/FullScreenScannerPage');
                  //Airoute.pushNamed(routeName: "/FullScreenScannerPage");
                },
                child: Text("FullScreen Style"),
                textTheme: ButtonTextTheme.accent,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/CustomSizeScannerPage');
                  //Airoute.pushNamed(routeName: "/CustomSizeScannerPage");
                },
                child: Text("CustomSize Style"),
                textTheme: ButtonTextTheme.accent,
              ),
              Spacer(),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
