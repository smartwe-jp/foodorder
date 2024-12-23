import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum PosAction {
  Connect,
  WritePay,
  Cancel,
  Close,
  None,
}

class PosSocketManager {
  static final bool posTest = false;
  static final PosSocketManager _instance = PosSocketManager._internal();
  factory PosSocketManager() => _instance;

  // Private constructor
  PosSocketManager._internal();

  // Socket instance
  Socket? _socket;
  bool _isConnected = false;
  bool _needInterActive = false;
  bool _payProcess = false;

  int _socketNumberTimes = 0;
  String _eventReportString = "";
  PosAction _posAction = PosAction.None;

  Function(String e)? _onError;
  Function(int mode)? _onLoading;
  // Function(String result)? _onSuccess;
  // Function? _onRequestPayData;
  Function? _onDone;
  //static bool get isConnected => _socket != null && !_socket!.done;
  // Function? _onTimeOut;
  // Function(String resultString, String pfsString)? _onCancel;

  //PosPayUtil();

  Future resetState() async {
    _payProcess = false;
    _eventReportString = "";
    _needInterActive = false;
    _posAction = PosAction.None;
    _socketNumberTimes = 0;
  }

  PosAction posAction() {
    return _posAction;
  }

  setPosPadding() {
    _needInterActive = true;
  }

  Future posActionWithData(PosAction action, String writeData) async {
    //Logger('').info('posActionWithData action:$action data:$writeData');
    _posAction = action;
    switch (action) {
      case PosAction.Connect:
      // TODO: Handle this case.
        break;
      case PosAction.WritePay:
        _socketNumberTimes = 0;
        break;
      case PosAction.Cancel:
        _socketNumberTimes = 0;
        if (_isConnected == false) {
          _onDone?.call(action);
          _onDone = null;
        } else {
          _onLoading?.call(0);
        }

        break;
      case PosAction.Close:
        _socketNumberTimes = 0;
        break;
    }

    //_socket?.write(writeData);
    await _posWirteData(writeData);
  }

  Future _posWirteData(String writeData) async {
    //Logger('').info('_posWirteData $writeData');
    try {
      _socket?.write(writeData);
    } catch (e) {
      _onError?.call(e.toString());
    }
  }

  Future closePos() async {
    debugPrint('--closePos--');
    resetState();
    if (_socket != null) {
      _socket?.destroy();
      _socket = null;
    }

  }

  //pos机相关
  Future payConnectSocket(
      String payment, String pos_ip, int pos_port, String machineCode,
      {questData = "",
        bool isRetry = false,
        Function(String)? onError,
        Function(int)? onLoading,
        Function? onLoadingEnd,
        Function(String)? onSuccess,
        Function? onRequestPayData,
        Function(PosAction)? onDone,
        Function? onTimeOut,
        Function(String, String)? onCancel}) async {
    debugPrint('payConnectSocket $payment $pos_ip:$pos_port $machineCode');
    debugPrint('questData : $questData');
    _eventReportString = "";
    _onError = onError;
    _onDone = onDone;
    _onLoading = onLoading;
    _payProcess = true;

    if (_isConnected) {
      debugPrint('socket has connected');
      if (questData != "") {
        _posAction = PosAction.WritePay;
        //_socket?.write(questData);
        _posWirteData(questData);
      }
      if (payment != "2") {
        print("进来关闭弹窗");
        Future.delayed(Duration(milliseconds: 1300), () async {
          onLoadingEnd?.call();
        });
      }

      return;
    }

    if (!isRetry) {
      _socketNumberTimes = 0;
    }
    //判断socket请求次数
    _posAction = PosAction.Connect;
    _socketNumberTimes++;
    if (_socketNumberTimes > 20) {
      //return posPayUtil;
      onTimeOut?.call();
      return;
    }

    try {
      _posAction = PosAction.Connect;
      Socket socket = await Socket.connect(pos_ip, pos_port);
      debugPrint('Connected to $pos_ip:$pos_port');
      _socket = socket;
      _isConnected = true;

      //扫码过来的，请求数据不为空时候发送POS请求
      if (questData != "") {
        //判断不为空则POS机
        _posAction = PosAction.WritePay;
        //socket.write(questData);
        _posWirteData(questData);
      }

      //获得pos数据并发送
      var paymentMethod = ["3", "4", "5", "6", "7", "8", "9", "10"];
      if (paymentMethod.contains(payment) == true) {
        onRequestPayData?.call();
        debugPrint('--_onRequestPayData--');
      }

      if (payment != "2") {
        print("进来关闭弹窗");
        Future.delayed(Duration(milliseconds: 1300), () async {
          onLoadingEnd?.call();
        });
      }

      _socket?.listen(
            (List<int> event) {
          for (var i = 0; i < event.length; i++) {
            if (event[i] > 127) {
              event[i] = 32;
              //print(i);
            }
          }
          var zhuanhuan = Uint8List.fromList(event);
          var eventString = Utf8Codec().decode(zhuanhuan);
          debugPrint("eventString:$eventString");
          _eventReportString += eventString;
          debugPrint("_eventReportString:$_eventReportString");

          //print(Utf8Codec().decode(zhuanhuan));
          //print("event=====${eventString}=====");
          String FirstString = _eventReportString.substring(0, 1);
          String SecondString = _eventReportString.substring(1, 3);
          String transactionType = _eventReportString.substring(3, 6);
          String resultString = _eventReportString.substring(10, 13);
          String resultMPFSString = _eventReportString.substring(13, 16);
          //
          debugPrint("FirstString==${FirstString} SecondString==${SecondString}");
          debugPrint("transaction_type==${transactionType}");
          debugPrint("resultString==${resultString} resultMPFSString==${resultMPFSString}");

          _checkIfTestMode();

          //支付成功 打印，返回首页 除了成功都取消
          if (transactionType == "900") {
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000" &&
                _eventReportString.length == 40) {
              debugPrint("Pos Cancel order");
              if (_posAction == PosAction.Cancel) onLoading?.call(0);
            } else if (resultString.trim() != "000") {
              //T10 交通系等待时间超过30-40后自动返回
              //06 需要密码但是不输入密码直接点击屏幕返回  需要弹框文字
              var posErrorCode = ["L06"];
              if (posErrorCode.contains(resultString) == true) {
                if (onCancel != null) onCancel(resultString, resultMPFSString);
              }
            } else {
              if (_posAction == PosAction.Cancel) onLoading?.call(0);
            }
          } else if ((transactionType == "600" || transactionType == "601") &&
              _eventReportString.length > 4800) {
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000" &&
                resultMPFSString == "000") {
              if (payment != "2") {
                onLoading?.call(0);
              }

              var thincaCloud = ["5", "6", "7", "8", "9", "10"];
              if (thincaCloud.contains(payment) == true) {
                String reportString = eventString.substring(0, 169);
                if (_payProcess)
                onSuccess?.call(reportString);
                _payProcess = false;
              } else {
                if (_payProcess)
                onSuccess?.call(_eventReportString);
                _payProcess = false;
              }
              _eventReportString = "";
            } else {
              if (resultString.trim() != "") {
                onCancel?.call(resultString, resultMPFSString);
              }
            }
          } else if (transactionType != "900" &&
              transactionType != "600" &&
              transactionType != "601") {
            //除了扫码的才显示
            if (payment != "2") {
              //showPosEasyLoading();
              onLoading?.call(1);
            }
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000" &&
                resultMPFSString == "000") {
              // &&  resultMPFSString == "000"
              var thincaCloud = ["5", "6", "7", "8", "9", "10"];
              if (thincaCloud.contains(payment) == true) {
                String reportString = eventString.substring(0, 169);
                if (_payProcess)
                onSuccess?.call(reportString);
                _payProcess = false;
              } else {
                if (_payProcess)
                onSuccess?.call(eventString);
                _payProcess = false;
              }
              _eventReportString = "";
            } else {
              if (resultString.trim() != "") {
                debugPrint("---Recorde error to firebase old---");
                //T10 交通系等待时间超过30-40后自动返回
                var posErrorCode = ["L11", "T10"];
                //onError?.call(resultString);
                if (posErrorCode.contains(resultString) == true) {
                  Future.delayed(Duration(milliseconds: 2500), () async {
                    debugPrint("Pos error done order");
                    //if (!_needInterActive) onDone?.call(_posAction);
                    _needInterActive = true;
                    _onError?.call(resultString);
                    //gotonewMenuPage(); backAction
                  });
                } else {
                  onCancel?.call(resultString, resultMPFSString);
                }
              }
            }
          } else {
            onError?.call(resultString);
          }
        },
        onDone: () {
          debugPrint('pos is done');
          _socketNumberTimes = 0;
          _isConnected = false;
          if (!_needInterActive) onDone?.call(_posAction);
        },
        onError: (e) {
          debugPrint('pos is error: $e');
          _socketNumberTimes = 0;
          _isConnected = false;
          if (!_needInterActive)
          onError?.call(e.toString());
          _needInterActive = true;


        },
      );
    } catch (e) {
      _isConnected = false;
      debugPrint('Unable to connect pos: $e');
      Future.delayed(Duration(milliseconds: 400), () async {
        await payConnectSocket(payment, pos_ip, pos_port, machineCode,
            isRetry: true, onTimeOut: onTimeOut, onError: onError);
      });
    }
  }

  _checkIfTestMode() {
    if (posTest) {
      //测试代码 发版时posTest必需为false
      String errorString = _eventReportString.substring(130, 133);
      print("errorString==${errorString}");
      if (errorString == "801") {
        // if (get801Flag.value == false) {
        //   get801Flag.value = true;
        //   showCheckLoading();
        //   this._socket?.write(create491Message());
        // } else {
        //   EasyLoading.dismiss();
        //   _showScanCodeNoOpenDialog(
        //       3,
        //       GString.getToString(checkLanguage.value,
        //           "settlement_posPay_error_connect_worker"),
        //       payType: "pos");
        // }

        return;
      } else if (errorString == "803" || errorString == "802") {
        // Get.dialog(DialogUtils.alertOneButton(
        //     "取引が不明な状態で終了しました（コード${errorString}）。端末の指示に従って操作してください。",
        //     title: GString.getToString(checkLanguage.value, "tag_title"),
        //     confirmtitle: GString.getToString(
        //         checkLanguage.value, "tag_button_yes"), confirm: () {
        //   Get.back();
        // }));
        return;
      }
    }
  }
}
