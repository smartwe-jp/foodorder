import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'HttpService.dart';

class PosCheckService extends GetxService {
  RxBool isPosChecking = false.obs;
  bool checkingResult = false;
  bool isPosBeUsedInOneHour = false;
  RxString posIp = ''.obs;
  int posPort = 9999;
  Timer? posCheckTimer;

  bool get isActive => posCheckTimer != null && posCheckTimer!.isActive;

  @override
  void onInit() {
    super.onInit();
    //_startPosCheckTimerIfNeeded();
  }

  //如果外部使用POS的时候，需要检查是否正在检测中，如果在检测中需要等在检测完毕才可以使用
  //创建一个检查的方法，如果isPosChecking为false则直接返回可使用，如果为true则需要等待检测完毕
  Future<bool> canUsePos() async {
    if (isPosChecking.value) {
      // 如果正在检查，则等待检查完成,不使用定时检查变量，使用监听变量的方法
      debugPrint('POS机正在检查中，请稍后');
      await isPosChecking.stream.firstWhere((value) => value == false);
      return true;
    }
    return true;
  }

  void toggleActive(bool active) {
    if (active) {
      _startPosCheck();
    } else {
      _stopPosCheckTimer();
    }
  }

  void _startPosCheck() {
    debugPrint('开始POS机检查服务');
    if (posCheckTimer != null && posCheckTimer!.isActive) {
      posCheckTimer!.cancel();
    }
    _startPosCheckTimer(posIp.value, posPort);
  }

  //停止POS机检查服务
  void _stopPosCheckTimer() {
    if (posCheckTimer != null) {
      posCheckTimer!.cancel();
      posCheckTimer = null;
      debugPrint('POS机检查服务已停止');
    }
  }

  //设置POS机的IP和端口
  void setPosConnection(String ip, int port) {
    // 检查IP和端口是否有效,检查IP使用正则表达式
    if (ip.isEmpty || port <= 0 || port > 65535) {
      //throw ArgumentError('Invalid POS IP or port');
      _stopPosCheckTimer();
      return;
    }
    final RegExp ipRegExp = RegExp(
        r'^((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)))$');
    if (!ipRegExp.hasMatch(ip)) {
      //throw ArgumentError('Invalid POS IP address');
      _stopPosCheckTimer();
      return;
    }
    posIp.value = ip;
    posPort = port;
    _startPosCheckTimer(posIp.value, posPort);
  }

  void _startPosCheckTimerIfNeeded() {
    debugPrint('POS机检查服务初始化，当前IP: ${posIp.value} 端口: $posPort');
    ever(posIp, (_) {
      // 当POS机IP发生变化时，重新启动定时器
      debugPrint('POS机IP发生变化: ${posIp.value} 端口: $posPort');
      setPosConnection(posIp.value, posPort);
    });
  }

  void updateUseStatus(bool isUsed) {
    isPosBeUsedInOneHour = isUsed;
  }

  //开启一个定时测试的任务，每60分钟执行一次
  void _startPosCheckTimer(String posIp, int posPort) {
    posCheckTimer?.cancel();
    posCheckTimer = Timer.periodic(Duration(minutes: 60), (timer) {
      if (isPosBeUsedInOneHour || isPosChecking.value) {
        debugPrint('POS机在一小时内被使用过或正在检查中，跳过检查');
        //如果POS机在一小时内被使用过，则不进行检查

        return;
      }
      checkPosConnection(posIp, posPort: posPort);
    });
  }

  //检查POS机连接状态
  Future<bool> checkPosConnection(String posIp, {int posPort = 9999}) async {
    if (isPosChecking.value) return false; // 如果正在检查，则不重复执行
    debugPrint('开始检查POS机连接: IP=$posIp, 端口=$posPort');
    isPosChecking.value = true;
    checkingResult = false;
    return await _posTest(posIp, posPort);
  }

  Future<bool> _posTest(posIp, posPort, {tryTime = 0}) async {
    debugPrint("--- posTest ---");

    try {
      var val = await request('webBootPosTest', method: 'POST')
          .timeout(Duration(seconds: 10));
      var response = json.decode(val.toString());
      debugPrint("webBootPosTest: " + response.toString());
      if (response['code'] == 200) {
        debugPrint("POS机连接信息：${response['data']}");
        return await _payConnectSocker(response['data'], posIp, posPort);
      } else {
        isPosChecking.value = false;
        return false;
      }
    } catch (error) {
      debugPrint("webBootPosTest 错误: $error");
      if (tryTime >= 3) {
        isPosChecking.value = false;
        debugPrint("POS机连接失败超过3次，停止尝试");
        return false;
      }
      await Future.delayed(Duration(seconds: 1));
      return await _posTest(posIp, posPort, tryTime: tryTime + 1);
    }
  }

  Future<bool> _payConnectSocker(questData, pos_ip, pos_port,
      {tryTime = 0}) async {
    final completer = Completer<bool>();

    await Socket.connect(
      pos_ip,
      pos_port,
      timeout: Duration(seconds: 10),
    ).then((Socket socket) async {
      debugPrint("POS机连接成功");

      socket.write(questData);
      await Future.delayed(Duration(seconds: 5));
      debugPrint("发送取消数据");
      socket.write("2109000001       00000                  ");

      socket.listen(
        (List<int> event) {
          debugPrint("POS机返回数据: ${utf8.decode(event)}");
          isPosChecking.value = false;
          checkingResult = true;
        },
        onDone: () async {
          debugPrint("POS机连接已关闭");
          await Future.delayed(Duration(seconds: 2));
          socket.destroy();
          isPosChecking.value = false;
          if (!completer.isCompleted) {
            completer.complete(checkingResult);
          }
        },
        onError: (e) async {
          debugPrint("POS机连接错误: $e");
          await Future.delayed(Duration(seconds: 2));
          isPosChecking.value = false;
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        cancelOnError: true,
      );
    }).catchError((e) async {
      debugPrint("POS机连接失败: $e");
      if (tryTime >= 3) {
        await Future.delayed(Duration(seconds: 2));
        isPosChecking.value = false;
        debugPrint("POS机连接失败超过3次，停止尝试");
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      } else {
        await Future.delayed(Duration(seconds: 1));
        bool retryResult = await _payConnectSocker(questData, pos_ip, pos_port,
            tryTime: tryTime + 1);
        if (!completer.isCompleted) {
          completer.complete(retryResult);
        }
      }
    });

    return await completer.future;
  }
}
