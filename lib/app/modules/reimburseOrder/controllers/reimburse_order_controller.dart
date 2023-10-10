import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';

import '../../../config/imageData.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/cashMoneyParser.dart';
import '../../../widget/DialogUtils.dart';

class ReimburseOrderController extends GetxController with StateMixin {
  //TODO: Implement ReimburseOrderController
  TextEditingController orderIdController=TextEditingController();

  RxString machineCode = "".obs;
  RxString reimburseText = "请输入六位注文番号".obs;
  RxList orderList = [].obs;
  RxMap refundInfo = {}.obs;

  Timer? allowtimer;
  Timer? stoptimer;
  Timer? outmoneytimer;
  Timer? OutMoneytimer;
  Timer? endtimer;

  RxString allowStatus = "".obs;
  RxString stopStatus = "".obs;
  RxString outStatus = "".obs;
  RxString endStatus = "".obs;

  //60秒内未接收现金机正确通知，则进行下一步操作
  Timer? showCashTimer;
  RxInt seconds = 60.obs;
  RxBool getOutMoneyString = true.obs; //是否允许获取出金金额字符串
  RxBool isReportOutMoney = false.obs; //新处理
  RxBool isReportCash = false.obs; //是否已汇报过现金
  RxString currencyString = "".obs; // 出金币种

  RxString isAllowPos = "0".obs; //1 使用信用卡刷卡  0 不可使用
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;
  Socket? _socket; //socket对象
  RxBool socketState = false.obs; //连接状态
  RxString eventReportString = "".obs;

  RxInt socketNumberTimes = 0.obs;


  @override
  void onInit() {
    machineCode.value = Get.arguments['machineCode'];
    _getSystemSettingInfo();
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

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    isAllowPos.value = systemSettingInfo['isAllowPos'];
    _getPosSettingInfo();

  }

  _getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    if(posSettingInfo.isNotEmpty){
      pos_ip.value = posSettingInfo['posIp'];
      pos_port.value = posSettingInfo['posPort'];
    }


    update();
    change(null, status: RxStatus.success());
  }


  queryOrder(){
    if(orderIdController.text == ""){
      update();
      return;
    }
    var formData = {
      "machineCode": machineCode.value,
      "orderIdStr": orderIdController.text,
    };print(formData);
    request('webBootReimburseQuery', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
LogUtil.d(response);
      if (response['code'] == 200 && response['data'] !=null) {

        orderList.value = response['data'];
        //print(orderId.value);
        //goToSettlement();
      }

      update();
    });


  }

  refoundOrderAlert(orderinfo){
    Get.dialog(
        DialogUtils.alert("确定要取消该笔订单么？",
            title: "お知らせ",
            canceltitle: "いいえ",
            confirmtitle: "はい",
            confirm: () {
              Get.back();
              refundInfo.value = orderinfo;
              refoundOrder();
            },
            cancle: () {
              Get.back();
            }),
        barrierDismissible: false
    );
  }

  refoundOrder() async {
    if(refundInfo.value["payChannel"] =="Cash"){
      showPosEasyLoading();
      String strartPayCube = await Paycube.strartRefundPayCube;
      //调用插件的监听
      Paycube.getPayCubeListener();
      startOutPutMoney(refundInfo.value["amount"]);

    }else if(
      refundInfo.value["payChannel"] =="Alipay" ||
      refundInfo.value["payChannel"] =="Wechat" ||
      refundInfo.value["payChannel"] =="PayPay"
    ){
      showPosEasyLoading();
      refundScanCodePay();
    }
  }

  refundScanCodePay(){
    var formData = {
      "machineCode": machineCode.value,
      "orderId": refundInfo.value["orderId"],
    };print("webBootReimburseExecute==${formData}");
    request('webBootReimburseExecute', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());LogUtil.d("webBootReimburseExecute===${response}");
      if(response['code'] == 200 && (response['data']["payChannel"] =="Alipay" || response['data']["payChannel"] =="Wechat" || response['data']["payChannel"] =="PayPay") && response['data']["executeMark"] == true){
        EasyLoading.dismiss();

        Get.dialog(
            DialogUtils.alertOneButton("退款成功",
                title: "お知らせ",
                confirmtitle: "はい",
                confirm: () {
                  orderIdController.text = "";
                  orderList.value = [];
                  refundInfo.value = {};
                  queryOrder();
                  Get.back();
                  update();
                }),
            barrierDismissible: false
        );

      }else if(response['code'] == 200 && response['data']["payChannel"] =="PayPay" && response['data']["executeMark"] == false && response['data']["requestMessage"] !=""){
        //showPosEasyLoading();
        payconnectSocker(questData: response['data']["requestMessage"]);
      }else{
        Get.dialog(
            DialogUtils.alertOneButton("退款失败",
                title: "お知らせ",
                confirmtitle: "はい",
                confirm: () {
                  //orderIdController.text = "";
                  //queryOrder();
                  Get.back();
                }),
            barrierDismissible: false
        );
      }
    });
  }

  //pos机相关
  showPosEasyLoading() {
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 0,),//_showTag
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

  payconnectSocker({questData=""}) async {

    //判断socket请求次数
    socketNumberTimes.value++;
    if(socketNumberTimes.value>20){
      Get.dialog(
          DialogUtils.alertOneButton("セルフレジは端末に接続されてません、スタフに聞いてお願いします。",
              title: "お知らせ",
              confirmtitle: "はい",
              confirm: () {
                Get.back();
              })
      );
      return;
    }

    Socket.connect(
      pos_ip.value,
      int.parse(pos_port.value),
      //timeout: Duration(seconds: 5),
    ).then((Socket socket) {
      print("连接成功了么");
      this._socket = socket;

      //扫码过来的，请求数据不为空时候发送POS请求
      if(questData!=""){
        //判断不为空则POS机
        this._socket?.write(questData);
      }


      // 监听wifi模块发送的数据
      this._socket?.listen((List<int> event) {
        LogUtil.d(event);
        //if (event.length > 40) event.fillRange(266, 289, 32);
        for(var i=0; i< event.length; i++){
          if(event[i] >127){
            event[i] = 32;
            //print(i);
          }
        }
        var zhuanhuan = Uint8List.fromList(event);
        var eventString = Utf8Codec().decode(zhuanhuan);
        eventReportString.value += eventString;
        LogUtil.d(eventString);
        //print(Utf8Codec().decode(zhuanhuan));
        //print("event=====${eventString}=====");
        String FirstString = eventReportString.value.substring(0, 1);
        String SecondString = eventReportString.value.substring(1, 3);
        String transaction_type = eventReportString.value.substring(3, 6);
        String resultString = eventReportString.value.substring(10, 13);
        String resultMPFSString = eventReportString.value.substring(13, 16);
        print("FirstString==${FirstString}");
        print("SecondString==${SecondString}");
        print("transaction_type==${transaction_type}");
        print("resultString==${resultString}");
        print("resultMPFSString==${resultMPFSString}");
        //支付成功 打印，返回首页 除了成功都取消
        if (transaction_type == "900") {
          if (FirstString == "3" && SecondString == "11" && resultString == "000") {print("进来取消了");
          //CancelOrder();
          //showEasyLoading();
          }else if(resultString.trim() != ""){

            //T10 交通系等待时间超过30-40后自动返回
            //06 需要密码但是不输入密码直接点击屏幕返回  需要弹框文字
            var posErrorCode = ["L06"];
            if (posErrorCode.contains(resultString) == true) {
              //_showPosCancelEasyLoading(resultString);
              /*Future.delayed(Duration(milliseconds: 2500),() async {
                CancelOrder();
              });*/
            }
          }
        }else if ((transaction_type == "600" || transaction_type == "601") && eventReportString.value.length >4800) {
          if (FirstString == "3" && SecondString == "11" && resultString == "000" &&  resultMPFSString == "000") {// &&  resultMPFSString == "000"
            reportChange(eventReportString.value);

          } else {
            EasyLoading.dismiss();
            if(resultString.trim() != ""){

              Get.dialog(
                  DialogUtils.alertOneButton("決済失敗ので、別の支払方法にて取引を実施してください。",
                      title: "お知らせ",
                      confirmtitle: "はい",
                      confirm: () {

                        Get.back();

                      })
              );
            }
          }
        }else if (transaction_type != "900" &&transaction_type != "600" && transaction_type != "601") {
          if (FirstString == "3" && SecondString == "11" && resultString == "000" &&  resultMPFSString == "000") {// &&  resultMPFSString == "000"
            String reportString = eventString.substring(0, 169);
            reportChange(reportString);

          } else {
            EasyLoading.dismiss();
            if(resultString.trim() != ""){

              Get.dialog(
                  DialogUtils.alertOneButton("決済失敗ので、別の支払方法にて取引を実施してください。",
                      title: "お知らせ",
                      confirmtitle: "はい",
                      confirm: () {

                        Get.back();

                      })
              );
            }
          }
        }
      },
        onDone: () {
          socketState.value = false;
          print("pos机done了");
        },
        onError: (e) {
          socketState.value = false;
          print("pos机错误了");
          //_close();
        },
      );

      socketState.value = true;

    }).catchError((e) {

      socketState.value = false;

      print("Unable to connect: $e");
      print("POS机连接${socketNumberTimes.value}");
      Future.delayed(Duration(milliseconds: 400), () async {
        payconnectSocker(questData:questData);
      });
      //_showScanCodeNoOpenDialog(3,GString.getToString(checkLanguage.value, "settlement_posPay_connect_error"),payType: "pos");
    });

  }

  //倒计时
  _countDownTimer(stepState) {
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds.value--;

      if (this.seconds == 0) {
        //如果60秒未接收返回正确通知，则进行下一步操作
        //eventBus.fire(new setShowCashEvent('支付成功...'));
        showCashTimer?.cancel(); //清除定时器

      }
    });
  }

  //现金机开始 开始出金 -交易终了
  startOutPutMoney(outMoney) async {
    var outStringMoney = outMoney.toString();
    await Paycube.setReceiveEvent;

    String outResult = await Paycube.outPayCubeMoney(outStringMoney);
    _countDownTimer("6");

    outmoneytimer?.cancel();
    outmoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outmoneyt) async {
      outStatus.value = await Paycube.getPayCubeOutMoneyStatus;print("outStatus.value${outStatus.value}");
      // 循环一定要记得设置取消条件，手动取消
      if (outStatus.value == "OutSuccess") {
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 180;
        //如果取消不汇报，则出金后直接关闭 ？？？？？？
        _getPayCubeOutMoney();

        outmoneyt?.cancel();
      } else if (outStatus.value == "Error-A0--02" || outStatus.value == "Error") {

      } else {
        await Paycube.outPayCubeMoney(outStringMoney);
      }
    });
  }

  _getPayCubeOutMoney() async {print("进来获取出金币种了么？");
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    OutMoneytimer?.cancel();
    await Paycube.setReceiveEvent;
    _countDownTimer("7");

    var queryTimes = 0;
    // 循环一定要记得设置取消条件，手动取消
    //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;

    OutMoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outMoneyTime) async {

      if(getOutMoneyString.value == true){
        // 循环一定要记得设置取消条件，手动取消
        String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;
        if (currencyStringresult.trim().length > 50) {
          var outtotalAmount = MoneyParser.calculateTotalAmount(currencyStringresult.trim());
          //print("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
          //print("计算现金机出金金额与实际投入是否相等${currencyStringresult}");

          if(outtotalAmount == refundInfo.value["amount"]){
            //如果打开了现金机，则去掉倒计时监听
            showCashTimer?.cancel();
            seconds.value = 180;
            currencyString.value = currencyStringresult;
            getOutMoneyString.value == false;

            OutMoneytimer?.cancel();

            payCubeCloseTransaction(currencyStringresult);
          }

        }
      }
      queryTimes++;
    });
  }

  //汇报出金币种,请求后台
  reportChange(changeString) {
    if(isReportCash.value == true){print("已汇报过");
    return;
    }

    isReportCash.value = true;

    var formData = {
      "responseMessage": changeString,
      "machineCode": machineCode.value,
      "orderId": refundInfo.value["orderId"],
    };print("webBootToReportV1==${formData}");
    request('webBootReimburseNotify', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());print(response);
      EasyLoading.dismiss();
      if(response['code'] == 200 && response['data'] == true){
        Get.dialog(
            DialogUtils.alertOneButton("退款成功",
                title: "お知らせ",
                confirmtitle: "はい",
                confirm: () {
                  orderIdController.text = "";
                  orderList.value = [];
                  refundInfo.value = {};
                  queryOrder();
                  Get.back();
                }),
            barrierDismissible: false
        );

      }
    });

  }

  payCubeCloseTransaction(cashOutString) async {
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    //开启倒计时
    _countDownTimer("5");
    await Paycube.setReceiveEvent;
    endtimer?.cancel();
    endtimer = Timer.periodic(Duration(milliseconds: 250), (Timer endtradet) async {
      endStatus.value = await Paycube.getPayCubeEndTradeStatus;print("endStatus.value==${endStatus.value}");
      // 循环一定要记得设置取消条件，手动取消 || _endStatus == "Error-A0--02"
      if (endStatus.value == "EndSuccess") {
        showCashTimer?.cancel();
        seconds.value = 180;
        print("退款成功");
        reportChange(cashOutString);
        endtradet.cancel();
      }else {
        //sleep(Duration(milliseconds: 200));
        await Paycube.endTrade;
      }
    });
  }




}
