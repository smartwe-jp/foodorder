import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cash_changer_method_channel.dart';

abstract class CashChangerPlatform extends PlatformInterface {
  /// Constructs a CashChangerPlatform.
  CashChangerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CashChangerPlatform _instance = MethodChannelCashChanger();

  /// The default instance of [CashChangerPlatform] to use.
  ///
  /// Defaults to [MethodChannelCashChanger].
  static CashChangerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CashChangerPlatform] when
  /// they register themselves.
  static set instance(CashChangerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
