import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';
import '../../scan_detail_page/logic.dart';
import '../../scan_detail_page/view.dart';

class CheckoutPageController extends GetxController with StateMixin {
  //TODO: Implement CheckoutPageController
  TextEditingController scanQrCodeHomeController = new TextEditingController();
  FocusNode scanQrCodeHomeFocusNode = FocusNode();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  MachineInfoController machineInfo = Get.find();

  RxBool actuarial = false.obs;
  RxBool lineup = false.obs;
  RxBool takeOut = false.obs; //是否允许外带

  RxString isReservation = "0".obs;
  RxBool showOpenPayment = false.obs;

  RxString orderId = "".obs;
  RxString totalPrice = "0".obs;
  RxString tableNum = "0".obs;

  RxString checkLanguage = "JP".obs;
  bool isFirstPage = false;


  RxMap orderInfoMap = {}.obs;
  String scanTextValue = '';

  @override
  void onInit() {
    debugPrint("CheckoutPageController init");
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    //Get.focusScope.unfocus();
    //Get.focusScope.requestFocus(scanQrCodeFocusNode);
    takeOut.value = (machineInfo.diningType == "2" || machineInfo.diningType == "3") ? true : false;

    change(null, status: RxStatus.success());
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
//   getMachineInfo() async {
//     var machineCodestr = await HomeServices.getMachineInfo();
//     if (machineCodestr != "") {
//         machineCode.value = machineCodestr;
//
//     }
//     //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
//
//     getHomeImageList();
//   }

  // getHomeImageList() async {
  //   List homeimageList = await HomeServices.getSmartweHomeImagesData();
  //   homeList.value = homeimageList;
  //
  //   getSmartweMachineSettingData();
  //   update();
  // }

  // getSmartweMachineSettingData() async {
  //   var smartweMachineSetting = await HomeServices.getSmartweMachineSettingData();
  //   actuarial.value = smartweMachineSetting["machineActuarial"];
  //   lineup.value = smartweMachineSetting["machineLineup"];
  //
  //   getSystemSettingInfo();
  // }



  //获取展示支付方式



  showOrderEasyLoading(){
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


  requestOrderList(String scanText, {goDetail = true, firstPage = false}) async {
    isFirstPage = firstPage;
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
      "language": checkLanguage.value,
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
        if (response["data"]["totalPrice"] > 0) {

          orderId.value = response["data"]["orderId"].toString();
          totalPrice.value = response["data"]["totalPrice"].toString();
          tableNum.value = response["data"]["tableNum"].toString();
          orderInfoMap.value = response["data"]["orderInfoMap"] ?? {};

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
      title: GString.getToString(checkLanguage.value, "tag_title"),
      confirmtitle:
      GString.getToString(checkLanguage.value, "tag_button_yes"),
      contentTagImg: "error_public", confirm: () {
        Get.back();
      }));
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog() async {
    scanQrCodeFocusNode.requestFocus();
    scanQrCodeHomeFocusNode.requestFocus();
    Get.to(
          () =>
        SelectPaymentPage(
            checkLanguage: checkLanguage.value,
            menuCount: 0,
            shopCartTotalPrice:totalPrice.value,
            tableNum: tableNum.value,
            onConfrimClick: () {
                showOpenPayment.value = true;
                machineInfo.showReceiptPage = true;
                goToSettlement();
            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                scanQrCodeController.text = "";
                scanQrCodeHomeController.text = "";
              }
              scanQrCodeFocusNode.requestFocus();// 获取焦点
              scanQrCodeHomeFocusNode.requestFocus();// 获取焦点
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
                title: GString.getToString(checkLanguage.value, "tag_title"),
                confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
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
          "checkLanguage": checkLanguage.value,
          "machineCode": machineInfo.machineCode,
          "orderId" : orderId.value,
          "totalPrice" : totalPrice.value,
          "machineMode":"2",
          "showOpenPayment": showOpenPayment.value
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

    final reset = isFirstPage || resetLanguage;
    debugPrint('backCheckHome isFirstPage:$isFirstPage, reset:$resetLanguage');
    if (reset)
    checkLanguage.value = 'JP';

    _resetScanState(resetLanguage);
    Get.back();
  }

  _resetScanState(resetLanguage) {
    if (isFirstPage) {
      debugPrint('isFirstPage = true');
      scanQrCodeHomeController.text = "";
      scanQrCodeHomeFocusNode.requestFocus();
      scanQrCodeFocusNode.unfocus();
    } else {
      debugPrint('isFirstPage = false');
      scanQrCodeController.text = "";
      scanQrCodeFocusNode.requestFocus();// 获取焦点
      if (resetLanguage) {//返回到首页需要重置首页扫码
        scanQrCodeHomeFocusNode.requestFocus();
      } else {
        scanQrCodeHomeFocusNode.unfocus();
      }

    }
  }


}
