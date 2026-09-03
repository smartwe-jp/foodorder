import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/imageData.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/rejishimei/state.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/plugins/flutter_plugin_msprinter/lib/flutter_plugin_msprinter.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/cash_monitoring_events.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:get/get.dart';
import 'package:widget_to_image/widget_to_image.dart';

class RejishimeLogic extends GetxController {
  RejishimeLogic({this.isRegisterClose = true});

  final bool isRegisterClose;
  final RejishimeState state = RejishimeState();
  final machineCode = Get.find<MachineInfoController>().machineCode;
  final SettingController settingController = Get.find();
  final PrintInfoService saveService = Get.find();
  String? _registerCloseFlowId;
  DateTime? _registerCloseStartedAt;
  bool _registerCloseTerminalReported = false;

  String get _cashDevice {
    final driver = settingController.machineInfo.cashMachineDriver.name;
    return driver == 'cashChanger' ? 'glory' : driver.toLowerCase();
  }

  String get _flowId =>
      _registerCloseFlowId ??= CashMonitoringEvents.newFlowId();

  void _registerCloseEvent(
    String eventCode,
    String message, {
    required String status,
    required String stage,
    bool warning = false,
    Object? error,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    if (!isRegisterClose) return;
    CashMonitoringEvents.registerClose(
      eventCode,
      message,
      flowId: _flowId,
      status: status,
      stage: stage,
      cashDevice: _cashDevice,
      warning: warning,
      error: error,
      data: data,
    );
  }

  void _finishRegisterClose({
    required bool baselineSucceeded,
    required bool backendSyncSucceeded,
    required bool printSucceeded,
  }) {
    if (!isRegisterClose || _registerCloseTerminalReported) return;
    _registerCloseTerminalReported = true;
    final durationMs = _registerCloseStartedAt == null
        ? null
        : DateTime.now().difference(_registerCloseStartedAt!).inMilliseconds;
    _registerCloseEvent(
      baselineSucceeded && backendSyncSucceeded && printSucceeded
          ? 'REGISTER_CLOSE_FLOW_SUCCEEDED'
          : 'REGISTER_CLOSE_FLOW_COMPLETED_WITH_WARNING',
      baselineSucceeded && backendSyncSucceeded && printSucceeded
          ? 'Register close flow succeeded'
          : 'Register close completed with a follow-up warning',
      status: baselineSucceeded && backendSyncSucceeded && printSucceeded
          ? 'succeeded'
          : 'completed_with_warning',
      stage: 'completed',
      warning: !baselineSucceeded || !backendSyncSucceeded || !printSucceeded,
      data: <String, Object?>{
        'business_close_status': 'succeeded',
        'baseline_status': baselineSucceeded ? 'succeeded' : 'failed',
        'backend_sync_status': backendSyncSucceeded ? 'succeeded' : 'failed',
        'print_status': printSucceeded ? 'succeeded' : 'failed',
        if (durationMs != null) 'duration_ms': durationMs,
      },
    );
  }

  @override
  void onInit() {
    debugPrint('---RejishimeLogic onInit---');
    //state.machineCode = Get.arguments['machineCode'];

    super.onInit();
    if (isRegisterClose) {
      _registerCloseStartedAt = DateTime.now();
      _registerCloseEvent(
        'REGISTER_CLOSE_FLOW_STARTED',
        'Register close flow started',
        status: 'started',
        stage: 'flow',
      );
      _registerCloseEvent(
        'REGISTER_CLOSE_EMAIL_LIST_STARTED',
        'Register close operator list request started',
        status: 'started',
        stage: 'email_list',
      );
    }
    loadMailAddress();
  }

  @override
  void onClose() {
    if (isRegisterClose && !_registerCloseTerminalReported) {
      _registerCloseTerminalReported = true;
      _registerCloseEvent(
        'REGISTER_CLOSE_FLOW_CANCELLED',
        'Register close flow cancelled',
        status: 'cancelled',
        stage: 'user_cancelled',
      );
    }
    super.onClose();
  }

  loadMailAddress() async {
    debugPrint('---loadMailAddress---');
    final param = {
      "machineCode": machineCode,
    };
    request('webBootEmailList', method: 'POST', parameters: param).then((val) {
      var response = json.decode(val.toString());

      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        state.mailInfo = response['data'];
        _registerCloseEvent(
          'REGISTER_CLOSE_EMAIL_LIST_SUCCEEDED',
          'Register close operator list request succeeded',
          status: 'succeeded',
          stage: 'email_list',
        );
        state.isRequesting = false;
        update();
      } else {
        _registerCloseEvent(
          'REGISTER_CLOSE_EMAIL_LIST_FAILED',
          'Register close operator list request failed',
          status: 'failed',
          stage: 'email_list',
          warning: true,
          data: <String, Object?>{'response_code': response?['code']},
        );
        showToast('取得に失敗しました');
      }
    }).catchError((e) {
      _registerCloseEvent(
        'REGISTER_CLOSE_EMAIL_LIST_FAILED',
        'Register close operator list request failed',
        status: 'failed',
        stage: 'email_list',
        warning: true,
        error: e,
      );
      state.isRequesting = false;
      update();
      showToast('取得に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        state.isRequesting = false;
        update();
        showToast('取得に失敗しました');
      },
    );
  }

  requestVerifyCode() async {
    debugPrint('requestVerifyCode');
    state.isRequesting = true;
    update();
    _registerCloseEvent(
      'REGISTER_CLOSE_VERIFICATION_STARTED',
      'Register close verification request started',
      status: 'started',
      stage: 'verification',
    );

    final param = {
      "machineCode": machineCode,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };
    request('webBootAdminVerify', method: 'POST', parameters: param)
        .then((val) async {
      state.isRequesting = false;
      update();
      var response = json.decode(val.toString());

      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        state.isSelected = true;
        _registerCloseEvent(
          'REGISTER_CLOSE_VERIFICATION_SUCCEEDED',
          'Register close verification request succeeded',
          status: 'succeeded',
          stage: 'verification',
        );
        update();
      } else {
        _registerCloseEvent(
          'REGISTER_CLOSE_VERIFICATION_FAILED',
          'Register close verification request failed',
          status: 'failed',
          stage: 'verification',
          warning: true,
          data: <String, Object?>{'response_code': response?['code']},
        );
        showToast('確認コードの送信に失敗しました');
      }
    }).catchError((e) {
      _registerCloseEvent(
        'REGISTER_CLOSE_VERIFICATION_FAILED',
        'Register close verification request failed',
        status: 'failed',
        stage: 'verification',
        warning: true,
        error: e,
      );
      state.isRequesting = false;
      update();
      showToast('確認コードの送信に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        state.isRequesting = false;
        update();
        showToast('確認コードの送信に失敗しました');
      },
    );
  }

  requestShimeInfo(code, machineCode) async {
    _showEasyLoading();
    _registerCloseEvent(
      'REGISTER_CLOSE_SUMMARY_STARTED',
      'Register close summary request started',
      status: 'started',
      stage: 'summary',
    );

    final param = {
      "machineCode": machineCode,
      "verifyCode": code,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };
    debugPrint("Rejishimei request: $param");

    final domain = 'webBootRejishimeiPrintInfo';
    // Platform.isAndroid
    //     ? 'webBootRejishimeiPrintInfo'
    //     : 'webGloryRejishimeiPrintInfo';

    request(domain, method: 'POST', parameters: param).then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        debugPrint("Rejishimei response: $response");
        int total = response['data']['cashTotal'] ?? 0;
        debugPrint("Rejishimei total: $total");
        state.recycleCash = total;
        _registerCloseEvent(
          'REGISTER_CLOSE_SUMMARY_SUCCEEDED',
          'Register close summary request succeeded',
          status: 'succeeded',
          stage: 'summary',
          data: <String, Object?>{'amount': total},
        );
        Get.back();
        showPrintView(response['data']);
      } else {
        _registerCloseEvent(
          'REGISTER_CLOSE_SUMMARY_FAILED',
          'Register close summary request failed',
          status: 'failed',
          stage: 'summary',
          warning: true,
          data: <String, Object?>{'response_code': response?['code']},
        );
        //当前没有レジ情報
        showToast('レジ情報がありません');
      }
    }).catchError((e) {
      _registerCloseEvent(
        'REGISTER_CLOSE_SUMMARY_FAILED',
        'Register close summary request failed',
        status: 'failed',
        stage: 'summary',
        warning: true,
        error: e,
      );
      logE("Rejishimei request error: $e");
      EasyLoading.dismiss();
      showToast('レジ情報の取得に失敗しました');
    }).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        _registerCloseEvent(
          'REGISTER_CLOSE_SUMMARY_FAILED',
          'Register close summary request timed out',
          status: 'failed',
          stage: 'summary',
          warning: true,
          data: const <String, Object?>{'failure_type': 'timeout'},
        );
        logE("Rejishimei request timeout");
        EasyLoading.dismiss();
        showToast('レジ情報の取得にタイムアウトしました');
      },
    );
  }

  _comfirmShimeInfo(code, printData) async {
    _showEasyLoading();
    _registerCloseEvent(
      'REGISTER_CLOSE_COMMIT_STARTED',
      'Register close commit started',
      status: 'started',
      stage: 'business_close',
    );

    final param = {
      "machineCode": machineCode,
      "verifyCode": code,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };

    request('webBootRejishimeiConfirm', method: 'POST', parameters: param)
        .then((val) async {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        //printView(response['data']);
        _registerCloseEvent(
          'REGISTER_CLOSE_COMMIT_SUCCEEDED',
          'Register close commit succeeded',
          status: 'succeeded',
          stage: 'business_close',
        );
        final printSucceeded =
            await _printRejishime(printData, state.printLength);
        _finishRegisterClose(
          baselineSucceeded: true,
          backendSyncSucceeded: true,
          printSucceeded: printSucceeded,
        );
      } else {
        _registerCloseEvent(
          'REGISTER_CLOSE_COMMIT_FAILED',
          'Register close commit failed',
          status: 'failed',
          stage: 'business_close',
          warning: true,
          data: <String, Object?>{'response_code': response?['code']},
        );
        //当前没有レジ情報
        showToast('印刷に失敗しました');
      }
    }).catchError((e) {
      _registerCloseEvent(
        'REGISTER_CLOSE_COMMIT_FAILED',
        'Register close commit failed',
        status: 'failed',
        stage: 'business_close',
        warning: true,
        error: e,
      );
      debugPrint("Rejishimei confirm error: $e");
      EasyLoading.dismiss();
      showToast('印刷に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _registerCloseEvent(
          'REGISTER_CLOSE_COMMIT_FAILED',
          'Register close commit timed out',
          status: 'failed',
          stage: 'business_close',
          warning: true,
          data: const <String, Object?>{'failure_type': 'timeout'},
        );
        EasyLoading.dismiss();
        showToast('印刷にタイムアウトしました');
      },
    );
  }

  _comfirmGloryShimeInfo(code, printData, {skip = false}) async {
    _registerCloseEvent(
      'REGISTER_CLOSE_CASH_PAYOUT_STARTED',
      'Register close cash payout started',
      status: 'started',
      stage: 'cash_payout',
    );
    final outResult = await _outCash(() {
      _registerCloseEvent(
        'REGISTER_CLOSE_CASH_PAYOUT_SKIPPED',
        'Register close cash payout was skipped',
        status: 'completed_with_warning',
        stage: 'cash_payout',
        warning: true,
      );
      //_comfirmGloryShimeInfo(code, printData, settingController, skip: true);
      _directRejishime(code, printData, null); //
      return;
    });

    if (outResult == null && skip == false) {
      _registerCloseEvent(
        'REGISTER_CLOSE_CASH_PAYOUT_FAILED',
        'Register close cash payout failed',
        status: 'failed',
        stage: 'cash_payout',
        warning: true,
      );
      return;
    }

    final normalizedOut = CashMonitoringEvents.normalizeCodeCounts(
      outResult ?? const <String, Object?>{},
    );
    _registerCloseEvent(
      'REGISTER_CLOSE_CASH_PAYOUT_SUCCEEDED',
      'Register close cash payout succeeded',
      status: 'succeeded',
      stage: 'cash_payout',
      data: <String, Object?>{
        'denomination_counts': jsonEncode(normalizedOut),
      },
    );
    CashMonitoringEvents.ledgerDelta(
      cashDevice: 'glory',
      operationType: 'register_close_payout',
      delta: normalizedOut.map((key, value) => MapEntry(key, -value)),
      flowId: _flowId,
      source: 'cash_changer',
    );

    _directRejishime(code, printData, outResult);
  }

  _directRejishime(code, printData, Map? outResult) async {
    final result =
        await _comfirmGloryShimeInfos(code, printData, outResult ?? {});
    if (!result) return;
    final cashSyncResult = await settingController.gloryConfirmSync(
      showLoading: false,
      reason: 'register_close',
      flowId: _flowId,
      createBaseline: true,
    );
    final baselineSucceeded = cashSyncResult.snapshotCaptured;
    _registerCloseEvent(
      baselineSucceeded
          ? 'REGISTER_CLOSE_BASELINE_SUCCEEDED'
          : 'REGISTER_CLOSE_BASELINE_FAILED',
      baselineSucceeded
          ? 'Register close cash baseline created'
          : 'Register close cash baseline creation failed',
      status: baselineSucceeded ? 'succeeded' : 'failed',
      stage: 'cash_baseline',
      warning: !baselineSucceeded,
      data: <String, Object?>{
        'backend_sync_status':
            cashSyncResult.backendSynced ? 'succeeded' : 'failed',
      },
    );
    if (!cashSyncResult.backendSynced) {
      _registerCloseEvent(
        'REGISTER_CLOSE_CASH_BACKEND_SYNC_FAILED',
        'Register close cash balance backend sync failed',
        status: 'failed',
        stage: 'cash_baseline',
        warning: true,
      );
    }
    final printSucceeded = await _printRejishime(printData, state.printLength);
    _finishRegisterClose(
      baselineSucceeded: baselineSucceeded,
      backendSyncSucceeded: cashSyncResult.backendSynced,
      printSucceeded: printSucceeded,
    );
  }

  Future<bool> _printRejishime(data, double length) async {
    _registerCloseEvent(
      'REGISTER_CLOSE_PRINT_STARTED',
      'Register close receipt print started',
      status: 'started',
      stage: 'print',
    );
    //_showEasyLoading();
    try {
      if (Platform.isAndroid) {
        ByteData byteData = await WidgetToImage.widgetToImage(
          PrintView(isPrint: true, printInfo: data),
          size: Size(383, length + 150),
        );

        List<int> imageBytes = byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
        String base64Image = base64Encode(imageBytes);
        await FlutterPluginMsprinter.sendPrintImgNew(
            base64Image, "0", "0", " "); //printLogoImage.value
        Future.delayed(Duration(milliseconds: 300), () async {
          await FlutterPluginMsprinter.sendPrintCut("0");
        });
        EasyLoading.dismiss();
        Get.back();
      } else {
        await settingController.printRejishimei(
          state.printLength,
          data,
          syncCashAfterPrint: false,
        );
      }
      _registerCloseEvent(
        'REGISTER_CLOSE_PRINT_SUCCEEDED',
        'Register close receipt print queued successfully',
        status: 'succeeded',
        stage: 'print',
      );
      return true;
    } catch (error) {
      _registerCloseEvent(
        'REGISTER_CLOSE_PRINT_FAILED',
        'Register close receipt print failed',
        status: 'failed',
        stage: 'print',
        warning: true,
        error: error,
      );
      return false;
    }
  }

  recycleCash() {
    settingController.recycleCash(state.verifyCode, state.selectMail);
  }

  _outCash(Function skipAction) async {
    Map? result =
        await settingController.recycleCashOut(state.recycleCash, skipAction);

    debugPrint("recycleCash result: $result");

    return result;
  }

  _comfirmGloryShimeInfos(code, printData, result) async {
    debugPrint("_comfirmGloryShimeInfo");
    var success = false;

    _showEasyLoading();
    _registerCloseEvent(
      'REGISTER_CLOSE_COMMIT_STARTED',
      'Register close commit started',
      status: 'started',
      stage: 'business_close',
    );

    // if (widget.recycleCash == null) {
    //   EasyLoading.dismiss();
    //   showToast('印刷に失敗しました');
    //   return success;
    // }

    final param = {
      "changeInfoMap": result,
      "machineCode": machineCode,
      "verifyCode": code,
      "verifyEmail": state.selectMail,
      "verifyUserName": state.selectUser,
    };
    debugPrint("webBootGloryConfirmClose param: $param");

    await request('webBootGloryConfirmClose', method: 'POST', parameters: param)
        .then((val) {
      //EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        saveService.addPrintJob(printData, category: 'rejishime');
        //printView(response['data']);
        success = true;
        _registerCloseEvent(
          'REGISTER_CLOSE_COMMIT_SUCCEEDED',
          'Register close commit succeeded',
          status: 'succeeded',
          stage: 'business_close',
        );
      } else {
        //当前没有レジ情報
        EasyLoading.dismiss();
        success = false;
        _registerCloseEvent(
          'REGISTER_CLOSE_COMMIT_FAILED',
          'Register close commit failed',
          status: 'failed',
          stage: 'business_close',
          warning: true,
          data: <String, Object?>{'response_code': response?['code']},
        );
        showToast('印刷に失敗しました');
      }
    }).catchError((e) {
      EasyLoading.dismiss();
      success = false;
      _registerCloseEvent(
        'REGISTER_CLOSE_COMMIT_FAILED',
        'Register close commit failed',
        status: 'failed',
        stage: 'business_close',
        warning: true,
        error: e,
      );
      showToast('印刷に失敗しました');
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        EasyLoading.dismiss();
        success = false;
        _registerCloseEvent(
          'REGISTER_CLOSE_COMMIT_FAILED',
          'Register close commit timed out',
          status: 'failed',
          stage: 'business_close',
          warning: true,
          data: const <String, Object?>{'failure_type': 'timeout'},
        );
        showToast('印刷に失敗しました');
      },
    );
    return success;
  }

  _showEasyLoading() {
    EasyLoading.show(
      status: 'Printer is printing...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //_showTag,
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

  showPrintView(printData) {
    Get.dialog(
        barrierDismissible: false,
        SimpleDialog(contentPadding: EdgeInsets.all(0), children: [
          Column(
            children: [
              Container(
                  padding:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                  child: Row(
                      //title
                      children: [
                        Expanded(
                          child: Text(
                            "レジ締め情報",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(36),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        InkWell(
                          highlightColor: Colors.transparent, // 透明色
                          splashColor: Colors.transparent, // 透明色
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.close_outlined,
                            color: ColorsUtil.hexToColor("#000000"),
                            size: 40.0,
                          ),
                        ),
                      ])),
              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
                width: ScreenAdapter.width(770),
                height: ScreenAdapter.height(1080),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: ColorsUtil.hexToColor("#000000"), width: 1),
                ),
                child: PrintView(
                  printInfo: printData,
                  lengthUpdate: (double length) {
                    print("printLength: $length");
                    state.printLength = length;
                    //_updatePrintInfo(length, printData);
                  },
                ),
              ),
            ],
          ),
          Container(
              height: ScreenAdapter.height(100),
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#f1f3f4"),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text(
                            "キャンセル",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ScreenAdapter.width(0.5),
                    height: ScreenAdapter.height(100),
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (Platform.isWindows) {
                          debugPrint("comfirmGloryShimeInfo");
                          await _comfirmGloryShimeInfo(
                              state.verifyCode, printData);
                        } else {
                          _comfirmShimeInfo(state.verifyCode, printData);
                        }
                        //_printRejishime(printData,printLength);
                        //Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text(
                            "印刷",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ]));
  }
}
