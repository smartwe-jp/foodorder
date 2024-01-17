import 'cash_changer_define.dart';
import 'package:cash_changer/cash_changer_platform_interface.dart';
import 'package:flutter/foundation.dart';

class CashChanger {
  static int? putMoney = 0;
  static String putCurrency = "";
  static String currencyString = ""; //币种 

  //监听几种状态
  static String payCubeStopCashStatus = "Error";
  static String payCubeOutMoneyStatus = "Error";
  static String payCubeEndTradeStatus = "Error";

  static Function(int)? onGetPutMoneyStringChange;
  static Function(OpenChangerResult)? onOpenResultReponse;

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

  //changer di status
  static Future<String?> changerDIStatus(int pData) async {
    return CashChangerPlatform.instance.changerDIStatus(pData);
  }

  //dispense cash
  static Future<int?> dispenseCash(String cashCounts) async {
    return CashChangerPlatform.instance.dispenseCash(cashCounts);
  }



  static getOposResult(int? result) {
    if (result == null) {
      return OposResult(resultCode:HealthResultCode.NONE, resultCodeExtended:ResultCodeExtended.NONE);
    }
    if (result > 200) {
       HealthResultCode resultCode = HealthResultCode.OPOS_E_EXTENDED;
       ResultCodeExtended? resultExtended = ResultCodeExtended.values.fromIndex(result-200);
       return OposResult(resultCode:resultCode, 
                        resultCodeExtended:resultExtended ?? ResultCodeExtended.NONE);
    } else {
      HealthResultCode? resultCode = HealthResultCode.values.fromIndex(result);
      return OposResult(resultCode:resultCode ?? HealthResultCode.NONE, 
                        resultCodeExtended:ResultCodeExtended.NONE);
    }
  }

  static Future changerResultNext(
      {required int? resultCode,
      required Function onSuccess,
      required Function onRetry,
      required Function(String) showError}) async {    
    OposResult result = getOposResult(resultCode);
    switch (result.resultCode) {
      case HealthResultCode.OPOS_SUCCESS:
        onSuccess();
        break;
      case HealthResultCode.OPOS_E_CLOSED:
        break;
      case HealthResultCode.OPOS_E_CLAIMED:
        break;
      case HealthResultCode.OPOS_E_NOTCLAIMED:
        break;
      case HealthResultCode.OPOS_E_DISABLED:
        break;
      case HealthResultCode.OPOS_E_ILLEGAL:
        break;
      case HealthResultCode.OPOS_E_BUSY:
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        break;
      case HealthResultCode.OPOS_E_EXTENDED:
        changerResultExtendedNext(
            resultCodeExtended: result.resultCodeExtended,
            onSuccess: onSuccess,
            onRetry: onRetry,
            showError: showError);
        break;
      default:
        showError("UNKNOWN ERROR");
        break;
    }
  }

  static Future changerResultExtendedNext(
      {required ResultCodeExtended resultCodeExtended,
      required Function onSuccess,
      required Function onRetry,
      required Function(String) showError}) async {

    switch (resultCodeExtended) {
      case ResultCodeExtended.OPOS_ECHAN_OVERDISPENSE:
        break;
      case ResultCodeExtended.OPOS_ECHAN_OVER:
        break;
      case ResultCodeExtended.OPOS_ECHAN_IFERROR:
        break;
      case ResultCodeExtended.OPOS_ECHAN_SETERROR:
        break;
      case ResultCodeExtended.OPOS_ECHAN_CHARGING:
        break;
      case ResultCodeExtended.OPOS_ECHAN_FULL:
        break;
      case ResultCodeExtended.OPOS_ECHAN_BUSY:
        break;
      case ResultCodeExtended.OPOS_ECHAN_CASSETTEWAIT:
        break;
      case ResultCodeExtended.OPOS_ECHAN_IMPOSSIBLE:
        break;
      case ResultCodeExtended.OPOS_ECHAN_DEPOSIT:
        break;
      case ResultCodeExtended.OPOS_ECHAN_PAUSEDEPOSIT:
        break;
      default:
        showError("UNKNOWN ERROR");
        break;
    }
  }

  static Future openChangerNext(
      {required int? openResult,
      required Function onSuccess,
      Function? onRetry,
      required Function(String) showError}) async {
        if (openResult == null) {
          showError("UNKNOWN ERROR");
          return;
        }
        OpenChangerResult result = OpenChangerResult.values.fromIndex(openResult) ?? OpenChangerResult.NONE;
    switch (result) {
      case OpenChangerResult.OPEN_SUCCESS:
      case OpenChangerResult.OPOS_OR_ALREADYOPEN:
        onSuccess();
        break;
      case OpenChangerResult.OPOS_OR_REGBADNAME:
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_OR_REGPROGID:
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_OR_CREATE:
        showError("初始化SO有问题 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_OR_BADIF:
        showError("SO库无法使用 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_NOPORT:
        showError("端口设置有问题 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_ORS_SENSETHREAD:
        showError("线程有问题 暂无法处理 上报记录");
        break;
      case OpenChangerResult.OPOS_ORS_CONFIG:
        showError("配置文件有问题 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_EVENTTHRREAD:
        showError("事件处理有问题 暂无法处理 上报记录");
        break;
      case OpenChangerResult.OPOS_ORS_FAILEDOPEN:
        showError("SO库无法使用 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_EVENTCLASS:
        showError("事件处理程序有问题 暂无法处理 上报记录");
        break;
      case OpenChangerResult.OPOS_ORS_BADVERSION:
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      default:
        showError("UNKNOWN ERROR");
        break;
    }
  }

}
