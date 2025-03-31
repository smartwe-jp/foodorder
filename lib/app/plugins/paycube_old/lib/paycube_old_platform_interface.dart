import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paycube_old_method_channel.dart';

abstract class PaycubeOldPlatform extends PlatformInterface {
  /// Constructs a PaycubeOldPlatform.
  PaycubeOldPlatform() : super(token: _token);

  static final Object _token = Object();

  static PaycubeOldPlatform _instance = MethodChannelPaycubeOld();

  /// The default instance of [PaycubeOldPlatform] to use.
  ///
  /// Defaults to [MethodChannelPaycubeOld].
  static PaycubeOldPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PaycubeOldPlatform] when
  /// they register themselves.
  static set instance(PaycubeOldPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
