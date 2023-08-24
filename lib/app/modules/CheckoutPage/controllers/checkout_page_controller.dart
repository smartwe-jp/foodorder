import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

class CheckoutPageController extends GetxController with StateMixin {
  //TODO: Implement CheckoutPageController
  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  RxString machineCode = "".obs;
  RxList homeList = [].obs;

  RxBool actuarial = false.obs;
  RxBool lineup = false.obs;
  RxBool takeOut = false.obs; //是否允许外带
  RxString menu_direction = "1".obs;//1 默认顶部横向  2 左侧纵向
  RxString isReservation = "0".obs;

  RxString isAllowPos = "0".obs; //1 使用信用卡刷卡  0 不可使用
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

  RxBool showVisa = false.obs;
  RxBool showMaster = false.obs;
  RxBool showJcb = false.obs;
  RxBool showUnionPay = false.obs;
  RxBool showAmericanExpress = false.obs;
  RxBool showDinersClub = false.obs;

  RxString orderId = "".obs;
  RxString totlaPrice = "0".obs;
  RxString tableNum = "0".obs;

  RxString payment_method_num = "0".obs; //支付类型选择
  RxString checkLanguage = "JP".obs;

  @override
  void onInit() {
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
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
    var smartweMachineSetting = await HomeServices.getSmartweMachineSettingData();
    actuarial.value = smartweMachineSetting["machineActuarial"];
    lineup.value = smartweMachineSetting["machineLineup"];

    getSystemSettingInfo();
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

      menu_direction.value = (SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1";
      isReservation.value = SystemSettingInfo["isReservation"];
      isAllowPos.value = SystemSettingInfo['isAllowPos'];
      takeOut.value = (SystemSettingInfo['diningType'] == "2" || SystemSettingInfo['diningType'] == "3") ? true : false;

    getmenchineLanguages();

  }

  getmenchineLanguages() async {
    var menchineLanguagesData = await HomeServices.getMachineLanguages();

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

    update();
    change(null, status: RxStatus.success());
  }


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

  _showDialogError(msg){
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

    Get.dialog(
        DialogUtils.alertOneButton(msg,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
            contentTagImg:"error_public",
            confirm: () {
              Get.back();
            })
    );
  }

  doNextPay(){
    var _orderkey = scanQrCodeController.text;//print(_orderkey);
    if(scanQrCodeController.text !=""){
      //_showOrderEasyLoading();
      if(scanQrCodeController.text.contains('?p=') == true){
        _orderkey = scanQrCodeController.text.substring(scanQrCodeController.text.length-21);
      }
      //自定义声音
      //playQRScannerSound();

      var formData = {
        "orderKey": _orderkey
      };print(formData);
      request('webBootCalculate', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());print(response);
        EasyLoading.dismiss();
        //print(response);
        if (response['code'] == 200 && response["data"] !=null && response["data"].isNotEmpty) {
          if(response["data"]["totalPrice"] >0){
              orderId.value = response["data"]["orderId"].toString();
              totlaPrice.value = response["data"]["totalPrice"].toString();
              tableNum.value = response["data"]["tableNum"].toString();
            _showSelectMealTypeAndPaymentMethodDialog();
          }else{
            scanQrCodeController.text = "";
            scanQrCodeFocusNode.requestFocus();
          }

        }else{
          scanQrCodeController.text = "";

          _showDialogError(response['msg']);
          scanQrCodeFocusNode.requestFocus();// 获取焦点
        }
      });
    }
  }

  //选择食用方式和支付方式
  _showSelectMealTypeAndPaymentMethodDialog() async {
    scanQrCodeFocusNode.requestFocus();
    Get.dialog(
        SelectPaymentPage(
            checkLanguage: checkLanguage.value,
            menuCount: 0,
            //mealType:_mealType,
            isAllowPos: isAllowPos.value,
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
            showDinersClub:showDinersClub.value,
            shopCartTotalPrice:totlaPrice.value,
            tableNum: tableNum.value,
            onConfrimClick: (String isAllowPosstr, String payment_method_numcheck) {
                isAllowPos.value = isAllowPosstr;
                payment_method_num.value = payment_method_numcheck;
                checkLanguage.value = "JP";
                scanQrCodeController.text = "";

              var paymentMethod = ["3","4","5","6","7","8","9","10"];
              if (paymentMethod.contains(payment_method_num.value) == true) {
                getPosSettingInfo();
              }else{
                //postNewOrderId();
                goToSettlement();
              }

            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                scanQrCodeController.text = "";

              }
              scanQrCodeFocusNode.requestFocus();// 获取焦点
            }
        )
    );
  }

  postNewOrderId() {

    var formData = {
      "orderId": orderId.value,
    };print(orderId.value);
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
print(response);
      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

          orderId.value = response['data']["orderId"];
          print(orderId.value);
          //goToSettlement();
      }else{

        showToast(response['data']["message"]);
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
  goToSettlement(){
    scanQrCodeController.text = "";
    Get.toNamed('/settlement',
        arguments: {
          "checkLanguage": checkLanguage.value,
          "machineCode": machineCode.value,
          "orderId" : orderId.value,
          "totalPrice" : totlaPrice.value,
          "machineMode":"2",
          "isAllowPos": isAllowPos.value,
          "posIp": pos_ip.value,
          "posPort": pos_port.value,
          "paymentMethod":payment_method_num.value,
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
        });
  }


}
