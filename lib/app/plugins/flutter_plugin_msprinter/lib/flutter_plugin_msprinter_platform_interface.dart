import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_plugin_msprinter_method_channel.dart';

abstract class FlutterPluginMsprinterPlatform extends PlatformInterface {
  /// Constructs a FlutterPluginMsprinterPlatform.
  FlutterPluginMsprinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPluginMsprinterPlatform _instance = MethodChannelFlutterPluginMsprinter();

  /// The default instance of [FlutterPluginMsprinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPluginMsprinter].
  static FlutterPluginMsprinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPluginMsprinterPlatform] when
  /// they register themselves.
  static set instance(FlutterPluginMsprinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
