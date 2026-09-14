import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/reimburseOrder/controllers/reimburse_order_controller_extension.dart';
import 'package:foodorder/app/modules/settlement/views/receipt_constrained_box.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../../../config/imageData.dart';
import '../../../plugins/flutter_plugin_msprinter/lib/flutter_plugin_msprinter.dart';
import '../../../controllers/app_config.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/cashMoneyParser.dart';
import '../../../services/payment_event_codes.dart';
import '../../../widget/DialogUtils.dart';
import '../views/reimbruse_order_print_view.dart';

part 'reimburse_order_monitoring.dart';

class ReimburseOrderController extends GetxController with StateMixin {
  //TODO: Implement ReimburseOrderController
  TextEditingController orderIdController = TextEditingController();
  AppConfig appConfig = Get.find();
  get payCube => appConfig.payCube;
  MachineInfoController machineInfo = Get.find();

  RxString reimburseText = "注文番号の後ろ六桁を入力してください".obs;
  RxList orderList = [].obs;
  RxMap refundInfo = {}.obs;
  RxString printLogoImage = "".obs;

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
  RxString checkLanguage = "JA".obs;

  RxInt socketNumberTimes = 0.obs;
  RxMap usbDevice = {}.obs;

  late ReimbursePrintView reimbursePrintView;
  late Size reimbursePrintViewSize;
  _RefundEventState _refundEventState = _RefundEventState();

  String get machineCode {
    return machineInfo.machineCode;
  }

  double get printWidth {
    if (Platform.isWindows) {
      return 530;
    } else {
      return appConfig.isAndroid11 ? 513 : 385;
    }
  }

  @override
  void onInit() {
    checkLanguage.value = Get.locale?.languageCode.toUpperCase() ?? "JA";
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
    usbDevice.value = await HomeServices.getUsbPrintSettingInfo();
    //Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    isAllowPos.value = machineInfo.isAllowPos;
    printLogoImage.value = machineInfo.printLogoImageUrl;
    _getPosSettingInfo();
    //_getPrintLogoImageData();
  }

  _getPosSettingInfo() async {
    // Map posSettingInfo = await HomeServices.getPosSettingInfo();
    // if(posSettingInfo.isNotEmpty){
      pos_ip.value = machineInfo.pos_ip;
      pos_port.value = machineInfo.pos_port;
    //}

    update();
    change(null, status: RxStatus.success());
  }

  queryOrder() {
    if (orderIdController.text == "") {
      update();
      return;
    }
    var formData = {
      "machineCode": machineCode,
      "orderIdStr": orderIdController.text,
    };
    request('webBootReimburseQuery', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
      logI("查询订单信息：${response}");
      if (response['code'] == 200 &&
          response['data'] != null &&
          response['data'].length > 0) {
        orderList.value = response['data'];
        //print(orderId.value);
        //goToSettlement();
      } else {
        logI("查询订单为空");
        noOrderAlsert("注文が見つかりませんでした。注文番号を確認してください。");
      }

      update();
    }).onError((error, stackTrace) {
      logI("查询订单信息失败：${error}");
       noOrderAlsert("注文が見つかりませんでした。注文番号を確認してください。error:${error}");
    });
  }

  noOrderAlsert(String message) {
    if (EasyLoading.isShow)
      EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alertOneButton(message,
            title: "お知らせ", confirmtitle: "はい", confirm: () {
          orderIdController.text = "";
          orderList.value = [];
          refundInfo.value = {};
          queryOrder();
          Get.back();
          update();
        }),
        barrierDismissible: false);
  }

  refoundOrderAlert(orderinfo, refoundView, viewSize) {
    reimbursePrintView = refoundView;
    reimbursePrintViewSize = viewSize;
    Get.dialog(
        DialogUtils.alert("この注文をキャンセルして返金しますか？",
            title: "お知らせ",
            canceltitle: "いいえ",
            confirmtitle: "はい", confirm: () async {
          Get.back();
          refundInfo.value = orderinfo;
          await refoundOrder();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  refoundOrder() async {
    startRefundMonitoring();
    if (refundInfo.value["payChannel"] == "Edy") {
      monitorRefundStageFailed(
        'refund_validation',
        PaymentEventCode.refundExecuteFailed,
        'Edy refund is not supported',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_validation',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      refundFailedAlert();
    } else if (refundInfo.value["payChannel"] == "Cash") {
      showPosEasyLoading();
      if (Platform.isAndroid) {
        monitorRefundStageStarted(
          'cash_device_prepare',
          PaymentEventCode.refundDeviceStarted,
          'PayCube refund preparation started',
          data: const <String, Object?>{'cash_device': 'paycube'},
        );
        try {
          String strartPayCube = await payCube.strartRefundPayCube;
          logI("调用插件的监听结果:${strartPayCube}");
          monitorRefundStageSucceeded(
            'cash_device_prepare',
            PaymentEventCode.refundDeviceSucceeded,
            'PayCube refund preparation completed',
            data: <String, Object?>{
              'cash_device': 'paycube',
              'device_result': strartPayCube,
            },
          );
          //调用插件的监听
          payCube.getPayCubeListener();
          _setPayCubeListener();
        } catch (error, stackTrace) {
          monitorRefundStageFailed(
            'cash_device_prepare',
            PaymentEventCode.refundDeviceFailed,
            'PayCube refund preparation failed',
            failureType: PaymentFailureType.deviceRejected,
            critical: true,
            error: error,
            stackTrace: stackTrace,
            data: const <String, Object?>{'cash_device': 'paycube'},
          );
          monitorRefundFlowFailed(
            failedStage: 'cash_device_prepare',
            failureType: PaymentFailureType.deviceRejected,
            error: error,
            stackTrace: stackTrace,
          );
          cashErrorHandle();
          return;
        }
      }

      startOutPutMoney(refundInfo["amount"]);
    } else if (refundInfo["payChannel"] == "CreditCard") {
      showPosEasyLoading();
      refundCreditCard();
    } else {
      showPosEasyLoading();
      refundScanCodePay();
    }
  }

  refundCreditCard() {
    monitorRefundStageStarted(
      'refund_execute',
      PaymentEventCode.refundExecuteStarted,
      'Credit card refund request started',
    );
    var formData = {
      "machineCode": machineCode,
      "orderId": refundInfo["orderId"],
    };
    request('webBootReimburseExecute', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());
      final responseData = response['data'];
      final refundData = responseData is Map
          ? responseData
          : const <dynamic, dynamic>{};
      if (response['code'] == 200 &&
          refundData["executeMark"] == true &&
          refundData["requestMessage"] != "") {
        monitorRefundStageSucceeded(
          'refund_execute',
          PaymentEventCode.refundExecuteSucceeded,
          'Credit card refund request accepted',
          data: const <String, Object?>{'requires_pos': true},
        );
        payconnectSocker(questData: refundData["requestMessage"]);
      } else {
        monitorRefundStageFailed(
          'refund_execute',
          PaymentEventCode.refundExecuteFailed,
          'Credit card refund request was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: true,
          data: <String, Object?>{'response_code': response['code']},
        );
        monitorRefundFlowFailed(
          failedStage: 'refund_execute',
          failureType: PaymentFailureType.backendRejected,
        );
        refundFailedAlert();
      }
    }).onError((error, stackTrace) {
      logI("信用卡退款请求失败：${error}");
      monitorRefundStageFailed(
        'refund_execute',
        PaymentEventCode.refundExecuteFailed,
        'Credit card refund request failed',
        failureType: PaymentFailureType.network,
        critical: true,
        error: error,
        stackTrace: stackTrace,
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_execute',
        failureType: PaymentFailureType.network,
        error: error,
        stackTrace: stackTrace,
      );
      refundFailedAlert();
    });
  }

  refundScanCodePay() {
    monitorRefundStageStarted(
      'refund_execute',
      PaymentEventCode.refundExecuteStarted,
      'QR refund request started',
    );
    var formData = {
      "machineCode": machineCode,
      "orderId": refundInfo["orderId"],
    };
    request('webBootReimburseExecute', method: 'POST', parameters: formData)
        .then((value) {
      EasyLoading.dismiss();
      var response = json.decode(value.toString());
      final responseData = response['data'];
      final refundData = responseData is Map
          ? responseData
          : const <dynamic, dynamic>{};
      if (response['code'] == 200 &&
          refundData["executeMark"] == true &&
          refundData["requestMessage"] == "") {
        monitorRefundStageSucceeded(
          'refund_execute',
          PaymentEventCode.refundExecuteSucceeded,
          'QR refund completed by backend',
          data: const <String, Object?>{'requires_pos': false},
        );
        monitorRefundFlowSucceeded(completionStage: 'refund_execute');
        EasyLoading.dismiss();
        printReimburseReceipt(reimbursePrintViewSize, reimbursePrintView); //打印
        Get.dialog(
            DialogUtils.alertOneButton("返金成功",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              orderIdController.text = "";
              orderList.value = [];
              refundInfo.value = {};
              queryOrder();
              Get.back();
              update();
            }),
            barrierDismissible: false);
      } else if (response['code'] == 200 &&
          refundData["executeMark"] == false &&
          refundData["requestMessage"] != "") {
        monitorRefundStageSucceeded(
          'refund_execute',
          PaymentEventCode.refundExecuteSucceeded,
          'QR refund request requires POS processing',
          data: const <String, Object?>{'requires_pos': true},
        );
        //showPosEasyLoading();
        payconnectSocker(questData: refundData["requestMessage"]);
      } else if (response['code'] == 200 &&
          refundData["executeMark"] == true &&
          refundData["requestMessage"] != "") {
        monitorRefundStageSucceeded(
          'refund_execute',
          PaymentEventCode.refundExecuteSucceeded,
          'QR refund request accepted for POS completion',
          data: const <String, Object?>{'requires_pos': true},
        );
        //showPosEasyLoading();
        payconnectSocker(questData: refundData["requestMessage"]);
      } else {
        monitorRefundStageFailed(
          'refund_execute',
          PaymentEventCode.refundExecuteFailed,
          'QR refund request was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: true,
          data: <String, Object?>{'response_code': response['code']},
        );
        monitorRefundFlowFailed(
          failedStage: 'refund_execute',
          failureType: PaymentFailureType.backendRejected,
        );
        refundFailedAlert();
      }
    }).onError((error, stackTrace) {
      logI("扫码支付退款请求失败：${error}");
      monitorRefundStageFailed(
        'refund_execute',
        PaymentEventCode.refundExecuteFailed,
        'QR refund request failed',
        failureType: PaymentFailureType.network,
        critical: true,
        error: error,
        stackTrace: stackTrace,
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_execute',
        failureType: PaymentFailureType.network,
        error: error,
        stackTrace: stackTrace,
      );
      refundFailedAlert();
    });
  }

  //refund failed alert
  refundFailedAlert() {
    if (EasyLoading.isShow)
      EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alertOneButton("返金失敗です。他の方法で返金を試してください",
            title: "お知らせ", confirmtitle: "はい", confirm: () {
          //orderIdController.text = "";
          //queryOrder();
          Get.back();
        }),
        barrierDismissible: false);
  }

  hadRefundAlert() {
    if (EasyLoading.isShow)
      EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alertOneButton("指定した取引は既に取消されています。",
            title: "お知らせ", confirmtitle: "はい", confirm: () {
          orderIdController.text = "";
          orderList.value = [];
          refundInfo.value = {};
          queryOrder();
          Get.back();
          update();
        }),
        barrierDismissible: false);
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
            Container(
              height: 0,
            ), //_showTag
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

  payconnectSocker({questData = ""}) async {
    //判断socket请求次数
    socketNumberTimes.value++;
    if (socketNumberTimes.value == 1) {
      monitorRefundStageStarted(
        'refund_pos_connect',
        PaymentEventCode.refundDeviceStarted,
        'Refund POS connection started',
        data: <String, Object?>{'attempt': socketNumberTimes.value},
      );
    }
    if (socketNumberTimes.value > 20) {
      monitorRefundStageFailed(
        'refund_pos_connect',
        PaymentEventCode.refundDeviceFailed,
        'Refund POS connection failed after retries',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
        data: <String, Object?>{'attempts': socketNumberTimes.value - 1},
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_pos_connect',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      socketNumberTimes.value = 0;
      EasyLoading.dismiss();
      Get.dialog(
        DialogUtils.alertOneButton("セルフレジは端末に接続されてません、スタフに聞いてお願いします。",
            title: "お知らせ", confirmtitle: "はい", confirm: () {
          Get.back();
        }),
      );
      return;
    }

    final port = int.tryParse(pos_port.value);
    if (pos_ip.value.trim().isEmpty || port == null) {
      monitorRefundStageFailed(
        'refund_pos_connect',
        PaymentEventCode.refundDeviceFailed,
        'Refund POS settings are invalid',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
        data: <String, Object?>{
          'has_pos_ip': pos_ip.value.trim().isNotEmpty,
          'has_valid_pos_port': port != null,
        },
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_pos_connect',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      refundFailedAlert();
      return;
    }

    Socket.connect(
      pos_ip.value,
      port,
      //timeout: Duration(seconds: 5),
    ).then((Socket socket) {
      logI("连接成功了么");
      monitorRefundStageSucceeded(
        'refund_pos_connect',
        PaymentEventCode.refundDeviceSucceeded,
        'Refund POS connection succeeded',
        data: <String, Object?>{'attempt': socketNumberTimes.value},
      );
      socketNumberTimes.value = 0;
      this._socket = socket;

      //扫码过来的，请求数据不为空时候发送POS请求
      if (questData != "") {
        monitorRefundStageStarted(
          'refund_device',
          PaymentEventCode.refundDeviceStarted,
          'Refund request sent to POS device',
        );
        //判断不为空则POS机
        this._socket?.write(questData);
      }

      // 监听wifi模块发送的数据
      this._socket?.listen(
        (List<int> event) {
          LogUtil.d(event);
          //if (event.length > 40) event.fillRange(266, 289, 32);
          for (var i = 0; i < event.length; i++) {
            if (event[i] > 127) {
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
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000") {
              print("进来取消了");
              //CancelOrder();
              //showEasyLoading();
            } else if (resultString.trim() != "") {
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
          } else if ((transaction_type == "600" || transaction_type == "601") &&
              eventReportString.value.length > 4800) {
            if (FirstString == "3" &&
                SecondString == "11" &&
              resultString == "000" &&
              resultMPFSString == "000") {
              // &&  resultMPFSString == "000"
              monitorRefundStageSucceeded(
                'refund_device',
                PaymentEventCode.refundDeviceSucceeded,
                'Refund POS device processing succeeded',
                data: <String, Object?>{
                  'result_code': resultString,
                  'result_sub_code': resultMPFSString,
                },
              );
              reportChange(eventReportString.value);
            } else {
              EasyLoading.dismiss();
              if (resultString.trim() != "") {
                monitorRefundStageFailed(
                  'refund_device',
                  PaymentEventCode.refundDeviceFailed,
                  'Refund POS device processing failed',
                  failureType: PaymentFailureType.deviceRejected,
                  critical: true,
                  data: <String, Object?>{
                    'result_code': resultString,
                    'result_sub_code': resultMPFSString,
                  },
                );
                monitorRefundFlowFailed(
                  failedStage: 'refund_device',
                  failureType: PaymentFailureType.deviceRejected,
                );
                refundFailedAlert();
              }
            }
          } else if (transaction_type != "900" &&
              transaction_type != "600" &&
              transaction_type != "601") {
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000" &&
              resultMPFSString == "000") {
              // &&  resultMPFSString == "000"
              String reportString = eventString.substring(0, 169);
              monitorRefundStageSucceeded(
                'refund_device',
                PaymentEventCode.refundDeviceSucceeded,
                'Refund POS device processing succeeded',
                data: <String, Object?>{
                  'result_code': resultString,
                  'result_sub_code': resultMPFSString,
                },
              );
              reportChange(reportString);
              EasyLoading.dismiss();
            } else {
              EasyLoading.dismiss();
              if (resultString.trim() != "") {
                monitorRefundStageFailed(
                  'refund_device',
                  PaymentEventCode.refundDeviceFailed,
                  'Refund POS device processing failed',
                  failureType: PaymentFailureType.deviceRejected,
                  critical: true,
                  data: <String, Object?>{
                    'result_code': resultString,
                    'result_sub_code': resultMPFSString,
                  },
                );
                monitorRefundFlowFailed(
                  failedStage: 'refund_device',
                  failureType: PaymentFailureType.deviceRejected,
                );
                refundFailedAlert();
              }
            }
          }
        },
        onDone: () {
          socketState.value = false;
          logI("pos机done了");
        },
        onError: (e) {
          socketState.value = false;
          logI("pos机错误了");
          monitorRefundStageFailed(
            'refund_device',
            PaymentEventCode.refundDeviceFailed,
            'Refund POS socket failed',
            failureType: PaymentFailureType.network,
            critical: true,
            error: e,
          );
          monitorRefundFlowFailed(
            failedStage: 'refund_device',
            failureType: PaymentFailureType.network,
            error: e,
          );
          //_close();
        },
      );

      socketState.value = true;
    }).catchError((e) {
      socketState.value = false;

      logI("Unable to connect: $e");
      logI("POS机连接${socketNumberTimes.value}");
      monitorRefundWarning(
        PaymentEventCode.refundDeviceFailed,
        'Refund POS connection attempt failed',
        failureType: PaymentFailureType.network,
        error: e,
        data: <String, Object?>{
          'stage': 'refund_pos_connect',
          'attempt': socketNumberTimes.value,
          'will_retry': socketNumberTimes.value <= 20,
        },
      );
      Future.delayed(Duration(milliseconds: 400), () async {
        payconnectSocker(questData: questData);
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

  _setPayCubeListener() async {
    await payCube.setReceiveEvent;
    payCube.getPayCubeListener();
    payCube.onCashInfoChange = (int type, String value) {
      switch (type) {
        case 0:
          debugPrint("putMoney==$value");
          //_updatePutMoneyInfo(value);
          break;
        case 1:
          debugPrint("putCurrency==$value");
          //_getPayCubePutMoneyCurrency(value);
          break;
        case 2:
          debugPrint("currencyString==$value");
          _getPayCubeOutMoney(value);
          break;
        default:
          break;
      }
    };
  }

  //现金机开始 开始出金 -交易终了
  startOutPutMoney(outMoney) async {
    monitorRefundStageStarted(
      'refund_device',
      PaymentEventCode.refundDeviceStarted,
      'Cash refund payout started',
      data: <String, Object?>{
        'cash_device': Platform.isWindows ? 'glory' : 'paycube',
        'refund_amount': outMoney,
      },
    );
    if (Platform.isWindows) {
      await gloryOutputMoney(outMoney);
      return;
    }

    var outStringMoney = outMoney.toString();
    //await Paycube.setReceiveEvent;
    Object? payoutError;
    bool outResult = await payCube.outPayCubeMoney(outStringMoney, onSuccess: () {
      logI("出金成功");
    }, catchError: (error) {
      payoutError = error;
      logI("出金失败");
    });
    logI("出金结果 ${outResult}");
    //_countDownTimer("6");

    // outmoneytimer?.cancel();
    // outmoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outmoneyt) async {
    //   outStatus.value = await Paycube.getPayCubeOutMoneyStatus;
    // 循环一定要记得设置取消条件，手动取消
    if (outResult) {
      monitorRefundInfo(
        PaymentEventCode.refundDeviceStarted,
        'PayCube refund payout command accepted',
        status: 'accepted',
        data: <String, Object?>{
          'stage': 'refund_device',
          'cash_device': 'paycube',
          'refund_amount': outMoney,
        },
      );
      //如果打开了现金机，则去掉倒计时监听
      showCashTimer?.cancel();
      seconds.value = 180;
      //如果取消不汇报，则出金后直接关闭 ？？？？？？
      //_getPayCubeOutMoney();
      await payCube.setReceiveEvent;
    } else {
      monitorRefundStageFailed(
        'refund_device',
        PaymentEventCode.refundDeviceFailed,
        'PayCube refund payout command failed',
        failureType: PaymentFailureType.deviceRejected,
        critical: true,
        error: payoutError,
        data: <String, Object?>{
          'cash_device': 'paycube',
          'refund_amount': outMoney,
        },
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_device',
        failureType: PaymentFailureType.deviceRejected,
      );
      cashErrorHandle();
    }
  }

  cashErrorHandle() {
    //现金机出错处理
    EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alertOneButton('返金に失敗しました。現金機の状態を確認してください。ありがとうございます。',
            confirm: () {
          orderIdController.text = "";
          orderList.value = [];
          refundInfo.value = {};
          queryOrder();
          Get.back();
        }),
        barrierDismissible: false);
  }

  _getPayCubeOutMoney(currencyStringResult) async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    //OutMoneytimer?.cancel();
    //await Paycube.setReceiveEvent;
    //_countDownTimer("7");

    var queryTimes = 0;
    // 循环一定要记得设置取消条件，手动取消
    //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;

    //OutMoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outMoneyTime) async {

    if (getOutMoneyString.value == true) {
      // 循环一定要记得设置取消条件，手动取消
      //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;
      debugPrint(
          "currencyStringResult.trim().length : ${currencyStringResult.trim().length}");
      if (currencyStringResult.trim().length > 50) {
        var outtotalAmount =
            MoneyParser.calculateTotalAmount(currencyStringResult.trim());
        debugPrint("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
        //print("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
        //print("计算现金机出金金额与实际投入是否相等${currencyStringresult}");

        if (outtotalAmount == refundInfo.value["amount"]) {
          monitorRefundStageSucceeded(
            'refund_device',
            PaymentEventCode.refundDeviceSucceeded,
            'PayCube refund payout succeeded',
            data: <String, Object?>{
              'cash_device': 'paycube',
              'refund_amount': outtotalAmount,
              'denomination_data': currencyStringResult.trim(),
            },
          );
          //如果打开了现金机，则去掉倒计时监听
          // showCashTimer?.cancel();
          // seconds.value = 180;
          currencyString.value = currencyStringResult;
          getOutMoneyString.value == false;

          //OutMoneytimer?.cancel();

          payCubeCloseTransaction(currencyStringResult);
        } else if (_refundEventState.lastDenominationMismatch !=
            currencyStringResult) {
          _refundEventState.lastDenominationMismatch = currencyStringResult;
          monitorRefundWarning(
            PaymentEventCode.refundDeviceFailed,
            'PayCube refund payout denominations do not match refund amount',
            failureType: PaymentFailureType.invalidResponse,
            data: <String, Object?>{
              'stage': 'refund_device',
              'cash_device': 'paycube',
              'expected_amount': refundInfo["amount"],
              'actual_amount': outtotalAmount,
              'denomination_data': currencyStringResult.trim(),
              'is_final': false,
            },
          );
        }
      }
    }
    queryTimes++;
    //});
  }

  //汇报出金币种,请求后台
  reportChange(changeString) {
    debugPrint("reportChange isReportCash = ${isReportCash.value}");
    if (isReportCash.value == true) {
      return;
    }

    isReportCash.value = true;

    monitorRefundStageStarted(
      'refund_notify',
      PaymentEventCode.refundNotifyStarted,
      'Refund result notification started',
      data: <String, Object?>{
        'response_message_length': changeString.toString().length,
      },
    );

    var formData = {
      "responseMessage": changeString,
      "machineCode": machineCode,
      "orderId": refundInfo["orderId"],
    };
    debugPrint('formData:  $formData');
    request('webBootReimburseNotify', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());

      EasyLoading.dismiss();
      if (response['code'] == 200 && response['data'] == true) {
        monitorRefundStageSucceeded(
          'refund_notify',
          PaymentEventCode.refundNotifySucceeded,
          'Refund result notification succeeded',
        );
        monitorRefundFlowSucceeded(completionStage: 'refund_notify');
        printReimburseReceipt(reimbursePrintViewSize, reimbursePrintView); //打印
        Get.dialog(
            DialogUtils.alertOneButton("返金成功。",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              isReportCash.value = false;
              orderIdController.text = "";
              orderList.value = [];
              refundInfo.value = {};
              queryOrder();
              Get.back();
            }),
            barrierDismissible: false);
      } else {
        monitorRefundStageFailed(
          'refund_notify',
          PaymentEventCode.refundNotifyFailed,
          'Refund result notification was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: true,
          data: <String, Object?>{'response_code': response['code']},
        );
        monitorRefundFlowFailed(
          failedStage: 'refund_notify',
          failureType: PaymentFailureType.backendRejected,
        );
        isReportCash.value = false;
        Get.dialog(
            DialogUtils.alertOneButton("返金失敗です。",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              orderIdController.text = "";
              orderList.value = [];
              refundInfo.value = {};
              queryOrder();
              Get.back();
            }),
            barrierDismissible: false);
      }
    }).catchError((error, stackTrace) {
      isReportCash.value = false;
      EasyLoading.dismiss();
      monitorRefundStageFailed(
        'refund_notify',
        PaymentEventCode.refundNotifyFailed,
        'Refund result notification failed',
        failureType: PaymentFailureType.network,
        critical: true,
        error: error,
        stackTrace: stackTrace,
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_notify',
        failureType: PaymentFailureType.network,
        error: error,
        stackTrace: stackTrace,
      );
      refundFailedAlert();
    });
  }

  payCubeCloseTransaction(cashOutString) async {
    //取引终了结束交易
    _countDownTimer("5");
    monitorRefundStageStarted(
      'refund_device_close',
      PaymentEventCode.refundDeviceStarted,
      'PayCube refund transaction close started',
      data: const <String, Object?>{'cash_device': 'paycube'},
    );
    Object? closeError;
    bool endTrade = await payCube.endTrade(onSuccess: () {
      debugPrint("取引终了结束交易成功");
    }, catchError: (error) {
      closeError = error;
      debugPrint("取引终了结束交易失败");
    });

    if (endTrade) {
      monitorRefundStageSucceeded(
        'refund_device_close',
        PaymentEventCode.refundDeviceSucceeded,
        'PayCube refund transaction close succeeded',
        data: const <String, Object?>{'cash_device': 'paycube'},
      );
      showCashTimer?.cancel();
      seconds.value = 180;
      reportChange(cashOutString);
    } else {
      debugPrint("取引终了结束交易失败");
      monitorRefundStageFailed(
        'refund_device_close',
        PaymentEventCode.refundDeviceFailed,
        'PayCube refund transaction close failed',
        failureType: PaymentFailureType.deviceRejected,
        critical: true,
        error: closeError,
        data: const <String, Object?>{'cash_device': 'paycube'},
      );
      monitorRefundFlowFailed(
        failedStage: 'refund_device_close',
        failureType: PaymentFailureType.deviceRejected,
        error: closeError,
      );
      cashErrorHandle();
    }
  }

  printReimburseReceipt(Size size, Widget widget) async {
    if (Platform.isAndroid) {
      ByteData byteData = await WidgetToImage.widgetToImage(
        Container(
          width: size.width.toDouble(),
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(2), right: ScreenAdapter.width(2)),
          height: size.height.toDouble(),
          color: Colors.white,
          child: widget,
        ),
        size: size,
      );

      List<int> imageBytes = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      String base64Image = base64Encode(imageBytes);
      await FlutterPluginMsprinter.sendPrintImgNew(
          base64Image, "0", "0", " "); //printLogoImage.value
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("0");
      });
    } else {
      // final printWidget = Container(
      //   width: 385,
      //   padding: EdgeInsets.only(left: ScreenAdapter.width(2),right: ScreenAdapter.width(2)),
      //   height: size.height.toDouble() + 150,
      //   color: Colors.white,
      //   //alignment: Alignment.topCenter,
      //   child: widget,
      // );
      // final printWidget = Container(
      //   width: size.width.toDouble(),
      //   height: size.height.toDouble() + 150,
      //   child: widget,
      // );
      sendToUsePrinter(widget);
    }
    //发送到厨房
    _sendToKitchen();
  }

  _sendToKitchen() async {
    //发送到厨房
    final printList = machineInfo.printerList;
    final kitchenList = printList.firstWhere(
        (element) =>
            element['type'] == 10 &&
            element['receipt'] == 0 &&
            element['isOff'] == false,
        orElse: () => null);
    if (kitchenList != null) {
      final printWidget = ReceiptConstrainedBox(
          ReimbursePrintView(reimburseInfo: refundInfo, widgetWidth: 530));

      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: printWidget as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip: kitchenList['printIp']),
        ),
      );
    }
  }

  // _getPrintLogoImageData() async {
  //   String logoImageInfo = await HomeServices.getSmartweLogoImagesData();
  //   if (logoImageInfo != "" && logoImageInfo != null) {
  //     printLogoImage.value = logoImageInfo;
  //   }
  //
  //   change(null, status: RxStatus.success());
  // }
}
