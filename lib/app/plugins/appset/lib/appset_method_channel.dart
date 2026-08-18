import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'appset_platform_interface.dart';

/// An implementation of [AppsetPlatform] that uses method channels.
class MethodChannelAppset extends AppsetPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('appset');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
