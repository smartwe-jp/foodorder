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

  static Future<int?> get fixDeposit async {
    return CashChangerPlatform.instance.fixDeposit();
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

  //collectAll
  static Future<int?> collectAll({int bill = 1, int coin = 1}) async {
    return CashChangerPlatform.instance.collectAll(bill: bill, coin: coin);
  }

  static getOposResult(int? result) {
    if (result == null) {
      return OposResult(
          resultCode: HealthResultCode.NONE,
          resultCodeExtended: ResultCodeExtended.NONE);
    }
    if (result > 200) {
      HealthResultCode resultCode = HealthResultCode.OPOS_E_EXTENDED;
      ResultCodeExtended? resultExtended =
          ResultCodeExtended.values.fromIndex(result - 200);
      return OposResult(
          resultCode: resultCode,
          resultCodeExtended: resultExtended ?? ResultCodeExtended.NONE);
    } else {
      HealthResultCode? resultCode = HealthResultCode.values.fromIndex(result>100 ? result - 100 : result);
      return OposResult(
          resultCode: resultCode ?? HealthResultCode.NONE,
          resultCodeExtended: ResultCodeExtended.NONE);
    }
  }


  static Future changerResultNext(
      {required int? resultCode,
      required Function onSuccess,
      required Function onRetry,
      required Function(String) showError}) async {
    OposResult result = getOposResult(resultCode);
    debugPrint("changerResultNext: ${result.resultCode}");
    switch (result.resultCode) {
      case HealthResultCode.OPOS_SUCCESS:
        onSuccess();
        break;
      case HealthResultCode.OPOS_E_CLOSED:
        showError("cash_error_closed");
        break;
      case HealthResultCode.OPOS_E_CLAIMED:
        showError("cash_error_claimed");
        break;
      case HealthResultCode.OPOS_E_NOTCLAIMED:
        showError("cash_error_not_claimed");
        break;
      case HealthResultCode.OPOS_E_DISABLED:
        showError("cash_error_disabled");
        break;
      case HealthResultCode.OPOS_E_ILLEGAL:
        showError("cash_error_illegal");
        break;
      case HealthResultCode.OPOS_E_NOSERVICE:
        showError("cash_error_no_service");
        break;
      case HealthResultCode.OPOS_E_BUSY:
        showError("cash_error_busy");
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        showError("cash_error_no_hardware");
        break;
      case HealthResultCode.OPOS_E_EXTENDED:
        changerResultExtendedNext(
            resultCodeExtended: result.resultCodeExtended,
            onSuccess: onSuccess,
            onRetry: onRetry,
            showError: showError);
        break;
      default:
        showError("cash_error_common");
        break;
    }
  }

  static Future changerResultExtendedNext(
      {required ResultCodeExtended resultCodeExtended,
      required Function onSuccess,
      required Function onRetry,
      required Function(String) showError}) async {
    debugPrint("changerResultExtendedNext: $resultCodeExtended");
    switch (resultCodeExtended) {
      case ResultCodeExtended.OPOS_ECHAN_OVERDISPENSE:
      case ResultCodeExtended.OPOS_ECHAN_TOTALOVER:
        showError("cash_error_over_dispense");
        break;
      case ResultCodeExtended.OPOS_ECHAN_OVER:
        showError("cash_error_over");
        break;
      case ResultCodeExtended.OPOS_ECHAN_IFERROR:
        showError("cash_error_if_error");
        break;
      case ResultCodeExtended.OPOS_ECHAN_SETERROR:
        showError("cash_error_set_error");
        break;
      case ResultCodeExtended.OPOS_ECHAN_CHARGING:
        showError("cash_error_charging");
        break;
      case ResultCodeExtended.OPOS_ECHAN_FULL:
        showError("cash_error_full");
        break;
      case ResultCodeExtended.OPOS_ECHAN_BUSY:
        showError("cash_error_busy");
        break;
      case ResultCodeExtended.OPOS_ECHAN_CASSETTEWAIT:
        showError("cash_error_cassette_wait");
        break;
      case ResultCodeExtended.OPOS_ECHAN_IMPOSSIBLE:
        showError("cash_error_impossible");
        break;
      case ResultCodeExtended.OPOS_ECHAN_DEPOSIT:
        showError("cash_error_deposit");
        break;
      case ResultCodeExtended.OPOS_ECHAN_PAUSEDEPOSIT:
        showError("cash_error_pause_deposit");
        break;
      default:
        showError("cash_error_common");
        break;
    }
  }

  static Map<int, OpenChangerResult> openChangerResultValues = {
    0: OpenChangerResult.OPEN_SUCCESS,
  300: OpenChangerResult.OPOS_OPEN_ERR,
  301: OpenChangerResult.OPOS_OR_ALREADYOPEN,
  302: OpenChangerResult.OPOS_OR_REGBADNAME,
  303: OpenChangerResult.OPOS_OR_REGPROGID,
  304: OpenChangerResult.OPOS_OR_CREATE,
  305: OpenChangerResult.OPOS_OR_BADIF,
  306: OpenChangerResult.OPOS_ORS_FAILEDOPEN,
  307: OpenChangerResult.OPOS_ORS_BADVERSION,
  400: OpenChangerResult.OPOS_OPEN_ERR_SO,
  401: OpenChangerResult.OPOS_ORS_NOPORT,
  402: OpenChangerResult.OPOS_ORS_NOPORTED,
  403: OpenChangerResult.OPOS_ORS_CONFIG,
  450: OpenChangerResult.OPOS_SPECIFIC,
};

  static Future openChangerNext(
      {required int? openResult,
      required Function onSuccess,
      Function? onRetry,
      required Function(String) showError}) async {
    if (openResult == null) {
      showError("cash_error_common");
      return;
    }

    if (openChangerResultValues[openResult] == null) {
      changerResultExtendedNext(
          resultCodeExtended: ResultCodeExtended.values.fromIndex(openResult) ??
              ResultCodeExtended.NONE,
          onSuccess: onSuccess,
          onRetry: onRetry ?? () {},
          showError: showError);
    }

    OpenChangerResult result = openChangerResultValues[openResult] ??
        OpenChangerResult.NONE;
    switch (result) {
      case OpenChangerResult.OPEN_SUCCESS:
      case OpenChangerResult.OPOS_OR_ALREADYOPEN:
        onSuccess();
        break;
      case OpenChangerResult.OPOS_OPEN_ERR:
        showError("cash_error_open");
        showError("打开失败 请重试");
        break;
      case OpenChangerResult.OPOS_OR_REGBADNAME:
        showError("cash_error_reg_bad_name");
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_OR_REGPROGID:
        showError("cash_error_reg_prog_id");
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_OR_CREATE:
        showError("cash_error_create");
        showError("初始化SO有问题 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_OR_BADIF:
        showError("cash_error_bad_if");
        showError("SO库无法使用 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_NOPORT:
        showError("cash_error_no_port");
        showError("端口设置有问题 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_ORS_SENSETHREAD:
        showError("cash_error_sense_thread");
        showError("线程有问题 暂无法处理 上报记录");
        break;
      case OpenChangerResult.OPOS_ORS_CONFIG:
        showError("cash_error_config");
        showError("配置文件有问题 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_EVENTTHRREAD:
        showError("cash_error_event_thread");
        showError("事件处理有问题 暂无法处理 上报记录");
        break;
      case OpenChangerResult.OPOS_ORS_FAILEDOPEN:
        showError("cash_error_failed_open");
        showError("SO库无法使用 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_EVENTCLASS:
        showError("cash_error_event_class");
        showError("事件处理程序有问题 暂无法处理 上报记录");
        break;
      case OpenChangerResult.OPOS_ORS_BADVERSION:
        showError("cash_error_bad_version");
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_OPEN_ERR_SO:
        showError("cash_error_open_so");
        showError("SO库无法使用 提醒处理 重新初始化");
        break;
      case OpenChangerResult.OPOS_ORS_NOPORTED:
        showError("cash_error_no_ported");
        showError("端口设置有问题 提醒处理 打开设置工具");
        break;
      case OpenChangerResult.OPOS_SPECIFIC:
        showError("cash_error_specific");
        showError("打开名称不正确 提醒处理 打开设置工具");
        break;
      default:
        showError("cash_error_unknown");
        //showError("UNKNOWN ERROR $openResult");
        break;
    }
  }
}
