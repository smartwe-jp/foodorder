import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'paycube_old_platform_interface.dart';

/// An implementation of [PaycubeOldPlatform] that uses method channels.
class MethodChannelPaycubeOld extends PaycubeOldPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paycube_old');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
