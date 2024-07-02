
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';


class RejishiMeRequestView extends StatefulWidget {

  @override
  RejishiMeRequestState createState() => RejishiMeRequestState();

}

class RejishiMeRequestState extends State<RejishiMeRequestView> {

  List mailList = [];
  bool isRequesting = true;
  bool isSelected = false;
  String selectMail = "";

  final TextEditingController _verifyCodeController = TextEditingController();

  @override
  void initState() {

    super.initState();
    _loadMailAddress();
  }


  _loadMailAddress() async {

    await Future.delayed(Duration(seconds: 1));
    mailList = ["mail1@gmail.com","mail2@gmail.com","mail3@gmail.com"];
    setState(() {
      isRequesting = false;
    });
  }

  _requestShimeInfo() async {
    _showEasyLoading();
    await Future.delayed(Duration(seconds: 2));
    EasyLoading.dismiss();
    Navigator.pop(context);
  }

  _showEasyLoading() {

    EasyLoading.show(
      status: 'Printer is printing...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //_showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(
                  GImage.getImageString("imgpublic", "printticketloading"),
                  fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
      Center(
        child: SimpleDialog(
          children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(680),
                    padding: EdgeInsets.only(left: ScreenAdapter.width(30),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
                    child:
                    isSelected ?
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("確認コードは電子メール アドレス $selectMail に送信されました。",
                            style:
                        TextStyle(fontSize:
                            ScreenAdapter.fontSize(28),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            height: 70,
                            child: Center(
                                child: TextField(
                                  controller: _verifyCodeController,
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
                                    hintText: "4桁のコードを入力してください",
                                    //border: InputBorder.none
                                  ),
                                )),
                          ),
                        ),
                        NumPad(
                          buttonSize: 70,
                          buttonColor: ColorsUtil.hexToColor("#f1f3f4"),
                          iconColor: ColorsUtil.hexToColor("#9C9C9C"),
                          controller: _verifyCodeController,
                          textLength: 4,
                          delete: () {
                            _verifyCodeController.text = _verifyCodeController.text.substring(0, _verifyCodeController.text.length - 1);
                          },
                          // do something with the input numbers
                          onSubmit: () {
                            if(_verifyCodeController.text.length <4){
                              showToast("正しいコードを入力してください");
                              return;
                            }
                            if(_verifyCodeController.text.length >4){
                              showToast("コード最大4ビット");
                              _verifyCodeController.text = _verifyCodeController.text.substring(0, 3);
                              return;
                            }

                            _requestShimeInfo();


                          },
                        ),
                      ],
                    ):requestView(),
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
              ),


          ],
        )
      ),
    );
  }

  Widget requestView() {
    return Container(
      height: 500.w,
      child: Stack(
        children: [
          //请求的列表
          Container(
            child: _mailList(),
          ),
          if (isRequesting)
          Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  Widget _mailList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      child:

      mailList.length == 0 && !isRequesting
          ?  Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isRequesting = true;
                  });
                  _loadMailAddress();
                },
                child: Text('Retry'),
              ),)
          :
      ListView.separated(
        shrinkWrap: true,
        itemCount: mailList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: [
              const SizedBox(width: 30),
              Expanded(child: Text(mailList.elementAt(index),style: TextStyle(fontSize: 20))),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectMail = mailList.elementAt(index);
                    isSelected = true;
                  });
                },
                child: Text('選択',style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 30),
            ],
          );
        },
      ),
    );
  }


}


