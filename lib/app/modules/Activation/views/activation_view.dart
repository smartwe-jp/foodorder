import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/activation_controller.dart';

class ActivationView extends GetView<ActivationController> {
  const ActivationView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        child: Container(
          width: ScreenAdapter.width(550),
          padding: EdgeInsets.only(top: ScreenAdapter.height(100)),
          child: ListView(
            physics: new NeverScrollableScrollPhysics(),
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: ScreenAdapter.height(30),bottom: ScreenAdapter.height(40)),
                child: Text("コードを入力してください",
                    style: TextStyle(
                      fontSize: 28,
                      color: ColorsUtil.hexToColor("#7b7b7b"),
                    )),
              ),
              //输入机器号
            Container(
              width: ScreenAdapter.width(450.0),
              padding:
              EdgeInsets.only(left: 10.0, right: 10, top: 0, bottom: 10),
              child: TextField(
                //keyboardType: TextInputType.number,
                autofocus: true,
                showCursor: true,
                // 显示光标
                //readOnly: true,
                controller: controller.machineCodeController,
                focusNode: controller.focusNode,
                decoration: InputDecoration(
                  hintText: "コードを入力してください",
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                obscureText: false,
                onChanged: (value) {
                  //print(value);
                },
                /*onSubmitted: (value) {
                  setState(() {
                    this._activation_code = value;
                  });

                  //sendActivationCode();
                  //print("onSubmitted 点击了键盘的确定按钮，输出的信息是：${value}");
                },*/

                /// 扫码密码
              ),
            ),

              //确认按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: ScreenAdapter.width(200),
                    margin: EdgeInsets.only(top: ScreenAdapter.height(20)),
                    child: TextButton(
                      child: Text(
                        "確 認",
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: ScreenAdapter.fontSize(32.0)),
                      ),
                      onPressed: () async {
                        controller.sendActivationCode();
                      },
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
