import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/models/machine_capabilities.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';

class Cashchangerservice {
  static final MachineInfoController machineInfo =
      Get.find<MachineInfoController>();

  static final logger = Logger('Cashchangerservice');

  static checkMachineState() async {
    final runtime = Get.find<MachineRuntimeService>();
    if (runtime.cashMachineEnabled &&
        runtime.capabilities.cashMachineDriver ==
            CashMachineDriver.cashChanger) {
      machineInfo.isChecking = true;
      machineInfo.update(['selectPayment']);
      var result = await Cashchangerservice.checkMachineFlow();
      logger.info('-- checkMachineState result = $result --');
      machineInfo.isChecking = false;
      if (result) {
        runtime.markCashMachineReady();
      } else {
        runtime.markCashMachineFailed();
      }
      machineInfo.update(['selectPayment']);
    }
  }

  static checkMachineFlow() async {
    bool canUse = false;

    bool machineStatus = await checkChangerStatus();
    logger.info("checkMachineFlow machineStatus = $machineStatus");
    if (machineStatus == false) {
      canUse = await openCashChanger();
      return canUse;
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
    final resultCodeEnum = HealthResultCode.values.fromIndex(resultCode - 100);
    if (resultCodeEnum == null) return false;
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
        return await checkChangerStatus();
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
