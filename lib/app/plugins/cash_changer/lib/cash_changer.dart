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

  //Get Cash Balance Info
  static Future<String?> get getCashBalance async {
    return CashChangerPlatform.instance.getCashBalance();
  }

  //Start Deposit
  static Future<int?> get startDeposit async {
    return CashChangerPlatform.instance.startDeposit();
  }

  //Deposit Amount
  static Future<int?> get depositAmount async {
    return CashChangerPlatform.instance.depositAmount();
  }

  //Stop Deposit
  static Future<int?> get stopDeposit async {
    return CashChangerPlatform.instance.stopDeposit();
  }
}
