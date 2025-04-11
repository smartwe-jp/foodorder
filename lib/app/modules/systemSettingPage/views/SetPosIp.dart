import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import 'CustomKeyboard.dart';



class SetPosIpPage extends StatefulWidget {
   Map? arguments;
  SetPosIpPage(
      {Key? key,
      this.posIp,
      this.posPort,
      this.showRadio,
      this.showPrintType,
      this.onConfrimClick
      }) : super(key: key);
  final String? posIp;
  final String? posPort;
  final int? showRadio;
  final int? showPrintType;
  final Function(String, String)? onConfrimClick;

  @override
  _SetPosIpPageState createState() => _SetPosIpPageState();
}

class _SetPosIpPageState extends State<SetPosIpPage> {
   TextEditingController? _tcpposIpController;
   TextEditingController? _tcpposPortController;
   final FocusNode focusNode1 = FocusNode();
   final FocusNode focusNode2 = FocusNode();
   TextEditingController? activeController;



  String _posIp = "192.168.11.188";
  String _posPort = "9100";
  int _showRadio = 0;
  int _showPrintType = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode1.addListener(() {
      if (focusNode1.hasFocus) {
        setState(() {
          activeController = _tcpposIpController;
        });
      }
    });

    focusNode2.addListener(() {
      if (focusNode2.hasFocus) {
        setState(() {
          activeController = _tcpposPortController;
        });
      }
    });
    _posIp = widget.posIp!;
    _posPort = widget.posPort!;
    _showRadio = widget.showRadio!;
    if(_showRadio == 1){
      _showPrintType = widget.showPrintType!;
    }

    _tcpposIpController = TextEditingController.fromValue(TextEditingValue(
        text: _posIp,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _posIp.length))));

    _tcpposPortController = TextEditingController.fromValue(TextEditingValue(
        text: _posPort,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _posPort.length))));


  }

   void handleKeyPress(String key) {
     if (activeController == null) return;

     if (key == '削除') {
       if (activeController!.text.isNotEmpty) {
         activeController!.text = activeController!.text.substring(
             0, activeController!.text.length - 1
         );
       }
     } else {
       activeController!.text = activeController!.text + key;
     }
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
          //height: ScreenAdapter.height(450),
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
                    fontFamily: GFont.getFontFamily(),
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
                            focusNode: focusNode1,
                            keyboardType: TextInputType.number,
                            controller: _tcpposIpController,
                            onChanged: (value) {
                              setState(() {
                                _posIp = value;
                              });
                            },
                            decoration: InputDecoration(hintText: "IPアドレス"),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0),fontFamily: GFont.getFontFamily(),),
                          ),
                        ),
                        flex: 3),
                    Expanded(
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            focusNode: focusNode2,
                            controller: _tcpposPortController,
                            onChanged: (value) {
                              setState(() {
                                _posPort = value;
                              });
                            },
                            decoration: InputDecoration(hintText: "ポート"),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0),fontFamily: GFont.getFontFamily(),),
                          ),
                        ),
                        flex:2),

                  ],
                ),
                /*SizedBox(height: ScreenAdapter.height(15),),
                if(_showRadio == 1)// 简易选择项
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      //height: ScreenAdapter.height(90),
                      child: Text("Receipt",style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    Transform.scale(
                      scale: 1.5,
                      child: Radio(
                        // 按钮的值
                        value: 0,
                        // 改变事件
                        onChanged: (value){
                          setState(() {
                            this._showPrintType = value;
                          });
                        },
                        // 按钮组的值
                        groupValue:this._showPrintType ,
                      ),
                    ),

                    SizedBox(width: 40,),
                    Container(
                      //height: ScreenAdapter.height(90),
                      child: Text("Label",style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    Transform.scale(
                      scale: 1.5,
                      child: Radio(
                        value:1,
                        onChanged: (value){
                          setState(() {
                            this._showPrintType = value;
                          });
                        },
                        groupValue: this._showPrintType,
                      ),
                    ),
                  ],
                ),*/
                SizedBox(height: ScreenAdapter.height(20),),

                CustomKeyboard(onKeyPressed: handleKeyPress),

                SizedBox(height: ScreenAdapter.height(20),),

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
                          fontFamily: GFont.getFontFamily(),
                          fontSize: ScreenAdapter.fontSize(32.0)),
                    ),
                    onPressed: () async {
                      try {
                        _posIp = _tcpposIpController?.text ?? "";
                        _posPort = _tcpposPortController?.text ?? "";
                        print(_posIp);
                        print(_posPort);
                        if(_posIp != "" && _posPort != ""){
                          widget.onConfrimClick!(_posIp, _posPort);
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
