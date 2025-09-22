import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/imageData.dart';
import 'package:foodorder/app/modules/rejishimei/state.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/plugins/flutter_plugin_msprinter/lib/flutter_plugin_msprinter.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:get/get.dart';
import 'package:widget_to_image/widget_to_image.dart';

class RejishimeLogic extends GetxController {
  final RejishimeState state = RejishimeState();

  @override
  void onInit() {
    debugPrint('---RejishimeLogic onInit---');
    state.machineCode = Get.arguments['machineCode'];

    super.onInit();
    loadMailAddress();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  loadMailAddress() async {
    debugPrint('---loadMailAddress---');
    final param = {
      "machineCode": state.machineCode,
    };
    request('webBootEmailList', method: 'POST', parameters: param).then((val) {
      var response = json.decode(val.toString());

      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        state.mailInfo = response['data'];
        state.isRequesting = false;
        update();
      } else {
        showToast('取得に失敗しました');
      }
    }).catchError((e) {
      state.isRequesting = false;
      update();
      showToast('取得に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        state.isRequesting = false;
        update();
        showToast('取得に失敗しました');
      },
    );
  }

  requestVerifyCode() async {
    debugPrint('requestVerifyCode');
    state.isRequesting = true;
    update();

    final param = {
      "machineCode": state.machineCode,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };
    request('webBootAdminVerify', method: 'POST', parameters: param)
        .then((val) {
      state.isRequesting = false;
      update();
      var response = json.decode(val.toString());

      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        state.isSelected = true;
        update();
      } else {
        showToast('確認コードの送信に失敗しました');
      }
    }).catchError((e) {
      state.isRequesting = false;
      update();
      showToast('確認コードの送信に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        state.isRequesting = false;
        update();
        showToast('確認コードの送信に失敗しました');
      },
    );
  }

  requestShimeInfo(
      code, machineCode, SettingController settingController) async {
    _showEasyLoading();

    final param = {
      "machineCode": machineCode,
      "verifyCode": code,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };
    debugPrint("Rejishimei request: $param");

    final domain = 'webBootRejishimeiPrintInfo';
    // Platform.isAndroid
    //     ? 'webBootRejishimeiPrintInfo'
    //     : 'webGloryRejishimeiPrintInfo';

    request(domain, method: 'POST', parameters: param).then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        debugPrint("Rejishimei response: $response");
        int total = response['data']['cashTotal'] ?? 0;
        debugPrint("Rejishimei total: $total");
        state.recycleCash = total;
        Get.back();
        showPrintView(response['data'], settingController);
      } else {
        //当前没有レジ情報
        showToast('レジ情報がありません');
      }
    }).catchError((e) {
      EasyLoading.dismiss();
      showToast('レジ情報の取得に失敗しました');
    }).timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        EasyLoading.dismiss();
        showToast('レジ情報の取得に失敗しました');
      },
    );
  }

  _comfirmShimeInfo(
      code, printData, SettingController settingController) async {
    _showEasyLoading();

    final param = {
      "machineCode": state.machineCode,
      "verifyCode": code,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };

    request('webBootRejishimeiConfirm', method: 'POST', parameters: param)
        .then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        //printView(response['data']);
        _printRejishime(printData, state.printLength, settingController);
      } else {
        //当前没有レジ情報
        showToast('印刷に失敗しました');
      }
    }).catchError((e) {
      debugPrint("Rejishimei confirm error: $e");
      EasyLoading.dismiss();
      showToast('印刷に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        EasyLoading.dismiss();
        showToast('印刷に失敗しました');
      },
    );
  }

  _comfirmGloryShimeInfo(code, printData, SettingController settingController,
      {skip = false}) async {
    final outResult = await _outCash(settingController, () {
      //_comfirmGloryShimeInfo(code, printData, settingController, skip: true);
      _directRejishime(code, printData, settingController, null);//
      return;
    });

    if (outResult == null && skip == false) return;

    _directRejishime(code, printData, settingController, outResult);
  }

  _directRejishime(code, printData, SettingController settingController,
      Map? outResult) async {
    final result =
        await _comfirmGloryShimeInfos(code, printData, outResult ?? {});
    if (!result) return;
    await _printRejishime(printData, state.printLength, settingController);
  }

  _printRejishime(
      data, double length, SettingController settingController) async {
    //_showEasyLoading();
    if (Platform.isAndroid) {
      ByteData byteData = await WidgetToImage.widgetToImage(
        PrintView(isPrint: true, printInfo: data),
        size: Size(383, length + 150),
      );

      List<int> imageBytes = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      String base64Image = base64Encode(imageBytes);
      await FlutterPluginMsprinter.sendPrintImgNew(
          base64Image, "0", "0", " "); //printLogoImage.value
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("0");
      });
      EasyLoading.dismiss();
      Get.back();
    } else {
      await settingController.printRejishimei(state.printLength, data);
    }
  }

  recycleCash(SettingController settingController) {
    settingController.recycleCash(state.verifyCode, state.selectMail);
  }

  _outCash(SettingController settingController, Function skipAction) async {
    Map? result =
        await settingController.recycleCashOut(state.recycleCash, skipAction);

    debugPrint("recycleCash result: $result");

    return result;
  }

  _comfirmGloryShimeInfos(code, printData, result) async {
    debugPrint("_comfirmGloryShimeInfo");
    var success = false;

    _showEasyLoading();

    // if (widget.recycleCash == null) {
    //   EasyLoading.dismiss();
    //   showToast('印刷に失敗しました');
    //   return success;
    // }

    final param = {
      "changeInfoMap": result,
      "machineCode": state.machineCode,
      "verifyCode": code,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };
    debugPrint("webBootGloryConfirmClose param: $param");

    await request('webBootGloryConfirmClose', method: 'POST', parameters: param)
        .then((val) {
      //EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        //printView(response['data']);
        success = true;
      } else {
        //当前没有レジ情報
        EasyLoading.dismiss();
        success = false;
        showToast('印刷に失敗しました');
      }
    }).catchError((e) {
      EasyLoading.dismiss();
      success = false;
      showToast('印刷に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        EasyLoading.dismiss();
        success = false;
        showToast('印刷に失敗しました');
      },
    );
    return success;
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

  showPrintView(printData, SettingController settingController) {
    Get.dialog(
        barrierDismissible: false,
        SimpleDialog(contentPadding: EdgeInsets.all(0), children: [
          Column(
            children: [
              Container(
                  padding:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                  child: Row(
                      //title
                      children: [
                        Expanded(
                          child: Text(
                            "レジ締め情報",
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
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.close_outlined,
                            color: ColorsUtil.hexToColor("#000000"),
                            size: 40.0,
                          ),
                        ),
                      ])),
              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
                width: ScreenAdapter.width(770),
                height: ScreenAdapter.height(1080),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: ColorsUtil.hexToColor("#000000"), width: 1),
                ),
                child: PrintView(
                  printInfo: printData,
                  lengthUpdate: (double length) {
                    print("printLength: $length");
                    state.printLength = length;
                    //_updatePrintInfo(length, printData);
                  },
                ),
              ),
            ],
          ),
          Container(
              height: ScreenAdapter.height(100),
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#f1f3f4"),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text(
                            "キャンセル",
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
                      onTap: () async {
                        if (Platform.isWindows) {
                          debugPrint("comfirmGloryShimeInfo");
                          await _comfirmGloryShimeInfo(
                              state.verifyCode, printData, settingController);
                        } else {
                          _comfirmShimeInfo(
                              state.verifyCode, printData, settingController);
                        }
                        //_printRejishime(printData,printLength);
                        //Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text(
                            "印刷",
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
              )),
        ]));
  }
}
