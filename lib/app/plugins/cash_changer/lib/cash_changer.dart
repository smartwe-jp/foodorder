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

  //end Deposit
  static Future<int?> endDeposit(int status) async {
    return CashChangerPlatform.instance.endDeposit(status);
  }

  //Dispense Change
  static Future<int?> dispenseChange(int change) async {
    return CashChangerPlatform.instance.dispenseChange(change);
  }

  //Deposit Repay
  static Future<int?> get depositRepay async {
    return CashChangerPlatform.instance.depositRepay();
  }

  //Check Changer Status
  static Future<int?> get checkChangerStatus async {
    return CashChangerPlatform.instance.checkChangerStatus();
  }
}
