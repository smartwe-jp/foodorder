import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/config/font.dart';


import '../../../config/colorsUtil.dart';
import '../../../services/HomeServices.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';

class SetPasswordPage extends StatefulWidget {
  SetPasswordPage({Key? key}) : super(key: key);

  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {

  final TextEditingController _myPassWordController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
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
                        Text("管理パスワードの設定",style:
                        TextStyle(fontSize:
                            ScreenAdapter.fontSize(28),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w600)),
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
                                  style:  TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: 40,
                                      //fontFamily: GFont.getFontFamily(),
                                  ),
                                  // Disable the default soft keybaord
                                  keyboardType: TextInputType.none,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontSize: ScreenAdapter.fontSize(24),fontFamily: GFont.getFontFamily(),),
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
                          onSubmit: () async {
                            if(_myPassWordController.text.length <4){
                              showToast("正しいパスワードを入力してください");
                              return;
                            }
                            if(_myPassWordController.text.length >4){
                              showToast("パスワード最大4ビット");
                              _myPassWordController.text = _myPassWordController.text.substring(0, 3);
                              return;
                            }

                            await HomeServices.updateMachineSettingPassword(
                                _myPassWordController.text);
                            showToast("設定に成功しました");

                            Future.delayed(Duration(milliseconds: 300),() async {
                              Navigator.pop(context);
                            });

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
