import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info.dart';

import 'package:get/get.dart';

import '../../../config/imageData.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';

class SelfCheckoutscanningcodeController extends GetxController with StateMixin {
  //TODO: Implement SelfCheckoutscanningcodeController
  OrderSqlController ordersqlcontroller = Get.find();
  MachineInfoController machineInfo = Get.find();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode(debugLabel: 'TextField');

  ScrollController itemscrollController = ScrollController();

  //默认语言包选择
  RxString checkLanguage = "JP".obs;
  RxBool mealType = false.obs;//用于判断下单

  RxList showCartItems = [].obs;
  RxList showScanCartItems = [].obs;
  RxMap showItem = {}.obs;
  RxString shopCartTotalPrice = "0".obs;
  RxInt showCartTotalGoodsNum = 0.obs;

  RxBool showOpenPayment = false.obs;


  RxString doSubmitOrderId = "".obs;

  final player = AudioPlayer();

  bool get containTax => machineInfo.taxSystem;

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

  readyQueryData() async {
    checkLanguage.value = Get.arguments['checkLanguage'];
    await ordersqlcontroller.removeAllFromCart();
    getCartPriceTotal();

  }

  //获取机器信息
  _getMachineInfo() async {
    // var machineCodeString = await HomeServices.getMachineInfo();
    // if (machineCodeString != "") {
    //   machineCode.value = machineCodeString;

    //   _getSystemSettingInfo();
    // }
    _getSystemSettingInfo();
  }

  _getSystemSettingInfo() async {
    // Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    // isAllowPos.value = systemSettingInfo['isAllowPos'];
    // isAllowReceipt.value = systemSettingInfo['isAllowReceipt'];
    _getMachineActivateInfo();

  }

  //获取展示支付方式
  _getMachineActivateInfo() async {
    // Map systemSettingInfo = await HomeServices.getMachineActivateData();
    // showCash.value = systemSettingInfo['showCash'];
    // showWechat.value = systemSettingInfo['showWechat'];
    // showAlipay.value = systemSettingInfo['showAlipay'];
    // showPayPay.value = systemSettingInfo['showPayPay'];
    // showCreditCard.value = systemSettingInfo['showCreditCard'];

    // showauPay.value = systemSettingInfo['au_Pay'];
    // showdPay.value = systemSettingInfo['d_Pay'];
    // showrPay.value = systemSettingInfo['R_Pay'];
    // showmPay.value = systemSettingInfo['m_Pay'];

    // showPosEdy.value = systemSettingInfo['pos_Edy'];
    // showPosiD.value = systemSettingInfo['pos_iD'];
    // showPosIC.value = systemSettingInfo['pos_IC'];
    // showPosQUICPay.value = systemSettingInfo['pos_QUICPay'];
    // showPosWAON.value = systemSettingInfo['pos_WAON'];
    // showPosnanaco.value = systemSettingInfo['pos_nanaco'];

    // showVisa.value = systemSettingInfo['show_visa'];
    // showMaster.value = systemSettingInfo['show_master'];
    // showJcb.value = systemSettingInfo['show_jcb'];
    // showUnionPay.value = systemSettingInfo['show_unionPay'];
    // showAmericanExpress.value = systemSettingInfo['show_americanExpress'];
    // showDinersClub.value = systemSettingInfo['show_dinersClub'];
    // showDiscover.value = systemSettingInfo['show_discover'];

    getCartPriceTotal(); //新版新获取分类
  }

  getCartPriceTotal({hideLoading = true}) async {
    await ordersqlcontroller.getCardList();
    var total = await ordersqlcontroller.getCartAllPrice();
    if(total != null){
      shopCartTotalPrice.value = total["totalPrice"] == null ? "0" : total["totalPrice"].toString();
    }

    var totalNum = await ordersqlcontroller.getCartTotalNum();
    showCartTotalGoodsNum.value = totalNum;

    showCartItems.value = ordersqlcontroller.cartItems;


    update();
    change(null, status: RxStatus.success());
    _resetScanQrCode(hideLoading);
    scrollToBottom();
  }

  _resetScanQrCode(hideLoading){
    scanQrCodeController.text = "";
    //所有流程执行完成后才能获取焦点
    scanQrCodeFocusNode.requestFocus();
    if (hideLoading) {
      EasyLoading.dismiss();
    }
  }

  deleteItemSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/697.wav"),
      autoStart: true,
      volume: 0.8,
    );
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

  doScanQrCodeQuery(){
    showOrderEasyLoading();//扫描后显示加载框
    if(scanQrCodeController.text !=""){
      var formData = {
        "language": checkLanguage.value,
        "machineCode": machineInfo.machineCode,
        "barCode":scanQrCodeController.text
      };

      request('webBootBarCodeQuery', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        //EasyLoading.dismiss();
        //scanQrCodeController.text = "";
        //scanQrCodeFocusNode.requestFocus();     // 获取焦点
        debugPrint("---- doScanQrCodeQuery ---- $response");
        //print(response);
        if (response['code'] == 200 && response["data"] !=null && response["data"].isNotEmpty) {

          publicAddCart(response["data"]);

        }else{
          print("未查询出来");
          _resetScanQrCode(true);
        }
      });
    }
  }

  publicAddCart(item) async {
    var cartItem = {
      "menuCode": item['menuCode'],
      "mainTitle": item['mainTitle'],
      "image": "",//item['homeImage']
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
    await ordersqlcontroller.addToCart(cartItem, checkItem: checkItem);
    publicScanAddToCart(cartItem);

      //ordersqlcontroller.getCardList();
    result = true;

    } catch (e) {
      print(e);
      result = false;
    }
    return result;
  }

  publicScanAddToCart(cartItem) async {
    var processData = false;
    if(showScanCartItems.value.length>0){
      for(var i=0;i<showScanCartItems.value.length;i++){
        if(cartItem['menuCode'] == showScanCartItems.value[i]['menuCode']){
          showScanCartItems.value[i]["goodsNum"]++;
          showScanCartItems.value[i]["currentPrice"] = showScanCartItems.value[i]["currentPrice"]+cartItem["unitPrice"];
          processData = true;
          break;
        }
      }
    }

    if(processData == false){
      var queryResult = await ordersqlcontroller.getCartItemNewId(cartItem['menuCode']);
      cartItem["id"] = queryResult;
      showScanCartItems.value.add(cartItem);

    }

    //scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (itemscrollController.hasClients) {
        itemscrollController.animateTo(
          itemscrollController.position.maxScrollExtent+200,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
    // itemscrollController.animateTo(
    //   itemscrollController.position.maxScrollExtent,
    //   duration: Duration(milliseconds: 200),
    //   curve: Curves.easeOut,
    // );
  }

  //公共购物车加减
  publicChangeCartMenuCount(cartItem, index, changeType) async {
    var result;
    try {
      if(changeType == 'add'){
        if(cartItem['qtyBounds'] >0){
          var checkresult = await ordersqlcontroller.getCartItemNum(cartItem['menuCode']);
          if(checkresult>=cartItem['qtyBounds']){
            var showString = "show_storage_num_error".tr;
            //showToast("${showString}");
            Get.dialog(
                DialogUtils.alertOneButton(showString,
                    title: "tag_title".tr,
                    confirmtitle: "tag_button_yes".tr,
                    confirm: () {
                      Get.back();
                    })
            );
            return;
          }else{
            result = await ordersqlcontroller.addToCartNum(cartItem);
          }
        }else if(cartItem['qtyBounds'] <0){
          result = await ordersqlcontroller.addToCartNum(cartItem);
        }

        showScanCartItems.value[index]["goodsNum"]++;
        showScanCartItems.value[index]["currentPrice"] = showScanCartItems.value[index]["currentPrice"]+cartItem["unitPrice"];

      }else{
        result = await ordersqlcontroller.reduceToCart(cartItem);

        showScanCartItems.value[index]["goodsNum"]--;
        showScanCartItems.value[index]["currentPrice"] = showScanCartItems.value[index]["currentPrice"]-cartItem["unitPrice"];
      }

      //ordersqlcontroller.getCardList();


    } catch (e) {
      print(e);
      result = 0;
    }

    return result;
  }

  deleteScanCartItems(index){
    showScanCartItems.value.removeAt(index);
    update();
  }

  clearCartList({hideLoading = true}) {
    ordersqlcontroller.removeAllFromCart();
    ordersqlcontroller.getCardList();
    showScanCartItems.value = [];
    getCartPriceTotal(hideLoading: hideLoading);
  }

  gotoLanguageHome(){
    clearCartList();
    //getBookingBootMenu();
    //Future.delayed(Duration(milliseconds: 100),() async {
    Get.back();
    //});
  }


  playQRScannerSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/14428.wav"),
      autoStart: true,
      volume: 0.3,
    );
  }

  //购物车
  getItemTotal(List items) {
    num sum = 0;
    items.forEach((e) {
      sum += e.currentPrice;
    });

    return sum.toString();
  }

  //提交订单
  doSubmitOrder({int times= 0}) async {
    if(machineInfo.machineCode !=""){
      showOrderEasyLoading();

      //自定义声音
      playQRScannerSound();

      var cartItems = ordersqlcontroller.getcartItems;
      List selectedItem = [];


      for(var oneItem in cartItems){
        var optionMap = {};
        if(oneItem["optionGroupVoList"] == ""){
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "qty": oneItem["goodsNum"]
          };
        }else{
          var optionGroupVoList = oneItem["optionGroupVoList"];
          var itemsOption = optionGroupVoList.split(',');
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "optionList": itemsOption,
            "qty": oneItem["goodsNum"]
          };
        }
        selectedItem.add(optionMap);
      }
      var orderTotlaPrice = getItemTotal(ordersqlcontroller.cartItems);
      var formData = {
        "language": checkLanguage.value,
        "machineCode": machineInfo.machineCode,
        "orderLineList": selectedItem,
        "total": orderTotlaPrice,
        //"takeout": (_dining_type == "2") ? true: false,
        "takeout": true,//machineInfo.mealType,
      };
      request('webBootOrder',
          method: 'POST',
          parameters: formData,
          timeout: const Duration(seconds: 30)
      ).then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();

        if (response['code'] == 200) {
          //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc
          doSubmitOrderId.value = response['data']["orderId"];
          //shopCartTotalPrice.value = response['data']["total"].toString();
          final total = response['data']["total"].toString();
          int tax1 = response['data']["tax1"] ?? 0;
          int tax2 = response['data']["tax2"] ?? 0;

          showSelectMealTypeAndPaymentMethodDialog(total, tax1: tax1, tax2: tax2);
        }else{
          Get.dialog(
              DialogUtils.alertOneButton(response['data']["message"],
                  title: "tag_title".tr,
                  confirmtitle: "tag_button_yes".tr,
                  confirm: () {
                    Get.back();
                  })
          );
        }
      }).catchError((e) {
        _handleOrderResultAlert(times: times);
      });
    }
  }

  _handleOrderResultAlert({int times= 0}) {
    EasyLoading.dismiss();
    if (times > 2) {
      Get.dialog(
          DialogUtils.alertOneButton("order_network_error".tr,
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr,
              confirm: () {
                Get.back();
                // FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
                //   "machineCode": machineInfo.machineCode,
                // });
              })
      );
      return;
    }

    Get.dialog(
        DialogUtils.alert("show_order_error".tr,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
              Get.back();
              doSubmitOrder(times: times + 1);
            },
            cancle: () {
              Get.back();
              //clearCartList();
              // FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
              //   "machineCode": machineInfo.machineCode,
              // });
            }
        )
    );
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog(String total, {int tax1 = 0, int tax2 = 0}) async {
    machineInfo.showReceiptPage = machineInfo.isReceiptPageShow;
    Get.to(
            () =>
            SelectPaymentPage(
                checkLanguage: checkLanguage.value,
                menuCount: showCartTotalGoodsNum.value,
                tax10: tax1,
                tax8: tax2,

                shopCartTotalPrice: total,
            tableNum: "",
            onConfrimClick: () {
                showOpenPayment.value = true;
                machineInfo.showReceiptPage = true;
                gotoSettlement(total, tax1 + tax2);

            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                CancelOrder();
              }
            }
        ),
        transition: Transition.fadeIn,
        fullscreenDialog: true,
        opaque: false,
    );
  }

  postNewOrderId() {

    var formData = {
      "orderId": doSubmitOrderId.value,
      "machineCode": machineInfo.machineCode,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

        doSubmitOrderId.value = response['data']["orderId"];

      }else{

        //showToast(response['data']["message"]);
        Get.dialog(
            DialogUtils.alertOneButton(response['data']["message"],
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr,
                confirm: () {
                  Get.back();
                })
        );

      }
    });


  }


  gotoSettlement(String total, int tax) async {
    await Get.toNamed('/settlement',preventDuplicates: false,
        arguments: {
          "checkLanguage":  checkLanguage.value,
          "machineCode":  machineInfo.machineCode,
          "orderId" : doSubmitOrderId.value,
          "totalPrice" : total,
          "machineMode":"1",
          "showOpenPayment":showOpenPayment.value
        });
  }

  CancelOrder() {
    var formData = {
      "machineCode": machineInfo.machineCode,
      "orderId": doSubmitOrderId.value,
      "model": "0",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);

  }

}
