
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';
import '../../settlement/views/receipt_constrained_box.dart';


class RejishiMeRequestView extends StatefulWidget {

  @override
  RejishiMeRequestState createState() => RejishiMeRequestState();

}

class RejishiMeRequestState extends State<RejishiMeRequestView> {

  List mailList = [];
  bool isRequesting = true;
  bool isSelected = false;
  String selectMail = "";
  GlobalKey _containerKey = GlobalKey();



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

    //Navigator.pop(context);
    Get.back();

    printView();
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
                alignment: Alignment.topCenter,
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

  _printRejishime(Size size) async {
    ByteData byteData = await WidgetToImage.widgetToImage(
      RejishimePrintView(isPrint: true),
      size: Size(383, 2880),
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    String base64Image = base64Encode(imageBytes);
    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0", " ");//printLogoImage.value
    Future.delayed(Duration(milliseconds: 300), () async {
      await FlutterPluginMsprinter.sendPrintCut("0");
    });
  }


  printView() {

    Get.dialog(
       SimpleDialog(
          contentPadding: EdgeInsets.all(0),
        children:[
          Column(

            children: [
              Container(//退款小票信息，计算大小用，不显示。
                child: Offstage(
                  offstage: true,//不显示
                  key: _containerKey,
                  child: RejishimePrintView(isPrint: true),
                ),
              ),

              Container(
                padding:EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                child: Row(
                   //title
                  children: [
                    Expanded(
                      child: Text("レジ締め情報",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(36),
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor("#000000"),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    InkWell(
                      highlightColor: Colors.transparent, // 透明色
                      splashColor: Colors.transparent, // 透明色
                      onTap: (){
                        Get.back();
                      },
                      child: Icon(
                        Icons.close_outlined,
                        color: ColorsUtil.hexToColor("#000000"),
                        size: 40.0,
                      ),
                    ),
                  ]

                )


              ),

              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
                width: ScreenAdapter.width(770),
                height: ScreenAdapter.height(1080),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorsUtil.hexToColor("#000000"), width: 1),
                ),

                child: RejishimePrintView(),

              ),


            ],
          ),

          Container(
              height: ScreenAdapter.height(100),
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#f1f3f4"),
              ),
              child:
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text("キャンセル",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ScreenAdapter.width(0.5),
                    height: ScreenAdapter.height(100),
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        final RenderBox box = _containerKey.currentContext?.findRenderObject() as RenderBox;
                        final size = box.size;
                        Widget? container = _containerKey.currentWidget;
                        if (container == null) {
                          return;
                        }
                        _printRejishime(size);
                        //Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text("印刷",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),

        ]
      )
    );
  }







}


