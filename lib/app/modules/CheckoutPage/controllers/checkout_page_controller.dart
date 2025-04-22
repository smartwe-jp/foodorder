import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';

class CheckoutPageController extends GetxController with StateMixin, GetTickerProviderStateMixin {
  //TODO: Implement CheckoutPageController
  // TextEditingController scanQrCodeHomeController = new TextEditingController();
  // FocusNode scanQrCodeHomeFocusNode = FocusNode();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  TextEditingController scanQrCode2Controller = new TextEditingController();
  FocusNode scanQrCode2FocusNode = FocusNode();

  MachineInfoController machineInfo = Get.find();

  bool machineLanguages_JP = false;
  bool machineLanguages_CH = false;
  bool machineLanguages_EN = false;
  bool machineLanguages_KO = false;

  String selectLanguage = 'JP';
  bool startShake = false;
  bool isAnimating = false;

  RxList categoryList = [].obs;

  get takeOut => machineInfo.diningType == "2" || machineInfo.diningType == "3";

  RxString isReservation = "0".obs;
  RxBool showOpenPayment = false.obs;


  RxString orderId = "".obs;
  RxString totlaPrice = "0".obs;
  RxString tableNum = "0".obs;
  RxMap orderInfoMap = {}.obs;

  int mealTypeStatus = 0;
  int resetTime = 30;
  Timer? resetTimer;

  RxString localkey = "JP".obs;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    print("CheckoutPageController new init");
    print("localkey = $localkey");
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    //Get.focusScope.unfocus();
    //Get.focusScope.requestFocus(scanQrCodeFocusNode);
    getMenchineLanguages();
    super.onInit();
  }

  @override
  void onReady() {
    startRepeatingAnimation();
    super.onReady();
        animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // 循环动画，反向重复

    animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void onClose() {
    //stopRepeatingAnimation();
    animationController.dispose();
    super.onClose();
  }

//获取机器信息
  getMachineInfo() async {
    // var machineCodestr = await HomeServices.getMachineInfo();
    // if (machineCodestr != "") {
    //   machineCode.value = machineCodestr;
    // }
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点

    //getHomeImageList();
  }

  // getHomeImageList() async {
  //   List homeimageList = await HomeServices.getSmartweHomeImagesData();
  //   homeList.value = homeimageList;

  //   getSmartweMachineSettingData();
  //   update();
  // }

  getSmartweMachineSettingData() async {
    // var smartweMachineSetting =
    //     await HomeServices.getSmartweMachineSettingData();
    // actuarial.value = smartweMachineSetting["machineActuarial"];
    // lineup.value = smartweMachineSetting["machineLineup"];

    getSystemSettingInfo();
  }

  getSystemSettingInfo() async {
    // Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    // menu_direction.value = (SystemSettingInfo["menuDirection"] != "" &&
    //         SystemSettingInfo["menuDirection"] != null)
    //     ? SystemSettingInfo["menuDirection"]
    //     : "1";
    // isReservation.value = SystemSettingInfo["isReservation"];
    // // isAllowPos.value = SystemSettingInfo['isAllowPos'];
    // // isAllowReceipt.value = SystemSettingInfo['isAllowReceipt'];
    // takeOut.value = (SystemSettingInfo['diningType'] == "2" ||
    //         SystemSettingInfo['diningType'] == "3")
    //     ? true
    //     : false;

    getMenchineLanguages();
  }

  getMenchineLanguages() async {
    debugPrint("获取机器语言");

    machineLanguages_JP = machineInfo.supportLanguages.contains('JP');
    machineLanguages_CH = machineInfo.supportLanguages.contains('CH');
    machineLanguages_EN = machineInfo.supportLanguages.contains('EN');
    machineLanguages_KO = machineInfo.supportLanguages.contains('KO');
    debugPrint("获取机器语言结束");
    update();
    change(null, status: RxStatus.success());
  }

  //获取展示支付方式
  getMachineActivateInfo() async {
    await getBookingBootIndexCagegory();
  }

  updateSettingLanguage(String language) async {
    print(" updateSetting Language = $language");
    await HomeServices.updateSettingLanguage(language);
    selectLanguage = language;
    localkey.value = language;
    var locale = Locale('${language.toLowerCase()}', '$language');
    Get.updateLocale(locale);
    //reload catagory...
    //await getBookingBootIndexCagegory();
  }

  updateDingType(int type) async {
    debugPrint("updateDingType $type");
    startResetTimer(); // Restart the timer when updating the dining type
    mealTypeStatus = type;
    update();

    await getBookingBootIndexCagegory(); // Uncommenting to fetch categories after updating the dining type
  }

  startResetTimer() async {
    debugPrint("startResetTimer");
    resetTimer?.cancel();
    resetTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      resetTime--;
      if (resetTime == 0) {
        resetTimer?.cancel();
        resetTime = 30;
        mealTypeStatus = 0;
        debugPrint("startResetTimer end");
        update();
      }
    });
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

  get showCatagory {
    if (categoryList.length == 0) {
      debugPrint("homeList.length == 0");
      return [];
    }
    debugPrint("homeList.length > 0");

    int showItemCount = 6;

    if (categoryList.length >= showItemCount - 1) {
      // 获取前8个
      var newList = List.from(categoryList.sublist(0, showItemCount - 1));
      newList.add({
        "categoryCode": categoryList.first["categoryCode"],
        "image": null,
        "categoryName": GString.getToString(selectLanguage, "more_title"),
        "showType": "1"
      });
      return newList;
    } else {
      var newList = List.from(categoryList);
      newList.add({
        "categoryCode": categoryList.first["categoryCode"],
        "image": null,
        "categoryName": GString.getToString(selectLanguage, "more_title"),
        "showType": "1"
      });
      return newList;
    }
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

  _showDialogError(msg) {
    debugPrint("showDialogError $msg & $selectLanguage");
    Get.dialog(DialogUtils.alertOneButton(msg,
        title: GString.getToString(selectLanguage, "tag_title"),
        confirmtitle:
            GString.getToString(selectLanguage, "tag_button_yes"),
        contentTagImg: "error_public", confirm: () {
      Get.back();
    }));
  }

  _getOrderKey(qrCodeString) {
    RegExp regExp = new RegExp(r"\?p=(.*)");
    return regExp.stringMatch(qrCodeString).toString().substring(3);
  }

  String formatSum(int sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  goMenu(String lan, bool mealType) {
    machineInfo.mealType = mealType;
    var jumpUrl =
        (machineInfo.menu_direction == "1") ? '/menu-page' : '/menuzong-page';
    startShake = false;
    Get.toNamed(jumpUrl,
        arguments: {"checkLanguage": lan, "mealType": mealType});
  }

  requestOrderList({goDetail = true}) async {
    debugPrint('qrCodeString: ${scanQrCode2Controller.text}');

    String orderKey = scanQrCode2Controller.text;
    if (orderKey.isEmpty) return;

    if (orderKey.contains('?p=') == true) {
      //正则实现截取'?p='之后的字符串
      orderKey = _getOrderKey(scanQrCode2Controller.text);
    }

    debugPrint('orderKey : $orderKey');
    // textController.text = "";
    // focus.requestFocus();

    // debugPrint('/scan-detail');
    // Get.toNamed('/scan-detail',
    //     arguments: {'machineCode': machineCode.value, 'orderKey': orderKey});

    // return;
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
          response["data"]["orderId"] != null) {
        if (response["data"]["totalPrice"] >= 0) {
          // scanQrCodeController.text = "";
          // scanQrCodeFocusNode.requestFocus();
          orderId.value = response["data"]["orderId"].toString();
          totlaPrice.value = response["data"]["totalPrice"].toString();
          tableNum.value = response["data"]["tableNum"].toString();
          orderInfoMap.value = response["data"]["orderInfoMap"] ?? {};

          if (goDetail) {
            debugPrint('/scan-detail');
            Get.toNamed('/scan-detail');
          } else {
            update();
          }

          // scanQrCode2Controller.text = "";
          // scanQrCode2FocusNode.requestFocus();
        } else {
          scanQrCode2Controller.text = "";
          scanQrCode2FocusNode.requestFocus();
        }
      } else {
        scanQrCode2Controller.text = "";

        _showDialogError(response['msg']);
        scanQrCode2FocusNode.requestFocus(); // 获取焦点
      }
    }).catchError((error) {
      print('webBootCalculateV2 error:${error.toString()}');
    });
  }

  getBookingBootIndexCagegory() async {
    debugPrint("获取页面分类");

    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": selectLanguage,
      "takeout": "0",
    };
    request('webBootIndexCategoryv2', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      //isLoading.value = false;
      if (response['code'] == 200) {
        List myList = response['data']['categoryVoList'];
        categoryList.clear();
        for (var i = 0; i < myList.length; i++) {
          //if(menuIndex >=5) menuIndex = 0;
          var categoryVoList = myList[i];
          //配置顶部菜单
          categoryList.add({
            "categoryCode": categoryVoList['categoryCode'],
            "categoryName": categoryVoList['categoryName'],
            "showType": categoryVoList['showType'],
            "image": categoryVoList['image'],
            "color": categoryVoList['color'],
          });
        }
        update();
        change(null, status: RxStatus.success());
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: GString.getToString(selectLanguage, "tag_title"),
            confirmtitle:
                GString.getToString(selectLanguage, "tag_button_yes"),
            confirm: () {
          getBookingBootIndexCagegory();
        }));
        Future.delayed(Duration(milliseconds: 2000), () {
          getBookingBootIndexCagegory();
        });

        //Get.back();
      }
    });
  }

  doNextPay() {
    var _orderkey = scanQrCodeController.text; //print(_orderkey);
    if (scanQrCodeController.text != "") {
      //_showOrderEasyLoading();
      if (scanQrCodeController.text.contains('?p=') == true) {
        //正则实现截取'?p='之后的字符串
        _orderkey = _getOrderKey(scanQrCodeController.text);
      }
      //自定义声音
      //playQRScannerSound();

      var formData = {"orderKey": _orderkey};
      request('webBootCalculate', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();
        //print(response);
        if (response['code'] == 200 &&
            response["data"] != null &&
            response["data"].isNotEmpty) {
          if (response["data"]["totalPrice"] > 0) {
            orderId.value = response["data"]["orderId"].toString();
            totlaPrice.value = response["data"]["totalPrice"].toString();
            tableNum.value = response["data"]["tableNum"].toString();
            showSelectMealTypeAndPaymentMethodDialog();
          } else {
            scanQrCodeController.text = "";
            scanQrCodeFocusNode.requestFocus();
          }
        } else {
          scanQrCodeController.text = "";

          _showDialogError(response['msg']);
          scanQrCodeFocusNode.requestFocus(); // 获取焦点
        }
      });
    }
  }

  doNextHomePay() {
    var _orderkey = scanQrCodeController.text; //print(_orderkey);
    if (scanQrCodeController.text != "") {
      //_showOrderEasyLoading();
      if (_orderkey.contains('?p=') == true) {
        //正则实现截取'?p='之后的字符串
        _orderkey = _getOrderKey(scanQrCodeController.text);
      }
      //自定义声音
      //playQRScannerSound();

      var formData = {"orderKey": _orderkey};
      request('webBootCalculate', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();
        //print(response);
        if (response['code'] == 200 &&
            response["data"] != null &&
            response["data"].isNotEmpty) {
          if (response["data"]["totalPrice"] > 0) {
            orderId.value = response["data"]["orderId"].toString();
            totlaPrice.value = response["data"]["totalPrice"].toString();
            tableNum.value = response["data"]["tableNum"].toString();
            showSelectMealTypeAndPaymentMethodDialog();
          } else {
            scanQrCodeController.text = "";
            scanQrCodeFocusNode.requestFocus();
          }
        } else {
          scanQrCodeController.text = "";

          _showDialogError(response['msg']);
          scanQrCodeFocusNode.requestFocus(); // 获取焦点
        }
      });
    }
  }

  detaiCheckPayment(iOrderId, iTotlaPrice, iTableNum) {
    orderId.value = iOrderId;
    totlaPrice.value = iTotlaPrice;
    tableNum.value = iTableNum;
    showSelectMealTypeAndPaymentMethodDialog();
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog() async {
    scanQrCodeFocusNode.requestFocus();
    debugPrint('localkey = $localkey');
    //scanQrCodeHomeFocusNode.requestFocus();
    machineInfo.showReceiptPage = machineInfo.isReceiptPageShow;
    debugPrint('showReceiptPage = ${machineInfo.showReceiptPage}');
    Get.to(
      () => SelectPaymentPage(
          checkLanguage: localkey.value, //padding and need improve
          menuCount: 0,
          //mealType:_mealType,
          shopCartTotalPrice: totlaPrice.value,
          tableNum: tableNum.value,
          onConfrimClick: () async {
            //checkLanguage.value = "JP";
            scanQrCodeController.text = "";
            //scanQrCodeHomeController.text = "";
            showOpenPayment.value = true;

            goToSettlement();
          },
          onCancelClick: (String isBack) {
            if (isBack == "back") {
              scanQrCodeController.text = "";
              //scanQrCodeHomeController.text = "";
            }
            scanQrCodeFocusNode.requestFocus(); // 获取焦点
            //scanQrCodeHomeFocusNode.requestFocus(); // 获取焦点
          }),
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
    request('webBootToPayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 &&
          response['data'] != null &&
          response['data']['orderId'] != null) {
        orderId.value = response['data']["orderId"];
        print(orderId.value);
        //goToSettlement();
      } else {
        //showToast(response['data']["message"]);
        Get.dialog(DialogUtils.alertOneButton("${response['data']["message"]}",
            title: GString.getToString(selectLanguage, "tag_title"),
            confirmtitle:
                GString.getToString(selectLanguage, "tag_button_yes"),
            confirm: () {
          Get.back();
        }));
      }
    });
  }

  getPosSettingInfo() async {
    // Map posSettingInfo = await HomeServices.getPosSettingInfo();
    // pos_ip.value = posSettingInfo['posIp'];
    // pos_port.value = posSettingInfo['posPort'];
    //postNewOrderId();
    goToSettlement();
  }

  goToSettlement() async {
    scanQrCodeController.text = "";
    //scanQrCodeHomeController.text = "";
    final result =
        await Get.toNamed('/settlement', preventDuplicates: false, arguments: {
      "checkLanguage": localkey.value, //padding and need improve,
      "orderId": orderId.value,
      "totalPrice": totlaPrice.value,
      "machineMode": "2",
      "showOpenPayment": showOpenPayment.value
    });
    if (result == true) {
      debugPrint('settlement back');
      Get.back();
      requestOrderList(goDetail: false);
    }
  }

  backCheckHome() {
    debugPrint("---backCheckHome---");
    Get.back();
    scanQrCodeController.text = "";
    scanQrCodeFocusNode.requestFocus();
    scanQrCode2Controller.text = "";
    scanQrCode2FocusNode.requestFocus();
  }
}
