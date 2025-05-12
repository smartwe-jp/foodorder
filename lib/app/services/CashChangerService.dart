
import 'dart:convert';

import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/GetxStorage.dart';
import 'package:foodorder/app/services/Storage.dart';
import 'package:logging/logging.dart';

class Cashchangerservice {

  static final logger = Logger('Cashchangerservice');

  static checkMachineFlow() async {
    bool canUse = false;

    bool machineStatus = await checkChangerStatus();
    logger.info("checkMachineFlow machineStatus = $machineStatus");
    if (machineStatus == false) {
      canUse = await openCashChanger();
      if (canUse) {
        //设置当前机器状态
        Map cashShowData = {
          "isCash": true,
        };
        Storage.setString('isCashState', json.encode(cashShowData));
        GetxStorage.setData('isCashState', json.encode(cashShowData));
        return canUse;
      } else {
        return canUse;
      }
    } else {
      return true;
    }
  }

  static checkChangerStatus() async {
    int? resultCode = await CashChanger.checkChangerStatus;
    logger.info("checkChangerStatus resultCode = $resultCode");
    if (resultCode == null) {
      return false;
    }
    if (resultCode == 0) {
      resultCode = 100;
    }
    HealthResultCode resultCodeEnum = HealthResultCode.values[resultCode - 100];
    logger.info("checkChangerStatus resultCodeEnum = $resultCodeEnum");
    switch (resultCodeEnum) {
      case HealthResultCode.OPOS_SUCCESS:
        return true;
      case HealthResultCode.OPOS_E_ILLEGAL:
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        return false;
      case HealthResultCode.OPOS_E_BUSY:
        await Future.delayed(Duration(seconds: 5));
        await checkChangerStatus();
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        return false;
      default:
        return false;
    }
  }

  static openCashChanger() async {
    bool openStatus = false;
    await CashChanger.openCashChanger(
      onSuccess: () async {
        openStatus = true;
      },
      catchError: (retCode, error) async {
        logger.info("openCashChanger retCode = $retCode");
        openStatus = false;
        if (retCode == 225) {
          //已打开 // clearinput?
          openStatus = true;
        }
      },
    );
    return openStatus;
  }

}