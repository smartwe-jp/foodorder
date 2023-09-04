import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../config/imageData.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';

class SelfCheckoutscanningcodeController extends GetxController with StateMixin {
  //TODO: Implement SelfCheckoutscanningcodeController
  OrderSqlController ordersqlcontroller = Get.find<OrderSqlController>();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  //默认语言包选择
  RxString checkLanguage = "JP".obs;
  RxString machineCode = "".obs;

  RxList showCartItems = [].obs;
  RxMap showItem = {}.obs;
  RxString shopCartTotalPrice = "0".obs;
  RxInt showCartTotalGoodsNum = 0.obs;

  RxString isAllowPos = "0".obs; //1 使用信用卡刷卡  0 不可使用
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;
  RxString payment_method_num = "0".obs; //支付类型选择

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

  @override
  void onInit() {
    readyQueryData();
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

  readyQueryData(){print(Get.arguments);
  checkLanguage.value = Get.arguments['checkLanguage'];
  _getMachineInfo();

  }

  //获取机器信息
  _getMachineInfo() async {
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode.value = machineCodeString;

      _getSystemSettingInfo();
    }
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    isAllowPos.value = systemSettingInfo['isAllowPos'];
    _getMachineActivateInfo();

  }

  //获取展示支付方式
  _getMachineActivateInfo() async {
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

    getCartPriceTotal(); //新版新获取分类
  }

  getCartPriceTotal() async {

    ordersqlcontroller.getCardList();
    var total = await ordersqlcontroller.getCartAllPrice();
    if(total != null){
      shopCartTotalPrice.value = total["totalPrice"] == null ? "0" : total["totalPrice"].toString();
    }

    var totalNum = await ordersqlcontroller.getCartTotalNum();
    showCartTotalGoodsNum.value = totalNum;


    showCartItems.value = ordersqlcontroller.cartItems;

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

  doScanQrCodeQuery(){print("扫码进来了");
  if(scanQrCodeController.text !=""){

    var formData = {
      "machineCode": machineCode.value,
      "barCode":scanQrCodeController.text
    };print(formData);

    request('webBootBarCodeQuery', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString()); print(response);
      EasyLoading.dismiss();
      scanQrCodeController.text = "";
      scanQrCodeFocusNode.requestFocus();     // 获取焦点

      //print(response);
      if (response['code'] == 200 && response["data"] !=null && response["data"].isNotEmpty) {
        print(response);
        publicAddCart(response["data"]);

      }else{
        print("未查询出来");
      }
    });
  }
  }

  publicAddCart(item) async {
    var cartItem = {
      "menuCode": item['menuCode'],
      "mainTitle": item['mainTitle'],
      "image": item['homeImage'],
      "currentPrice": item['currentPrice'],
      "unitPrice": item['currentPrice'],
      "optionGroupVoList": "",
      "optionVoListMsg": "",
      "goodsNum": 1,
      "qtyBounds": item['qtyBounds']
    };
    publicAddCartMenu(cartItem, true).then((val) {
      //更改显示购物车价格
      getCartPriceTotal();
    });
  }

  //公共加入购物车
  publicAddCartMenu(cartItem, checkItem) async {
    var result = false;
    try {
      result = await ordersqlcontroller.addToCart(cartItem, checkItem: checkItem);
      ordersqlcontroller.getCardList();


    } catch (e) {
      print(e);
      result = false;
    }
    return result;
  }


}
