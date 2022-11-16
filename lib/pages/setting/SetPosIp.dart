import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foodorder/services/ScreenAdapter.dart';

import '../../config/colorsUtil.dart';

class SetPosIpPage extends StatefulWidget {
  Map arguments;
  SetPosIpPage(
      {Key key,
      this.posIp,
      this.posPort,
        this.onConfrimClick
      }) : super(key: key);
  final String posIp;
  final String posPort;
  final Function(String, String) onConfrimClick;

  @override
  _SetPosIpPageState createState() => _SetPosIpPageState();
}

class _SetPosIpPageState extends State<SetPosIpPage> {
  TextEditingController _tcpposIpController;
  TextEditingController _tcpposPortController;

  String _posIp = "192.168.11.188";
  String _posPort = "9999";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _posIp = widget.posIp;
    _posPort = widget.posPort;

    _tcpposIpController = TextEditingController.fromValue(TextEditingValue(
        text: _posIp,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _posIp.length))));

    _tcpposPortController = TextEditingController.fromValue(TextEditingValue(
        text: _posPort,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _posPort.length))));


  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      children: [
        Container(
          alignment: Alignment.center,
          color: Colors.white,
          width: ScreenAdapter.width(550),
          height: ScreenAdapter.height(450),
          padding: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  //height: ScreenAdapter.height(90),
                  child: Text("IPアドレスとポートの設定",style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(30),
                    fontWeight: FontWeight.w600,
                  )),
                ),
                SizedBox(height: ScreenAdapter.height(40),),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _tcpposIpController,
                            onChanged: (value) {
                              setState(() {
                                _posIp = value;
                              });
                            },
                            decoration: InputDecoration(hintText: "IPアドレス"),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                          ),
                        ),
                        flex: 3),
                    Expanded(
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _tcpposPortController,
                            onChanged: (value) {
                              setState(() {
                                _posPort = value;
                              });
                            },
                            decoration: InputDecoration(hintText: "ポート"),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                          ),
                        ),
                        flex:2),

                  ],
                ),
                SizedBox(height: ScreenAdapter.height(40),),
                Container(
                  alignment: Alignment.center,
                  width: ScreenAdapter.width(180),
                  height: ScreenAdapter.height(85),
                  margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                  decoration: BoxDecoration(

                    color: ColorsUtil.hexToColor("#409eff"),
                    //设置圆角
                    borderRadius: new BorderRadius.circular((16.0)),
                  ),
                  child: TextButton(
                    child: Text(
                      "はい",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenAdapter.fontSize(32.0)),
                    ),
                    onPressed: () async {
                      try {
                        print(_posIp);
                        print(_posPort);
                        if(_posIp != "" && _posPort != ""){
                          widget.onConfrimClick(_posIp, _posPort);
                          Navigator.pop(context);
                        }

                      } catch (_) {}

                    },
                  ),
                ),

              ],
            ),
          ),
        )
      ],
    );
  }
}
