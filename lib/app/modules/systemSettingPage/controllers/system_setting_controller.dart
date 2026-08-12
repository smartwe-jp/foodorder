

import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/systemSettingPage/controllers/system_setting_page_controller.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/SetPassword.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/SetPosIp.dart';
import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get.dart';

extension SystemSettingPageControllerExtension on SystemSettingPageController {
  showScreenCallSettingDialog() async {
    Get.dialog(
        SetPosIpPage(
          posIp: machineInfo.wlan_panel_print_ip,
          posPort: machineInfo.wlan_panel_print_port,
          showRadio:0,
          onConfrimClick: (String posIp, String posPort) {
            
            updateScreenCallSetting(
                posIp: posIp,
                posPort: posPort);

          },
        )
    );
  }

  showPosSettingDialog() async {
    Get.dialog(
        SetPosIpPage(
          posIp: machineInfo.pos_ip,
          posPort: machineInfo.pos_port,
          showRadio:0,
          onConfrimClick: (String posIp, String posPort) {
            
            updatePosSetting(
                posIp: posIp,
                posPort: posPort);

          },
        )
    );
  }

  showSettingPassword() async {
    Get.dialog(
        SetPasswordPage()
    );
  }

  updatePosSetting({String? posIp, String? posPort, bool? isAllowPos}) async {
    if (posIp != null) {
      machineInfo.pos_ip = posIp;
      machineInfo.posSettingInfo['posIp'] = posIp;
    }
    if (posPort != null) {
      machineInfo.pos_port = posPort;
      machineInfo.posSettingInfo['posPort'] = posPort;
    }

    if (isAllowPos != null) {
      machineInfo.isAllowPos = isAllowPos ? '1' : '0';
      machineInfo.posSettingInfo['allowPos'] = isAllowPos;
      await _updateSystemSetting("isAllowPos", machineInfo.isAllowPos);
    }

    await HomeServices.updatePosSettingInfo(machineInfo.posSettingInfo);
    await machineInfo.updateMachineSettingInfo();
    update();
  }

  Future<void> _updateSystemSetting(String key, dynamic value) async {
    if (systemSettingData.containsKey(key)) {
      systemSettingData[key] = value;
      await HomeServices.updateSystemSettingInfo(systemSettingData);
    } else {
      print('Key $key does not exist in systemSettingData.');
    }
  }

  updateScreenCallSetting({String? posIp, String? posPort, bool? isAllowScreenCall}) async {


    if (posIp != null) {
      machineInfo.wlan_panel_print_ip = posIp;
      machineInfo.screenCallSetting['wlanPrintIp'] = posIp;
    }
    if (posPort != null) {
      machineInfo.wlan_panel_print_port = posPort;
      machineInfo.screenCallSetting['wlanPrintPort'] = posPort;
    }
    if (isAllowScreenCall != null) {
      machineInfo.isAllowScreenCall = isAllowScreenCall;
      machineInfo.screenCallSetting['isAllowScreenCall'] = isAllowScreenCall;
    }

    await HomeServices.updateWlanPanelPrintSettingInfo(machineInfo.screenCallSetting);
    await machineInfo.updateMachineSettingInfo();
    update();

  }


}


extension MachineInfoExtension on  MachineInfoController {

}
