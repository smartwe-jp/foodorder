import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';

class SelfCheckoutscanningcodeController extends GetxController with StateMixin {
  //TODO: Implement SelfCheckoutscanningcodeController
  OrderSqlController ordersqlcontroller = Get.find<OrderSqlController>();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode(debugLabel: 'TextField');

  ScrollController itemscrollController = ScrollController();

  //默认语言包选择
  RxString checkLanguage = "JP".obs;
  RxString machineCode = "".obs;
  RxBool mealType = false.obs;//用于判断下单

  RxList showCartItems = [].obs;
  RxList showScanCartItems = [].obs;
  RxMap showItem = {}.obs;
  RxString shopCartTotalPrice = "0".obs;
  RxInt showCartTotalGoodsNum = 0.obs;

  RxString isAllowPos = "0".obs; //1 使用信用卡刷卡  0 不可使用
  RxString isAllowReceipt = "2".obs; //1 直接打印領収書  ２ 实现打印領収書菜单
  RxString receiptPrintType = "2".obs; //1 打印領収書  ２ 不打印領収書
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
  RxBool showDiscover = false.obs;

  RxString doSubmitOrderId = "".obs;

  final player = AudioPlayer();

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

  readyQueryData(){
    checkLanguage.value = Get.arguments['checkLanguage'];
    mealType.value = (Get.arguments["mealType"]!=null)?Get.arguments["mealType"]:false;
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
    isAllowReceipt.value = systemSettingInfo['isAllowReceipt'];
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
    showDiscover.value = systemSettingInfo['show_discover'];

    getCartPriceTotal(); //新版新获取分类
  }

  getCartPriceTotal() async {
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
    _resetScanQrCode();
    scrollToBottom();
  }

  _resetScanQrCode(){
    scanQrCodeController.text = "";
    //所有流程执行完成后才能获取焦点
    scanQrCodeFocusNode.requestFocus();
    EasyLoading.dismiss();
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
        "machineCode": machineCode.value,
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
          _resetScanQrCode();
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
            var showString = GString.getToString(checkLanguage.value,"show_storage_num_error");
            //showToast("${showString}");
            Get.dialog(
                DialogUtils.alertOneButton(showString,
                    title: GString.getToString(checkLanguage.value, "tag_title"),
                    confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
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

  clearCartList() {
    ordersqlcontroller.removeAllFromCart();
    ordersqlcontroller.getCardList();
    showScanCartItems.value = [];
    getCartPriceTotal();
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
  doSubmitOrder(){
    if(machineCode.value !=""){
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
        "machineCode": machineCode.value,
        "orderLineList": selectedItem,
        "total": orderTotlaPrice,
        //"takeout": (_dining_type == "2") ? true: false,
        "takeout": mealType.value,
      };
      request('webBootOrder', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();

        if (response['code'] == 200) {
          //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc

          doSubmitOrderId.value = response['data']["orderId"];
          shopCartTotalPrice.value = response['data']["total"].toString();

          //只有现金，并且其余都为false的时候，直接跳转支付
          // if(showCash.value == true &&
          //     isAllowPos.value == "0" &&
          //     showAlipay.value == false &&
          //     showWechat.value == false &&
          //     showPayPay.value == false
          // ){
          //   payment_method_num.value = "1";
          //   //postNewOrderId();
          //   gotoSettlement();
          // }else{
          //   showSelectMealTypeAndPaymentMethodDialog();
          // }
          showSelectMealTypeAndPaymentMethodDialog();


        }else{
          //getBookingBootMenu();
          //menuLackMap.value = response['data']["menuLackMap"];
          //showToast(response['data']["message"]);
          Get.dialog(
              DialogUtils.alertOneButton(response['data']["message"],
                  title: GString.getToString(checkLanguage.value, "tag_title"),
                  confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
                  confirm: () {
                    Get.back();
                  })
          );
        }
      });
    }
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog() async {
    Get.dialog(
        SelectPaymentPage(
            checkLanguage: checkLanguage.value,
            menuCount: showCartTotalGoodsNum.value,
            //mealType:_mealType.value,
            isAllowPos:isAllowPos.value,
            isAllowReceipt: isAllowReceipt.value,
            payment_method_num:payment_method_num.value,
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
            shopCartTotalPrice:shopCartTotalPrice.value,
            tableNum: "",
            onConfrimClick: (String isAllowPosString, String payment_method_num_string, String receiptPrintTypeString) {

              isAllowPos.value = isAllowPosString;
              payment_method_num.value = payment_method_num_string;
              receiptPrintType.value = receiptPrintTypeString;
              showOpenPayment.value = true;
              //230629点击弹出支付方式后，需要重新请求下后台获得orderid

              var paymentMethod = ["3","4","5","6","7","8","9","10"];
              if (paymentMethod.contains(payment_method_num.value) == true) {
                _getPosSettingInfo();
              }else{
                //postNewOrderId();
                gotoSettlement();
              }

            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                CancelOrder();
              }
            }
        )
    );
  }

  postNewOrderId() {

    var formData = {
      "orderId": doSubmitOrderId.value,
      "machineCode": machineCode.value,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

        doSubmitOrderId.value = response['data']["orderId"];

      }else{

        //showToast(response['data']["message"]);
        Get.dialog(
            DialogUtils.alertOneButton(response['data']["message"],
                title: GString.getToString(checkLanguage.value, "tag_title"),
                confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
                confirm: () {
                  Get.back();
                })
        );

      }
    });


  }

  _getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    pos_ip.value = posSettingInfo['posIp'];
    pos_port.value = posSettingInfo['posPort'];
    //postNewOrderId();
    gotoSettlement();
  }


  gotoSettlement() async {
    await Get.toNamed('/settlement',preventDuplicates: false,
        arguments: {
          "checkLanguage":  checkLanguage.value,
          "machineCode":  machineCode.value,
          "orderId" : doSubmitOrderId.value,
          "totalPrice" : shopCartTotalPrice.value,
          "machineMode":"1",
          "isAllowPos":isAllowPos.value,
          "receiptPrintType": receiptPrintType.value,
          "posIp":pos_ip.value,
          "posPort":pos_port.value,
          "paymentMethod":payment_method_num.value,
          "showWechat": showWechat.value,
          "showAlipay": showAlipay.value,
          "showPayPay": showPayPay.value,
          "showCreditCard":showCreditCard.value,
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
          "showOpenPayment":showOpenPayment.value
        });
  }

  CancelOrder() {
    var formData = {
      "machineCode": machineCode.value,
      "orderId": doSubmitOrderId.value,
      "model": "0",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);

  }

}
