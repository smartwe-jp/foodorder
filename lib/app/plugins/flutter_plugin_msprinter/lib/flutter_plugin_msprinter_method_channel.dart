import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_plugin_msprinter_platform_interface.dart';

/// An implementation of [FlutterPluginMsprinterPlatform] that uses method channels.
class MethodChannelFlutterPluginMsprinter extends FlutterPluginMsprinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_plugin_msprinter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
