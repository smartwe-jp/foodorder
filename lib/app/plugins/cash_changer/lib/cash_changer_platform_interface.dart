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

  //Open cash change
  Future<int?> openCashChanger() {
    throw UnimplementedError('openCashChanger() has not been implemented.');
  }

  //Close cash change
  Future<int?> closeCashChanger() {
    throw UnimplementedError('closeCashChanger() has not been implemented.');
  }

  //Get Cash Balance Info
  Future<String?> getCashBalance() {
    throw UnimplementedError('getCashBalance() has not been implemented.');
  }

  //Start Deposit
  Future<int?> startDeposit() {
    throw UnimplementedError('startDeposit() has not been implemented.');
  }

  //Deposit Amount
  Future<int?> depositAmount() {
    throw UnimplementedError('depositAmount() has not been implemented.');
  }

  //Stop Deposit
  Future<int?> stopDeposit() {
    throw UnimplementedError('stopDeposit() has not been implemented.');
  }
}
