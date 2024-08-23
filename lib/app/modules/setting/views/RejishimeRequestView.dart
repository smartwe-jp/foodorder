
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../plugins/flutter_plugin_msprinter/lib/flutter_plugin_msprinter.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';
import '../../settlement/views/receipt_constrained_box.dart';
import 'package:android_usb_printer/android_usb_printer.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';


class RejishiMeRequestView extends StatefulWidget {

  final String machineCode;

  final Function resetCash;
  final Map? usbDevice;


  const RejishiMeRequestView({super.key, required this.machineCode, required this.resetCash, this.usbDevice});


  @override
  RejishiMeRequestState createState() => RejishiMeRequestState();

}

class RejishiMeRequestState extends State<RejishiMeRequestView> {

  List mailInfo = [];
  bool isRequesting = true;
  bool isSelected = false;
  String selectMail = "";
  String selectUser = "";
  double printLength = 2352;
  Function _resetCash = () {};
  Map _usbDevice = {}.obs;




  final TextEditingController _verifyCodeController = TextEditingController();

  @override
  void initState() {
    _resetCash = widget.resetCash;
    _usbDevice = widget.usbDevice ?? {};
    debugPrint("RejishiMeRequestState usbDevice: $_usbDevice");
    //usbDevice.value = HomeServices.getUsbPrintSettingInfo();
    super.initState();
    _loadMailAddress();
  }

  UsbDeviceInfo? get curUsbPrinter {
    if (_usbDevice.isEmpty) {
      print("usbDevice is empty");
      //弹出提示框，打印机未设置，请设置打印机或者联系管理员
      Get.dialog(
        AlertDialog(
          title: Text("プリンター未設定"),
          content: Text("プリンターを設定してください。"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      
      return null;
    }
    print("usbDevice.value:${_usbDevice}");
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(_usbDevice));
  }

  _loadMailAddress() async {

      final param = {
        "machineCode": widget.machineCode,
      };
      request('webBootEmailList', method: 'POST', parameters: param)
          .then((val) {
        var response = json.decode(val.toString());

        if (response != null &&
            response['code'] == 200 &&
            null != response['data']) {
          mailInfo = response['data'];
          setState(() {
            isRequesting = false;
          });
        } else {
          showToast('取得に失敗しました');
        }
      })
      .catchError((e){
        setState(() {
          isRequesting = false;
        });
        showToast('取得に失敗しました');
      });


  }

  _sendVerifyCode() async {
    setState(() {
      isRequesting = true;
    });
    final param = {
      "machineCode": widget.machineCode,
      "verifyEmail": selectMail,
      "verifyUserName": selectUser,
    };
    request('webBootAdminVerify', method: 'POST', parameters: param)
        .then((val) {
      var response = json.decode(val.toString());
      setState(() {
        isRequesting = false;
      });
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        setState(() {
          isSelected = true;
        });
      } else {
        showToast('確認コードの送信に失敗しました');
      }
    }).catchError((e){
      setState(() {
        isRequesting = false;
      });
      showToast('確認コードの送信に失敗しました');
    });
  }

  _requestShimeInfo(code) async {
    _showEasyLoading();

    final param = {
      "machineCode": widget.machineCode,
      "verifyCode": code,
      "verifyEmail": selectMail,
      "verifyUserName": selectUser,
    };

    request('webBootRejishimeiPrintInfo', method: 'POST', parameters: param)
        .then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {

        Get.back();
        printView(response['data']);
      } else {
        //当前没有レジ情報
        showToast('レジ情報がありません');
      }
    })
    .catchError((e){
      EasyLoading.dismiss();
      showToast('レジ情報の取得に失敗しました');
    });
  }

  _comfirmShimeInfo(code, printData) async {
    _showEasyLoading();

    final param = {
      "machineCode": widget.machineCode,
      "verifyCode": code,
      "verifyEmail": selectMail,
      "verifyUserName": selectUser,
    };

    request('webBootRejishimeiConfirm', method: 'POST', parameters: param)
        .then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        //printView(response['data']);
        _printRejishime(printData,printLength);
      } else {
        //当前没有レジ情報
        showToast('印刷に失敗しました');
      }
    }).catchError((e){
      EasyLoading.dismiss();
      showToast('印刷に失敗しました');
    });
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
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
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
                        Text("確認コードはメール アドレス $selectMail に送信されました。",
                            style:
                        TextStyle(fontSize:
                            ScreenAdapter.fontSize(26),
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

                            _requestShimeInfo(_verifyCodeController.text);


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
          // Expanded(
          //   child:
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
            child: CircularProgressIndicator()),
         // )
        ],
      ),
    );
  }

  Widget _mailList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      child: Column(
        children: [

          Text(
            'メールアドレスを選択してください',
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(26),
                fontFamily: GFont.getFontFamily(),
                color: ColorsUtil.hexToColor("#000000"),
              ),
          ),

           SizedBox(
              height: 20.w,
            ),
          mailInfo.length == 0 && !isRequesting
              ?
          Expanded(
                  child:
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isRequesting = true;
                        });
                        _loadMailAddress();
                      },
                      child: Text('再取得',style: TextStyle(fontSize: 20, fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w400)),
                    ),
                  )
              )
              :
          ListView.separated(
            shrinkWrap: true,
            itemCount: mailInfo.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              return
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectMail = mailInfo[index]['verifyEmail'] ?? "";
                      selectUser = mailInfo[index]['verifyUserName'] ?? "";
                    });
                    _sendVerifyCode();
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text(mailInfo[index]['verifyEmail'] ?? "",style: TextStyle(fontSize: 20,
                                                                                                  fontFamily: GFont.getFontFamily(),
                                                                                                  fontWeight: FontWeight.w400))),

                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              offset: Offset(4, 3),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text('選択', style: TextStyle(fontSize: 20,
                                                          fontFamily: GFont.getFontFamily(),
                                                          fontWeight: FontWeight.w400)),
                      ),

                    ],
                  ),
                );
            },
          ),
        ],
      ),


    );
  }

  _printRejishime(data, double length) async {

    if (Platform.isAndroid) {
      ByteData byteData = await WidgetToImage.widgetToImage(
        RejishimePrintView(isPrint: true, printInfo: data),
        size: Size(383, length + 150),
      );

      List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      String base64Image = base64Encode(imageBytes);
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0", " ");//printLogoImage.value
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("0");
      });
    } else {
      final printWidget = Container(
        width: 385,
        height: length + 150,
        child: RejishimePrintView(isPrint: true, printInfo: data),
        
      );
      _sendToUsePrinter(printWidget);
    }

    //_resetCash();
    Get.back();

  }

  _sendToUsePrinter(widget) {

    final printWidget = ReceiptConstrainedBox(widget);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: printWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(usbDevice: curUsbPrinter),
      ),
    );
  }


  printView(printData) {

    Get.dialog(
        barrierDismissible: false,
       SimpleDialog(
          contentPadding: EdgeInsets.all(0),
        children:[
          Column(

            children: [

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

                child: RejishimePrintView(printInfo: printData, lengthUpdate: (double length){
                  print("printLength: $length");
                  printLength = length;
                },),

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
                        _comfirmShimeInfo(_verifyCodeController.text, printData);
                        //_printRejishime(printData,printLength);
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


