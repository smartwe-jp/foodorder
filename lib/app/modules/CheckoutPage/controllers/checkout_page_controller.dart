import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/ScanDetail/views/scan_detail_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';

class CheckoutPageController extends GetxController with StateMixin {
  //TODO: Implement CheckoutPageController
  // TextEditingController scanQrCodeHomeController = new TextEditingController();
  // FocusNode scanQrCodeHomeFocusNode = FocusNode();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  TextEditingController scanQrCode2Controller = new TextEditingController();
  FocusNode scanQrCode2FocusNode = FocusNode();

  RxBool machineLanguages_JP = false.obs;
  RxBool machineLanguages_CH = false.obs;
  RxBool machineLanguages_EN = false.obs;
  RxBool machineLanguages_KO = false.obs;
  RxString settingLanguage = "JP".obs;

  RxString machineCode = "".obs;
  RxList homeList = [].obs;
  RxList categoryList = [].obs;

  RxBool actuarial = false.obs;
  RxBool lineup = false.obs;
  RxBool takeOut = false.obs; //是否允许外带
  RxString menu_direction = "1".obs; //1 默认顶部横向  2 左侧纵向
  RxString isReservation = "0".obs;

  RxString isAllowPos = "0".obs; //1 使用信用卡刷卡  0 不可使用
  RxString isAllowReceipt = "2".obs; //1 直接打印領収書  ２ 实现打印領収書菜单
  RxString receiptPrintType = "2".obs; //1 打印領収書  ２ 不打印領収書
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;

  RxList machineLanguagesList = [].obs;

  //顶部展示支付类型
  RxBool showWechat = false.obs;
  RxBool showAlipay = false.obs;
  RxBool showPayPay = false.obs;
  RxBool showCreditCard = false.obs;
  RxBool showCash = false.obs;

  RxBool showauPay = false.obs;
  RxBool showdPay = false.obs;
  RxBool showrPay = false.obs;
  RxBool showmPay = false.obs;

  RxBool showPosEdy = false.obs;
  RxBool showPosiD = false.obs;
  RxBool showPosIC = false.obs;
  RxBool showPosQUICPay = false.obs;
  RxBool showPosWAON = false.obs;
  RxBool showPosnanaco = false.obs;
  RxBool showOpenPayment = false.obs;

  RxBool showVisa = false.obs;
  RxBool showMaster = false.obs;
  RxBool showJcb = false.obs;
  RxBool showUnionPay = false.obs;
  RxBool showAmericanExpress = false.obs;
  RxBool showDinersClub = false.obs;
  RxBool showDiscover = false.obs;

  RxString orderId = "".obs;
  RxString totlaPrice = "0".obs;
  RxString tableNum = "0".obs;
  RxMap orderInfoMap = {}.obs;

  RxString payment_method_num = "0".obs; //支付类型选择
  RxString checkLanguage = "JP".obs;
  int mealTypeStatus = 0;
  int resetTime = 3;
  Timer? resetTimer;

  @override
  void onInit() {
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    //Get.focusScope.unfocus();
    //Get.focusScope.requestFocus(scanQrCodeFocusNode);
    getMachineInfo();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

//获取机器信息
  getMachineInfo() async {
    var machineCodestr = await HomeServices.getMachineInfo();
    if (machineCodestr != "") {
      machineCode.value = machineCodestr;
    }
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点

    getHomeImageList();
  }

  getHomeImageList() async {
    List homeimageList = await HomeServices.getSmartweHomeImagesData();
    homeList.value = homeimageList;

    getSmartweMachineSettingData();
    update();
  }

  getSmartweMachineSettingData() async {
    var smartweMachineSetting =
        await HomeServices.getSmartweMachineSettingData();
    actuarial.value = smartweMachineSetting["machineActuarial"];
    lineup.value = smartweMachineSetting["machineLineup"];

    getSystemSettingInfo();
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    menu_direction.value = (SystemSettingInfo["menuDirection"] != "" &&
            SystemSettingInfo["menuDirection"] != null)
        ? SystemSettingInfo["menuDirection"]
        : "1";
    isReservation.value = SystemSettingInfo["isReservation"];
    isAllowPos.value = SystemSettingInfo['isAllowPos'];
    isAllowReceipt.value = SystemSettingInfo['isAllowReceipt'];
    takeOut.value = (SystemSettingInfo['diningType'] == "2" ||
            SystemSettingInfo['diningType'] == "3")
        ? true
        : false;

    getmenchineLanguages();
  }

  getmenchineLanguages() async {
    var menchineLanguagesData = await HomeServices.getMachineLanguages();
    debugPrint("获取机器语言");
    var languageJP = false;
    var languageCH = false;
    var languageEN = false;
    var languageKO = false;

    for (var item in menchineLanguagesData) {
      if (item == "JP") {
        languageJP = true;
      } else if (item == "CH") {
        languageCH = true;
      } else if (item == "EN") {
        languageEN = true;
      } else if (item == "KO") {
        languageKO = true;
      }
    }

    machineLanguages_JP.value = languageJP;
    machineLanguages_CH.value = languageCH;
    machineLanguages_EN.value = languageEN;
    machineLanguages_KO.value = languageKO;

    machineLanguagesList.value = menchineLanguagesData;

    getMachineActivateInfo();
  }

  //获取展示支付方式
  getMachineActivateInfo() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();

    showCash.value = systemSettingInfo['showCash'];
    showWechat.value = systemSettingInfo['showWechat'];
    showAlipay.value = systemSettingInfo['showAlipay'];
    showPayPay.value = systemSettingInfo['showPayPay'];
    showCreditCard.value = systemSettingInfo['showCreditCard'];

    showauPay.value = systemSettingInfo['au_Pay'];
    showdPay.value = systemSettingInfo['d_Pay'];
    showrPay.value = systemSettingInfo['R_Pay'];
    showmPay.value = systemSettingInfo['m_Pay'];

    showPosEdy.value = systemSettingInfo['pos_Edy'];
    showPosiD.value = systemSettingInfo['pos_iD'];
    showPosIC.value = systemSettingInfo['pos_IC'];
    showPosQUICPay.value = systemSettingInfo['pos_QUICPay'];
    showPosWAON.value = systemSettingInfo['pos_WAON'];
    showPosnanaco.value = systemSettingInfo['pos_nanaco'];

    showVisa.value = systemSettingInfo['show_visa'];
    showMaster.value = systemSettingInfo['show_master'];
    showJcb.value = systemSettingInfo['show_jcb'];
    showUnionPay.value = systemSettingInfo['show_unionPay'];
    showAmericanExpress.value = systemSettingInfo['show_americanExpress'];
    showDinersClub.value = systemSettingInfo['show_dinersClub'];
    showDiscover.value = systemSettingInfo['show_discover'];

    await getBookingBootIndexCagegory();
  }

  updateSettingLanguage(String language) async {
    await HomeServices.updateSettingLanguage(language);
    settingLanguage.value = language;
    var locale = Locale('${language.toLowerCase()}', '$language');
    Get.updateLocale(locale);
    //reload catagory...
    await getBookingBootIndexCagegory();
  }

  updateDingType(int type) async {
    debugPrint("updateDingType $type");
    startResetTimer();
    mealTypeStatus = type;
    update();

    //await getBookingBootIndexCagegory();
  }

  startResetTimer() async {
    debugPrint("startResetTimer");
    resetTimer?.cancel();
    resetTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      resetTime--;
      if (resetTime == 0) {
        resetTimer?.cancel();
        resetTime = 3;
        mealTypeStatus = 0;
        debugPrint("startResetTimer end");
        update();
      }
    });
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
        "categoryName":
            GString.getToString(settingLanguage.value, "more_title"),
        "showType": "1"
      });
      return newList;
    } else {
      var newList = List.from(categoryList);
      newList.add({
        "categoryCode": categoryList.first["categoryCode"],
        "image": null,
        "categoryName":
            GString.getToString(settingLanguage.value, "more_title"),
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
    //查询订单弹出提示
    /*Get.dialog(
        Container(
          width: ScreenAdapter.width(950),
          child: SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Align(
                  alignment: Alignment.center,
                  child:  Text(GString.getToString(checkLanguage.value, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
              ),
              children: <Widget>[
                Container(
                  width: ScreenAdapter.width(650),
                  padding: EdgeInsets.only(left: ScreenAdapter.width(30),right: ScreenAdapter.width(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onLongPress: (){
                              EasyLoading.dismiss();
                            },
                            child: Container(
                              //width: ScreenAdapter.width(400),
                              //margin: EdgeInsets.only(top: 60),
                              height: ScreenAdapter.height(75),
                              child: Image.asset(GImage.getImageString("imgpublic", "error_public"),fit: BoxFit.fitHeight),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: ScreenAdapter.width(25),right: ScreenAdapter.width(25)),
                                  child: Text(msg,style: TextStyle(fontSize: ScreenAdapter.fontSize(28)))
                              )
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 70.0),
                              child: TextButton(
                                child: Text(
                                  GString.getToString(this._checkLanguage, "settlement_change_method"),
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  //Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ]
          ),
        )
    );*/

    Get.dialog(DialogUtils.alertOneButton(msg,
        title: GString.getToString(checkLanguage.value, "tag_title"),
        confirmtitle:
            GString.getToString(checkLanguage.value, "tag_button_yes"),
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

  requestOrderList(
      TextEditingController textController, FocusNode focus) async {
    debugPrint('qrCodeString: ${textController.text}');

    String orderKey = textController.text;
    if (orderKey.isEmpty) return;

    if (orderKey.contains('?p=') == true) {
      //正则实现截取'?p='之后的字符串
      orderKey = _getOrderKey(textController.text);
    }

    debugPrint('orderKey : $orderKey');
    textController.text = "";
    focus.requestFocus();

    debugPrint('/scan-detail');
    Get.toNamed('/scan-detail',
        arguments: {'machineCode': machineCode.value, 'orderKey': orderKey});

    return;
    var formData = {
      "orderKey": orderKey,
      "language": checkLanguage.value,
      "machineCode": machineCode.value
    };

    debugPrint('formData: $formData');

    request('webBootCalculateV2', method: 'POST', parameters: formData)
        .then((val) {
      print('webBootCalculateV2:$val');

      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 &&
          response["data"] != null &&
          response["data"].isNotEmpty) {
        if (response["data"]["totalPrice"] > 0) {
          // scanQrCodeController.text = "";
          // scanQrCodeFocusNode.requestFocus();
          orderId.value = response["data"]["orderId"].toString();
          totlaPrice.value = response["data"]["totalPrice"].toString();
          tableNum.value = response["data"]["tableNum"].toString();
          orderInfoMap.value = response["data"]["orderInfoMap"] ?? {};
          debugPrint('/scan-detail');
          Get.toNamed('/scan-detail');
          textController.text = "";
          focus.requestFocus();
        } else {
          textController.text = "";
          focus.requestFocus();
        }
      } else {
        textController.text = "";

        _showDialogError(response['msg']);
        focus.requestFocus(); // 获取焦点
      }
    }).catchError((error) {
      print('webBootCalculateV2 error:${error.toString()}');
    });
  }

  getBookingBootIndexCagegory() async {
    debugPrint("获取页面分类");

    var formData = {
      "machineCode": machineCode.value,
      "language": settingLanguage.value,
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
            title: GString.getToString(settingLanguage.value, "tag_title"),
            confirmtitle:
                GString.getToString(settingLanguage.value, "tag_button_yes"),
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
    //scanQrCodeHomeFocusNode.requestFocus();
    Get.dialog(SelectPaymentPage(
        checkLanguage: checkLanguage.value,
        menuCount: 0,
        //mealType:_mealType,
        isAllowPos: isAllowPos.value,
        isAllowReceipt: isAllowReceipt.value,
        payment_method_num: payment_method_num.value,
        showCash: showCash.value,
        showWechat: showWechat.value,
        showAlipay: showAlipay.value,
        showPayPay: showPayPay.value,
        showauPay: showauPay.value,
        showdPay: showdPay.value,
        showrPay: showrPay.value,
        showmPay: showmPay.value,
        showCreditCard: showCreditCard.value,
        showPosEdy: showPosEdy.value,
        showPosiD: showPosiD.value,
        showPosIC: showPosIC.value,
        showPosQUICPay: showPosQUICPay.value,
        showPosWAON: showPosWAON.value,
        showPosnanaco: showPosnanaco.value,
        showVisa: showVisa.value,
        showMaster: showMaster.value,
        showJcb: showJcb.value,
        showUnionPay: showUnionPay.value,
        showAmericanExpress: showAmericanExpress.value,
        showDinersClub: showDinersClub.value,
        showDiscover: showDiscover.value,
        shopCartTotalPrice: totlaPrice.value,
        tableNum: tableNum.value,
        onConfrimClick: (String isAllowPosstr, String payment_method_numcheck,
            String receiptPrintTypeString) {
          isAllowPos.value = isAllowPosstr;
          payment_method_num.value = payment_method_numcheck;
          receiptPrintType.value = receiptPrintTypeString;
          //checkLanguage.value = "JP";
          scanQrCodeController.text = "";
          //scanQrCodeHomeController.text = "";
          showOpenPayment.value = true;

          var paymentMethod = ["3", "4", "5", "6", "7", "8", "9", "10"];
          if (paymentMethod.contains(payment_method_num.value) == true) {
            getPosSettingInfo();
          } else {
            //postNewOrderId();
            goToSettlement();
          }
        },
        onCancelClick: (String isBack) {
          if (isBack == "back") {
            scanQrCodeController.text = "";
            //scanQrCodeHomeController.text = "";
          }
          scanQrCodeFocusNode.requestFocus(); // 获取焦点
          //scanQrCodeHomeFocusNode.requestFocus(); // 获取焦点
        }));
  }

  postNewOrderId({orderIdIfTakeOut = ""}) {
    if (orderId.value == "") {
      orderId.value = orderIdIfTakeOut;
    }

    var formData = {
      "orderId": orderId.value,
      "machineCode": machineCode.value,
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
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle:
                GString.getToString(checkLanguage.value, "tag_button_yes"),
            confirm: () {
          Get.back();
        }));
      }
    });
  }

  getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    pos_ip.value = posSettingInfo['posIp'];
    pos_port.value = posSettingInfo['posPort'];
    //postNewOrderId();
    goToSettlement();
  }

  goToSettlement() {
    scanQrCodeController.text = "";
    //scanQrCodeHomeController.text = "";
    Get.toNamed('/settlement', preventDuplicates: false, arguments: {
      "checkLanguage": checkLanguage.value,
      "machineCode": machineCode.value,
      "orderId": orderId.value,
      "totalPrice": totlaPrice.value,
      "machineMode": "2",
      "isAllowPos": isAllowPos.value,
      "receiptPrintType": receiptPrintType.value,
      "posIp": pos_ip.value,
      "posPort": pos_port.value,
      "paymentMethod": payment_method_num.value,
      "showWechat": showWechat.value,
      "showAlipay": showAlipay.value,
      "showPayPay": showPayPay.value,
      "showCreditCard": showCreditCard.value,
      "showauPay": showauPay.value,
      "showdPay": showdPay.value,
      "showrPay": showrPay.value,
      "showmPay": showmPay.value,
      "showPosEdy": showPosEdy.value,
      "showPosiD": showPosiD.value,
      "showPosIC": showPosIC.value,
      "showPosQUICPay": showPosQUICPay.value,
      "showPosWAON": showPosWAON.value,
      "showPosnanaco": showPosnanaco.value,
      "showVisa": showVisa.value,
      "showMaster": showMaster.value,
      "showJcb": showJcb.value,
      "showUnionPay": showUnionPay.value,
      "showAmericanExpress": showAmericanExpress.value,
      "showDinersClub": showDinersClub.value,
      "showDiscover": showDiscover.value,
      "showOpenPayment": showOpenPayment.value
    });
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
