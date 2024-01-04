import 'package:cash_changer/cash_changer_platform_interface.dart';
import 'package:flutter/foundation.dart';

class CashChanger {
  static int? putMoney = 0;
  static String putCurrency = "";
  static String currencyString = ""; //币种 截取0B 81的43位开始

  //监听几种状态
  static String payCubeStopCashStatus = "Error";
  static String payCubeOutMoneyStatus = "Error";
  static String payCubeEndTradeStatus = "Error";

  static Function(int)? onGetPutMoneyStringChange;


  //set event listener
  static Future<void> setEventsListener() async {
    CashChangerPlatform.instance.setEvenstListener((call) async {

      debugPrint('Cash Changer Event: ${call.method} ${call.arguments}');
      switch (call.method) {
        case 'DirectIOEvent':
          
          break;
        case 'DataEvent':
          putMoney = call.arguments;
          onGetPutMoneyStringChange?.call(putMoney ?? 0);
          break;
        case 'StatusUpdateEvent':
          
          break;
        default:
          debugPrint('No method found');
      }
      
    });
  }

  //remove event listener
  static Future<void> removeEventsListener() async {
    CashChangerPlatform.instance.removeEvenstListener();
  }


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
