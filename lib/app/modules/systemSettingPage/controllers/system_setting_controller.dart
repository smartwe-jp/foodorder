

import 'dart:convert';

import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/systemSettingPage/controllers/system_setting_page_controller.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/SetPassword.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/SetPosIp.dart';
import 'package:foodorder/app/services/GetxStorage.dart';
import 'package:foodorder/app/services/HomeServices.dart';
import 'package:foodorder/app/services/Storage.dart';
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

  updatePosSetting({String? posIp, String? posPort, bool? isAllowPos}) {
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
      _updateSystemSetting("isAllowPos", machineInfo.isAllowPos);
    }

    HomeServices.updatePosSettingInfo(machineInfo.posSettingInfo);
    machineInfo.updateMachineSettingInfo();
    update();
  }

  void _updateSystemSetting(String key, dynamic value) {
    if (systemSettingData.containsKey(key)) {
      systemSettingData[key] = value;
      Storage.setString(
          'smartwe_systemSetting', json.encode(systemSettingData));
      GetxStorage.setData(
          'smartwe_systemSetting', json.encode(systemSettingData));
    } else {
      print('Key $key does not exist in systemSettingData.');
    }
    machineInfo.updateMachineSettingInfo(settingInfo: systemSettingData);
    update();
  }

  updateScreenCallSetting({String? posIp, String? posPort, bool? isAllowScreenCall}) {


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

    HomeServices.updateWlanPanelPrintSettingInfo(machineInfo.screenCallSetting);
    machineInfo.updateMachineSettingInfo();
    update();

  }


}


extension MachineInfoExtension on  MachineInfoController {

}
