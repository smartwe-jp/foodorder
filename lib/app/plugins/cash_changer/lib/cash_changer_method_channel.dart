import 'cash_changer_define.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cash_changer_platform_interface.dart';

/// An implementation of [CashChangerPlatform] that uses method channels.
class MethodChannelCashChanger extends CashChangerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cash_changer');

  @override
  Future<void> setEvenstListener(Future<void> Function(MethodCall) events) async {
    methodChannel.setMethodCallHandler(events);
  }

  @override
  Future<void> removeEvenstListener() async {
    try {
      methodChannel.setMethodCallHandler(null);
    } catch (e) {
      print('停止监听失败: $e');
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int?> openCashChanger() async {
    final result = await methodChannel.invokeMethod<int>('openCashChanger');
    return result;
  }

  @override
  Future<int?> closeCashChanger() async {
    final result = await methodChannel.invokeMethod<int>('closeCashChanger');
    return result;
  }

  @override
  Future<String?> getCashBalance() async {
    final result = await methodChannel.invokeMethod<String>('getCashBalance');
    return result;
  }

  @override
  Future<int?> startDeposit() async {
    final result = await methodChannel.invokeMethod<int>('startDeposit');
    return result;
  }

  @override
  Future<int?> depositAmount() async {
    final result = await methodChannel.invokeMethod<int>('depositAmount');
    return result;
  }

  @override
  Future<int?> endDeposit(int status) async {
    final result = await methodChannel.invokeMethod<int>('endDeposit' , <String, dynamic>{
        'end_deposit': status,
    });
    return result;
  }

  @override
  Future<int?> dispenseChange(int change) async {
    final result = await methodChannel.invokeMethod<int>('dispenseChange', <String, dynamic>{
        'dispense': change,
    });
    return result;
  }

  @override
  Future<int?> depositRepay() async {
    final result = await methodChannel.invokeMethod<int>('depositRepay');
    return result;
  }

  @override
  Future<int?> checkChangerStatus() async {
    final result = await methodChannel.invokeMethod<int>('checkChangerStatus');
    return result;
  }

  @override
  Future<String?> changerDIStatus(int pData) async {
    final result = await methodChannel.invokeMethod<String>('changer_di_status', <String, dynamic>{
        'pData': pData,
    });
    return result;
  }

  @override
  Future<int?> dispenseCash(String cashCounts) async {
    final result = await methodChannel.invokeMethod<int>('dispenseCash', <String, dynamic>{
        'cashCounts': cashCounts,
    });
    return result;
  }
}