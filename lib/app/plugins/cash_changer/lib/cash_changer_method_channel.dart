import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cash_changer_platform_interface.dart';

/// An implementation of [CashChangerPlatform] that uses method channels.
class MethodChannelCashChanger extends CashChangerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cash_changer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
