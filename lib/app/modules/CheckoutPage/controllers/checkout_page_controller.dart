import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/CheckoutPage/controllers/posCheckView.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/PinterCheckService.dart';
import '../../../services/PosCheckService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';
import '../../scan_detail_page/logic.dart';
import '../../scan_detail_page/view.dart';
import 'checkStatusView.dart';

class CheckoutPageController extends GetxController with StateMixin {
  //TODO: Implement CheckoutPageController
  // TextEditingController scanQrCodeHomeController = new TextEditingController();
  // FocusNode scanQrCodeHomeFocusNode = FocusNode();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  MachineInfoController machineInfo = Get.find();

  PrinterCheckService printerCheckService = Get.find();

  RxBool allAreReady = false.obs;
  RxList checkList = [].obs;

  RxBool actuarial = false.obs;
  RxBool lineup = false.obs;
  //RxBool takeOut = false.obs; //是否允许外带

  RxString isReservation = "0".obs;
  RxBool showOpenPayment = false.obs;

  RxString orderId = "".obs;
  RxInt totalPrice = 0.obs;
  RxInt voucherAmount = 0.obs;
  RxInt payableAmount = 0.obs;
  RxString tableNum = "0".obs;
  RxString tableNumText = "0".obs;
  RxInt tax10 = 0.obs;
  RxInt tax8 = 0.obs;
  RxInt discount = 0.obs;
  RxInt itemCount = 0.obs;


  bool machineLanguages_JP = false;
  bool machineLanguages_CH = false;
  bool machineLanguages_EN = false;
  bool machineLanguages_KO = false;
  String selectLanguage = 'JP';
  bool startShake = false;
  bool isAnimating = false;


  RxMap orderInfoMap = {}.obs;
  RxList orderLines = [].obs;
  String scanTextValue = '';
  bool firstLoad = false;
  get printerList => machineInfo.printerList;
  get sseList => machineInfo.sseSettingList;

  bool get containTax => machineInfo.taxSystem;

  final RxInt posCheckStatus = 0.obs;

  String get defaultLanguage {
    final languages = machineInfo.supportLanguages;
    if (languages.length == 1) {
      return languages[0] ?? 'JP';
    }
    return 'JP';
  }

  Color get themeColor {
    return Color(machineInfo.themeColor);
  }

  Color get themeTextColor {
    return machineInfo.is_dark_theme ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  Color preThemeColor = Colors.green.shade900;

  @override
  void onInit() {
    debugPrint("CheckoutPageController init");
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    _getMachineLanguages();
    if (Get.arguments != null && Get.arguments.containsKey('initLaunch')) {
      firstLoad = Get.arguments['initLaunch'] ?? false;
    }
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("CheckoutPageController onReady");
    //startRepeatingAnimation();
    _checkToCloseLoading();
    if (firstLoad) {
      bool isSseEnabled =
          sseList.isNotEmpty && sseList.any((item) => item['isOn'] == true);
      if (isSseEnabled) {
        debugPrint('SSE is enabled, starting to check printer status');
        //Future.delayed(const Duration(milliseconds: 300), () {
        Get.dialog(
          checkStatusCopyView(onEnd: () {
            _showPosCheck();
          }),
          barrierDismissible: false,
        );
        checkPrinterStatus();
        //});
      } else {
        _showPosCheck();
      }
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      updateSettingLanguage(defaultLanguage);
    });
  }

  @override
  void onClose() {
    //stopRepeatingAnimation();
    super.onClose();
  }

  _checkToCloseLoading() async {
    if (EasyLoading.isShow) {
      logI('--Dismissing EasyLoading--');
      try {
        await EasyLoading.dismiss();
      } catch (e) {
        logger.warning('EasyLoading.dismiss error: $e');
      }
    }
  }

  _checkPosStatus() async {
    //检查POS机状态
    final posCheckService = Get.find<PosCheckService>();

    posCheckStatus.value =
    await posCheckService.checkPosConnection(machineInfo.pos_ip) ? 1 : 2;
    if (posCheckStatus.value == 1) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (Get.isDialogOpen == true) {
        Get.back(); // Close the dialog
      }
    }
    debugPrint('POS机检查结果: ${posCheckStatus.value == 1 ? "成功" : "失败"}');
  }

  _showPosCheck() async {
    //检查POS机状态
    if (machineInfo.allowPos && machineInfo.pos_ip.isNotEmpty) {
      posCheckStatus.value = 0; // 检测中
      Get.dialog(
        PosCheckView(
            posCheckStatus: posCheckStatus,
            onRetry: () {
              _checkPosStatus();
            }),
        barrierDismissible: false,
      );
      _checkPosStatus();
    }
  }

  Future<void> checkPrinterStatus() async {
    debugPrint('checkPrinterStatus');

    checkList.clear();
    checkList.value = printerList.map((item) {
      return {
        'name': item['name'],
        'isOn': !(item['isOff'] ?? true),
        'ip': item['printIp'] ?? '',
        'port': item['printPort'] ?? '',
        'isReady': false,
        'isChecking': false,
        'checked': false,
      };
    }).toList();

    allAreReady.value = false;
    await Future.delayed(const Duration(milliseconds: 3000));
    await printerCheckService.checkPrinters(checkList, (printer) {
      int index = checkList.indexWhere((item) => item['name'] == printer['name']);
      debugPrint('Checking printer back: ${printer['name']} isReady: ${printer['isReady']} isChecking: ${printer['isChecking']} checked: ${printer['checked']}');
      if (index != -1) {
        checkList[index]['isReady'] = printer['isReady'];
        checkList[index]['isChecking'] = printer['isChecking'];
        checkList[index]['checked'] = printer['checked'];
      }
      allAreReady.value = checkList.every((item) => item['checked']);
      //if (allAreReady.value) {
        //EasyLoading.showToast('All printers are ready');
        //Get.back(); // Close the dialog
      //}
      update();
    });
  }

  _getMachineLanguages() async {
    debugPrint("获取机器语言");
    //takeOut.value = (machineInfo.diningType == "2" || machineInfo.diningType == "3") ? true : false;
    machineLanguages_JP = machineInfo.supportLanguages.contains('JP');
    machineLanguages_CH = machineInfo.supportLanguages.contains('CH');
    machineLanguages_EN = machineInfo.supportLanguages.contains('EN');
    machineLanguages_KO = machineInfo.supportLanguages.contains('KO');
    debugPrint("获取机器语言结束");
    update();
    change(null, status: RxStatus.success());
  }

  void startRepeatingAnimation() {
    debugPrint('startRepeatingAnimation');
    isAnimating = true;
    Timer.periodic(Duration(milliseconds: 1200), (timer) {
      if (!isAnimating) {
        timer.cancel();
        return;
      }
      startShake = !startShake;
      update();
    });
  }

  void stopRepeatingAnimation() {
    debugPrint('stopRepeatingAnimation');
    isAnimating = false;
    startShake = false;
    update();
  }

  void updateThemeColor(Color color) async {
    //translate color to int
    machineInfo.themeColor = color.toARGB32();
    machineInfo.is_dark_theme = useWhiteForeground(color);
    // final systemSetting = await HomeServices.getSystemSettingInfo();
    // systemSetting['themeColor'] = machineInfo.themeColor;
    // systemSetting['isDarkTheme'] = machineInfo.is_dark_theme;
    // HomeServices.updateSystemSettingInfo(systemSetting);
    update();
  }

  void confirmColorSetting(Color color) async {
    machineInfo.themeColor = color.toARGB32();
    machineInfo.is_dark_theme = useWhiteForeground(color);
    final systemSetting = await HomeServices.getSystemSettingInfo();
    systemSetting['themeColor'] = machineInfo.themeColor;
    systemSetting['isDarkTheme'] = machineInfo.is_dark_theme;
    HomeServices.updateSystemSettingInfo(systemSetting);
  }

  void cancelColorSetting() async {
    machineInfo.themeColor = preThemeColor.toARGB32();
    machineInfo.is_dark_theme = useWhiteForeground(preThemeColor);
    final systemSetting = await HomeServices.getSystemSettingInfo();
    systemSetting['themeColor'] = machineInfo.themeColor;
    systemSetting['isDarkTheme'] = machineInfo.is_dark_theme;
    HomeServices.updateSystemSettingInfo(systemSetting);
    update();
  }

  showOrderEasyLoading() {
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onLongPress: (){
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }


  //{"msg":"success","code":200,"data":{"orderId":459105413798756352,"totalPrice":2250,"discount":0,"tableNum":"Ａ０２","machineCode":null,"orderQty":15,"orderKey":null,"language":null,"orderInfoMap":{"ミルクティー":3,"枝豆":2,"生ビール":1,"牛すじドテ焼大根日":7,"甘蘭牛肉麺":1,"コーラ":1,"アイス紅茶":1}}}
  requestOrderList(String scanText, {goDetail = true}) async {
    debugPrint('qrCodeString: $scanText');
    scanTextValue = scanText;
    String orderKey = scanText;
    if (orderKey.isEmpty) {
      EasyLoading.dismiss();
      return;
    }

    if (orderKey.contains('?p=') == true) {
      //正则实现截取'?p='之后的字符串
      orderKey = _getOrderKey(scanText);
    }
    debugPrint('orderKey : $orderKey');
    var formData = {
      "orderKey": orderKey,
      "language": selectLanguage,
      "machineCode": machineInfo.machineCode
    };

    debugPrint('formData: $formData');

    request('webBootCalculateV2', method: 'POST', parameters: formData)
        .then((val) {
      print('webBootCalculateV2:$val');

      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 &&
          response["data"] != null &&
          response["data"].isNotEmpty &&
          response["data"]["orderId"] != null
      ) {
        if (response["data"]["totalPrice"] >= 0) {

          orderId.value = response["data"]["orderId"].toString();
          totalPrice.value = response["data"]["totalPrice"];
          discount.value = response["data"]["discount"];
          tableNum.value = response["data"]["tableNum"] ?? "0";
          tableNumText.value = response["data"]["tableNumText"] ?? "";
          tax10.value = response["data"]["tax1"] ?? 0;
          tax8.value = response["data"]["tax2"] ?? 0;
          voucherAmount.value = response["data"]["voucherAmount"] ?? 0;
          payableAmount.value = response["data"]["payableAmount"] ?? 0;

          orderInfoMap.value = response["data"]["orderInfoMap"] ?? {};
          orderLines.value = response["data"]["orderLines"] ?? [];
          //orderInfoMap: {牛すじドテ焼大根日8: 1}
          itemCount.value = orderInfoMap.map((key, value) => MapEntry(key, value as int)).values.fold(0, (previousValue, element) => previousValue + element);
          

          if (goDetail) {
            debugPrint('/scan-detail');
            Get.to(()=>ScanDetailPagePage());
          } else {
            if (Get.isRegistered<ScanDetailPageLogic>())
              Get.find<ScanDetailPageLogic>().update();
            update();
          }
        } else {
          _resetScanState(false);
        }
      } else {
        _resetScanState(false);
        _showDialogError(response['msg']);
      }
    }).catchError((error) {
      print('webBootCalculateV2 error:${error.toString()}');
    });
  }



  _getOrderKey(qrCodeString) {
    RegExp regExp = new RegExp(r"\?p=(.*)");
    return regExp.stringMatch(qrCodeString).toString().substring(3);
  }



  _showDialogError(msg){
      Get.dialog(DialogUtils.alertOneButton(msg,
      title: "tag_title".tr,
      confirmtitle:"tag_button_yes".tr,
      contentTagImg: "error_public", confirm: () {
        Get.back();
      }));
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog() async {
    scanQrCodeFocusNode.requestFocus();
    //scanQrCodeHomeFocusNode.requestFocus();
    machineInfo.showReceiptPage = machineInfo.isReceiptPageShow;
    Get.to(
          () =>
        SelectPaymentPage(
            checkLanguage: selectLanguage,
            menuCount: itemCount.value,
            shopCartTotalPrice:(totalPrice.value + discount.value - voucherAmount.value).toString(),
            tableNum: tableNum.value,
            tableName: tableNumText.value,
            tax10: tax10.value,
            tax8: tax8.value,
            onConfrimClick: () {
                showOpenPayment.value = true;
                //machineInfo.showReceiptPage = true;
                goToSettlement();
            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                scanQrCodeController.text = "";
                //scanQrCodeHomeController.text = "";
              }
              scanQrCodeFocusNode.requestFocus();// 获取焦点
              //scanQrCodeHomeFocusNode.requestFocus();// 获取焦点
            }
        ),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      opaque: false,
    );
  }

  postNewOrderId({orderIdIfTakeOut = ""}) {

    if (orderId.value == "") {
      orderId.value = orderIdIfTakeOut;
    }

    var formData = {
      "orderId": orderId.value,
      "machineCode": machineInfo.machineCode,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

          orderId.value = response['data']["orderId"];
          print(orderId.value);
          //goToSettlement();
      }else{

        //showToast(response['data']["message"]);
        Get.dialog(
            DialogUtils.alertOneButton("${response['data']["message"]}",
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr,
                confirm: () {
                  Get.back();
                })
        );
      }
    });

  }

  goToSettlement() async {
    // scanQrCodeController.text = "";
    // scanQrCodeHomeController.text = "";
    Get.toNamed('/settlement',preventDuplicates: false,
        arguments: {
          "checkLanguage": selectLanguage,
          "machineCode": machineInfo.machineCode,
          "orderId" : orderId.value,
          "totalPrice" : (totalPrice.value + discount.value - voucherAmount.value).toString(),
          "machineMode":"2",
          "showOpenPayment": showOpenPayment.value,
          "isScanCheckOut" : true,
        });
    // if (result == true) {
    //   debugPrint('---settlement back---');
    //   if (result == true) {
    //     debugPrint('settlement back');
    //     Get.back();
    //     showOrderEasyLoading();
    //     requestOrderList(scanTextValue, goDetail: false);
    //   }
    // }
  }

  resetStateBack() {
    debugPrint('settlement back');
    Get.back();
    showOrderEasyLoading();
    requestOrderList(scanTextValue, goDetail: false);
  }

  backCheckHome({resetLanguage = false}) {

    //final reset = resetLanguage;
    debugPrint('backCheckHome, reset:$resetLanguage');
    // if (reset)
    // selectLanguage = 'JP';

    _resetScanState(resetLanguage);
    Get.back();
  }

  _resetScanState(resetLanguage) {
    // if (isFirstPage) {
    //   debugPrint('isFirstPage = true');
    //   scanQrCodeHomeController.text = "";
    //   scanQrCodeHomeFocusNode.requestFocus();
    //   scanQrCodeFocusNode.unfocus();
    // } else {
      debugPrint('isFirstPage = false');
      scanQrCodeController.text = "";
      scanQrCodeFocusNode.requestFocus();// 获取焦点
      //if (resetLanguage) {//返回到首页需要重置首页扫码
        //scanQrCodeHomeFocusNode.requestFocus();
      //} else {
        //scanQrCodeHomeFocusNode.unfocus();
      //}

    //}
  }

  goMenu(String lan) {
    // machineInfo.mealType = mealType;
    //machineInfo.currentMode = MachineMode.sell;
    String jumpUrl = '/menu-page';

    switch (machineInfo.currentMode) {
      case MachineMode.sell:
        jumpUrl = '/menu-page';
        break;
      case MachineMode.scan:
        jumpUrl = '/self-checkoutscanningcode';
        break;
      case MachineMode.takeout:
        jumpUrl = '/menu-page';
        break;
      case MachineMode.checkout:
        jumpUrl = '/scancode-page';
        break;
    }

    // if (mealType) {
    //   machineInfo.currentMode = MachineMode.takeout;
    //   jumpUrl = '/menu-page';
    // } else {
    //   if (machineInfo.isScanbuyOn) {
    //     jumpUrl = '/self-checkoutscanningcode';
    //     machineInfo.currentMode = MachineMode.scan;
    //   }
    // }

    Get.toNamed(jumpUrl,
        arguments: {"checkLanguage": lan});

  }

  // goSelfCheckout() {
  //   Get.toNamed('/self-checkoutscanningcode',arguments: {
  //     "checkLanguage": selectLanguage,
  //     "mealType": machineInfo.mealType
  //   });
  // }

  updateSettingLanguage(String language) async {

    selectLanguage = language;

    var locale = const Locale('ja', 'JP');
    if (language == "CH") {
      locale = const Locale('zh', 'CN');
    } else if (language == "EN") {
      locale = const Locale('en', 'US');
    } else if (language == "KO") {
      locale = const Locale('ko', 'KR');
    }
    Get.updateLocale(locale);

    //var locale = Locale('${language.toLowerCase()}', '$language');
    //Get.updateLocale(locale);

  }


}
