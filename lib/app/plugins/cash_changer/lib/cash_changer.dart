import 'package:cash_changer/cash_changer_platform_interface.dart';

class CashChanger {
  static Future<String?> get getPlatformVersion async {
    return CashChangerPlatform.instance.getPlatformVersion();
  }

  //Open cash changer
  static Future<int?> get openCashChanger async {
    return CashChangerPlatform.instance.openCashChanger();
    // final result = await _channel.invokeMethod('openCashChanger');
    // return result;
  }

  //Close cash changer
  static Future<int?> get closeCashChanger async {
    return CashChangerPlatform.instance.closeCashChanger();
  }
}
