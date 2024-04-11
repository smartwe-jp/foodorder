import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_plugin_msprinter/flutter_plugin_msprinter.dart';
import 'package:foodorder/app/config/font.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/HomeServices.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';


class VerifyPasswordPage extends StatefulWidget {
   Map? arguments;
  VerifyPasswordPage({Key? key,required this.machineCode,}) : super(key: key);
  final String machineCode;
  _VerifyPasswordPageState createState() => _VerifyPasswordPageState();
}

class _VerifyPasswordPageState extends State<VerifyPasswordPage> {

  final TextEditingController _myPassWordController = TextEditingController();

  String _machineCode = "";

  @override
  void initState() {
    super.initState();
    _machineCode = widget.machineCode;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  checkPassword(myPassWord) async {
    var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      if(smartweMachineSettingPassword == myPassWord){
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(context, '/setting', arguments: {"machineCode": this._machineCode});

      }else{
        showToast("パスワードが違います。");
      }
    }else{
      showToast("パスワードが違います。");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
        child: SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            /*title: Align(
                    alignment: Alignment.center,
                    child:  Text("管理パスワードの設定",style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),*/
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    width: ScreenAdapter.width(680),
                    padding: EdgeInsets.only(left: ScreenAdapter.width(30),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("管理パスワードを入力",style: TextStyle(fontFamily: GFont.getFontFamily(),fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600)),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            height: 70,
                            child: Center(
                                child: TextField(
                                  controller: _myPassWordController,
                                  textAlign: TextAlign.center,
                                  showCursor: false,
                                  style:  TextStyle(fontFamily: GFont.getFontFamily(),fontSize: 40),
                                  // Disable the default soft keybaord
                                  keyboardType: TextInputType.none,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontFamily: GFont.getFontFamily(),fontSize: ScreenAdapter.fontSize(24)),
                                    hintText: "4桁のパスワードを入力してください",
                                    //border: InputBorder.none
                                  ),
                                )),
                          ),
                        ),
                        NumPad(
                          buttonSize: 70,
                          buttonColor: ColorsUtil.hexToColor("#f1f3f4"),
                          iconColor: ColorsUtil.hexToColor("#9C9C9C"),
                          controller: _myPassWordController,
                          textLength: 4,
                          delete: () {
                            _myPassWordController.text = _myPassWordController.text.substring(0, _myPassWordController.text.length - 1);
                          },
                          // do something with the input numbers
                          onSubmit: () {
                            if(_myPassWordController.text.length >4){
                              showToast("パスワード最大4ビット");
                              _myPassWordController.text = _myPassWordController.text.substring(0, 3);
                              return;
                            }

                            checkPassword(_myPassWordController.text);

                            /*GetxStorage.setData('machineSettingManagePassword', _myPassWordController.text);
                            showToast("設定に成功しました");

                            Future.delayed(Duration(milliseconds: 300),() async {
                              Navigator.pop(context);
                            });*/

                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: ScreenAdapter.width(5),
                    child: InkWell(
                      highlightColor: Colors.transparent, // 透明色
                      splashColor: Colors.transparent, // 透明色
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close_outlined,
                        color: ColorsUtil.hexToColor("#000000"),
                        size: 40.0,
                      ),
                    ),
                  )
                ],
              )
            ]
        ),
          ),
    );
  }
}
